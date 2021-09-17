(* Implementation of loop for filtering traces of deadlocks based on
 * concurrency checking and simple ranking mechanism.
 *
 * Author: Tomas Dacik *)

open Deadlock_types
open Thread_analysis

val filter : Thread_graph.t 
             -> Lockset_analysis.Results.t 
             -> abstract_deadlock list
             -> concrete_deadlock list
(** Filter out non-concurrent traces and return best-ranked concrete instances *)

val no_conc : Lockset_analysis.Results.t
              -> abstract_deadlock list 
              -> concrete_deadlock list
(** Return best-ranked concrete instances (without concurrency checking) *)
