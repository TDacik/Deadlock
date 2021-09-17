(* Imperative representation of Deadlock's concurrency model.
 *
 * Author: Tomas Dacik (xdacik00@fit.vutbr.cz), 2021 
 *)

(* Imperative set with minimal functionality needed for the model *)
module Imperative_set (Ord : Set.OrderedType) = struct
  
  module S = Set.Make(Ord)

  let self = ref S.empty
  
  let add x = self := S.add x !self
  let mem x = S.mem x !self
  let iter fn = S.iter fn !self
  let cardinal () = S.cardinal !self

end

(* Imperative map with minimal functionality needed for the model *)
module Imperative_map (Ord : Map.OrderedType) = struct
  
  module M = Map.Make(Ord)

  let self = ref M.empty

  let add (key, (x : int list)) = self := M.add key x !self
  let mem key = M.mem key !self
  let find key = M.find key !self
  let iter fn = M.iter fn !self
  let cardinal () = M.cardinal !self

end

(* Locks *)

module Lock_types                 = Imperative_set(String)
module Lock_functions             = Imperative_map(String)
module Unlock_functions           = Imperative_map(String)
module Nonblocking_lock_functions = Imperative_map(String)
module Lock_init_functions        = Imperative_map(String)
module Lock_destroy_functions     = Imperative_map(String)

(* Conditions *)

module Condition_wait_functions = Imperative_map(String)

(* Threads *)

module Thread_types            = Imperative_set(String)
module Thread_create_functions = Imperative_map(String)
module Thread_join_functions   = Imperative_map(String)
