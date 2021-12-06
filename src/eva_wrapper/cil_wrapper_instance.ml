(* Instance of wrapper that uses only syntactic functions provided by CIL API
 *
 * Author: Tomas Dacik (xdacik00@fit.vutbr.cz), 2020
 *
 * TODO: simplify extraction of reads & writes
 *)

open! Deadlock_top

open Locations
open Cil_types
open Cil_datatype

module AI = Abstract_interp
module Utils = Eva_wrapper_utils

let using_eva = ref false
let active_thread : Thread.t option ref = ref None

let init () = ()

let set_active_thread thread = 
  active_thread := Some thread

let get_active_thread () = !active_thread

let eval_expr stmt exp =
  Cil.extract_varinfos_from_exp exp
  |> Varinfo.Set.filter (fun var -> not @@ Cil.isArithmeticType var.vtype)
  |> Varinfo.Set.elements
  |> List.map (fun var -> (var, 0))

(* Extract all bases from given expression *)
let expr_to_zone expr =
  let interval = (AI.Int.zero, AI.Int.zero) in
  let zero_interval = Int_Intervals.inject_itv interval in
  Cil.extract_varinfos_from_exp expr
  |> Varinfo.Set.elements
  |> List.map Base.of_varinfo
  |> List.fold_left 
    (fun zone b -> 
      let zone' = Zone.inject b zero_interval in
      Zone.join zone zone'  
    ) Zone.bottom

let eval_expr_raw stmt expr =
  let bases = expr_to_zone expr |> Utils.zone_to_bases in
  List.fold_left 
    (fun acc base ->
       Cvalue.V.add base Ival.zero acc
    ) Cvalue.V.bottom bases

let get_stmt_state ?(after=false) _ = Cvalue.Model.top

(* TODO: Find all functions that are assigned in program *)
let eval_fn_pointer stmt expr = []

(* ==== Inputs & Outputs ==== *)

(** Extract all bases from given expression *)
let extract_bases expr =
  let vars = Cil.extract_varinfos_from_exp expr in
  Varinfo.Set.fold (fun var acc -> Base.of_varinfo var :: acc) vars []

let rec expr_to_zone ?(top_offset=false) expr = match expr.enode with
  | Lval lval
  | AddrOf lval -> lval_to_zone lval
  
  (* Continue to sub-expression *)
  | SizeOfE (e) 
  | AlignOfE (e) 
  | CastE (_, e)
  | UnOp (_, e, _)
  | Info (e, _) -> expr_to_zone ~top_offset e
 
  | BinOp (_, e1, e2, _) ->
    let z1 = expr_to_zone ~top_offset e1 in
    let z2 = expr_to_zone ~top_offset e2 in
    Zone.join z1 z2

  | _ ->
    let interval = 
      if top_offset then Int_Intervals.top 
      else Int_Intervals.inject_itv (AI.Int.zero, AI.Int.zero)
    in
    Cil.extract_varinfos_from_exp expr
    |> Varinfo.Set.elements
    |> List.map Base.of_varinfo
    |> List.fold_left 
      (fun zone b -> 
         let zone' = Zone.inject b interval in
         Zone.join zone zone'  
      ) Zone.bottom

and get_index_offset expr = match expr.enode with
  | Const c -> begin match c with
      | CInt64 (value, _, _) -> (value, value)
      | _ -> (AI.Int.zero, AI.Int.max_int64)
    end
  | _ -> (AI.Int.zero, AI.Int.max_int64)

and get_field_interval fieldinfo = 
  let x, y = Cil.fieldBitsOffset fieldinfo in
  (* Do not include the last bit *)
  (AI.Int.of_int x, AI.Int.of_int (x+y - 1))

and handle_offset offset = match offset with
  | NoOffset -> 
    (AI.Int.zero, AI.Int.zero)
  | Field (fieldinfo, _) -> 
    get_field_interval fieldinfo
  | Index (expr, _) -> 
    get_index_offset expr

and lval_to_zone lval =   
  match lval with
  | (lhost, offset) -> match lhost with
    | Var varinfo -> 
      let interval = handle_offset offset in
      let interval = Int_Intervals.inject_itv interval in
      let base = Base.of_varinfo varinfo in
      Zone.inject base interval
    
    (* Pointer arithmetic *)
    | Mem expr -> 
      begin match expr.enode with
        | Const _ | Lval _ -> expr_to_zone expr
        | _ -> expr_to_zone ~top_offset:true expr
      end

let fn_io fn how_to_get =
  List.fold_left (fun zone stmt -> Zone.join zone (how_to_get stmt)) Zone.bottom fn.sallstmts

let _stmt_writes stmt = match stmt.skind with
  | Instr instr -> begin match instr with
      | Set (lval, _, _) -> lval_to_zone lval
      | Call (lval_opt, _, _, _) -> begin match lval_opt with
          | Some lval -> lval_to_zone lval
          | None -> Zone.bottom
        end
      | Local_init (var, _, _) -> 
        let base = Base.of_varinfo var in
        let interval = (AI.Int.zero, AI.Int.zero) in
        let zero_interval = Int_Intervals.inject_itv interval in
        Zone.inject base zero_interval
      | _ -> Zone.bottom
    end
  | _ -> Zone.bottom

let _stmt_reads stmt = 
  let expressions = match stmt.skind with
  | Instr instr -> begin match instr with
      | Set (_, expr, _) -> [expr]
      | Call (_, _, expr_list, _) -> expr_list
      | Local_init (_, local_init, _) -> begin match local_init with
          | AssignInit init -> begin match init with
              | SingleInit expr -> [expr]
              | CompoundInit _ -> [] (* TODO *)
            end
          | ConsInit (_, expr_list, _) -> expr_list
        end
      | _ -> [] (*TODO *)
    end
  
  | If (expr, _, _, _) -> [expr]
  | Switch (expr, _, _, _) -> [expr]
  | Return (expr, _) -> begin match expr with
      | Some expr -> [expr] 
      | None -> []
    end
  | _ -> []
  in List.fold_left 
    (fun acc expr -> (Zone.join acc) @@ expr_to_zone expr) Zone.bottom expressions

let stmt_reads stmt =
  let res = _stmt_reads stmt in
  res

let stmt_writes stmt =
  let res = _stmt_writes stmt in
  res

let inputs fn = fn_io fn stmt_reads

let outputs fn = fn_io fn stmt_writes
