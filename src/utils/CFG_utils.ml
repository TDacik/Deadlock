(* Utilities for scanning and searching in Control Flow Graph that are not implemented in Frama-C.
 * All functions use syntactic information (mainly reachability) only and are therefore
 * under-approximations.
 *
 * Author: Tomas Dacik (xdacik00@fit.vutbr.cz), 2020
 *)

open! Deadlock_top

open Cil_types
open Trace_utils

(** Return all statements matching predicate *)
let all_stmts_predicate predicate =
  let aux predicate fundec =
    List.fold_right
      (fun stmt acc ->
         if predicate stmt then stmt :: acc else acc
      ) fundec.sallstmts []
  in
  Globals.Functions.fold
    (fun kf acc ->
      try
        let fundec = Kernel_function.get_definition kf in
        aux predicate fundec @ acc
      with Kernel_function.No_Definition -> acc
    ) []

(** Return all functions matching predicate *)
let all_fundecs_predicate predicate =
  Globals.Functions.fold
    (fun kf acc ->
      if predicate kf then
        try
          let fundec = Kernel_function.get_definition kf in
          fundec :: acc
        with _ -> acc
      else acc
    ) []

let callsites stmt =
  let kf = Kernel_function.find_englobing_kf stmt in
  Kernel_function.find_syntactic_callsites kf |> List.map snd

let rec transitive_callsites_aux stmt visited =
  let kf = Kernel_function.find_englobing_kf stmt in
  let callsites = Kernel_function.find_syntactic_callsites kf in
  let stmts = List.map snd callsites in
  List.fold_right
    (fun (kf, stmt) acc ->
       let fn = Kernel_function.get_definition kf in
       if not @@ List.mem ~eq:Fundec.equal fn visited then
           acc @ transitive_callsites_aux stmt (fn :: visited)
       else acc
    ) callsites stmts

let transitive_callsites stmt = 
  transitive_callsites_aux stmt []
  |> List.sort_uniq ~cmp:Stmt.compare

let toplevel_callsites entry_points stmt =
  transitive_callsites stmt
  |> List.find_all
    (fun stmt ->
       let kf = Kernel_function.find_englobing_kf stmt in
       let fn = Kernel_function.get_definition kf in
       List.mem ~eq:Fundec.equal fn entry_points
    )

let rec all_callstacks_ stmt entry_points call_suffix =
  let kf = Kernel_function.find_englobing_kf stmt in
  let fn = Kernel_function.get_definition kf in
  let callsites = Kernel_function.find_syntactic_callsites kf in

  if List.mem ~eq:Fundec.equal fn entry_points then
    let dummy_thread = Thread.create_bottom fn in
    [Callstack.Thread_entry dummy_thread :: call_suffix]
  else
    List.fold_left
      (fun acc callsite ->
         let event = Callstack.Call (callsite, fn) in
         if not @@ List.mem ~eq:Callstack.equal_event event call_suffix then
           let suffix = event :: call_suffix in
           all_callstacks_ callsite entry_points suffix @ acc
         else
           [call_suffix] @ acc
      ) [] (List.map snd callsites)
  

let all_callstacks ?(name="") entry_points stmt = 
  let callstacks = all_callstacks_ stmt entry_points [] in
  List.map
    (fun suffix ->
       List.concat [suffix; [Callstack.Action (stmt, name)]]
       |> List.rev
    ) callstacks

(** Maximal depth of statemt in callgraph *)
let max_depth stmt =
  let entry_points = 
    all_fundecs_predicate 
      (fun kf ->
        match Kernel_function.find_syntactic_callsites kf with
        | [] -> true
        | _ -> false
      )
  in
  all_callstacks entry_points stmt
  |> List.map (fun cs -> (Callstack.depth cs) - 1)
  |> List.fold_left (fun max elem -> if elem > max then elem else max) 0
