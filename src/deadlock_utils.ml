open Deadlock_options
open Value_types
open Cil_types

module Stmts = Statement_matching

module Callstack = struct

  type event =
    | Call of stmt * fundec
    | Lock of stmt * string
    | Thread_entry of fundec

  type t = event list

  let empty () = []

  let push_call stmt callstack =
    let event = match Stmts.stmt_type stmt with
      | Stmts.Call (callee) -> Call (stmt, callee) 
    in
    event :: callstack

  let push_thread_entry fundec callstack =
    let event = Thread_entry fundec in
    event :: callstack

  let push_lock stmt name callstack =
    let event = Lock (stmt, name) in
    event :: callstack

  let pop callstack = match callstack with
    | [] -> failwith "Empty Callstack"
    | _ :: stack -> stack

  let rec get_common_prefix cs1 cs2 = match cs1, cs2 with
    | [], cs2 -> []
    | cs1, [] -> []
    | h1 :: t1, h2 :: t2 ->
      if h1 == h2 then
        h1 :: get_common_prefix t1 t2
      else
        []

  let rec remove_prefix prefix cs = match prefix, cs with
    | [], cs -> cs
    | p, [] -> failwith "Not a prefix"
    | h1 :: t1, h2 :: t2 ->
      if h1 == h2 then begin
        remove_prefix t1 t2
      end
      else
        failwith "Not a prefix"

  let rec bottom = function
    | [] -> failwith "Empty Callstack"
    | bottom :: [] ->
      (match bottom with
       | Thread_entry fundec -> fundec
       | _ -> failwith "Callstack Error"
      )
    | head :: tail -> bottom tail

  let partition cs1 cs2 =
    let rev_cs1 = List.rev cs1 in
    let rev_cs2 = List.rev cs2 in
    let prefix = get_common_prefix rev_cs1 rev_cs2 in
    let cs1' = remove_prefix prefix rev_cs1 in
    let cs2' = remove_prefix prefix rev_cs2 in
    [prefix; cs1'; cs2']

  let join cs1 cs2 =
    let parts = partition cs1 cs2 in
    List.rev (List.flatten parts)

  (** Printing functions **)

  let event_to_string prefix = function
    | Call (stmt, fundec) ->
      Format.asprintf "%sCall of %a (%a)"
        prefix
        Printer.pp_fundec fundec
        Printer.pp_location (Stmts.get_location stmt)

    | Lock (stmt, name) ->
      Format.asprintf "%sLock of %s (%a)"
        prefix
        name
        Printer.pp_location (Stmts.get_location stmt)

    | Thread_entry fundec ->
      Format.asprintf "In thread %a:"
        Printer.pp_fundec fundec

  let print_event prefix event = Self.result "%s" (event_to_string prefix event)

  let rec to_string_aux prefix = function
    | [] -> ""
    | event :: tail -> event_to_string prefix event ^ "\n" ^ to_string_aux prefix tail

  let to_string callstack = to_string_aux "" (List.rev callstack)

  let print callstack = Self.result "%s" (to_string callstack)

  let to_string2 label = match partition (fst label) (snd label) with
    | prefix :: cs1 :: cs2 :: [] ->
      let newline = if (List.length (cs1 @ cs2)) > 2 then "\n" else "" in
      to_string_aux "  " prefix 
      ^ to_string_aux "    " cs1 ^ newline
      ^ to_string_aux "    " cs2
    | _ -> failwith "Callstack error"

  let print2 callstack = Self.result "%s" (to_string2 callstack)

end
