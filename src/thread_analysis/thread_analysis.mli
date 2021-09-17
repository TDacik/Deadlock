(* Thread graph is a multigraph that represents parent-child relations of threads.
 *
 * Edges are of form:  parent --[create_stmt]--> child
 *
 * Author: Tomas Dacik (xdacik00@fit.vutbr.cz), 2020 
 *)

module Thread_graph : sig

  (** Thread graph is oriented graph with threads as vertices and edges that represent
      parent-child relation. Edges are labelled by statements, where creation of child
      was done. For two threads there can be more create-edges differentiated by their
      labels. *)

  include Graph.Sig.P
    with type V.t = Thread.t
     and type E.t = Thread.t * Cil_types.stmt * Thread.t

  val equal : t -> t -> bool

  val hash : t -> int

  val get_threads : t -> Thread.t list
  (** List of all threads **)

  val get_entry_points : t -> Cil_types.fundec list
  (** List of entry point functions *)

  val get_create_stmts : t -> Cil_types.stmt list
  (** List of all statements where threads are created **)

  val create_stmts_of_thread : t -> Thread.t -> Cil_types.stmt list
  (** List of all statements where given thread is created **)

  val get_thread_ids : t -> Thread.t -> Cil_types.lval list
  (** List of all thread identifiers as strings **)

  val is_created_multiple_times : t -> Thread.t -> bool
  (** Is given thread created multiple times **)

  val find_by_fundec : t -> Cil_types.fundec -> Thread.t

  val find_by_kf : t -> Kernel_function.t -> Thread.t

  val get_main_thread : t -> Thread.t
  (** Return representation of the main thread *)

  val get_equiv_threads : t -> Thread.t -> Thread.t list
  (** Return all threads that have initial state equivalent to t without t itself *)

  val imprecise_threads : t -> Thread.t list

  val is_precise : t -> bool

  val pp : Format.formatter -> t -> unit
  
  val pp_threads : Format.formatter -> t -> unit

  val pp_init_states : Format.formatter -> t -> unit

end

val compute : unit -> Thread_graph.t

(** {2 Statistics} *)

module Nb_fixpoint_iterations : Imperative_counter.IMPERATIVE_COUNTER
