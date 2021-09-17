(* Lockset summaries for single statements. Unlike function summaries, statement summaries
 * are not used for caching in generic CFA analysis. They only store the results of lockset 
 * analysis. Statement precondition is same as function summary precondition. Postcondition
 * is only statement's exit set of locksets. 
 *
 * Summary is non-trivial only for lock operations and calls, otherwise it allways has form
 * entry_lockset -> {entry_lockset}. 
 *
 * Author: Tomas Dacik (xdacik00@fit.vutbr.cz), 2020
 *)

open Lock_types

type precondition = Function_summaries.precondition
(** Statement precondition is same as for function analysis. *)

type postcondition = LocksetSet.t
(** Possible locksets after statement is executed for given precondition. *)

module Summaries : Map.S with type key = Cil_types.stmt * precondition

include Monomorphic_map.S with type key = Cil_types.stmt * precondition
                           and type data = postcondition

val union : t -> t -> t

val summaries_of_stmt : Cil_types.stmt -> t -> t
(** Return subset of summaries only containing given statement. *)

val find_imprecise_lock_stmts : t -> Cil_datatype.Stmt.Set.t
(** Statement is considered imprecise if any of its postconditions is set of locksets with
    cardinality higher than 1, i.e., analysis did not precisely computed which locks are
    locked at this point. *)

val stmt_must_lockset : Cil_types.stmt -> t -> Lockset.t
(** Return locks that are held at entry of statements on all paths through it. *)

val stmt_may_lockset : Cil_types.stmt -> t -> Lockset.t
(** Return locks that are held at entry of statements on at least one path through it. *)

val stmt_exit_may_lockset : Cil_types.stmt -> t -> Lockset.t

val stmt_exit_must_lockset : Cil_types.stmt -> t -> Lockset.t

val stmt_must_acquire : Cil_types.stmt -> t -> Lockset.t
(** Return locks that statement acquires on all paths through it. *)

val stmt_may_acquire : Cil_types.stmt -> t -> Lockset.t
(** Return locks that statement acquires on at least one path through it. *)

val pp : Format.formatter -> t -> unit

val pp_entry : Format.formatter -> Cil_types.stmt * precondition * postcondition -> unit
(** Pretty-print single entry of summary. *)
