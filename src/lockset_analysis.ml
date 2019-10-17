open Deadlock_options
open Deadlock_utils
open Lockset
open Thread_analysis

module Results = Lockset_analysis_results
module StatementCache = Results.StatementCache
module FunctionCache = Results.FunctionCache

let check_values_for_bottom values results =
  if values == [] then
    Results.add_ptr_imprecision results
  else ()

let get_lockset stmt lock results =
  let values = Value.eval_ptr stmt lock in
  let valid_values = Value.remove_invalid_bases values in
  check_values_for_bottom valid_values results;
  let locks = List.map 
      (fun (base, offset) ->
         let varinfo = Base.to_varinfo base in
         let name = match offset with
           | 0 -> Format.asprintf "%a" Printer.pp_varinfo varinfo 
           | offset -> Format.asprintf "%a[%d]" Printer.pp_varinfo varinfo offset in

         let trace = Callstack.push_lock stmt name results.callstack in
         Lock.Varinfo (varinfo, offset, trace)
      ) valid_values in
  Lockset.of_list locks

let create_worklist stmts lss =
  let ls_list = LocksetSet.to_list lss in
  let aux = List.map
    (fun stmt ->
       List.map (fun ls -> (stmt, ls)) ls_list
    ) stmts in
  List.flatten aux

let update_on_lock entry_ls stmt lock results = 
  let possible_locks = get_lockset stmt lock results in
  if not (Lockset.is_empty entry_ls) then
    let edges = Lockset.cartesian_product entry_ls possible_locks in
    List.iter
      (fun (l1, l2) ->
         let trace1 = Lock.get_trace l1 in
         let trace2 = Lock.get_trace l2 in
         let trace = (trace1, trace2) in
         if not (Lock.equal l1 l2) then
           Results.add_dependency l1 l2 trace results
         else ()
      ) edges
  else ();
  LocksetSet.add_each entry_ls possible_locks

let update_on_unlock entry_ls stmt lock results =
  let possible_locks = get_lockset stmt lock results in
  LocksetSet.remove_each entry_ls possible_locks


let rec traverse_stmt (stmt : Cil_types.stmt) entry_ls (results : Results.t) =
  if StatementCache.mem (stmt.sid, entry_ls) results.stmt_cache then
    StatementCache.find (stmt.sid, entry_ls) results.stmt_cache
  else
    let exit_lss = match Stmts.stmt_type stmt with
    | Lock (lock) -> update_on_lock entry_ls stmt lock results
    | Unlock (lock) -> update_on_unlock entry_ls stmt lock results
    | Call (fundec) -> 
      Results.callstack_push stmt results;
      let exit = traverse_fn fundec entry_ls results in
      Results.callstack_pop results;
      exit
    | _ -> LocksetSet.singleton entry_ls in

    Results.add_stmt stmt.sid entry_ls exit_lss results; 

    let worklist = create_worklist stmt.succs exit_lss in
    List.iter
      (fun (stmt, entry_ls) ->
         let _ = traverse_stmt stmt entry_ls results in
         ()
      ) worklist;

    exit_lss

and traverse_fn fundec entry_ls results = 
  if FunctionCache.mem (fundec, entry_ls) results.fn_cache then
    FunctionCache.find (fundec, entry_ls) results.fn_cache
  else
    let entry_point = List.hd fundec.sallstmts in
    let exit_ls = traverse_stmt (entry_point : Cil_types.stmt) entry_ls results in
    Results.add_fn fundec entry_ls exit_ls results;
    exit_ls

(** Set given initial state and arguments and run EVA from given entry point *)
let compute_values_for_thread (thread : Thread.t) =
  let threadinfo = match thread.threadinfo with
    | Some ti -> ti
    | None -> failwith ("Not computed: " 
                        ^ (Format.asprintf "%a" Printer.pp_fundec thread.entry_point)) in
  let entry_point = Format.asprintf "%a" Printer.pp_fundec thread.entry_point in
  Globals.set_entry_point entry_point false;
  Db.Value.globals_set_initial_state threadinfo.init_state_join;
  if threadinfo.arguments != [] then 
    Db.Value.fun_set_args threadinfo.arguments_join else ();
  !Db.Value.compute()

let compute () =
  let empty_results = Results.empty () in
  let ta_results = Thread_analysis.compute () in
  let results = { empty_results with threads = ta_results } in
  Thread_analysis.Results.iter_on_threads
    (fun thread -> 
      compute_values_for_thread thread;

      let entry_ls = Lockset.empty in
      let entry_point = thread.entry_point in
      Results.callstack_push_thread_entry entry_point results;
      let exit_ls = traverse_fn entry_point entry_ls results in
      Results.callstack_pop results;
      ()
    ) results.threads;

  results
