(* camlp5r *)
(***********************************************************************)
(*                                                                     *)
(*                             Camlp5                                  *)
(*                                                                     *)
(*                Daniel de Rauglaudre, INRIA Rocquencourt             *)
(*                                                                     *)
(*  Copyright 2007 Institut National de Recherche en Informatique et   *)
(*  Automatique.  Distributed only by permission.                      *)
(*                                                                     *)
(***********************************************************************)

(* This file has been generated by program: do not edit! *)

type glue = LO | RO | LR | NO;;
type pretty =
    S of glue * string
  | Hbox of pretty Stream.t
  | HVbox of pretty Stream.t
  | HOVbox of pretty Stream.t
  | HOVCbox of pretty Stream.t
  | Vbox of pretty Stream.t
  | BEbox of pretty Stream.t
  | BEVbox of pretty Stream.t
  | LocInfo of Stdpp.location * pretty
;;
type prettyL =
    SL of int * glue * string
  | HL of prettyL list
  | BL of prettyL list
  | PL of prettyL list
  | QL of prettyL list
  | VL of prettyL list
  | BE of prettyL list
  | BV of prettyL list
  | LI of (string * int * int) * prettyL
;;
type getcomm = Stdpp.location -> int -> int -> string * int * int * int;;

let quiet = ref true;;
let maxl = ref 20;;
let dt = ref 2;;
let tol = ref 1;;
let sp = ref ' ';;
let last_ep = ref 0;;
let getcomm = ref (fun _ _ _ -> "", 0, 0, 0);;
let prompt = ref "";;
let print_char_fun = ref (output_char stdout);;
let print_string_fun = ref (output_string stdout);;
let print_newline_fun = ref (fun () -> output_char stdout '\n');;
let lazy_tab = ref (-1);;

let flush_tab () =
  if !lazy_tab >= 0 then
    begin
      !print_newline_fun ();
      !print_string_fun !prompt;
      for i = 1 to !lazy_tab do !print_char_fun !sp done;
      lazy_tab := -1
    end
;;
let print_newline_and_tab tab = lazy_tab := tab;;
let print_char c = flush_tab (); !print_char_fun c;;
let print_string s = flush_tab (); !print_string_fun s;;

let rec print_spaces nsp = for i = 1 to nsp do print_char !sp done;;

let end_with_tab s =
  let rec loop i =
    if i >= 0 then if s.[i] = ' ' then loop (i - 1) else s.[i] = '\n'
    else false
  in
  loop (String.length s - 1)
;;

let print_comment tab s nl_bef tab_bef empty_stmt =
  if s = "" then ()
  else
    let (tab_aft, i_bef_tab) =
      let rec loop tab_aft i =
        if i >= 0 && s.[i] = ' ' then loop (tab_aft + 1) (i - 1)
        else tab_aft, i
      in
      loop 0 (String.length s - 1)
    in
    let tab_bef = if nl_bef > 0 then tab_bef else tab in
    let len = if empty_stmt then i_bef_tab else String.length s in
    let rec loop i =
      if i = len then ()
      else
        begin
          !print_char_fun s.[i];
          let i =
            if s.[i] = '\n' && (i + 1 = len || s.[i+1] <> '\n') then
              let delta_ind =
                if i = i_bef_tab then tab - tab_aft else tab - tab_bef
              in
              if delta_ind >= 0 then
                begin
                  for i = 1 to delta_ind do !print_char_fun ' ' done;
                  i + 1
                end
              else
                let rec loop cnt i =
                  if cnt = 0 then i
                  else if i = len then i
                  else if s.[i] = ' ' then loop (cnt + 1) (i + 1)
                  else i
                in
                loop delta_ind (i + 1)
            else i + 1
          in
          loop i
        end
    in
    loop 0
;;

let string_np pos np = pos + np;;

let trace_ov pos =
  if not !quiet && pos > !maxl then
    begin
      prerr_string "<W> prettych: overflow (length = ";
      prerr_int pos;
      prerr_endline ")"
    end
;;

let tolerate tab pos spc = pos + spc <= tab + !dt + !tol;;

let h_print_string pos spc np x =
  let npos = string_np (pos + spc) np in
  print_spaces spc; print_string x; npos
;;

let n_print_string pos spc np x =
  print_spaces spc; print_string x; string_np (pos + spc) np
;;

let rec hnps (pos, spc as ps) =
  function
    SL (np, RO, _) -> string_np pos np, 1
  | SL (np, LO, _) -> string_np (pos + spc) np, 0
  | SL (np, NO, _) -> string_np pos np, 0
  | SL (np, LR, _) -> string_np (pos + spc) np, 1
  | HL x -> hnps_list ps x
  | BL x -> hnps_list ps x
  | PL x -> hnps_list ps x
  | QL x -> hnps_list ps x
  | VL [x] -> hnps ps x
  | VL [] -> ps
  | VL x -> !maxl + 1, 0
  | BE x -> hnps_list ps x
  | BV x -> !maxl + 1, 0
  | LI (_, x) -> hnps ps x
and hnps_list (pos, _ as ps) pl =
  if pos > !maxl then !maxl + 1, 0
  else
    match pl with
      p :: pl -> hnps_list (hnps ps p) pl
    | [] -> ps
;;

let rec first =
  function
    SL (_, _, s) -> Some s
  | HL x -> first_in_list x
  | BL x -> first_in_list x
  | PL x -> first_in_list x
  | QL x -> first_in_list x
  | VL x -> first_in_list x
  | BE x -> first_in_list x
  | BV x -> first_in_list x
  | LI (_, x) -> first x
and first_in_list =
  function
    p :: pl ->
      begin match first p with
        Some p -> Some p
      | None -> first_in_list pl
      end
  | [] -> None
;;

let first_is_too_big tab p =
  match first p with
    Some s -> tab + String.length s >= !maxl
  | None -> false
;;

let too_long tab x p =
  if first_is_too_big tab p then false
  else let (pos, spc) = hnps x p in pos > !maxl
;;

let rec has_comment =
  function
    LI ((comm, nl_bef, tab_bef), x) :: pl ->
      comm <> "" || has_comment (x :: pl)
  | (HL x | BL x | PL x | QL x | VL x | BE x | BV x) :: pl ->
      has_comment x || has_comment pl
  | SL (_, _, _) :: pl -> has_comment pl
  | [] -> false
;;

let rec hprint_pretty tab pos spc =
  function
    SL (np, RO, x) -> h_print_string pos 0 np x, 1
  | SL (np, LO, x) -> h_print_string pos spc np x, 0
  | SL (np, NO, x) -> h_print_string pos 0 np x, 0
  | SL (np, LR, x) -> h_print_string pos spc np x, 1
  | HL x -> hprint_box tab pos spc x
  | BL x -> hprint_box tab pos spc x
  | PL x -> hprint_box tab pos spc x
  | QL x -> hprint_box tab pos spc x
  | VL [x] -> hprint_pretty tab pos spc x
  | VL [] -> pos, spc
  | VL x -> hprint_box tab pos spc x
  | BE x -> hprint_box tab pos spc x
  | BV x -> invalid_arg "hprint_pretty"
  | LI ((comm, nl_bef, tab_bef), x) ->
      if !lazy_tab >= 0 then
        begin
          for i = 2 to nl_bef do !print_char_fun '\n' done;
          flush_tab ()
        end;
      print_comment tab comm nl_bef tab_bef false;
      hprint_pretty tab pos spc x
and hprint_box tab pos spc =
  function
    p :: pl ->
      let (pos, spc) = hprint_pretty tab pos spc p in
      hprint_box tab pos spc pl
  | [] -> pos, spc
;;

let rec print_pretty tab pos spc =
  function
    SL (np, RO, x) -> n_print_string pos 0 np x, 1
  | SL (np, LO, x) -> n_print_string pos spc np x, 0
  | SL (np, NO, x) -> n_print_string pos 0 np x, 0
  | SL (np, LR, x) -> n_print_string pos spc np x, 1
  | HL x -> print_horiz tab pos spc x
  | BL x as p -> print_horiz_vertic tab pos spc (too_long tab (pos, spc) p) x
  | PL x as p -> print_paragraph tab pos spc (too_long tab (pos, spc) p) x
  | QL x as p -> print_sparagraph tab pos spc (too_long tab (pos, spc) p) x
  | VL x -> print_vertic tab pos spc x
  | BE x as p -> print_begin_end tab pos spc (too_long tab (pos, spc) p) x
  | BV x -> print_beg_end tab pos spc x
  | LI ((comm, nl_bef, tab_bef), x) ->
      if !lazy_tab >= 0 then
        begin
          for i = 2 to nl_bef do !print_char_fun '\n' done;
          if comm <> "" && nl_bef = 0 then
            for i = 1 to tab_bef do !print_char_fun ' ' done
          else if comm = "" && x = BL [] then lazy_tab := -1
          else flush_tab ()
        end;
      print_comment tab comm nl_bef tab_bef (x = BL []);
      if comm <> "" && nl_bef = 0 then
        if end_with_tab comm then lazy_tab := -1 else flush_tab ();
      print_pretty tab pos spc x
and print_horiz tab pos spc =
  function
    p :: pl ->
      let (npos, nspc) = print_pretty tab pos spc p in
      if match pl with
           [] -> true
         | _ -> false
      then
        npos, nspc
      else print_horiz tab npos nspc pl
  | [] -> pos, spc
and print_horiz_vertic tab pos spc ov pl =
  if ov || has_comment pl then print_vertic tab pos spc pl
  else hprint_box tab pos spc pl
and print_vertic tab pos spc =
  function
    p :: pl ->
      let (npos, nspc) = print_pretty tab pos spc p in
      if match pl with
           [] -> true
         | _ -> false
      then
        npos, nspc
      else if tolerate tab npos nspc then
        begin print_spaces nspc; print_vertic_rest (npos + nspc) pl end
      else
        begin
          print_newline_and_tab (tab + !dt);
          print_vertic_rest (tab + !dt) pl
        end
  | [] -> pos, spc
and print_vertic_rest tab =
  function
    p :: pl ->
      let (pos, spc) = print_pretty tab tab 0 p in
      if match pl with
           [] -> true
         | _ -> false
      then
        pos, spc
      else begin print_newline_and_tab tab; print_vertic_rest tab pl end
  | [] -> tab, 0
and print_paragraph tab pos spc ov pl =
  if has_comment pl then print_vertic tab pos spc pl
  else if ov then print_parag tab pos spc pl
  else hprint_box tab pos spc pl
and print_parag tab pos spc =
  function
    p :: pl ->
      let (npos, nspc) = print_pretty tab pos spc p in
      if match pl with
           [] -> true
         | _ -> false
      then
        npos, nspc
      else if npos == tab then print_parag_rest tab tab 0 pl
      else if too_long tab (pos, spc) p then
        begin
          print_newline_and_tab (tab + !dt);
          print_parag_rest (tab + !dt) (tab + !dt) 0 pl
        end
      else if tolerate tab npos nspc then
        begin
          print_spaces nspc;
          print_parag_rest (npos + nspc) (npos + nspc) 0 pl
        end
      else print_parag_rest (tab + !dt) npos nspc pl
  | [] -> pos, spc
and print_parag_rest tab pos spc =
  function
    p :: pl ->
      let (pos, spc) =
        if pos > tab && too_long tab (pos, spc) p then
          begin print_newline_and_tab tab; tab, 0 end
        else pos, spc
      in
      let (npos, nspc) = print_pretty tab pos spc p in
      if match pl with
           [] -> true
         | _ -> false
      then
        npos, nspc
      else
        let (pos, spc) =
          if npos > tab && too_long tab (pos, spc) p then
            begin print_newline_and_tab tab; tab, 0 end
          else npos, nspc
        in
        print_parag_rest tab pos spc pl
  | [] -> pos, spc
and print_sparagraph tab pos spc ov pl =
  if has_comment pl then print_vertic tab pos spc pl
  else if ov then print_sparag tab pos spc pl
  else hprint_box tab pos spc pl
and print_sparag tab pos spc =
  function
    p :: pl ->
      let (npos, nspc) = print_pretty tab pos spc p in
      if match pl with
           [] -> true
         | _ -> false
      then
        npos, nspc
      else if tolerate tab npos nspc then
        begin
          print_spaces nspc;
          print_sparag_rest (npos + nspc) (npos + nspc) 0 pl
        end
      else print_sparag_rest (tab + !dt) npos nspc pl
  | [] -> pos, spc
and print_sparag_rest tab pos spc =
  function
    p :: pl ->
      let (pos, spc) =
        if pos > tab && too_long tab (pos, spc) p then
          begin print_newline_and_tab tab; tab, 0 end
        else pos, spc
      in
      let (npos, nspc) = print_pretty tab pos spc p in
      if match pl with
           [] -> true
         | _ -> false
      then
        npos, nspc
      else print_sparag_rest tab npos nspc pl
  | [] -> pos, spc
and print_begin_end tab pos spc ov pl =
  if ov || has_comment pl then print_beg_end tab pos spc pl
  else hprint_box tab pos spc pl
and print_beg_end tab pos spc =
  function
    p :: pl ->
      let (npos, nspc) = print_pretty tab pos spc p in
      if match pl with
           [] -> true
         | _ -> false
      then
        npos, nspc
      else if tolerate tab npos nspc then
        let nspc = if npos == tab then nspc + !dt else nspc in
        print_spaces nspc; print_beg_end_rest tab (npos + nspc) pl
      else
        begin
          print_newline_and_tab (tab + !dt);
          print_beg_end_rest tab (tab + !dt) pl
        end
  | [] -> pos, spc
and print_beg_end_rest tab pos =
  function
    p :: pl ->
      let (pos, spc) = print_pretty (tab + !dt) pos 0 p in
      if match pl with
           [] -> true
         | _ -> false
      then
        pos, spc
      else begin print_newline_and_tab tab; print_beg_end_rest tab tab pl end
  | [] -> pos, 0
;;

let string_npos s = String.length s;;

let rec conv =
  function
    S (g, s) -> SL (string_npos s, g, s)
  | Hbox x -> HL (conv_stream x)
  | HVbox x -> BL (conv_stream x)
  | HOVbox x ->
      begin match conv_stream x with
        [PL _ as x] -> x
      | x -> PL x
      end
  | HOVCbox x -> QL (conv_stream x)
  | Vbox x -> VL (conv_stream x)
  | BEbox x -> BE (conv_stream x)
  | BEVbox x -> BV (conv_stream x)
  | LocInfo (loc, x) ->
      let (comm, nl_bef, tab_bef, cnt) =
        let len = Stdpp.first_pos loc - !last_ep in
        if len > 0 then !getcomm loc !last_ep len else "", 0, 0, 0
      in
      last_ep := !last_ep + cnt;
      let v = conv x in
      last_ep := max (Stdpp.last_pos loc) !last_ep;
      LI ((comm, nl_bef, tab_bef), v)
and conv_stream (strm__ : _ Stream.t) =
  match Stream.peek strm__ with
    Some p -> Stream.junk strm__; let x = conv p in x :: conv_stream strm__
  | _ -> []
;;

let print_pretty pr_ch pr_str pr_nl pr pr2 m lf bp p =
  maxl := m;
  print_char_fun := pr_ch;
  print_string_fun := pr_str;
  print_newline_fun := pr_nl;
  prompt := pr2;
  getcomm := lf;
  last_ep := bp;
  print_string pr;
  let _ = print_pretty 0 0 0 (conv p) in ()
;;
