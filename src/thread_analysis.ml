open Deadlock_options
open Lockset
open Graph
open Cvalue
open Callgraph

module Stmts = Statement_matching

module Thread = struct

  type threadinfo = {
    create_locations : Cil_types.stmt list;
    init_states : Db.Value.state list;
    init_state_join : Db.Value.state;
    arguments : Db.Value.t list list;
    arguments_join : Db.Value.t list;
  }

  type t = {
    entry_point : Cil_types.fundec;
    threadinfo : threadinfo option;
  }

  let compare t1 t2 = Pervasives.compare t1.entry_point t2.entry_point

  let equal t1 t2 = Pervasives.(=) t1.entry_point t2.entry_point

  let hash t = Hashtbl.hash t.entry_point

  let create fundec = {
    entry_point = fundec;
    threadinfo = None;
  }

  let create_with_ti stmt fundec args = 
    let current_state = Db.Value.get_stmt_state stmt in {
    entry_point = fundec;
    threadinfo = Some {
        create_locations = [stmt];
        init_states = [current_state];
        init_state_join = current_state;
        arguments = [args];
        arguments_join = args
      }
  } 
    
  let get_entry_point thread = thread.entry_point

  let get_thread_create_locs thread = match thread.threadinfo with
    | Some ti -> ti.create_locations
    | None -> raise Not_found

  let get_main_thread () =  
    let main_kf = Globals.Functions.find_by_name "main" in
    let main_fundec = Kernel_function.get_definition main_kf in {
      entry_point = main_fundec;
      threadinfo = Some {
        create_locations = [];
        init_states = [];
        init_state_join = Db.Value.globals_state ();
        arguments = [];
        arguments_join = []
      }
    }

  let to_string t = Format.asprintf "%a" Printer.pp_fundec t.entry_point

  let get_from_expr ?(aliasing = false) stmt fn_expr args_expr =
      let possible_threads = Value.eval_ptr stmt fn_expr in
      List.map 
        (fun (base, offset) -> 
          let varinfo = Base.to_varinfo base in
          let fundec = Stmts.fundec_from_varinfo varinfo in
          (* TODO *)
          let kinstr = Cil_types.Kstmt stmt in
          let args = !Db.Value.access_expr kinstr args_expr in
          create_with_ti stmt fundec [args] 
        ) possible_threads

end

module ThreadGraph = Graph.Imperative.Digraph.ConcreteBidirectionalLabeled
                       (Thread)
                       (struct
                         type t = Cil_types.stmt list
                         let compare = Pervasives.compare
                         let default = []
                       end)

module Results = struct

  module ThreadSet = Set.Make
      (struct
        type t = Thread.t
        let compare = Pervasives.compare
      end)

  type t = {
    mutable create_graph : ThreadGraph.t;
    mutable create_locs : Cil_types.stmt list;
    mutable threads : ThreadSet.t;
  }

  let empty () = {
    create_graph = ThreadGraph.create ();
    create_locs = [];
    threads = ThreadSet.empty;
  }
  
  let add_thread thread results = 
    { results with threads = ThreadSet.add thread results.threads }

  let add_new_thread thread results =
      results.threads <- ThreadSet.add thread results.threads
   
  let iter_on_threads f results = ThreadSet.iter f results.threads

  let get_threads_list results =
    ThreadSet.fold
      (fun thread acc ->
         thread :: acc
      ) results.threads []

  let find_by_fundec fundec (results : t) =
      ThreadSet.find_first 
        (fun thread -> thread.entry_point == fundec) results.threads

  let print_threads results =
    iter_on_threads
      (fun thread -> Self.result "%a" Printer.pp_fundec thread.entry_point) results

end

module Dijkstra = Graph.Path.Dijkstra
                    (Cg.G)
                    (struct
                      type edge = Cg.G.E.t
                      type t = int
                      let weight e = 1
                      let compare = Pervasives.compare
                      let add = (+)
                      let zero = 0
                    end)

let thread_can_reach_stmt thread stmt =
  let fn = Kernel_function.find_englobing_kf stmt in
  let thread_fn = Thread.get_entry_point thread in
  let thread_fn_str = Format.asprintf "%a" Printer.pp_fundec thread_fn in
  let thread_kf = Globals.Functions.find_by_name thread_fn_str in 
  let callgraph = Cg.get () in
  try
    let _ = Dijkstra.shortest_path callgraph thread_kf fn in
    true
  with Not_found -> 
    false

let stmt_get_thread stmt (results : Results.t) = match Stmts.stmt_type stmt with
  | Thread_create (thread_expr, args) -> 
    let possible_threads = Thread.get_from_expr stmt thread_expr args in
    List.iter (fun t -> Results.add_new_thread t results) possible_threads

  | _ -> ()

let create_locs_of_fn (fundec : Cil_types.fundec) = List.fold_right
    (fun stmt l -> match Stmts.stmt_type stmt with
       | Thread_create (_, _) -> stmt :: l
       | _ -> l
    ) fundec.sallstmts []

let find_create_locs () = 
  Globals.Functions.fold
    (fun fn l -> match fn.fundec with
       | Definition (fundec, _) -> create_locs_of_fn fundec @ l 
       | Declaration _ -> l
    ) []

let find_threads creates_stmts results =
  List.iter
    (fun stmt ->
      stmt_get_thread stmt results
    ) creates_stmts

(** Assigns thread-creates to threads *)
let create_vertexes results create_stmts =
  let threads = Results.get_threads_list results in
  List.fold_right
    (fun thread acc ->
       let fundec = Thread.get_entry_point thread in
       let entry_point = List.hd fundec.sallstmts in
       let str = Format.asprintf "%a" Printer.pp_fundec thread.entry_point in
       let kf = Globals.Functions.find_by_name str in
       let aux = List.fold_right
         (fun create_stmt acc ->
           if thread_can_reach_stmt thread create_stmt then
             (thread, create_stmt) :: acc
           else
             acc
         ) create_stmts [] in
       acc @ aux
    ) threads []


let compute () =
  if true then !Db.Value.compute (); (**TODO*)

  let empty_results = Results.empty () in
  let main = Thread.get_main_thread () in
  let results = Results.add_thread main empty_results in

  (** Find statements, where threads are created *)
  let create_locs = find_create_locs () in
  (*List.iter (fun stmt -> Self.result "%a" Printer.pp_stmt stmt) create_locs;*)


  let _ = find_threads create_locs results in
  (*
  List.iter 
    (fun thread ->
       let fundec = Thread.get_entry_point thread in 
       Self.result "%a" Printer.pp_fundec fundec
    ) (Results.get_threads_list results);*)

  let g = create_vertexes results create_locs in
  List.iter
    (fun (thread, stmt) ->
       let fundec = Thread.get_entry_point thread in
       
       (*Self.result "Thread %a : %a"
       Printer.pp_fundec fundec
       Printer.pp_stmt stmt*)()
    ) g;
  results

