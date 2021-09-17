(* EVA wrapper has three purposes:
 *
 *  1. Pretends that EVA can analyse multithread programs (@see 'thread analysis' for details) by
 *     setting active thread and switching computed results.
 *  2. Simplifies values returned by EVA according needs of Deadlock.
 *  3. Provides implementation that does not require EVA and uses only syntactic features from
 *     CIL API
 *
 *  Author: Tomas Dacik (xdacik00@fit.vutbr.cz), 2020
 *)

open Cil_types

module Utils = Eva_wrapper_utils
module Stmts = Statement_utils
module Conc_model = Concurrency_model

(* Wrapper instance using CIL *)
module Cil_wrapper = Cil_wrapper_instance

(* Wrapper instance using EVA *)
module Eva_wrapper = Eva_wrapper_instance

(* Simplified abstract context of EVA *)
type abstract_context = (Cil_types.varinfo * int) list

let using_eva = ref false

let init () =
  Eva_wrapper.init ();
  using_eva := true

(* Functions determining right implementation. 
   TODO: can this be simplified? *)

let set_active_thread thread =
  if !using_eva then Eva_wrapper.set_active_thread thread
  else Cil_wrapper.set_active_thread thread

let get_active_thread thread =
  if !using_eva then Eva_wrapper.get_active_thread thread
  else Cil_wrapper.get_active_thread thread

let eval_expr stmt expr =
  if !using_eva then Eva_wrapper.eval_expr stmt expr
  else Cil_wrapper.eval_expr stmt expr

let eval_expr_raw stmt expr =
  if !using_eva then Eva_wrapper.eval_expr_raw stmt expr
  else Cil_wrapper.eval_expr_raw stmt expr

let get_stmt_state stmt =
  if !using_eva then Eva_wrapper.get_stmt_state stmt
  else Cil_wrapper.get_stmt_state stmt

let eval_thread thread =
  if !using_eva then Eva_wrapper.simplify_state (Thread.get_args thread)
  else []

let eval_fn_pointer expr =
  if !using_eva then Eva_wrapper.eval_fn_pointer expr
  else Cil_wrapper.eval_fn_pointer expr

(* ==== Memory accesses ==== *)

let stmt_reads stmt =
  if !using_eva
  then Eva_wrapper.stmt_reads stmt
  else Cil_wrapper.stmt_reads stmt

let stmt_writes stmt =
  if !using_eva
  then Eva_wrapper.stmt_writes stmt
  else Cil_wrapper.stmt_writes stmt

let inputs fn =
  if !using_eva
  then Eva_wrapper.inputs fn |> Utils.zone_to_bases
  else Cil_wrapper.inputs fn |> Utils.zone_to_bases

let outputs fn =
  if !using_eva
  then Eva_wrapper.outputs fn |> Utils.zone_to_bases
  else Cil_wrapper.outputs fn |> Utils.zone_to_bases

(* ==== Functions build using minimal signature ==== *)

let pure_inputs fn =
  let inputs = inputs fn in
  let outputs = outputs fn in
  List.find_all (fun x -> not @@ List.mem x outputs) inputs
  |> Base.Set.of_list

let get_stmt_state_with_arg stmt =
  let state = get_stmt_state stmt in
  let arg = eval_expr_raw stmt (Conc_model.thread_create_arg stmt) in
  (state, arg)

(*
let eval_expr_with_cs stmt expr cs = 
  Utils.callstack_backtrack eval_expr eval_thread stmt expr cs
*)

let eval_expr_in_context context expr = 
  !Db.Value.eval_expr context expr
  |> Eva_wrapper.simplify_state

let eval_fn_call stmt expr =
  try
    let name = Format.asprintf "%a" Printer.pp_exp expr in
    let cil_fn = Globals.Functions.find_by_name name in
    match cil_fn.fundec with 
    | Definition (fundec, _) -> [fundec]
    | Declaration _ -> [] (* Nothing to analyze *)
  
  (* Function pointers *)
  with Not_found -> eval_fn_pointer stmt expr
 
(* Find all functions matching signature void * -> void *
   such functions should not be so common so they could be approximated as threads. *)
let fns_matching_thread_sig () =
 CFG_utils.all_fundecs_predicate 
    (fun kf ->
      let return_type = Kernel_function.get_return_type kf in
      let formals = Kernel_function.get_formals kf in
      Cil.isVoidPtrType return_type
      && (List.length formals) = 1
      && Cil.isVoidPtrType (List.hd formals).vtype
    )

let get_created_threads stmt =
  let thread_expr = Conc_model.thread_create_entry_point stmt in
  let thread_vals = eval_expr stmt thread_expr in
  let globals, arg = get_stmt_state_with_arg stmt in
  try 
    List.fold_right
      (fun (v, _) acc ->
        Thread.create (Stmts.fundec_from_varinfo v) globals arg :: acc
      ) thread_vals []

  with Not_found -> (* Can happen only when not using EVA for create wrappers *)
    assert (not !using_eva);
    let threads = fns_matching_thread_sig () in
    List.fold_right (fun fn acc -> Thread.create fn globals arg :: acc) threads []

let save_thread_state thread = 
  let current_thread = get_active_thread () |> Option.get in
  set_active_thread thread;
  let project = Project.current () in
  let filepath = Filepath.Normalized.of_string (Thread.to_string thread) in
  Project.save ~project:project filepath;
  set_active_thread current_thread
