(* Thread graph is a multigraph that represents parent-child relations of threads.
 *
 * Edges are of form:  parent -{create_stmt}-> child
 *
 * Author: Tomas Dacik (xdacik00@fit.vutbr.cz), 2020 
 *)

open! Deadlock_top

open Graph
open Callgraph
open Cil_types
open Cil_datatype

module Stmts = Statement_utils
module Conc_model = Concurrency_model

module Thread_create_edge = struct
  type t = Cil_types.stmt
  let compare = Stmt.compare
  let default = Cil.dummyStmt
end

module G = Graph.Persistent.Digraph.ConcreteBidirectionalLabeled
    (Thread)(Thread_create_edge)

include G

module Vertex_set = Set.Make(G.V)
module Edge_set = Set.Make(G.E)

let get_vertices g = fold_vertex Vertex_set.add g Vertex_set.empty

let get_edges g = fold_edges_e Edge_set.add g Edge_set.empty

(* Extensional equality based on all vertices and edges *)
let equal g1 g2 =
  let v1 = get_vertices g1 in
  let v2 = get_vertices g2 in
  let e1 = get_edges g1 in
  let e2 = get_edges g2 in
  Vertex_set.equal v1 v2 && Edge_set.equal e1 e2

let hash = Hashtbl.hash

(* ==== Accessors ==== *)

let get_threads g = fold_vertex List.cons g []

let get_create_stmts g = fold_edges_e (fun (_, stmt, _) acc -> stmt :: acc) g []

let get_entry_points g =
  let threads = get_threads g in
  List.map Thread.get_entry_point threads

(* ==== Queries ==== *)

let create_stmts_of_thread g thread =
  let incoming_edges = pred_e g thread in
  List.fold_left (fun acc (_, stmt, _) -> stmt :: acc) [] incoming_edges
    
(* TODO: use all callstacks? *)
let is_created_multiple_times g thread =
  let create_stmts = create_stmts_of_thread g thread in
  if (List.length create_stmts) > 1 then true
  else if Thread.is_main thread then false
  else
    let _ = assert (List.length create_stmts = 1) in
    let create_stmt = List.hd create_stmts in
    let all_callsites = CFG_utils.transitive_callsites create_stmt in
    let entry_points = get_entry_points g in
    let toplevel_callsites =
      List.fold_right
        (fun stmt acc ->
           acc @ CFG_utils.toplevel_callsites entry_points stmt
        ) create_stmts []
    in
    List.exists Stmts_graph.stmt_is_in_cycle (create_stmt :: all_callsites)
    || (List.length toplevel_callsites) > 1
    || List.exists 
      (fun stmt ->
         let callsites = CFG_utils.callsites stmt in
         List.length callsites > 1
      ) all_callsites 

let get_thread_ids g thread = 
  let create_stmts = create_stmts_of_thread g thread in
  List.fold_right
    (fun stmt acc ->
       Conc_model.thread_create_id stmt :: acc
    ) create_stmts []

let get_main_thread g = List.find Thread.is_main (get_threads g)

let find_by_fundec g fundec =
  get_threads g
  |> List.find (fun t -> Fundec.equal (Thread.get_entry_point t) fundec)

let find_by_kf g kf =
  try find_by_fundec g (Kernel_function.get_definition kf)
  with Kernel_function.No_Definition -> raise Not_found

let get_equiv_threads g t =
  get_threads g
  |> List.filter (fun t' -> Thread.equal_states t t' && not @@ Thread.equal t t')

let imprecise_threads g = 
  List.filter (fun t -> not (Thread.is_computed t)) (get_threads g)

let is_precise g = List.for_all Thread.is_computed (get_threads g)

(* ==== Printing functions ==== *)

let pp_init_states fmt g = iter_vertex
    (fun thread -> Format.fprintf fmt "%a" Thread.pp_init_state thread) g

let pp fmt g = iter_edges_e
    (fun (t1, _, t2) -> Format.fprintf fmt "%a -> %a" Thread.pp t1 Thread.pp t2) g

let pp_threads fmt g = iter_vertex
    (fun thread -> Format.fprintf fmt "%a\n" Printer.pp_fundec (Thread.get_entry_point thread)) g
