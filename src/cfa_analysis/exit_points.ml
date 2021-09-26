(* In intermediate representation used by Frama-C, all functions have a single exit point that
 * can be preceeded by unbounded numbers of Leave edges. Purpose of this module is to compute
 * actual exit points.
 *
 * TODO: caching
 *
 * Author: Tomas Dacik (xdacik00@fit.vutbr.cz), 2021
 *)

open! Deadlock_top

module CFA = Interpreted_automata
open CFA

let get_cfa fn =
  Statement_utils.kernel_fn_from_fundec fn
  |> CFA.get_automaton
  
(** Return true, if edge has no effect *)
let edge_has_no_effect (_, e, _) = match e.edge_transition with
  | Skip | Return _ | Prop _ | Leave _ -> true
  | Instr (instr, _) -> 
    begin match instr with 
      | Skip _ -> true 
      | _ -> false
    end
  | _ -> false

let is_exit_point cfa v = Vertex.equal v cfa.return_point

(** Compute exit points using backward reachability from automaton's exit point via edges
    that has no effect. *)

module Exit_points = Graph.Fixpoint.Make
    (CFA.G)
    (struct
      type vertex = CFA.G.V.t
      type edge = CFA.G.E.t
      type g = G.t
      type data = bool (* true iff V is exit point *)

      let direction = Graph.Fixpoint.Backward
      let equal = Bool.equal
      let join = (||)
      let analyze edge data = data && edge_has_no_effect edge
    end)

let is_exit_point stmt =
  let fn = Statement_utils.find_englobing_fn stmt in
  let cfa = get_cfa fn in
  let _, vertex = Stmt.Hashtbl.find cfa.stmt_table stmt in
  let is_exit = Exit_points.analyze (is_exit_point cfa) cfa.graph in
  is_exit vertex
