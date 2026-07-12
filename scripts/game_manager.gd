extends Node3D

@onready var board = $Board

var active_piece: Area3D
var allowed_moves: Array[String]

func _ready() -> void:
	board.piece_moving.connect(handle_piece_moving)
	
	for child in get_children():
		if child is PlayerPiece:
			child.piece_selected.connect(_on_piece_selected)
			board.update_board_data(child.current_cell, child.current_cell, child.piece_type, true)
	for child in board.get_children():
		if child is Tile:
			child.clicked.connect(_on_tile_selected)

func _on_tile_selected(_tile: Tile, coord: String):
	if GameState.current_state == GameState.State.WAITING_FOR_TILE_SELECTION:
		if allowed_moves.has(coord):
			board.update_board_data(active_piece.current_cell, coord, active_piece.piece_type, true)
			active_piece.move_to(board.board_coordinates[coord], coord)
		active_piece = null
		allowed_moves = []
		GameState.change_state(GameState.State.ENEMY_TURN)

func _on_piece_selected(piece: Area3D) -> void:
	if GameState.current_state == GameState.State.WAITING_FOR_PIECE_SELECTION:
		active_piece = piece
		allowed_moves = get_allowed_moves(piece.piece_type, piece.current_cell, board.board_data)
		GameState.change_state(GameState.State.WAITING_FOR_TILE_SELECTION)

func handle_piece_moving(piece: PlayerPiece, to: Vector3, coord: String):
	for child in get_children():
		if child is PlayerPiece:
			if child.get_instance_id() == piece.get_instance_id():
				child.move_to(to, coord)

func get_allowed_moves(piece_type: GlobalEnums.PieceType, current_cell: String, board_data: Dictionary) -> Array[String]:
	match piece_type:
		GlobalEnums.PieceType.PAWN:
			return _get_pawn_moves(current_cell, board_data)
		GlobalEnums.PieceType.KNIGHT:
			return _get_knight_moves(current_cell, board_data)
		GlobalEnums.PieceType.BISHOP:
			return _get_sliding_moves(current_cell, board_data, [Vector2i(1, 1), Vector2i(1, -1), Vector2i(-1, 1), Vector2i(-1, -1)])
		GlobalEnums.PieceType.ROOK:
			return _get_sliding_moves(current_cell, board_data, [Vector2i(0, 1), Vector2i(0, -1), Vector2i(1, 0), Vector2i(-1, 0)])
		GlobalEnums.PieceType.QUEEN:
			return _get_sliding_moves(current_cell, board_data, [
				Vector2i(0, 1), Vector2i(0, -1), Vector2i(1, 0), Vector2i(-1, 0),
				Vector2i(1, 1), Vector2i(1, -1), Vector2i(-1, 1), Vector2i(-1, -1)
			])
		GlobalEnums.PieceType.KING:
			return _get_king_moves(current_cell, board_data)
	return []

func _get_knight_moves(current_cell: String, board_data: Dictionary) -> Array[String]:
	var moves: Array[String] = []
	var origin := GameState.board.cell_to_coords(current_cell)
	var offsets := [
		Vector2i(1, 2), Vector2i(2, 1), Vector2i(2, -1), Vector2i(1, -2),
		Vector2i(-1, -2), Vector2i(-2, -1), Vector2i(-2, 1), Vector2i(-1, 2)
	]
	for offset in offsets:
		var cell := GameState.board.coords_to_cell(origin + offset)
		if cell == "":
			continue
		if not board_data.has(cell) or not board_data[cell].is_occupied_by_player:
			moves.append(cell)
	return moves

func _get_king_moves(current_cell: String, board_data: Dictionary) -> Array[String]:
	var moves: Array[String] = []
	var origin := GameState.board.cell_to_coords(current_cell)
	for dx in range(-1, 2):
		for dy in range(-1, 2):
			if dx == 0 and dy == 0:
				continue
			var cell := GameState.board.coords_to_cell(origin + Vector2i(dx, dy))
			if cell == "":
				continue
			if not board_data.has(cell) or not board_data[cell].is_occupied_by_player:
				moves.append(cell)
	return moves

func _get_sliding_moves(current_cell: String, board_data: Dictionary, directions: Array[Vector2i]) -> Array[String]:
	var moves: Array[String] = []
	var origin := GameState.board.cell_to_coords(current_cell)
	for dir in directions:
		var pos: Vector2i = origin + dir
		while true:
			var cell := GameState.board.coords_to_cell(pos)
			if cell == "":
				break
			if board_data.has(cell):
				if not board_data[cell].is_occupied_by_player:
					moves.append(cell)
				break
			moves.append(cell)
			pos += dir
	return moves

func _get_pawn_moves(current_cell: String, board_data: Dictionary) -> Array[String]:
	var moves: Array[String] = []
	var origin := GameState.board.cell_to_coords(current_cell)
	var forward := Vector2i(0, 1) # adjust sign / add is_player check for direction

	var one_step := GameState.board.coords_to_cell(origin + forward)
	if one_step != "" and not board_data.has(one_step):
		moves.append(one_step)

		var two_step := GameState.board.coords_to_cell(origin + forward * 2)
		if origin.y == 1 and two_step != "" and not board_data.has(two_step):
			moves.append(two_step)

	for dx in [-1, 1]:
		var diag := GameState.board.coords_to_cell(origin + Vector2i(dx, 1))
		if diag != "" and board_data.has(diag) and not board_data[diag].is_occupied_by_player:
			moves.append(diag)

	return moves
