open Thread_analysis
open Trace_utils

open CFA_analysis_signatures

module Make (Analysis : ANALYSIS) : sig
  open Analysis

  module States : sig 
    
    type t 
  
  end

  val compute : Thread_graph.t -> Analysis.Results.t

end


(** {2 Statistics} *)
open Imperative_counter

module Nb_success_refinements : IMPERATIVE_COUNTER
module Nb_failed_refinements : IMPERATIVE_COUNTER
module Nb_function_analyses : IMPERATIVE_COUNTER
