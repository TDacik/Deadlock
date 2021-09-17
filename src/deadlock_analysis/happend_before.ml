(* Static happens before relation
 *
 * Author: Tomas Dacik (xdacik00@fit.vutbr.cz), 2021
 *)

open! Deadlock_top

open Trace_utils

let bound_cache = ref None

let callstack_bound () = match !bound_cache with
  | Some bound -> bound
  | None ->
    let fn = (fun stmt -> Conc_model.is_thread_create stmt || Conc_model.is_thread_join stmt) in
    let bound = CFG_utils.all_stmts_predicate fn
                |> List.map CFG_utils.max_depth
                |> List.fold_left (fun curr_max elem -> if elem > curr_max then elem else curr_max) 0
                |> (+) 1
    in
    bound_cache := Some bound;
    bound

let reduce_list callstacks =
  let bound = callstack_bound () in
  let compare = (fun (_, cs1) (_, cs2) -> Callstack.compare_abstr bound cs1 cs2) in
  List.sort_uniq compare callstacks

(* Does stmt1 precedes stmt2? *)
let stmt_precedes stmt1 stmt2 =
  let kf1 = Kernel_function.find_englobing_kf stmt1 in
  let kf2 = Kernel_function.find_englobing_kf stmt2 in
  if not @@ Kernel_function.equal kf1 kf2 then false
  else
    let ord1 = Stmts_graph.stmt_can_reach kf1 stmt1 stmt2 in
    let ord2 = Stmts_graph.stmt_can_reach kf1 stmt2 stmt1 in
    ord1 && not ord2

let rec happend_before_ callstack1 callstack2 = match callstack1, callstack2 with
  | [], [] -> false (* Identical callstacks, HB is irreflexive *)
  | _, _ ->
    let stmt1 = Callstack.top_stmt callstack1 in
    let stmt2 = Callstack.top_stmt callstack2 in
    if Stmt.equal stmt1 stmt2
    then happend_before_ (Callstack.pop callstack1) (Callstack.pop callstack2)
    else stmt_precedes stmt1 stmt2

let happend_before callstack1 callstack2 =
  let thread1 = Callstack.get_thread callstack1 in
  let thread2 = Callstack.get_thread callstack2 in
  if Thread.equal thread1 thread2 then
    let cs1 = Callstack.remove_guards callstack1 |> List.rev |> Callstack.pop in
    let cs2 = Callstack.remove_guards callstack2 |> List.rev |> Callstack.pop in
    happend_before_ cs1 cs2
  else false
