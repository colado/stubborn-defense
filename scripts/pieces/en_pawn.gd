extends EnemyPiece

var has_moved: bool = false
var _pending_on_complete: Callable

func _init() -> void:
	piece_type = GlobalEnums.PieceType.EN_PAWN

func handle_move(board_data: Dictionary, on_complete: Callable) -> void:
	var origin := GameState.board.cell_to_coords(current_cell)
	var forward := Vector2i(0, -1)

	var chosen_cell := ""

	# 1. check captures first
	for dx in [-1, 1]:
		var diagonal := GameState.board.coords_to_cell(origin + Vector2i(dx, -1))
		if diagonal != "" and board_data.has(diagonal) and board_data[diagonal].is_occupied_by_player:
			chosen_cell = diagonal
			break

	# 2. no capture available — fall back to regular forward movement
	if chosen_cell == "":
		var one_step := GameState.board.coords_to_cell(origin + forward)
		var one_step_free := one_step != "" and not board_data.has(one_step)

		if not has_moved and one_step_free:
			var two_step := GameState.board.coords_to_cell(origin + forward * 2)
			var two_step_free := two_step != "" and not board_data.has(two_step)

			if two_step_free:
				chosen_cell = [one_step, two_step][randi() % 2]
			else:
				chosen_cell = one_step
		elif one_step_free:
			chosen_cell = one_step

	# 3. nothing legal to do
	if chosen_cell == "":
		on_complete.call(self)
		return

	_pending_on_complete = on_complete
	has_moved = true

	move_to(GameState.board.board_coordinates[chosen_cell], chosen_cell)


func on_move_finished(target_board_cell: String) -> void:
	super.on_move_finished(target_board_cell)
	if _pending_on_complete.is_valid():
		_pending_on_complete.call(self)
