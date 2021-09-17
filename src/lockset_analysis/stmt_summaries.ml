(* Lockset summaries for single statements. Unlike function summaries, statement summaries
 * are not used for caching in generic CFA analysis. They only store the results of lockset 
 * analysis. Statement precondition is same as function summary precondition. Postcondition
 * is only statement's exit set of locksets. 
 *
 * Summary is non-trivial only for lock operations and calls, otherwise it allways has form
 * entry_lockset -> {entry_lockset}. 
 *
 * Author: Tomas Dacik (xdacik00@fit.vutbr.cz), 2020
 *)

open Lock_types
open Cil_datatype

(* Precondition of statement is always inherited from its englobing function *)
type precondition = Function_summaries.precondition

type postcondition = LocksetSet.t

module Summaries = Map.Make
    (struct
      type t = Cil_types.stmt * precondition
      let compare (s1, pre1) (s2, pre2) =
        let aux = Stmt.compare s1 s2 in
        if aux <> 0 then aux
        else Function_summaries.precondition_compare pre1 pre2
    end)

include Summaries

type key = Cil_types.stmt * precondition
type data = postcondition

type t = postcondition Summaries.t
type 'a _t = 'a Summaries.t

let union map1 map2 = fold add map1 map2

(* ==== Queries over computed summaries ==== *)

let find_imprecise_lock_stmts map =
  fold 
    (fun (stmt, _) lss acc ->
      if (LocksetSet.cardinal lss) > 2
      then Stmt.Set.add stmt acc
      else acc
    ) map Stmt.Set.empty

(* Subset of map containing only statement and all its preconditions *)
let summaries_of_stmt stmt map =
  filter_map
    (fun (stmt', pre) post ->
       if Stmt.equal stmt stmt' then Some post
       else None
    ) map

(* must-lockset is intersection of all preconditions *)
let stmt_must_lockset stmt map =
  let summaries = summaries_of_stmt stmt map in
  let ls =
    try match fst (choose summaries) with (_, (_, ls, _)) -> ls
    with Not_found -> Lockset.empty
  in
  fold (fun (_, (_, ls, _)) _ acc -> Lockset.inter ls acc) summaries ls

(* may-lockset is union of all preconditions *)
let stmt_may_lockset stmt map =
  let summaries = summaries_of_stmt stmt map in
  fold (fun (_, (_, ls, _)) _ acc -> Lockset.union ls acc) summaries Lockset.empty

let stmt_exit_may_lockset stmt map =
  let summaries = summaries_of_stmt stmt map in
  fold (fun (_, (_, _, _)) lss acc -> LocksetSet.union lss acc) summaries LocksetSet.empty
  |> LocksetSet.elems_union

let stmt_exit_must_lockset stmt map =
  let summaries = summaries_of_stmt stmt map in
  fold (fun (_, (_, _, _)) lss acc -> LocksetSet.union lss acc) summaries LocksetSet.empty
  |> LocksetSet.elems_inter

let stmt_may_acquire stmt map =
  let inputs = stmt_may_lockset stmt map in
  let outputs = stmt_must_lockset stmt map in
  Lockset.diff outputs inputs

let stmt_must_acquire stmt map =
  let inputs = stmt_must_lockset stmt map in
  let outputs = stmt_may_lockset stmt map in
  Lockset.filter (fun lock -> not (Lockset.mem lock outputs)) inputs

let pp_entry fmt (stmt, (_, ls, _), lss) =
  Format.fprintf fmt "(%a, %a) ↦  %a\n"
  Print_utils.pp_loc stmt
  Lockset.pp ls
  LocksetSet.pp lss

let pp fmt map = iter (fun (stmt, pre) lss -> pp_entry fmt (stmt, pre, lss)) map
