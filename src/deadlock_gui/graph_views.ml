(* Graph visualisation
 *
 * Author: Tomas Dacik (xdacik00@fit.vutbr.cz), 2021
 *)

open Lock_types
open Thread_analysis

module Thread_graph_dot = Graph.Graphviz.Dot
    (struct
      include Thread_graph

      let graph_attributes _ = []
      let default_vertex_attributes _ = []
      let vertex_name = Thread.to_string
      let vertex_attributes _ = []
      let get_subgraph _ = None
      let edge_attributes _ = []
      let default_edge_attributes _ = []
    end)

module Lockgraph_dot = Graph.Graphviz.Dot
    (struct
      include Lockgraph

      let graph_attributes _ = []
      let default_vertex_attributes _ = []
      let vertex_name = Lock.to_string
      let vertex_attributes _ = []
      let get_subgraph _ = None
      let edge_attributes _ = []
      let default_edge_attributes _ = []
    end)
