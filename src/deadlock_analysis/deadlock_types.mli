(* Definition of two deadlock types and related operations:
 *
 * Author: Tomas Dacik (xdacik00@fit.vutbr.cz), 2020 *)

open Lock_types
open Trace_utils

type abstract_edge = Lock.t * (Edge_trace.t list) * Lock.t
(** Edge labelled with multiple traces of its creation *)

type concrete_edge = Lock.t * Edge_trace.t * Lock.t
(** Edge labelled with a single selected trace of its creation *)

type abstract_deadlock = abstract_edge list
(** Cycle of abstract edges *)

type concrete_deadlock = concrete_edge list
(** Cycle of concrete edges *)

val get_trace : concrete_deadlock -> Edge_trace.t list

val get_traces : abstract_deadlock -> Edge_trace.t list list

val is_simple_deadlock : abstract_deadlock -> bool
(** Simple deadlock consists of exactly two lockgraph edges *)

val concrete_instances : abstract_deadlock -> concrete_deadlock list
(** Return all possible concrete instances of given abstract deadlock *)

val get_involved_threads : concrete_deadlock -> Thread.t list
(** Return list of threads involved in deadlock *)

val pp : Format.formatter -> concrete_deadlock -> unit
