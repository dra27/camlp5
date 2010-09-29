(* camlp5r *)
(* $Id: ploc.mli,v 6.2 2010/09/29 04:26:54 deraugla Exp $ *)
(* Copyright (c) INRIA 2007-2010 *)

(** Locations and some pervasive type and value. *)

type t = 'abstract;

(* located exceptions *)

exception Exc of t and exn;
   (** [Ploc.Exc loc e] is an encapsulation of the exception [e] with
       the input location [loc]. To be used to specify a location
       for an error. This exception must not be raised by [raise] but
       rather by [Ploc.raise] (see below), to prevent the risk of several
       encapsulations of [Ploc.Exc]. *)
value raise : t -> exn -> 'a;
   (** [Ploc.raise loc e], if [e] is already the exception [Ploc.Exc],
       re-raise it (ignoring the new location [loc]), else raise the
       exception [Ploc.Exc loc e]. *)

(* making locations *)

value make_loc : int -> int -> (int * int) -> string -> t;
   (** [Ploc.make_loc line_nb bol_pos (bp, ep) comm] creates a location
       starting at line number [line_nb], where the position of the beginning
       of the line is [bol_pos] and between the positions [bp] (included) and
       [ep] excluded. And [comm] is the comment before the location. The
       positions are in number of characters since the begin of the stream. *)
value make_unlined : (int * int) -> t;
   (** [Ploc.make_unlined] is like [Ploc.make] except that the line number
       is not provided (to be used e.g. when the line number is unknown. *)

value dummy : t;
   (** [Ploc.dummy] is a dummy location, used in situations when location
       has no meaning. *)

(* getting location info *)

value first_pos : t -> int;
   (** [Ploc.first_pos loc] returns the position of the begin of the location
       in number of characters since the beginning of the stream. *)
value last_pos : t -> int;
   (** [Ploc.last_pos loc] returns the position of the first character not
       in the location in number of characters since the beginning of the
       stream. *)
value line_nb : t -> int;
   (** [Ploc.line_nb loc] returns the line number of the location or [-1] if
       the location does not contain a line number (i.e. built with
       [Ploc.make_unlined]. *)
value bol_pos : t -> int;
   (** [Ploc.bol_pos loc] returns the position of the beginning of the line
       of the location in number of characters since the beginning of
       the stream, or [0] if the location does not contain a line number
       (i.e. built with [Ploc.make_unlined]. *)
value comment : t -> string;
   (** [Ploc.comment loc] returns the comment before the location. *)

(* combining locations *)

value encl : t -> t -> t;
   (** [Ploc.encl loc1 loc2] returns the location starting at the
       smallest start of [loc1] and [loc2] and ending at the greatest end
       of them. In other words, it is the location enclosing [loc1] and
       [loc2]. *)
value shift : int -> t -> t;
   (** [Ploc.shift sh loc] returns the location [loc] shifted with [sh]
       characters. The line number is not recomputed. *)
value sub : t -> int -> int -> t;
   (** [Ploc.sub loc sh len] is the location [loc] shifted with [sh]
       characters and with length [len]. The previous ending position
       of the location is lost. *)
value after : t -> int -> int -> t;
   (** [Ploc.after loc sh len] is the location just after loc (starting at
       the end position of [loc]) shifted with [sh] characters and of length
       [len]. *)

(* miscellaneous *)

value name : ref string;
   (** [Ploc.name.val] is the name of the location variable used in grammars
       and in the predefined quotations for OCaml syntax trees. Default:
       ["loc"] *)

value get : string -> t -> (int * int * int * int * int);
   (** [Ploc.get fname loc] returns in order: 1/ the line number of
       the begin of the location, 2/ its column, 3/ the line number
       of the first character not in the location, 4/ its column and
       5/ the length of the location. The parameter [fname] is the
       file where the location occurs. *)

value from_file : string -> t -> (string * int * int * int);
   (** [Ploc.from_file fname loc] reads the file [fname] up to the
       location [loc] and returns the real input file, the line number
       and the characters location in the line; the real input file
       can be different from [fname] because of possibility of line
       directives typically generated by /lib/cpp. *)

(* pervasives *)

type vala 'a =
  [ VaAnt of string
  | VaVal of 'a ]
;
   (** Encloser of many abstract syntax tree nodes types, in "strict" mode.
       Thhis allow the system of antiquotations of abstract syntax tree
       quotations to work when using the quotation kit [q_ast.cmo]. *)

value call_with : ref 'a -> 'a -> ('b -> 'c) -> 'b -> 'c;
   (** [Ploc.call_with r v f a] sets the reference [r] to the value [v],
       then call [f a], and resets [r] to its initial value. If [f a] raises
       an exception, its initial value is also reset and the exception is
       re-raised. The result is the result of [f a]. *)

(**/**)

value make : int -> int -> (int * int) -> t;
   (** deprecated function since version 6.00; use [make_loc] instead
       with the empty string *)
