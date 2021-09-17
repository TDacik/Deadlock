(* Human-readable json output.
 *
 * Author: Tomas Dacik (xdacik00@fit.vutbr.cz), 2021
 *)

val output :
  Lockset_analysis.Results.t
  -> Thread_analysis.Thread_graph.t
  -> Deadlock_types.concrete_deadlock list
  -> Statistics.t
  -> string
  -> unit

