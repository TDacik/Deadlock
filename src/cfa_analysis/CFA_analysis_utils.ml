(* Predefined instances of parameters of CFA analysis functor.
 *
 * Author: Tomas Dacik (xdacik00@fit.vutbr.cz), 2021
 *)

open Trace_utils
open Cil_datatype

include CFA_analysis_signatures

(** No function refinement is performed *)
module No_refinement (State : STATE) (Results : RESULTS) = struct
  type state = State.t
  type results = Results.t

  let condition _ _ _ = false

  (* Folowing functions are never called *)
  let refine_entry_state _ _ = failwith "Internal error"
  let post_refine _ _ = failwith "Internal error"
  let post_failed_refine _ _ _ _ _ = failwith "Internal error"
end

(** Summary caching visited functions. *)
module Visited_functions (State : STATE) (Results : RESULTS) = struct
  module Cache = Fundec.Map

  type t = bool Cache.t
  type state = State.t
  type results = Results.t

  let empty = Cache.empty
  let add fn _ _ _ cache = Cache.add fn true cache
  let find_and_update fn state _ cache =
    let _ = Cache.find fn cache in
    ([state], Results.empty)

  let pp fmt = Cache.iter (fun fn _ -> Format.fprintf fmt "%a" Printer.pp_fundec fn)

end

(** Summary caching visited functions separately for different threads. *)
module Visited_functions_threads (State : STATE) (Results : RESULTS) = struct
  module Cache = Map.Make
      (struct
        type t = Thread.t * Fundec.t
        let compare (t1, fn1) (t2, fn2) =
          if Thread.compare t1 t2 <> 0 then Thread.compare t1 t2
          else Fundec.compare fn1 fn2
      end)

  type t = bool Cache.t
  type state = State.t
  type results = Results.t

  let empty = Cache.empty
  
  let add fn _ callstack _ cache =
    let thread = Callstack.get_thread callstack in
    Cache.add (thread, fn) true cache
  
  let find_and_update fn state callstack cache =
    let thread = Callstack.get_thread callstack in
    let _ = Cache.find (thread, fn) cache in
    ([state], Results.empty)

  let pp fmt = 
    Cache.iter (fun (t, fn) _ -> Format.fprintf fmt "(%a, %a)" Thread.pp t Printer.pp_fundec fn)

end
