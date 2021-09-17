(* Initialization of concurrency model from json.
 *
 * Author: Tomas Dacik (xdacik00@stud.fit.vutbr.cz 
 *)

open Concurrency_model_data
open Yojson.Basic.Util

module Json = Yojson.Basic

let extract_list json str =
  json
  |> member str
  |> convert_each to_string

let extract_function_list ?(str_pos="lock-position") json str =
  try
    json
    |> member str
    |> convert_each
      (fun entry ->
         let name = member "function" entry |> to_string in
         let pos = member str_pos entry |> to_int in
         (name, [pos])
      )
  with _ -> failwith ""

let extract_function_list2 
    ?(str_pos1="entry-point-position")
    ?(str_pos2="argument-position")
    json str =
  try
    json
    |> member str
    |> convert_each
      (fun entry ->
         let name = member "function" entry |> to_string in
         let pos_fn = member str_pos1 entry |> to_int in
         let pos_arg = member str_pos2 entry |> to_int in 
         (name, [pos_fn; pos_arg])
      )
  with _ -> failwith str

let extract_function_list3 json str =
  try
    json
    |> member str
    |> convert_each
      (fun entry ->
         let name = member "function" entry |> to_string in
         let pos_id = member "thread-id-position" entry |> to_int in
         let pos_fn = member "entry-point-position" entry |> to_int in 
         let pos_arg = member "argument-position" entry |> to_int in 
         (name, [pos_id; pos_fn; pos_arg])
      )
  with _ -> failwith str



let load_model path =
  let json = Json.from_file path in
  let locking = json |> member "Locking" in
  let conditions = json |> member "Conditions" in
  let threads = json |> member "Threads" in

  let lock_types = extract_list locking "types" in
  let blocking_locks = extract_function_list locking "blocking-lock" in
  let non_blocking_locks = extract_function_list locking "non-blocking-lock" in
  let unlocks = extract_function_list locking "unlock" in
  let inits = extract_function_list locking "init" in
  let destroys = extract_function_list locking "destroy" in

  let waits = extract_function_list2 
      ~str_pos1:"condition-position"
      ~str_pos2:"lock-position" 
      conditions "wait" 
  in

  let creates = extract_function_list3 threads "create" in
  let joins = extract_function_list ~str_pos:"thread-id-position" threads "join" in
 
  (* Initialization of the model *)

  List.iter Lock_types.add lock_types;
  List.iter Lock_functions.add blocking_locks;
  List.iter Nonblocking_lock_functions.add non_blocking_locks;
  List.iter Unlock_functions.add unlocks;
  List.iter Lock_init_functions.add inits;
  List.iter Lock_destroy_functions.add destroys;

  List.iter Condition_wait_functions.add waits;

  List.iter Thread_create_functions.add creates;
  List.iter Thread_join_functions.add joins
