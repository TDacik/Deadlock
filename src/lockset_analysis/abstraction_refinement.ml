(** Functions for abstraction refinement of the lockset analysis
 *
 * Author: Tomas Dacik
 *)

open !Deadlock_top

open Cil_types
open Trace_utils

open Locations

module Stmts = Statement_utils

let get_binding fn stmt formal_param =
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

let base_is_relevant base = match base with
  | Base.Var (var, _)  -> Concurrency_model.is_lock_type_rec var.vtype
  | Base.Allocated _ -> true
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
    let base = List.hd (Cvalue.V.fold_bases (fun b acc -> b :: acc) binding []) in
    extract [base] context
  
let rec find_binding_ callstack formal_param formal_param_list =
  let top_call, callsite = Callstack.top_call callstack in
  let binding_expr = get_binding top_call callsite formal_param in
  
  (* TODO: *)
  let variables = Cil.extract_varinfos_from_exp binding_expr in
  let var = Varinfo.Set.choose variables in

  if var.vformal then
    let callstack = Callstack.pop callstack in
    let params = var :: formal_param_list in
    find_binding_ callstack var params
  else
    let value = Eva_wrapper.eval_expr_raw callsite binding_expr in
    let context = Eva_wrapper.get_stmt_state callsite in
    let context = extract_minimal_context callsite value context in
    (value, context, formal_param_list)

let find_binding callstack formal_param =
  let binding, context, formal_params = find_binding_ callstack formal_param [formal_param] in
  let res = List.fold_left
      (fun acc formal ->
         let location = Locations.loc_of_varinfo formal in
         Cvalue.Model.add_binding ~exact:true acc location binding
      ) context formal_params
  in
  (formal_params, res)

(* ==== Extraction of pure inputs ==== *)

let create_calling_context fn callsite =
  let kf = Statement_utils.kernel_fn_from_fundec fn in
  let formals = Kernel_function.get_formals kf in
  List.fold_left
    (fun acc var ->
       let index = Kernel_function.get_formal_position var kf in
       let expr = Statement_utils.nth_call_param callsite index in
       let location = Locations.loc_of_varinfo var in
       let const = Cil.constFoldToInt expr in
       (* Add only singleton values *)
       if Option.is_some const && not @@ Concurrency_model.is_lock_type_rec var.vtype then 
         let value = Cvalue.V.inject_int (Option.get const) in
         Cvalue.Model.add_binding ~exact:true acc location value
       else acc
    ) Cvalue.Model.empty_map formals

(* Extract non-locks pure inputs of function at callsite *)
let extract_pure_inputs fn callsite =
  let context = create_calling_context fn callsite in
  let pure_vars =
    Cvalue.Model.fold (fun b _ acc -> b :: acc) (Option.get @@ lmap_to_map context) []               
    |> List.map Base.to_varinfo
    |> List.filter (fun v -> not @@ Concurrency_model.is_lock_type_rec v.vtype)
  in
  pure_vars, context
