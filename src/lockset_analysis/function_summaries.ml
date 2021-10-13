(* Top-down summaries for caching results of lockset analysis. 
 * Summaries are of form:
 *
 *  (thread, lockset, context) -> (set of locksets, lockgraph)
 *
 *  Author: Tomas Dacik (xdacik00@fit.vutbr.cz), 2020
 *)

open! Deadlock_top

open Lock_types
open Trace_utils

module Stmts = Statement_utils

type precondition = Thread.t * Lockset.t * Cvalue.Model.t

type postcondition = LocksetSet.t * Lockgraph.t

let precondition_compare (thread1, lockset1, context1) (thread2, lockset2, context2) =
  let res1 = Thread.compare_states thread1 thread2 in
  if res1 <> 0 then res1
  else
    let res2 = Lockset.compare lockset1 lockset2 in
    if res2 <> 0 then res2
    else Cvalue.Model.compare context1 context2

(* Summary is mapping (fn, precondition) -> postcondtion *)
module Summaries = Map.Make
    (struct
      type t = Cil_types.fundec * precondition
      let compare (fn1, pre1) (fn2, pre2) =
        if Fundec.compare fn1 fn2 <> 0 then Fundec.compare fn1 fn2
        else precondition_compare pre1 pre2
    end)

include Summaries

type key = Cil_types.fundec * precondition
type data = postcondition
type t = postcondition Summaries.t
type 'a _t = 'a Summaries.t

let union map1 map2 =
  union 
    (fun _ (lss1, g1) (lss2, g2) ->
       let lss = LocksetSet.union lss1 lss2 in
       let graph = Lockgraph.union g1 g2 in
       Some (lss, graph)
    ) map1 map2

(* Return list of all functions such that there exists their summary satisfying predicate *)
let filter_functions predicate map =
  let set =
    fold (fun (fn, pre) post acc -> 
      if predicate pre post then Fundec.Set.add fn acc
      else acc
    ) map Fundec.Set.empty
  in
  Fundec.Set.fold List.cons set []

(* === Manipulation with summaries' entries ==== *)

(* Entry is identity if exit lockset = {entry lockset} and created lockgraph is empty *)
let entry_is_identity (pre, pos) =
  let _, ls, _ = pre in
  let lss, g = pos in
  LocksetSet.equal (LocksetSet.singleton ls) lss
  && Lockgraph.is_empty g

let summary_is_identity (fn, pre) cache =
  let _, ls, _ = pre in
  let lss, g = find (fn, pre) cache in
  LocksetSet.equal (LocksetSet.singleton ls) lss
  && Lockgraph.is_empty g

(* Function is identity if all its entries are identities *)
let fn_is_identity fn summaries =
  filter (fun (fn2, _) _ -> Fundec.equal fn fn2) summaries
  |> for_all (fun (_, pre) post -> entry_is_identity (pre, post))

let non_id_summaries summaries =
  filter (fun (fn, _) _ -> not (fn_is_identity fn summaries)) summaries

(** Queries **)

let summaries_of_fn map fn =
  filter_map (fun (fn', pre) post ->
    if Fundec.equal fn fn' then Some post
    else None
  ) map

(* ==== Statistics ==== *)

let nb_functions map =
  fold (fun (fn, _) _ acc -> Fundec.Set.add fn acc) map Fundec.Set.empty
  |> Fundec.Set.cardinal

(* ==== Pretty printers ==== *)

let pp_entry fmt (fn, pre) post =
  let thread, ls, context = pre in
  let lss, graph = post in
  if Cvalue.Model.is_empty_map context then
    Format.fprintf fmt "(%a, %a, %a) ↦ (%a, %d)\n"
      Thread.pp thread
      Printer.pp_fundec fn
      Lockset.pp ls
      LocksetSet.pp lss
      (Lockgraph.nb_edges graph)
  else
    Format.fprintf fmt "(%a, %a, %a, {%a}) ↦ (%a, %d)\n"
      Thread.pp thread
      Printer.pp_fundec fn
      Lockset.pp ls
      Cvalue.Model.pretty context
      LocksetSet.pp lss
      (Lockgraph.nb_edges graph)

let pp fmt = iter (pp_entry fmt)

let pp_non_id fmt summaries =
  let filtered = non_id_summaries summaries in
  pp fmt filtered
