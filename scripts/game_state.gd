extends Node

enum State {
	WAITING_FOR_PIECE_SELECTION,
	WAITING_FOR_TILE_SELECTION,
	PLAYER_PIECE_MOVING,
	ENEMY_TURN
}

signal state_changed(old_state: State, new_state: State)

var current_state: State = State.WAITING_FOR_PIECE_SELECTION
var board = null

func change_state(new_state: State) -> void:
	var old_state := current_state
	current_state = new_state
	state_changed.emit(old_state, new_state)
	print("State: %s -> %s" % [State.keys()[old_state], State.keys()[new_state]])