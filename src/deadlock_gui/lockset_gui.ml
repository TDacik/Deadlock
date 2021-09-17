(* Experimental visualisation of lockset analysis results
 *
 * TODO: Refactoring
 *
 * Author: Tomas Dacik (xdacik00@fit.vutbr.cz), 2021
 *)

open !Deadlock_top

open Dgraph_helper
open Pretty_source
open Gtk_helper

open Gui_utils
open Graph_views

open Cil_types
open Cil_datatype

open Lock_types
open Trace_utils
open Thread_analysis
open Deadlock_options

module KF = Kernel_function
module Results = Lockset_analysis.Results

let empty_table () = GPack.table ~columns:1 ()

let empty_stmt_table () =
  let table = GPack.table ~columns:4 () in
  table#attach ~left:0 ~top:0 ~xpadding:12 (GMisc.label ~text:"Entry lockset" ())#coerce;
  table#attach ~left:1 ~top:0 ~xpadding:12 (GMisc.label ~text:"Context" ())#coerce;
  table#attach ~left:2 ~top:0 ~xpadding:12 (GMisc.label ~text:"Exit locksets" ())#coerce;
  table

let lockset_info = ref None

let get_results () = match !Deadlock_main._results with
  | Some results -> results
  | None -> failwith "Lockset analysis was not computed"

let get_thread_graph () = match !Deadlock_main._thread_graph with
  | Some g -> g
  | None -> failwith "Thread analysis was not computed"


(** Statement summary *)
let table_stmt results stmt =
  let summaries = Results.summaries_of_stmt results stmt in
  let table = empty_stmt_table () in
  if Stmt_summaries.cardinal summaries = 0 then
    table#attach 
      ~left:0 
      ~top:1 
      (GMisc.label 
         ~text:"This statement was not reached during lockset analysis." 
         ()
      )#coerce;

  let _ = Stmt_summaries.fold
      (fun (stmt, (_, ls, context)) lss row ->
         let ls_str = Format.asprintf "%a" Lockset.pp ls in
         let lss_str = Format.asprintf "%a" LocksetSet.pp lss in
         let context_str = Format.asprintf "%a" Cvalue.Model.pretty context in
         table#attach ~left:0 ~top:row (GMisc.label ~text:ls_str ())#coerce;
         table#attach ~left:1 ~top:row (GMisc.label ~text:context_str ())#coerce;
         table#attach ~left:2 ~top:row (GMisc.label ~text:lss_str ())#coerce;
         row + 1
      ) summaries 1
  in table

let show_lockgraph_fn lockgraph main_ui () =
  Dgraph_helper.graph_window_through_dot 
    ~parent: main_ui#main_window
    ~title:"Lockgraph" 
    (fun fmt -> Lockgraph_dot.fprint_graph fmt lockgraph)

let state_button main_ui (table : GPack.table) top state =
  if Gui_utils.state_too_long state then
    let text = Format.asprintf "%a" Cvalue.Model.pretty state in
    let label = "Initial context" in
    let button = GButton.button ~label ~relief:`NONE () in
    let callback = Gui_utils.text_window main_ui#main_window "Initial context" text in 
    ignore @@ button#connect#clicked ~callback;
    table#attach ~left:2 ~top button#coerce

  else 
    let text = Format.asprintf "%a" Cvalue.Model.pretty state in
    table#attach ~left:2 ~top (GMisc.label ~text ())#coerce

let thread_button main_ui (table : GPack.table) top thread =
  let label = Format.asprintf "%a" Thread.pp thread in
  let state, arg_value = Thread.get_init_state thread in
  let text = Format.asprintf "State:\n %a Argument:\n%a" 
      Cvalue.Model.pretty state 
      Cvalue.V.pretty arg_value
  in
  let equiv_threads = Thread_graph.get_equiv_threads (get_thread_graph ()) thread in
  let text2 = "\n\nThis thread's initial state is equivalent to " in
  let text3 = List.fold_left (fun acc t -> acc ^ " ," ^ (Thread.to_string t)) 
      text2 equiv_threads in
  let button = GButton.button ~label ~relief:`NONE () in
  let callback = Gui_utils.text_window main_ui#main_window label (text^text3) in 
  ignore @@ button#connect#clicked ~callback;
  table#attach ~left:0 ~top button#coerce

let table_fn_summaries main_ui results varinfo =
  try
    let kf = Globals.Functions.find_by_name 
        (Format.asprintf "%a" Printer.pp_varinfo varinfo) in
    let fn = Kernel_function.get_definition kf in
    let (table : GPack.table) = GPack.table
        ~columns: 5
        ()
    in
    let summaries = Results.summaries_of_fn results fn in
    table#attach ~left:0 ~top:0 ~xpadding:12 (GMisc.label ~text:"Thread" ())#coerce;
    table#attach ~left:1 ~top:0 ~xpadding:12 (GMisc.label ~text:"Entry lockset" ())#coerce;
    table#attach ~left:2 ~top:0 ~xpadding:12  (GMisc.label ~text:"Context" ())#coerce;
    table#attach ~left:3 ~top:0 ~xpadding:12 (GMisc.label ~text:"Exit locksets" ())#coerce;
    table#attach ~left:4 ~top:0 ~xpadding:12 (GMisc.label ~text:"Lockgraph (|E|)" ())#coerce;
    let _ = Function_summaries.fold
      (fun (fn, (thread, ls, context)) (lss, g) (row : int) ->
         let ls_str = Format.asprintf "%a" Lockset.pp ls in
         let lss_str = Format.asprintf "%a" LocksetSet.pp lss in
         let lockgraph = Format.asprintf "lockgraph (%d)" (Lockgraph.nb_edges g) in
         thread_button main_ui table row thread;
         table#attach ~left:1 ~top:row (GMisc.label ~text:ls_str ())#coerce;
         state_button main_ui table row context;
         table#attach ~left:3 ~top:row (GMisc.label ~text:lss_str ())#coerce;

         (* Create label with callback *)
         let label = GButton.button ~label:lockgraph ~relief:`NONE () in
         ignore @@ label#connect#clicked ~callback:(show_lockgraph_fn g main_ui);
         
         table#attach ~left:4 ~top:row label#coerce;
         row + 1
      ) summaries 1 in
    table
  with KF.No_Definition -> 
    empty_table ()

let table_expr results kinstr expr = match kinstr with
  | Kstmt stmt ->
    let ls = Lockset_analysis.possible_locks stmt expr in
    let table = GPack.table ~columns:1 ~rows:1 () in
    table#attach ~left:0 ~top:0 (GMisc.label ~text:(Lockset.to_string ls) ())#coerce;
    table
  | Kglobal -> empty_table ()

(** Callback: selection of element in the source code. *)
let on_select menu (main_ui : Design.main_window_extension_points) ~button selected =
  let results = get_results () in
  let notebook = main_ui#lower_notebook in
  let table = match selected with
    (* Statements *)
    | PStmt (_, stmt) | PStmtStart (_, stmt) -> table_stmt results stmt

    (* Declaration and definition of functior or variable *)
    | PVDecl (_, _, varinfo) -> 
      begin match varinfo.vtype with
        | TFun _ -> table_fn_summaries main_ui results varinfo
        | _ -> 
          let t = GPack.table ~columns:1 ~rows:1 () in
          t#attach 
            ~left:0 
            ~top:0 
            (GMisc.label 
               ~text:"Debug: Deadlock has no info for this selection." 
               ()
            )#coerce;
          t
      end

    (* Expression *)
    | PExp (_, kinstr, expr) -> table_expr results kinstr expr
    | PLval (_, kinstr, lval) -> 
      let loc = match kinstr with
        | Kstmt stmt -> Stmt.loc stmt
        | Kglobal -> Location.unknown
      in
      let expr = Cil.mkAddrOf ~loc lval in
      table_expr results kinstr expr

    (* Otherwise empty table *)
    | _ -> 
      let t = GPack.table ~columns:1 ~rows:1 () in
      t#attach ~left:0 ~top:0 (GMisc.label ~text:"Debug: Deadlock has no info for this selection." ())#coerce;
      t

  in
  let table = table#coerce in
  let page = Option.get !lockset_info in

  let pos_focused = main_ui#lower_notebook#current_page in
  let pos = main_ui#lower_notebook#page_num page in
  main_ui#lower_notebook#remove_page pos;
  let label = Some (GMisc.label ~text:"Deadlock" ())#coerce in
  let page_pos = main_ui#lower_notebook#insert_page ?tab_label:label ?menu_label:label ~pos table in
  let page = main_ui#lower_notebook#get_nth_page page_pos in
  main_ui#lower_notebook#goto_page pos_focused;
  lockset_info := Some page;
  ()

let show_lockgraph main_ui () =
  let lockgraph = Results.lockgraph (get_results ()) in
  Dgraph_helper.graph_window_through_dot 
    ~parent: main_ui#main_window
    ~title:"Lockgraph" 
    (fun fmt -> Lockgraph_dot.fprint_graph fmt lockgraph)

let show_thread_graph main_ui () =
  let thread_graph = get_thread_graph () in
  Dgraph_helper.graph_window_through_dot 
    ~parent: main_ui#main_window
    ~title:"Thread graph" 
    (fun fmt -> Thread_graph_dot.fprint_graph fmt thread_graph)

let change_thread thread main_ui () = 
  Eva_wrapper.set_active_thread thread;
  let _ = Eva.Value_results.get_results () in
  main_ui#redisplay ()

let deadlock_panel main_ui =
  let box = GPack.box `VERTICAL () in
  let button1 = GButton.button ~label:"Show lockgraph" () in
  ignore @@ button1#connect#clicked ~callback:(show_lockgraph main_ui);
  
  let button2 = GButton.button ~label:"Show thread graph" () in
  ignore @@ button2#connect#clicked ~callback:(show_thread_graph main_ui);

  let label = GMisc.label ~text:"Active thread" () in

  let liste = GList.liste () ~selection_mode: `SINGLE in
  
  let threads = Thread_graph.get_threads (get_thread_graph ()) in
  List.iteri
    (fun i thread ->
      let thread_str = Thread.to_string thread in
      let item = GList.list_item ~label:thread_str () in
      ignore @@ item#connect#select ~callback:(change_thread thread main_ui);
      liste#insert ~pos:i item
    ) threads;

  (box :> GContainer.container)#add button1#coerce;
  (box :> GContainer.container)#add button2#coerce;
  (box :> GContainer.container)#add label#coerce;
  (box :> GContainer.container)#add liste#coerce;
  box#coerce

let high buffer localizable ~start ~stop =
  let results = get_results () in
  let buffer = buffer#buffer in
  match localizable with
  | PStmt (_, stmt) ->
    if Cil_datatype.Stmt.Set.mem stmt (Results.imprecise_lock_stmts results) then
      let tag = make_tag buffer "deadlock" [`BACKGROUND "red" ] in
      apply_tag buffer tag start stop
  
  | PVDecl (_, _, varinfo) -> 
    begin match varinfo.vtype with
      | TFun _ ->
        let kf = Option.get @@ kf_of_localizable localizable in
        let fundec = Kernel_function.get_definition kf in
        if List.mem ~eq:Fundec.equal fundec (Results.imprecise_fns results) then
          let tag = make_tag buffer "deadlock" [`BACKGROUND "red" ] in
          apply_tag buffer tag start stop

      | _ -> ()
    end
  
  | _ -> ()

(** Initialisation of new tabe in lower notebook. **)
let main (main_ui : Design.main_window_extension_points) = 

  main_ui#register_source_selector on_select;
  main_ui#register_panel (fun main_ui -> ("Deadlock", deadlock_panel main_ui, None));
  main_ui#register_source_highlighter high;

  (* Create page in lower notebook and store reference to it. *)
  let tab_label = Some (GMisc.label ~text:"Deadlock" ())#coerce in
  let info = empty_table () in
  let page_pos = main_ui#lower_notebook#append_page
      ?tab_label:tab_label ?menu_label:tab_label info#coerce in
  let page = main_ui#lower_notebook#get_nth_page page_pos in
  lockset_info := Some page;
  ()

let init main_ui = if Enabled.get () then main main_ui else ()

let () = Design.register_extension init
