extends Piece
class_name PlayerPiece

signal piece_selected(piece: Area3D)
signal player_piece_finished_move(cell: String)

func on_move_finished(coord: String):
	GameState.board.update_board_data(current_cell, coord, self, true)
	current_cell = coord
	player_piece_finished_move.emit(current_cell)

func _input_event(_camera, event, _position, _normal, _shape_idx) -> void:
	if (event is InputEventMouseButton or event is InputEventScreenTouch) and event.pressed:
		piece_selected.emit(self)
