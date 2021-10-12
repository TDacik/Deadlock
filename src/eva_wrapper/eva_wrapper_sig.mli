(* Minimal signature of EVA wrapper
 *
 * Author: Tomas Dacik (xdacik00@fit.vutbr.cz), 2021
 *)

type abstract_context = (Cil_types.varinfo * int) list
(** Simplified representation of memory adresses used by wrappers *)

module type EVA_WRAPPER = sig
  
  val using_eva : bool ref

  (** {2 Imperative manipulation} *)

  val init : unit -> unit

  val set_active_thread : Thread.t -> unit

  val get_active_thread : unit -> Thread.t option

  (** {2 Queries} *)

  val eval_expr : Cil_types.stmt -> Cil_types.exp -> abstract_context
  (** Evalaule expression to simplified abstract context *)

  val eval_expr_raw : Cil_types.stmt -> Cil_types.exp -> Cvalue.V.t
  (** Evaluate expression without any simplifications *)
  
  val get_stmt_state : ?after:bool -> Cil_types.stmt -> Cvalue.Model.t
  
  val eval_fn_pointer : Cil_types.stmt -> Cil_types.exp -> Cil_types.fundec list

  (** {2 Inputs & Outputs} *)

  val stmt_reads : Cil_types.stmt -> Locations.Zone.t

  val stmt_writes : Cil_types.stmt -> Locations.Zone.t

  val inputs : Cil_types.fundec -> Base.t list

  val pure_inputs : Cil_types.fundec -> Base.Set.t

  val outputs : Cil_types.fundec -> Base.t list

  (** {2 Imprecision of the analysis} 

  type imprecision

  val imprecise_threads : unit -> Thread.t list

  val pp_imprecision : unit -> unit

  *)

end
