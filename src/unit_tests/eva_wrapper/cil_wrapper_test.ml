open Unit_tests_top

open Locations
open Cil_types

open Eva_wrapper

let stmt1 () = find_stmt_by_label "main" "stmt1" (* a = 0 *)
let stmt2 () = find_stmt_by_label "main" "stmt2" (* b = a *)
let stmt3 () = find_stmt_by_label "main" "stmt3" (* a++   *)

let a () = find_local_var_by_name "main" "a"
let b () = find_local_var_by_name "main" "b"

let stmt_reads_test _ =
  let reads1 = stmt_reads (stmt1 ()) in
  let reads2 = stmt_reads (stmt2 ()) in
  let reads3 = stmt_reads (stmt3 ()) in
  let a = a () in
  let b = b () in

  assert_bool "stmt1 reads nothing" (Zone.is_bottom reads1);
  assert_bool "stmt2 reads a"       (Zone.mem_base a reads2);
  assert_bool "stmt3 reads a"       (Zone.mem_base a reads3)

let stmt_writes_test _ = 
  let writes1 = stmt_writes (stmt1 ()) in
  let writes2 = stmt_writes (stmt2 ()) in
  let writes3 = stmt_writes (stmt3 ()) in
  let a = a () in
  let b = b () in

  assert_bool "stmt1 writes to a"   (Zone.mem_base a writes1);
  assert_bool "stmt2 writes to b"   (Zone.mem_base b writes2);
  assert_bool "stmt3 writes to a"   (Zone.mem_base a writes3)

let suite = "CIL instance of EVA wrapper" >:::
            [
              "stmt_reads test" >:: stmt_reads_test;
              "stmt_writes test" >:: stmt_writes_test;
            ]

let run () = run_test_tt_main suite
