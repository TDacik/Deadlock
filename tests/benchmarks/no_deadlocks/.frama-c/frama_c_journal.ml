(* Frama-C journal generated at 16:07 the 18/03/2021 *)

exception Unreachable
exception Exception of string

[@@@ warning "-26"]

(* Run the user commands *)
let run () =
  Dynamic.Parameter.String.set "-dl-lock-fn" "pthread_mutex_lock";
  Dynamic.Parameter.String.set "-dl-unlock-fn" "pthread_mutex_unlock";
  Dynamic.Parameter.String.set "-dl-lock-init-fn" "pthread_mutex_init";
  Dynamic.Parameter.String.set "-dl-lock-destroy-fn" "pthread_mutex_destroy";
  Dynamic.Parameter.String.set "-dl-condition-wait-fn" "pthread_cond_wait";
  Dynamic.Parameter.String.set "-dl-thread-create-fn" "pthread_create";
  Dynamic.Parameter.String.set "-dl-thread-join-fn" "pthread_join";
  Dynamic.Parameter.String.set "-dl-lock-type" "pthread_mutex_t";
  Dynamic.Parameter.String.set "-dl-lock-fn"
    "pthread_mutex_lock,pthread_spin_lock";
  Dynamic.Parameter.String.set "-no-block-lock-fn" "pthread_spin_trylock";
  Dynamic.Parameter.String.set "-no-block-lock-fn"
    "pthread_mutex_trylock,pthread_spin_trylock";
  Dynamic.Parameter.String.set "-no-block-lock-fn"
    "pthread_mutex_timedlock,pthread_mutex_trylock,pthread_spin_trylock";
  Dynamic.Parameter.String.set "-dl-unlock-fn"
    "pthread_mutex_unlock,pthread_spin_unlock";
  Dynamic.Parameter.String.set "-dl-lock-type"
    "pthread_mutex_t,pthread_spinlock_t";
  Dynamic.Parameter.Bool.set "-deadlock" true;
  Dynamic.Parameter.String.set ""
    "/home/tom/skola/frama/Deadlock/tests/benchmarks/no_deadlocks/no_dl_exit2.c";
  File.init_from_cmdline ();
  !Db.Value.compute ();
  (failwith "Function cannot be journalized: Db.Value.globals_set_initial_state" : _ -> unit)
    (failwith "no printer registered for value of type (Offsetmap(Cvalue.V_Or_Uninitialized.t), Cvalue.Default_offsetmap) Lmap:
                running the journal will fail.") ;
  !Db.Value.compute ();
  let __ = Callgraph.Cg.get () in
  let __ = Callgraph.Cg.get () in
  Project.clear
    ~selection:(State_selection.of_list
                  [ State.get "sign.Store.Table_By_Callstack";
                    State.get "sign.Store.Table";
                    State.get "sign.Store.Storage";
                    State.get "sign.Store.Global_State";
                    State.get "sign.Store.Called_Functions_Memo";
                    State.get "sign.Store.Called_Functions_By_Callstack";
                    State.get "sign.Store.AfterTable_By_Callstack";
                    State.get "sign.Store.AfterTable";
                    State.get "postdominator.value";
                    State.get "inout.Store.Table_By_Callstack";
                    State.get "inout.Store.Table";
                    State.get "inout.Store.Storage";
                    State.get "inout.Store.Global_State";
                    State.get "inout.Store.Called_Functions_Memo";
                    State.get "inout.Store.Called_Functions_By_Callstack";
                    State.get "inout.Store.AfterTable_By_Callstack";
                    State.get "inout.Store.AfterTable";
                    State.get "Widen.Per_Function_Hints";
                    State.get "Widen.Parsed_Dynamic_Hints";
                    State.get "Widen.Dynamic_Hints";
                    State.get "Value_util.Degeneration";
                    State.get "Value_messages.Alarm_cache";
                    State.get "Value.Value_results.is_called";
                    State.get "Value.Value_results.Callers";
                    State.get
                      "Value.Traces_domain.Traces.state.Store.Table_By_Callstack";
                    State.get "Value.Traces_domain.Traces.state.Store.Table";
                    State.get
                      "Value.Traces_domain.Traces.state.Store.Storage";
                    State.get
                      "Value.Traces_domain.Traces.state.Store.Global_State";
                    State.get
                      "Value.Traces_domain.Traces.state.Store.Called_Functions_Memo";
                    State.get
                      "Value.Traces_domain.Traces.state.Store.Called_Functions_By_Callstack";
                    State.get
                      "Value.Traces_domain.Traces.state.Store.AfterTable_By_Callstack";
                    State.get
                      "Value.Traces_domain.Traces.state.Store.AfterTable";
                    State.get "Value.Red_statuses.RedStatusesTable";
                    State.get "Value.Gui.UsedVarState";
                    State.get "Users_register.print";
                    State.get "Users";
                    State.get "Unit domain.Store.Table_By_Callstack";
                    State.get "Unit domain.Store.Table";
                    State.get "Unit domain.Store.Storage";
                    State.get "Unit domain.Store.Global_State";
                    State.get "Unit domain.Store.Called_Functions_Memo";
                    State.get
                      "Unit domain.Store.Called_Functions_By_Callstack";
                    State.get "Unit domain.Store.AfterTable_By_Callstack";
                    State.get "Unit domain.Store.AfterTable";
                    State.get "Transfer_stmt.InOutCallback";
                    State.get "Transfer_stmt.DumpFileCounters";
                    State.get
                      "Symbolic locations domain.Store.Table_By_Callstack";
                    State.get "Symbolic locations domain.Store.Table";
                    State.get "Symbolic locations domain.Store.Storage";
                    State.get "Symbolic locations domain.Store.Global_State";
                    State.get
                      "Symbolic locations domain.Store.Called_Functions_Memo";
                    State.get
                      "Symbolic locations domain.Store.Called_Functions_By_Callstack";
                    State.get
                      "Symbolic locations domain.Store.AfterTable_By_Callstack";
                    State.get "Symbolic locations domain.Store.AfterTable";
                    State.get "Subgraph of Callgraph.Services";
                    State.get "Subgraph of Callgraph.Cg";
                    State.get "Studia.Highlighter.WritesOrRead";
                    State.get "Studia.Highlighter.StudiaState";
                    State.get "Sparecode without unused globals";
                    State.get "Sparecode";
                    State.get "Slicing_gui.State";
                    State.get "Slicing.Project";
                    State.get "Semantical constant propagation";
                    State.get "Scope.Datatscope.ModifsEdge";
                    State.get "Printer domain.Store.Table_By_Callstack";
                    State.get "Printer domain.Store.Table";
                    State.get "Printer domain.Store.Storage";
                    State.get "Printer domain.Store.Global_State";
                    State.get "Printer domain.Store.Called_Functions_Memo";
                    State.get
                      "Printer domain.Store.Called_Functions_By_Callstack";
                    State.get "Printer domain.Store.AfterTable_By_Callstack";
                    State.get "Printer domain.Store.AfterTable";
                    State.get "Pdg.State";
                    State.get "Pdg.Register.compute_once";
                    State.get "Operational_inputs.MemExec";
                    State.get "Octagon domain.Store.Table_By_Callstack";
                    State.get "Octagon domain.Store.Table";
                    State.get "Octagon domain.Store.Storage";
                    State.get "Octagon domain.Store.Global_State";
                    State.get "Octagon domain.Store.Called_Functions_Memo";
                    State.get
                      "Octagon domain.Store.Called_Functions_By_Callstack";
                    State.get "Octagon domain.Store.AfterTable_By_Callstack";
                    State.get "Octagon domain.Store.AfterTable";
                    State.get "Occurrences.State";
                    State.get "Occurrences.LastResult";
                    State.get "Occurrence_gui.State";
                    State.get "Occurrence.compute";
                    State.get "Nonterm.run";
                    State.get "Metrics_coverage.Kf_coverage";
                    State.get "Mem_exec.PreviousCalls(1)";
                    State.get "Inout.Register.ShouldOuput";
                    State.get "Inout.Outputs.Externals";
                    State.get "Inout.Operational_inputs.Internals";
                    State.get
                      "Inout.Operational_inputs.Externals_With_Formals";
                    State.get "Inout.Operational_inputs.CallwiseResults";
                    State.get "Inout.Inputs.Externals";
                    State.get "Inout.Derefs.Externals";
                    State.get "Inout.Cumulative_analysis.Memo(outputs)";
                    State.get "Inout.Cumulative_analysis.Memo(inputs)";
                    State.get "Inout.Cumulative_analysis.Memo(derefs)";
                    State.get "Impact_gui.SelectedStmt";
                    State.get "Impact_gui.Highlighted_stmt";
                    State.get "Impact.Register_gui.ReasonGraph";
                    State.get "Impact.Register_gui.InitialNodes";
                    State.get "Impact.Register_gui.ImpactedNodes";
                    State.get "Gauges domain.Store.Table_By_Callstack";
                    State.get "Gauges domain.Store.Table";
                    State.get "Gauges domain.Store.Storage";
                    State.get "Gauges domain.Store.Global_State";
                    State.get "Gauges domain.Store.Called_Functions_Memo";
                    State.get
                      "Gauges domain.Store.Called_Functions_By_Callstack";
                    State.get "Gauges domain.Store.AfterTable_By_Callstack";
                    State.get "Gauges domain.Store.AfterTable";
                    State.get "Functionwise dependencies";
                    State.get "From.Callwise.MemExec";
                    State.get "External inouts full";
                    State.get "Eva.Builtins.BuiltinsOverride";
                    State.get "Equality domain.Store.Table_By_Callstack";
                    State.get "Equality domain.Store.Table";
                    State.get "Equality domain.Store.Storage";
                    State.get "Equality domain.Store.Global_State";
                    State.get "Equality domain.Store.Called_Functions_Memo";
                    State.get
                      "Equality domain.Store.Called_Functions_By_Callstack";
                    State.get "Equality domain.Store.AfterTable_By_Callstack";
                    State.get "Equality domain.Store.AfterTable";
                    State.get "Dpds_gui.Highlighter.ZonesState";
                    State.get "Dpds_gui.Highlighter.ShowDef";
                    State.get "Dpds_gui.Highlighter.Pscope_warn";
                    State.get "Dpds_gui.Highlighter.Pscope";
                    State.get "Dpds_gui.Highlighter.Fscope";
                    State.get "Dpds_gui.Highlighter.FBscope";
                    State.get "Dpds_gui.Highlighter.DpdsState";
                    State.get "Dpds_gui.Highlighter.Bscope";
                    State.get "Db.Value.Table_By_Callstack";
                    State.get "Db.Value.Table";
                    State.get "Db.Value.RecursiveCallsFound";
                    State.get "Db.Value.Conditions_table";
                    State.get "Db.Value.Called_Functions_Memo";
                    State.get "Db.Value.Called_Functions_By_Callstack";
                    State.get "Db.Value.AfterTable_By_Callstack";
                    State.get "Db.Value.AfterTable";
                    State.get "Cvalue domain.Storage";
                    State.get "Constant_Propagation.compute";
                    State.get "Callwise dependencies";
                    State.get "Callgraph.Usesiter_in_rev_order";
                    State.get "Callgraph.Usesiter_in_order";
                    State.get "Callgraph.Services";
                    State.get "Callgraph.Cg";
                    State.get "Bitwise domain.Store.Table_By_Callstack";
                    State.get "Bitwise domain.Store.Table";
                    State.get "Bitwise domain.Store.Storage";
                    State.get "Bitwise domain.Store.Global_State";
                    State.get "Bitwise domain.Store.Called_Functions_Memo";
                    State.get
                      "Bitwise domain.Store.Called_Functions_By_Callstack";
                    State.get "Bitwise domain.Store.AfterTable_By_Callstack";
                    State.get "Bitwise domain.Store.AfterTable";
                    State.get "-pdgShouldOutput";
                    State.get "-metrics-eva-coverShouldOutput";
                    State.get "-evaShouldOutput";
                    State.get "-depsShouldOutput";
                    State.get "-calldepsShouldOutput";
                    State.get "!Db.Value.compute";
                    State.get "!Db.From.compute_all" ])
    ();
  (failwith "Function cannot be journalized: Db.Value.globals_set_initial_state" : _ -> unit)
    (failwith "no printer registered for value of type (Offsetmap(Cvalue.V_Or_Uninitialized.t), Cvalue.Default_offsetmap) Lmap:
                running the journal will fail.") ;
  Db.Value.fun_use_default_args ();
  Db.Value.mark_as_computed ();
  Project.clear
    ~selection:(State_selection.of_list
                  [ State.get "sign.Store.Table_By_Callstack";
                    State.get "sign.Store.Table";
                    State.get "sign.Store.Storage";
                    State.get "sign.Store.Global_State";
                    State.get "sign.Store.Called_Functions_Memo";
                    State.get "sign.Store.Called_Functions_By_Callstack";
                    State.get "sign.Store.AfterTable_By_Callstack";
                    State.get "sign.Store.AfterTable";
                    State.get "postdominator.value";
                    State.get "inout.Store.Table_By_Callstack";
                    State.get "inout.Store.Table";
                    State.get "inout.Store.Storage";
                    State.get "inout.Store.Global_State";
                    State.get "inout.Store.Called_Functions_Memo";
                    State.get "inout.Store.Called_Functions_By_Callstack";
                    State.get "inout.Store.AfterTable_By_Callstack";
                    State.get "inout.Store.AfterTable";
                    State.get "Widen.Per_Function_Hints";
                    State.get "Widen.Parsed_Dynamic_Hints";
                    State.get "Widen.Dynamic_Hints";
                    State.get "Value_util.Degeneration";
                    State.get "Value_messages.Alarm_cache";
                    State.get "Value.Value_results.is_called";
                    State.get "Value.Value_results.Callers";
                    State.get
                      "Value.Traces_domain.Traces.state.Store.Table_By_Callstack";
                    State.get "Value.Traces_domain.Traces.state.Store.Table";
                    State.get
                      "Value.Traces_domain.Traces.state.Store.Storage";
                    State.get
                      "Value.Traces_domain.Traces.state.Store.Global_State";
                    State.get
                      "Value.Traces_domain.Traces.state.Store.Called_Functions_Memo";
                    State.get
                      "Value.Traces_domain.Traces.state.Store.Called_Functions_By_Callstack";
                    State.get
                      "Value.Traces_domain.Traces.state.Store.AfterTable_By_Callstack";
                    State.get
                      "Value.Traces_domain.Traces.state.Store.AfterTable";
                    State.get "Value.Red_statuses.RedStatusesTable";
                    State.get "Value.Gui.UsedVarState";
                    State.get "Users_register.print";
                    State.get "Users";
                    State.get "Unit domain.Store.Table_By_Callstack";
                    State.get "Unit domain.Store.Table";
                    State.get "Unit domain.Store.Storage";
                    State.get "Unit domain.Store.Global_State";
                    State.get "Unit domain.Store.Called_Functions_Memo";
                    State.get
                      "Unit domain.Store.Called_Functions_By_Callstack";
                    State.get "Unit domain.Store.AfterTable_By_Callstack";
                    State.get "Unit domain.Store.AfterTable";
                    State.get "Transfer_stmt.InOutCallback";
                    State.get "Transfer_stmt.DumpFileCounters";
                    State.get
                      "Symbolic locations domain.Store.Table_By_Callstack";
                    State.get "Symbolic locations domain.Store.Table";
                    State.get "Symbolic locations domain.Store.Storage";
                    State.get "Symbolic locations domain.Store.Global_State";
                    State.get
                      "Symbolic locations domain.Store.Called_Functions_Memo";
                    State.get
                      "Symbolic locations domain.Store.Called_Functions_By_Callstack";
                    State.get
                      "Symbolic locations domain.Store.AfterTable_By_Callstack";
                    State.get "Symbolic locations domain.Store.AfterTable";
                    State.get "Subgraph of Callgraph.Services";
                    State.get "Subgraph of Callgraph.Cg";
                    State.get "Studia.Highlighter.WritesOrRead";
                    State.get "Studia.Highlighter.StudiaState";
                    State.get "Sparecode without unused globals";
                    State.get "Sparecode";
                    State.get "Slicing_gui.State";
                    State.get "Slicing.Project";
                    State.get "Semantical constant propagation";
                    State.get "Scope.Datatscope.ModifsEdge";
                    State.get "Printer domain.Store.Table_By_Callstack";
                    State.get "Printer domain.Store.Table";
                    State.get "Printer domain.Store.Storage";
                    State.get "Printer domain.Store.Global_State";
                    State.get "Printer domain.Store.Called_Functions_Memo";
                    State.get
                      "Printer domain.Store.Called_Functions_By_Callstack";
                    State.get "Printer domain.Store.AfterTable_By_Callstack";
                    State.get "Printer domain.Store.AfterTable";
                    State.get "Pdg.State";
                    State.get "Pdg.Register.compute_once";
                    State.get "Operational_inputs.MemExec";
                    State.get "Octagon domain.Store.Table_By_Callstack";
                    State.get "Octagon domain.Store.Table";
                    State.get "Octagon domain.Store.Storage";
                    State.get "Octagon domain.Store.Global_State";
                    State.get "Octagon domain.Store.Called_Functions_Memo";
                    State.get
                      "Octagon domain.Store.Called_Functions_By_Callstack";
                    State.get "Octagon domain.Store.AfterTable_By_Callstack";
                    State.get "Octagon domain.Store.AfterTable";
                    State.get "Occurrences.State";
                    State.get "Occurrences.LastResult";
                    State.get "Occurrence_gui.State";
                    State.get "Occurrence.compute";
                    State.get "Nonterm.run";
                    State.get "Metrics_coverage.Kf_coverage";
                    State.get "Mem_exec.PreviousCalls(1)";
                    State.get "Inout.Register.ShouldOuput";
                    State.get "Inout.Outputs.Externals";
                    State.get "Inout.Operational_inputs.Internals";
                    State.get
                      "Inout.Operational_inputs.Externals_With_Formals";
                    State.get "Inout.Operational_inputs.CallwiseResults";
                    State.get "Inout.Inputs.Externals";
                    State.get "Inout.Derefs.Externals";
                    State.get "Inout.Cumulative_analysis.Memo(outputs)";
                    State.get "Inout.Cumulative_analysis.Memo(inputs)";
                    State.get "Inout.Cumulative_analysis.Memo(derefs)";
                    State.get "Impact_gui.SelectedStmt";
                    State.get "Impact_gui.Highlighted_stmt";
                    State.get "Impact.Register_gui.ReasonGraph";
                    State.get "Impact.Register_gui.InitialNodes";
                    State.get "Impact.Register_gui.ImpactedNodes";
                    State.get "Gauges domain.Store.Table_By_Callstack";
                    State.get "Gauges domain.Store.Table";
                    State.get "Gauges domain.Store.Storage";
                    State.get "Gauges domain.Store.Global_State";
                    State.get "Gauges domain.Store.Called_Functions_Memo";
                    State.get
                      "Gauges domain.Store.Called_Functions_By_Callstack";
                    State.get "Gauges domain.Store.AfterTable_By_Callstack";
                    State.get "Gauges domain.Store.AfterTable";
                    State.get "Functionwise dependencies";
                    State.get "From.Callwise.MemExec";
                    State.get "External inouts full";
                    State.get "Eva.Builtins.BuiltinsOverride";
                    State.get "Equality domain.Store.Table_By_Callstack";
                    State.get "Equality domain.Store.Table";
                    State.get "Equality domain.Store.Storage";
                    State.get "Equality domain.Store.Global_State";
                    State.get "Equality domain.Store.Called_Functions_Memo";
                    State.get
                      "Equality domain.Store.Called_Functions_By_Callstack";
                    State.get "Equality domain.Store.AfterTable_By_Callstack";
                    State.get "Equality domain.Store.AfterTable";
                    State.get "Dpds_gui.Highlighter.ZonesState";
                    State.get "Dpds_gui.Highlighter.ShowDef";
                    State.get "Dpds_gui.Highlighter.Pscope_warn";
                    State.get "Dpds_gui.Highlighter.Pscope";
                    State.get "Dpds_gui.Highlighter.Fscope";
                    State.get "Dpds_gui.Highlighter.FBscope";
                    State.get "Dpds_gui.Highlighter.DpdsState";
                    State.get "Dpds_gui.Highlighter.Bscope";
                    State.get "Db.Value.Table_By_Callstack";
                    State.get "Db.Value.Table";
                    State.get "Db.Value.RecursiveCallsFound";
                    State.get "Db.Value.Conditions_table";
                    State.get "Db.Value.Called_Functions_Memo";
                    State.get "Db.Value.Called_Functions_By_Callstack";
                    State.get "Db.Value.AfterTable_By_Callstack";
                    State.get "Db.Value.AfterTable";
                    State.get "Cvalue domain.Storage";
                    State.get "Constant_Propagation.compute";
                    State.get "Callwise dependencies";
                    State.get "Callgraph.Usesiter_in_rev_order";
                    State.get "Callgraph.Usesiter_in_order";
                    State.get "Callgraph.Services";
                    State.get "Callgraph.Cg";
                    State.get "Bitwise domain.Store.Table_By_Callstack";
                    State.get "Bitwise domain.Store.Table";
                    State.get "Bitwise domain.Store.Storage";
                    State.get "Bitwise domain.Store.Global_State";
                    State.get "Bitwise domain.Store.Called_Functions_Memo";
                    State.get
                      "Bitwise domain.Store.Called_Functions_By_Callstack";
                    State.get "Bitwise domain.Store.AfterTable_By_Callstack";
                    State.get "Bitwise domain.Store.AfterTable";
                    State.get "-pdgShouldOutput";
                    State.get "-metrics-eva-coverShouldOutput";
                    State.get "-evaShouldOutput";
                    State.get "-depsShouldOutput";
                    State.get "-calldepsShouldOutput";
                    State.get "!Db.Value.compute";
                    State.get "!Db.From.compute_all" ])
    ();
  (failwith "Function cannot be journalized: Db.Value.globals_set_initial_state" : _ -> unit)
    (failwith "no printer registered for value of type (Offsetmap(Cvalue.V_Or_Uninitialized.t), Cvalue.Default_offsetmap) Lmap:
                running the journal will fail.") ;
  Db.Value.fun_use_default_args ();
  Db.Value.mark_as_computed ();
  Project.clear
    ~selection:(State_selection.of_list
                  [ State.get "sign.Store.Table_By_Callstack";
                    State.get "sign.Store.Table";
                    State.get "sign.Store.Storage";
                    State.get "sign.Store.Global_State";
                    State.get "sign.Store.Called_Functions_Memo";
                    State.get "sign.Store.Called_Functions_By_Callstack";
                    State.get "sign.Store.AfterTable_By_Callstack";
                    State.get "sign.Store.AfterTable";
                    State.get "postdominator.value";
                    State.get "inout.Store.Table_By_Callstack";
                    State.get "inout.Store.Table";
                    State.get "inout.Store.Storage";
                    State.get "inout.Store.Global_State";
                    State.get "inout.Store.Called_Functions_Memo";
                    State.get "inout.Store.Called_Functions_By_Callstack";
                    State.get "inout.Store.AfterTable_By_Callstack";
                    State.get "inout.Store.AfterTable";
                    State.get "Widen.Per_Function_Hints";
                    State.get "Widen.Parsed_Dynamic_Hints";
                    State.get "Widen.Dynamic_Hints";
                    State.get "Value_util.Degeneration";
                    State.get "Value_messages.Alarm_cache";
                    State.get "Value.Value_results.is_called";
                    State.get "Value.Value_results.Callers";
                    State.get
                      "Value.Traces_domain.Traces.state.Store.Table_By_Callstack";
                    State.get "Value.Traces_domain.Traces.state.Store.Table";
                    State.get
                      "Value.Traces_domain.Traces.state.Store.Storage";
                    State.get
                      "Value.Traces_domain.Traces.state.Store.Global_State";
                    State.get
                      "Value.Traces_domain.Traces.state.Store.Called_Functions_Memo";
                    State.get
                      "Value.Traces_domain.Traces.state.Store.Called_Functions_By_Callstack";
                    State.get
                      "Value.Traces_domain.Traces.state.Store.AfterTable_By_Callstack";
                    State.get
                      "Value.Traces_domain.Traces.state.Store.AfterTable";
                    State.get "Value.Red_statuses.RedStatusesTable";
                    State.get "Value.Gui.UsedVarState";
                    State.get "Users_register.print";
                    State.get "Users";
                    State.get "Unit domain.Store.Table_By_Callstack";
                    State.get "Unit domain.Store.Table";
                    State.get "Unit domain.Store.Storage";
                    State.get "Unit domain.Store.Global_State";
                    State.get "Unit domain.Store.Called_Functions_Memo";
                    State.get
                      "Unit domain.Store.Called_Functions_By_Callstack";
                    State.get "Unit domain.Store.AfterTable_By_Callstack";
                    State.get "Unit domain.Store.AfterTable";
                    State.get "Transfer_stmt.InOutCallback";
                    State.get "Transfer_stmt.DumpFileCounters";
                    State.get
                      "Symbolic locations domain.Store.Table_By_Callstack";
                    State.get "Symbolic locations domain.Store.Table";
                    State.get "Symbolic locations domain.Store.Storage";
                    State.get "Symbolic locations domain.Store.Global_State";
                    State.get
                      "Symbolic locations domain.Store.Called_Functions_Memo";
                    State.get
                      "Symbolic locations domain.Store.Called_Functions_By_Callstack";
                    State.get
                      "Symbolic locations domain.Store.AfterTable_By_Callstack";
                    State.get "Symbolic locations domain.Store.AfterTable";
                    State.get "Subgraph of Callgraph.Services";
                    State.get "Subgraph of Callgraph.Cg";
                    State.get "Studia.Highlighter.WritesOrRead";
                    State.get "Studia.Highlighter.StudiaState";
                    State.get "Sparecode without unused globals";
                    State.get "Sparecode";
                    State.get "Slicing_gui.State";
                    State.get "Slicing.Project";
                    State.get "Semantical constant propagation";
                    State.get "Scope.Datatscope.ModifsEdge";
                    State.get "Printer domain.Store.Table_By_Callstack";
                    State.get "Printer domain.Store.Table";
                    State.get "Printer domain.Store.Storage";
                    State.get "Printer domain.Store.Global_State";
                    State.get "Printer domain.Store.Called_Functions_Memo";
                    State.get
                      "Printer domain.Store.Called_Functions_By_Callstack";
                    State.get "Printer domain.Store.AfterTable_By_Callstack";
                    State.get "Printer domain.Store.AfterTable";
                    State.get "Pdg.State";
                    State.get "Pdg.Register.compute_once";
                    State.get "Operational_inputs.MemExec";
                    State.get "Octagon domain.Store.Table_By_Callstack";
                    State.get "Octagon domain.Store.Table";
                    State.get "Octagon domain.Store.Storage";
                    State.get "Octagon domain.Store.Global_State";
                    State.get "Octagon domain.Store.Called_Functions_Memo";
                    State.get
                      "Octagon domain.Store.Called_Functions_By_Callstack";
                    State.get "Octagon domain.Store.AfterTable_By_Callstack";
                    State.get "Octagon domain.Store.AfterTable";
                    State.get "Occurrences.State";
                    State.get "Occurrences.LastResult";
                    State.get "Occurrence_gui.State";
                    State.get "Occurrence.compute";
                    State.get "Nonterm.run";
                    State.get "Metrics_coverage.Kf_coverage";
                    State.get "Mem_exec.PreviousCalls(1)";
                    State.get "Inout.Register.ShouldOuput";
                    State.get "Inout.Outputs.Externals";
                    State.get "Inout.Operational_inputs.Internals";
                    State.get
                      "Inout.Operational_inputs.Externals_With_Formals";
                    State.get "Inout.Operational_inputs.CallwiseResults";
                    State.get "Inout.Inputs.Externals";
                    State.get "Inout.Derefs.Externals";
                    State.get "Inout.Cumulative_analysis.Memo(outputs)";
                    State.get "Inout.Cumulative_analysis.Memo(inputs)";
                    State.get "Inout.Cumulative_analysis.Memo(derefs)";
                    State.get "Impact_gui.SelectedStmt";
                    State.get "Impact_gui.Highlighted_stmt";
                    State.get "Impact.Register_gui.ReasonGraph";
                    State.get "Impact.Register_gui.InitialNodes";
                    State.get "Impact.Register_gui.ImpactedNodes";
                    State.get "Gauges domain.Store.Table_By_Callstack";
                    State.get "Gauges domain.Store.Table";
                    State.get "Gauges domain.Store.Storage";
                    State.get "Gauges domain.Store.Global_State";
                    State.get "Gauges domain.Store.Called_Functions_Memo";
                    State.get
                      "Gauges domain.Store.Called_Functions_By_Callstack";
                    State.get "Gauges domain.Store.AfterTable_By_Callstack";
                    State.get "Gauges domain.Store.AfterTable";
                    State.get "Functionwise dependencies";
                    State.get "From.Callwise.MemExec";
                    State.get "External inouts full";
                    State.get "Eva.Builtins.BuiltinsOverride";
                    State.get "Equality domain.Store.Table_By_Callstack";
                    State.get "Equality domain.Store.Table";
                    State.get "Equality domain.Store.Storage";
                    State.get "Equality domain.Store.Global_State";
                    State.get "Equality domain.Store.Called_Functions_Memo";
                    State.get
                      "Equality domain.Store.Called_Functions_By_Callstack";
                    State.get "Equality domain.Store.AfterTable_By_Callstack";
                    State.get "Equality domain.Store.AfterTable";
                    State.get "Dpds_gui.Highlighter.ZonesState";
                    State.get "Dpds_gui.Highlighter.ShowDef";
                    State.get "Dpds_gui.Highlighter.Pscope_warn";
                    State.get "Dpds_gui.Highlighter.Pscope";
                    State.get "Dpds_gui.Highlighter.Fscope";
                    State.get "Dpds_gui.Highlighter.FBscope";
                    State.get "Dpds_gui.Highlighter.DpdsState";
                    State.get "Dpds_gui.Highlighter.Bscope";
                    State.get "Db.Value.Table_By_Callstack";
                    State.get "Db.Value.Table";
                    State.get "Db.Value.RecursiveCallsFound";
                    State.get "Db.Value.Conditions_table";
                    State.get "Db.Value.Called_Functions_Memo";
                    State.get "Db.Value.Called_Functions_By_Callstack";
                    State.get "Db.Value.AfterTable_By_Callstack";
                    State.get "Db.Value.AfterTable";
                    State.get "Cvalue domain.Storage";
                    State.get "Constant_Propagation.compute";
                    State.get "Callwise dependencies";
                    State.get "Callgraph.Usesiter_in_rev_order";
                    State.get "Callgraph.Usesiter_in_order";
                    State.get "Callgraph.Services";
                    State.get "Callgraph.Cg";
                    State.get "Bitwise domain.Store.Table_By_Callstack";
                    State.get "Bitwise domain.Store.Table";
                    State.get "Bitwise domain.Store.Storage";
                    State.get "Bitwise domain.Store.Global_State";
                    State.get "Bitwise domain.Store.Called_Functions_Memo";
                    State.get
                      "Bitwise domain.Store.Called_Functions_By_Callstack";
                    State.get "Bitwise domain.Store.AfterTable_By_Callstack";
                    State.get "Bitwise domain.Store.AfterTable";
                    State.get "-pdgShouldOutput";
                    State.get "-metrics-eva-coverShouldOutput";
                    State.get "-evaShouldOutput";
                    State.get "-depsShouldOutput";
                    State.get "-calldepsShouldOutput";
                    State.get "!Db.Value.compute";
                    State.get "!Db.From.compute_all" ])
    ();
  (failwith "Function cannot be journalized: Db.Value.globals_set_initial_state" : _ -> unit)
    (failwith "no printer registered for value of type (Offsetmap(Cvalue.V_Or_Uninitialized.t), Cvalue.Default_offsetmap) Lmap:
                running the journal will fail.") ;
  Db.Value.fun_use_default_args ();
  Db.Value.mark_as_computed ();
  let __ = Callgraph.Cg.get () in
  let __ = Callgraph.Cg.get () in
  Project.clear
    ~selection:(State_selection.of_list
                  [ State.get "sign.Store.Table_By_Callstack";
                    State.get "sign.Store.Table";
                    State.get "sign.Store.Storage";
                    State.get "sign.Store.Global_State";
                    State.get "sign.Store.Called_Functions_Memo";
                    State.get "sign.Store.Called_Functions_By_Callstack";
                    State.get "sign.Store.AfterTable_By_Callstack";
                    State.get "sign.Store.AfterTable";
                    State.get "postdominator.value";
                    State.get "inout.Store.Table_By_Callstack";
                    State.get "inout.Store.Table";
                    State.get "inout.Store.Storage";
                    State.get "inout.Store.Global_State";
                    State.get "inout.Store.Called_Functions_Memo";
                    State.get "inout.Store.Called_Functions_By_Callstack";
                    State.get "inout.Store.AfterTable_By_Callstack";
                    State.get "inout.Store.AfterTable";
                    State.get "WpPropertyIndex";
                    State.get "Wp.WpPropId.Names3.Index";
                    State.get "Wp.WpPropId.Names2.Index";
                    State.get "Wp.WpPropId.Names.Index";
                    State.get "Wp.LogicUsage.Database";
                    State.get "Widen.Per_Function_Hints";
                    State.get "Widen.Parsed_Dynamic_Hints";
                    State.get "Widen.Dynamic_Hints";
                    State.get "Value_util.Degeneration";
                    State.get "Value_messages.Alarm_cache";
                    State.get "Value.Value_results.is_called";
                    State.get "Value.Value_results.Callers";
                    State.get
                      "Value.Traces_domain.Traces.state.Store.Table_By_Callstack";
                    State.get "Value.Traces_domain.Traces.state.Store.Table";
                    State.get
                      "Value.Traces_domain.Traces.state.Store.Storage";
                    State.get
                      "Value.Traces_domain.Traces.state.Store.Global_State";
                    State.get
                      "Value.Traces_domain.Traces.state.Store.Called_Functions_Memo";
                    State.get
                      "Value.Traces_domain.Traces.state.Store.Called_Functions_By_Callstack";
                    State.get
                      "Value.Traces_domain.Traces.state.Store.AfterTable_By_Callstack";
                    State.get
                      "Value.Traces_domain.Traces.state.Store.AfterTable";
                    State.get "Value.Red_statuses.RedStatusesTable";
                    State.get "Value.Initialization(1)";
                    State.get "Value.Gui.UsedVarState";
                    State.get "Users_register.print";
                    State.get "Users";
                    State.get "Unit domain.Store.Table_By_Callstack";
                    State.get "Unit domain.Store.Table";
                    State.get "Unit domain.Store.Storage";
                    State.get "Unit domain.Store.Global_State";
                    State.get "Unit domain.Store.Called_Functions_Memo";
                    State.get
                      "Unit domain.Store.Called_Functions_By_Callstack";
                    State.get "Unit domain.Store.AfterTable_By_Callstack";
                    State.get "Unit domain.Store.AfterTable";
                    State.get "Transfer_stmt.InOutCallback";
                    State.get "Transfer_stmt.DumpFileCounters";
                    State.get
                      "Symbolic locations domain.Store.Table_By_Callstack";
                    State.get "Symbolic locations domain.Store.Table";
                    State.get "Symbolic locations domain.Store.Storage";
                    State.get "Symbolic locations domain.Store.Global_State";
                    State.get
                      "Symbolic locations domain.Store.Called_Functions_Memo";
                    State.get
                      "Symbolic locations domain.Store.Called_Functions_By_Callstack";
                    State.get
                      "Symbolic locations domain.Store.AfterTable_By_Callstack";
                    State.get "Symbolic locations domain.Store.AfterTable";
                    State.get "Subgraph of Callgraph.Services";
                    State.get "Subgraph of Callgraph.Cg";
                    State.get "Studia.Highlighter.WritesOrRead";
                    State.get "Studia.Highlighter.StudiaState";
                    State.get "Sparecode without unused globals";
                    State.get "Sparecode";
                    State.get "Slicing_gui.State";
                    State.get "Slicing.Project";
                    State.get "Semantical constant propagation";
                    State.get "Scope.Datatscope.ModifsEdge";
                    State.get "Report.print_once";
                    State.get "Report.print_csv_once";
                    State.get "Report.classify_once";
                    State.get "Property_status.Valid_cycles";
                    State.get "Property_status.Status";
                    State.get "Property_status.Hypotheses";
                    State.get "Property_status.Consolidated_status";
                    State.get "Printer domain.Store.Table_By_Callstack";
                    State.get "Printer domain.Store.Table";
                    State.get "Printer domain.Store.Storage";
                    State.get "Printer domain.Store.Global_State";
                    State.get "Printer domain.Store.Called_Functions_Memo";
                    State.get
                      "Printer domain.Store.Called_Functions_By_Callstack";
                    State.get "Printer domain.Store.AfterTable_By_Callstack";
                    State.get "Printer domain.Store.AfterTable";
                    State.get "Pdg.State";
                    State.get "Pdg.Register.compute_once";
                    State.get "Operational_inputs.MemExec";
                    State.get "Octagon domain.Store.Table_By_Callstack";
                    State.get "Octagon domain.Store.Table";
                    State.get "Octagon domain.Store.Storage";
                    State.get "Octagon domain.Store.Global_State";
                    State.get "Octagon domain.Store.Called_Functions_Memo";
                    State.get
                      "Octagon domain.Store.Called_Functions_By_Callstack";
                    State.get "Octagon domain.Store.AfterTable_By_Callstack";
                    State.get "Octagon domain.Store.AfterTable";
                    State.get "Occurrences.State";
                    State.get "Occurrences.LastResult";
                    State.get "Occurrence_gui.State";
                    State.get "Occurrence.compute";
                    State.get "Nonterm.run";
                    State.get "Metrics_coverage.Kf_coverage";
                    State.get "Metrics_acsl.Global_acsl_stats";
                    State.get "Metrics_acsl.Functions_acsl_stats";
                    State.get "Metrics_acsl.Computed";
                    State.get "Mem_exec.PreviousCalls(1)";
                    State.get "LogicUsage.compute";
                    State.get "Inout.Register.ShouldOuput";
                    State.get "Inout.Outputs.Externals";
                    State.get "Inout.Operational_inputs.Internals";
                    State.get
                      "Inout.Operational_inputs.Externals_With_Formals";
                    State.get "Inout.Operational_inputs.CallwiseResults";
                    State.get "Inout.Inputs.Externals";
                    State.get "Inout.Derefs.Externals";
                    State.get "Inout.Cumulative_analysis.Memo(outputs)";
                    State.get "Inout.Cumulative_analysis.Memo(inputs)";
                    State.get "Inout.Cumulative_analysis.Memo(derefs)";
                    State.get "Impact_gui.SelectedStmt";
                    State.get "Impact_gui.Highlighted_stmt";
                    State.get "Impact.Register_gui.ReasonGraph";
                    State.get "Impact.Register_gui.InitialNodes";
                    State.get "Impact.Register_gui.ImpactedNodes";
                    State.get "Gauges domain.Store.Table_By_Callstack";
                    State.get "Gauges domain.Store.Table";
                    State.get "Gauges domain.Store.Storage";
                    State.get "Gauges domain.Store.Global_State";
                    State.get "Gauges domain.Store.Called_Functions_Memo";
                    State.get
                      "Gauges domain.Store.Called_Functions_By_Callstack";
                    State.get "Gauges domain.Store.AfterTable_By_Callstack";
                    State.get "Gauges domain.Store.AfterTable";
                    State.get "Functionwise dependencies";
                    State.get "From.Callwise.MemExec";
                    State.get "File.Implicit_annotations";
                    State.get "External inouts full";
                    State.get "Eva.Builtins.BuiltinsOverride";
                    State.get "Equality domain.Store.Table_By_Callstack";
                    State.get "Equality domain.Store.Table";
                    State.get "Equality domain.Store.Storage";
                    State.get "Equality domain.Store.Global_State";
                    State.get "Equality domain.Store.Called_Functions_Memo";
                    State.get
                      "Equality domain.Store.Called_Functions_By_Callstack";
                    State.get "Equality domain.Store.AfterTable_By_Callstack";
                    State.get "Equality domain.Store.AfterTable";
                    State.get "Dpds_gui.Highlighter.ZonesState";
                    State.get "Dpds_gui.Highlighter.ShowDef";
                    State.get "Dpds_gui.Highlighter.Pscope_warn";
                    State.get "Dpds_gui.Highlighter.Pscope";
                    State.get "Dpds_gui.Highlighter.Fscope";
                    State.get "Dpds_gui.Highlighter.FBscope";
                    State.get "Dpds_gui.Highlighter.DpdsState";
                    State.get "Dpds_gui.Highlighter.Bscope";
                    State.get "Db.Value.fun_args";
                    State.get "Db.Value.Table_By_Callstack";
                    State.get "Db.Value.Table";
                    State.get "Db.Value.RecursiveCallsFound";
                    State.get "Db.Value.Conditions_table";
                    State.get "Db.Value.Called_Functions_Memo";
                    State.get "Db.Value.Called_Functions_By_Callstack";
                    State.get "Db.Value.AfterTable_By_Callstack";
                    State.get "Db.Value.AfterTable";
                    State.get "Cvalue domain.Storage";
                    State.get "Constant_Propagation.compute";
                    State.get "Consolidation graph";
                    State.get "Callwise dependencies";
                    State.get "Callgraph.Usesiter_in_rev_order";
                    State.get "Callgraph.Usesiter_in_order";
                    State.get "Callgraph.Services";
                    State.get "Callgraph.Cg";
                    State.get "Bitwise domain.Store.Table_By_Callstack";
                    State.get "Bitwise domain.Store.Table";
                    State.get "Bitwise domain.Store.Storage";
                    State.get "Bitwise domain.Store.Global_State";
                    State.get "Bitwise domain.Store.Called_Functions_Memo";
                    State.get
                      "Bitwise domain.Store.Called_Functions_By_Callstack";
                    State.get "Bitwise domain.Store.AfterTable_By_Callstack";
                    State.get "Bitwise domain.Store.AfterTable";
                    State.get "Annotations.Code_annots";
                    State.get "Alarms.State";
                    State.get "-pdgShouldOutput";
                    State.get "-metrics-eva-coverShouldOutput";
                    State.get "-main";
                    State.get "-lib-entry";
                    State.get "-evaShouldOutput";
                    State.get "-depsShouldOutput";
                    State.get "-calldepsShouldOutput";
                    State.get "!Db.Value.compute";
                    State.get "!Db.From.compute_all" ])
    ();
  Dynamic.Parameter.String.unsafe_set "-main" "thread1";
  Dynamic.Parameter.Bool.unsafe_set "-lib-entry" false;
  (failwith "Function cannot be journalized: Db.Value.globals_set_initial_state" : _ -> unit)
    (failwith "no printer registered for value of type (Offsetmap(Cvalue.V_Or_Uninitialized.t), Cvalue.Default_offsetmap) Lmap:
                running the journal will fail.") ;
  (failwith "Function cannot be journalized: Db.Value.fun_set_args" : _ -> unit)
    (failwith "no code for pretty printer of type (Base.t, ival) ptmap mapset_lattice list:
                running the journal will fail.") ;
  !Db.Value.compute ();
  let __ = Callgraph.Cg.get () in
  let __ = Callgraph.Cg.get () in
  Project.clear
    ~selection:(State_selection.of_list
                  [ State.get "sign.Store.Table_By_Callstack";
                    State.get "sign.Store.Table";
                    State.get "sign.Store.Storage";
                    State.get "sign.Store.Global_State";
                    State.get "sign.Store.Called_Functions_Memo";
                    State.get "sign.Store.Called_Functions_By_Callstack";
                    State.get "sign.Store.AfterTable_By_Callstack";
                    State.get "sign.Store.AfterTable";
                    State.get "postdominator.value";
                    State.get "inout.Store.Table_By_Callstack";
                    State.get "inout.Store.Table";
                    State.get "inout.Store.Storage";
                    State.get "inout.Store.Global_State";
                    State.get "inout.Store.Called_Functions_Memo";
                    State.get "inout.Store.Called_Functions_By_Callstack";
                    State.get "inout.Store.AfterTable_By_Callstack";
                    State.get "inout.Store.AfterTable";
                    State.get "WpPropertyIndex";
                    State.get "Wp.WpPropId.Names3.Index";
                    State.get "Wp.WpPropId.Names2.Index";
                    State.get "Wp.WpPropId.Names.Index";
                    State.get "Wp.LogicUsage.Database";
                    State.get "Widen.Per_Function_Hints";
                    State.get "Widen.Parsed_Dynamic_Hints";
                    State.get "Widen.Dynamic_Hints";
                    State.get "Value_util.Degeneration";
                    State.get "Value_messages.Alarm_cache";
                    State.get "Value.Value_results.is_called";
                    State.get "Value.Value_results.Callers";
                    State.get
                      "Value.Traces_domain.Traces.state.Store.Table_By_Callstack";
                    State.get "Value.Traces_domain.Traces.state.Store.Table";
                    State.get
                      "Value.Traces_domain.Traces.state.Store.Storage";
                    State.get
                      "Value.Traces_domain.Traces.state.Store.Global_State";
                    State.get
                      "Value.Traces_domain.Traces.state.Store.Called_Functions_Memo";
                    State.get
                      "Value.Traces_domain.Traces.state.Store.Called_Functions_By_Callstack";
                    State.get
                      "Value.Traces_domain.Traces.state.Store.AfterTable_By_Callstack";
                    State.get
                      "Value.Traces_domain.Traces.state.Store.AfterTable";
                    State.get "Value.Red_statuses.RedStatusesTable";
                    State.get "Value.Initialization(1)";
                    State.get "Value.Gui.UsedVarState";
                    State.get "Users_register.print";
                    State.get "Users";
                    State.get "Unit domain.Store.Table_By_Callstack";
                    State.get "Unit domain.Store.Table";
                    State.get "Unit domain.Store.Storage";
                    State.get "Unit domain.Store.Global_State";
                    State.get "Unit domain.Store.Called_Functions_Memo";
                    State.get
                      "Unit domain.Store.Called_Functions_By_Callstack";
                    State.get "Unit domain.Store.AfterTable_By_Callstack";
                    State.get "Unit domain.Store.AfterTable";
                    State.get "Transfer_stmt.InOutCallback";
                    State.get "Transfer_stmt.DumpFileCounters";
                    State.get
                      "Symbolic locations domain.Store.Table_By_Callstack";
                    State.get "Symbolic locations domain.Store.Table";
                    State.get "Symbolic locations domain.Store.Storage";
                    State.get "Symbolic locations domain.Store.Global_State";
                    State.get
                      "Symbolic locations domain.Store.Called_Functions_Memo";
                    State.get
                      "Symbolic locations domain.Store.Called_Functions_By_Callstack";
                    State.get
                      "Symbolic locations domain.Store.AfterTable_By_Callstack";
                    State.get "Symbolic locations domain.Store.AfterTable";
                    State.get "Subgraph of Callgraph.Services";
                    State.get "Subgraph of Callgraph.Cg";
                    State.get "Studia.Highlighter.WritesOrRead";
                    State.get "Studia.Highlighter.StudiaState";
                    State.get "Sparecode without unused globals";
                    State.get "Sparecode";
                    State.get "Slicing_gui.State";
                    State.get "Slicing.Project";
                    State.get "Semantical constant propagation";
                    State.get "Scope.Datatscope.ModifsEdge";
                    State.get "Report.print_once";
                    State.get "Report.print_csv_once";
                    State.get "Report.classify_once";
                    State.get "Property_status.Valid_cycles";
                    State.get "Property_status.Status";
                    State.get "Property_status.Hypotheses";
                    State.get "Property_status.Consolidated_status";
                    State.get "Printer domain.Store.Table_By_Callstack";
                    State.get "Printer domain.Store.Table";
                    State.get "Printer domain.Store.Storage";
                    State.get "Printer domain.Store.Global_State";
                    State.get "Printer domain.Store.Called_Functions_Memo";
                    State.get
                      "Printer domain.Store.Called_Functions_By_Callstack";
                    State.get "Printer domain.Store.AfterTable_By_Callstack";
                    State.get "Printer domain.Store.AfterTable";
                    State.get "Pdg.State";
                    State.get "Pdg.Register.compute_once";
                    State.get "Operational_inputs.MemExec";
                    State.get "Octagon domain.Store.Table_By_Callstack";
                    State.get "Octagon domain.Store.Table";
                    State.get "Octagon domain.Store.Storage";
                    State.get "Octagon domain.Store.Global_State";
                    State.get "Octagon domain.Store.Called_Functions_Memo";
                    State.get
                      "Octagon domain.Store.Called_Functions_By_Callstack";
                    State.get "Octagon domain.Store.AfterTable_By_Callstack";
                    State.get "Octagon domain.Store.AfterTable";
                    State.get "Occurrences.State";
                    State.get "Occurrences.LastResult";
                    State.get "Occurrence_gui.State";
                    State.get "Occurrence.compute";
                    State.get "Nonterm.run";
                    State.get "Metrics_coverage.Kf_coverage";
                    State.get "Metrics_acsl.Global_acsl_stats";
                    State.get "Metrics_acsl.Functions_acsl_stats";
                    State.get "Metrics_acsl.Computed";
                    State.get "Mem_exec.PreviousCalls(1)";
                    State.get "LogicUsage.compute";
                    State.get "Inout.Register.ShouldOuput";
                    State.get "Inout.Outputs.Externals";
                    State.get "Inout.Operational_inputs.Internals";
                    State.get
                      "Inout.Operational_inputs.Externals_With_Formals";
                    State.get "Inout.Operational_inputs.CallwiseResults";
                    State.get "Inout.Inputs.Externals";
                    State.get "Inout.Derefs.Externals";
                    State.get "Inout.Cumulative_analysis.Memo(outputs)";
                    State.get "Inout.Cumulative_analysis.Memo(inputs)";
                    State.get "Inout.Cumulative_analysis.Memo(derefs)";
                    State.get "Impact_gui.SelectedStmt";
                    State.get "Impact_gui.Highlighted_stmt";
                    State.get "Impact.Register_gui.ReasonGraph";
                    State.get "Impact.Register_gui.InitialNodes";
                    State.get "Impact.Register_gui.ImpactedNodes";
                    State.get "Gauges domain.Store.Table_By_Callstack";
                    State.get "Gauges domain.Store.Table";
                    State.get "Gauges domain.Store.Storage";
                    State.get "Gauges domain.Store.Global_State";
                    State.get "Gauges domain.Store.Called_Functions_Memo";
                    State.get
                      "Gauges domain.Store.Called_Functions_By_Callstack";
                    State.get "Gauges domain.Store.AfterTable_By_Callstack";
                    State.get "Gauges domain.Store.AfterTable";
                    State.get "Functionwise dependencies";
                    State.get "From.Callwise.MemExec";
                    State.get "File.Implicit_annotations";
                    State.get "External inouts full";
                    State.get "Eva.Builtins.BuiltinsOverride";
                    State.get "Equality domain.Store.Table_By_Callstack";
                    State.get "Equality domain.Store.Table";
                    State.get "Equality domain.Store.Storage";
                    State.get "Equality domain.Store.Global_State";
                    State.get "Equality domain.Store.Called_Functions_Memo";
                    State.get
                      "Equality domain.Store.Called_Functions_By_Callstack";
                    State.get "Equality domain.Store.AfterTable_By_Callstack";
                    State.get "Equality domain.Store.AfterTable";
                    State.get "Dpds_gui.Highlighter.ZonesState";
                    State.get "Dpds_gui.Highlighter.ShowDef";
                    State.get "Dpds_gui.Highlighter.Pscope_warn";
                    State.get "Dpds_gui.Highlighter.Pscope";
                    State.get "Dpds_gui.Highlighter.Fscope";
                    State.get "Dpds_gui.Highlighter.FBscope";
                    State.get "Dpds_gui.Highlighter.DpdsState";
                    State.get "Dpds_gui.Highlighter.Bscope";
                    State.get "Db.Value.fun_args";
                    State.get "Db.Value.Table_By_Callstack";
                    State.get "Db.Value.Table";
                    State.get "Db.Value.RecursiveCallsFound";
                    State.get "Db.Value.Conditions_table";
                    State.get "Db.Value.Called_Functions_Memo";
                    State.get "Db.Value.Called_Functions_By_Callstack";
                    State.get "Db.Value.AfterTable_By_Callstack";
                    State.get "Db.Value.AfterTable";
                    State.get "Cvalue domain.Storage";
                    State.get "Constant_Propagation.compute";
                    State.get "Consolidation graph";
                    State.get "Callwise dependencies";
                    State.get "Callgraph.Usesiter_in_rev_order";
                    State.get "Callgraph.Usesiter_in_order";
                    State.get "Callgraph.Services";
                    State.get "Callgraph.Cg";
                    State.get "Bitwise domain.Store.Table_By_Callstack";
                    State.get "Bitwise domain.Store.Table";
                    State.get "Bitwise domain.Store.Storage";
                    State.get "Bitwise domain.Store.Global_State";
                    State.get "Bitwise domain.Store.Called_Functions_Memo";
                    State.get
                      "Bitwise domain.Store.Called_Functions_By_Callstack";
                    State.get "Bitwise domain.Store.AfterTable_By_Callstack";
                    State.get "Bitwise domain.Store.AfterTable";
                    State.get "Annotations.Code_annots";
                    State.get "Alarms.State";
                    State.get "-pdgShouldOutput";
                    State.get "-metrics-eva-coverShouldOutput";
                    State.get "-main";
                    State.get "-lib-entry";
                    State.get "-evaShouldOutput";
                    State.get "-depsShouldOutput";
                    State.get "-calldepsShouldOutput";
                    State.get "!Db.Value.compute";
                    State.get "!Db.From.compute_all" ])
    ();
  Dynamic.Parameter.String.unsafe_set "-main" "thread2";
  Dynamic.Parameter.Bool.unsafe_set "-lib-entry" false;
  (failwith "Function cannot be journalized: Db.Value.globals_set_initial_state" : _ -> unit)
    (failwith "no printer registered for value of type (Offsetmap(Cvalue.V_Or_Uninitialized.t), Cvalue.Default_offsetmap) Lmap:
                running the journal will fail.") ;
  (failwith "Function cannot be journalized: Db.Value.fun_set_args" : _ -> unit)
    (failwith "no code for pretty printer of type (Base.t, ival) ptmap mapset_lattice list:
                running the journal will fail.") ;
  !Db.Value.compute ();
  let __ = Callgraph.Cg.get () in
  let __ = Callgraph.Cg.get () in
  Project.clear
    ~selection:(State_selection.of_list
                  [ State.get "sign.Store.Table_By_Callstack";
                    State.get "sign.Store.Table";
                    State.get "sign.Store.Storage";
                    State.get "sign.Store.Global_State";
                    State.get "sign.Store.Called_Functions_Memo";
                    State.get "sign.Store.Called_Functions_By_Callstack";
                    State.get "sign.Store.AfterTable_By_Callstack";
                    State.get "sign.Store.AfterTable";
                    State.get "postdominator.value";
                    State.get "inout.Store.Table_By_Callstack";
                    State.get "inout.Store.Table";
                    State.get "inout.Store.Storage";
                    State.get "inout.Store.Global_State";
                    State.get "inout.Store.Called_Functions_Memo";
                    State.get "inout.Store.Called_Functions_By_Callstack";
                    State.get "inout.Store.AfterTable_By_Callstack";
                    State.get "inout.Store.AfterTable";
                    State.get "Widen.Per_Function_Hints";
                    State.get "Widen.Parsed_Dynamic_Hints";
                    State.get "Widen.Dynamic_Hints";
                    State.get "Value_util.Degeneration";
                    State.get "Value_messages.Alarm_cache";
                    State.get "Value.Value_results.is_called";
                    State.get "Value.Value_results.Callers";
                    State.get
                      "Value.Traces_domain.Traces.state.Store.Table_By_Callstack";
                    State.get "Value.Traces_domain.Traces.state.Store.Table";
                    State.get
                      "Value.Traces_domain.Traces.state.Store.Storage";
                    State.get
                      "Value.Traces_domain.Traces.state.Store.Global_State";
                    State.get
                      "Value.Traces_domain.Traces.state.Store.Called_Functions_Memo";
                    State.get
                      "Value.Traces_domain.Traces.state.Store.Called_Functions_By_Callstack";
                    State.get
                      "Value.Traces_domain.Traces.state.Store.AfterTable_By_Callstack";
                    State.get
                      "Value.Traces_domain.Traces.state.Store.AfterTable";
                    State.get "Value.Red_statuses.RedStatusesTable";
                    State.get "Value.Gui.UsedVarState";
                    State.get "Users_register.print";
                    State.get "Users";
                    State.get "Unit domain.Store.Table_By_Callstack";
                    State.get "Unit domain.Store.Table";
                    State.get "Unit domain.Store.Storage";
                    State.get "Unit domain.Store.Global_State";
                    State.get "Unit domain.Store.Called_Functions_Memo";
                    State.get
                      "Unit domain.Store.Called_Functions_By_Callstack";
                    State.get "Unit domain.Store.AfterTable_By_Callstack";
                    State.get "Unit domain.Store.AfterTable";
                    State.get "Transfer_stmt.InOutCallback";
                    State.get "Transfer_stmt.DumpFileCounters";
                    State.get
                      "Symbolic locations domain.Store.Table_By_Callstack";
                    State.get "Symbolic locations domain.Store.Table";
                    State.get "Symbolic locations domain.Store.Storage";
                    State.get "Symbolic locations domain.Store.Global_State";
                    State.get
                      "Symbolic locations domain.Store.Called_Functions_Memo";
                    State.get
                      "Symbolic locations domain.Store.Called_Functions_By_Callstack";
                    State.get
                      "Symbolic locations domain.Store.AfterTable_By_Callstack";
                    State.get "Symbolic locations domain.Store.AfterTable";
                    State.get "Subgraph of Callgraph.Services";
                    State.get "Subgraph of Callgraph.Cg";
                    State.get "Studia.Highlighter.WritesOrRead";
                    State.get "Studia.Highlighter.StudiaState";
                    State.get "Sparecode without unused globals";
                    State.get "Sparecode";
                    State.get "Slicing_gui.State";
                    State.get "Slicing.Project";
                    State.get "Semantical constant propagation";
                    State.get "Scope.Datatscope.ModifsEdge";
                    State.get "Printer domain.Store.Table_By_Callstack";
                    State.get "Printer domain.Store.Table";
                    State.get "Printer domain.Store.Storage";
                    State.get "Printer domain.Store.Global_State";
                    State.get "Printer domain.Store.Called_Functions_Memo";
                    State.get
                      "Printer domain.Store.Called_Functions_By_Callstack";
                    State.get "Printer domain.Store.AfterTable_By_Callstack";
                    State.get "Printer domain.Store.AfterTable";
                    State.get "Pdg.State";
                    State.get "Pdg.Register.compute_once";
                    State.get "Operational_inputs.MemExec";
                    State.get "Octagon domain.Store.Table_By_Callstack";
                    State.get "Octagon domain.Store.Table";
                    State.get "Octagon domain.Store.Storage";
                    State.get "Octagon domain.Store.Global_State";
                    State.get "Octagon domain.Store.Called_Functions_Memo";
                    State.get
                      "Octagon domain.Store.Called_Functions_By_Callstack";
                    State.get "Octagon domain.Store.AfterTable_By_Callstack";
                    State.get "Octagon domain.Store.AfterTable";
                    State.get "Occurrences.State";
                    State.get "Occurrences.LastResult";
                    State.get "Occurrence_gui.State";
                    State.get "Occurrence.compute";
                    State.get "Nonterm.run";
                    State.get "Metrics_coverage.Kf_coverage";
                    State.get "Mem_exec.PreviousCalls(1)";
                    State.get "Inout.Register.ShouldOuput";
                    State.get "Inout.Outputs.Externals";
                    State.get "Inout.Operational_inputs.Internals";
                    State.get
                      "Inout.Operational_inputs.Externals_With_Formals";
                    State.get "Inout.Operational_inputs.CallwiseResults";
                    State.get "Inout.Inputs.Externals";
                    State.get "Inout.Derefs.Externals";
                    State.get "Inout.Cumulative_analysis.Memo(outputs)";
                    State.get "Inout.Cumulative_analysis.Memo(inputs)";
                    State.get "Inout.Cumulative_analysis.Memo(derefs)";
                    State.get "Impact_gui.SelectedStmt";
                    State.get "Impact_gui.Highlighted_stmt";
                    State.get "Impact.Register_gui.ReasonGraph";
                    State.get "Impact.Register_gui.InitialNodes";
                    State.get "Impact.Register_gui.ImpactedNodes";
                    State.get "Gauges domain.Store.Table_By_Callstack";
                    State.get "Gauges domain.Store.Table";
                    State.get "Gauges domain.Store.Storage";
                    State.get "Gauges domain.Store.Global_State";
                    State.get "Gauges domain.Store.Called_Functions_Memo";
                    State.get
                      "Gauges domain.Store.Called_Functions_By_Callstack";
                    State.get "Gauges domain.Store.AfterTable_By_Callstack";
                    State.get "Gauges domain.Store.AfterTable";
                    State.get "Functionwise dependencies";
                    State.get "From.Callwise.MemExec";
                    State.get "External inouts full";
                    State.get "Eva.Builtins.BuiltinsOverride";
                    State.get "Equality domain.Store.Table_By_Callstack";
                    State.get "Equality domain.Store.Table";
                    State.get "Equality domain.Store.Storage";
                    State.get "Equality domain.Store.Global_State";
                    State.get "Equality domain.Store.Called_Functions_Memo";
                    State.get
                      "Equality domain.Store.Called_Functions_By_Callstack";
                    State.get "Equality domain.Store.AfterTable_By_Callstack";
                    State.get "Equality domain.Store.AfterTable";
                    State.get "Dpds_gui.Highlighter.ZonesState";
                    State.get "Dpds_gui.Highlighter.ShowDef";
                    State.get "Dpds_gui.Highlighter.Pscope_warn";
                    State.get "Dpds_gui.Highlighter.Pscope";
                    State.get "Dpds_gui.Highlighter.Fscope";
                    State.get "Dpds_gui.Highlighter.FBscope";
                    State.get "Dpds_gui.Highlighter.DpdsState";
                    State.get "Dpds_gui.Highlighter.Bscope";
                    State.get "Db.Value.Table_By_Callstack";
                    State.get "Db.Value.Table";
                    State.get "Db.Value.RecursiveCallsFound";
                    State.get "Db.Value.Conditions_table";
                    State.get "Db.Value.Called_Functions_Memo";
                    State.get "Db.Value.Called_Functions_By_Callstack";
                    State.get "Db.Value.AfterTable_By_Callstack";
                    State.get "Db.Value.AfterTable";
                    State.get "Cvalue domain.Storage";
                    State.get "Constant_Propagation.compute";
                    State.get "Callwise dependencies";
                    State.get "Callgraph.Usesiter_in_rev_order";
                    State.get "Callgraph.Usesiter_in_order";
                    State.get "Callgraph.Services";
                    State.get "Callgraph.Cg";
                    State.get "Bitwise domain.Store.Table_By_Callstack";
                    State.get "Bitwise domain.Store.Table";
                    State.get "Bitwise domain.Store.Storage";
                    State.get "Bitwise domain.Store.Global_State";
                    State.get "Bitwise domain.Store.Called_Functions_Memo";
                    State.get
                      "Bitwise domain.Store.Called_Functions_By_Callstack";
                    State.get "Bitwise domain.Store.AfterTable_By_Callstack";
                    State.get "Bitwise domain.Store.AfterTable";
                    State.get "-pdgShouldOutput";
                    State.get "-metrics-eva-coverShouldOutput";
                    State.get "-evaShouldOutput";
                    State.get "-depsShouldOutput";
                    State.get "-calldepsShouldOutput";
                    State.get "!Db.Value.compute";
                    State.get "!Db.From.compute_all" ])
    ();
  (failwith "Function cannot be journalized: Db.Value.globals_set_initial_state" : _ -> unit)
    (failwith "no printer registered for value of type (Offsetmap(Cvalue.V_Or_Uninitialized.t), Cvalue.Default_offsetmap) Lmap:
                running the journal will fail.") ;
  Db.Value.fun_use_default_args ();
  Project.clear
    ~selection:(State_selection.of_list
                  [ State.get "Report.print_once";
                    State.get "Report.print_csv_once";
                    State.get "Report.classify_once";
                    State.get "Property_status.Consolidated_status";
                    State.get "Consolidation graph" ])
    ();
  Project.clear
    ~selection:(State_selection.of_list
                  [ State.get "Report.print_once";
                    State.get "Report.print_csv_once";
                    State.get "Report.classify_once";
                    State.get "Property_status.Consolidated_status";
                    State.get "Consolidation graph" ])
    ();
  Project.clear
    ~selection:(State_selection.of_list
                  [ State.get "Report.print_once";
                    State.get "Report.print_csv_once";
                    State.get "Report.classify_once";
                    State.get "Property_status.Consolidated_status";
                    State.get "Consolidation graph" ])
    ();
  Project.clear
    ~selection:(State_selection.of_list
                  [ State.get "Report.print_once";
                    State.get "Report.print_csv_once";
                    State.get "Report.classify_once";
                    State.get "Property_status.Consolidated_status";
                    State.get "Consolidation graph" ])
    ();
  Project.clear
    ~selection:(State_selection.of_list
                  [ State.get "Report.print_once";
                    State.get "Report.print_csv_once";
                    State.get "Report.classify_once";
                    State.get "Property_status.Consolidated_status";
                    State.get "Consolidation graph" ])
    ();
  Project.clear
    ~selection:(State_selection.of_list
                  [ State.get "Report.print_once";
                    State.get "Report.print_csv_once";
                    State.get "Report.classify_once";
                    State.get "Property_status.Consolidated_status";
                    State.get "Consolidation graph" ])
    ();
  Project.clear
    ~selection:(State_selection.of_list
                  [ State.get "Report.print_once";
                    State.get "Report.print_csv_once";
                    State.get "Report.classify_once";
                    State.get "Property_status.Consolidated_status";
                    State.get "Consolidation graph" ])
    ();
  Project.clear
    ~selection:(State_selection.of_list
                  [ State.get "Report.print_once";
                    State.get "Report.print_csv_once";
                    State.get "Report.classify_once";
                    State.get "Property_status.Consolidated_status";
                    State.get "Consolidation graph" ])
    ();
  Project.clear
    ~selection:(State_selection.of_list
                  [ State.get "Report.print_once";
                    State.get "Report.print_csv_once";
                    State.get "Report.classify_once";
                    State.get "Property_status.Consolidated_status";
                    State.get "Consolidation graph" ])
    ();
  Project.clear
    ~selection:(State_selection.of_list
                  [ State.get "Report.print_once";
                    State.get "Report.print_csv_once";
                    State.get "Report.classify_once";
                    State.get "Property_status.Consolidated_status";
                    State.get "Consolidation graph" ])
    ();
  Project.clear
    ~selection:(State_selection.of_list
                  [ State.get "Report.print_once";
                    State.get "Report.print_csv_once";
                    State.get "Report.classify_once";
                    State.get "Property_status.Consolidated_status";
                    State.get "Consolidation graph" ])
    ();
  Project.clear
    ~selection:(State_selection.of_list
                  [ State.get "Report.print_once";
                    State.get "Report.print_csv_once";
                    State.get "Report.classify_once";
                    State.get "Property_status.Consolidated_status";
                    State.get "Consolidation graph" ])
    ();
  Project.clear
    ~selection:(State_selection.of_list
                  [ State.get "Report.print_once";
                    State.get "Report.print_csv_once";
                    State.get "Report.classify_once";
                    State.get "Property_status.Consolidated_status";
                    State.get "Consolidation graph" ])
    ();
  Project.clear
    ~selection:(State_selection.of_list
                  [ State.get "Report.print_once";
                    State.get "Report.print_csv_once";
                    State.get "Report.classify_once";
                    State.get "Property_status.Consolidated_status";
                    State.get "Consolidation graph" ])
    ();
  Project.clear
    ~selection:(State_selection.of_list
                  [ State.get "Report.print_once";
                    State.get "Report.print_csv_once";
                    State.get "Report.classify_once";
                    State.get "Property_status.Consolidated_status";
                    State.get "Consolidation graph" ])
    ();
  Project.clear
    ~selection:(State_selection.of_list
                  [ State.get "Report.print_once";
                    State.get "Report.print_csv_once";
                    State.get "Report.classify_once";
                    State.get "Property_status.Consolidated_status";
                    State.get "Consolidation graph" ])
    ();
  Project.clear
    ~selection:(State_selection.of_list
                  [ State.get "Report.print_once";
                    State.get "Report.print_csv_once";
                    State.get "Report.classify_once";
                    State.get "Property_status.Consolidated_status";
                    State.get "Consolidation graph" ])
    ();
  Project.clear
    ~selection:(State_selection.of_list
                  [ State.get "Report.print_once";
                    State.get "Report.print_csv_once";
                    State.get "Report.classify_once";
                    State.get "Property_status.Consolidated_status";
                    State.get "Consolidation graph" ])
    ();
  Project.clear
    ~selection:(State_selection.of_list
                  [ State.get "Report.print_once";
                    State.get "Report.print_csv_once";
                    State.get "Report.classify_once";
                    State.get "Property_status.Consolidated_status";
                    State.get "Consolidation graph" ])
    ();
  Project.clear
    ~selection:(State_selection.of_list
                  [ State.get "Report.print_once";
                    State.get "Report.print_csv_once";
                    State.get "Report.classify_once";
                    State.get "Property_status.Consolidated_status";
                    State.get "Consolidation graph" ])
    ();
  Db.Value.mark_as_computed ();
  Project.clear
    ~selection:(State_selection.of_list
                  [ State.get "sign.Store.Table_By_Callstack";
                    State.get "sign.Store.Table";
                    State.get "sign.Store.Storage";
                    State.get "sign.Store.Global_State";
                    State.get "sign.Store.Called_Functions_Memo";
                    State.get "sign.Store.Called_Functions_By_Callstack";
                    State.get "sign.Store.AfterTable_By_Callstack";
                    State.get "sign.Store.AfterTable";
                    State.get "postdominator.value";
                    State.get "inout.Store.Table_By_Callstack";
                    State.get "inout.Store.Table";
                    State.get "inout.Store.Storage";
                    State.get "inout.Store.Global_State";
                    State.get "inout.Store.Called_Functions_Memo";
                    State.get "inout.Store.Called_Functions_By_Callstack";
                    State.get "inout.Store.AfterTable_By_Callstack";
                    State.get "inout.Store.AfterTable";
                    State.get "Widen.Per_Function_Hints";
                    State.get "Widen.Parsed_Dynamic_Hints";
                    State.get "Widen.Dynamic_Hints";
                    State.get "Value_util.Degeneration";
                    State.get "Value_messages.Alarm_cache";
                    State.get "Value.Value_results.is_called";
                    State.get "Value.Value_results.Callers";
                    State.get
                      "Value.Traces_domain.Traces.state.Store.Table_By_Callstack";
                    State.get "Value.Traces_domain.Traces.state.Store.Table";
                    State.get
                      "Value.Traces_domain.Traces.state.Store.Storage";
                    State.get
                      "Value.Traces_domain.Traces.state.Store.Global_State";
                    State.get
                      "Value.Traces_domain.Traces.state.Store.Called_Functions_Memo";
                    State.get
                      "Value.Traces_domain.Traces.state.Store.Called_Functions_By_Callstack";
                    State.get
                      "Value.Traces_domain.Traces.state.Store.AfterTable_By_Callstack";
                    State.get
                      "Value.Traces_domain.Traces.state.Store.AfterTable";
                    State.get "Value.Red_statuses.RedStatusesTable";
                    State.get "Value.Gui.UsedVarState";
                    State.get "Users_register.print";
                    State.get "Users";
                    State.get "Unit domain.Store.Table_By_Callstack";
                    State.get "Unit domain.Store.Table";
                    State.get "Unit domain.Store.Storage";
                    State.get "Unit domain.Store.Global_State";
                    State.get "Unit domain.Store.Called_Functions_Memo";
                    State.get
                      "Unit domain.Store.Called_Functions_By_Callstack";
                    State.get "Unit domain.Store.AfterTable_By_Callstack";
                    State.get "Unit domain.Store.AfterTable";
                    State.get "Transfer_stmt.InOutCallback";
                    State.get "Transfer_stmt.DumpFileCounters";
                    State.get
                      "Symbolic locations domain.Store.Table_By_Callstack";
                    State.get "Symbolic locations domain.Store.Table";
                    State.get "Symbolic locations domain.Store.Storage";
                    State.get "Symbolic locations domain.Store.Global_State";
                    State.get
                      "Symbolic locations domain.Store.Called_Functions_Memo";
                    State.get
                      "Symbolic locations domain.Store.Called_Functions_By_Callstack";
                    State.get
                      "Symbolic locations domain.Store.AfterTable_By_Callstack";
                    State.get "Symbolic locations domain.Store.AfterTable";
                    State.get "Subgraph of Callgraph.Services";
                    State.get "Subgraph of Callgraph.Cg";
                    State.get "Studia.Highlighter.WritesOrRead";
                    State.get "Studia.Highlighter.StudiaState";
                    State.get "Sparecode without unused globals";
                    State.get "Sparecode";
                    State.get "Slicing_gui.State";
                    State.get "Slicing.Project";
                    State.get "Semantical constant propagation";
                    State.get "Scope.Datatscope.ModifsEdge";
                    State.get "Printer domain.Store.Table_By_Callstack";
                    State.get "Printer domain.Store.Table";
                    State.get "Printer domain.Store.Storage";
                    State.get "Printer domain.Store.Global_State";
                    State.get "Printer domain.Store.Called_Functions_Memo";
                    State.get
                      "Printer domain.Store.Called_Functions_By_Callstack";
                    State.get "Printer domain.Store.AfterTable_By_Callstack";
                    State.get "Printer domain.Store.AfterTable";
                    State.get "Pdg.State";
                    State.get "Pdg.Register.compute_once";
                    State.get "Operational_inputs.MemExec";
                    State.get "Octagon domain.Store.Table_By_Callstack";
                    State.get "Octagon domain.Store.Table";
                    State.get "Octagon domain.Store.Storage";
                    State.get "Octagon domain.Store.Global_State";
                    State.get "Octagon domain.Store.Called_Functions_Memo";
                    State.get
                      "Octagon domain.Store.Called_Functions_By_Callstack";
                    State.get "Octagon domain.Store.AfterTable_By_Callstack";
                    State.get "Octagon domain.Store.AfterTable";
                    State.get "Occurrences.State";
                    State.get "Occurrences.LastResult";
                    State.get "Occurrence_gui.State";
                    State.get "Occurrence.compute";
                    State.get "Nonterm.run";
                    State.get "Metrics_coverage.Kf_coverage";
                    State.get "Mem_exec.PreviousCalls(1)";
                    State.get "Inout.Register.ShouldOuput";
                    State.get "Inout.Outputs.Externals";
                    State.get "Inout.Operational_inputs.Internals";
                    State.get
                      "Inout.Operational_inputs.Externals_With_Formals";
                    State.get "Inout.Operational_inputs.CallwiseResults";
                    State.get "Inout.Inputs.Externals";
                    State.get "Inout.Derefs.Externals";
                    State.get "Inout.Cumulative_analysis.Memo(outputs)";
                    State.get "Inout.Cumulative_analysis.Memo(inputs)";
                    State.get "Inout.Cumulative_analysis.Memo(derefs)";
                    State.get "Impact_gui.SelectedStmt";
                    State.get "Impact_gui.Highlighted_stmt";
                    State.get "Impact.Register_gui.ReasonGraph";
                    State.get "Impact.Register_gui.InitialNodes";
                    State.get "Impact.Register_gui.ImpactedNodes";
                    State.get "Gauges domain.Store.Table_By_Callstack";
                    State.get "Gauges domain.Store.Table";
                    State.get "Gauges domain.Store.Storage";
                    State.get "Gauges domain.Store.Global_State";
                    State.get "Gauges domain.Store.Called_Functions_Memo";
                    State.get
                      "Gauges domain.Store.Called_Functions_By_Callstack";
                    State.get "Gauges domain.Store.AfterTable_By_Callstack";
                    State.get "Gauges domain.Store.AfterTable";
                    State.get "Functionwise dependencies";
                    State.get "From.Callwise.MemExec";
                    State.get "External inouts full";
                    State.get "Eva.Builtins.BuiltinsOverride";
                    State.get "Equality domain.Store.Table_By_Callstack";
                    State.get "Equality domain.Store.Table";
                    State.get "Equality domain.Store.Storage";
                    State.get "Equality domain.Store.Global_State";
                    State.get "Equality domain.Store.Called_Functions_Memo";
                    State.get
                      "Equality domain.Store.Called_Functions_By_Callstack";
                    State.get "Equality domain.Store.AfterTable_By_Callstack";
                    State.get "Equality domain.Store.AfterTable";
                    State.get "Dpds_gui.Highlighter.ZonesState";
                    State.get "Dpds_gui.Highlighter.ShowDef";
                    State.get "Dpds_gui.Highlighter.Pscope_warn";
                    State.get "Dpds_gui.Highlighter.Pscope";
                    State.get "Dpds_gui.Highlighter.Fscope";
                    State.get "Dpds_gui.Highlighter.FBscope";
                    State.get "Dpds_gui.Highlighter.DpdsState";
                    State.get "Dpds_gui.Highlighter.Bscope";
                    State.get "Db.Value.Table_By_Callstack";
                    State.get "Db.Value.Table";
                    State.get "Db.Value.RecursiveCallsFound";
                    State.get "Db.Value.Conditions_table";
                    State.get "Db.Value.Called_Functions_Memo";
                    State.get "Db.Value.Called_Functions_By_Callstack";
                    State.get "Db.Value.AfterTable_By_Callstack";
                    State.get "Db.Value.AfterTable";
                    State.get "Cvalue domain.Storage";
                    State.get "Constant_Propagation.compute";
                    State.get "Callwise dependencies";
                    State.get "Callgraph.Usesiter_in_rev_order";
                    State.get "Callgraph.Usesiter_in_order";
                    State.get "Callgraph.Services";
                    State.get "Callgraph.Cg";
                    State.get "Bitwise domain.Store.Table_By_Callstack";
                    State.get "Bitwise domain.Store.Table";
                    State.get "Bitwise domain.Store.Storage";
                    State.get "Bitwise domain.Store.Global_State";
                    State.get "Bitwise domain.Store.Called_Functions_Memo";
                    State.get
                      "Bitwise domain.Store.Called_Functions_By_Callstack";
                    State.get "Bitwise domain.Store.AfterTable_By_Callstack";
                    State.get "Bitwise domain.Store.AfterTable";
                    State.get "-pdgShouldOutput";
                    State.get "-metrics-eva-coverShouldOutput";
                    State.get "-evaShouldOutput";
                    State.get "-depsShouldOutput";
                    State.get "-calldepsShouldOutput";
                    State.get "!Db.Value.compute";
                    State.get "!Db.From.compute_all" ])
    ();
  (failwith "Function cannot be journalized: Db.Value.globals_set_initial_state" : _ -> unit)
    (failwith "no printer registered for value of type (Offsetmap(Cvalue.V_Or_Uninitialized.t), Cvalue.Default_offsetmap) Lmap:
                running the journal will fail.") ;
  (failwith "Function cannot be journalized: Db.Value.fun_set_args" : _ -> unit)
    (failwith "no code for pretty printer of type (Base.t, ival) ptmap mapset_lattice list:
                running the journal will fail.") ;
  Project.clear
    ~selection:(State_selection.of_list
                  [ State.get "Report.print_once";
                    State.get "Report.print_csv_once";
                    State.get "Report.classify_once";
                    State.get "Property_status.Consolidated_status";
                    State.get "Consolidation graph" ])
    ();
  Project.clear
    ~selection:(State_selection.of_list
                  [ State.get "Report.print_once";
                    State.get "Report.print_csv_once";
                    State.get "Report.classify_once";
                    State.get "Property_status.Consolidated_status";
                    State.get "Consolidation graph" ])
    ();
  Project.clear
    ~selection:(State_selection.of_list
                  [ State.get "Report.print_once";
                    State.get "Report.print_csv_once";
                    State.get "Report.classify_once";
                    State.get "Property_status.Consolidated_status";
                    State.get "Consolidation graph" ])
    ();
  Project.clear
    ~selection:(State_selection.of_list
                  [ State.get "Report.print_once";
                    State.get "Report.print_csv_once";
                    State.get "Report.classify_once";
                    State.get "Property_status.Consolidated_status";
                    State.get "Consolidation graph" ])
    ();
  Project.clear
    ~selection:(State_selection.of_list
                  [ State.get "Report.print_once";
                    State.get "Report.print_csv_once";
                    State.get "Report.classify_once";
                    State.get "Property_status.Consolidated_status";
                    State.get "Consolidation graph" ])
    ();
  Project.clear
    ~selection:(State_selection.of_list
                  [ State.get "Report.print_once";
                    State.get "Report.print_csv_once";
                    State.get "Report.classify_once";
                    State.get "Property_status.Consolidated_status";
                    State.get "Consolidation graph" ])
    ();
  Project.clear
    ~selection:(State_selection.of_list
                  [ State.get "Report.print_once";
                    State.get "Report.print_csv_once";
                    State.get "Report.classify_once";
                    State.get "Property_status.Consolidated_status";
                    State.get "Consolidation graph" ])
    ();
  Project.clear
    ~selection:(State_selection.of_list
                  [ State.get "Report.print_once";
                    State.get "Report.print_csv_once";
                    State.get "Report.classify_once";
                    State.get "Property_status.Consolidated_status";
                    State.get "Consolidation graph" ])
    ();
  Project.clear
    ~selection:(State_selection.of_list
                  [ State.get "Report.print_once";
                    State.get "Report.print_csv_once";
                    State.get "Report.classify_once";
                    State.get "Property_status.Consolidated_status";
                    State.get "Consolidation graph" ])
    ();
  Project.clear
    ~selection:(State_selection.of_list
                  [ State.get "Report.print_once";
                    State.get "Report.print_csv_once";
                    State.get "Report.classify_once";
                    State.get "Property_status.Consolidated_status";
                    State.get "Consolidation graph" ])
    ();
  Project.clear
    ~selection:(State_selection.of_list
                  [ State.get "Report.print_once";
                    State.get "Report.print_csv_once";
                    State.get "Report.classify_once";
                    State.get "Property_status.Consolidated_status";
                    State.get "Consolidation graph" ])
    ();
  Project.clear
    ~selection:(State_selection.of_list
                  [ State.get "Report.print_once";
                    State.get "Report.print_csv_once";
                    State.get "Report.classify_once";
                    State.get "Property_status.Consolidated_status";
                    State.get "Consolidation graph" ])
    ();
  Project.clear
    ~selection:(State_selection.of_list
                  [ State.get "Report.print_once";
                    State.get "Report.print_csv_once";
                    State.get "Report.classify_once";
                    State.get "Property_status.Consolidated_status";
                    State.get "Consolidation graph" ])
    ();
  Project.clear
    ~selection:(State_selection.of_list
                  [ State.get "Report.print_once";
                    State.get "Report.print_csv_once";
                    State.get "Report.classify_once";
                    State.get "Property_status.Consolidated_status";
                    State.get "Consolidation graph" ])
    ();
  Project.clear
    ~selection:(State_selection.of_list
                  [ State.get "Report.print_once";
                    State.get "Report.print_csv_once";
                    State.get "Report.classify_once";
                    State.get "Property_status.Consolidated_status";
                    State.get "Consolidation graph" ])
    ();
  Project.clear
    ~selection:(State_selection.of_list
                  [ State.get "Report.print_once";
                    State.get "Report.print_csv_once";
                    State.get "Report.classify_once";
                    State.get "Property_status.Consolidated_status";
                    State.get "Consolidation graph" ])
    ();
  Project.clear
    ~selection:(State_selection.of_list
                  [ State.get "Report.print_once";
                    State.get "Report.print_csv_once";
                    State.get "Report.classify_once";
                    State.get "Property_status.Consolidated_status";
                    State.get "Consolidation graph" ])
    ();
  Project.clear
    ~selection:(State_selection.of_list
                  [ State.get "Report.print_once";
                    State.get "Report.print_csv_once";
                    State.get "Report.classify_once";
                    State.get "Property_status.Consolidated_status";
                    State.get "Consolidation graph" ])
    ();
  Project.clear
    ~selection:(State_selection.of_list
                  [ State.get "Report.print_once";
                    State.get "Report.print_csv_once";
                    State.get "Report.classify_once";
                    State.get "Property_status.Consolidated_status";
                    State.get "Consolidation graph" ])
    ();
  Project.clear
    ~selection:(State_selection.of_list
                  [ State.get "Report.print_once";
                    State.get "Report.print_csv_once";
                    State.get "Report.classify_once";
                    State.get "Property_status.Consolidated_status";
                    State.get "Consolidation graph" ])
    ();
  Db.Value.mark_as_computed ();
  Project.clear
    ~selection:(State_selection.of_list
                  [ State.get "sign.Store.Table_By_Callstack";
                    State.get "sign.Store.Table";
                    State.get "sign.Store.Storage";
                    State.get "sign.Store.Global_State";
                    State.get "sign.Store.Called_Functions_Memo";
                    State.get "sign.Store.Called_Functions_By_Callstack";
                    State.get "sign.Store.AfterTable_By_Callstack";
                    State.get "sign.Store.AfterTable";
                    State.get "postdominator.value";
                    State.get "inout.Store.Table_By_Callstack";
                    State.get "inout.Store.Table";
                    State.get "inout.Store.Storage";
                    State.get "inout.Store.Global_State";
                    State.get "inout.Store.Called_Functions_Memo";
                    State.get "inout.Store.Called_Functions_By_Callstack";
                    State.get "inout.Store.AfterTable_By_Callstack";
                    State.get "inout.Store.AfterTable";
                    State.get "Widen.Per_Function_Hints";
                    State.get "Widen.Parsed_Dynamic_Hints";
                    State.get "Widen.Dynamic_Hints";
                    State.get "Value_util.Degeneration";
                    State.get "Value_messages.Alarm_cache";
                    State.get "Value.Value_results.is_called";
                    State.get "Value.Value_results.Callers";
                    State.get
                      "Value.Traces_domain.Traces.state.Store.Table_By_Callstack";
                    State.get "Value.Traces_domain.Traces.state.Store.Table";
                    State.get
                      "Value.Traces_domain.Traces.state.Store.Storage";
                    State.get
                      "Value.Traces_domain.Traces.state.Store.Global_State";
                    State.get
                      "Value.Traces_domain.Traces.state.Store.Called_Functions_Memo";
                    State.get
                      "Value.Traces_domain.Traces.state.Store.Called_Functions_By_Callstack";
                    State.get
                      "Value.Traces_domain.Traces.state.Store.AfterTable_By_Callstack";
                    State.get
                      "Value.Traces_domain.Traces.state.Store.AfterTable";
                    State.get "Value.Red_statuses.RedStatusesTable";
                    State.get "Value.Gui.UsedVarState";
                    State.get "Users_register.print";
                    State.get "Users";
                    State.get "Unit domain.Store.Table_By_Callstack";
                    State.get "Unit domain.Store.Table";
                    State.get "Unit domain.Store.Storage";
                    State.get "Unit domain.Store.Global_State";
                    State.get "Unit domain.Store.Called_Functions_Memo";
                    State.get
                      "Unit domain.Store.Called_Functions_By_Callstack";
                    State.get "Unit domain.Store.AfterTable_By_Callstack";
                    State.get "Unit domain.Store.AfterTable";
                    State.get "Transfer_stmt.InOutCallback";
                    State.get "Transfer_stmt.DumpFileCounters";
                    State.get
                      "Symbolic locations domain.Store.Table_By_Callstack";
                    State.get "Symbolic locations domain.Store.Table";
                    State.get "Symbolic locations domain.Store.Storage";
                    State.get "Symbolic locations domain.Store.Global_State";
                    State.get
                      "Symbolic locations domain.Store.Called_Functions_Memo";
                    State.get
                      "Symbolic locations domain.Store.Called_Functions_By_Callstack";
                    State.get
                      "Symbolic locations domain.Store.AfterTable_By_Callstack";
                    State.get "Symbolic locations domain.Store.AfterTable";
                    State.get "Subgraph of Callgraph.Services";
                    State.get "Subgraph of Callgraph.Cg";
                    State.get "Studia.Highlighter.WritesOrRead";
                    State.get "Studia.Highlighter.StudiaState";
                    State.get "Sparecode without unused globals";
                    State.get "Sparecode";
                    State.get "Slicing_gui.State";
                    State.get "Slicing.Project";
                    State.get "Semantical constant propagation";
                    State.get "Scope.Datatscope.ModifsEdge";
                    State.get "Printer domain.Store.Table_By_Callstack";
                    State.get "Printer domain.Store.Table";
                    State.get "Printer domain.Store.Storage";
                    State.get "Printer domain.Store.Global_State";
                    State.get "Printer domain.Store.Called_Functions_Memo";
                    State.get
                      "Printer domain.Store.Called_Functions_By_Callstack";
                    State.get "Printer domain.Store.AfterTable_By_Callstack";
                    State.get "Printer domain.Store.AfterTable";
                    State.get "Pdg.State";
                    State.get "Pdg.Register.compute_once";
                    State.get "Operational_inputs.MemExec";
                    State.get "Octagon domain.Store.Table_By_Callstack";
                    State.get "Octagon domain.Store.Table";
                    State.get "Octagon domain.Store.Storage";
                    State.get "Octagon domain.Store.Global_State";
                    State.get "Octagon domain.Store.Called_Functions_Memo";
                    State.get
                      "Octagon domain.Store.Called_Functions_By_Callstack";
                    State.get "Octagon domain.Store.AfterTable_By_Callstack";
                    State.get "Octagon domain.Store.AfterTable";
                    State.get "Occurrences.State";
                    State.get "Occurrences.LastResult";
                    State.get "Occurrence_gui.State";
                    State.get "Occurrence.compute";
                    State.get "Nonterm.run";
                    State.get "Metrics_coverage.Kf_coverage";
                    State.get "Mem_exec.PreviousCalls(1)";
                    State.get "Inout.Register.ShouldOuput";
                    State.get "Inout.Outputs.Externals";
                    State.get "Inout.Operational_inputs.Internals";
                    State.get
                      "Inout.Operational_inputs.Externals_With_Formals";
                    State.get "Inout.Operational_inputs.CallwiseResults";
                    State.get "Inout.Inputs.Externals";
                    State.get "Inout.Derefs.Externals";
                    State.get "Inout.Cumulative_analysis.Memo(outputs)";
                    State.get "Inout.Cumulative_analysis.Memo(inputs)";
                    State.get "Inout.Cumulative_analysis.Memo(derefs)";
                    State.get "Impact_gui.SelectedStmt";
                    State.get "Impact_gui.Highlighted_stmt";
                    State.get "Impact.Register_gui.ReasonGraph";
                    State.get "Impact.Register_gui.InitialNodes";
                    State.get "Impact.Register_gui.ImpactedNodes";
                    State.get "Gauges domain.Store.Table_By_Callstack";
                    State.get "Gauges domain.Store.Table";
                    State.get "Gauges domain.Store.Storage";
                    State.get "Gauges domain.Store.Global_State";
                    State.get "Gauges domain.Store.Called_Functions_Memo";
                    State.get
                      "Gauges domain.Store.Called_Functions_By_Callstack";
                    State.get "Gauges domain.Store.AfterTable_By_Callstack";
                    State.get "Gauges domain.Store.AfterTable";
                    State.get "Functionwise dependencies";
                    State.get "From.Callwise.MemExec";
                    State.get "External inouts full";
                    State.get "Eva.Builtins.BuiltinsOverride";
                    State.get "Equality domain.Store.Table_By_Callstack";
                    State.get "Equality domain.Store.Table";
                    State.get "Equality domain.Store.Storage";
                    State.get "Equality domain.Store.Global_State";
                    State.get "Equality domain.Store.Called_Functions_Memo";
                    State.get
                      "Equality domain.Store.Called_Functions_By_Callstack";
                    State.get "Equality domain.Store.AfterTable_By_Callstack";
                    State.get "Equality domain.Store.AfterTable";
                    State.get "Dpds_gui.Highlighter.ZonesState";
                    State.get "Dpds_gui.Highlighter.ShowDef";
                    State.get "Dpds_gui.Highlighter.Pscope_warn";
                    State.get "Dpds_gui.Highlighter.Pscope";
                    State.get "Dpds_gui.Highlighter.Fscope";
                    State.get "Dpds_gui.Highlighter.FBscope";
                    State.get "Dpds_gui.Highlighter.DpdsState";
                    State.get "Dpds_gui.Highlighter.Bscope";
                    State.get "Db.Value.Table_By_Callstack";
                    State.get "Db.Value.Table";
                    State.get "Db.Value.RecursiveCallsFound";
                    State.get "Db.Value.Conditions_table";
                    State.get "Db.Value.Called_Functions_Memo";
                    State.get "Db.Value.Called_Functions_By_Callstack";
                    State.get "Db.Value.AfterTable_By_Callstack";
                    State.get "Db.Value.AfterTable";
                    State.get "Cvalue domain.Storage";
                    State.get "Constant_Propagation.compute";
                    State.get "Callwise dependencies";
                    State.get "Callgraph.Usesiter_in_rev_order";
                    State.get "Callgraph.Usesiter_in_order";
                    State.get "Callgraph.Services";
                    State.get "Callgraph.Cg";
                    State.get "Bitwise domain.Store.Table_By_Callstack";
                    State.get "Bitwise domain.Store.Table";
                    State.get "Bitwise domain.Store.Storage";
                    State.get "Bitwise domain.Store.Global_State";
                    State.get "Bitwise domain.Store.Called_Functions_Memo";
                    State.get
                      "Bitwise domain.Store.Called_Functions_By_Callstack";
                    State.get "Bitwise domain.Store.AfterTable_By_Callstack";
                    State.get "Bitwise domain.Store.AfterTable";
                    State.get "-pdgShouldOutput";
                    State.get "-metrics-eva-coverShouldOutput";
                    State.get "-evaShouldOutput";
                    State.get "-depsShouldOutput";
                    State.get "-calldepsShouldOutput";
                    State.get "!Db.Value.compute";
                    State.get "!Db.From.compute_all" ])
    ();
  (failwith "Function cannot be journalized: Db.Value.globals_set_initial_state" : _ -> unit)
    (failwith "no printer registered for value of type (Offsetmap(Cvalue.V_Or_Uninitialized.t), Cvalue.Default_offsetmap) Lmap:
                running the journal will fail.") ;
  (failwith "Function cannot be journalized: Db.Value.fun_set_args" : _ -> unit)
    (failwith "no code for pretty printer of type (Base.t, ival) ptmap mapset_lattice list:
                running the journal will fail.") ;
  Project.clear
    ~selection:(State_selection.of_list
                  [ State.get "Report.print_once";
                    State.get "Report.print_csv_once";
                    State.get "Report.classify_once";
                    State.get "Property_status.Consolidated_status";
                    State.get "Consolidation graph" ])
    ();
  Project.clear
    ~selection:(State_selection.of_list
                  [ State.get "Report.print_once";
                    State.get "Report.print_csv_once";
                    State.get "Report.classify_once";
                    State.get "Property_status.Consolidated_status";
                    State.get "Consolidation graph" ])
    ();
  Project.clear
    ~selection:(State_selection.of_list
                  [ State.get "Report.print_once";
                    State.get "Report.print_csv_once";
                    State.get "Report.classify_once";
                    State.get "Property_status.Consolidated_status";
                    State.get "Consolidation graph" ])
    ();
  Project.clear
    ~selection:(State_selection.of_list
                  [ State.get "Report.print_once";
                    State.get "Report.print_csv_once";
                    State.get "Report.classify_once";
                    State.get "Property_status.Consolidated_status";
                    State.get "Consolidation graph" ])
    ();
  Project.clear
    ~selection:(State_selection.of_list
                  [ State.get "Report.print_once";
                    State.get "Report.print_csv_once";
                    State.get "Report.classify_once";
                    State.get "Property_status.Consolidated_status";
                    State.get "Consolidation graph" ])
    ();
  Project.clear
    ~selection:(State_selection.of_list
                  [ State.get "Report.print_once";
                    State.get "Report.print_csv_once";
                    State.get "Report.classify_once";
                    State.get "Property_status.Consolidated_status";
                    State.get "Consolidation graph" ])
    ();
  Project.clear
    ~selection:(State_selection.of_list
                  [ State.get "Report.print_once";
                    State.get "Report.print_csv_once";
                    State.get "Report.classify_once";
                    State.get "Property_status.Consolidated_status";
                    State.get "Consolidation graph" ])
    ();
  Project.clear
    ~selection:(State_selection.of_list
                  [ State.get "Report.print_once";
                    State.get "Report.print_csv_once";
                    State.get "Report.classify_once";
                    State.get "Property_status.Consolidated_status";
                    State.get "Consolidation graph" ])
    ();
  Project.clear
    ~selection:(State_selection.of_list
                  [ State.get "Report.print_once";
                    State.get "Report.print_csv_once";
                    State.get "Report.classify_once";
                    State.get "Property_status.Consolidated_status";
                    State.get "Consolidation graph" ])
    ();
  Project.clear
    ~selection:(State_selection.of_list
                  [ State.get "Report.print_once";
                    State.get "Report.print_csv_once";
                    State.get "Report.classify_once";
                    State.get "Property_status.Consolidated_status";
                    State.get "Consolidation graph" ])
    ();
  Project.clear
    ~selection:(State_selection.of_list
                  [ State.get "Report.print_once";
                    State.get "Report.print_csv_once";
                    State.get "Report.classify_once";
                    State.get "Property_status.Consolidated_status";
                    State.get "Consolidation graph" ])
    ();
  Project.clear
    ~selection:(State_selection.of_list
                  [ State.get "Report.print_once";
                    State.get "Report.print_csv_once";
                    State.get "Report.classify_once";
                    State.get "Property_status.Consolidated_status";
                    State.get "Consolidation graph" ])
    ();
  Project.clear
    ~selection:(State_selection.of_list
                  [ State.get "Report.print_once";
                    State.get "Report.print_csv_once";
                    State.get "Report.classify_once";
                    State.get "Property_status.Consolidated_status";
                    State.get "Consolidation graph" ])
    ();
  Project.clear
    ~selection:(State_selection.of_list
                  [ State.get "Report.print_once";
                    State.get "Report.print_csv_once";
                    State.get "Report.classify_once";
                    State.get "Property_status.Consolidated_status";
                    State.get "Consolidation graph" ])
    ();
  Project.clear
    ~selection:(State_selection.of_list
                  [ State.get "Report.print_once";
                    State.get "Report.print_csv_once";
                    State.get "Report.classify_once";
                    State.get "Property_status.Consolidated_status";
                    State.get "Consolidation graph" ])
    ();
  Project.clear
    ~selection:(State_selection.of_list
                  [ State.get "Report.print_once";
                    State.get "Report.print_csv_once";
                    State.get "Report.classify_once";
                    State.get "Property_status.Consolidated_status";
                    State.get "Consolidation graph" ])
    ();
  Project.clear
    ~selection:(State_selection.of_list
                  [ State.get "Report.print_once";
                    State.get "Report.print_csv_once";
                    State.get "Report.classify_once";
                    State.get "Property_status.Consolidated_status";
                    State.get "Consolidation graph" ])
    ();
  Project.clear
    ~selection:(State_selection.of_list
                  [ State.get "Report.print_once";
                    State.get "Report.print_csv_once";
                    State.get "Report.classify_once";
                    State.get "Property_status.Consolidated_status";
                    State.get "Consolidation graph" ])
    ();
  Project.clear
    ~selection:(State_selection.of_list
                  [ State.get "Report.print_once";
                    State.get "Report.print_csv_once";
                    State.get "Report.classify_once";
                    State.get "Property_status.Consolidated_status";
                    State.get "Consolidation graph" ])
    ();
  Project.clear
    ~selection:(State_selection.of_list
                  [ State.get "Report.print_once";
                    State.get "Report.print_csv_once";
                    State.get "Report.classify_once";
                    State.get "Property_status.Consolidated_status";
                    State.get "Consolidation graph" ])
    ();
  Db.Value.mark_as_computed ();
  Project.set_keep_current false;
  let __ = Callgraph.Cg.get () in
  let __ = Callgraph.Cg.get () in
  Project.clear
    ~selection:(State_selection.of_list
                  [ State.get "Report.print_once";
                    State.get "Report.print_csv_once";
                    State.get "Report.classify_once";
                    State.get "Property_status.Consolidated_status";
                    State.get "Consolidation graph" ])
    ();
  Project.clear
    ~selection:(State_selection.of_list
                  [ State.get "Report.print_once";
                    State.get "Report.print_csv_once";
                    State.get "Report.classify_once";
                    State.get "Property_status.Consolidated_status";
                    State.get "Consolidation graph" ])
    ();
  Project.clear
    ~selection:(State_selection.of_list
                  [ State.get "Report.print_once";
                    State.get "Report.print_csv_once";
                    State.get "Report.classify_once";
                    State.get "Property_status.Consolidated_status";
                    State.get "Consolidation graph" ])
    ();
  Project.clear
    ~selection:(State_selection.of_list
                  [ State.get "Report.print_once";
                    State.get "Report.print_csv_once";
                    State.get "Report.classify_once";
                    State.get "Property_status.Consolidated_status";
                    State.get "Consolidation graph" ])
    ();
  Project.clear
    ~selection:(State_selection.of_list
                  [ State.get "Report.print_once";
                    State.get "Report.print_csv_once";
                    State.get "Report.classify_once";
                    State.get "Property_status.Consolidated_status";
                    State.get "Consolidation graph" ])
    ();
  Project.clear
    ~selection:(State_selection.of_list
                  [ State.get "Report.print_once";
                    State.get "Report.print_csv_once";
                    State.get "Report.classify_once";
                    State.get "Property_status.Consolidated_status";
                    State.get "Consolidation graph" ])
    ();
  Project.clear
    ~selection:(State_selection.of_list
                  [ State.get "Report.print_once";
                    State.get "Report.print_csv_once";
                    State.get "Report.classify_once";
                    State.get "Property_status.Consolidated_status";
                    State.get "Consolidation graph" ])
    ();
  Project.clear
    ~selection:(State_selection.of_list
                  [ State.get "Report.print_once";
                    State.get "Report.print_csv_once";
                    State.get "Report.classify_once";
                    State.get "Property_status.Consolidated_status";
                    State.get "Consolidation graph" ])
    ();
  Dynamic.Parameter.String.set "-wp-cache" "update";
  Project.clear
    ~selection:(State_selection.of_list
                  [ State.get "Report.print_once";
                    State.get "Report.print_csv_once";
                    State.get "Report.classify_once";
                    State.get "Property_status.Consolidated_status";
                    State.get "Consolidation graph" ])
    ();
  Project.clear
    ~selection:(State_selection.of_list
                  [ State.get "Report.print_once";
                    State.get "Report.print_csv_once";
                    State.get "Report.classify_once";
                    State.get "Property_status.Consolidated_status";
                    State.get "Consolidation graph" ])
    ();
  Project.clear
    ~selection:(State_selection.of_list
                  [ State.get "Report.print_once";
                    State.get "Report.print_csv_once";
                    State.get "Report.classify_once";
                    State.get "Property_status.Consolidated_status";
                    State.get "Consolidation graph" ])
    ();
  Project.clear
    ~selection:(State_selection.of_list
                  [ State.get "Report.print_once";
                    State.get "Report.print_csv_once";
                    State.get "Report.classify_once";
                    State.get "Property_status.Consolidated_status";
                    State.get "Consolidation graph" ])
    ();
  Project.clear
    ~selection:(State_selection.of_list
                  [ State.get "Report.print_once";
                    State.get "Report.print_csv_once";
                    State.get "Report.classify_once";
                    State.get "Property_status.Consolidated_status";
                    State.get "Consolidation graph" ])
    ();
  Project.clear
    ~selection:(State_selection.of_list
                  [ State.get "Report.print_once";
                    State.get "Report.print_csv_once";
                    State.get "Report.classify_once";
                    State.get "Property_status.Consolidated_status";
                    State.get "Consolidation graph" ])
    ();
  Project.clear
    ~selection:(State_selection.of_list
                  [ State.get "Report.print_once";
                    State.get "Report.print_csv_once";
                    State.get "Report.classify_once";
                    State.get "Property_status.Consolidated_status";
                    State.get "Consolidation graph" ])
    ();
  Project.clear
    ~selection:(State_selection.of_list
                  [ State.get "Report.print_once";
                    State.get "Report.print_csv_once";
                    State.get "Report.classify_once";
                    State.get "Property_status.Consolidated_status";
                    State.get "Consolidation graph" ])
    ();
  Project.clear
    ~selection:(State_selection.of_list
                  [ State.get "Report.print_once";
                    State.get "Report.print_csv_once";
                    State.get "Report.classify_once";
                    State.get "Property_status.Consolidated_status";
                    State.get "Consolidation graph" ])
    ();
  Project.clear
    ~selection:(State_selection.of_list
                  [ State.get "Report.print_once";
                    State.get "Report.print_csv_once";
                    State.get "Report.classify_once";
                    State.get "Property_status.Consolidated_status";
                    State.get "Consolidation graph" ])
    ();
  ()

(* Main *)
let main () =
  Journal.keep_file ".frama-c/frama_c_journal.ml";
  try run ()
  with
  | Unreachable -> Kernel.fatal "Journal reaches an assumed dead code" 
  | Exception s -> Kernel.log "Journal re-raised the exception %S" s
  | exn ->
    Kernel.fatal
      "Journal raised an unexpected exception: %s"
      (Printexc.to_string exn)

(* Registering *)
let main : unit -> unit =
  Dynamic.register
    ~plugin:"Frama_c_journal.ml"
    "main"
    (Datatype.func Datatype.unit Datatype.unit)
    ~journalize:false
    main

(* Hooking *)
let () = Cmdline.run_after_loading_stage main; Cmdline.is_going_to_load ()
