(* Computation of may-happen-in-parallel relation
 *
 * Author: Tomas Dacik (xdacik00@fit.vutbr.cz), 2021
 *)

open! Deadlock_top

open Lock_types
open Trace_utils
open Happend_before
open Thread_analysis
open Imperative_counter

module Results = Lockset_analysis.Results
module KF = Kernel_function
module CFG = CFG_utils
module Conc_model = Concurrency_model

(* Counters for statistics of performed concurrency checks *)
module Nb_deadlocks = Counter(struct end)
module Nb_nonc = Counter(struct end)
module Nb_before_create = Counter(struct end) 
module Nb_after_join = Counter(struct end)
module Nb_same_thread = Counter(struct end)
module Nb_nonc_threads = Counter(struct end)
module Nb_gatelock = Counter(struct end)

let update_statistics before_create after_join same_thread gatelock nonc_threads =
  let res = before_create || after_join || same_thread || gatelock || nonc_threads in
  Nb_nonc.inc_cond res;
  Nb_before_create.inc_cond before_create;
  Nb_after_join.inc_cond after_join;
  Nb_same_thread.inc_cond same_thread;
  Nb_nonc_threads.inc_cond nonc_threads;
  Nb_gatelock.inc_cond gatelock

let reset_statistics () =
  Nb_deadlocks.reset ();
  Nb_nonc.reset ();
  Nb_before_create.reset ();
  Nb_after_join.reset ();
  Nb_same_thread.reset ();
  Nb_nonc_threads.reset ();
  Nb_gatelock.reset ()

let is_before_create thread_graph thread callstack =
  if Thread.is_main thread then false
  else
    let create_stmts = Thread_graph.create_stmts_of_thread thread_graph thread in
    let entry_points = Thread_graph.get_entry_points thread_graph in
    
    (* Forall create statement of thread T *)
    let res = List.for_all
      (fun create_stmt ->
         let name = Format.asprintf "Create of %a" Thread.pp thread in
         let create_callstacks = CFG_utils.all_callstacks ~name entry_points create_stmt in
         List.for_all (fun c_cs -> happend_before callstack c_cs) create_callstacks
      ) create_stmts
    in
    res

let check_before_create g cs1 cs2 =
  let thread1 = Callstack.get_thread cs1 in
  let thread2 = Callstack.get_thread cs2 in
  is_before_create g thread1 cs2 || is_before_create g thread2 cs1

(** Is thread always joined before the statement? *)
let is_after_join g thread callstack =
  if Thread.is_main thread then false
  else
    let ids = Thread_graph.get_thread_ids g thread in
    let joins = CFG.all_stmts_predicate Conc_model.is_thread_join in
    let entry_points = Thread_graph.get_entry_points g in

    (* Inner function *)
    let is_id_joined g callstack id =
      let stmts_join_the_id = 
        List.find_all (fun s -> LvalStructEq.equal id (Conc_model.thread_join_id s)) joins in
      
      if Int.equal (List.length stmts_join_the_id) 0 then false
      else 
        List.for_all
          (fun join_stmt ->
             let name = Format.asprintf "Join of %a" Thread.pp thread in
             let join_callstacks = CFG_utils.all_callstacks ~name entry_points join_stmt in
             List.for_all (fun j_cs -> happend_before j_cs callstack) join_callstacks
          ) stmts_join_the_id

    in
    List.for_all (is_id_joined g callstack) ids

let check_after_join g cs1 cs2 =
  let thread1 = Callstack.get_thread cs1 in
  let thread2 = Callstack.get_thread cs2 in
  is_after_join g thread1 cs2 || is_after_join g thread2 cs1

(** Does two abstract threads refers to the same instance? *)
let check_same_instances g locksets thread1 thread2 =
  if (Thread.is_main thread1) && (Thread.is_main thread2) then true
  else if Thread.equal thread1 thread2 then
    not (Thread_graph.is_created_multiple_times g thread1)
  else false

(** Gatelock = intersection of stmts must-locksets is non empty *)
let check_gatelock locksets stmt1 stmt2 =
  let ls1 = Results.stmt_must_lockset stmt1 locksets in
  let ls2 = Results.stmt_must_lockset stmt2 locksets in
  let acquired1 = Results.stmt_may_acquire stmt1 locksets in
  let acquired2 = Results.stmt_may_acquire stmt2 locksets in
  let acquired = Lockset.union acquired1 acquired2 in
  let ls1 = Lockset.diff ls1 acquired in
  not (Lockset.are_disjoint ls1 ls2)

(* Is thread1 always joined before thread2 is created *)
let nonc_threads_aux g t1 t2 =
  if Thread.is_main t1 || Thread.is_main t2 then false
  else
    let creates = Thread_graph.create_stmts_of_thread g t2 in
    let joins = CFG.all_stmts_predicate Conc_model.is_thread_join in
    let entry_points = Thread_graph.get_entry_points g in
    if (List.length joins) = 0 then false

    else
    let create_callstacks = List.map (CFG_utils.all_callstacks entry_points) creates |> List.concat in
    let join_callstacks = List.map (CFG_utils.all_callstacks entry_points) joins |> List.concat in
    List.cartesian_product [join_callstacks; create_callstacks]
    |> List.for_all (fun [join; create] -> happend_before join create)

let check_nonc_threads g thread1 thread2 =
  nonc_threads_aux g thread1 thread2 || nonc_threads_aux g thread2 thread1

let are_concurrent_callstacks ?(conservative=true) g locksets cs1 cs2 =
  if conservative 
     && (not @@ Lockset_analysis.Results.is_precise locksets 
         || not @@ Thread_graph.is_precise g)
  then true
  else begin
    let cs1 = Callstack.remove_guards cs1 in
    let cs2 = Callstack.remove_guards cs2 in
    let thread1 = Callstack.get_thread cs1 in
    let thread2 = Callstack.get_thread cs2 in
    let stmt1 = Callstack.get_action_stmt cs1 in
    let stmt2 = Callstack.get_action_stmt cs2 in
    
    let r1 = check_before_create g cs1 cs2 in
    let r2 = check_after_join g cs1 cs2 in
    let r3 = check_nonc_threads g thread1 thread2 in
    let r4 = check_gatelock locksets stmt1 stmt2 in
    let r5 = check_same_instances g locksets thread1 thread2 in

    update_statistics r1 r2 r5 r4 r3;
    not r1 && not r2 && not r3 && not r4 && not r5
  end

(* Are two deadlock traces concurrenct? *)
let are_concurrent_traces g locksets trace1 trace2 =
  let callstack1 = snd trace1 in
  let callstack2 = snd trace2 in
  are_concurrent_callstacks g locksets callstack1 callstack2
