(* Toplevel definitions for unit tests *)
include OUnit2
include Deadlock_options

include Deadlock_stubs
include Cil_stubs

include Cil_datatype

open Trace_utils
open Lock_types
open Cil_types

module List = CCList

let assert_equal_int = assert_equal ~cmp:Int.equal ~printer:(Format.asprintf "%d")

let assert_equal_callstacks = assert_equal ~cmp:Callstack.equal ~printer:Callstack.to_string

let assert_equal_events = assert_equal ~cmp:Callstack.equal_event

let assert_equal_threads = assert_equal ~cmp:Thread.equal

let assert_equal_locksets = assert_equal ~cmp:Lockset.equal ~printer:Lockset.to_string

let assert_equal_lockset_sets = assert_equal ~cmp:LocksetSet.equal ~printer:LocksetSet.to_string

let assert_list_eq_length l1 l2 printer = 
  assert_equal 
    ~cmp:(fun l1 l2 -> (List.compare_lengths l1 l2) = 0)
    ~printer:(fun l -> 
        List.fold_left (fun acc s -> Format.asprintf "%s%a\n" acc printer s) "[" l
        ^ "]"
      )
    l1 l2

let assert_stmt_list_length length lst = 
  let dummy = List.range' 0 length |> List.map (fun _ -> Cil.dummyStmt) in
  assert_list_eq_length dummy lst Print_utils.pp_loc

let assert_fn_list_length length lst = 
  let dummy = List.range' 0 length |> List.map (fun _ -> Cil.emptyFunction "dummyFn") in
  assert_list_eq_length dummy lst Printer.pp_fundec


(* ==== Utilities ==== *)

let find_stmt_by_label fn_name label =
  try
    let kf = Globals.Functions.find_by_name fn_name in
    let stmt = Kernel_function.find_label kf label in
    !stmt
  with Not_found -> 
    Self.failure "Not found label %s in function %s" label fn_name;
    raise Not_found

let find_fn_by_name kf = 
  Globals.Functions.find_by_name kf
  |> Kernel_function.get_definition

let find_local_var_by_name fn_name var_name =
  try
    Globals.Functions.find_by_name fn_name
    |> Kernel_function.get_locals
    |> List.find (fun v -> String.equal v.vname var_name)
    |> Base.of_varinfo
  with Not_found -> 
    Self.failure "Not found variable %s in function %s" var_name fn_name;
    raise Not_found
