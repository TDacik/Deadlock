open Deadlock_options

let main () = 
  Self.feedback "Running %s unit tests" (Unit_tests.get ());
  match Unit_tests.get () with
  | "cycle_detection"        -> Cycle_detection_test.run ()
  | "lockset_analysis"       -> Lockset_analysis_test.run ()
  | "abstraction_refinement" -> Abstraction_refinement_test.run ()
  | "lock_types"             -> Lock_types_test.run ()
  | "trace_utils"            -> Trace_utils_test.run ()
  | "cfg_utils"              -> CFG_utils_test.run ()
  | "cil_wrapper"            -> Cil_wrapper_test.run ()
  | "exit_points"            -> Exit_points_test.run ()
  | ""  -> failwith "Deadlock is compiled in test-mode"
  | str -> failwith ("Unknown unit test setup: " ^ str);

  exit 0

let () = Db.Main.extend main
