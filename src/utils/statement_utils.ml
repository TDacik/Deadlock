(* Helper functions for manipulation with cil types
 *
 * Author: Tomas Dacik (xdacik00@fit.vutbr.cz), 2020
 *)

open Cil_types
open Cil_datatype

let are_in_same_kf stmt1 stmt2 =
  let kf1 = Kernel_function.find_englobing_kf stmt1 in
  let kf2 = Kernel_function.find_englobing_kf stmt2 in
  Kernel_function.equal kf1 kf2

let get_location_short stmt =
  let loc = Format.asprintf "%a" Printer.pp_location (Stmt.loc stmt) in
  let regex = Str.regexp "/" in
  let path = Str.split_delim regex loc in
  List.hd (List.rev path)

let fundec_from_varinfo varinfo =
  let kernel_function = Globals.Functions.get varinfo in
  Kernel_function.get_definition kernel_function

let kernel_fn_from_fundec fn =
  let name = Format.asprintf "%a" Printer.pp_fundec fn in
  Globals.Functions.find_by_name name

let find_englobing_fn stmt =
  Kernel_function.find_englobing_kf stmt
  |> Kernel_function.get_definition

let call_params stmt = match stmt.skind with
  | Instr instr -> 
    begin match instr with
      | Call (_, _, params, _) -> params
      | Local_init (_, init, _) -> 
        begin match init with
          | ConsInit (_, params, _) -> params
          | _ -> failwith "Not a call stmt"
        end
      | _ -> failwith "Not a call stmt"
    end
  | _ -> failwith "Not a call call"

let nth_call_param stmt position =
  let params = call_params stmt in
  List.nth params position

let nth_formal kf n = 
  let formals = Kernel_function.get_formals kf in
  List.nth formals n

let find_functions pred =
  Globals.Functions.fold
    (fun kf acc ->
      if pred kf then
        try 
          let fundec = Kernel_function.get_definition kf in
          fundec :: acc
        with _ -> acc
      else acc
    ) []

let guard_to_condition stmt = match stmt.skind with
  | If (exp, _, _, _) -> exp
  | Switch (exp, _, _, _) -> exp
  | _ -> failwith "Not a guard statement"

let is_exit_point stmt = match stmt.skind with
  | Return (_, _) -> true
  | Instr i -> begin match i with
      | Skip _ -> 
        begin match (List.hd stmt.succs).skind with
          | Return (_, _) -> true
          | _ -> false
        end
      | _ -> false
    end
  | _ -> false
