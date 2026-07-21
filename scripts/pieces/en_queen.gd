extends EnemyPiece
class_name EnQueen

var _capturing_cell = ""
var _pending_on_complete: Callable

func _init() -> void:
	piece_type = GlobalVars.PieceType.EN_QUEEN

func handle_move(board_data: Dictionary, on_complete: Callable) -> void:
	if _capturing_cell == "":
		on_complete.call(self)

	if _capturing_cell != "":
		GameState.board.board_data[_capturing_cell].piece.handle_getting_captured()
		move_to(GameState.board.board_coordinates[_capturing_cell], _capturing_cell)
		_pending_on_complete = on_complete

# NEEDS TO BE TESTED!!!
func get_capturing_cell(excluded_cells: Array[String]) -> String:
	var directions = [
		Vector2i(0, 1),   # up
		Vector2i(0, -1),  # down
		Vector2i(1, 0),   # right
		Vector2i(-1, 0),  # left
		Vector2i(1, 1),   # diagonal up-right
		Vector2i(-1, 1),  # diagonal up-left
		Vector2i(1, -1),  # diagonal down-right
		Vector2i(-1, -1)  # diagonal down-left
	]

	var candidates: Array[String] = []

	var start := GameState.board.cell_to_coords(current_cell)

	for direction in directions:
		var next = start + direction

		while _is_inside_board(next):
			var coord = GameState.board.coords_to_cell(next)

			if GameState.board.board_data.has(coord):
				var cell = GameState.board.board_data[coord]

				if cell.is_occupied_by_player and not excluded_cells.has(coord):
					candidates.append(coord)

				break

			next += direction

	# No captures available
	if candidates.is_empty():
		return ""

	var capturing_cell = _get_highest_value_piece(candidates)
	_capturing_cell = capturing_cell

	return capturing_cell

func _is_inside_board(pos: Vector2) -> bool:
	return pos.x >= 0 and pos.x < 8 and pos.y >= 0 and pos.y < 8

func _get_highest_value_piece(candidates: Array[String]) -> String:
	var best_cell := ""
	var best_value := -1

	var values = {
		"king": 5,
		"queen": 4,
		"rook": 3,
		"bishop": 2,
		"knight": 2,
		"pawn": 1
	}

	for coord in candidates:
		var piece = GameState.board.board_data[coord].piece

		var value = values.get(piece.piece_type, 0)

		if value > best_value:
			best_value = value
			best_cell = coord

	return best_cell

func on_move_finished(target_board_cell: String) -> void:
	super.on_move_finished(target_board_cell)
	if _pending_on_complete.is_valid():
		_pending_on_complete.call(self)
	_capturing_cell = ""