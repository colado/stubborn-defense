extends EnemyPiece
class_name EnPawn

signal en_pawn_being_promoted(en_pawn: EnPawn)

var _has_moved: bool = false
var _pending_on_complete: Callable
var _next_cell = ""

func _init() -> void:
	piece_type = GlobalVars.PieceType.EN_PAWN

func get_capturing_cell(excluded_cells: Array[String]) -> String:
	var origin := GameState.board.cell_to_coords(current_cell)

	# 1. check captures first
	for dx in [-1, 1]:
		var diagonal := GameState.board.coords_to_cell(origin + Vector2i(dx, -1))
		if diagonal != "" and GameState.board.board_data.has(diagonal) and GameState.board.board_data[diagonal].is_occupied_by_player and not excluded_cells.has(diagonal) and not GameState.board.board_data[diagonal].is_elevated:
			_next_cell = diagonal
			break
	
	return _next_cell

func get_next_cell(excluded_cells: Array[String]) -> String:
	var origin := GameState.board.cell_to_coords(current_cell)
	var forward := Vector2i(0, -1)
	
	if _next_cell != "":
		return _next_cell
	else:
		var one_step := GameState.board.coords_to_cell(origin + forward)
		var one_step_free := one_step != "" \
			and not excluded_cells.has(one_step) \
			and (
				not GameState.board.board_data.has(one_step) \
				or not GameState.board.board_data[one_step].is_occupied_by_player
			) \
			and (
				not GameState.board.board_data.has(one_step) \
				or not GameState.board.board_data[one_step].is_elevated
			)

		if not _has_moved and one_step_free:
			var two_step := GameState.board.coords_to_cell(origin + forward * 2)
			var two_step_free := two_step != "" \
				and not excluded_cells.has(two_step) \
				and (
					not GameState.board.board_data.has(two_step) \
					or not GameState.board.board_data[two_step].is_occupied_by_player
				) \
			and (
				not GameState.board.board_data.has(two_step) \
				or not GameState.board.board_data[two_step].is_elevated
			)

			if two_step_free:
				_next_cell = [one_step, two_step][randi() % 2]
			else:
				_next_cell = one_step
		elif one_step_free:
			_next_cell = one_step
		else:
			_next_cell = current_cell
	
	return _next_cell

func handle_move(board_data: Dictionary, on_complete: Callable) -> void:
	if _next_cell == "":
		on_complete.call(self)
		return

	_pending_on_complete = on_complete
	_has_moved = true

	if GameState.board.board_data.has(_next_cell) and GameState.board.board_data[_next_cell].is_occupied_by_player:
		GameState.board.board_data[_next_cell].piece.handle_getting_captured()

	move_to(GameState.board.board_coordinates[_next_cell], _next_cell)


func on_move_finished(target_board_cell: String) -> void:
	_next_cell = ""
	if target_board_cell[1] == "1":
		en_pawn_being_promoted.emit(self)
	super.on_move_finished(target_board_cell)
	if _pending_on_complete.is_valid():
		_pending_on_complete.call(self)
