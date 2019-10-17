open Cil_types
open Deadlock_options

type stmt_type = 
  | Lock of Cil_types.exp
  | Unlock of Cil_types.exp
  | Call of Cil_types.fundec
  | Thread_create of Cil_types.exp * Cil_types.exp
  | Thread_join of Cil_types.exp
  | End_of_path
  | Other

let get_location stmt = match stmt.skind with
  | Instr i ->
    (match i with
     | Call (_, _, _, location) -> location
     | _ -> failwith ""
    )
  | _ -> failwith ""

let fundec_from_varinfo varinfo =
  let kernel_function = Globals.Functions.get varinfo in
  Kernel_function.get_definition kernel_function

let lock_fn = "pthread_mutex_lock"
let unlock_fn = "pthread_mutex_unlock"
let thread_create_fn = "pthread_create"
let thread_join_fn = "pthread_join"

let is_locking_fn fn = 
  let fn_name = Format.asprintf "%a" Printer.pp_exp fn in
  try
    let fn = Globals.Functions.find_def_by_name fn_name in
    let fundec = Kernel_function.get_definition fn in
    (fn_name = lock_fn) || Lock_wrappers.mem fundec
  with _ ->
    (fn_name = lock_fn)

let is_unlocking_fn fn =
  let fn_name = Format.asprintf "%a" Printer.pp_exp fn in
  try
    let fn = Globals.Functions.find_def_by_name fn_name in
    let fundec = Kernel_function.get_definition fn in
    (fn_name = unlock_fn) || Unlock_wrappers.mem fundec
  with _ ->
    (fn_name = unlock_fn)

let is_thread_create_fn fn =
  let fn_name = Format.asprintf "%a" Printer.pp_exp fn in
  let fundec = Globals.Functions.find_def_by_name fn_name in
  (fn_name = thread_create_fn)

let is_thread_join_fn fn = 
  let fn_name = Format.asprintf "%a" Printer.pp_exp fn in
  try
    let fundec = Globals.Functions.find_def_by_name fn_name in
    (fn_name = thread_join_fn)
  with _ ->
    (fn_name = thread_join_fn)

let recognize_fn fn_call = match fn_call with
  | (fn, arg) ->
    (
      let fn_name = Format.asprintf "%a" Printer.pp_exp fn in

      if (is_locking_fn fn) then 
        Lock (List.hd arg)    

      else if (is_unlocking_fn fn) then 
        Unlock (List.hd arg)

      else if (fn_name = thread_create_fn) then  
        Thread_create (List.nth arg 2, List.nth arg 3)

      else if (is_thread_join_fn fn) then
        Thread_join(List.hd arg)

      (*Other functions than lock/unlock *)
      else try
          let fn_cil = Globals.Functions.find_by_name fn_name in match fn_cil.fundec with
          | Definition (fundec, _) -> Call(fundec)
          | _ -> Other (*Call of library function *)
        with Not_found ->
          Other
    )

let stmt_type stmt = match stmt.skind with
  | Instr i -> (match i with
     | Call (_, fn, args, _) -> recognize_fn (fn,args)
     | _ -> Other 
    )
  | Return (_, _) -> End_of_path
  | _ -> Other
