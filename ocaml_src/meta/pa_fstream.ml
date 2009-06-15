(* camlp5r pa_extend.cmo q_MLast.cmo *)
(* This file has been generated by program: do not edit! *)

open Pcaml;;

type spat_comp =
    SpTrm of MLast.loc * MLast.patt * MLast.expr option
  | SpNtr of MLast.loc * MLast.patt * MLast.expr
  | SpStr of MLast.loc * MLast.patt
;;
type sexp_comp =
    SeTrm of MLast.loc * MLast.expr
  | SeNtr of MLast.loc * MLast.expr
;;

(* parsers *)

let strm_n = "strm__";;
let next_fun loc =
  MLast.ExAcc (loc, MLast.ExUid (loc, "Fstream"), MLast.ExLid (loc, "next"))
;;

let rec pattern_eq_expression p e =
  match p, e with
    MLast.PaLid (_, a), MLast.ExLid (_, b) -> a = b
  | MLast.PaUid (_, a), MLast.ExUid (_, b) -> a = b
  | MLast.PaApp (_, p1, p2), MLast.ExApp (_, e1, e2) ->
      pattern_eq_expression p1 e1 && pattern_eq_expression p2 e2
  | MLast.PaTup (_, pl), MLast.ExTup (_, el) ->
      let rec loop pl el =
        match pl, el with
          p :: pl, e :: el -> pattern_eq_expression p e && loop pl el
        | [], [] -> true
        | _ -> false
      in
      loop pl el
  | _ -> false
;;

let stream_pattern_component skont =
  function
    SpTrm (loc, p, wo) ->
      let p =
        MLast.PaApp
          (loc, MLast.PaUid (loc, "Some"),
           MLast.PaTup (loc, [p; MLast.PaLid (loc, strm_n)]))
      in
      if wo = None && pattern_eq_expression p skont then
        MLast.ExApp (loc, next_fun loc, MLast.ExLid (loc, strm_n))
      else
        MLast.ExMat
          (loc, MLast.ExApp (loc, next_fun loc, MLast.ExLid (loc, strm_n)),
           [p, wo, skont; MLast.PaAny loc, None, MLast.ExUid (loc, "None")])
  | SpNtr (loc, p, e) ->
      let p =
        MLast.PaApp
          (loc, MLast.PaUid (loc, "Some"),
           MLast.PaTup (loc, [p; MLast.PaLid (loc, strm_n)]))
      in
      if pattern_eq_expression p skont then
        MLast.ExApp (loc, e, MLast.ExLid (loc, strm_n))
      else
        MLast.ExMat
          (loc, MLast.ExApp (loc, e, MLast.ExLid (loc, strm_n)),
           [p, None, skont; MLast.PaAny loc, None, MLast.ExUid (loc, "None")])
  | SpStr (loc, p) ->
      MLast.ExLet (loc, false, [p, MLast.ExLid (loc, strm_n)], skont)
;;

let rec stream_pattern loc epo e =
  function
    [] ->
      let e =
        match epo with
          Some ep ->
            MLast.ExLet
              (loc, false,
               [ep,
                MLast.ExApp
                  (loc,
                   MLast.ExAcc
                     (loc, MLast.ExUid (loc, "Fstream"),
                      MLast.ExLid (loc, "count")),
                   MLast.ExLid (loc, strm_n))],
               e)
        | None -> e
      in
      MLast.ExApp
        (loc, MLast.ExUid (loc, "Some"),
         MLast.ExTup (loc, [e; MLast.ExLid (loc, strm_n)]))
  | spc :: spcl ->
      let skont = stream_pattern loc epo e spcl in
      stream_pattern_component skont spc
;;

let rec parser_cases loc =
  function
    [] -> MLast.ExUid (loc, "None")
  | (spcl, epo, e) :: spel ->
      match parser_cases loc spel with
        MLast.ExUid (_, "None") -> stream_pattern loc epo e spcl
      | pc ->
          MLast.ExMat
            (loc, stream_pattern loc epo e spcl,
             [MLast.PaAli
                (loc,
                 MLast.PaApp
                   (loc, MLast.PaUid (loc, "Some"), MLast.PaAny loc),
                 MLast.PaLid (loc, "x")),
              None, MLast.ExLid (loc, "x");
              MLast.PaUid (loc, "None"), None, pc])
;;

let cparser_match loc me bpo pc =
  let pc = parser_cases loc pc in
  let e =
    match bpo with
      Some bp ->
        MLast.ExLet
          (loc, false,
           [bp,
            MLast.ExApp
              (loc,
               MLast.ExAcc
                 (loc, MLast.ExUid (loc, "Fstream"),
                  MLast.ExLid (loc, "count")),
               MLast.ExLid (loc, strm_n))],
           pc)
    | None -> pc
  in
  MLast.ExLet
    (loc, false,
     [MLast.PaTyc
        (loc, MLast.PaLid (loc, strm_n),
         MLast.TyApp
           (loc,
            MLast.TyAcc
              (loc, MLast.TyUid (loc, "Fstream"), MLast.TyLid (loc, "t")),
            MLast.TyAny loc)),
      me],
     e)
;;

let cparser loc bpo pc =
  let e = parser_cases loc pc in
  let e =
    match bpo with
      Some bp ->
        MLast.ExLet
          (loc, false,
           [bp,
            MLast.ExApp
              (loc,
               MLast.ExAcc
                 (loc, MLast.ExUid (loc, "Fstream"),
                  MLast.ExLid (loc, "count")),
               MLast.ExLid (loc, strm_n))],
           e)
    | None -> e
  in
  let p =
    MLast.PaTyc
      (loc, MLast.PaLid (loc, strm_n),
       MLast.TyApp
         (loc,
          MLast.TyAcc
            (loc, MLast.TyUid (loc, "Fstream"), MLast.TyLid (loc, "t")),
          MLast.TyAny loc))
  in
  MLast.ExFun (loc, [p, None, e])
;;

(* streams *)

let slazy loc x = MLast.ExFun (loc, [MLast.PaUid (loc, "()"), None, x]);;

let rec cstream loc =
  function
    [] ->
      MLast.ExAcc
        (loc, MLast.ExUid (loc, "Fstream"), MLast.ExLid (loc, "nil"))
  | SeTrm (loc, e) :: sel ->
      let e2 = cstream loc sel in
      let x =
        MLast.ExApp
          (loc,
           MLast.ExApp
             (loc,
              MLast.ExAcc
                (loc, MLast.ExUid (loc, "Fstream"),
                 MLast.ExLid (loc, "cons")),
              e),
           e2)
      in
      MLast.ExApp
        (loc,
         MLast.ExAcc
           (loc, MLast.ExUid (loc, "Fstream"), MLast.ExLid (loc, "flazy")),
         slazy loc x)
  | [SeNtr (loc, e)] -> e
  | SeNtr (loc, e) :: sel ->
      let e2 = cstream loc sel in
      let x =
        MLast.ExApp
          (loc,
           MLast.ExApp
             (loc,
              MLast.ExAcc
                (loc, MLast.ExUid (loc, "Fstream"), MLast.ExLid (loc, "app")),
              e),
           e2)
      in
      MLast.ExApp
        (loc,
         MLast.ExAcc
           (loc, MLast.ExUid (loc, "Fstream"), MLast.ExLid (loc, "flazy")),
         slazy loc x)
;;

(* meta parsers *)

let patt_expr_of_patt p =
  let loc = MLast.loc_of_patt p in
  match p with
    MLast.PaLid (_, x) -> p, MLast.ExLid (loc, x)
  | MLast.PaApp (_, MLast.PaUid (_, _), MLast.PaLid (_, x)) ->
      MLast.PaLid (loc, x), MLast.ExLid (loc, x)
  | _ -> MLast.PaUid (loc, "()"), MLast.ExUid (loc, "()")
;;

let mstream_pattern_component m =
  function
    SpTrm (loc, p, wo) ->
      let (p, e) = patt_expr_of_patt p in
      let e =
        MLast.ExApp
          (loc,
           MLast.ExAcc
             (loc, MLast.ExUid (loc, m), MLast.ExLid (loc, "b_term")),
           MLast.ExFun
             (loc,
              [p, None, MLast.ExApp (loc, MLast.ExUid (loc, "Some"), e);
               MLast.PaAny loc, None, MLast.ExUid (loc, "None")]))
      in
      p, e
  | SpNtr (loc, p, e) -> p, e
  | SpStr (loc, p) ->
      Ploc.raise loc (Stream.Error "not impl: stream_pattern_component")
;;

let rec mstream_pattern loc m (spcl, epo, e) =
  match spcl with
    [] ->
      let e =
        let e =
          MLast.ExApp
            (loc,
             MLast.ExApp
               (loc,
                MLast.ExAcc
                  (loc, MLast.ExUid (loc, m), MLast.ExLid (loc, "b_act")),
                e),
             MLast.ExLid (loc, strm_n))
        in
        match epo with
          Some p ->
            MLast.ExLet
              (loc, false,
               [p,
                MLast.ExApp
                  (loc,
                   MLast.ExAcc
                     (loc, MLast.ExUid (loc, m), MLast.ExLid (loc, "count")),
                   MLast.ExLid (loc, strm_n))],
               e)
        | None -> e
      in
      MLast.ExFun (loc, [MLast.PaLid (loc, strm_n), None, e])
  | spc :: spcl ->
      let (p1, e1) = mstream_pattern_component m spc in
      let skont = mstream_pattern loc m (spcl, epo, e) in
      let f = MLast.ExFun (loc, [p1, None, skont]) in
      MLast.ExApp
        (loc,
         MLast.ExApp
           (loc,
            MLast.ExAcc
              (loc, MLast.ExUid (loc, m), MLast.ExLid (loc, "b_seq")),
            e1),
         f)
;;

let mparser_cases loc m spel =
  let rel = List.rev_map (mstream_pattern loc m) spel in
  match rel with
    e :: rel ->
      let e =
        List.fold_left
          (fun e e1 ->
             MLast.ExApp
               (loc,
                MLast.ExApp
                  (loc,
                   MLast.ExAcc
                     (loc, MLast.ExUid (loc, m), MLast.ExLid (loc, "b_or")),
                   e1),
                e))
          e rel
      in
      MLast.ExApp (loc, e, MLast.ExLid (loc, strm_n))
  | [] -> MLast.ExUid (loc, "None")
;;

let mparser_match loc m me bpo pc =
  let pc = mparser_cases loc m pc in
  let e =
    match bpo with
      Some bp ->
        MLast.ExLet
          (loc, false,
           [bp,
            MLast.ExApp
              (loc,
               MLast.ExAcc
                 (loc, MLast.ExUid (loc, m), MLast.ExLid (loc, "count")),
               MLast.ExLid (loc, strm_n))],
           pc)
    | None -> pc
  in
  MLast.ExLet
    (loc, false,
     [MLast.PaTyc
        (loc, MLast.PaLid (loc, strm_n),
         MLast.TyApp
           (loc,
            MLast.TyAcc (loc, MLast.TyUid (loc, m), MLast.TyLid (loc, "t")),
            MLast.TyAny loc)),
      me],
     e)
;;

let mparser loc m bpo pc =
  let e = mparser_cases loc m pc in
  let e =
    match bpo with
      Some bp ->
        MLast.ExLet
          (loc, false,
           [bp,
            MLast.ExApp
              (loc,
               MLast.ExAcc
                 (loc, MLast.ExUid (loc, m), MLast.ExLid (loc, "count")),
               MLast.ExLid (loc, strm_n))],
           e)
    | None -> e
  in
  let p =
    MLast.PaTyc
      (loc, MLast.PaLid (loc, strm_n),
       MLast.TyApp
         (loc,
          MLast.TyAcc (loc, MLast.TyUid (loc, m), MLast.TyLid (loc, "t")),
          MLast.TyAny loc))
  in
  MLast.ExFun (loc, [p, None, e])
;;

Grammar.extend
  (let _ = (expr : 'expr Grammar.Entry.e) in
   let grammar_entry_create s =
     Grammar.create_local_entry (Grammar.of_entry expr) s
   in
   let parser_case : 'parser_case Grammar.Entry.e =
     grammar_entry_create "parser_case"
   and stream_patt : 'stream_patt Grammar.Entry.e =
     grammar_entry_create "stream_patt"
   and stream_patt_comp : 'stream_patt_comp Grammar.Entry.e =
     grammar_entry_create "stream_patt_comp"
   and ipatt : 'ipatt Grammar.Entry.e = grammar_entry_create "ipatt"
   and stream_expr_comp : 'stream_expr_comp Grammar.Entry.e =
     grammar_entry_create "stream_expr_comp"
   in
   [Grammar.Entry.obj (expr : 'expr Grammar.Entry.e),
    Some (Gramext.Level "top"),
    [None, None,
     [[Gramext.Stoken ("", "match"); Gramext.Sself;
       Gramext.Stoken ("", "with"); Gramext.Stoken ("", "bparser");
       Gramext.Sopt
         (Gramext.Snterm
            (Grammar.Entry.obj (ipatt : 'ipatt Grammar.Entry.e)));
       Gramext.Snterm
         (Grammar.Entry.obj (parser_case : 'parser_case Grammar.Entry.e))],
      Gramext.action
        (fun (pc : 'parser_case) (po : 'ipatt option) _ _ (e : 'expr) _
             (loc : Ploc.t) ->
           (mparser_match loc "Fstream" e po [pc] : 'expr));
      [Gramext.Stoken ("", "match"); Gramext.Sself;
       Gramext.Stoken ("", "with"); Gramext.Stoken ("", "bparser");
       Gramext.Sopt
         (Gramext.Snterm
            (Grammar.Entry.obj (ipatt : 'ipatt Grammar.Entry.e)));
       Gramext.Stoken ("", "[");
       Gramext.Slist0sep
         (Gramext.Snterm
            (Grammar.Entry.obj (parser_case : 'parser_case Grammar.Entry.e)),
          Gramext.Stoken ("", "|"));
       Gramext.Stoken ("", "]")],
      Gramext.action
        (fun _ (pcl : 'parser_case list) _ (po : 'ipatt option) _ _
             (e : 'expr) _ (loc : Ploc.t) ->
           (mparser_match loc "Fstream" e po pcl : 'expr));
      [Gramext.Stoken ("", "bparser");
       Gramext.Sopt
         (Gramext.Snterm
            (Grammar.Entry.obj (ipatt : 'ipatt Grammar.Entry.e)));
       Gramext.Snterm
         (Grammar.Entry.obj (parser_case : 'parser_case Grammar.Entry.e))],
      Gramext.action
        (fun (pc : 'parser_case) (po : 'ipatt option) _ (loc : Ploc.t) ->
           (mparser loc "Fstream" po [pc] : 'expr));
      [Gramext.Stoken ("", "bparser");
       Gramext.Sopt
         (Gramext.Snterm
            (Grammar.Entry.obj (ipatt : 'ipatt Grammar.Entry.e)));
       Gramext.Stoken ("", "[");
       Gramext.Slist0sep
         (Gramext.Snterm
            (Grammar.Entry.obj (parser_case : 'parser_case Grammar.Entry.e)),
          Gramext.Stoken ("", "|"));
       Gramext.Stoken ("", "]")],
      Gramext.action
        (fun _ (pcl : 'parser_case list) _ (po : 'ipatt option) _
             (loc : Ploc.t) ->
           (mparser loc "Fstream" po pcl : 'expr));
      [Gramext.Stoken ("", "match"); Gramext.Sself;
       Gramext.Stoken ("", "with"); Gramext.Stoken ("", "fparser");
       Gramext.Sopt
         (Gramext.Snterm
            (Grammar.Entry.obj (ipatt : 'ipatt Grammar.Entry.e)));
       Gramext.Snterm
         (Grammar.Entry.obj (parser_case : 'parser_case Grammar.Entry.e))],
      Gramext.action
        (fun (pc : 'parser_case) (po : 'ipatt option) _ _ (e : 'expr) _
             (loc : Ploc.t) ->
           (cparser_match loc e po [pc] : 'expr));
      [Gramext.Stoken ("", "match"); Gramext.Sself;
       Gramext.Stoken ("", "with"); Gramext.Stoken ("", "fparser");
       Gramext.Sopt
         (Gramext.Snterm
            (Grammar.Entry.obj (ipatt : 'ipatt Grammar.Entry.e)));
       Gramext.Stoken ("", "[");
       Gramext.Slist0sep
         (Gramext.Snterm
            (Grammar.Entry.obj (parser_case : 'parser_case Grammar.Entry.e)),
          Gramext.Stoken ("", "|"));
       Gramext.Stoken ("", "]")],
      Gramext.action
        (fun _ (pcl : 'parser_case list) _ (po : 'ipatt option) _ _
             (e : 'expr) _ (loc : Ploc.t) ->
           (cparser_match loc e po pcl : 'expr));
      [Gramext.Stoken ("", "fparser");
       Gramext.Sopt
         (Gramext.Snterm
            (Grammar.Entry.obj (ipatt : 'ipatt Grammar.Entry.e)));
       Gramext.Snterm
         (Grammar.Entry.obj (parser_case : 'parser_case Grammar.Entry.e))],
      Gramext.action
        (fun (pc : 'parser_case) (po : 'ipatt option) _ (loc : Ploc.t) ->
           (cparser loc po [pc] : 'expr));
      [Gramext.Stoken ("", "fparser");
       Gramext.Sopt
         (Gramext.Snterm
            (Grammar.Entry.obj (ipatt : 'ipatt Grammar.Entry.e)));
       Gramext.Stoken ("", "[");
       Gramext.Slist0sep
         (Gramext.Snterm
            (Grammar.Entry.obj (parser_case : 'parser_case Grammar.Entry.e)),
          Gramext.Stoken ("", "|"));
       Gramext.Stoken ("", "]")],
      Gramext.action
        (fun _ (pcl : 'parser_case list) _ (po : 'ipatt option) _
             (loc : Ploc.t) ->
           (cparser loc po pcl : 'expr))]];
    Grammar.Entry.obj (parser_case : 'parser_case Grammar.Entry.e), None,
    [None, None,
     [[Gramext.Stoken ("", "[:");
       Gramext.Snterm
         (Grammar.Entry.obj (stream_patt : 'stream_patt Grammar.Entry.e));
       Gramext.Stoken ("", ":]");
       Gramext.Sopt
         (Gramext.Snterm
            (Grammar.Entry.obj (ipatt : 'ipatt Grammar.Entry.e)));
       Gramext.Stoken ("", "->");
       Gramext.Snterm (Grammar.Entry.obj (expr : 'expr Grammar.Entry.e))],
      Gramext.action
        (fun (e : 'expr) _ (po : 'ipatt option) _ (sp : 'stream_patt) _
             (loc : Ploc.t) ->
           (sp, po, e : 'parser_case))]];
    Grammar.Entry.obj (stream_patt : 'stream_patt Grammar.Entry.e), None,
    [None, None,
     [[], Gramext.action (fun (loc : Ploc.t) -> ([] : 'stream_patt));
      [Gramext.Snterm
         (Grammar.Entry.obj
            (stream_patt_comp : 'stream_patt_comp Grammar.Entry.e));
       Gramext.Stoken ("", ";");
       Gramext.Slist1sep
         (Gramext.Snterm
            (Grammar.Entry.obj
               (stream_patt_comp : 'stream_patt_comp Grammar.Entry.e)),
          Gramext.Stoken ("", ";"))],
      Gramext.action
        (fun (sp : 'stream_patt_comp list) _ (spc : 'stream_patt_comp)
             (loc : Ploc.t) ->
           (spc :: sp : 'stream_patt));
      [Gramext.Snterm
         (Grammar.Entry.obj
            (stream_patt_comp : 'stream_patt_comp Grammar.Entry.e))],
      Gramext.action
        (fun (spc : 'stream_patt_comp) (loc : Ploc.t) ->
           ([spc] : 'stream_patt))]];
    Grammar.Entry.obj (stream_patt_comp : 'stream_patt_comp Grammar.Entry.e),
    None,
    [None, None,
     [[Gramext.Snterm (Grammar.Entry.obj (patt : 'patt Grammar.Entry.e))],
      Gramext.action
        (fun (p : 'patt) (loc : Ploc.t) ->
           (SpStr (loc, p) : 'stream_patt_comp));
      [Gramext.Snterm (Grammar.Entry.obj (patt : 'patt Grammar.Entry.e));
       Gramext.Stoken ("", "=");
       Gramext.Snterm (Grammar.Entry.obj (expr : 'expr Grammar.Entry.e))],
      Gramext.action
        (fun (e : 'expr) _ (p : 'patt) (loc : Ploc.t) ->
           (SpNtr (loc, p, e) : 'stream_patt_comp));
      [Gramext.Stoken ("", "`");
       Gramext.Snterm (Grammar.Entry.obj (patt : 'patt Grammar.Entry.e));
       Gramext.Sopt
         (Gramext.srules
            [[Gramext.Stoken ("", "when");
              Gramext.Snterm
                (Grammar.Entry.obj (expr : 'expr Grammar.Entry.e))],
             Gramext.action
               (fun (e : 'expr) _ (loc : Ploc.t) -> (e : 'e__1))])],
      Gramext.action
        (fun (eo : 'e__1 option) (p : 'patt) _ (loc : Ploc.t) ->
           (SpTrm (loc, p, eo) : 'stream_patt_comp))]];
    Grammar.Entry.obj (ipatt : 'ipatt Grammar.Entry.e), None,
    [None, None,
     [[Gramext.Stoken ("LIDENT", "")],
      Gramext.action
        (fun (i : string) (loc : Ploc.t) ->
           (MLast.PaLid (loc, i) : 'ipatt))]];
    Grammar.Entry.obj (expr : 'expr Grammar.Entry.e),
    Some (Gramext.Level "simple"),
    [None, None,
     [[Gramext.Stoken ("", "fstream"); Gramext.Stoken ("", "[:");
       Gramext.Slist0sep
         (Gramext.Snterm
            (Grammar.Entry.obj
               (stream_expr_comp : 'stream_expr_comp Grammar.Entry.e)),
          Gramext.Stoken ("", ";"));
       Gramext.Stoken ("", ":]")],
      Gramext.action
        (fun _ (se : 'stream_expr_comp list) _ _ (loc : Ploc.t) ->
           (cstream loc se : 'expr))]];
    Grammar.Entry.obj (stream_expr_comp : 'stream_expr_comp Grammar.Entry.e),
    None,
    [None, None,
     [[Gramext.Snterm (Grammar.Entry.obj (expr : 'expr Grammar.Entry.e))],
      Gramext.action
        (fun (e : 'expr) (loc : Ploc.t) ->
           (SeNtr (loc, e) : 'stream_expr_comp));
      [Gramext.Stoken ("", "`");
       Gramext.Snterm (Grammar.Entry.obj (expr : 'expr Grammar.Entry.e))],
      Gramext.action
        (fun (e : 'expr) _ (loc : Ploc.t) ->
           (SeTrm (loc, e) : 'stream_expr_comp))]]]);;
