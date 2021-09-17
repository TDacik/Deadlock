(* Lockgraph is oriented graph with locks as vertices and edges representing locking
 * order. Each edge is labelled by list of traces describing how the edge was obtained.
 *
 * Author: Tomas Dacik (xdacik00@fit.vutbr.cz), 2020
 *)

open Lock_types
open Deadlock_types
open Trace_utils

include Graph.Sig.P
  with type V.t = Lock.t
   and type E.t = Lock.t * Edge_trace.t list * Lock.t
   and type E.label = (Edge_trace.t) list

val add_edge : t -> E.t -> t
(** [add_edge g l1 l2 trace] creates edge l1 -> l2 labeled by trace and
    adds it to the g. If l1 -[traces]-> l2 is already presented, its label
    is updated to trace :: traces *)

val union : t -> t -> t
(** Union of (not necessarily disjoint) graphs. Labels on edges are concatenated. *)

val get_locks : t -> Lockset.t

val has_cycle : t -> bool

val find_deadlocks : t -> abstract_deadlock list
(** Return all cycles as potential deadlocks. See 'deadlock_types' for details of deadlocks
    representation. *)

val pp_edges : Format.formatter -> t -> unit
