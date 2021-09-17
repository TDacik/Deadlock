(* Predefined instances of parameters of CFA analysis functor.
 *
 * Author: Tomas Dacik (xdacik00@fit.vutbr.cz), 2021
 *)

open CFA_analysis_signatures

module No_refinement (State : STATE) (Results : RESULTS)
  : REFINEMENT with type state = State.t 
                and type results = Results.t 

(** No function refinement is performed. *)


module Visited_functions (State : STATE) (Results : RESULTS)
  : FUNCTION_CACHE with type state = State.t 
                    and type results = Results.t

(** Summary caching visited functions. Each function is analysed at most once. *)


module Visited_functions_threads (State : STATE) (Results : RESULTS)
  : FUNCTION_CACHE with type state = State.t 
                    and type results = Results.t

(** Summary caching visited functions sepparately for different threads. Each function is analysed 
    at most n times, where n is number of program threads. *)
