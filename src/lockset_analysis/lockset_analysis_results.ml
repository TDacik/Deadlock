(* Results of lockset analysis
 *
 * Author: Tomas Dacik (xdacik00@fit.vutbr.cz), 2020
 *)

open! Deadlock_top

open Cil_datatype

open Lock_types
open Trace_utils

module Function_status = struct

  type status =
    | Normal
    | Refined of Varinfo.t list * Varinfo.t list
    | Imprecise

  let status_compare s1 s2 = match s1, s2 with
    | Refined (cs1, ps1), Refined (cs2, ps2) ->
      let res = List.compare Varinfo.compare cs1 cs2 in
      if res <> 0 then res
      else List.compare Varinfo.compare ps1 ps2
    | _, _ -> Stdlib.compare s1 s2

  let status_join s1 s2 = match s1, s2 with
    | _, Imprecise -> Imprecise
    | Imprecise, _ -> Imprecise
    | Normal, x -> x
    | x, Normal -> x
    | Refined (cs1, ps1), Refined (cs2, ps2) -> Refined (cs1 @ cs2, ps1 @ ps2)

  module M = Fundec.Map

  type t = status M.t

  let compare m1 m2 = M.compare status_compare m1 m2

  let find fn map =
    try M.find fn map
    with Not_found -> Normal

  let empty = M.empty

  let add = M.add

  let filter_keys fn map =
    M.filter (fun key _ -> fn key) map
    |> M.bindings
    |> List.map fst

  let union m1 m2 = M.union (fun _ s1 s2 -> Some (status_join s1 s2)) m1 m2

  let is_normal map fn = match find fn map with
    | Normal -> true
    | _ -> false

  let is_imprecise map fn = match find fn map with
    | Imprecise -> true
    | _ -> false

  let is_context_sensitive map fn = match find fn map with
    | Refined ([], _) -> false
    | Refined (_, _) -> true
    | _ -> false

  let is_path_sensitive map fn = match find fn map with
    | Refined (_, []) -> false
    | Refined (_, _) -> true
    | _ -> false

  let pp_status fmt status = match status with
    | Normal -> Format.fprintf fmt "NORMAL"
    | Refined _ -> Format.fprintf fmt "REFINED"
    | Imprecise -> Format.fprintf fmt "IMPRECISE"

  let pp fmt = M.iter (fun fn status -> 
      Format.fprintf fmt "%a -> %a"
        Printer.pp_fundec fn
        pp_status status
    )
end

type t = {
  lockgraph : Lockgraph.t;
  lock_stmts : Stmt.Set.t;
  mutable imprecise_lock_stmts : Stmt.Set.t;
  function_status : Function_status.t;
  stmt_summaries : Stmt_summaries.t;
  function_summaries : Function_summaries.t;
}

let empty = {
  lockgraph = Lockgraph.empty;
  lock_stmts = Stmt.Set.empty;
  imprecise_lock_stmts = Stmt.Set.empty;
  function_status = Function_status.empty;
  stmt_summaries = Stmt_summaries.empty;
  function_summaries = Function_summaries.empty;
}

let join res1 res2 = {
  lockgraph = Lockgraph.union res1.lockgraph res2.lockgraph;
  lock_stmts = Stmt.Set.union res1.lock_stmts res2.lock_stmts;
  imprecise_lock_stmts = Stmt.Set.union res1.imprecise_lock_stmts res2.imprecise_lock_stmts;
  function_status = Function_status.union res1.function_status res2.function_status;
  stmt_summaries = Stmt_summaries.union res1.stmt_summaries res2.stmt_summaries;
  function_summaries = Function_summaries.union res1.function_summaries res2.function_summaries
}

let add_imprecise_stmt stmt res = 
  res.imprecise_lock_stmts <- Stmt.Set.add stmt res.imprecise_lock_stmts

(* ==== ==== *)

let is_precise results = Stmt.Set.is_empty results.imprecise_lock_stmts

let find_deadlocks results = Lockgraph.find_deadlocks results.lockgraph

let path_sensitive_fns results = 
  Function_status.filter_keys 
    (Function_status.is_path_sensitive results.function_status)
    results.function_status

let context_sensitive_fns results = 
  Function_status.filter_keys 
    (Function_status.is_context_sensitive results.function_status)
    results.function_status

let imprecise_fns results =
  Function_status.filter_keys 
    (Function_status.is_imprecise results.function_status)
    results.function_status

(* ==== Accessors ==== *)

let lockgraph results = results.lockgraph

let lock_stmts results = results.lock_stmts

let imprecise_lock_stmts results = results.imprecise_lock_stmts

let stmt_summaries results = results.stmt_summaries

let function_summaries results = results.function_summaries

(* ==== Statistics ==== *)

let nb_lock_stmts results = Stmt.Set.cardinal results.lock_stmts

let nb_imprecise_lock_stmts results = Stmt.Set.cardinal results.imprecise_lock_stmts

let nb_stmt_summaries results = Stmt_summaries.cardinal results.stmt_summaries

let nb_analysed_functions results = Function_summaries.nb_functions results.function_summaries

let avg_analyses_per_fn results = 
  let nb_summaries = Function_summaries.cardinal results.function_summaries in
  let nb_functions = nb_analysed_functions results in
  if nb_functions = 0 then 0.0
  else Float.of_int nb_summaries /. Float.of_int nb_functions

(** Printers **)

let pp fmt results = Lockgraph.pp_edges fmt results.lockgraph

let pp_stmt_summaries fmt results = Stmt_summaries.pp fmt results.stmt_summaries

let pp_fn_summaries fmt results = Function_summaries.pp fmt results.function_summaries

let pp_non_id_fn_summaries fmt results = 
  Stmt.Set.iter (fun s -> Format.fprintf fmt "%a" Print_utils.pp_loc s) results.lock_stmts;
  Function_summaries.pp_non_id fmt results.function_summaries

(***************************************************************************************)

(** Analysis of computed locksets  **)

let summaries_of_stmt res stmt = Stmt_summaries.summaries_of_stmt stmt res.stmt_summaries

let stmt_must_lockset stmt res = Stmt_summaries.stmt_must_lockset stmt res.stmt_summaries

let stmt_may_lockset stmt res = Stmt_summaries.stmt_may_lockset stmt res.stmt_summaries

let stmt_must_acquire stmt res = Stmt_summaries.stmt_must_acquire stmt res.stmt_summaries

let stmt_may_acquire stmt res = Stmt_summaries.stmt_may_acquire stmt res.stmt_summaries

let stmt_exit_must_lockset stmt res = Stmt_summaries.stmt_exit_must_lockset stmt res.stmt_summaries

(** Fundecs **)
let summaries_of_fn res fn = Function_summaries.summaries_of_fn res.function_summaries fn

let fn_must_lockset fn results =
  let locksets = Function_summaries.fold
    (fun (fundec, _) (lss, _) acc ->
       if Fundec.equal fn fundec then
         let must = LocksetSet.fold Lockset.inter lss (LocksetSet.choose lss) in
         must :: acc
       else acc
    ) results.function_summaries []
    in
    List.fold_right Lockset.inter locksets (List.hd locksets)

let fn_may_lockset fn results = 
  let locksets = Function_summaries.fold
    (fun (fundec, _) (lss, _) acc ->
       if Fundec.equal fn fundec then
         let must = LocksetSet.fold Lockset.union lss Lockset.empty in
         must :: acc
       else acc
    ) results.function_summaries []
    in
    List.fold_right Lockset.union locksets Lockset.empty

(*
let pp_function_summaries fmt results = 
  Format.fprintf fmt "%a" Function_summaries.pp results.function_summaries

let pp_interesting_fn_summs fmt results = 
  Format.fprintf fmt "%a" Function_summaries.pp_non_ids results.function_summaries

let pp_must_exit_locksets fmt results = 
  Stmt_summaries.iter
    (fun (stmt, _) _ ->
      Format.fprintf fmt "%a : %a\n"
        Printer.pp_stmt stmt 
        Lockset.pp (stmt_must_lockset stmt results)
    ) results.stmt_summaries
*)
