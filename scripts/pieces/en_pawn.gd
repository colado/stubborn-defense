extends EnemyPiece
class_name EnPawn

signal en_pawn_being_promoted(en_pawn: EnPawn)

var _has_moved: bool = false
var _pending_on_complete: Callable
var _capturing_cell = ""

func _init() -> void:
	piece_type = GlobalVars.PieceType.EN_PAWN

func get_capturing_cell(excluded_cells: Array[String]) -> String:
	var origin := GameState.board.cell_to_coords(current_cell)

	# 1. check captures first
	for dx in [-1, 1]:
		var diagonal := GameState.board.coords_to_cell(origin + Vector2i(dx, -1))
		if diagonal != "" and GameState.board.board_data.has(diagonal) and GameState.board.board_data[diagonal].is_occupied_by_player and not excluded_cells.has(diagonal):
			_capturing_cell = diagonal
			break
	
	return _capturing_cell

func handle_move(board_data: Dictionary, on_complete: Callable) -> void:
	var origin := GameState.board.cell_to_coords(current_cell)
	var forward := Vector2i(0, -1)

	var chosen_cell := ""

	# 1. check captures first
	if _capturing_cell != "":
		chosen_cell = _capturing_cell

	# 2. no capture available — fall back to regular forward movement
	if chosen_cell == "":
		var one_step := GameState.board.coords_to_cell(origin + forward)
		var one_step_free := one_step != "" and not board_data.has(one_step)

		if not _has_moved and one_step_free:
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
	_has_moved = true

	if GameState.board.board_data.has(chosen_cell) and GameState.board.board_data[chosen_cell].is_occupied_by_player:
		GameState.board.board_data[chosen_cell].piece.handle_getting_captured()

	move_to(GameState.board.board_coordinates[chosen_cell], chosen_cell)


func on_move_finished(target_board_cell: String) -> void:
	if target_board_cell[1] == "1":
		en_pawn_being_promoted.emit(self)
	super.on_move_finished(target_board_cell)
	if _pending_on_complete.is_valid():
		_pending_on_complete.call(self)
