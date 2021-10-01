(* Human-readable json output.
 *
 * Author: Tomas Dacik (xdacik00@fit.vutbr.cz), 2021
 *)

open! Deadlock_top

open Yojson

open Lock_types
open Thread_analysis
open Deadlock_options

module Results = Lockset_analysis.Results

let format_time (tm : Unix.tm) =
  Printf.sprintf "%02d.%02d.%d %02d:%02d:%02d"
    tm.tm_mday
    (tm.tm_mon + 1)
    (tm.tm_year + 1900)
    tm.tm_hour
    tm.tm_min
    tm.tm_sec

(* Return list of json representations of all source files *)
let json_sources () =
  Kernel.Files.fold
    (fun file acc ->
       `String (Format.asprintf "%a" Datatype.Filepath.pp_abs file) :: acc
    ) []

let analysis_summary () =
  [
    "Source files",     `List (json_sources ());
    "Using EVA",        `Bool (!Eva_wrapper.using_eva);
    "Deadlock version", `String (Deadlock_options.version);
    "Date and time",    `String (Unix.time () |> Unix.localtime |> format_time)
  ]

let context_sensitive_fns results =
  Results.context_sensitive_fns results
  |> List.map (fun fn -> `String (Format.asprintf "%a" Printer.pp_fundec fn))

let path_sensitive_fns results =
  Results.path_sensitive_fns results
  |> List.map (fun fn -> `String (Format.asprintf "%a" Printer.pp_fundec fn))

let ls_summary results =
  [
    "Lock operations",               `Int (Results.nb_lock_stmts results);
    "Imprecise lock operations",     `Int (Results.nb_imprecise_lock_stmts results);
    "Analysed functions",            `Int (Results.nb_analysed_functions results);
    "Avg. function analyses",        `Float (Results.avg_analyses_per_fn results);
    (*TODO: load it from statistics! *)
    "Success function refinements",  `Int (CFA_analysis.Nb_success_refinements.get ());
    "Failed function refinements",   `Int (CFA_analysis.Nb_failed_refinements.get ());
    "Total function analyses",       `Int (CFA_analysis.Nb_function_analyses.get ());

    "Context sensitive functions",   `List (context_sensitive_fns results);
    "Path sensitive functions",      `List (path_sensitive_fns results);
  ]

let threads thread_graph =
  Thread_graph.fold_vertex (fun t acc -> `String (Thread.to_string t) :: acc) thread_graph []

let thread_graph graph =
  Thread_graph.fold_edges_e
    (fun (parent, stmt, child) acc ->
       `List [`String (Thread.to_string parent); `String (Thread.to_string child)] :: acc
    ) graph []

let thread_summary graph =
  [
    "Threads",             `Int (Thread_graph.nb_vertex graph);
    "Imprecise threads",   `Int (Thread_graph.imprecise_threads graph |> List.length);
    "Fixpoint iterations", `Int (Thread_analysis.Nb_fixpoint_iterations.get ());
    "Thread functions",    `List (threads graph);
    "Thread graph",        `List (thread_graph graph);
  ]

let deadlock dl =
  List.map
      (fun (l1, _, l2) ->
         `List [`String (Lock.to_string l1); `String (Lock.to_string l2)]
      ) dl

let deadlock_list deadlocks =
  List.map
    (fun (dl) ->
       `Assoc [
         "deadlock", `List (deadlock dl)
       ]
    ) deadlocks

let concurrency_check (stats : Statistics.t) =
  [
    "Callstack bound",          `Int (Happend_before.callstack_bound ());
    "Non-concurrent deadlocks", `Int stats.nonc_deadlocks;
    "Total",                    `Int stats.nonc_total;
    "Before create",            `Int stats.nonc_before_create;
    "After join",               `Int stats.nonc_after_join;
    "Same instance",            `Int stats.nonc_same_thread;
    "Non-concurrent threads",   `Int stats.nonc_threads;
    "Gatelocks",                `Int stats.nonc_gatelock;
  ]

let lockgraph locksets =
  Lockgraph.fold_edges_e
    (fun (lock1, traces, lock2) acc ->
       `List [
         `String (Lock.to_string lock1);
         `String (Lock.to_string lock2);
         `Assoc ["count", `Int (List.length traces)];
       ] :: acc
    ) (Results.get_lockgraph locksets) []

let times (stats : Statistics.t) =
  [
    "Main thread analysis",   `Float stats.times.main_thread;
    "Thread analysis",        `Float stats.times.thread_analysis;
    "Lockset analysis",       `Float stats.times.lockset_analysis;
    "Deadlock analysis",      `Float stats.times.deadlock_analysis;
    "Total",                  `Float stats.times.total;
  ]

let json_repr locksets (thread_graph : Thread_analysis.Thread_graph.t) deadlocks (stats : Statistics.t) =
  `Assoc [
    "Analysis informations",    `Assoc (analysis_summary ());
    "Lockset analysis summary", `Assoc (ls_summary locksets);
    "Thread analysis summary",  `Assoc (thread_summary thread_graph);
    "Lockgraph",                `List  (lockgraph locksets);
    "Concurrency check",        `Assoc (concurrency_check stats);
    "Deadlocks",                `List  (deadlock_list deadlocks);
    "Execution times",          `Assoc (times stats);
  ]

let output locksets thread_graph deadlocks stats file =
  let channel = open_out_gen [Open_creat; Open_wronly] 0o666 file in
  Yojson.Basic.(pretty_to_channel channel (json_repr locksets thread_graph deadlocks stats));
  close_out channel
