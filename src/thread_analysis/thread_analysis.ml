(* Fixpoint computation of thread-creation graph and initial states of all threads.
 *
 * Author: Tomas Dacik (xdacik00@fit.vutbr.cz), 2020 
 *)

open! Deadlock_top

open Graph
open Callgraph
open Cil_datatype

module Stmts = Statement_utils
module Thread_graph = Thread_graph

module Nb_fixpoint_iterations = Imperative_counter.Counter ()

(* Dijkstra algorithm over callgraph *)
module Dijkstra = Graph.Path.Dijkstra
    (Cg.G)
    (struct
      type edge = Cg.G.E.t
      type t = int
      let weight e = 1
      let compare = Stdlib.compare
      let add = (+)
      let zero = 0
    end)

(* ==== Fixpoint computation ==== **)

let init thread = Thread.get_init_state thread

let fixpoint_step (parent, stmt, child) (globals, args) =
  
  Self.debug ~level:1 "Fixpoint step for %a -> %a at %a"
    Thread.pp parent 
    Thread.pp child 
    Printer.pp_stmt stmt;

  let thread = Thread.create (Thread.get_entry_point parent) globals args in
  Eva_wrapper.set_active_thread thread;
  Eva_wrapper.get_stmt_state_with_arg stmt

(* Weak topological ordering over thread graph *)
module WTO = WeakTopological.Make(Thread_graph)

(* Initialisation of fixpoint algorithm *)
module ChaoticIteration = ChaoticIteration.Make(Thread_graph)
    (struct
      type t = Thread.Thread_initial_state.t
      type edge = Thread_graph.E.t

      let join = Thread.Thread_initial_state.join
      let equal = Thread.Thread_initial_state.equal
      let widening = Thread.Thread_initial_state.widening
    
      let analyze = fixpoint_step
    end)

(* Reachability of stmt from thread is determined based on existence of path
   from thread entry point to stmt's function in callgraph *)
let is_stmt_reachable_from_thread_precise thread stmt =
  let stmt_kf = Kernel_function.find_englobing_kf stmt in
  let thread_fn = Thread.get_entry_point thread in
  let thread_kf = Stmts.kernel_fn_from_fundec thread_fn in
  let callgraph = Cg.get () in
  try
    let _ = Dijkstra.shortest_path callgraph thread_kf stmt_kf in
    true
  with Not_found -> false

let is_stmt_reachable_from_thread_aprox thread stmt =
  let thread = Thread.get_entry_point thread in
  let stmts = CFG_utils.toplevel_callsites [thread] stmt in
  (List.length stmts) > 0

let is_stmt_reachable_from_thread thread stmt =
  is_stmt_reachable_from_thread_aprox thread stmt       (* Syntactic reachability *)
  || is_stmt_reachable_from_thread_precise thread stmt  (* Possible semantic reachability *)

(* Construct thread graph based on information that thread can reach particular
   statement and create a child here *)
let build_graph threads =
  let main = Eva_wrapper.get_main_thread () in
  let g0 = Thread_graph.add_vertex Thread_graph.empty main in
  let create_locs = CFG_utils.all_stmts_predicate Conc_model.is_thread_create in
  List.fold_right
    (fun thread g ->
         Eva_wrapper.set_active_thread thread;
         List.fold_right
           (fun stmt g ->
              if is_stmt_reachable_from_thread thread stmt then
                let created_threads = Eva_wrapper.get_created_threads stmt in
                List.fold_right
                  (fun child g ->
                     Thread_graph.add_edge_e g (thread, stmt, child);
                  ) created_threads g
              else g
           ) create_locs g
    ) threads g0

module Graph_update = Gmap.Edge(Thread_graph)
    (struct
      include Thread_graph
      let empty () = Thread_graph.empty
    end)

let update_graph initial_states g = match Thread_graph.nb_vertex g with
  | 1 -> g
  | _ ->
    Self.result "Map:";
    ChaoticIteration.M.iter
      (fun k v -> Self.result "-((%a,%a) -> <$>)" 
          Thread.pp k 
          Printer.pp_fundec (Thread.get_entry_point k)
      ) initial_states;
    Self.result "Graph:";
    Thread_graph.iter_edges_e
      (fun (t1, _, t2) -> Self.result "%a -> %a" 
          Thread.pp t1
          Thread.pp t2
      ) g;
    Graph_update.map
      (fun (t1, stmt, t2) ->
         Self.result "Search for %a" Thread.pp t1;
         let t1' = Thread.update_state t1 (ChaoticIteration.M.find t1 initial_states) in
         Self.result "Search for %a" Thread.pp t2;
         let t2' = Thread.update_state t2 (ChaoticIteration.M.find t2 initial_states) in
         (t1', stmt, t2')
      ) g

let rec graph_construction_fixpoint g_init =
  
  Nb_fixpoint_iterations.inc ();
  Self.debug ~level:1 "Outter fixpoint iteration: %d" (Nb_fixpoint_iterations.get ());
 
  (* Inner fixpoint computations -- initial states of threads *)
  let root = Thread_graph.get_main_thread g_init in
  let wto = WTO.recursive_scc g_init root in
  let initial_states = ChaoticIteration.recurse g_init wto init FromWto 1 in

  (* Update thread states *)
  Self.result "Graph:";
  Thread_graph.iter_edges_e
    (fun (t1, _, t2) -> Self.result "%a -> %a" 
        Thread.pp t1
        Thread.pp t2
    ) g_init;
  let g = update_graph initial_states g_init in 

  (* Build a new graph *)
  let threads = Thread_graph.get_threads g in
  let new_g = build_graph threads in
  
  (* Repeat until fixpoint *)
  if Thread_graph.equal g new_g then g else graph_construction_fixpoint new_g

let compute () =

  Self.feedback "Thread analysis started";
  Nb_fixpoint_iterations.reset ();
  
  (* Initial graph with main thread only *)
  let threads = [Eva_wrapper.get_main_thread ()] in
  let g0 = build_graph threads in

  let res = graph_construction_fixpoint g0 in

  Self.debug ~level:1 ~dkey:Deadlock_options.dkey_t_init_state "%a" Thread_graph.pp_init_states res;
  Self.feedback "Thread analysis finished";
  res
