(* camlp5r pa_macro.cmo *)
(* $Id: versdep.ml,v 1.21 2010/09/02 14:38:09 deraugla Exp $ *)
(* Copyright (c) INRIA 2007-2010 *)

open Parsetree;
open Longident;
open Asttypes;

IFDEF OCAML_2_00 OR OCAML_2_01 OR OCAML_2_02 THEN
  DEFINE OCAML_2_02_OR_BEFORE
END;
IFDEF OCAML_2_02_OR_BEFORE OR OCAML_2_03 OR OCAML_2_04 THEN
  DEFINE OCAML_2_04_OR_BEFORE
END;
IFDEF OCAML_2_04_OR_BEFORE OR OCAML_2_99 THEN
  DEFINE OCAML_2_99_OR_BEFORE
END;
IFDEF OCAML_2_99_OR_BEFORE OR OCAML_3_00 THEN
  DEFINE OCAML_3_00_OR_BEFORE
END;
IFDEF OCAML_3_00_OR_BEFORE OR OCAML_3_01 THEN
  DEFINE OCAML_3_01_OR_BEFORE
END;
IFDEF OCAML_3_01_OR_BEFORE OR OCAML_3_02 THEN
  DEFINE OCAML_3_02_OR_BEFORE
END;
IFDEF OCAML_3_02_OR_BEFORE OR OCAML_3_03 OR OCAML_3_04 THEN
  DEFINE OCAML_3_04_OR_BEFORE
END;
IFDEF OCAML_3_04_OR_BEFORE OR OCAML_3_05 OR OCAML_3_06 THEN
  DEFINE OCAML_3_06_OR_BEFORE
END;
IFDEF
  OCAML_3_06_OR_BEFORE OR OCAML_3_07 OR
  OCAML_3_08_0 OR OCAML_3_08_1 OR OCAML_3_08_2 OR OCAML_3_08_3 OR OCAML_3_08_4
THEN
  DEFINE OCAML_3_08_OR_BEFORE
END;
IFDEF OCAML_3_12_0 OR OCAML_3_12_1 OR OCAML_3_13_0 THEN
  DEFINE OCAML_3_12_OR_AFTER
END;
IFDEF
  OCAML_3_11 OR OCAML_3_11_0 OR OCAML_3_11_1 OR OCAML_3_11_2 OR
  OCAML_3_11_3 OR OCAML_3_12_OR_AFTER
THEN
  DEFINE OCAML_3_11_OR_AFTER
END;
IFDEF
  OCAML_3_10 OR OCAML_3_10_0 OR OCAML_3_10_1 OR OCAML_3_10_2 OR
  OCAML_3_10_3 OR OCAML_3_11_OR_AFTER
THEN
  DEFINE OCAML_3_10_OR_AFTER
END;

type choice 'a 'b =
  [ Left of 'a
  | Right of 'b ]
;

value sys_ocaml_version =
  IFDEF OCAML_2_00 THEN "2.00"
  ELSIFDEF OCAML_2_01 THEN "2.01"
  ELSIFDEF OCAML_2_02 THEN "2.02"
  ELSIFDEF OCAML_2_03 THEN "2.03"
  ELSIFDEF OCAML_2_04 THEN "2.04"
  ELSIFDEF OCAML_2_99 THEN "2.99"
  ELSIFDEF OCAML_3_00 THEN "3.00"
  ELSIFDEF OCAML_3_01 THEN "3.01"
  ELSIFDEF OCAML_3_02 THEN "3.02"
  ELSIFDEF OCAML_3_03 THEN "3.03"
  ELSIFDEF OCAML_3_04 THEN "3.04"
  ELSE Sys.ocaml_version END
;

value ocaml_location (fname, lnum, bolp, bp, ep) =
  IFDEF OCAML_2_02_OR_BEFORE THEN
    {Location.loc_start = bp; Location.loc_end = ep}
  ELSIFDEF OCAML_3_06_OR_BEFORE THEN
    {Location.loc_start = bp; Location.loc_end = ep;
     Location.loc_ghost = bp = 0 && ep = 0}
  ELSE
    let loc_at n =
      {Lexing.pos_fname = if lnum = -1 then "" else fname;
       Lexing.pos_lnum = lnum; Lexing.pos_bol = bolp; Lexing.pos_cnum = n}
    in
    {Location.loc_start = loc_at bp; Location.loc_end = loc_at ep;
     Location.loc_ghost = bp = 0 && ep = 0}
  END
;

value ocaml_type_declaration params cl tk pf tm loc variance =
  IFDEF OCAML_3_11_OR_AFTER THEN
    {ptype_params = params; ptype_cstrs = cl; ptype_kind = tk;
     ptype_private = pf; ptype_manifest = tm; ptype_loc = loc;
     ptype_variance = variance}
  ELSIFDEF OCAML_3_00_OR_BEFORE THEN
    {ptype_params = params; ptype_cstrs = cl; ptype_kind = tk;
     ptype_manifest = tm; ptype_loc = loc}
  ELSE
    {ptype_params = params; ptype_cstrs = cl; ptype_kind = tk;
     ptype_manifest = tm; ptype_loc = loc; ptype_variance = variance}
  END
;

value ocaml_ptype_private =
  IFDEF OCAML_3_08_OR_BEFORE OR OCAML_3_11_OR_AFTER THEN Ptype_abstract
  ELSE Ptype_private END
;

value ocaml_ptype_record ltl priv =
  IFDEF OCAML_3_08_OR_BEFORE THEN
    let ltl = List.map (fun (n, m, t, _) -> (n, m, t)) ltl in
    IFDEF OCAML_3_06_OR_BEFORE THEN
      Ptype_record ltl
    ELSE
      Ptype_record ltl priv
    END
  ELSIFDEF OCAML_3_11_OR_AFTER THEN
    Ptype_record ltl
  ELSE
    Ptype_record ltl priv
  END
;

value ocaml_ptype_variant ctl priv =
  IFDEF OCAML_3_08_OR_BEFORE THEN
    let ctl = List.map (fun (c, tl, _) -> (c, tl)) ctl in
    IFDEF OCAML_3_06_OR_BEFORE THEN
      Ptype_variant ctl
    ELSE
      Ptype_variant ctl priv
    END
  ELSIFDEF OCAML_3_11_OR_AFTER THEN
    Ptype_variant ctl
  ELSE
    Ptype_variant ctl priv
  END
;

value ocaml_ptyp_arrow lab t1 t2 =
  IFDEF OCAML_2_04_OR_BEFORE THEN Ptyp_arrow t1 t2
  ELSE Ptyp_arrow lab t1 t2 END
;

value ocaml_ptyp_class li tl ll =
  IFDEF OCAML_2_04_OR_BEFORE THEN Ptyp_class li tl
  ELSE Ptyp_class li tl ll END
;

value ocaml_ptyp_poly =
  IFDEF OCAML_3_04_OR_BEFORE THEN None
  ELSE Some (fun cl t -> Ptyp_poly cl t) END
;

value ocaml_ptyp_variant catl clos sl_opt =
  IFDEF OCAML_2_04_OR_BEFORE THEN None
  ELSIFDEF OCAML_3_02_OR_BEFORE THEN
    try
      let catl =
        List.map
          (fun
           [ Left (c, a, tl) -> (c, a, tl)
           | Right t -> raise Exit ])
          catl
      in
      let sl = match sl_opt with [ Some sl -> sl | None -> [] ] in
      Some (Ptyp_variant catl clos sl)
    with
    [ Exit -> None ]
  ELSE
    let catl =
      List.map
        (fun
         [ Left (c, a, tl) -> Rtag c a tl
         | Right t -> Rinherit t ])
        catl
    in
    Some (Ptyp_variant catl clos sl_opt)
  END
;

value ocaml_const_int32 =
  IFDEF OCAML_3_06_OR_BEFORE THEN None
  ELSE Some (fun s -> Const_int32 (Int32.of_string s)) END
;

value ocaml_const_int64 =
  IFDEF OCAML_3_06_OR_BEFORE THEN None
  ELSE Some (fun s -> Const_int64 (Int64.of_string s)) END
;

value ocaml_const_nativeint =
  IFDEF OCAML_3_06_OR_BEFORE THEN None
  ELSE Some (fun s -> Const_nativeint (Nativeint.of_string s)) END
;

value ocaml_pexp_apply f lel =
  IFDEF OCAML_2_04_OR_BEFORE THEN Pexp_apply f (List.map snd lel)
  ELSE Pexp_apply f lel END
;

value ocaml_pexp_assertfalse fname loc =
  IFDEF OCAML_3_00_OR_BEFORE THEN
    let ghexp d = {pexp_desc = d; pexp_loc = loc} in
    let triple =
      ghexp (Pexp_tuple
             [ghexp (Pexp_constant (Const_string fname));
              ghexp (Pexp_constant (Const_int loc.Location.loc_start));
              ghexp (Pexp_constant (Const_int loc.Location.loc_end))])
    in
    let excep = Ldot (Lident "Pervasives") "Assert_failure" in
    let bucket = ghexp (Pexp_construct excep (Some triple) False) in
    let raise_ = ghexp (Pexp_ident (Ldot (Lident "Pervasives") "raise")) in
    ocaml_pexp_apply raise_ [("", bucket)]
  ELSE Pexp_assertfalse END
;

value ocaml_pexp_assert fname loc e =
  IFDEF OCAML_3_00_OR_BEFORE THEN
    let ghexp d = {pexp_desc = d; pexp_loc = loc} in
    let ghpat d = {ppat_desc = d; ppat_loc = loc} in
    let triple =
      ghexp (Pexp_tuple
             [ghexp (Pexp_constant (Const_string fname));
              ghexp (Pexp_constant (Const_int loc.Location.loc_start));
              ghexp (Pexp_constant (Const_int loc.Location.loc_end))])
    in
    let excep = Ldot (Lident "Pervasives") "Assert_failure" in
    let bucket = ghexp (Pexp_construct excep (Some triple) False) in
    let raise_ = ghexp (Pexp_ident (Ldot (Lident "Pervasives") "raise")) in
    let raise_af = ghexp (ocaml_pexp_apply raise_ [("", bucket)]) in
    let under = ghpat Ppat_any in
    let false_ = ghexp (Pexp_construct (Lident "false") None False) in
    let try_e = ghexp (Pexp_try e [(under, false_)]) in

    let not_ = ghexp (Pexp_ident (Ldot (Lident "Pervasives") "not")) in
    let not_try_e = ghexp (ocaml_pexp_apply not_ [("", try_e)]) in
    Pexp_ifthenelse not_try_e raise_af None
  ELSE Pexp_assert e END
;

value ocaml_pexp_function lab eo pel =
  IFDEF OCAML_2_04_OR_BEFORE THEN Pexp_function pel
  ELSE Pexp_function lab eo pel END
;

value ocaml_pexp_lazy =
  IFDEF OCAML_3_04_OR_BEFORE THEN None ELSE Some (fun e -> Pexp_lazy e) END
;

value ocaml_pexp_object =
  IFDEF OCAML_3_06_OR_BEFORE OR OCAML_3_07 THEN None
  ELSE Some (fun cs -> Pexp_object cs) END
;

value ocaml_pexp_poly =
  IFDEF OCAML_3_04_OR_BEFORE THEN None
  ELSE Some (fun e t -> Pexp_poly e t) END
;

value ocaml_pexp_variant =
  IFDEF OCAML_2_04_OR_BEFORE THEN None
  ELSE
    let pexp_variant_pat =
      fun
      [ Pexp_variant lab eo -> Some (lab, eo)
      | _ -> None ]
    in
    let pexp_variant (lab, eo) = Pexp_variant lab eo in
    Some (pexp_variant_pat, pexp_variant)
  END
;

value ocaml_ppat_lazy =
  IFDEF OCAML_3_11_OR_AFTER THEN Some (fun p -> Ppat_lazy p) ELSE None END
;

value ocaml_ppat_record lpl =
  IFDEF OCAML_3_12_OR_AFTER THEN Ppat_record lpl Closed
  ELSE Ppat_record lpl END
;

value ocaml_ppat_type =
  IFDEF OCAML_2_99_OR_BEFORE THEN None
  ELSE Some (fun sl -> Ppat_type sl) END
;

value ocaml_ppat_variant =
  IFDEF OCAML_2_04_OR_BEFORE THEN None
  ELSE
    let ppat_variant_pat =
      fun
      [ Ppat_variant lab po -> Some (lab, po)
      | _ -> None ]
    in
    let ppat_variant (lab, po) = Ppat_variant lab po in
    Some (ppat_variant_pat, ppat_variant)
  END
;

value ocaml_psig_recmodule =
  IFDEF OCAML_3_06_OR_BEFORE THEN None
  ELSE Some (fun ntl -> Psig_recmodule ntl) END
;

value ocaml_pstr_exn_rebind =
  IFDEF OCAML_2_99_OR_BEFORE THEN None
  ELSE Some (fun s sl -> Pstr_exn_rebind s sl) END
;

value ocaml_pstr_include =
  IFDEF OCAML_3_00_OR_BEFORE THEN None
  ELSE Some (fun me -> Pstr_include me) END
;

value ocaml_pstr_recmodule =
  IFDEF OCAML_3_06_OR_BEFORE THEN None
  ELSE Some (fun nel -> Pstr_recmodule nel) END
;

value ocaml_class_infos virt params name expr loc variance =
  IFDEF OCAML_3_00_OR_BEFORE THEN
    {pci_virt = virt; pci_params = params; pci_name = name; pci_expr = expr;
     pci_loc = loc}
  ELSE
    {pci_virt = virt; pci_params = params; pci_name = name; pci_expr = expr;
     pci_loc = loc; pci_variance = variance}
  END
;

value ocaml_pcf_inher ce pb =
  IFDEF OCAML_3_12_OR_AFTER THEN Pcf_inher Fresh ce pb
  ELSE Pcf_inher ce pb END
;

value ocaml_pcf_meth (s, b, e, loc) =
  IFDEF OCAML_3_12_OR_AFTER THEN Pcf_meth (s, b, Fresh, e, loc) 
  ELSE Pcf_meth (s, b, e, loc) END
;

value ocaml_pcf_val (s, b, e, loc) =
  IFDEF OCAML_3_12_OR_AFTER THEN Pcf_val (s, b, Fresh, e, loc)
  ELSE Pcf_val (s, b, e,  loc) END
;

value ocaml_pcl_apply ce lel =
  IFDEF OCAML_2_04_OR_BEFORE THEN Pcl_apply ce (List.map snd lel)
  ELSE Pcl_apply ce lel END
;

value ocaml_pcl_fun lab ceo p ce =
  IFDEF OCAML_2_04_OR_BEFORE THEN Pcl_fun p ce ELSE Pcl_fun lab ceo p ce END
;

value ocaml_pctf_val (s, b, t, loc) =
  IFDEF OCAML_3_10_OR_AFTER THEN Pctf_val (s, b, Concrete, t, loc)
  ELSE Pctf_val (s, b, Some t, loc) END
;

value ocaml_pcty_fun lab t ct =
  IFDEF OCAML_2_04_OR_BEFORE THEN Pcty_fun t ct ELSE Pcty_fun lab t ct END
;

value ocaml_pdir_bool =
  IFDEF OCAML_2_04_OR_BEFORE THEN None ELSE Some (fun b -> Pdir_bool b) END
;

value module_prefix_can_be_in_first_record_label_only =
  IFDEF OCAML_3_06_OR_BEFORE OR OCAML_3_07 THEN False ELSE True END
;

value split_or_patterns_with_bindings =
  IFDEF OCAML_3_01_OR_BEFORE THEN True ELSE False END
;

value arg_rest =
  fun
  [ IFNDEF OCAML_1_07 THEN Arg.Rest r -> Some r END
  | _ -> None ]
;

value arg_set_string =
  fun
  [ IFNDEF OCAML_3_06_OR_BEFORE THEN Arg.Set_string r -> Some r END
  | _ -> None ]
;

value arg_set_int =
  fun
  [ IFNDEF OCAML_3_06_OR_BEFORE THEN Arg.Set_int r -> Some r END
  | _ -> None ]
;

value arg_set_float =
  fun
  [ IFNDEF OCAML_3_06_OR_BEFORE THEN Arg.Set_float r -> Some r END
  | _ -> None ]
;

value arg_symbol =
  fun
  [ IFNDEF OCAML_3_06_OR_BEFORE THEN Arg.Symbol s f -> Some (s, f) END
  | _ -> None ]
;

value arg_tuple =
  fun
  [ IFNDEF OCAML_3_06_OR_BEFORE THEN Arg.Tuple t -> Some t END
  | _ -> None ]
;

value arg_bool =
  fun
  [ IFNDEF OCAML_3_06_OR_BEFORE THEN Arg.Bool f -> Some f END
  | _ -> None ]
;

value char_escaped =
  IFDEF OCAML_3_11_OR_AFTER THEN Char.escaped
  ELSE
    fun
    [ '\r' -> "\\r"
    | c -> Char.escaped c ]
  END
;

value hashtbl_mem =
  IFDEF OCAML_2_00 OR OCAML_2_01 THEN
    fun ht a ->
      try let _ = Hashtbl.find ht a in True with [ Not_found -> False ]
  ELSE
    Hashtbl.mem
  END
;

value list_rev_append =
  IFDEF OCAML_1_07 THEN
    loop where rec loop accu =
      fun
      [ [x :: l] -> loop [x :: accu] l
      | [] -> accu ]
  ELSE
    List.rev_append
  END
;

value list_rev_map =
  IFDEF OCAML_2_02_OR_BEFORE THEN
    fun f ->
      loop [] where rec loop r =
        fun
        [ [x :: l] -> loop [f x :: r] l
        | [] -> r ]
  ELSE
    List.rev_map
  END
;

IFDEF OCAML_3_04_OR_BEFORE THEN
  declare
    value scan_format fmt i kont =
      match fmt.[i+1] with
      [ 'c' -> Obj.magic (fun (c : char) -> kont (String.make 1 c) (i + 2))
      | 'd' -> Obj.magic (fun (d : int) -> kont (string_of_int d) (i + 2))
      | 's' -> Obj.magic (fun (s : string) -> kont s (i + 2))
      | c ->
          failwith
            (Printf.sprintf "Pretty.sprintf \"%s\" '%%%c' not impl" fmt c) ]
    ;
    value printf_ksprintf kont fmt =
      let fmt = (Obj.magic fmt : string) in
      let len = String.length fmt in
      doprn [] 0 where rec doprn rev_sl i =
        if i >= len then do {
          let s = String.concat "" (List.rev rev_sl) in
          Obj.magic (kont s)
        }
        else do {
          match fmt.[i] with
          [ '%' -> scan_format fmt i (fun s -> doprn [s :: rev_sl])
          | c -> doprn [String.make 1 c :: rev_sl] (i + 1)  ]
        }
    ;
  end;
ELSE
  value printf_ksprintf = Printf.kprintf;
END;

value string_contains =
  IFDEF OCAML_2_00 THEN
    fun s c ->
      loop 0 where rec loop i =
        if i = String.length s then False
        else if s.[i] = c then True
        else loop (i + 1)
  ELSIFDEF OCAML_2_01 THEN
    fun s c -> s <> "" && String.contains s c
  ELSE
    String.contains
  END
;
