(* Modules for working with:
 * - locks
 * - locksets (sets of locks)
 * - lockset sets (sets of locksets)
 *
 * Author: Tomas Dacik (xdacik00@fit.vutbr.cz), 2020
 *)

open! Deadlock_top

open Trace_utils

module AI = Abstract_interp

module Lock = struct

  type t = {
    var : Cil_types.varinfo;
    offset : int;
    trace : Callstack.t
  }

  let create var offset trace = {
    var = var;
    offset = offset;
    trace = trace;
  }

  let get_varinfo lock = lock.var

  let get_address lock = (lock.var, lock.offset)

  let get_trace lock = lock.trace

  let origin_stmt lock = Callstack.get_action_stmt lock.trace
 
  let is_weak lock = lock.var.vformal || not lock.var.vglob

  (* TODO: local init *)
  let return_var lock =
    let stmt = origin_stmt lock in
    match stmt.skind with
    | Instr i -> begin match i with
        | Call (res, _, _, _) -> begin match res with
            | None -> None
            | Some (Var var, _) -> Some (Cil.evar var)
            | Some (Mem expr, _) -> Some expr
          end
        | _ -> None
      end
    | _ -> None
  
  let compare lock1 lock2 =
    let res = Varinfo.compare lock1.var lock2.var in
    if res <> 0 then res
    else Int.compare lock1.offset lock2.offset

  let equal lock1 lock2 = Int.equal (compare lock1 lock2) 0
  
  let hash lock = Hashtbl.hash (get_address lock)

  let update_trace lock new_trace = {lock with trace = new_trace}
  
  let pp fmt lock = 
    (*
    let singleton_itv = (AI.Int.of_int lock.offset, AI.Int.of_int lock.offset) in
    let singleton_interval = Int_Intervals.inject_itv singleton_itv in  
    Format.fprintf fmt "%a%a"
      Varinfo.pretty lock.var
      (Int_Intervals.pretty_typ (Some lock.var.vtype)) singleton_interval
    *)
    match lock.offset with
    | 0 -> Format.fprintf fmt "%a" Printer.pp_varinfo lock.var
    | i -> Format.fprintf fmt "%a[%d]" 
             Printer.pp_varinfo lock.var
             lock.offset
  
  let to_string lock = Format.asprintf "%a" pp lock

end

module Lockset = struct

  module S = Set.Make(Lock)

  module Map = Map.Make(S)

  include S

  let from_list l = List.fold_right add l empty
  
  let to_list ls = fold List.cons ls []

  let cartesian_product ls1 ls2 =
    let list1 = to_list ls1 in
    let list2 = to_list ls2 in
    let aux = List.map
        (fun lock1 ->
           List.map (fun lock2 -> (lock1, lock2)) list2
        ) list1 in
    List.flatten aux

  let are_disjoint ls1 ls2 = is_empty (inter ls1 ls2)
    
  let to_string ls =
    if is_empty ls then "{}" else
      let str = fold
          (fun l str ->
             let new_str = Lock.to_string l in
             let sep = if str = "{" then "" else ", " in
             String.concat sep [str; new_str]
          ) ls "{" in
      String.concat "" [str; "}"]

  let pp fmt ls = Format.fprintf fmt "%s" (to_string ls)

end

module LocksetSet = struct

  include Set.Make(Lockset)

  exception Empty_intersection

  let from_list l = List.fold_right union l empty

  let singletons_from_list l = 
    List.fold_right 
      (fun l acc -> 
         let ls = Lockset.singleton l in
         union acc (singleton ls)
      ) l empty

  let to_list lss = fold (fun ls acc -> ls :: acc) lss []

  let map_locks f lss =
    map (fun ls -> Lockset.map (fun lock -> f lock) ls) lss

  let add_each ls1 ls2 = 
    if Lockset.is_empty ls2 then singleton ls1
    else Lockset.fold
        (fun lock lss ->
           union (singleton (Lockset.add lock ls1)) lss
        ) ls2 empty

  let remove_each ls1 ls2 = 
    if Lockset.is_empty ls2 then singleton ls1
    else Lockset.fold
      (fun lock acc ->
         union (singleton (Lockset.remove lock ls1)) acc
      ) ls2 empty

  (* Union of all elements *)
  let elems_union lss = fold Lockset.union lss Lockset.empty

  (* Intersection of all elements *)
  let elems_inter lss = 
    if is_empty lss then raise Empty_intersection
    else fold Lockset.inter lss (choose lss)

  let to_string lss =
    if is_empty lss then "{}" else
      let str = fold
          (fun ls str ->
             let new_str = Lockset.to_string ls in
             let sep = if str = "{" then "" else ", " in
             String.concat sep [str; new_str]
          ) lss "{" in
      String.concat "" [str; "}"]

  let pp fmt lss = Format.fprintf fmt "%s" (to_string lss)

end
