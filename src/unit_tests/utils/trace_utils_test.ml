open Unit_tests_top
open Trace_utils
open Callstack

let cs1 =
  Callstack.push_thread_entry thread1
  |> Callstack.push_action stmt1 "a1"

let cs2 = 
  Callstack.push_thread_entry thread2
  |> Callstack.push_call stmt2 fn1
  |> Callstack.push_action stmt1 "a1"

let cs2' = [Action (stmt1, "a1")]

let cs3 = 
  Callstack.push_thread_entry thread3
  |> Callstack.push_call stmt2 fn1
  |> Callstack.push_call stmt3 fn2
  |> Callstack.push_call stmt4 fn3
  |> Callstack.push_action stmt1 "a1"

let cs3' = [Action (stmt1, "a1"); Call (stmt4, fn3)]
  
let cs4 =
  Callstack.push_thread_entry thread1
  |> Callstack.push_call stmt2 fn1
  |> Callstack.push_call stmt3 fn2
  |> Callstack.push_call stmt4 fn3
  |> Callstack.push_action stmt1 "a1"

let cs4b =
  Callstack.push_thread_entry thread1
  |> Callstack.push_call stmt2 fn1
  |> Callstack.push_call stmt3 fn2
  |> Callstack.push_call stmt5 fn3
  |> Callstack.push_action stmt1 "a1"

let cs5 =
  Callstack.push_thread_entry thread1
  |> Callstack.push_call stmt2 fn1
  |> Callstack.push_call stmt3 fn2
  |> Callstack.push_call stmt5 fn3
  |> Callstack.push_action stmt1 "a2"

let cs5_prefix = [Action (stmt1, "a2"); Call (stmt5, fn3); Call (stmt3, fn2); Call (stmt2, fn1)]
let cs5_suffix = [Thread_entry thread1]

let bottom_test _ =
  assert_equal_events (Callstack.bottom cs1) (Thread_entry thread1);
  assert_equal_events (Callstack.bottom cs2) (Thread_entry thread2);
  assert_equal_events (Callstack.bottom cs3) (Thread_entry thread3)

let get_thread_test _ =
  assert_equal_threads (Callstack.get_thread cs1) thread1;
  assert_equal_threads (Callstack.get_thread cs2) thread2;
  assert_equal_threads (Callstack.get_thread cs3) thread3

let mem_call_test _ =
  assert_bool "" (not @@ Callstack.mem_call cs1 fn1);
  assert_bool "" (Callstack.mem_call cs2 fn1);
  assert_bool "" (Callstack.mem_call cs3 fn2);
  assert_bool "" (not @@ Callstack.mem_call cs3 fn4)

let remove_guards_test _ = () 

let cut_prefix_test _ =
  assert_raises Not_found (fun _ -> Callstack.cut_prefix fn1 cs1);
  assert_equal_callstacks cs2' (Callstack.cut_prefix fn1 cs2);
  assert_equal_callstacks cs3' (Callstack.cut_prefix fn2 cs3)

let conc_check_abstr_test _ =
  let with_action_stmt = false in
  assert_bool "" (Callstack.equal_abstr ~with_action_stmt 0 cs1 cs2);
  assert_bool "" (Callstack.equal_abstr ~with_action_stmt 0 cs2 cs3);
  assert_bool "" (Callstack.equal_abstr ~with_action_stmt 1 cs4 cs5);
  assert_bool "" (Callstack.equal_abstr ~with_action_stmt 2 cs4 cs5);
  assert_bool "" (Callstack.equal_abstr ~with_action_stmt 3 cs4 cs5);
  assert_bool "" (not @@ Callstack.equal_abstr ~with_action_stmt 4 cs4 cs5);
  assert_bool "" (not @@ Callstack.equal_abstr ~with_action_stmt 100 cs4 cs5);
  
  let with_action_stmt = true in
  assert_bool "" (Callstack.equal_abstr ~with_action_stmt 0 cs1 cs2);
  assert_bool "" (Callstack.equal_abstr ~with_action_stmt 0 cs2 cs3);
  assert_bool "" (Callstack.equal_abstr ~with_action_stmt 1 cs4 cs4b);
  assert_bool "" (Callstack.equal_abstr ~with_action_stmt 2 cs4 cs4b);
  assert_bool "" (Callstack.equal_abstr ~with_action_stmt 3 cs4 cs4b);
  assert_bool "" (not @@ Callstack.equal_abstr ~with_action_stmt 4 cs4b cs5);
  assert_bool "" (not @@ Callstack.equal_abstr ~with_action_stmt 100 cs4b cs5)

let remove_prefix_test _ =
  assert_equal_callstacks cs5 (Callstack.remove_prefix [] cs5);
  assert_equal_callstacks cs5_suffix (Callstack.remove_prefix cs5_prefix cs5)

let suite = "Callstack tests" >:::
            ["bottom" >:: bottom_test;
             "get_thread" >:: get_thread_test;
             "mem_call" >:: mem_call_test;
             "remove_guards" >:: remove_guards_test;
             "cut_prefix" >:: cut_prefix_test;
             "remove_prefix" >:: remove_prefix_test;
             "abstr_compare" >:: conc_check_abstr_test;
            ]

let run () = run_test_tt_main suite
