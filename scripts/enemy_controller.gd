extends Node3D

var _pieces_remaining: int = 0

func _ready() -> void:
	GameState.state_changed.connect(_handle_state_changed)
	for child in get_children():
		GameState.board.update_board_data(child.current_cell, child.current_cell, child, false)

func _handle_state_changed(_old_state: GameState.State, new_state: GameState.State):
	if new_state == GameState.State.ENEMY_TURN:
		_handle_enemy_movement()

func _handle_enemy_movement() -> void:
	var pieces := get_children()
	_pieces_remaining = pieces.size()

	if _pieces_remaining == 0:
		_on_all_pieces_done()
		return

	for piece in pieces:
		piece.handle_move(GameState.board.board_data, _on_piece_move_finished)

func _on_piece_move_finished(_piece: Node) -> void:
	_pieces_remaining -= 1
	if _pieces_remaining <= 0:
		_on_all_pieces_done()


func _on_all_pieces_done() -> void:
	GameState.change_state(GameState.State.WAITING_FOR_PIECE_SELECTION)
