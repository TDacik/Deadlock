(* Definition of two deadlock types and related operations:
 *  
 *  - abstract deadlock stores for each lockgraph edge all possible traces
 *    leading to its creation
 *  
 *  - concrete deadlock is obtained by selection of a single trace for each
 *    edge
 *
 * Author: Tomas Dacik (xdacik00@fit.vutbr.cz), 2020 *)

open! Deadlock_top

open Lock_types
open Trace_utils

type abstract_edge = Lock.t * (Edge_trace.t list) * Lock.t

type concrete_edge = Lock.t * Edge_trace.t * Lock.t

type abstract_deadlock = abstract_edge list

type concrete_deadlock = concrete_edge list

let is_simple_deadlock deadlock = Int.equal (List.length deadlock) 2

let get_trace dl = List.map (fun (_, trace, _) -> trace) dl

let get_traces dl = List.map (fun (_, traces, _) -> traces) dl

let get_involved_threads dl = get_traces dl |> List.map Edge_trace.get_thread

let edge_concrete_instances (l1, traces, l2) =
  List.map (fun trace -> (l1, trace, l2)) traces

(* For abstract deadlock, return all its concrete instances *)
let concrete_instances abstract_deadlock =
  abstract_deadlock
  |> List.map edge_concrete_instances
  |> List.cartesian_product

(* String of involved threads separated by comma *)
let get_involved_threads_str dl =
  get_involved_threads dl
  |> List.map Thread.get_entry_point
  |> List.sort Cil_datatype.Fundec.compare
  |> List.map (Format.asprintf "%a" Printer.pp_fundec)
  |> String.concat " and "

let edge_to_string lock1 lock2 =
  Format.asprintf "%a -> %a" 
    Lock.pp lock1 
    Lock.pp lock2

let to_string dl =
  let threads_str = get_involved_threads_str dl in
  let str1 = Format.asprintf "Deadlock between threads %s:\n" threads_str in
  let deps = List.fold_right
      (fun (lock1, trace, lock2) acc ->
         let str = Format.asprintf "\nTrace of dependency (%s):\n" 
             (edge_to_string lock1 lock2) 
         in
         let str2 = str ^ Edge_trace.to_string trace in
         acc ^ str2
      ) dl "" 
  in
  str1 ^ deps

let pp fmt dl = Format.fprintf fmt "%s" (to_string dl)
