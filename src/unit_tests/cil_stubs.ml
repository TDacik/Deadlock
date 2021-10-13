open Filepath
open Cil_types
open Cil_datatype

module List = CCList

(** Contruct representation of position file:line *)
let loc_constructor file line =
  let file = Filepath.Normalized.of_string file in
  let position = {pos_path = file; pos_lnum = line; pos_bol = 0; pos_cnum = 0} in
  (position, position)

(* Statements *)

let stmt1 = Cil.mkEmptyStmt ~valid_sid:true ~loc:(loc_constructor "stmt" 1) ()
let stmt2 = Cil.mkEmptyStmt ~valid_sid:true ~loc:(loc_constructor "stmt" 2) ()
let stmt3 = Cil.mkEmptyStmt ~valid_sid:true ~loc:(loc_constructor "stmt" 3) ()
let stmt4 = Cil.mkEmptyStmt ~valid_sid:true ~loc:(loc_constructor "stmt" 4) ()
let stmt5 = Cil.mkEmptyStmt ~valid_sid:true ~loc:(loc_constructor "stmt" 5) ()
let stmt6 = Cil.mkEmptyStmt ~valid_sid:true ~loc:(loc_constructor "stmt" 6) ()
let stmt7 = Cil.mkEmptyStmt ~valid_sid:true ~loc:(loc_constructor "stmt" 7) ()
let stmt8 = Cil.mkEmptyStmt ~valid_sid:true ~loc:(loc_constructor "stmt" 8) ()
let stmt9 = Cil.mkEmptyStmt ~valid_sid:true ~loc:(loc_constructor "stmt" 9) ()

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
