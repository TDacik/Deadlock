(* Purpose of this module is to collect all statistics computed by Deadlock and return them
 * as a record.
 *
 * Author: Tomas Dacik (xdacik00@fit.vutbr.cz), 2020
 *)

let clocks = ref []

open Unix

open Thread_analysis
open Lockset_analysis
open Concurrency_check

type times = {
  main_thread : float;
  thread_analysis : float;
  lockset_analysis : float;
  deadlock_analysis : float;
  total : float;
}

let get_time times = times.tms_utime

let create () = 
  let main_thread = List.assoc "Main thread" !clocks |> get_time in
  let thread_analysis = List.assoc "Thread analysis" !clocks |> get_time in
  let lockset_analysis = List.assoc "Lockset analysis" !clocks |> get_time in
  let deadlock_analysis = List.assoc "Deadlock analysis" !clocks |> get_time in
  let total = List.assoc "Total" !clocks |> get_time in
  (* Compute time differences in reverse order *)
  {
    deadlock_analysis = deadlock_analysis -. lockset_analysis;
    lockset_analysis = lockset_analysis -. thread_analysis;
    thread_analysis = thread_analysis -. main_thread;
    main_thread = main_thread;
    total = total;
  }

let timer event =
  clocks := (event, Unix.times ()) :: !clocks

type t = {
  imprecise_locks : int;
  imprecise_threads : Thread.t list;
  nonc_deadlocks : int;
  nonc_total : int;
  nonc_before_create : int;
  nonc_after_join : int;
  nonc_same_thread : int;
  nonc_threads : int;
  nonc_gatelock : int;
  times : times;
}

let get results g = {
  imprecise_locks = Results.nb_imprecise_lock_stmts results;
  imprecise_threads = Thread_graph.imprecise_threads g;

  nonc_deadlocks = Nb_deadlocks.get ();
  nonc_total = Nb_nonc.get ();
  nonc_before_create = Nb_before_create.get ();
  nonc_after_join = Nb_after_join.get ();
  nonc_same_thread = Nb_same_thread.get ();
  nonc_threads = Nb_nonc_threads.get ();
  nonc_gatelock = Nb_gatelock.get ();
  times = create ();
}

let pp_imprecision fmt stats =
  let threads = stats.imprecise_threads in 
  if stats.imprecise_locks > 0 then Format.fprintf fmt "Imprecise lock statements:\n" else  ();
  if (List.length threads) > 0 then Format.fprintf fmt "Imprecise threads:\n" else  (); 
  List.iter (fun thread -> Format.fprintf fmt "%a\n" Thread.pp thread) threads;
