(* Main file of Deadlock analyser.
 *
 * Author: Tomas Dacik (xdacik00@fit.vutbr.cz), 2020
 *)

open! Deadlock_top

open Lock_types
open Print_utils
open Deadlock_options
open Lockset_analysis
open Concurrency_check

module Deadlock = Deadlock_types
module Results = Lockset_analysis.Results
module Thread_graph = Thread_analysis.Thread_graph

let init () =
  (* Set EVA parameters *)
  let eva_verbose = match Self.Verbose.get () with
    | 0 -> 0
    | n -> n - 1
  in
  Dynamic.Parameter.Int.set "-eva-verbose" eva_verbose;

  (* Load concurrency model *)
  let path = match Conc_model_param.get () with
    | "pthread" -> Self.Share.get_dir "pthread.json"
    | "c11_threads" -> Self.Share.get_dir "c11_threads.json"
    | "win32_threads" -> Self.Share.get_dir "win32_threads.json"
    | path -> Filepath.Normalized.of_string ~existence:Filepath.Must_exist path 
  in 
  Format.asprintf "%a" Filepath.Normalized.pp_abs path
  |> Load_model.load_model;

  (* Try to automatically infer lock types *)
  if Auto_find_lock_types.get () then
    try
      let kf = Globals.Functions.find_by_name "pthread_mutex_lock" in
      let lock_type = List.hd (Kernel_function.get_formals kf) in
      let lock_type_str = 
        Format.asprintf "%a" Printer.pp_typ lock_type.vtype 
        |> String.split_on_char ' '
      in let lock_type_str = List.nth lock_type_str 1 in
      Concurrency_model_data.Lock_types.add lock_type_str;
      Self.feedback "Found lock type: %s" lock_type_str
    with Not_found -> 
      Self.feedback "No pthread_mute_lock prototype found."
  else ()

let _results = ref None
let _thread_graph = ref None

let main () =

  Self.feedback "Deadlock analysis started";

  if Use_EVA.get () then Eva_wrapper.init () else ();
  Statistics.timer "Main thread";

  let thread_graph = Thread_analysis.compute () in
  Statistics.timer "Thread analysis";

  let results = Lockset_analysis.compute thread_graph in
  _results := Some results;
  _thread_graph := Some thread_graph;
  Statistics.timer "Lockset analysis";

  Self.result "=== Assumed threads: === \n%a" Thread_graph.pp_threads thread_graph;

  Self.result "=== Lockgraph: ===\n%a" Lockgraph.pp_edges (Results.lockgraph results);
 
  Self.feedback "==== Results: ====";
  let possible_deadlocks = Results.find_deadlocks results in

  (* Concurrency check *)
  let deadlocks =
    if Do_concurrency_check.get () then
      Deadlock_analysis.filter thread_graph results possible_deadlocks
    else Deadlock_analysis.no_conc results possible_deadlocks
  in
  Statistics.timer "Deadlock analysis";

  let _ = match deadlocks with
    | [] -> Self.result "No deadlock found"
    | deadlocks -> 
      List.iter (fun dl -> Self.result "%a" Deadlock.pp dl) deadlocks;
      let imprecise_fns = Results.imprecise_fns results in
      if imprecise_fns <> [] then
        begin
          Self.result "Sources of imprecision of lockset analysis (functions):";
          List.iter (Self.result "- %a" Printer.pp_fundec) imprecise_fns;
          let is = Stmt_summaries.find_imprecise_lock_stmts (Results.stmt_summaries results) in
          Self.result "Sources of imprecision of lockset analysis (stmts):";
          Stmt.Set.iter (Self.result "- %a" Printer.pp_stmt) is;
        end
      else ()
  in

  if List.length possible_deadlocks <> List.length deadlocks then begin
    Concurrency_check.Nb_deadlocks.inc ();
    Self.result "Lock order violation found, rerun with x for mor info"
  end
  else ();
 
  Self.debug ~level:2 ~dkey:dkey_function_summaries "%a" Results.pp_fn_summaries results;
  
  Statistics.timer "Total";
  let stats = Statistics.get results thread_graph in
  Self.result "%a" Statistics.pp_imprecision stats;

  (* Output summary to file *)
  let output_file = Json_summary_filename.get () in
  if output_file <> "" then begin
    Json_output.output results thread_graph deadlocks stats output_file
  end
  else ()

(* Run plugin only if it is enabled *)
let run () = if Enabled.get () then begin init (); main () end else init ()

(* Register plugin *)
let () = Db.Main.extend run
