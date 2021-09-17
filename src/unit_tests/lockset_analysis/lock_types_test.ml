open Unit_tests_top
open Lock_types

(* ==== Locksets ==== *)

let ls_emp = Lockset.empty

let ls_1 = Lockset.singleton lock1

let ls_2 = Lockset.singleton lock2

let ls_3 = Lockset.singleton lock3

let ls_4 = Lockset.singleton lock4

let ls_12 = Lockset.of_list [lock1; lock2]

let ls_34 = Lockset.of_list [lock3; lock4]

let ls_123 = Lockset.of_list [lock1; lock2; lock3]

let ls_124 = Lockset.of_list [lock1; lock2; lock4]

let ls_134 = Lockset.of_list [lock1; lock3; lock4]

let ls_1234 = Lockset.of_list [lock1; lock2; lock3; lock4]

(* ==== Sets of locksets ===== *)

let lss_emp = LocksetSet.empty

let lss_ls_emp = LocksetSet.of_list [Lockset.empty]

let lss_1 = LocksetSet.of_list [ls_1]

let lss_2 = LocksetSet.of_list [ls_2]

let lss_1_2 = LocksetSet.of_list [ls_1; ls_2]

let lss_1234 = LocksetSet.of_list [ls_1234]

let lss_1_2_3_4 = LocksetSet.of_list [ls_1; ls_2; ls_3; ls_4]

let lss_12_34 = LocksetSet.of_list [ls_12; ls_34]

let lss_123_124 = LocksetSet.of_list [ls_123; ls_124]

let lss_12_1_134 = LocksetSet.of_list [ls_12; ls_1; ls_134]

(* ==== Tests ==== *)

let basic_test _ =
  assert_bool "Lockset equality 1" (Lockset.equal ls_1234 ls_1234);
  assert_bool "Lockset equality 2" (LocksetSet.equal lss_12_1_134 lss_12_1_134);
  
  assert_bool "Lockset comparison 1" (not @@ Lockset.equal ls_1 ls_2);
  assert_bool "Lockset comparison 2" (not @@ LocksetSet.equal lss_1 lss_2)

let elems_union_test _ =
  assert_equal_locksets ls_emp  (LocksetSet.elems_union lss_emp);     (* identity *)
  assert_equal_locksets ls_emp  (LocksetSet.elems_union lss_ls_emp);  (* identity *)
  assert_equal_locksets ls_1    (LocksetSet.elems_union lss_1);       (* identity *)
  assert_equal_locksets ls_12   (LocksetSet.elems_union lss_1_2);     (* identity *)
  assert_equal_locksets ls_1234 (LocksetSet.elems_union lss_12_1_134)

let elems_inter_test _ =
  assert_raises LocksetSet.Empty_intersection (fun _ -> LocksetSet.elems_inter lss_emp);
  
  assert_equal_locksets ls_emp (LocksetSet.elems_inter lss_ls_emp);   (* empty *)
  assert_equal_locksets ls_emp (LocksetSet.elems_inter lss_12_34);    (* empty *)
  assert_equal_locksets ls_1   (LocksetSet.elems_inter lss_1);        (* singleton *)
  assert_equal_locksets ls_1   (LocksetSet.elems_inter lss_12_1_134)

let add_each_test _ =
  assert_equal_lockset_sets lss_ls_emp  (LocksetSet.add_each ls_emp ls_emp);
  assert_equal_lockset_sets lss_1_2     (LocksetSet.add_each ls_emp ls_12);
  assert_equal_lockset_sets lss_1234    (LocksetSet.add_each ls_1234 ls_emp);
  assert_equal_lockset_sets lss_1_2_3_4 (LocksetSet.add_each ls_emp ls_1234)

let remove_each_test _ = 
  assert_equal_lockset_sets lss_ls_emp  (LocksetSet.remove_each ls_emp ls_emp);
  assert_equal_lockset_sets lss_ls_emp  (LocksetSet.remove_each ls_emp ls_12);
  assert_equal_lockset_sets lss_1234    (LocksetSet.remove_each ls_1234 ls_emp);
  assert_equal_lockset_sets lss_123_124 (LocksetSet.remove_each ls_1234 ls_34)

let suite = "Lockset analysis tests" >:::
            [
              "basic" >:: basic_test;
              "add_each" >:: add_each_test;
              "remove_each" >:: remove_each_test;
              "elems_union" >:: elems_union_test;
              "elems_inter" >:: elems_inter_test;
            ]

let run () = run_test_tt_main suite
