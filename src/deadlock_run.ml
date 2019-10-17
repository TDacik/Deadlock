open Deadlock_options
open Lockset
open Lockset_analysis

module LA_results = Lockset_analysis.Results
module TA_results = Thread_analysis.Results

(** Print summary of deadlock analysis to given file *)
let print_summary filename results =
  let res_string = if LA_results.get_all_deadlocks results == [] then "OK" else "DL" in
  let n_edges = Lockgraph.nb_vertex results.lockgraph in
  let imprecision = LA_results.imprecision_to_string results in 
  let source_files = Kernel.Files.get () in
  let source_name = List.fold_right (fun str acc -> str ^ acc) source_files "" in
  let open_flags = [Open_append; Open_creat] in
  let file = "./" ^ filename ^ ".out" in
  let out_channel = open_out_gen open_flags 0o777 file in

  Printf.fprintf out_channel "%s:%s:%i:%s\n" source_name res_string n_edges imprecision;
  close_out out_channel

let main () =
  Self.feedback "Deadlock analysis started";
  let results = Lockset_analysis.compute () in
  Self.feedback "=== Assumed threads: ===";
  Thread_analysis.Results.print_threads results.threads;
  Self.feedback "=== Lockgraph: ===";
  Lockset_analysis.Results.print_edges results;

  Self.feedback "==== Results: ====";  
  let deadlocks = Results.get_all_deadlocks results in 
  let _ = match deadlocks with
    | [] -> Self.result "No deadlock found"
    | deadlocks -> List.iter 
      (fun dl -> 
        Deadlock.print dl
      ) deadlocks in

  LA_results.print_imprecision results;

  (** Output summary to file *)
  let output_file = OutputSummary.get () in
  if output_file != "" then
    print_summary output_file results    
  else ()

(** Run plugin only on demand *)
let run () = if Enabled.get () then main () else ()

(** Registr plugin *)
let () = Db.Main.extend run
