(* Implementation of lockset analysis as instance of CFA analysis.
 *
 * The structure of this module is following. First, all necesary functions are defined and the CFA
 * analysis is instantiated. For clarity, all branching depending on Deadlock's parameters should 
 * occur in the second part only.
 *
 * Author: Tomas Dacik (xdacik00@fit.vutbr.cz), 2020
 *)

open! Deadlock_top

open Locations
open Cil_types

open Lock_types
open Trace_utils
open Function_summaries
open Abstraction_refinement

module Results = Lockset_analysis_results
module Function_status = Results.Function_status
module Stmts = Statement_utils

(* Abstract state of lockset analysis *)
module State = struct

  type t = {
    lockset : Lockset.t;
    context : Cvalue.Model.t;
    thread : Thread.t;
    function_status : Function_status.t;
    imprecise : bool;
  }

  let empty thread = {
    lockset = Lockset.empty;
    context = Cvalue.Model.empty_map;
    thread = thread;
    function_status = Function_status.empty;
    imprecise = false;
  }

  let pp_context fmt context =
    if Cvalue.Model.is_empty_map context then Format.fprintf fmt "{}"
    else Format.fprintf fmt "%a" Cvalue.Model.pretty context

  let pp fmt state = 
    Format.fprintf fmt "  lockset: %a\n  context: %a\n" 
      Lockset.pp state.lockset
      pp_context state.context

  (* States can be join if they have the same lockset *)
  let are_joinable s1 s2 = Lockset.equal s1.lockset s2.lockset

  let compare s1 s2 =
    let res1 = Lockset.compare s1.lockset s2.lockset in
    if res1 <> 0 then res1
    else Cvalue.Model.compare s1.context s2.context

  let join s1 s2 =
    assert (are_joinable s1 s2);
    assert (Thread.equal s1.thread s2.thread);
    {
      lockset = s1.lockset;
      context = Cvalue.Model.join s1.context s2.context;
      thread = s1.thread;
      function_status = Function_status.union s1.function_status s2.function_status;
      imprecise = s1.imprecise || s2.imprecise;
    }

  let update_function_status_var kind status var = 
    let kf = Kernel_function.find_defining_kf var in
    match kf with
    | None -> status 
    | Some kf -> 
      try
        let fn = Kernel_function.get_definition kf in
        match kind with
        | `Path -> Function_status.add fn (Refined ([], [var])) status
        | `Context -> Function_status.add fn (Refined ([var], [])) status
      with Kernel_function.No_Definition -> status

  let update_function_status state cs_vars ps_vars =
    let fn_status = state.function_status in
    let fn_status = List.fold_left (update_function_status_var `Context) fn_status cs_vars in
    let fn_status = List.fold_left (update_function_status_var `Path) fn_status ps_vars in
    {state with function_status = fn_status}

  let mark_fn_imprecise state fn =
    let fn_status = state.function_status in
    {state with function_status = Function_status.add fn Imprecise fn_status}
 
  (* Convert state to function precondition *)
  let to_precondition state = (state.thread, state.lockset, state.context)

end

(* ==== Operations over set of abstract states ==== *)

open State
open Results

(* Return set of locksets of given states *)
let locksets (states : State.t list) =
  List.fold_left (fun acc s -> LocksetSet.add s.lockset acc) LocksetSet.empty states

let is_any_imprecise (states : State.t list) =
  List.exists (fun s -> s.imprecise) states

let function_status (states : State.t list) =
  List.fold_left (fun acc (s : State.t) -> Function_status.union s.function_status acc) 
    Function_status.empty
    states

let check_return_code stmt ls =
  Lockset.filter
    (fun lock ->
       match Lock.return_var lock with
       | Some var ->
         let values = Eva_wrapper.eval_expr_raw stmt var in
         Cvalue.V.contains_zero values || Cvalue.V.is_bottom values
       | None -> true
    ) ls

let update_return callstack stmt state =
  let ls = check_return_code stmt state.lockset in
  {state with lockset = ls}

(* ==== Precondition refinement ==== *)

(* Locks should not refer to local or formal variable -- this can be case when not using EVA *)
let is_state_imprecise fn state = Lockset.exists Lock.is_weak state.lockset

(* Single function will probably not introduce a cycle *)
let are_results_imprecise fn results = Lockgraph.has_cycle results.lockgraph

let should_be_refined fn states results =
  List.exists (is_state_imprecise fn) states
  || are_results_imprecise fn results
  || List.length states > 1

let can_be_refined callstack fn states results =
  let fn, callsite = Callstack.top_call callstack in
  (* Refinement for threads is not implemented yet *)
  if Stmt.equal Cil.dummyStmt callsite then false
  else  
    let lock_params = Concurrency_model.fn_lock_params fn in
    let path_params, _ = extract_pure_inputs callstack in
    lock_params <> [] 
    || path_params <> []

let refine_condition callstack fn states results =
  should_be_refined fn states results
  && can_be_refined callstack fn states results
  && not @@ is_any_imprecise states

(* Refine function that is sensitive to input lock parameter *)
let refine_lock_params callstack params = 
  List.fold_left
    (fun (params, context) param ->
       let params', context' = find_binding callstack param in
       (params @ params', Cvalue.Model.merge context context')
    ) ([], Cvalue.Model.empty_map) params

let refine_entry_state callstack state =
  let fn, callsite = Callstack.top_call callstack in
  let lock_params = Concurrency_model.fn_lock_params fn in
  let lock_params, lock_state = refine_lock_params callstack lock_params in
  let path_params, path_state = extract_pure_inputs callstack in
  let state = update_function_status state lock_params path_params in
  {state with context = 
                Cvalue.Model.merge lock_state path_state
                |> Cvalue.Model.merge ~into:state.context
  }

let refine_state_fn_entry callstack (state : State.t) = 
  if Callstack.depth callstack > 1 then
    let fn, callsite = Callstack.top_call callstack in
    if not @@ Function_status.is_normal state.function_status fn
    then refine_entry_state callstack state 
    else state
  else state

(* After function is refined, remove from context all bases that correspond to its
   formal parameters *)
let post_refine_universal fn state =
  let context = state.context in
  let kf = Stmts.kernel_fn_from_fundec fn in
  let formals = Kernel_function.get_formals kf
                |> List.map Base.of_varinfo
  in
  let new_context = List.fold_right Cvalue.Model.remove_base formals context in
  let new_context = Cvalue.Model.filter_base (fun b -> Base.is_any_formal_or_local b)
      new_context in
  {state with context = new_context}

let post_refine callstack state =
  let fn = Callstack.top_call_fn callstack in
  post_refine_universal fn state

(* If refiment fail, mark that function is imprecise to avoid repeated refiments *)
let post_failed_refine callstack old_states new_states _ new_results =
  (List.map (fun s -> {s with imprecise = true}) new_states, new_results)

(* ==== Auxiliary function for lockset analysis ==== *)

let check_guard stmt exp state =
  let value = !Db.Value.eval_expr state.context exp in

  (* Values of expression are not bind to any base *)
  let ival = Cvalue.V.find Base.null value in
  if Ival.is_zero ival then `False
  else if Ival.is_one ival then `True
  else `Unknown

(** Trace of lock is mutex_lock():: ... :: fn :: ... thread
 *                   ^----------------------^
 *  prefix to fn (including -- different callsite) is replaced by current
 *  callstack
 *  note : due to our threating of recursive fns, fn is present at most once
*)
let update_trace cached_cs callstack =
  let fn = Callstack.top_call_fn callstack in
  let suffix = Callstack.cut_prefix fn cached_cs in
  Callstack.concat suffix callstack

(** When we use data from cache we need to update traces of locks in
 *  a) locksets
 *  b) lockgraph edges
 *     - fst lock is in current lockset
 *     - no lock is in current lockset
 **)
let update_on_fn_cache_load cached_lss current_ls cached_g callstack =
  let locksets = LocksetSet.map_locks
    (fun lock ->
       (* If lock is present, do not over-write it *)
       if Lockset.mem lock current_ls then Lockset.find lock current_ls
       else
         let cached_cs = Lock.get_trace lock in
         let trace = update_trace cached_cs callstack in
         Lock.update_trace lock trace
    ) cached_lss
  in
  let g = Lockgraph.fold_edges_e
    (fun (lock, traces, lock2) g ->
      let new_traces = List.map
        (fun trace ->
          let cs1, cs2 = Edge_trace.get_callstacks trace in
          (*let cs1' = if Lockset.mem lock current_ls
            then update_trace cs1 callstack fn
            else update_trace cs1 callstack fn
          in
          let cs2' = if Lockset.mem lock2 current_ls
            then update_trace cs2 callstack fn
            else update_trace cs2 callstack fn 
          in*)
          Edge_trace.create cs1 cs2
        ) traces
      in
      Lockgraph.add_edge g (lock, new_traces, lock2)
    ) cached_g Lockgraph.empty
  in
  (locksets, g)

let is_var_included context var =
  let base = Base.of_varinfo var in
  try 
    let _ = Cvalue.Model.find_base base context in
    true
  with Not_found -> false

(* TODO: add checks *)
let possible_locks_from_expr stmt expr state callstack results =
  let context = state.context in
  let vars = Cil.extract_varinfos_from_exp expr |> Varinfo.Set.elements in
  let values =
    if List.exists (is_var_included context) vars 
    then Eva_wrapper.eval_expr_in_context context expr
    else Eva_wrapper.eval_expr stmt expr
  in
  List.map
    (fun (varinfo, offset) ->
       let name = match offset with
         | 0 -> Format.asprintf "Lock of %a" Printer.pp_varinfo varinfo 
         | offset -> Format.asprintf "Lock of %a[%d]" Printer.pp_varinfo varinfo offset in

       let trace = Callstack.push_action stmt name callstack in
       Lock.create varinfo offset trace
    ) values
  |> Lockset.of_list

(* Simplified version for API -- TODO*)
let possible_locks stmt expr =
  let state = State.empty Thread.dummy in
  let results = Results.empty in
  let callstack = Callstack.push_thread_entry Thread.dummy in
  possible_locks_from_expr stmt expr state callstack results
  
(** Update state on lock *)
let update_on_lock stmt expr (state : State.t) callstack (results : Results.t) =
  let possible_locks = possible_locks_from_expr stmt expr state callstack results in
  let current_ls = state.lockset in
  let edges = Lockset.cartesian_product current_ls possible_locks in
  let results = List.fold_right
    (fun (l1, l2) (results : Results.t) ->
       let trace1 = Lock.get_trace l1 in
       let trace2 = Lock.get_trace l2 in
       let trace = Edge_trace.create trace1 trace2 in
       if (not (Lock.equal l1 l2) || not (Ignore_self_deadlocks.get ()))
       then begin
         Self.debug ~level:3 ~dkey:Deadlock_options.dkey_la
           "Adding dependency %a -> %a" Lock.pp l1 Lock.pp l2;
         let g = Lockgraph.add_edge results.lockgraph (l1, [trace], l2)
         in
         {results with lockgraph = g}
       end
       else results
    ) edges results
  in

  (* Add imprecision if no locks were identified *)
  if Lockset.cardinal possible_locks == 0 then
    Results.add_imprecise_stmt stmt results;

  (* Return updated results *)
  let lock_stmts = Stmt.Set.add stmt results.lock_stmts in
  let results = {results with lock_stmts = lock_stmts} in
  let exit_lss = LocksetSet.add_each current_ls possible_locks in
  exit_lss, results

(** Update state on unlock **)
let update_on_unlock stmt exp state callstack results =
  let current_ls = state.lockset in
  let possible_locks = possible_locks_from_expr stmt exp state callstack results in
  if Lockset.are_disjoint current_ls possible_locks 
  then LocksetSet.remove_each current_ls current_ls
       |> LocksetSet.add current_ls
  else LocksetSet.remove_each current_ls possible_locks

(** The analysis itself **)
(** TODO: handle results **)
let analyse_stmt callstack stmt state =
  let results = Results.empty in
  let entry_ls = state.lockset in
  let exit_lss, results = match Conc_model.classify_stmt stmt with
    | Lock exp -> update_on_lock stmt exp state callstack results
    | Unlock exp -> update_on_unlock stmt exp state callstack results, results
    (** Jump to return is considered as end of path in order to apply retval heuristic *)
    | End_of_path -> LocksetSet.singleton (check_return_code stmt state.lockset), results
    | _ -> LocksetSet.singleton entry_ls, results
  in
  let precondition = State.to_precondition state in
  let stmt_summaries = Stmt_summaries.add (stmt, precondition) exit_lss Stmt_summaries.empty in
  let locksets = LocksetSet.to_list exit_lss in
  
  let states = List.map (fun ls -> {state with lockset = ls}) locksets in
  (states, {results with stmt_summaries = stmt_summaries})

let analyse_call callstack stmt state =
  match Conc_model.classify_stmt stmt with
  | Lock _ | Unlock _ -> `Analyse_atomically
  | _ -> `Continue

(* ==== Lockset analysis as instance of CFA analysis ==== *)

module Analysis = CFA_analysis.Make
    (struct

      module Debug = Self

      open State
      open Results

      let name = "Lockset analysis"

      module Function_cache = struct
        
        include Function_summaries

        type state = State.t
        type results = Results.t

        type t = Function_summaries.t

        let add fn state callstack (states, results) (cache : t) =
          let thread = Callstack.get_thread callstack in
          let lss = locksets states in
          let post = (lss, results.lockgraph) in
          
          (* TODO -- hotfix *)
          let state =
            try
              let context = (List.hd states).context in
              if Cvalue.Model.is_included context state.context then
                state
              else {state with context = context}
            with _ -> state
          in

          let pre = State.to_precondition state in
          add (fn, pre) post cache
        
        let find fn state callstack (cache : t) =
          let thread = Callstack.get_thread callstack in
          if not @@ Do_caching.get () then raise Not_found
          else
            let pre = State.to_precondition state in
            Function_summaries.find (fn, pre) cache

        let find_and_update fn (state : State.t) callstack (cache : t) =
          let current_ls = state.lockset in
          let lss_cached, g_cached = find fn state callstack cache in
          let lss, g = update_on_fn_cache_load lss_cached current_ls g_cached callstack in
          let states = LocksetSet.fold (fun ls acc -> {state with lockset = ls} :: acc) lss []
          in
          let res = {Results.empty with lockgraph = g} in
          (states, res)

      end
      
      module Strategy = struct
        let only_forward_edges = false
      end

      module State = struct
        include State
        let empty thread = empty thread
      end

      module Results = Results

      let analyse_stmt = analyse_stmt
      let analyse_call = analyse_call
      let update_return = update_return
      let check_guard = check_guard

      module Refinement = struct
        type state = State.t
        type results = Results.t
        
        let condition callstack fn states res =
          Do_refinement.get ()
          && refine_condition callstack fn states res
        
        let refine_entry_state = refine_entry_state
        let post_refine = post_refine
        let post_failed_refine = post_failed_refine
      end

      let function_entry callstack state = refine_state_fn_entry callstack state 

      (** After analysis of function is finished, copy its function summary
          to summary of its callsite *)
      let function_exit fn callsite state states results =
        let pre = State.to_precondition state in
        let lss = locksets states in
        let summary = Stmt_summaries.add (callsite, pre) lss results.stmt_summaries in
        let states = List.map (post_refine_universal fn) states in
        (states, {results with stmt_summaries = summary})

      (** After analysis is finished, add computed function summaries to results. *)
      let post_process states results _ function_summaries = 
        {results with function_summaries = function_summaries;
                      function_status = function_status states}

    end)

let compute = Analysis.compute
