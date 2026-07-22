extends Node

enum State {
	INITIAL_DEPLOY,
	DEPLOYING_ENEMIES,
	WAITING_FOR_PIECE_SELECTION,
	WAITING_FOR_TILE_SELECTION,
	PLAYER_PIECE_MOVING,
	ENEMY_TURN,
	BETWEEN_SETS,
	PROMOTING_PAWN,
	UPGRADE_SELECTION
}

signal state_changed(old_state: State, new_state: State)
signal turns_left_changed(new_turns: int)
signal moves_left_changed(new_turns: int)

const INITIAL_MOVES := 1
const INITIAL_TURNS := 6

var current_state := State.INITIAL_DEPLOY
var current_set := 1
var points := 100
var moves_left := INITIAL_MOVES
var turns_left := INITIAL_TURNS
var board: Board = null

func change_state(new_state: State) -> void:
	var old_state := current_state
	current_state = new_state
	state_changed.emit(old_state, new_state)
	print("State: %s -> %s" % [State.keys()[old_state], State.keys()[new_state]])

func edit_points(points_to_change: int):
	points += points_to_change

func change_set(plus = 1):
	current_set += plus

func update_moves_left(minus = -1):
	moves_left += minus
	moves_left_changed.emit(moves_left)

func update_turns_left(minus = -1):
	turns_left += minus
	turns_left_changed.emit(turns_left)

func reset_moves_and_turns():
	turns_left = INITIAL_TURNS
	moves_left = INITIAL_MOVES
	moves_left_changed.emit(moves_left)
	turns_left_changed.emit(turns_left)