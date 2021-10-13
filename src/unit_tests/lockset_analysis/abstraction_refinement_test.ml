open Unit_tests_top

open Cil_types
open Cil_datatype

open Trace_utils

(* ==== Callstack ==== *)

let thread1 () = find_thread_by_name "thread1"
let thread2 () = find_thread_by_name "thread2"

let lock_wrapper () = find_fn_by_name "lock_wrapper"
let pause_fn () = find_fn_by_name "pause_fn"
let no_pure_input () = find_fn_by_name "no_pure_input"

let stmt1 () = find_stmt_by_label "thread1" "stmt1"
let stmt2 () = find_stmt_by_label "thread1" "stmt2"

let callstack1 () =
  Callstack.push_thread_entry (thread1 ())
  |> Callstack.push_call (stmt1 ()) (pause_fn ())

let callstack2 () =
  Callstack.push_thread_entry (thread1 ())
  |> Callstack.push_call (stmt2 ()) (no_pure_input ())



(* ==== Variables and bases ==== *)
let var_action () = find_formal_var_by_name "pause_fn" "action"


let extract_pure_inputs_test _ =
  (* Extract single input *)
  let _, pure_inputs = Abstraction_refinement.extract_pure_inputs (callstack1 ()) in
  let expected = make_state [(var_action (), Cvalue.V.of_int64 0L)] in
  assert_equal_states expected pure_inputs;

  (* Input is not pure *)
  let _, pure_inputs2 = Abstraction_refinement.extract_pure_inputs (callstack2 ()) in
  let expected2 = make_state [] in
  assert_equal_states expected2 pure_inputs2

let suite = "Lockset analysis tests" >:::
            [
              "pure input extraction" >:: extract_pure_inputs_test
            ]

let run () = run_test_tt_main suite
