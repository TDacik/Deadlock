(* Deadlock API
 * See particular modules for their documentation.
 *
 * Author: Tomas Dacik (xdacik00@fit.vutbr.cz), 2020
 *)

open Cil_datatype

module Lock_types : sig
  
  module Lock : sig

    type t

    val pp : Format.formatter -> t -> unit

  end

  module Lockset : sig

    include Set.S with type elt = Lock.t
    
    module Map : Map.S

    val are_disjoint : t -> t -> bool

    val to_list : t -> Lock.t list

    val pp : Format.formatter -> t -> unit

  end

  module LocksetSet : sig
  
    include Set.S

    val pp : Format.formatter -> t -> unit

  end

end

module Thread : sig

  type t
  
  val create : ?is_main:bool -> Cil_types.fundec -> Cvalue.Model.t -> Cvalue.V.t -> t
  
  val create_bottom : ?is_main:bool -> Cil_types.fundec -> t

  val compare : t -> t -> int

  val equal : t -> t -> bool

  val get_entry_point : t -> Cil_types.fundec

  val is_computed : t -> bool

  val is_main : t -> bool

  val get_globals : t -> Db.Value.state

  val get_args : t -> Db.Value.t

  val get_arg_base : t -> Base.t list

  val get_formal_arg_base : t -> Base.t option

  val to_string : t -> string

  val pp : Format.formatter -> t -> unit

  val pp_init_state : Format.formatter -> t -> unit

  module Set : Set.S with type elt = t

  module Map : Map.S with type key = t

end

module Eva_wrapper : sig

  val init : [`EVA | `CIL] -> unit

  val using_eva : bool ref

  val set_active_thread : Thread.t -> unit

  val stmt_reads : Cil_types.stmt -> Locations.Zone.t

  val stmt_writes : Cil_types.stmt -> Locations.Zone.t

  val eval_fn_call : Cil_types.stmt -> Cil_types.exp -> Cil_types.fundec list

end

module Concurrency_model : sig

  type stmt =
    | Lock of Cil_types.exp
    | Unlock of Cil_types.exp
    | Lock_init of Cil_types.exp
    | Lock_destroy of Cil_types.exp
    | Condition_wait of Cil_types.exp * Cil_types.exp
    | Thread_create of Cil_types.exp * Cil_types.exp * Cil_types.exp
    | Thread_join of Cil_types.exp
    | Call of Cil_types.exp * Cil_types.exp list
    | End_of_path
    | Other

  val classify_stmt : Cil_types.stmt -> stmt

  val is_lock_init : Cil_types.stmt -> bool

  val is_lock_destroy : Cil_types.stmt -> bool

  val thread_create_arg : Cil_types.stmt -> Cil_types.exp

end

module CFG_utils : sig

  val all_stmts_predicate : (Cil_types.stmt -> bool) -> Cil_types.stmt list

end

module Thread_analysis : sig

  module Thread_graph : sig

    include Graph.Sig.P
      with type V.t = Thread.t
       and type E.t = Thread.t * Cil_types.stmt * Thread.t

    val get_threads : t -> Thread.t list

    val find_by_fundec : t -> Cil_types.fundec -> Thread.t

    val find_by_kf : t -> Kernel_function.t -> Thread.t
  
    val create_stmts_of_thread : t -> Thread.t -> Cil_types.stmt list
  
    val is_created_multiple_times : t -> Thread.t -> bool

    val pp : Format.formatter -> t -> unit
  end

  val compute : unit -> Thread_graph.t

end

module Trace_utils : sig
  module Callstack : sig

    type t

    val empty : t

    val is_empty : t -> bool

    val depth : t -> int

    val compare : t -> t -> int

    val compare_abstr : ?with_action_stmt:bool -> int -> t -> t -> int

    val top_call_fn : t -> Cil_types.fundec
    
    val top_call_stmt : t -> Cil_types.stmt
    
    val top_call : t -> Cil_types.fundec * Cil_types.stmt

    val mem_call : t -> Cil_types.fundec -> bool

    val pop_call : t -> t

    val push_thread_entry : Thread.t -> t

    val push_call : Cil_types.stmt -> Cil_types.fundec -> t -> t

    val push_action : Cil_types.stmt -> string -> t -> t

    val get_thread : t -> Thread.t

    val set_thread : Thread.t -> t -> t

    val get_bottom_stmt : t -> Cil_types.stmt

    val get_action : t -> Cil_types.stmt * string

    val get_action_stmt : t -> Cil_types.stmt

    val pp : Format.formatter -> t -> unit
  
    val cut_prefix : Cil_types.fundec -> t -> t

    val concat : t -> t -> t

  end

  module Edge_trace : sig
    type t
  end

end

module Lockgraph : sig
  open Lock_types
  open Trace_utils
  include Graph.Sig.P
    with type V.t = Lock.t
     and type E.t = Lock.t * Edge_trace.t list * Lock.t
     and type E.label = (Edge_trace.t) list

  val add_edge : t -> E.t -> t
end

module Lockset_analysis : sig

  open Lock_types

  type precondition = Thread.t * Lockset.t * Cvalue.Model.t

  module Stmt_summaries : sig

    include Monomorphic_map.S with type key = Stmt.t * precondition

    val union : t -> t -> t

  end
  
  module Function_summaries : sig
    
    include Monomorphic_map.S with type key = Fundec.t * precondition
    
    val union : t -> t -> t
  
  end

  module Results : sig

    type t
    val empty : t

    val get_lockgraph : t -> Lockgraph.t
    val get_lock_stmts : t -> Stmt.Set.t
    val get_imprecise_lock_stmts : t -> Stmt.Set.t
    val get_stmt_summaries : t -> Stmt_summaries.t
    val get_function_summaries : t -> Function_summaries.t

    val stmt_must_lockset : Cil_types.stmt -> t -> Lock_types.Lockset.t
    val stmt_may_lockset : Cil_types.stmt -> t -> Lock_types.Lockset.t
    val stmt_must_acquire : Cil_types.stmt -> t -> Lock_types.Lockset.t
    val stmt_may_acquire : Cil_types.stmt -> t -> Lock_types.Lockset.t
  
  end

  val compute : Thread_analysis.Thread_graph.t -> Results.t 

end

module CFA_analysis_signatures : sig

  open Trace_utils
  open Thread_analysis

  type bool_with_unknown = [`True | `False | `Unknown]
  type call_analysis = [`Continue | `Analyse_atomically]

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

  end

  (* When [condition] holds after function analysis, its results are deiscarded and
   * [refine_entry_state] is called. *) 

  module type REFINEMENT = sig
    type state
    type results

    val condition : Callstack.t -> Cil_types.fundec -> state list -> results -> bool
    val refine_entry_state : Callstack.t -> state -> state
    val post_refine : Callstack.t -> state -> state
    val post_failed_refine : 
      Callstack.t -> 
      state list -> 
      state list -> 
      results ->
      results ->
      state list * results
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

end

module CFA_analysis : sig

  open Trace_utils
  open Thread_analysis
  open CFA_analysis_signatures

  module Make (Analysis : ANALYSIS) : sig
    val compute : Thread_graph.t -> Analysis.Results.t
  end

end

module CFA_analysis_utils : sig
  open CFA_analysis
  open CFA_analysis_signatures

  module No_refinement (State : STATE) (Results : RESULTS)
    : REFINEMENT with type state = State.t 
                  and type results = Results.t 

  module Visited_functions (State : STATE) (Results : RESULTS)
    : FUNCTION_CACHE with type state = State.t 
                      and type results = Results.t

end

module Imperative_counter : sig

  module type IMPERATIVE_COUNTER = sig
    
    val set : int -> unit
    val get : unit -> int
    val reset : unit -> unit

    val inc : unit -> unit
    val dec : unit -> unit

    val inc_cond : bool -> unit
    val dec_cond : bool -> unit

    val add : int -> unit
    val sub : int -> unit

    val add_cond : int -> bool -> unit
    val sub_cond : int -> bool -> unit

  end

  module Counter () : IMPERATIVE_COUNTER

end

module Happend_before : sig

  val callstack_bound : unit -> int

end

module Concurrency_check : sig

  open Trace_utils
  open Imperative_counter

  val are_concurrent_callstacks : 
    ?conservative:bool 
    -> Thread_analysis.Thread_graph.t 
    -> Lockset_analysis.Results.t 
    -> Callstack.t 
    -> Callstack.t 
    -> bool

  module Nb_deadlocks : IMPERATIVE_COUNTER
  module Nb_nonc : IMPERATIVE_COUNTER
  module Nb_before_create : IMPERATIVE_COUNTER
  module Nb_after_join : IMPERATIVE_COUNTER
  module Nb_same_thread : IMPERATIVE_COUNTER
  module Nb_nonc_threads : IMPERATIVE_COUNTER
  module Nb_gatelock : IMPERATIVE_COUNTER
end

module Statement_utils : sig

  val is_exit_point : Cil_types.stmt -> bool

  val find_englobing_fn : Cil_types.stmt -> Cil_types.fundec 

end

module Print_utils : sig

  val pp_loc : Format.formatter -> Cil_types.stmt -> unit
 
  val stmt_line : Cil_types.stmt -> int

end
