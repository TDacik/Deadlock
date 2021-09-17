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



let suite = "Lockset analysis tests" >:::
            [
              "stmt_must_lockset" >:: stmt_must_lockset_test;
              "stmt_may_lockset" >:: stmt_must_lockset_test;
              "stmt_exit_must_lockset" >:: stmt_exit_must_lockset; 
              "stmt_exit_may_lockset" >:: stmt_exit_may_lockset; 
              "stmt_must_acquire" >:: stmt_must_acquire_test;
              "stmt_may_acquire" >:: stmt_may_acquire_test;
            ]

let run () = run_test_tt_main suite
