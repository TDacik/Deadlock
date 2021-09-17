(* Implementation of loop for filtering traces of deadlocks based on
 * concurrency checking and simple ranking mechanism.
 *
 * Author: Tomas Dacik *)

open! Deadlock_top

open Deadlock_types
open Lock_types
open Trace_utils

(* ==== Trace ranking ==== *)

(* Ranking of a single edge (lock1, [..., stmt], lock2) based on must-lockset information:
  
   + 1 ... lock1 is in must-lockset of stmt
   + 1 ... lock2 must be acquired after executing stmt

  *)
let trace_must_lockset_rank locksets lock1 lock2 trace =
  let _, stmt = Edge_trace.get_action_stmts trace in
  let must_in = Lockset_analysis.Results.stmt_must_lockset stmt locksets in
  let must_acquire = Lockset_analysis.Results.stmt_must_acquire stmt locksets in
  let res1 = Lockset.mem lock1 must_in in
  let res2 = Lockset.mem lock2 must_acquire in
  if res1 && res2 then 2
  else if res1 || res2 then 1
  else 0

(* Length of trace, TODO: consider branching *)
let trace_length_rank trace = Edge_trace.length trace

let trace_rank locksets lock1 lock2 trace =
  100 * (trace_must_lockset_rank locksets lock1 lock2 trace) - trace_length_rank trace

(* Find trace with highest rank *)
let find_best_trace locksets (lock1, traces, lock2) =
  let best_rank = List.fold_right
    (fun trace max ->
      let rank = trace_rank locksets lock1 lock2 trace in
      if rank > max then rank else max
      ) traces (-99999) 
  in
  let best_trace = List.find (fun trace -> trace_rank locksets lock1 lock2 trace = best_rank) traces in
  (lock1, best_trace, lock2)

(* For each abstract edge find best concrete edge using edge ranking *)
let find_best_instance locksets abstract_dl : concrete_deadlock =
  List.map (fun (lock1, traces, lock2) -> find_best_trace locksets (lock1, traces, lock2)) abstract_dl

(* ==== Deadlock ranking and filtering ==== *)

(* Concrete deadlock is concurrent if all its edges are pair-wise concurrent. *)
let is_concurrent_instance locksets thread_graph concrete_dl =
  get_trace concrete_dl 
  |> List.diagonal
  |> List.for_all (fun (t1, t2) -> (Concurrency_check.are_concurrent_traces thread_graph locksets t1 t2))

(* Abstract deadlock is concurrent if at least one of its instances is concurrent. *)
let is_concurrent locksets thread_graph dl =
  concrete_instances dl
  |> List.exists (is_concurrent_instance locksets thread_graph)
  
(* Concurrency check + ranking *)
let filter thread_graph locksets deadlocks = 
  deadlocks
  |> List.find_all (is_concurrent locksets thread_graph)
  |> List.map (find_best_instance locksets)

(* Ranking only *)
let no_conc locksets deadlocks = 
  List.map (find_best_instance locksets) deadlocks
