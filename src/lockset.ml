open Deadlock_options
open Deadlock_utils

module Lock = struct

      type t = 
        | Varinfo of (Cil_types.varinfo * int * Callstack.t)
        | Name of (string * Callstack.t)

      let to_string = function
        | Varinfo (var, 0, _) -> Format.asprintf "%a" Printer.pp_varinfo var
        | Varinfo (var, offset, _) -> Format.asprintf "%a[%d]" Printer.pp_varinfo var offset 
        | Name (str, _) -> Format.asprintf "%s" str
      
      let compare lock1 lock2 = match lock1, lock2 with
        | Varinfo (var1, offset1, _), Varinfo (var2, offset2, _) -> 
          Pervasives.compare (var1, offset1) (var2, offset2)
        | Name (str, _), Name (str2, _) -> 
          Pervasives.compare str str2

      let get_trace = function
        | Varinfo (_, _, trace) -> trace
        | Name (_, trace) -> trace

      let equal l1 l2 = match l1, l2 with
        | Varinfo (var1, offset1, _), 
          Varinfo (var2, offset2, _) -> (var1 == var2) && (offset1 = offset2)
        | Name str1, Name str2 -> Pervasives.(==) str1 str2

      let hash = function
        | Varinfo (var, offset, _) -> Hashtbl.hash (var, offset)
        | Name (str, _) -> Hashtbl.hash str
              
      let print lock = Self.result "%s" (to_string lock)

    end

module Deadlock = struct

  type t = {
    locks : Lock.t list;
    traces : Callstack.t list;
  }

  let get_involved_threads_str dl =
    let str = List.fold_right
      (fun (_, _, t1, t2) acc ->
         let trace = Callstack.join t1 t2 in
         let thread = Callstack.bottom trace in
         let str = Format.asprintf "%a" Printer.pp_fundec thread in
         str :: acc
      ) dl [] in
    String.concat " and " str 
      
  let edge_to_str l1 l2 = 
    let src = Lock.to_string l1 in
    let dst = Lock.to_string l2 in
    Format.asprintf "(%s -> %s)" src dst

  let to_string dl = 
      let threads_str = get_involved_threads_str dl in
      let str1 = Format.asprintf "Deadlock between threads %s:\n" threads_str in
      let deps = List.fold_right
          (fun (src, dst, trace1, trace2) acc ->
             let str = Format.asprintf "\nTrace of dependency %s:\n" (edge_to_str src dst) in
             let str2 = str ^ Callstack.to_string2 (trace1, trace2) in
             acc ^ str2
          ) dl "" in
      str1 ^ deps

  let print deadlock = Self.result "%s" (to_string deadlock)

end

module Lockset = struct
  include Set.Make(Lock)

  let to_list ls =
    fold
      (fun lock out_list ->
         lock :: out_list
      ) ls []

  let cartesian_product ls1 ls2 =
    let list1 = to_list ls1 in
    let list2 = to_list ls2 in
    let aux = List.map
        (fun lock1 ->
           List.map (fun lock2 -> (lock1, lock2)) list2
        ) list1 in
    List.flatten aux
    
  let to_string ls = 
    if is_empty ls then "{}" else 
      let str = fold
          (fun l str ->
             let new_str = Lock.to_string l in
             let sep = if str = "" then "" else ", " in
             String.concat ""  [str; new_str]
          ) ls "{" in
      String.concat "" [str; "}"]

  let print ls = Self.result "%s" (to_string ls)

end

module LocksetSet = struct
  include Set.Make
      (struct
        type t = Lockset.t
        let compare = Pervasives.compare
      end)

  let to_list lss =
    fold
      (fun ls out_list ->
         ls :: out_list
      ) lss []

  let to_string lss =
    if is_empty lss then "{}" else 
      let str = fold
          (fun ls str ->
             let new_str = Lockset.to_string ls in
             let sep = if str = "" then "" else ", " in
             String.concat sep [str; new_str]
          ) lss "{" in
      String.concat "" [str; "}"]

  let add_each ls1 ls2 = Lockset.fold
      (fun lock l ->
         union (singleton (Lockset.add lock ls1)) l
      ) ls2 empty

  let remove_each ls1 ls2 = Lockset.fold
      (fun lock l ->
         union (singleton (Lockset.remove lock ls1)) l
      ) ls2 empty

end
