open Cil_types
open Cil_datatype

module List = CCList

(* Statements *)

let stmt1 = Cil.mkStmt ~valid_sid:true (Instr Cil.dummyInstr)
let stmt2 = Cil.mkStmt ~valid_sid:true (Instr Cil.dummyInstr)
let stmt3 = Cil.mkStmt ~valid_sid:true (Instr Cil.dummyInstr)
let stmt4 = Cil.mkStmt ~valid_sid:true (Instr Cil.dummyInstr)
let stmt5 = Cil.mkStmt ~valid_sid:true (Instr Cil.dummyInstr)
let stmt6 = Cil.mkStmt ~valid_sid:true (Instr Cil.dummyInstr)
let stmt7 = Cil.mkStmt ~valid_sid:true (Instr Cil.dummyInstr)
let stmt8 = Cil.mkStmt ~valid_sid:true (Instr Cil.dummyInstr)
let stmt9 = Cil.mkStmt ~valid_sid:true (Instr Cil.dummyInstr)

let stmts = [stmt1; stmt2; stmt3; stmt4; stmt5; stmt6; stmt7; stmt8; stmt9]
let diff_stmts = List.diagonal stmts

(* Functions *)

let fn1 = Cil.emptyFunction "fn1"
let fn2 = Cil.emptyFunction "fn2"
let fn3 = Cil.emptyFunction "fn3"
let fn4 = Cil.emptyFunction "fn4"
let fn5 = Cil.emptyFunction "fn5"
let fn6 = Cil.emptyFunction "fn6"
let fn7 = Cil.emptyFunction "fn7"
let fn8 = Cil.emptyFunction "fn8"
let fn9 = Cil.emptyFunction "fn9"

let fns = [fn1; fn2; fn3; fn4; fn5; fn6; fn7; fn8; fn9]
let diff_fns = List.diagonal fns

(* Variables *)
let var1 = Varinfo.dummy


(* Make sure there are no equal definitions *)
let () =
  assert (not @@ List.exists (fun (s1, s2) -> Stmt.equal s1 s2) diff_stmts);
  assert (not @@ List.exists (fun (f1, f2) -> Fundec.equal f1 f2) diff_fns)
