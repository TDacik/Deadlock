(* Utilities for scanning and searching in Control Flow Graph that are not implemented in Frama-C.
 * All functions use syntactic information (mainly reachability) only and are therefore
 * under-approximations.
 *
 * Author: Tomas Dacik (xdacik00@fit.vutbr.cz), 2020
 *)

open Trace_utils

val all_stmts_predicate : (Cil_types.stmt -> bool) -> Cil_types.stmt list
(** Return all (possible unreachable) program statements satisfying given predicate. *)

val all_stmts_in_fn_predicate : 
  (Cil_types.stmt -> bool) -> Cil_types.fundec -> Cil_types.stmt list
(** Return all (possible unreachable) program statements satisfying given predicate. *)

val all_fundecs_predicate : (Kernel_function.t -> bool) -> Cil_types.fundec list
(** Return all functions satisfying given predicate. *)

val callsites : Cil_types.stmt -> Cil_types.stmt list
(** Callsites of statement's englobing function. *)

val transitive_callsites : Cil_types.stmt -> Cil_types.stmt list
(** Callsites of statement's englobing function and of all its transitive callers. *)

val toplevel_callsites : Cil_types.fundec list -> Cil_types.stmt -> Cil_types.stmt list
(** Same as 
    'transitive_callsites', but return only statements of specified kernel
    functions (assuming these functions are program entry points). *)

val all_callstacks : ?name:string -> Cil_types.fundec list -> Cil_types.stmt -> Callstack.t list

val max_depth : Cil_types.stmt -> int
