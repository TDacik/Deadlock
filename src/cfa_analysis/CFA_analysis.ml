(* Implementation of analysis similar to classic Data Flow Analysis with generic function summaries,
 * support for multi-threaded programs and refinement of functions' analysis -- if some user-defined
 * condition holds after analysis, the analysis of function can be refined with less general 
 * precondition.
 *
 * TODO: The analysis is designed as generic, but it still copy implementation of original lockset
 * analysis and some aspect are therefore not so generic as they could be.
 *
 * Author: Tomas Dacik (xdacik00@fit.vutbr.cz), 2020
 *)

open! Deadlock_top

open Trace_utils
open Thread_analysis

open Cil_types
open Cil_datatype

module Stmts = Statement_utils
module CFA = Interpreted_automata

include CFA_analysis_signatures

(* Statistics *)
module Nb_success_refinements = Imperative_counter.Counter (struct end)
module Nb_failed_refinements = Imperative_counter.Counter (struct end)
module Nb_function_analyses = Imperative_counter.Counter (struct end)

module Make (Analysis : ANALYSIS) = struct
  
  open Analysis

  (* Set of states with automatic joining of joinable states *)
  module States = struct

    module S = Set.Make(State)

    include S

    (** Partition of cache to joinable and non-joinable states **)
    let join_partition state set = S.partition (State.are_joinable state) set

    let add state set =
      let joinable, non_joinable = join_partition state set in
      let join_state = S.fold State.join joinable state in
      S.add join_state non_joinable

    let cardinal = S.cardinal

    let to_list set = S.fold List.cons set []

    let from_list l = List.fold_right S.add l S.empty

    let pp fmt states = S.iter (Format.fprintf fmt "%a\n" State.pp) states

  end

  (** Initialisation of debug functor **)
  module Debug = CFA_analysis_debug.Make
      (struct
        module Analysis = Analysis

        type state = State.t
        type results = Results.t
        type states = States.t
        type callstack = Callstack.t

        let pp_state = State.pp
        let pp_results = Results.pp
        let pp_states = States.pp
        let pp_callstack = Callstack.pp
      end)

  (* For each vertex contains set of states that reached the vertex
   *  - implemented as stack simulating nesting of function calls *)
  module Vertex_cache = struct 
    
    module M = Map.Make
        (struct
          type t = CFA.vertex
          let compare (v1 : CFA.vertex) (v2 : CFA.vertex) = 
            Int.compare v1.vertex_key v2.vertex_key
        end)

    let cache = ref (Stack.create ())

    let push () = Stack.push M.empty !cache

    let pop () = let _ = Stack.pop !cache in ()

    let clean () = cache := (Stack.create ())

    let find_or_empty vertex =
      try M.find vertex (Stack.top !cache)
      with Not_found -> States.empty

    let add vertex state =
      let states = find_or_empty vertex in
      let old_cache = Stack.pop !cache in
      let cache' = M.add vertex (States.add state states) old_cache in
      Stack.push cache' !cache

  end

  module Fn_cache = struct

    let empty = Function_cache.empty

    let find_and_update fn state callstack cache =
      let states, res = Function_cache.find_and_update fn state callstack cache in
      States.from_list states, res

    let add thread fn state (states, res) cache = 
      Function_cache.add thread fn state (States.to_list states, res) cache

    let pp = Function_cache.pp
        
  end
  
  module Control = struct

    type t = States.t * Function_cache.t * Results.t
    
    (* Precondition: cache is included in cache' *)
    let join (states, cache, results) (states', cache', results') =
      (States.union states states',
       cache',
       Results.join results results'
      )

    let analyse_stmt callstack stmt state cache = 
      let states, results = Analysis.analyse_stmt callstack stmt state in
      assert (List.length states > 0);

      let states =
        if Exit_points.is_exit_point stmt
        then List.map (fun state -> Analysis.update_return callstack stmt state) states
        else states
      in

      let states = States.from_list states in
      Debug.debug_stmt stmt state states;
      (states, cache, results)

    let return cache = (States.empty, cache, Results.empty)

    let fork fn lst cache =
      List.fold_left
        (fun (states, cache, results) x ->
           let states', cache', results' = fn x cache in
           (States.union states states',
            cache',
            Results.join results results'
           )         
        ) (return cache) lst


    let fork_states fn (states, cache, results) =
      List.fold_left
        (fun (states, cache, results) state ->
           let states', cache', results' = fn state cache in
           (States.union states states',
            cache',
            Results.join results results'
           )
        ) (States.empty, cache, results) (States.to_list states)

  end
  
  (** Fork analysis for each possible call *)
  let rec traverse_call callstack stmt expr state cache =
    let possible_calls = Eva_wrapper.eval_fn_call stmt expr in
    if possible_calls == []
    then (States.singleton state, cache, Results.empty)
    else Control.fork (fun call -> traverse_fn callstack stmt call state) possible_calls cache

  (** Traverse vertex of CFA *)
  and traverse_vertex callstack g (vertex : CFA.G.V.t) state cache =
    let fn = Callstack.top_call_fn callstack in
    let cached_states = Vertex_cache.find_or_empty vertex in

    if States.mem state cached_states then
      Control.return cache
    
    else begin
      Vertex_cache.add vertex state;
      let succ_edges = CFA.G.succ_e g vertex in
      Control.fork (fun e -> traverse_edge callstack g e state) succ_edges cache
    end

  (** Traverse edge of CFA *)
  and traverse_edge callstack g (v, edge, next) state cache =
    Debug.debug_edge (v, edge, next);
    let fn = Callstack.top_call_fn callstack in
    let kf = Stmts.kernel_fn_from_fundec fn in

    (* Stop analysis on backage *)
    if Strategy.only_forward_edges && CFA.is_back_edge kf (v, next) then
      Control.return cache

    else match edge.edge_transition with
      | CFA.Return (_, stmt) ->
        Control.analyse_stmt callstack stmt state cache

      | CFA.Guard (expr, kind, stmt) ->
        let context = Control.analyse_stmt callstack stmt state cache in
        Control.fork_states (traverse_guard callstack g next stmt kind expr) context

      | CFA.Instr (instr, stmt) ->
        let context = traverse_instr callstack stmt instr state cache in
        Control.fork_states (traverse_vertex callstack g next) context

      | CFA.Enter _ | CFA.Leave _ | CFA.Skip | CFA.Prop (_, _) ->
        traverse_vertex callstack g next state cache

  and traverse_instr callstack stmt instr (state : States.elt) cache =
    Debug.debug_instr callstack stmt instr state;
    match instr with
    | Call (_, expr, _, _) -> 
      begin match Analysis.analyse_call callstack stmt state with
        | `Analyse_atomically -> Control.analyse_stmt callstack stmt state cache
        | `Continue -> traverse_call callstack stmt expr state cache
      end
    
    | Local_init (_, init, _) ->
      begin match init with
        | AssignInit _ -> Control.analyse_stmt callstack stmt state cache
        | ConsInit (fn_varinfo, args, _) ->
          begin match Analysis.analyse_call callstack stmt state with
            | `Analyse_atomically -> Control.analyse_stmt callstack stmt state cache
            | `Continue ->
              let expr = Cil.evar fn_varinfo in
              traverse_call callstack stmt expr state cache
          end
      end

    (* Ordinary stmts *)
    | _ -> Control.analyse_stmt callstack stmt state cache


  and traverse_guard callstack g next stmt kind expr state cache =
    let eval = Analysis.check_guard stmt expr state in
    Debug.debug_guard expr kind eval;
    match kind, eval with
    | Then, `False
    | Else, `True  -> Control.return cache

    | Then, `True ->
      let cs = Callstack.push_guard stmt Callstack.Then callstack in
      traverse_vertex cs g next state cache

    | Else, `False ->
      let cs = Callstack.push_guard stmt Callstack.Else callstack in
      traverse_vertex cs g next state cache

    | Then, `Unknown -> 
      let cs = Callstack.push_guard stmt Callstack.Then_nondet callstack in
      traverse_vertex cs g next state cache

    | Else, `Unknown ->
      let cs = Callstack.push_guard stmt Callstack.Else_nondet callstack in
      traverse_vertex cs g next state cache


  and traverse_fn callstack callsite fn state cache =
    (* Recursive call is considered to have no effect *)
    if Callstack.mem_call callstack fn then
      (States.singleton state, cache, Results.empty)

    else begin
      let callstack =
        if Stmt.equal callsite Cil.dummyStmt then callstack
        else Callstack.push_call callsite fn callstack
      in

      (* Try cache first *)
      try
        let states, results = Fn_cache.find_and_update fn state callstack cache in
        Debug.debug_cache_hit fn states results;
        (states, cache, results)

      (* Analyse function *)
      with Not_found ->
        (* Entry is possibly refined entry state *)
        let entry, states, cache, results = analyse_fn callstack callsite fn state cache in
        let cache = Fn_cache.add fn entry callstack (states, results) cache in
        let states, results =
          Analysis.function_exit fn callsite state (States.to_list states) results in
        let states = States.from_list states in
        Debug.debug_fn_leave fn states results;
        (states, cache, results)
    end

  (** Function analysis with possible refinement *)
  and analyse_fn ?(already_refined=false) callstack callsite fn state cache =
    Nb_function_analyses.inc ();
    let state = Analysis.function_entry callstack state in
    let kf = Stmts.kernel_fn_from_fundec fn in
    let cfa = CFA.get_automaton kf in
    Debug.debug_fn_enter kf state;

    Vertex_cache.push ();
    let states, cache', results = 
      traverse_vertex callstack cfa.graph cfa.entry_point state cache
    in 
    Vertex_cache.pop ();

    (* Refinement *)
    let refine_callstack = Callstack.push_call callsite fn callstack in
    if (Refinement.condition refine_callstack fn (States.to_list states) results
        && (not already_refined)
        && Callstack.depth callstack > 1 (* Do not refine threads *)
       )
    then begin
      (* Analysis refinement, note that we use cache and instead cache', so are imprecisely 
       * computed function summaries are dropped *)
      Debug.refinement_start fn states callstack;
      let entry, states_refined, cache_refined, results_refined =
        traverse_fn_refined fn callsite state callstack cache
      in
      (* Refinement condition still hold and refinement was therefore unsuccessful *)
      if Refinement.condition refine_callstack fn (States.to_list states_refined) results_refined then begin
        Nb_failed_refinements.inc ();
        Debug.refinement_finished fn states_refined false;
        let states_new = States.to_list states_refined in
        let states_old = States.to_list states in
        let results_new = results_refined in
        let states_post, results_post =
          Refinement.post_failed_refine
            refine_callstack states_old states_new results results_new
        in
        (entry, States.from_list states_post, cache_refined, results_post)
      end
      else begin 
        Nb_success_refinements.inc ();
        Debug.refinement_finished fn states_refined true;
        (entry, states_refined, cache_refined, results_refined)
      end
    end
    else (state, states, cache', results)

  and traverse_fn_refined fn callsite state callstack cache =
    let state = Refinement.refine_entry_state callstack state in
    let entry, states, cache, results = analyse_fn ~already_refined:true callstack callsite fn state cache in
    (entry, States.map (Refinement.post_refine callstack) states, cache, results)

  (** Compute analysis for each thread and join their results *)
  let compute thread_graph =
    Debug.trav_start ();
    Vertex_cache.clean ();
    Nb_success_refinements.reset ();
    Nb_failed_refinements.reset ();
    Nb_function_analyses.reset ();
    
    Thread_graph.fold_vertex
      (fun thread (results, cache) ->
         Self.feedback "Computing thread %a" Thread.pp thread;
         Eva_wrapper.set_active_thread thread;
         let entry_point = Thread.get_entry_point thread in
         let callsite = Cil.dummyStmt in
         let callstack = Callstack.push_thread_entry thread in
         let state = State.empty thread in
         let states', cache', results' = traverse_fn callstack callsite entry_point state cache in
         let post_results = Analysis.post_process (States.to_list states') results' thread_graph cache' in
         (Results.join results post_results, cache')
      ) thread_graph (Results.empty, Fn_cache.empty)
    |> fst
end
