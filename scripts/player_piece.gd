extends Piece
class_name PlayerPiece

signal piece_selected(piece: Area3D)

func on_move_finished(coord: String):
	GameState.change_state(GameState.State.ENEMY_TURN)
	GameState.board.update_board_data(current_cell, coord, self, true)
	current_cell = coord

func _input_event(_camera, event, _position, _normal, _shape_idx) -> void:
	if (event is InputEventMouseButton or event is InputEventScreenTouch) and event.pressed:
		piece_selected.emit(self)
