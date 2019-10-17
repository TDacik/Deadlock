open Abstract_interp
open Locations

let ival_to_int ival =
  Ival.fold_int (fun i acc ->
      Integer.to_int i :: acc
    ) ival []

let get_offset_map = function
  | Location_Bytes.Top _ -> raise Error_Top
  | Location_Bytes.Map map -> map

let is_bottom = Location_Bytes.is_bottom

(** Convert values as returned by EVA to list *)
let values_to_list = function
  | Location_Bytes.Top _ -> []
  | Location_Bytes.Map map ->
    Location_Bytes.M.fold
      (fun base _ acc -> 
         base :: acc
      ) map []

(*Prints values of given statement*)
let lock_print stmt values =
  let stmt_string = Format.asprintf "%a" Printer.pp_stmt stmt in
  Format.printf "Values %s:\t\n" stmt_string;
  Db.Value.pretty Format.std_formatter values

(** Remove bases that cannot be converted to varinfos *)
let remove_invalid_bases values =
  List.filter
    (fun (base, _) ->
       try
         let _ = Base.to_varinfo base in
         true
       with _ -> false
    ) values

let eval_no_ptr stmt expr =
  let str = Format.asprintf "%a" Printer.pp_exp expr in
  [(str, 0)]

let eval_ptr stmt expr =
  let kinstr = Cil_types.Kstmt stmt in
  let values = !Db.Value.access_expr kinstr expr in
  (*lock_print stmt values;*)
  let values_list = values_to_list values in
  let ll = List.map
      (fun base ->
         let offsets_map = get_offset_map values in
         let offsets_ival = Location_Bytes.find_or_bottom base offsets_map in
         let offsets_int = ival_to_int offsets_ival in
         List.map
           (fun offset ->
              (base, offset)
           ) offsets_int
      ) values_list in

  List.flatten ll
