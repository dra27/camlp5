(* camlp5r *)
(* This file has been generated by program: do not edit! *)
(* Copyright (c) INRIA 2007 *)

type 'a t =
  { pr_name : string;
    mutable pr_fun : string -> 'a pr_fun;
    mutable pr_levels : 'a pr_level list }
and 'a pr_level = { pr_label : string; mutable pr_rules : 'a pr_rule }
and 'a pr_rule = ('a, 'a pr_fun -> 'a pr_fun -> pr_context -> string) Extfun.t
and 'a pr_fun = pr_context -> 'a -> string
and pr_context = { ind : int; bef : string; aft : string; dang : string };;

type position =
    First
  | Last
  | Before of string
  | After of string
  | Level of string
;;

let add_lev (lab, extf) levs =
  let lab =
    match lab with
      Some lab -> lab
    | None -> ""
  in
  let lev = {pr_label = lab; pr_rules = extf Extfun.empty} in lev :: levs
;;

let extend pr pos levs =
  match pos with
    None ->
      let levels = List.fold_right add_lev levs pr.pr_levels in
      pr.pr_levels <- levels
  | Some (Level lab) ->
      let levels =
        let rec loop =
          function
            pr_lev :: pr_levs ->
              if lab = pr_lev.pr_label then
                match levs with
                  (_, extf) :: levs ->
                    let lev = {pr_lev with pr_rules = extf pr_lev.pr_rules} in
                    let levs = List.fold_right add_lev levs pr_levs in
                    lev :: levs
                | [] -> pr_lev :: pr_levs
              else pr_lev :: loop pr_levs
          | [] -> failwith ("level " ^ lab ^ " not found")
        in
        loop pr.pr_levels
      in
      pr.pr_levels <- levels
  | Some (After lab) ->
      let levels =
        let rec loop =
          function
            pr_lev :: pr_levs ->
              if lab = pr_lev.pr_label then
                let pr_levs = List.fold_right add_lev levs pr_levs in
                pr_lev :: pr_levs
              else pr_lev :: loop pr_levs
          | [] -> failwith ("level " ^ lab ^ " not found")
        in
        loop pr.pr_levels
      in
      pr.pr_levels <- levels
  | Some _ -> failwith "not impl EXTEND_PRINTER entry with at level parameter"
;;

let pr_fun name pr lab =
  let rec loop app =
    function
      [] ->
        (fun pc z ->
           failwith
             (Printf.sprintf "unable to print %s%s" name
                (if lab = "" then "" else " \"" ^ lab ^ "\"")))
    | lev :: levl ->
        if lab = "" || app || lev.pr_label = lab then
          let next = loop true levl in
          let rec curr pc z = Extfun.apply lev.pr_rules z curr next pc in curr
        else loop app levl
  in
  loop false pr.pr_levels
;;

let make name =
  let pr =
    {pr_name = name;
     pr_fun = (fun _ -> raise (Match_failure ("eprinter.ml", 89, 37)));
     pr_levels = []}
  in
  pr.pr_fun <- pr_fun name pr; pr
;;

let clear pr = pr.pr_levels <- []; pr.pr_fun <- pr_fun pr.pr_name pr;;

let apply_level pr lname pc z = pr.pr_fun lname pc z;;
let apply pr pc z = pr.pr_fun "" pc z;;

let empty_pc = {ind = 0; bef = ""; aft = ""; dang = ""};;

let print pr =
  List.iter
    (fun lev ->
       Printf.printf "level \"%s\"\n" lev.pr_label;
       Extfun.print lev.pr_rules;
       flush stdout)
    pr.pr_levels
;;

let tab ind = String.make ind ' ';;

let sprint_break nspaces offset pc f g =
  Pretty.horiz_vertic
    (fun () ->
       let sp = String.make nspaces ' ' in
       Pretty.sprintf "%s%s%s" (f {pc with aft = ""}) sp
         (g {pc with bef = ""}))
    (fun () ->
       let s1 = f {pc with aft = ""} in
       let s2 =
         g {pc with ind = pc.ind + offset; bef = tab (pc.ind + offset)}
       in
       Pretty.sprintf "%s\n%s" s1 s2)
;;

let sprint_break_all force_newlines pc f fl =
  Pretty.horiz_vertic
    (fun () ->
       if force_newlines then Pretty.sprintf "\n"
       else
         let rec loop s =
           function
             (sp, off, f) :: fl ->
               let s =
                 Pretty.sprintf "%s%s%s" s (String.make sp ' ')
                   (f
                      {pc with bef = "";
                       aft = if fl = [] then pc.aft else ""})
               in
               loop s fl
           | [] -> s
         in
         loop (f (if fl = [] then pc else {pc with aft = ""})) fl)
    (fun () ->
       let rec loop s =
         function
           (sp, off, f) :: fl ->
             let s =
               Pretty.sprintf "%s\n%s" s
                 (f
                    {pc with ind = pc.ind + off; bef = tab (pc.ind + off);
                     aft = if fl = [] then pc.aft else ""})
             in
             loop s fl
         | [] -> s
       in
       loop (f (if fl = [] then pc else {pc with aft = ""})) fl)
;;
