(* Utilities for the lockset analysis:              *)
(*   - callstack of an acquisition of lock          *)
(*   - trace of a creations of edge                 *)
(* Author: Tomas Dacik (xdacik00@stud.fit.vutbr.cz) *)   

open Cil_datatype
open Containers

module Stmts = Statement_utils

(** Callstack represents sequence of function calls and branching leading
    to some action. Structure of each callstack is given by the following
    regular expression (from bottom up):

    <thread entry> [<function call> | <branch taken>]* <action>{0,1}

    Callstack that doesn't match this regex is called invalid.
    Callstack without action on the top is call incomplete.

*)
module Callstack = struct

  type path_taken =
    | Then
    | Else
    | Then_nondet
    | Else_nondet
  
  type event =
    | Thread_entry of Thread.t
    | Call of Cil_types.stmt * Cil_types.fundec
    | Guard of Cil_types.stmt * path_taken
    | Action of Cil_types.stmt * string

  type t = event list

  exception Empty_callstack

  exception Invalid_callstack of string

  exception Incomplete_callstack

  let empty = []

  let is_empty = function
    | [] -> true
    | _ -> false

  let depth = List.length

  let compare_event e1 e2 = match e1, e2 with
    | Thread_entry t1, Thread_entry t2 -> Thread.compare t1 t2
    
    | Call (stmt1, fn1), Call (stmt2, fn2) ->
      if Stmt.compare stmt1 stmt2 <> 0 then Stmt.compare stmt1 stmt2
      else Fundec.compare fn1 fn2

    | Action (stmt1, str1), Action (stmt2, str2) ->
      if Stmt.compare stmt1 stmt2 <> 0 then Stmt.compare stmt1 stmt2
      else String.compare str1 str2

    | Guard (stmt1, type1), Guard (stmt2, type2) ->
      if Stmt.compare stmt1 stmt2 <> 0 then Stmt.compare stmt1 stmt2
      else Stdlib.compare type1 type2

    | _ -> Stdlib.compare e1 e2

  (* Equality of two events based on their compare function. *)
  let equal_event e1 e2 = (compare_event e1 e2) = 0

  (* Comparison of two stack based on comparison of their events. *)
  let compare cs1 cs2 = List.compare compare_event cs1 cs2

  (* Equality of two stack based on equality of their events. *)
  let equal cs1 cs2 = List.equal equal_event cs1 cs2

  let bottom callstack = match callstack with
    | [] -> raise Empty_callstack
    | callstack -> List.rev callstack |> List.hd

  (** {2 Manipulations with callstack } *)

  let push_thread_entry thread = Thread_entry thread :: []

  let push_call stmt fundec callstack = match callstack with
    | [] -> raise Empty_callstack
    | callstack -> Call (stmt, fundec) :: callstack

  let push_guard stmt path_taken callstack = match callstack with
    | [] -> raise Empty_callstack
    | callstack -> Guard (stmt, path_taken) :: callstack

  let push_action stmt action callstack = match callstack with
    | [] -> raise Empty_callstack
    | callstack -> Action (stmt, action) :: callstack

  let top callstack = match callstack with
    | [] -> raise Empty_callstack
    | top :: _ -> top

  let rec top_call_fn callstack = match callstack with
    | Call (_, fundec) :: _ -> fundec
    | Guard _ :: tail -> top_call_fn tail
    | Thread_entry thread :: [] -> Thread.get_entry_point thread
    | Action _ :: Call (_, fundec) :: _ -> fundec
    | _ -> raise (Invalid_callstack "No top call")

  let rec top_call_stmt callstack = match callstack with
    | Call (stmt, _) :: _ -> stmt
    | Guard _ :: tail -> top_call_stmt tail
    | Action _ :: Call (stmt, _) :: _ -> stmt
    | _ -> raise (Invalid_callstack "No top call")

  let top_stmt = function
    | Call (stmt, _) :: _ -> stmt
    | Guard (stmt, _) :: _ -> stmt
    | Action (stmt, _) :: _ -> stmt
    | _ -> raise (Invalid_callstack "No top statement")

  let top_call callstack = (top_call_fn callstack, top_call_stmt callstack)

  let get_thread callstack = match bottom callstack with
    | Thread_entry thread -> thread
    | _ -> raise (Invalid_callstack "No thread")

  let set_thread thread callstack = match List.rev callstack with
    | [] -> push_thread_entry thread
    | _ :: rest -> (Thread_entry thread :: rest) |> List.rev

  let get_bottom_stmt callstack = match List.rev callstack with
    | [] -> raise Empty_callstack
    | _ :: Action (stmt, _) :: _ -> stmt
    | _ :: Call (stmt, _) :: _ -> stmt
    | _ :: Guard (stmt, _) :: _ -> stmt (* Check *)
    | _ -> raise (Invalid_callstack 
                    "Second bottom element is neither call nor action"
                 )

  let get_action callstack = match callstack with
    | [] -> raise Empty_callstack
    | Action (stmt, action) :: _ -> (stmt, action)
    | _ -> raise Incomplete_callstack

  let get_action_stmt callstack = match callstack with
    | [] -> raise Empty_callstack
    | Action (stmt, _) :: _ -> stmt
    | _ -> raise Incomplete_callstack

  let pop callstack = match callstack with
    | [] -> raise Empty_callstack
    | _ :: stack -> stack

  let rec top_guards = function
    | [] -> raise Empty_callstack
    | Guard (s, p) :: t -> (s, p) :: top_guards t
    | _ -> []

  let rec mem_call callstack call = match callstack with
    | Action _ :: t -> mem_call t call
    | Guard _ :: t -> mem_call t call
    | Call (_, fundec) :: t ->
      if Fundec.equal fundec call then true
      else mem_call t call
    | _ -> false

  let path_taken_to_string = function
    | Then -> "taking true branch"
    | Else -> "taking false branch"
    | Then_nondet -> "taking true branch nondeterministically"
    | Else_nondet -> "taking false branch nondeterministically"

  let event_is_guard = function
    | Guard _ -> true
    | _ -> false

  let event_to_string prefix = function
    | Call (stmt, fundec) ->
      Format.asprintf "%sCall of %a (%a)"
        prefix
        Printer.pp_fundec fundec
        Printer.pp_location (Stmt.loc stmt)

    | Guard (stmt, path_taken) ->
      let expr = Stmts.guard_to_condition stmt in
      Format.asprintf "%sCondition %a, %s"
        prefix
        Printer.pp_exp expr
        (path_taken_to_string path_taken)

    | Action (stmt, action) ->
      Format.asprintf "%s%s (%a)"
        prefix
        action
        Printer.pp_location (Stmt.loc stmt)

    | Thread_entry thread ->
      Format.asprintf "In thread %a:"
        Thread.pp thread

  let rec to_string_aux prefix = function
    | [] -> ""
    | event :: tail ->
      if not @@ String.equal (Deadlock_options.Callstack_mode.get ()) "branching" 
         && event_is_guard event
      then to_string_aux prefix tail
      else event_to_string prefix event ^ "\n" ^ to_string_aux prefix tail

  let to_string = function 
    | [] -> "[]"
    | callstack -> to_string_aux "" (List.rev callstack)

  let pp fmt callstack = Format.fprintf fmt "%s" (to_string callstack)

  let rec cut_prefix_aux fn cs = match cs with
    | [] -> raise Not_found
    | Call (_, f) :: tail ->
      if Fundec.equal f fn then tail
      else cut_prefix_aux fn tail
    | _ :: t -> cut_prefix_aux fn t
   
  let cut_prefix fn cs = match cs with
    | [] -> []
    | cs -> 
      List.rev cs
      |> cut_prefix_aux fn
      |> List.rev
  
  let rec remove_guards callstack = match callstack with
    | Guard (_, _) :: cs -> remove_guards cs
    | [Thread_entry fn] -> [Thread_entry fn]
    | event :: cs -> event :: remove_guards cs
    | _ -> raise (Invalid_callstack "")
  

  (** Auxiliary manipulation functions **)

  let concat callstack1 callstack2 = callstack1 @ callstack2

  (* Converts callstack to form used in EVA *)
  let rec convert = function
    | [] -> []
    | Action _ :: tail -> convert tail
    | Guard _ :: tail -> convert tail

    | Thread_entry thread :: tail ->
      let fundec = Thread.get_entry_point thread in 
      let kernel_function = Stmts.kernel_fn_from_fundec fundec in
      let call_site = (kernel_function, Cil_types.Kglobal) in
      call_site :: convert tail

    | Call (stmt, fundec) :: tail ->
      let kinstr = Cil_types.Kstmt stmt in
      let kernel_function = Stmts.kernel_fn_from_fundec fundec in
      let call_site = (kernel_function, kinstr) in
      call_site :: convert tail

  (** Printing functions **)
  
  let rec remove_prefix prefix cs = match prefix, cs with
    | [], cs -> cs
    | _, [] -> failwith "Not a prefix"
    | h1 :: t1, h2 :: t2 ->
      if equal_event h1 h2 then remove_prefix t1 t2
      else failwith "Not a prefix"

  let pp_event fmt event = Format.fprintf fmt "%s" (event_to_string "" event)

  let conc_check_abstraction with_action_stmt n cs =
    let reduced = remove_guards cs in
    let prefix = List.last n reduced in  
    if with_action_stmt then 
      List.take 1 cs @ prefix
    else prefix
  
  let compare_abstr ?(with_action_stmt=true) n cs1 cs2 =
    let abstr1 = conc_check_abstraction with_action_stmt n cs1 in
    let abstr2 = conc_check_abstraction with_action_stmt n cs2 in
    compare abstr1 abstr2

  let equal_abstr ?(with_action_stmt=true) n cs1 cs2 =
    let cmp = compare_abstr ~with_action_stmt n cs1 cs2 in
    Int.equal cmp 0

end

module Edge_trace = struct

  type t = Callstack.t * Callstack.t

  let compare (cs1, cs2) (cs1', cs2') =
    let aux = Callstack.compare cs1 cs1' in
    if aux <> 0 then aux
    else Callstack.compare cs2 cs2'

  let get_callstacks (cs1, cs2) = (cs1, cs2)

  let rec get_common_prefix (cs1, cs2) = match cs1, cs2 with
    | [], _ -> []
    | _, [] -> []
    | h1 :: t1, h2 :: t2 ->
      if Callstack.equal_event h1 h2 then h1 :: get_common_prefix (t1, t2)
      else []

  let get_thread trace = Callstack.get_thread (fst trace)

  let get_origin_stmt trace =  
    Callstack.get_action_stmt (snd trace)

  let get_action_stmts trace =
    (Callstack.get_action_stmt (fst trace), Callstack.get_action_stmt (snd trace))

  let partition (cs1, cs2) =
    let rev_cs1 = List.rev cs1 in
    let rev_cs2 = List.rev cs2 in
    let prefix = get_common_prefix (rev_cs1, rev_cs2) in
    let cs1' = Callstack.remove_prefix prefix rev_cs1 in
    let cs2' = Callstack.remove_prefix prefix rev_cs2 in
    (prefix, cs1', cs2')

  let length trace =
    let (prefix, cs1, cs2) = partition trace in
    Callstack.depth prefix
    + Callstack.depth cs1
    + Callstack.depth cs2

  let create cs1 cs2 = 
    try
      let _, _ = Callstack.get_action cs1, Callstack.get_action cs2 in
      (cs1, cs2)
    with _ -> raise Callstack.Incomplete_callstack

  let to_string trace = match partition trace with
    | (prefix, cs1, cs2) ->
      let newline = if (List.length (cs1 @ cs2)) > 2 then "\n" else "" in
      Callstack.to_string_aux "  " prefix 
      ^ Callstack.to_string_aux "    " cs1 
      ^ newline
      ^ Callstack.to_string_aux "    " cs2

  let pp fmt trace = Format.fprintf fmt "%s" (to_string trace)

end
