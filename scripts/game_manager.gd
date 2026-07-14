extends Node3D

@onready var board = $Board
@onready var enemy_controller = $EnemyController

@export var pawn_to_deploy: PackedScene
var active_piece: Area3D
var allowed_moves: Array[String]

func _ready() -> void:
	for child in get_children():
		if child is PlayerPiece:
			_init_player_piece(child)
	for child in board.get_children():
		if child is Tile:
			child.clicked.connect(_on_tile_selected)
	
	GameState.state_changed.connect(_on_state_changed)

func _on_state_changed(_old_state: GameState.State, new_state: GameState.State):
	if new_state == GameState.State.DEPLOYING_ENEMIES:
		enemy_controller.deploy_enemies()

func _init_player_piece(player_piece: PlayerPiece):
	player_piece.piece_selected.connect(_on_piece_selected)
	player_piece.player_piece_finished_move.connect(_on_player_piece_finished_move)
	board.update_board_data(player_piece.current_cell, player_piece.current_cell, player_piece, true)

func _on_player_piece_finished_move():
	if enemy_controller.get_children().size() == 0:  # Will need to be refactored in the future, since capture animations could take longer and this could return false
		GameState.change_state(GameState.State.BETWEEN_SETS)
		GameState.change_set()
	else:
		GameState.change_state(GameState.State.ENEMY_TURN)

func _on_tile_selected(_tile: Tile, coord: String):
	if GameState.current_state == GameState.State.WAITING_FOR_TILE_SELECTION:
		_handle_tile_piece_target(coord)
	elif GameState.current_state == GameState.State.INITIAL_DEPLOY or GameState.current_state == GameState.State.BETWEEN_SETS:
		_handle_player_pawn_deploy(coord)

func _handle_tile_piece_target(coord):
	if allowed_moves.has(coord):
		if board.board_data.has(coord) and not board.board_data[coord].is_occupied_by_player:
			board.board_data[coord].piece.handle_getting_captured()

		board.update_board_data(active_piece.current_cell, coord, active_piece, true)
		active_piece.move_to(board.board_coordinates[coord], coord)
		active_piece = null
		allowed_moves = []
		GameState.change_state(GameState.State.PLAYER_PIECE_MOVING)

func _handle_player_pawn_deploy(coord):
	if coord[1] != "1" and coord[1] != "2":
		print("The row must be 1 or 2")
		return
	
	if GameState.points <= 0:
		print("Not enough points")
		return
	
	if board.board_data.has(coord):
		print("Cell is occupied")
		return

	var instance := pawn_to_deploy.instantiate()
	var selected_cell_coordinates := GameState.board.board_coordinates[coord]
	selected_cell_coordinates.y = 0.227 # Ideal pawn y coord, TODO: Store somewhere else
	instance.position = selected_cell_coordinates
	add_child(instance)
	_init_player_piece(instance)
	GameState.edit_points(-1)

func _on_piece_selected(piece: Area3D) -> void:
	if GameState.current_state == GameState.State.WAITING_FOR_PIECE_SELECTION:
		active_piece = piece
		allowed_moves = get_allowed_moves(piece.piece_type, piece.current_cell, board.board_data)
		GameState.change_state(GameState.State.WAITING_FOR_TILE_SELECTION)

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
		var diagonal := GameState.board.coords_to_cell(origin + Vector2i(dx, 1))
		if diagonal != "" and board_data.has(diagonal) and not board_data[diagonal].is_occupied_by_player:
			moves.append(diagonal)

	return moves
