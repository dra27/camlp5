(* camlp5r *)
(* This file has been generated by program: do not edit! *)
(* Copyright (c) INRIA 2007 *)

open Gramext;;

let trace =
  ref (try let _ = Sys.getenv "GRAMTEST" in true with Not_found -> false)
;;

(* LR(0) test (experiment) *)

let not_impl name x =
  let desc =
    if Obj.tag (Obj.repr x) = Obj.tag (Obj.repr "") then
      Printf.sprintf "\"%s\"" (Obj.magic x)
    else if Obj.is_block (Obj.repr x) then
      "tag = " ^ string_of_int (Obj.tag (Obj.repr x))
    else "int_val = " ^ string_of_int (Obj.magic x)
  in
  Printf.sprintf "\"gramalgo, not impl: %s; %s\"" name (String.escaped desc)
;;

module Fifo =
  struct
    type 'a t = { mutable bef : 'a list; mutable aft : 'a list };;
    let add x f = {bef = x :: f.bef; aft = f.aft};;
    let get f =
      if f.aft = [] then begin f.aft <- List.rev f.bef; f.bef <- [] end;
      match f.aft with
        x :: aft -> Some (x, {bef = f.bef; aft = aft})
      | [] -> None
    ;;
    let empty () = {bef = []; aft = []};;
    let single x = {bef = []; aft = [x]};;
    let to_list f = List.rev_append f.bef f.aft;;
  end
;;

type gram_symb =
    GS_term of string
  | GS_nterm of string
;;

let name_of_entry entry lev = entry.ename ^ "-" ^ string_of_int lev;;

let fold_rules_of_level f name elev init =
  let rec do_level accu lev =
    let accu =
      do_tree [] accu
        (Node {node = Sself; son = lev.lsuffix; brother = DeadEnd})
    in
    do_tree [] accu lev.lprefix
  and do_tree r accu =
    function
      Node n ->
        let accu = do_tree (n.node :: r) accu n.son in
        do_tree r accu n.brother
    | LocAct (_, _) -> f (name, List.rev r) accu
    | DeadEnd -> accu
  in
  do_level init elev
;;

let rec gram_symb cnt to_treat e levn lev s sl =
  match s with
    Sfacto s -> gram_symb cnt to_treat e levn lev s sl
  | Snterm e ->
      to_treat := (e, 0) :: !to_treat; GS_nterm (name_of_entry e 0) :: sl
  | Snterml (e, lev_name) ->
      let levn =
        match e.edesc with
          Dlevels levs ->
            let rec loop n =
              function
                lev :: levs ->
                  begin match lev.lname with
                    Some s -> if s = lev_name then n else loop (n + 1) levs
                  | None -> loop (n + 1) levs
                  end
              | [] -> n
            in
            loop 0 levs
        | Dparser _ -> 1
      in
      to_treat := (e, levn) :: !to_treat;
      GS_nterm (name_of_entry e levn) :: sl
  | Slist0 _ ->
      incr cnt; let n = "x-list0-" ^ string_of_int !cnt in GS_nterm n :: sl
  | Slist0sep (_, _) ->
      incr cnt; let n = "x-list0sep-" ^ string_of_int !cnt in GS_nterm n :: sl
  | Slist1 _ ->
      incr cnt; let n = "x-list1-" ^ string_of_int !cnt in GS_nterm n :: sl
  | Slist1sep (_, _) ->
      incr cnt; let n = "x-list1sep-" ^ string_of_int !cnt in GS_nterm n :: sl
  | Sopt s ->
      incr cnt; let n = "x-opt-" ^ string_of_int !cnt in GS_nterm n :: sl
  | Stoken p ->
      let n =
        match p with
          "", prm -> "\"" ^ prm ^ "\""
        | con, "" -> con
        | con, prm -> "(" ^ con ^ " \"" ^ prm ^ "\")"
      in
      GS_term n :: sl
  | Sself ->
      let n =
        match sl with
          [] ->
            begin match lev.assoc with
              NonA | LeftA -> levn + 1
            | RightA -> levn
            end
        | _ -> 0
      in
      if n <> levn then to_treat := (e, n) :: !to_treat;
      GS_nterm (name_of_entry e n) :: sl
  | Stree _ ->
      incr cnt; let n = "x-rules-" ^ string_of_int !cnt in GS_nterm n :: sl
  | Svala (ls, s) ->
      incr cnt; let n = "x-v-" ^ string_of_int !cnt in GS_nterm n :: sl
  | s -> GS_term (not_impl "gram_symb" s) :: sl
;;

let create_closed_rules entry levn =
  let cnt = ref 0 in
  let treat_entry rules to_treat entry levn =
    match entry.edesc with
      Dlevels [] -> rules, to_treat
    | Dlevels elev ->
        let lev =
          try List.nth elev levn with
            Failure _ ->
              {assoc = NonA; lname = None; lsuffix = DeadEnd;
               lprefix = DeadEnd}
        in
        let to_treat_r = ref to_treat in
        let f (name, r) accu =
          let sl =
            match r with
              Sself :: r ->
                let s =
                  let n =
                    match lev.assoc with
                      NonA | RightA ->
                        to_treat_r := (entry, levn + 1) :: !to_treat_r;
                        levn + 1
                    | LeftA -> levn
                  in
                  GS_nterm (name_of_entry entry n)
                in
                let sl =
                  List.fold_right (gram_symb cnt to_treat_r entry levn lev) r
                    []
                in
                s :: sl
            | r ->
                List.fold_right (gram_symb cnt to_treat_r entry levn lev) r []
          in
          Fifo.add (name, sl) accu
        in
        let rules =
          fold_rules_of_level f (name_of_entry entry levn) lev rules
        in
        let rules =
          match
            try Some (List.nth elev (levn + 1)) with Failure _ -> None
          with
            Some _ ->
              let r =
                name_of_entry entry levn,
                [GS_nterm (name_of_entry entry (levn + 1))]
              in
              to_treat_r := (entry, levn + 1) :: !to_treat_r; Fifo.add r rules
          | None -> rules
        in
        rules, !to_treat_r
    | Dparser p -> rules, to_treat
  in
  let rec loop rules treated =
    function
      (entry, levn) :: to_treat ->
        if List.mem (entry.ename, levn) treated then
          loop rules treated to_treat
        else
          let treated = (entry.ename, levn) :: treated in
          let (rules, to_treat) = treat_entry rules to_treat entry levn in
          loop rules treated to_treat
    | [] -> Fifo.to_list rules
  in
  loop (Fifo.empty ()) [] [entry, levn]
;;

let sprint_symb =
  function
    GS_term s -> s
  | GS_nterm s -> s
;;

let eprint_rule (n, sl) =
  Printf.eprintf "%s ->" n;
  if sl = [] then Printf.eprintf " ε"
  else List.iter (fun s -> Printf.eprintf " %s" (sprint_symb s)) sl;
  Printf.eprintf "\n"
;;

let lr0 entry lev =
  Printf.eprintf "LR(0) %s %d\n" entry.ename lev;
  flush stderr;
  let rl = create_closed_rules entry lev in
  Printf.eprintf "%d rules\n\n" (List.length rl);
  flush stderr;
  List.iter eprint_rule rl;
  Printf.eprintf "\n";
  flush stderr
;;
