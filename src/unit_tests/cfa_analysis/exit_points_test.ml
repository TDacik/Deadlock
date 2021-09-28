open Unit_tests_top

open Exit_points

let stmt1 _ = find_stmt_by_label "f" "stmt1"
let stmt2 _ = find_stmt_by_label "f" "stmt2"
let stmt3 _ = find_stmt_by_label "f" "stmt3"
let stmt4 _ = find_stmt_by_label "f" "stmt4"
let stmt5 _ = find_stmt_by_label "f" "stmt5"
let stmt6 _ = find_stmt_by_label "f" "stmt6"
let stmt7 _ = find_stmt_by_label "f" "stmt7"

let exit_points_test _ =
  assert_bool "stmt1 is not exit point" (not @@ is_exit_point (stmt1 ()));
  assert_bool "stmt2 is not exit point" (not @@ is_exit_point (stmt2 ()));
  assert_bool "stmt3 is exit point"     (is_exit_point        (stmt3 ()));
  assert_bool "stmt4 is not exit point" (not @@ is_exit_point (stmt4 ()));
  assert_bool "stmt5 is exit point"     (not @@ is_exit_point (stmt5 ()));
  assert_bool "stmt6 is not exit point" (not @@ is_exit_point (stmt6 ()));
  assert_bool "stmt7 is exit point"     (is_exit_point        (stmt7 ()))

let suite = "CFA exit points tests" >:::
            [
              "exit_points" >:: exit_points_test;
            ]

let run () = run_test_tt_main suite
