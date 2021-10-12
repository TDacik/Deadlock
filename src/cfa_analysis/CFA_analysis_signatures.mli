open Trace_utils
open Thread_analysis

type bool_with_unknown = [`True | `False | `Unknown]
type call_analysis = [`Continue | `Analyse_atomically]

(* State represents data propagated during cfa traversal *)

module type STATE = sig
    type t

    val empty : Thread.t -> t
    val compare : t -> t -> int
    val are_joinable : t -> t -> bool
    val join : t -> t -> t
    val pp : Format.formatter -> t -> unit
end

(* Results are computed for each function separately and joined after,
 * this enables their easy caching and refinement of function analysis
 * when its result is not presice enough *)

module type RESULTS = sig
    type t

    val empty : t
    val join : t -> t -> t
    val pp : Format.formatter -> t-> unit
end

(* Function cache *)

module type FUNCTION_CACHE = sig
  type t
  type state
  type results

  val empty : t
  val add : Cil_types.fundec -> state -> Callstack.t -> (state list * results) -> t -> t
  val find_and_update : Cil_types.fundec -> state -> Callstack.t -> t -> (state list * results)

  val pp : Format.formatter -> t -> unit
  (** For debug purposes only, can be no-operation *)

end

(* When [condition] holds after function analysis, its results are deiscarded and
 * [refine_entry_state] is called. *) 

module type REFINEMENT = sig
    type state
    type results

    (** Refinement of analysis. In all following functions, current function is located
        on the top of the callstack. *)

    val condition : Callstack.t -> Cil_types.fundec -> state list -> results -> bool
    (** After function was analysed resulting to (states, results), should is analysis be refined? *)
    
    val refine_entry_state : Callstack.t -> state -> state
    (** How to refine entry state. *)
    
    val post_refine : Callstack.t -> state -> state
    
    val post_failed_refine : 
      Callstack.t -> 
      state list -> 
      state list -> 
      results ->
      results ->
      state list * results
    (** post_failed_refine callstack old_states new_states old_results new_results *)

end

module type ANALYSIS = sig
  
  (* Splitting to submodules enables using of default modules for unwanted features *)

  module State : STATE
  module Results : RESULTS
  module Refinement : REFINEMENT with type state = State.t
                                  and type results = Results.t

  module Function_cache : FUNCTION_CACHE with type state = State.t
                                          and type results = Results.t

  module Debug : Log.Messages

  val name : string

  val analyse_stmt : Callstack.t -> Cil_types.stmt -> State.t -> (State.t list * Results.t)
  
  val analyse_call : Callstack.t -> Cil_types.stmt -> State.t -> call_analysis
 
  val update_return : Callstack.t -> Cil_types.stmt -> State.t -> State.t

  val check_guard : Cil_types.stmt -> Cil_types.exp -> State.t -> bool_with_unknown

  val function_entry : Callstack.t -> State.t -> State.t
  (** Hook on function entry. This function is NOT called when summary of a function is
      used insted of its analysis. *)

  val function_exit :
    Callstack.t -> State.t -> State.t list -> Results.t -> (State.t list * Results.t)
   (** Hook on function exit *)

  module Strategy : sig
    val only_forward_edges : bool
  end

  val post_process : State.t list -> Results.t -> Thread_graph.t -> Function_cache.t -> Results.t

end
