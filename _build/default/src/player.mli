(** Representation of a player in the game Catan This module contains
    all of the functions and type definitions for players, including
    resources, cities/settlements, victory points, and development
    cards. It handles actions that players will take to interact with
    the game, such as rolling the dice or making a purchase. *)

type t
(** The abstract type of values that represent a player in Catan. *)

type player_id = string
(** The type [player_id] represents the player identifier for a player
    in Catan. *)

type resource =
  | Brick
  | Lumber
  | Ore
  | Grain
  | Wool
  | None  (** The type representing kinds of hexagons on the board*)

val to_string : t -> string
(** [to_string pl] pretty prints the content of player [pl] Requires:
    [pl] is a valid player*)

val create_player :
  player_id -> (resource * int) list -> int -> ANSITerminal.style -> t
(** [create_player id res points] creates a new player with id [id],
    resources [res] and number of vicotry points [points] with color
    [color]. Requires: [resources] is a valid list of pairs with valid
    resource values and integer values greater than 0, [color] is a
    valid ANSITerminal.style*)

val init_player : player_id -> ANSITerminal.style -> t
(** [create_player id] creates a new player with id [id] and color
    [color], no resources, victory points, or development cards*)

val init_demo_player : player_id -> ANSITerminal.style -> t

val get_num_resource : t -> resource -> int
(** [get_num_resource pl res] is the number of resource [res] owned by
    player [pl]. Requires: [pl] is a valid player representation and
    [res] is a valid resource. Raises: NotAResource if resource None is
    input Example: get_num_resources player1 Brick = 4 - indicates that
    player1 currently possesses 4 bricks*)

val add_resources : t -> (resource * int) list -> t
(** [add_resources pl resources] is a [pl] with additional resources
    allocated by [resources] that are distributed on every turn. Raises:
    NotAResource if resource None is input. Requires: [pl] is a valid
    player; [resources] is a valid list of pairs with valid resource
    values and integer values greater than 0*)

val get_num_victory_points : t -> int
(** [get_num_victory_points pl] is the number of victory points that a
    player [pl] possesses. Requires: [pl] is a valid player
    representation. Example: get_num_victory_ponts player1 = 2*)

val inc_num_victory_ponts : t -> int -> t
(**[inc_num_victory_ponts pl vp] is a player with [vp] additional
   victory points. Requires: [pl] is a valid player; [vp] is an integer
   between 0 and 10*)

val dec_num_victory_ponts : t -> int -> t
(**[dec_num_victory_ponts pl vp] is a player with [vp] less victory
   points. Requires: [pl] is a valid player; [vp] is an integer between
   0 and 10*)

val get_player_id : t -> player_id
(**[get_player_id pl] returns the player id of the player [pl]*)

val to_string : t -> string
(**[to_string pl] returns a string representation of a player. *)

exception InsufficientResources of resource
(* thrown when a player does not have sufficient resources of type
   [resource] to perform a requested action*)

val trade_resource : resource -> resource -> t -> t
(** [trade_resource selling_resource buying_resource pl] is a player
    that has traded in 4 resource cards of type [selling_resource] for 1
    resource card of type [buying_resource]. Raises
    [InsufficientResources selling_resource] if the player does not have
    at least 4 resource cards of type [selling_resource]. Requires: [pl]
    is a valid player and [selling_resource] and [buying_resource] are
    valid resource types. *)

val print_player : t -> unit
(** [print_player player] pretty prints the player [player] with colors
    to cli Requires: [player] is a valid player*)

val buy_settlement : t -> t
(* [buy_settlement player] is [player] with resources decremented to
   take into account the purchase of a settlement. Raises
   [InsufficientResources selling_resource] if the player does not have
   sufficient resources to buy a settlement.*)

val buy_city : t -> t
(* [buy_city player] is [player] with resources decremented to take into
   account the purchase of a city. Raises [InsufficientResources
   selling_resource] if the player does not have sufficient resources to
   buy a city.*)

val buy_road : t -> t
(* [buy_road player] is [player] with resources decremented to take into
   account the purchase of a road. Raises [InsufficientResources
   selling_resource] if the player does not have sufficient resources to
   buy a road.*)

val trade_resource_with_port : t -> resource -> resource -> t
(* [trade_resource_with_port player outgoing_resource incoming_resource]
   is [player] after trading [outgoing_resource] to a port for
   [incoming_resource]. Raises [InsufficientResources selling_resource]
   if the player does not have sufficient resources to trade with a
   port.*)

val resource_to_string : resource -> string
(* [resource_to_string resource] is the string representation of a
   resource. The corresponding string representation of each resource is
   as follows: Brick -> "Brick", Lumber -> "Lumber", Ore -> "Ore", Grain
   -> "Grain", Wool -> "Wool", None -> ""*)

val player_with_new_resource : t -> resource -> t
(* [player_with_new_resource player resource] is [player] with with an
   additional resource of type [resource] in its inventory*)

val set_color : t -> ANSITerminal.style -> t
(* [set_color player color] is [player] with its color set to [color]*)

val get_color : t -> ANSITerminal.style
(* [get_color player] is the color associated with [player]*)
