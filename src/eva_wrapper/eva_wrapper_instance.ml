(* Instance of wrapper that uses results computed by EVA
 *
 * Author: Tomas Dacik (xdacik00@fit.vutbr.cz), 2020
 *)

open! Deadlock_top

open Locations
open Cil_types

module AI = Abstract_interp

(* Cache of results computed by EVA *)
module Cache = Map.Make
    (struct
      type t = Thread.t
      let compare = Thread.compare_with_states
    end)

(* Imperative state *)

let using_eva = ref true
let active_thread = ref None
let cache = ref Cache.empty

let init () = !Db.Value.compute ()

let set_active_thread thread = 
  if Cache.mem thread !cache then
    let results = Cache.find thread !cache in
    active_thread := Some thread;
    Eva.Value_results.set_results results
  
  else if !active_thread = Some thread then ()
  
  else
    let entry_point = Thread.get_entry_point thread in
    let thread_name = Thread.to_string thread in
    let globals = Thread.get_globals thread in
    let args = Thread.get_args thread in
    
    Globals.set_entry_point thread_name false;
    Db.Value.globals_set_initial_state globals;

    if (List.length entry_point.sformals) = 1 && not (Thread.is_main thread) then
      Db.Value.fun_set_args [args]
    else ();

    active_thread := Some thread;
    !Db.Value.compute ();
    
    (* Store computed results *)
    let results = Eva.Value_results.get_results () in
    cache := Cache.add thread results !cache

let get_active_thread () = !active_thread

(* ==== Internal functions ==== *)

(** Simplification of Cvalue.State to pairs (varinfo, offset) *)
let simplify_state state = match state with
  | Location_Bytes.Top _ -> []
  | Location_Bytes.Map map ->
    Location_Bytes.M.fold
      (fun base offsets acc ->
        try
          let varinfo = Base.to_varinfo base in
          let integers = 
            try Ival.fold_int (fun i acc -> Integer.to_int i :: acc) offsets []
            with AI.Error_Top -> [0]
          in
          List.map (fun offset -> (varinfo, offset)) integers @ acc 
        with Base.Not_a_C_variable -> acc
      ) map []

(* ==== Implementation of wrapper signature ==== *)

let eval_expr_raw stmt expr =
  let kinstr = Cil_types.Kstmt stmt in
  !Db.Value.access_expr kinstr expr

let eval_expr stmt expr =
  let state = eval_expr_raw stmt expr in
  simplify_state state

let get_stmt_state ?(after=false) stmt = Db.Value.get_stmt_state ~after stmt

let eval_fn_pointer stmt expr =
  let kfs = Db.Value.call_to_kernel_function stmt in
  Kernel_function.Hptset.fold
      (fun kf acc ->
         try Kernel_function.get_definition kf :: acc
         with Kernel_function.No_Definition -> acc
      ) kfs []

(* ==== Inputs and outputs as provided by Frama-C ==== *)
(* TODO: static variables *)

let stmt_reads stmt = 
  let zone = !Db.Inputs.statement stmt in
  let kf = Kernel_function.find_englobing_kf stmt in
  let zone_kf_all = !Db.Inputs.get_internal kf in
  let zone_kf_ext = !Db.Inputs.get_external kf in
  zone

let stmt_writes stmt = 
  let zone = !Db.Outputs.statement stmt in
  let kf = Kernel_function.find_englobing_kf stmt in
  let zone_kf_all = !Db.Outputs.get_internal kf in
  let zone_kf_ext = !Db.Outputs.get_external kf in
  zone
  
let inputs fn = 
  let kf = Statement_utils.kernel_fn_from_fundec fn in 
  !Db.Inputs.get_internal kf

let outputs fn = 
  let kf = Statement_utils.kernel_fn_from_fundec fn in 
  !Db.Outputs.get_internal kf
