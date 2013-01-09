val cell_size : int ref = {contents = 50}
val bg_r : int ref = {contents = 50}
val bg_g : int ref = {contents = 150}
val bg_b : int ref = {contents = 50}
val size : int ref = {contents = 8}
val ia : bool ref = {contents = true}
val depth : int ref = {contents = 4}
type cell = White | Black | Empty
type board = cell array array
type coord = int * int
type coord_list = coord list
val make_othello_board : cell array array =
  [|[|Empty; Empty; Empty; Empty; Empty; Empty; Empty; Empty|];
    [|Empty; Empty; Empty; Empty; Empty; Empty; Empty; Empty|];
    [|Empty; Empty; Empty; Empty; Empty; Empty; Empty; Empty|];
    [|Empty; Empty; Empty; Empty; Empty; Empty; Empty; Empty|];
    [|Empty; Empty; Empty; Empty; Empty; Empty; Empty; Empty|];
    [|Empty; Empty; Empty; Empty; Empty; Empty; Empty; Empty|];
    [|Empty; Empty; Empty; Empty; Empty; Empty; Empty; Empty|];
    [|Empty; Empty; Empty; Empty; Empty; Empty; Empty; Empty|]|]
val copy_board : 'a array array -> 'a array array = <fun>
val make_board : cell array array =
  [|[|Empty; Empty; Empty; Empty; Empty; Empty; Empty; Empty|];
    [|Empty; Empty; Empty; Empty; Empty; Empty; Empty; Empty|];
    [|Empty; Empty; Empty; Empty; Empty; Empty; Empty; Empty|];
    [|Empty; Empty; Empty; White; Black; Empty; Empty; Empty|];
    [|Empty; Empty; Empty; Black; White; Empty; Empty; Empty|];
    [|Empty; Empty; Empty; Empty; Empty; Empty; Empty; Empty|];
    [|Empty; Empty; Empty; Empty; Empty; Empty; Empty; Empty|];
    [|Empty; Empty; Empty; Empty; Empty; Empty; Empty; Empty|]|]
val display_cell : cell array array -> int -> int -> unit = <fun>
val display_board : cell array array -> unit = <fun>
val display_message : string -> unit = <fun>
val count : 'a array array -> 'a -> int = <fun>
val is_finished : cell array array -> bool = <fun>
val check_pos : 'a array array -> int -> int -> bool = <fun>
val get_opponent : cell -> cell = <fun>
val playable_dir : cell array array -> cell -> int * int -> int * int -> bool =
  <fun>
val playable_cell : cell array array -> cell -> int -> int -> bool = <fun>
val play_cell : cell array array -> cell -> int -> int -> unit = <fun>
val sim_play_cell :
  cell array array -> cell -> int -> int -> cell array array = <fun>
val playable_cells : cell array array -> cell -> (int * int) list = <fun>
val score : cell array array -> cell -> int = <fun>
val display_scores : cell array array -> unit = <fun>
val fold_until : ('a -> 'b -> 'a) -> ('a -> bool) -> 'a -> 'b list -> 'a =
  <fun>
val alpha_beta : cell array array -> cell -> int -> int -> int -> int = <fun>
val player_turn : cell array array -> unit = <fun>
val ia_turn : cell array array -> unit = <fun>
val rdm_turn : cell array array -> unit = <fun>
val end_message : cell array array -> string = <fun>
val continue : unit -> bool = <fun>
val game : unit -> unit -> unit = <fun>
val speclist : (string * Arg.spec * string) list =
  [("-size", Arg.Int <fun>, "<int> : set cell size in pixels");
   ("-ia", Arg.Bool <fun>, "<bool> : intelligence artificielle on/off");
   ("-depth", Arg.Int <fun>, "<int> : profondeur de l'algorithme minimax");
   ("-background", Arg.Tuple [Arg.Int <fun>; Arg.Int <fun>; Arg.Int <fun>],
    "<int> <int> <int> : set background (RGB)")]
val main : unit -> unit -> unit = <fun>