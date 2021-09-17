(* Functions over conccurency model.
 *
 * Author: Tomas Dacik (xdacik00@fit.vutbr.cz), 2021
 *)

type stmt =
  | Lock of Cil_types.exp
  | Unlock of Cil_types.exp
  | Lock_init of Cil_types.exp
  | Lock_destroy of Cil_types.exp
  | Condition_wait of Cil_types.exp * Cil_types.exp
  (* Condition * Lock *)
  
  | Thread_create of Cil_types.exp * Cil_types.exp * Cil_types.exp
  (* Thread ID * Entry point * Argument *)
  
  | Thread_join of Cil_types.exp
  (* Thread ID *)  

  | Call of Cil_types.exp * Cil_types.exp list
  (* Function * Params *)
  
  | End_of_path
  | Other
(** Abstraction over statements *)

(** {2 Classification of statements} *)

val classify_stmt : Cil_types.stmt -> stmt

val is_lock : Cil_types.stmt -> bool

val is_unlock : Cil_types.stmt -> bool

val is_lock_init : Cil_types.stmt -> bool

val is_lock_destroy : Cil_types.stmt -> bool 

val is_condition_wait : Cil_types.stmt -> bool

val is_thread_create : Cil_types.stmt -> bool

val is_thread_join : Cil_types.stmt -> bool

(** {2 Classification of types} *)

val is_lock_type_rec : Cil_types.typ -> bool
(** Does given type (possibly recursively) containts lock type. *)

val fn_lock_params : Cil_types.fundec -> Cil_types.varinfo list
(** Return formal parameters of functions that main contain a lock. *)

(** {2 Auxiliary functions} *)

val thread_create_id : Cil_types.stmt -> Cil_types.lval

val thread_create_entry_point : Cil_types.stmt -> Cil_types.exp

val thread_create_arg : Cil_types.stmt -> Cil_types.exp

val thread_join_id : Cil_types.stmt -> Cil_types.lval
