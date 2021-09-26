(* Lockgraph is oriented graph with locks as vertices and edges representing locking
 * order. Each edge is labelled by list of traces describing how the edge was obtained.
 *
 * Author: Tomas Dacik (xdacik00@fit.vutbr.cz), 2020
 *)

open! Deadlock_top

open Lock_types
open Trace_utils

module Lock_order_edge = struct
  type t = Edge_trace.t list
  let compare = List.compare Edge_trace.compare
  let default = []
end

module Lockgraph = Graph.Persistent.Digraph.ConcreteBidirectionalLabeled
    (Lock)(Lock_order_edge)

include Lockgraph

(* Create new edge. If it already exists, update it by adding labels. *)
let add_edge g (lock1, traces, lock2) =
  try
    let edge = find_edge g lock1 lock2 in
    let label = E.label edge in
    let new_label = traces @ label in
    let new_edge = E.create lock1 new_label lock2 in
    let g = remove_edge_e g edge in
    add_edge_e g new_edge

  (* Create new edge *)
  with Not_found ->
    let edge = E.create lock1 traces lock2 in
    add_edge_e g edge

let add_edge_e g e =
  let src, label, dst = E.src e, E.label e, E.dst e in
  add_edge g (src, label, dst)

(* Union of (not necessarily disjoint) graphs. Traces at common edges are concatenated. *)
let union g1 g2 = fold_edges_e (fun e g_res -> add_edge_e g_res e) g1 g2

module Edge_set = Set.Make(E)

let compare_edge_list l1 l2 = Edge_set.compare (Edge_set.of_list l1) (Edge_set.of_list l2)

module BF = Graph.Path.BellmanFord
    (Lockgraph)
    (struct
      include Int
      
      type edge = Lockgraph.edge
      let weight _ = -1
    end)

let has_cycle g =
  try 
    let _ = BF.find_negative_cycle g in
    true
  with Not_found -> false

(* Remove duplicit and empty cycles. Then convert rest to list of locks. *)
(* TODO: consider reversed cycles *)
let filter_deadlocks dls =
  let dls_vertexes = List.map
      (fun dl ->
         List.map
           (fun edge ->
              let src = E.src edge in
              let dst = E.dst edge in
              let traces = E.label edge in
              (src, traces, dst)
           ) (List.sort E.compare dl)
      ) dls in
  List.sort_uniq compare_edge_list dls_vertexes

let rec dfs g vertex visited path =
  fold_succ_e
    (fun e cycles ->
       let dst = E.dst e in
       let path = e :: path in
       if V.equal dst (List.hd visited) then path :: cycles
       else if List.mem ~eq:V.equal dst visited then cycles
       else dfs g dst (List.append visited [dst]) path @ cycles
    ) g vertex []

let cycles_from_v g v = dfs g v [v] [] 

let find_deadlocks g =
  fold_vertex
    (fun vertex acc ->
       cycles_from_v g vertex @ acc
    ) g []
  |> filter_deadlocks

let get_locks g = fold_vertex Lockset.add g Lockset.empty

let pp_edges fmt g =
  iter_edges_e
    (fun (l1, traces, l2) ->
       let str1 = Lock.to_string l1 in
       let str2 = Lock.to_string l2 in
       let count = List.length traces in
       Format.fprintf fmt "%s -> %s \t (%d times)\n" str1 str2 count;
    ) g
