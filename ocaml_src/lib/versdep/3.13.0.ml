(* camlp5r pa_macro.cmo *)
(* This file has been generated by program: do not edit! *)
(* Copyright (c) INRIA 2007-2010 *)

open Parsetree;;
open Longident;;
open Asttypes;;

(* *)
(* *)
(* *)
(* *)
(* *)
(* *)
(* *)
(* *)
(* *)
(* *)
(* *)
(* *)

type ('a, 'b) choice =
    Left of 'a
  | Right of 'b
;;

let sys_ocaml_version = Sys.ocaml_version;;

let ocaml_location (fname, lnum, bolp, bp, ep) =
  let loc_at n =
    {Lexing.pos_fname = if lnum = -1 then "" else fname;
     Lexing.pos_lnum = lnum; Lexing.pos_bol = bolp; Lexing.pos_cnum = n}
  in
  {Location.loc_start = loc_at bp; Location.loc_end = loc_at ep;
   Location.loc_ghost = bp = 0 && ep = 0}
;;

let ocaml_type_declaration params cl tk pf tm loc variance =
  {ptype_params = params; ptype_cstrs = cl; ptype_kind = tk;
   ptype_private = pf; ptype_manifest = tm; ptype_loc = loc;
   ptype_variance = variance}
;;

let ocaml_ptype_private = Ptype_abstract;;

let ocaml_ptype_record ltl priv = Ptype_record ltl;;

let ocaml_ptype_variant ctl priv = Ptype_variant ctl;;

let ocaml_ptyp_arrow lab t1 t2 = Ptyp_arrow (lab, t1, t2);;

let ocaml_ptyp_class li tl ll = Ptyp_class (li, tl, ll);;

let ocaml_ptyp_poly = Some (fun cl t -> Ptyp_poly (cl, t));;

let ocaml_ptyp_variant catl clos sl_opt =
  let catl =
    List.map
      (function
         Left (c, a, tl) -> Rtag (c, a, tl)
       | Right t -> Rinherit t)
      catl
  in
  Some (Ptyp_variant (catl, clos, sl_opt))
;;

let ocaml_const_int32 = Some (fun s -> Const_int32 (Int32.of_string s));;

let ocaml_const_int64 = Some (fun s -> Const_int64 (Int64.of_string s));;

let ocaml_const_nativeint =
  Some (fun s -> Const_nativeint (Nativeint.of_string s))
;;

let ocaml_pexp_apply f lel = Pexp_apply (f, lel);;

let ocaml_pexp_assertfalse fname loc = Pexp_assertfalse;;

let ocaml_pexp_assert fname loc e = Pexp_assert e;;

let ocaml_pexp_function lab eo pel = Pexp_function (lab, eo, pel);;

let ocaml_pexp_lazy = Some (fun e -> Pexp_lazy e);;

let ocaml_pexp_object = Some (fun cs -> Pexp_object cs);;

let ocaml_pexp_poly = Some (fun e t -> Pexp_poly (e, t));;

let ocaml_pexp_variant =
  let pexp_variant_pat =
    function
      Pexp_variant (lab, eo) -> Some (lab, eo)
    | _ -> None
  in
  let pexp_variant (lab, eo) = Pexp_variant (lab, eo) in
  Some (pexp_variant_pat, pexp_variant)
;;

let ocaml_ppat_lazy = Some (fun p -> Ppat_lazy p);;

let ocaml_ppat_record lpl = Ppat_record (lpl, Closed);;

let ocaml_ppat_type = Some (fun sl -> Ppat_type sl);;

let ocaml_ppat_variant =
  let ppat_variant_pat =
    function
      Ppat_variant (lab, po) -> Some (lab, po)
    | _ -> None
  in
  let ppat_variant (lab, po) = Ppat_variant (lab, po) in
  Some (ppat_variant_pat, ppat_variant)
;;

let ocaml_psig_recmodule = Some (fun ntl -> Psig_recmodule ntl);;

let ocaml_pstr_exn_rebind = Some (fun s sl -> Pstr_exn_rebind (s, sl));;

let ocaml_pstr_include = Some (fun me -> Pstr_include me);;

let ocaml_pstr_recmodule = Some (fun nel -> Pstr_recmodule nel);;

let ocaml_class_infos virt params name expr loc variance =
  {pci_virt = virt; pci_params = params; pci_name = name; pci_expr = expr;
   pci_loc = loc; pci_variance = variance}
;;

let ocaml_pcf_inher ce pb = Pcf_inher (Fresh, ce, pb);;

let ocaml_pcf_meth (s, b, e, loc) = Pcf_meth (s, b, Fresh, e, loc);;

let ocaml_pcf_val (s, b, e, loc) = Pcf_val (s, b, Fresh, e, loc);;

let ocaml_pcl_apply ce lel = Pcl_apply (ce, lel);;

let ocaml_pcl_fun lab ceo p ce = Pcl_fun (lab, ceo, p, ce);;

let ocaml_pctf_val (s, b, t, loc) = Pctf_val (s, b, Concrete, t, loc);;

let ocaml_pcty_fun lab t ct = Pcty_fun (lab, t, ct);;

let ocaml_pdir_bool = Some (fun b -> Pdir_bool b);;

let module_prefix_can_be_in_first_record_label_only = true;;

let split_or_patterns_with_bindings = false;;

let arg_rest =
  function
    Arg.Rest r -> Some r
  | _ -> None
;;

let arg_set_string =
  function
    Arg.Set_string r -> Some r
  | _ -> None
;;

let arg_set_int =
  function
    Arg.Set_int r -> Some r
  | _ -> None
;;

let arg_set_float =
  function
    Arg.Set_float r -> Some r
  | _ -> None
;;

let arg_symbol =
  function
    Arg.Symbol (s, f) -> Some (s, f)
  | _ -> None
;;

let arg_tuple =
  function
    Arg.Tuple t -> Some t
  | _ -> None
;;

let arg_bool =
  function
    Arg.Bool f -> Some f
  | _ -> None
;;

let char_escaped = Char.escaped;;

let hashtbl_mem = Hashtbl.mem;;

let list_rev_append = List.rev_append;;

let list_rev_map = List.rev_map;;

let printf_ksprintf = Printf.kprintf;;

let string_contains = String.contains;;
