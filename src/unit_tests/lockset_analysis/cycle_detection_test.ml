open Unit_tests_top

open Cil_datatype
open Lock_types

let add_edge l1 l2 g = Lockgraph.add_edge g (Lockgraph.E.create l1 [] l2)

(* Graphs *)

let empty = Lockgraph.empty

let single = Lockgraph.empty 
             |> add_edge lock1 lock2

let cycle2 = Lockgraph.empty
             |> add_edge lock1 lock2
             |> add_edge lock2 lock1

let cycle3 = Lockgraph.empty
             |> add_edge lock1 lock2
             |> add_edge lock2 lock3
             |> add_edge lock3 lock1

let cycle2x2 = Lockgraph.empty
               |> add_edge lock1 lock2
               |> add_edge lock2 lock1
               |> add_edge lock1 lock3 
               |> add_edge lock3 lock1

let cycle2_3 = Lockgraph.empty
               |> add_edge lock1 lock2
               |> add_edge lock2 lock1 (* 2-cycle *)
               |> add_edge lock1 lock3 
               |> add_edge lock3 lock2 (* 3-cycle *)

(* Complete graph on 3 vertices *)
let complete3 = Lockgraph.empty
                |> add_edge lock1 lock1
                |> add_edge lock1 lock2
                |> add_edge lock1 lock3
                |> add_edge lock2 lock1
                |> add_edge lock2 lock2
                |> add_edge lock2 lock3
                |> add_edge lock3 lock1
                |> add_edge lock3 lock2
                |> add_edge lock3 lock3

let complete4 = complete3
                |> add_edge lock1 lock4
                |> add_edge lock2 lock4
                |> add_edge lock3 lock4
                |> add_edge lock4 lock4
                |> add_edge lock4 lock1
                |> add_edge lock4 lock2
                |> add_edge lock4 lock3
                |> add_edge lock4 lock4

let cycle_detection_test _ =
  assert_bool "Empty" (Lockgraph.find_deadlocks empty = []);
  assert_bool "Singleton" (Lockgraph.find_deadlocks single = []);
  assert_bool "2-cycle" (Lockgraph.find_deadlocks cycle2 |> List.length = 1);
  assert_bool "3-cycle" (Lockgraph.find_deadlocks cycle3 |> List.length = 1);
  assert_bool "2 x 2-cycle" (Lockgraph.find_deadlocks cycle2x2 |> List.length = 2);
  assert_bool "2-cycle & 3-cycle" (Lockgraph.find_deadlocks cycle2_3 |> List.length = 2)
  (*
  assert_bool "complete 3" (Lockgraph.find_deadlocks complete3 |> List.length = 7);
  assert_bool "complete 4" (Lockgraph.find_deadlocks complete4 |> List.length = 16)
  *)

  let suite = "Lockgraph" >:::
            [
              "cycle_detection" >:: cycle_detection_test;
            ]

let run () = run_test_tt_main suite

