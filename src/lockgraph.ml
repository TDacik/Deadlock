open Deadlock_options
open Deadlock_utils
open Lockset

module G = Graph.Imperative.Digraph.ConcreteBidirectionalLabeled(Lock)
    (struct
      type t = Callstack.t * Callstack.t
      let compare = Pervasives.compare
      let default = (Callstack.empty (), Callstack.empty ())
    end)

module Weights = 
struct
  type edge = G.E.t
  type t = int
  let weight edge = -1
  let compare = Pervasives.compare
  let add = (+)
  let zero = 0
end

module BellmanFord = Graph.Path.BellmanFord(G)(Weights)

module VertexMap = Map.Make
(struct
  type t = G.E.t
  let compare = Pervasives.compare
end)

include G
    
let add_dependency lock1 lock2 trace g =
  let edge = (lock1, trace, lock2) in
  add_edge_e g edge

(** Filter duplicit and empty cycles and converts rest to list of locks *)
let filter_deadlocks dls = 
  let dls_vertexes = List.map
      (fun dl ->
         List.map
           (fun edge ->
              let src = E.src edge in
              let dst = E.dst edge in
              let trace1 = fst (E.label edge) in
              let trace2 = snd (E.label edge) in
              (src, dst, trace1, trace2)
           ) dl
      ) dls in
  List.sort_uniq Pervasives.compare dls_vertexes

let get_all_deadlocks g =
  let dls = fold_vertex
      (fun vertex acc ->
         try
           let dl = BellmanFord.find_negative_cycle_from g vertex in
           dl :: acc
         with Not_found ->
           acc
      ) g [] in
  filter_deadlocks dls

let print_edges g =
  iter_edges
    (fun l1 l2 ->
       let str1 = Lock.to_string l1 in
       let str2 = Lock.to_string l2 in
       Self.feedback "%s -> %s" str1 str2
    ) g
