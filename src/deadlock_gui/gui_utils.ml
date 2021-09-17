(* Is string representing abstract state too long? *)
let state_too_long state =
  let str = Format.asprintf "%a" Cvalue.Model.pretty state in
  String.length str > 34

let text_window parent title text () =
  let height = int_of_float (float parent#default_height *. 3. /. 4.) in
  let width = int_of_float (float parent#default_width *. 3. /. 4.) in
  let window = GWindow.window 
      ~width
      ~height
      ~title
      ~resizable:true
      ~position:`CENTER ()
  in
  let label = (GMisc.label ~text ())#coerce in
  window#add label;
  window#show();
  ()
