(** Functions for abstraction refinement of the lockset analysis
 *
 * Author: Tomas Dacik
 *)

open !Deadlock_top

open Cil_types
open Trace_utils

open Locations

module Stmts = Statement_utils

(** For function fn called at stmt return expression at this statement, that represents
    value of formal_param *)
let get_actual_expr fn stmt formal_param =
  let kf = Stmts.kernel_fn_from_fundec fn in
  let position = Kernel_function.get_formal_position formal_param kf in
  Stmts.nth_call_param stmt position

let relevant_expr expr =
  let variables = Cil.extract_varinfos_from_exp expr in
  let var = Varinfo.Set.choose variables in
  if var.vformal then Some var
  else None

let lmap_to_map = function
  | Cvalue.Model.Top | Cvalue.Model.Bottom -> None 
  | Cvalue.Model.Map map -> Some map

(** Base is relevant if it is statically or dynamically variable of type that contains a lock *)
let base_is_relevant base = match base with
  | Base.Var (var, _) | Base.Allocated (var, _, _) ->
    Concurrency_model.is_lock_type_rec var.vtype
  | _ -> false

let offsetmap_to_bases map = 
  Cvalue.V_Offsetmap.fold_on_values List.cons map []
  |> List.map Cvalue.V_Or_Uninitialized.get_v
  |> List.map (fun lb -> Location_Bytes.fold_bases List.cons lb [])
  |> List.concat
  |> List.filter base_is_relevant

let rec extract bases state =
  match lmap_to_map state with
  | Some map ->
    Cvalue.Model.fold
      (fun base offsetmap acc -> 
         if List.mem ~eq:Base.equal base bases then 
           let bases' = offsetmap_to_bases offsetmap in
           let model = extract bases' state in
           Cvalue.Model.add_base base offsetmap acc
           |> Cvalue.Model.merge ~into:model
         else acc
      ) map Cvalue.Model.empty_map
  | None -> Cvalue.Model.empty_map

let extract_minimal_context stmt binding context =
  let bases = Cvalue.V.fold_bases (fun b acc -> b :: acc) binding [] in
  match bases with
  | base :: _ -> extract [base] context
  | _ -> Cvalue.Model.empty_map
  

let rec find_actual_lock_ callstack formal_param formal_param_list =
  let fn, callsite = Callstack.top_call callstack in
  
  let expr = get_actual_expr fn callsite formal_param in
  
  (* TODO: *)
  let variables = Cil.extract_varinfos_from_exp expr in
  let var = Varinfo.Set.choose variables in

  (* If variable is still formal, continue deeper *)
  if var.vformal then
    let callstack = Callstack.pop_call callstack in
    let params = var :: formal_param_list in
    find_actual_lock_ callstack var params

  (* When we find some concrete value, create a minimal context of it *)
  else
    let value = Eva_wrapper.eval_expr_raw callsite expr in
    let context = Eva_wrapper.get_stmt_state callsite in
    let minimal_context = extract_minimal_context callsite value context in
    (value, minimal_context, formal_param_list)

let find_actual_lock callstack formal_param =
  let binding, context, formal_params = find_actual_lock_ callstack formal_param [formal_param] in
  let res = List.fold_left
      (fun acc formal ->
         let location = Locations.loc_of_varinfo formal in
         Cvalue.Model.add_binding ~exact:true acc location binding
      ) context formal_params
  in
  (formal_params, res)

let get_top_guard_exprs callstack =
  let fn = Callstack.top_call_fn callstack in
  CFG_utils.all_stmts_in_fn_predicate Statement_utils.is_guard fn
  |> List.map Statement_utils.guard_to_condition

(* ==== Extraction of pure inputs ==== *)

(*
let pure_calling_state callstack =
  let fn, callsite = Callstack.top_call callstack in
  let kf = Statement_utils.kernel_fn_from_fundec fn in
  let formals = Kernel_function.get_formals kf in
  List.fold_left
    (fun acc formal ->
      
    ) Cvalue.Model.empty_map formals
*)
    (*
let extract_pure_inputs callstack =
  let pure_calling_state = create_pure_calling_state callstack in
  let guard_exprs = get_top_guard_exprs callstack in
*)
let create_calling_context callstack =
  let fn, callsite = Callstack.top_call callstack in
  let kf = Statement_utils.kernel_fn_from_fundec fn in
  let formals = Kernel_function.get_formals kf in
  let pure_vars = Eva_wrapper.pure_inputs fn in
  let guards = get_top_guard_exprs callstack in
  List.fold_left
    (fun acc var ->
       let index = Kernel_function.get_formal_position var kf in
       let expr = Statement_utils.nth_call_param callsite index in
       let location = Locations.loc_of_varinfo var in
       let const = Cil.constFoldToInt expr in
       (* Add only singleton values *)
       if Option.is_some const 
          && not @@ Concurrency_model.is_lock_type_rec var.vtype 
          && List.exists (Cil.appears_in_expr var) guards
          && Base.Set.mem (Base.of_varinfo var) pure_vars
       then 
         let value = Cvalue.V.inject_int (Option.get const) in
         Cvalue.Model.add_binding ~exact:true acc location value
       else acc
    ) Cvalue.Model.empty_map formals

(* Extract non-locks pure inputs of function at callsite *)
let extract_pure_inputs callstack =
  let context = create_calling_context callstack in
  let guards = get_top_guard_exprs callstack in
  let pure_vars =
    Cvalue.Model.fold (fun b _ acc -> b :: acc) (Option.get @@ lmap_to_map context) []
    |> List.map Base.to_varinfo
    |> List.filter (fun v -> not @@ Concurrency_model.is_lock_type_rec v.vtype)
    |> List.filter (fun v -> List.exists (Cil.appears_in_expr v) guards)
  in
  pure_vars, context
