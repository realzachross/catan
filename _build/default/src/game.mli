(** Representation of a game in the game Catan.

    This module contains all of the functions and type definitions for
    games, including the players, board, and states of the game at a
    given point in time. It handles changes that affect the state of the
    game with each turn. *)

type t
(** The abstract type of values that represent a game in Catan. *)

exception InvalidPlayer
(* thrown when the function attempts to use an invalid player*)

exception InvalidTrade
(* thrown when an invalid trade is attempted in the game*)

val get_board : t -> Board.t
(** [get_board gm] is the board that is associated with the game [gm]*)

val get_players : t -> Player.t array
(** [get_players gm] is the list of players associated with the game
    [gm]*)

val get_curr_pl_ind : t -> int
(* [get_curr_pl_ind game] is the index of the current player in [game]*)

val get_current_player : t -> Player.t
(** [get_current_player gm] is the current player associated with the
    game [gm]*)

val next_player : t -> unit
(** [next_player gm] mutates the game to increment the player *)

val vp_from_cities_and_settlements : Player.t -> Board.t -> int
(*[get_victory_points p b] is the number of victory points exclusively
  from cities and settlements Player.t [p] has Board.t [b].*)

val get_victory_points : Player.t -> Board.t -> t -> int
(** [get_victory_points pl brd] is the number of victory points owned by
    [pl]. Requires: [pl] is a valid Player.t and [brd] is a valid
    Board.t. Output should always be between 2 and 10. *)

val update_board : t -> Board.t -> t
(* [update_board game baord] is game with its board updated to [board].
   Requires: [game] to be a valid game and [board] to be a valid
   board.*)

val update_players : t -> Player.t array -> t
(* [update_ players game players] is game with its array of players
   updates to [players]. Requires: [game] is a valid game and [players]
   has a length in the range [2, 4] and contains only valid players.*)

val init_game : Player.t array -> Board.t -> t
(** [create_game players board] creates a new game with players
    [players], board [board]. Requires: [players] is a valid list of
    Player and [board] is a valid Board*)

val can_trade : Player.t -> (Player.resource * int) list -> unit
(** [can_trade pl \[(r1,n1);..(rn,nn)\]] returns () if player [pl] has
    at least ni resources of resurce ri for 1 <= i <= n Raises: Invalid
    trade if [pl] has less than ni resources of resource ri for any
    1<=i<=n*)

val trade :
  Player.player_id ->
  (Player.resource * int) list ->
  (Player.resource * int) list ->
  t ->
  unit
(** [trade pl wishlist givelist state] gives the wishlist to
    [current player] and the givelist to [pl]. Raises InvalidTrade if
    [current player] cannot supply [givelist] or [pl] cannot supply
    [wishlist]*)

val get_player_with_longest_road : t -> Player.t
(** [get_player_with_longest_road gm] is the Player.t with the longest
    road bonus currently. Player.t must have a longest road of at least
    5, or else the longest road bonus does not apply. Requires: [gm] is
    a valid game. *)

val valid_player : Player.player_id -> t -> bool
(** [valid_player pl gm] is true if [pl] corresponds to a player in
    [gm], false otherwise*)

val set_player : t -> 'a -> Player.t -> t
(* [set_player game player new_player] is the game with [player]
   replaced with [new_player]. Requires: [new_player] is a valid player
   [player] is contained [game]'s array of players.*)

val get_game_with_incremented_player : t -> t
(* [get_game_with_incrememented_player game] returns [game] with the
   current player advanced to the next player Requires: [game] is a
   valid game.*)

val player_string : Player.t -> Board.t -> t -> string
(* [player_string player board game] is the string representation of
   [player] in [game]. The string is of the form : "[player
   name]\nVictory Point's: [num_victory_points]"*)

val set_curr_player : t -> Player.t -> unit
(*[set_curr_player game player] modifies the state of game such that the
  current player becomes [player]. Requires: [player] is a valid player
  and [game] is a valid game.*)

val set_players : t -> Player.t array -> unit
(* [set_players game players] modifies the state of [game] such that the
   array of players is set to [players]. Requires: [game] is a valid
   game and [players] has a length in the range [2, 4] and contains only
   valid players. *)

val max_victory_points : Player.t array -> Board.t -> t -> int option
(* [max_victory_points players board game] is the int option of the
   array index correspodning to the player with the highest number of
   victory points. If [players] has a length of 0 the int option return
   will be None.*)

val get_player_color_pairs :
  t -> (Player.player_id * ANSITerminal.style) list
(* [get_player_color_pairs game] is a list of pairs for each player of
   the following format: ([player_id], [player_color]). Each pair will
   will correspond to a specific player. Requires: [game] is a valid
   game.*)
