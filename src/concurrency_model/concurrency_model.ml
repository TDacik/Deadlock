(* Functions over conccurency model.
 *
 * Author: Tomas Dacik (xdacik00@fit.vutbr.cz), 2021
 *)

open Cil_datatype
open Concurrency_model_data

module Stmts = Statement_utils

type stmt =
  | Lock of Cil_types.exp
  | Unlock of Cil_types.exp
  | Lock_init of Cil_types.exp
  | Lock_destroy of Cil_types.exp
  | Condition_wait of Cil_types.exp * Cil_types.exp
  | Thread_create of Cil_types.exp * Cil_types.exp * Cil_types.exp
  | Thread_join of Cil_types.exp
  | Call of Cil_types.exp * Cil_types.exp list
  | End_of_path
  | Other

let classify_call fn args =
  let fn_name = Format.asprintf "%a" Printer.pp_exp fn in

  if Lock_functions.mem fn_name then
    let [lock_pos] = Lock_functions.find fn_name in
    Lock (List.nth args lock_pos)

  else if Nonblocking_lock_functions.mem fn_name then
    let [lock_pos] = Nonblocking_lock_functions.find fn_name in
    Lock (List.nth args lock_pos)

  else if Unlock_functions.mem fn_name then
    let [lock_pos] = Unlock_functions.find fn_name in
    Unlock (List.nth args lock_pos)

  else if Lock_init_functions.mem fn_name then
    let [lock_pos] = Lock_init_functions.find fn_name in
    Lock_init (List.nth args lock_pos)

  else if Lock_destroy_functions.mem fn_name then
    let [lock_pos] = Lock_destroy_functions.find fn_name in
    Lock_destroy (List.nth args lock_pos)

  else if Condition_wait_functions.mem fn_name then
    let [cond_pos; lock_pos] = Condition_wait_functions.find fn_name in
    let cond = List.nth args cond_pos in
    let lock = List.nth args lock_pos in
    Condition_wait (cond, lock)

  else if Thread_create_functions.mem fn_name then
    let [id_pos; thread_pos; arg_pos] = Thread_create_functions.find fn_name in
    let id = List.nth args id_pos in
    let thread = List.nth args thread_pos in
    let arg = List.nth args arg_pos in
    Thread_create (id, thread, arg)

  else if Thread_join_functions.mem fn_name then
    let [id_pos] = Thread_join_functions.find fn_name in
    Thread_join (List.nth args id_pos)

  else Call (fn, args)

open Cil_types

let classify_instr instr = match instr with
  | Call (_, fn, args, _) -> classify_call fn args
  | Local_init (_, init, _) ->
    begin match init with
    | AssignInit _ -> Other
    | ConsInit (varinfo, args, _) -> 
      let fn = Cil.evar varinfo in
      classify_call fn args
    end
  | _ -> Other

let classify_stmt stmt = match stmt.skind with
  | Instr instr -> classify_instr instr
  | Return _ -> End_of_path
  | _ -> Other

(* API *)

let is_lock_type type_name = Lock_types.mem type_name

(* Does given type (e.g., array, struct, ...) recursively contain a lock type *)
let is_lock_type_rec =
  let rec recursive_scan = function
    | TNamed (typeinfo, _) ->
      if is_lock_type typeinfo.tname
      then Cil.ExistsTrue
      else Cil.ExistsMaybe (* recursive call *)
    
    (* Structure or union without name *)
    | TComp (compinfo, _, _) -> 
      if is_lock_type compinfo.corig_name
      then Cil.ExistsTrue
      else Cil.ExistsMaybe (* recursive call *)
    
    | _ -> Cil.ExistsMaybe
  in
  Cil.existsType recursive_scan

let fn_lock_params fn =
  let kf = Stmts.kernel_fn_from_fundec fn in
  let formals = Kernel_function.get_formals kf in
  List.find_all (fun var -> is_lock_type_rec var.vtype) formals

let is_lock stmt = match classify_stmt stmt with
  | Lock _ -> true
  | _ -> false

let is_unlock stmt = match classify_stmt stmt with
  | Unlock _ -> true
  | _ -> false

let is_lock_init stmt = match classify_stmt stmt with
  | Lock_init _ -> true
  | _ -> false

let is_lock_destroy stmt = match classify_stmt stmt with
  | Lock_destroy _ -> true
  | _ -> false

let is_condition_wait stmt = match classify_stmt stmt with
  | Condition_wait _ -> true
  | _ -> false

let is_thread_create stmt = match classify_stmt stmt with
  | Thread_create _ -> true
  | _ -> false

let is_thread_join stmt = match classify_stmt stmt with
  | Thread_join _ -> true
  | _ -> false

let thread_create_id stmt = match classify_stmt stmt with
  | Thread_create (id,  _, _) -> match id.enode with
    | AddrOf lval -> lval
    | StartOf lval -> lval
    | Lval lval -> lval
    | _ -> (Mem (id) , NoOffset) (*TODO: Dummy lval *)
  | _ -> failwith "Not thread create statement"

let thread_create_entry_point stmt = match classify_stmt stmt with
  | Thread_create (_, fn, _) -> fn
  | _ -> failwith "Not thread create statement"

let thread_create_arg stmt = match classify_stmt stmt with
  | Thread_create (_, _, arg) -> arg
  | _ -> failwith "Not thread create statement"

let thread_join_id stmt = match classify_stmt stmt with
  | Thread_join id -> match id.enode with
    | Lval (host, offset) -> match offset with
      | Index (exp, _) -> 
        if Cil.isZero exp then (host, NoOffset)
        else (host, offset)
      | _ -> (host, offset)
  | _ -> failwith "Not thread join statement"
