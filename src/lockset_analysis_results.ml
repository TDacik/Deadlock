open Deadlock_options
open Deadlock_utils
open Thread_analysis
open Lockset

module FunctionCache = Map.Make
    (struct
      type t = Cil_types.fundec * Lockset.t
      let compare = Pervasives.compare
    end)

module StatementCache = Map.Make
    (struct
      type t = int * Lockset.t
      let compare = Pervasives.compare
    end)

type imprecision =
  | Pointer_analysis_error of int
  | Wrapper_function of Cil_types.fundec
  | Non_unrolled_cycle of Cil_types.stmt
  | None

type t = {
  mutable threads : Thread_analysis.Results.t;
  mutable fn_cache : LocksetSet.t FunctionCache.t;
  mutable stmt_cache : LocksetSet.t StatementCache.t;
  mutable lockgraph : Lockgraph.t;
  mutable deadlocks : Lock.t list;
  mutable max_locks_vals : int;
  mutable imprecision : imprecision;
  mutable callstack : Callstack.t;
}

let empty () = 
  {
    threads = Thread_analysis.Results.empty ();
    fn_cache = FunctionCache.empty;
    stmt_cache = StatementCache.empty;
    lockgraph = Lockgraph.create ();
    deadlocks = [];
    max_locks_vals = 0;
    imprecision = None;
    callstack = Callstack.empty ();
  }

let add_stmt stmt ls lss results =
  let cache = StatementCache.add (stmt, ls) lss results.stmt_cache in
  results.stmt_cache <- cache

let add_fn fn ls lss (results : t) =
  let cache = FunctionCache.add (fn, ls) lss results.fn_cache in
  results.fn_cache <- cache

(** Lockgraph operations *)
let add_dependency l1 l2 trace results =
  Lockgraph.add_dependency l1 l2 trace results.lockgraph

let get_all_deadlocks results =
  Lockgraph.get_all_deadlocks results.lockgraph

let print_edges results =
  Lockgraph.print_edges results.lockgraph


(** Operations over callstack *)
let callstack_push stmt results =
  results.callstack <- Callstack.push_call stmt results.callstack

let callstack_push_thread_entry fundec results =
  results.callstack <- Callstack.push_thread_entry fundec results.callstack

let callstack_pop results =
  results.callstack <- Callstack.pop results.callstack

let print_callstack results =
  Callstack.print results.callstack

(** Operations over threads *)
let get_threads results = Thread_analysis.Results.get_threads_list results.threads 

let add_ptr_imprecision results =
  results.imprecision <- Pointer_analysis_error 1

let imprecision_to_string results = match results.imprecision with
  | Pointer_analysis_error _ -> "PTR"
  | _ -> "NO"

let print_imprecision results = match results.imprecision with
  | Pointer_analysis_error _ ->
    Self.result "PTR ERR"
  | _ -> ()

let dump_all results =
  Self.result "Function cache:";
  FunctionCache.iter
    (fun (fn,ls) lss ->
       let ls_string = Lockset.to_string ls in
       let lss_string = LocksetSet.to_string lss in
       Self.result "  %a with %s -> %s" Printer.pp_fundec fn ls_string lss_string
    ) results.fn_cache;

  Self.result "Statement cache:";
  StatementCache.iter
    (fun (sid, ls) lss ->
       let stmt = fst (Kernel_function.find_from_sid sid) in
       let stmt_string = Format.asprintf "%a" Printer.pp_stmt stmt in
       let ls_string = Lockset.to_string ls in
       let lss_string = LocksetSet.to_string lss in
       Self.result "%s with %s -> %s" 
         (stmt_string)
         (ls_string) 
         (lss_string)
    ) results.stmt_cache
