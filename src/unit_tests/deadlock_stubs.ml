open Lock_types
open Deadlock_types
open Trace_utils

open Cil_stubs

(* Locks *)

let lock1 = Lock.create var1 1 []
let lock2 = Lock.create var1 2 []
let lock3 = Lock.create var1 3 []
let lock4 = Lock.create var1 4 []
let lock5 = Lock.create var1 5 []
let lock6 = Lock.create var1 6 []
let lock7 = Lock.create var1 7 []
let lock8 = Lock.create var1 8 []
let lock9 = Lock.create var1 9 []

(* Threads *)

let thread1 = Thread.create_bottom (Cil.emptyFunction "thread1")
let thread2 = Thread.create_bottom (Cil.emptyFunction "thread2")
let thread3 = Thread.create_bottom (Cil.emptyFunction "thread3")
let thread4 = Thread.create_bottom (Cil.emptyFunction "thread4")
let thread5 = Thread.create_bottom (Cil.emptyFunction "thread5")
let thread6 = Thread.create_bottom (Cil.emptyFunction "thread6")
let thread7 = Thread.create_bottom (Cil.emptyFunction "thread7")
let thread8 = Thread.create_bottom (Cil.emptyFunction "thread8")
let thread9 = Thread.create_bottom (Cil.emptyFunction "thread9")
