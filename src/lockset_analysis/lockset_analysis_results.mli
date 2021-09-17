open Cil_datatype
open Lock_types
open Deadlock_types

module Function_status : sig

  type status =
    | Normal
    | Refined of Varinfo.t list * Varinfo.t list
    | Imprecise

  type t

  val empty : t

  val compare : t -> t -> int

  val add : Fundec.t -> status -> t -> t

  val find : Fundec.t -> t -> status

  val union : t -> t -> t

  val is_normal : t -> Fundec.t -> bool
  
  val is_imprecise : t -> Fundec.t -> bool

end

type t = {
  lockgraph : Lockgraph.t;
  lock_stmts : Stmt.Set.t;
  mutable imprecise_lock_stmts : Stmt.Set.t;
  function_status : Function_status.t;
  stmt_summaries : Stmt_summaries.t;
  function_summaries : Function_summaries.t;
}

val empty : t

val join : t -> t -> t
(** Join two results, no over-approximation *)

val add_imprecise_stmt : Cil_types.stmt -> t -> unit

(** Analysis **)

val is_precise : t -> bool

val find_deadlocks : t -> abstract_deadlock list

val path_sensitive_fns : t -> Fundec.t list

val context_sensitive_fns : t -> Fundec.t list

val imprecise_fns : t -> Fundec.t list

(** Accessors **)

val lockgraph : t -> Lockgraph.t

val lock_stmts : t -> Stmt.Set.t

val imprecise_lock_stmts : t -> Stmt.Set.t

val stmt_summaries : t -> Stmt_summaries.t

val function_summaries : t -> Function_summaries.t

(** Results of lockset analysis **)

val summaries_of_stmt : t -> Cil_types.stmt -> Stmt_summaries.t

val stmt_must_lockset : Cil_types.stmt -> t -> Lockset.t
(** Return set of locks that are held at entry of statements on all paths through it *)

val stmt_may_lockset : Cil_types.stmt -> t -> Lockset.t
(** Return set of locks that are held at entry of statements on some path through it *)

val stmt_must_acquire : Cil_types.stmt -> t -> Lockset.t

val stmt_may_acquire : Cil_types.stmt -> t -> Lockset.t

val stmt_exit_must_lockset : Cil_types.stmt -> t -> Lockset.t

(**            **)
val summaries_of_fn : t -> Cil_types.fundec -> Function_summaries.t

(** Statistics **)

val nb_lock_stmts : t -> int

val nb_stmt_summaries : t -> int

val nb_imprecise_lock_stmts : t -> int

val nb_analysed_functions : t -> int

val avg_analyses_per_fn : t -> float

(** Printers **)

val pp : Format.formatter -> t -> unit
(** Dummy printer **)

val pp_stmt_summaries : Format.formatter -> t -> unit
(** Print all statement summaries **)

val pp_fn_summaries : Format.formatter -> t -> unit
(** Print all function summaries **)

val pp_non_id_fn_summaries : Format.formatter -> t -> unit
(** Print summaries of those functions that do some lock manipulation **)
