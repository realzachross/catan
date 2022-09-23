open Board
open Player
open Game

(* This module will contain the get_command function which returns a
   command from user input*)
exception Empty

(* Raised when an empty command is parsed. *)
exception InvalidOutOfBounds

(* Raised when a out of bounds command_input is encountered. *)
exception UnownedSettlement

(*Raised if settlement user tries to upgrade is unowned*)
exception InvalidLocation

(*Raised if settlement user tries to build/upgrade on an out fo bounds
  location*)
exception TakenLocation

(*Raised if user tried to build settlement at taken location*)
exception InvalidNumInput

(*Raised if the user user passes in incorrect num_input*)

exception NoCurrentPlayer

exception RobberNotMoved
(*Raised if user tries to move the robber to its current location*)

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

val get_command : unit -> command
(*[get_command] is the command inputted by the user.*)

val move_robber : Board.t -> Board.t

type execute_command_return =
  | BoardC of Board.t
  | PlayerB
  | InputC
  | UnitC of unit

val execute :
  unit -> Board.t -> Game.t -> Player.t -> execute_command_return

val get_command_input : unit -> command_input

val turn : Player.t -> Board.t -> Game.t -> bool -> unit

val ecr_to_string : 'a -> string
