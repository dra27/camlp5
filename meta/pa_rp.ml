(* camlp5r pa_extend.cmo q_MLast.cmo *)
(* $Id: pa_rp.ml,v 1.11 2007/09/15 16:30:43 deraugla Exp $ *)
(* Copyright (c) INRIA 2007 *)

open Exparser;
open Pcaml;

(* Syntax extensions in Revised Syntax grammar *)

EXTEND
  GLOBAL: expr;
  expr: LEVEL "top"
    [ [ "parser"; po = OPT ipatt; "["; pcl = LIST0 parser_case SEP "|"; "]" ->
          <:expr< $cparser loc po pcl$ >>
      | "parser"; po = OPT ipatt; pc = parser_case ->
          <:expr< $cparser loc po [pc]$ >>
      | "match"; e = SELF; "with"; "parser"; po = OPT ipatt; "[";
        pcl = LIST0 parser_case SEP "|"; "]" ->
          <:expr< $cparser_match loc e po pcl$ >>
      | "match"; e = SELF; "with"; "parser"; po = OPT ipatt;
        pc = parser_case ->
          <:expr< $cparser_match loc e po [pc]$ >> ] ]
  ;
  parser_case:
    [ [ "[:"; sp = stream_patt; ":]"; po = OPT ipatt; "->"; e = expr ->
          (sp, po, e) ] ]
  ;
  stream_patt:
    [ [ spc = stream_patt_comp -> [(spc, SpoNoth)]
      | spc = stream_patt_comp; ";"; sp = stream_patt_kont ->
          [(spc, SpoNoth) :: sp]
      | spc = stream_patt_let; sp = stream_patt -> [spc :: sp]
      | -> [] ] ]
  ;
  stream_patt_kont:
    [ [ spc = stream_patt_comp_err -> [spc]
      | spc = stream_patt_comp_err; ";"; sp = stream_patt_kont -> [spc :: sp]
      | spc = stream_patt_let; sp = stream_patt_kont -> [spc :: sp] ] ]
  ;
  stream_patt_comp_err:
    [ [ spc = stream_patt_comp; "?"; e = expr -> (spc, SpoQues e)
      | spc = stream_patt_comp; "!" -> (spc, SpoBang)
      | spc = stream_patt_comp -> (spc, SpoNoth) ] ]
  ;
  stream_patt_comp:
    [ [ "`"; p = patt; eo = OPT [ "when"; e = expr -> e ] -> SpTrm loc p eo
      | "?="; pll = LIST1 lookahead SEP "|" -> SpLhd loc pll
      | p = patt; "="; e = expr -> SpNtr loc p e
      | p = patt -> SpStr loc p ] ]
  ;
  stream_patt_let:
    [ [ "let"; p = ipatt; "="; e = expr; "in" -> (SpLet loc p e, SpoNoth) ] ]
  ;
  lookahead:
    [ [ "["; pl = LIST1 patt SEP ";"; "]" -> pl ] ]
  ;
  ipatt:
    [ [ i = LIDENT -> <:patt< $lid:i$ >> ] ]
  ;
  expr: LEVEL "simple"
    [ [ "[:"; se = LIST0 stream_expr_comp SEP ";"; ":]" ->
          <:expr< $cstream loc se$ >> ] ]
  ;
  stream_expr_comp:
    [ [ "`"; e = expr -> SeTrm loc e | e = expr -> SeNtr loc e ] ]
  ;
END;
