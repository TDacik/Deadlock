open Thread_analysis
open Trace_utils
open Lock_types

open Cil_datatype

type precondition = Thread.t * Lockset.t * Cvalue.Model.t

module Stmt_summaries = Stmt_summaries
module Function_summaries = Function_summaries
module Results = Lockset_analysis_results

val compute : Thread_graph.t -> Results.t
(** Compute lockset analysis for every thread in graph. *)

(** {2 Exported functions} *)

val update_trace : Callstack.t -> Callstack.t -> Callstack.t

val possible_locks : Cil_types.stmt -> Cil_types.exp -> Lockset.t
(** Possible locks occuring in given expression. This function does not require lockset analysis
    to be computed, but depends on initialisation of EVA wrapper.

    Traces for locks are not valid. *)

