open Unit_tests_top
open Trace_utils
open CFG_utils
open Cil_types
open Concurrency_model

(* Ignore "atomic" calls, e.g, lock() *)
let stmt_is_call stmt = match classify_stmt stmt with
  | Call _ -> true
  | _ -> false

let fn_has_params fn =
  let formals = Kernel_function.get_formals fn in
  (List.length formals) > 0

let stmt1 _ = find_stmt_by_label "thread1" "stmt1"
let stmt2 _ = find_stmt_by_label "main" "stmt2"
let stmt3 _ = find_stmt_by_label "f" "stmt3"
let create1 _ = find_stmt_by_label "g" "create1"
let create2 _ = find_stmt_by_label "g" "create2"
let join1 _ = find_stmt_by_label "g" "join1"
let join2 _ = find_stmt_by_label "g" "join2"

let entry_points _ = List.map find_fn_by_name ["thread1"; "thread2"; "main"]

let all_stmts_predicate_test _ =
  assert_stmt_list_length 0  (all_stmts_predicate (fun _ -> false));
  assert_stmt_list_length 1  (all_stmts_predicate (Stmt.equal (stmt1 ())));
  assert_stmt_list_length 2  (all_stmts_predicate is_thread_create);
  assert_stmt_list_length 8 (all_stmts_predicate stmt_is_call)

let all_fundecs_predicate_test _ = 
  assert_fn_list_length 0 (all_fundecs_predicate (fun _ -> false));
  assert_fn_list_length 5 (all_fundecs_predicate (fun _ -> true));
  assert_fn_list_length 2 (all_fundecs_predicate fn_has_params)

let transitive_callsites_test _ =
  assert_stmt_list_length 0 (transitive_callsites (stmt2 ()));
  assert_stmt_list_length 8 (transitive_callsites (stmt1 ()));
  assert_stmt_list_length 5 (transitive_callsites (create1 ()))

let toplevel_callsites_test _ =
  assert_stmt_list_length 0 (toplevel_callsites (entry_points ()) (stmt2 ())); (* Check *)
  assert_stmt_list_length 3 (toplevel_callsites (entry_points ()) (stmt1 ()));
  assert_stmt_list_length 1 (toplevel_callsites (entry_points ()) (stmt3 ()))

let all_callstacks_test _ = ()

let max_depth_test _ =
  assert_equal_int 1 (max_depth (stmt2 ()));
  assert_equal_int 5 (max_depth (stmt1 ()))


let suite = "CFG utils tests" >:::
            [
              "all_stmts_predicate" >:: all_stmts_predicate_test;
              "all_fundecs_predicate" >:: all_fundecs_predicate_test;
              "transitive_callsites" >:: transitive_callsites_test;
              "toplevel_callsites" >:: toplevel_callsites_test;
              "all_callstacks" >:: all_callstacks_test;
              "max_depth" >:: max_depth_test;
            ]

let run () = run_test_tt_main suite
