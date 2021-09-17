(* Implementation of concurrency checking functions
 *
 * Author: Tomas Dacik (xdacik00@fit.vutbr.cz), 2020
 *)

open Trace_utils
open Thread_analysis
open Imperative_counter

module Results = Lockset_analysis.Results

val are_concurrent_callstacks : ?conservative:bool -> Thread_graph.t -> Results.t -> Callstack.t -> Callstack.t -> bool

(** {2 separated checking functions} *)

val check_gatelock : Results.t -> Cil_types.stmt -> Cil_types.stmt ->  bool

val check_same_instances : Thread_graph.t -> Results.t -> Thread.t -> Thread.t -> bool

val check_nonc_threads : Thread_graph.t ->Thread.t -> Thread.t -> bool

val check_before_create : Thread_graph.t -> Callstack.t -> Callstack.t -> bool

val check_after_join : Thread_graph.t -> Callstack.t -> Callstack.t -> bool

(** {2 checking functions applied to deadlocks} *)

val are_concurrent_traces : Thread_graph.t -> Results.t -> Edge_trace.t -> Edge_trace.t -> bool

(** {2 Statistics} *)
module Nb_deadlocks : IMPERATIVE_COUNTER
module Nb_nonc : IMPERATIVE_COUNTER
module Nb_before_create : IMPERATIVE_COUNTER
module Nb_after_join : IMPERATIVE_COUNTER
module Nb_same_thread : IMPERATIVE_COUNTER
module Nb_nonc_threads : IMPERATIVE_COUNTER
module Nb_gatelock : IMPERATIVE_COUNTER

val reset_statistics : unit -> unit
