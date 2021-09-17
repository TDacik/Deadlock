open Unit_tests_top

open Lockset_analysis
open Trace_utils

open Cil_types
open Cil_datatype

(** 
 * Analysis with *current CS* is going to use cached summary of function
 * *fn2*. This summary requires lock *l* with trace *trace*. The new
 * trace of *l* should be *updated trace*.
 *
 * Trace:                  Current CS:          Updated trace:
 * 
 * Thread thread 1         Thread thread2         Thread thread2
 *   Call fn1 at stmt1       Call fn4 at stmt4      Call fn4 at stmt4
 *   Call fn2 at stmt2       Call fn2 at stmt5      Call fn2 at stmt5
 *   Call fn3 at stmt3                              Call fn3 at stmt3
 *   Lock l   at stmt6                              Lock l   at stmt6
 *)

let cached_trace = 
  Callstack.push_thread_entry thread1
  |> Callstack.push_call stmt1 fn1
  |> Callstack.push_call stmt2 fn2
  |> Callstack.push_call stmt3 fn3
  |> Callstack.push_action stmt6 "lock"

let current_cs =
  Callstack.push_thread_entry thread2
  |> Callstack.push_call stmt4 fn4
  |> Callstack.push_call stmt5 fn2

let expected : Callstack.t =
  Callstack.push_thread_entry thread2
  |> Callstack.push_call stmt4 fn4
  |> Callstack.push_call stmt5 fn2
  |> Callstack.push_call stmt3 fn3
  |> Callstack.push_action stmt6 "lock"
  
let caching_test _ =
  assert_equal_callstacks expected (update_trace cached_trace current_cs)

let suite = "Lockset analysis tests" >:::
            [
              "caching" >:: caching_test
            ]

let run () = run_test_tt_main suite
