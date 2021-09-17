(* Utilities for pretty-printing.
 *
 * Author: Tomas Dacik (xdacik00@fit.vutbr.cz), 2020
 *)

val get_time : unit -> string

val pp_globals : Format.formatter -> Cvalue.Model.t -> unit
(** Filter and print global variables only *)

val stmt_line : Cil_types.stmt -> int
(** Return number of line for a statement *)

val pp_loc : Format.formatter -> Cil_types.stmt -> unit
(** Print statement as its position in source code *)
