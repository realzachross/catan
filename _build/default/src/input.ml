(*Note, need to app handling of exceptions*)

exception Empty

exception InvalidOutOfBounds

exception UnownedSettlement

exception InvalidLocation

exception TakenLocation

exception InvalidNumInput

exception NoCurrentPlayer

exception InvalidResource

exception RobberNotMoved

type command_input = int

type trade_player = {
  trade_with : Player.player_id;
  wishlist : (Player.resource * int) list;
  givelist : (Player.resource * int) list;
}

type trade_bank = {
  owned_resource : Player.resource;
  wanted_resource : Player.resource;
}

type trade =
  | Bank of trade_bank
  | Player of trade_player

type tradePlayer = {
  trade_with : Player.player_id;
  wishlist : (Player.resource * int) list;
  givelist : (Player.resource * int) list;
}

type num_input =
  | Int of Board.node_position
  | Pair of Board.node_position * Board.node_position
  | Trade of trade
  | None

type command =
  | Quit
  | TradeResource of trade
  | BuildSettlement of Board.node_position
  | UpgradeSettlement of Board.node_position
  | BuildRoad of Board.node_position * Board.node_position
  | End

let is_valid_num_input c ni =
  match c with
  | 1 -> ni
  | 2 -> begin
      match ni with
      | Trade (Bank { owned_resource; wanted_resource }) -> ni
      | Trade (Player { trade_with; wishlist; givelist }) -> ni
      | _ -> raise InvalidNumInput
    end
  | 3 -> begin
      match ni with
      | Int n -> ni
      | _ -> raise InvalidNumInput
    end
  | 4 -> begin
      match ni with
      | Int n -> ni
      | _ -> raise InvalidNumInput
    end
  | 5 -> begin
      match ni with
      | Pair (x, y) -> ni
      | _ -> raise InvalidNumInput
    end
  | 6 -> ni
  | _ -> raise InvalidOutOfBounds

let input_to_command i n =
  match i with
  | 1 -> Quit
  | 2 ->
      TradeResource
        (match is_valid_num_input i n with
        | Trade n -> n
        | _ -> raise InvalidNumInput)
  | 3 ->
      BuildSettlement
        (match is_valid_num_input i n with
        | Int n -> n
        | _ -> raise InvalidNumInput)
  | 4 ->
      UpgradeSettlement
        (match is_valid_num_input i n with
        | Int n -> n
        | _ -> raise InvalidNumInput)
  | 5 ->
      BuildRoad
        ( (match is_valid_num_input i n with
          | Pair (x, _) -> x
          | _ -> raise InvalidNumInput),
          match is_valid_num_input i n with
          | Pair (_, y) -> y
          | _ -> raise InvalidNumInput )
  | 6 -> End
  | _ -> raise InvalidOutOfBounds
(*[input_to_command i] is the command corresponding to the inputted
  commapndInput [i]. [Requires] i is in the range [1, 6]. [i]
  corresponds the the commands as follows: 1 -> Quit 2 -> TradeResource
  3 -> BuildSettlement 4 -> UpgradeSettlement 5 -> BuildRoad 6 -> End *)

let command_input_prompt =
  "What would you like to do?\n\
  \ 1. Quit\n\
  \ 2. Trade resources\n\
  \ 3. Build a settlement\n\
  \ 4. Upgrade a settlement\n\
  \ 5. Build a road\n\
  \ 6. End Turn\n\n\
   Enter a number: "

let check_command_input n = if n > 6 || n < 1 then false else true

(*[check_command_input] checks to make sure the command input is in the
  range [1,7]*)
let rec get_command_input () =
  let () = print_string command_input_prompt in
  let i =
    try read_int () with
    | Failure _ ->
        Printers.red_print_endline
          "\nTry again. Please Enter a valid input. \n";
        get_command_input ()
  in
  if check_command_input i then i
  else
    let () =
      print_string
        "\n\
         ***********************************************\n\
         Try again. Input must be in range [1, 6]\n\
         ***********************************************\n"
    in
    let () = print_newline () in
    get_command_input ()

(*[get_command_input] is the command input of the user. This function
  outputs a prompt to the user and will continue to output a prompt
  until a valid input ([1, 6]) is entered*)

let check_num_input_int n = if n > 53 || n < 0 then false else true

let num_input_prompt_bs =
  "Which position do you want to build your settlement at?\n\
   Enter a value in the range [0, 53]: "

let num_input_prompt_us =
  "Which position do you want to upgrade your settlement at?\n\
   Enter a value in the range [0, 53]: "

let num_input_prompt_br =
  "Which position do you want to build your road at?\n\
   Enter a 2 different space seperated values, each in\n\
   the range of [0, 53]: "

let rec get_int_num_input s =
  let () = print_string s in
  let i =
    try read_int () with
    | Failure _ ->
        Printers.red_print_endline
          "\nTry again. Please Enter a valid input. \n";
        get_command_input ()
  in
  if check_num_input_int i = true then i
  else
    let () =
      print_string
        "\n\
        \ ***********************************************\n\
         Try again. Input must be in range [0, 53]\n\
        \ ***********************************************\n"
    in
    let () = print_newline () in
    get_int_num_input s

let not_pair () =
  print_string
    "\n\
     ***********************************************\n\
    \ Try again. Input must be 2 different space seperated values, \
     each in range [0,  53]\n\
    \ Example: 10, 12\n\n\
    \ ***********************************************\n"

let input_to_pair s =
  match
    List.map
      (fun s -> int_of_string s)
      (List.filter
         (fun s -> s <> " ")
         (String.split_on_char ' ' (s ())))
  with
  | [ x; y ] -> (x, y)
  | _ -> (-420, 69)

let rec get_pair_num_input () =
  let () = print_string num_input_prompt_br in
  let i =
    try input_to_pair (fun () -> read_line ()) with
    | Failure _ ->
        Printers.red_print_endline
          "\nTry again. Please Enter a valid input. \n";
        get_pair_num_input ()
  in
  if Board.is_valid_edge i then i
  else
    let () =
      Printers.red_print
        "\nPlease Enter a Valid Road with Two Valid Locations\n"
    in
    let () = print_newline () in
    get_pair_num_input ()

let rec list_to_pair_list lst =
  match lst with
  | x :: y :: t -> (x, y) :: list_to_pair_list t
  | h :: t ->
      raise InvalidNumInput (* because not every resource has a num*)
  | [] -> []

let string_to_resource s =
  match s with
  | "Brick" -> Player.Brick
  | "Lumber" -> Player.Lumber
  | "Ore" -> Player.Ore
  | "Wool" -> Player.Wool
  | "Grain" -> Player.Grain
  | "brick" -> Player.Brick
  | "lumber" -> Player.Lumber
  | "ore" -> Player.Ore
  | "wool" -> Player.Wool
  | "grain" -> Player.Grain
  | "None" -> Player.None
  | "none" -> Player.None
  | _ -> raise InvalidResource

(*Trading**********************************************************************)
(*Trading**********************************************************************)
(*Trading**********************************************************************)

let is_valid_trade_type n = if n < 1 || n > 2 then false else true

let rec get_trade_type () =
  let () =
    print_string
      "Which kind of trade would you like to make?\n\
      \      1. Bank\n\
      \      2. Player\n\
      \      Enter a number: "
  in
  let i =
    try read_int () with
    | Failure _ ->
        Printers.red_print_endline
          "\nTry again. Please Enter a valid input. \n";
        get_command_input ()
  in
  if is_valid_trade_type i = true then i
  else
    let () =
      print_string
        "\n\
         ***********************************************\n\
        \  Try again. Input must be in range [1, 2]\n\
         ***********************************************\n"
    in
    let () = print_newline () in
    get_trade_type ()

let check_trade_input_player id gm = Game.valid_player id gm

let trade_num_input_player_prompt =
  "\n\
   ************************************************************\n\
  \ Try again. Input must be a valid player id\n\
   ************************************************************\n"

let trade_num_input_wishlist_prompt =
  "\n\
   ****************************************************************************\n\
   Try again. Input must be a valid wishlist of the form [resource] \
   [num] ...\n\
   ****************************************************************************\n"

let trade_num_input_givelist_prompt =
  "\n\
   ****************************************************************************\n\
   Try again. Input must be a valid givelist of the form [resource] \
   [num] ...\n\
   ****************************************************************************\n"

(*let rec get_trade_num_input_player () = print_string "Who would you\n\
  \ like to trade with?\n\ \ Enter a valid id of another player: "; let
  i = read_line () in if check_trade_input_player i then i else (
  print_endline trade_num_input_player_prompt;
  get_trade_num_input_player ())

  let get_trade_num_input_wishlist () = List.map (fun x -> match x with
  | res, num -> (string_to_resource res, int_of_string num))
  (list_to_pair_list (String.split_on_char ' '
  (get_trade_num_input_player ())))

  let get_trade_num_input_givelist () = List.map (fun x -> match x with
  | res, num -> (string_to_resource res, int_of_string num))
  (list_to_pair_list (String.split_on_char ' '
  (get_trade_num_input_player ())))*)

let is_valid_resource_input p =
  match p with
  | [ x; y ] -> true
  | _ -> false

let get_rec_error_prompt =
  "\n\
   *********************************************************************************\n\
   Try again. Input must be a valid space seperated pair of resources \
   of the form \n\
  \ [owned resource] [wanted resource] ...\n\
   *********************************************************************************\n"

let rec get_rec () =
  let () =
    print_string
      "Enter two space seperated resources of the format [owned \
       resource] [wanted resource]: "
  in
  let i =
    List.map
      (fun x -> string_to_resource x)
      (String.split_on_char ' ' (read_line ()))
  in
  if is_valid_resource_input i = true then
    match i with
    | [ x; y ] -> { wanted_resource = x; owned_resource = y }
    | _ ->
        let () = print_string get_rec_error_prompt in
        get_rec ()
  else
    let () = print_string get_rec_error_prompt in
    get_rec ()

let get_trade_command_from_input n =
  match n with
  | 1 -> Bank (get_rec ())
  | 2 ->
      failwith "unimplemented"
      (* Player { trade_with = get_trade_num_input_player (); wishlist =
         get_trade_num_input_wishlist (); givelist =
         get_trade_num_input_givelist ();}*)
  | _ -> raise InvalidNumInput

(******************************************************************************)
(******************************************************************************)
(******************************************************************************)

let get_par_fst p =
  match p with
  | x, _ -> x

(*[get_par_fst p] is the first member of pair [p]*)
let get_par_snd p =
  match p with
  | _, y -> y

(*[get_par_snd p] is the second member of pair [p]*)
let get_num_input command =
  match command with
  | 1 -> None
  | 2 -> Trade (get_trade_command_from_input (get_trade_type ()))
  | 3 -> Int (get_int_num_input num_input_prompt_bs)
  | 4 -> Int (get_int_num_input num_input_prompt_us)
  | 5 ->
      let p = get_pair_num_input () in
      Pair (get_par_fst p, get_par_snd p)
  | 6 -> None
  | _ -> raise InvalidOutOfBounds

let get_command () =
  let c = get_command_input () in
  input_to_command c (get_num_input c)

type execute_command_return =
  | BoardC of Board.t
  | PlayerB
  | InputC
  | UnitC of unit

let ecr_to_string ecr = ""

let execute_command command board game player =
  match command with
  | BuildSettlement n ->
      Game.set_curr_player game
        (Player.buy_settlement (Game.get_current_player game));
      BoardC
        (Board.buy_sett n
           (Player.get_player_id (Game.get_current_player game))
           board)
  | TradeResource trade -> begin
      match trade with
      | Bank { owned_resource; wanted_resource } ->
          Game.set_curr_player game
            (Player.trade_resource owned_resource wanted_resource
               (Game.get_current_player game));
          PlayerB
      | Player { trade_with; wishlist; givelist } ->
          UnitC (Game.trade trade_with wishlist givelist game)
    end
  | UpgradeSettlement n ->
      Game.set_curr_player game
        (Player.buy_city (Game.get_current_player game));
      BoardC
        (Board.upgr_city n
           (Player.get_player_id (Game.get_current_player game))
           board)
  | BuildRoad (x, y) ->
      Game.set_curr_player game
        (Player.buy_road (Game.get_current_player game));
      BoardC
        (Board.buy_road (x, y)
           (Player.get_player_id (Game.get_current_player game))
           board)
  | End -> InputC
  | Quit ->
      Printers.red_print_endline "Thanks for playing!";
      exit 0

let execute () = execute_command (get_command ())

let valid_hex n = n <= 18 && n >= 0

(*converts user input of desired hexagon to hexagon number in the
  backend*)
let i_o_pos pos : int =
  let arr =
    [|
      -1;
      7;
      3;
      12;
      0;
      8;
      16;
      4;
      13;
      1;
      9;
      17;
      5;
      14;
      2;
      10;
      18;
      6;
      15;
      11;
    |]
  in
  arr.(pos)

(* user input of robber placement and moves robber in the backend*)
let rec move_robber board =
  print_endline
    "You have rolled a 7! Choose a new location for the robber.";
  Printers.yellow_print
    "Note: the board now tmeporarily shows locations.\n";
  print_endline
    "The new location must be an integer in the range [0, 18].\n\
    \    Enter input: ";
  let rec get_pos () =
    try
      let pos = read_int () in
      if pos <= 19 && pos >= 1 then i_o_pos pos
      else (
        Printers.red_print_endline
          "\nTry again. Please enter a value in the range [0]1, 19].\n";
        get_pos ())
    with
    | Failure _ ->
        Printers.red_print_endline
          "\nTry again. Please Enter a valid input. \n";
        get_pos ()
  in
  try Board.rob (get_pos ()) board with
  | RobberNotMoved -> move_robber board

let apply_updates pair player =
  if fst pair = Player.get_player_id player then
    Player.player_with_new_resource player (snd pair)
  else player

let rec update_players_with_resources lst game =
  match lst with
  | [] -> ()
  | h :: t ->
      let apply_updates_with_h player = apply_updates h player in
      Game.set_players game
        (Array.map apply_updates_with_h (Game.get_players game));
      update_players_with_resources t game

(* main turn function*)
let rec turn player board game flag =
  if flag then (
    Printers.cyan_print_endline
      ("" ^ (player |> Player.get_player_id |> String.trim) ^ "'s Turn:");
    let roll =
      Random.self_init ();
      Random.int 10 + 2
    in
    let new_resources = Board.get_updates roll board in
    update_players_with_resources new_resources game;
    Printers.green_print_endline ("Your roll: " ^ string_of_int roll);
    print_endline (Game.player_string player board game);
    if roll = 7 then
      (Board.print_board_alt board (Game.get_player_color_pairs game);
       turn player (move_robber board) game)
        false
    else turn player board game false)
  else Board.print_board board (Game.get_player_color_pairs game);
  try
    let input_command = get_command () in
    let cmd = execute_command input_command board game player in
    match cmd with
    | BoardC brd -> turn (Game.get_current_player game) brd game false
    | PlayerB ->
        turn
          (Game.get_current_player game)
          (Game.get_board game) game false
    | InputC ->
        Game.next_player game;
        let next_player = Game.get_current_player game in
        turn next_player board game true
    | _ -> turn player board game false
  with
  (*may delete pattern below*)
  | Board.InvalidPlacement -> (
      Printers.red_print_endline
        "\nPlease Enter a Valid Road with Two Valid Locations\n";
      let input_command = get_command () in
      let cmd = execute_command input_command board game player in
      match cmd with
      | BoardC brd -> turn (Game.get_current_player game) brd game false
      | PlayerB -> turn (Game.get_current_player game) board game false
      | InputC ->
          Game.next_player game;
          let next_player = Game.get_current_player game in
          turn next_player board game false
      | _ -> turn player board game false)
  | InvalidOutOfBounds -> (
      Printers.red_print_endline
        "\nPlease Enter a Valid Road with Two Valid Locations\n";
      let input_command = get_command () in
      let cmd = execute_command input_command board game player in
      match cmd with
      | BoardC brd -> turn (Game.get_current_player game) brd game false
      | PlayerB -> turn (Game.get_current_player game) board game false
      | InputC ->
          Game.next_player game;
          let next_player = Game.get_current_player game in
          turn next_player board game false
      | _ -> turn player board game false)
  | Failure _ -> (
      Printers.red_print_endline "\nPlease Enter a Valid Option\n";
      let input_command = get_command () in
      let cmd = execute_command input_command board game player in
      match cmd with
      | BoardC brd -> turn (Game.get_current_player game) brd game false
      | PlayerB -> turn (Game.get_current_player game) board game false
      | InputC ->
          Game.next_player game;
          let next_player = Game.get_current_player game in
          turn next_player board game false
      | _ -> turn player board game false)
  | _ -> (
      Printers.red_print_endline "Invalid option. Please try again.\n";
      let input_command = get_command () in
      let cmd = execute_command input_command board game player in
      match cmd with
      | BoardC brd -> turn (Game.get_current_player game) brd game false
      | PlayerB -> turn (Game.get_current_player game) board game false
      | InputC ->
          Game.next_player game;
          let next_player = Game.get_current_player game in
          turn next_player board game false
      | _ -> turn player board game false)
