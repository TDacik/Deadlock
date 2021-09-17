open Trace_utils

val callstack_bound : unit -> int

val reduce_list : Edge_trace.t list -> Edge_trace.t list

val happend_before : Callstack.t -> Callstack.t -> bool
