extends Node3D

@export var en_pawn_to_deploy: PackedScene
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

func _init_enemy_piece(piece: EnemyPiece):
	GameState.board.update_board_data(piece.current_cell, piece.current_cell, piece, false)

func _on_all_pieces_done() -> void:
	GameState.update_turns_left()

func deploy_enemies():
	var cells_to_deploy := _get_random_deployment_cells()

	for cell in cells_to_deploy:
		var instance := en_pawn_to_deploy.instantiate()
		var selected_cell_coordinates := GameState.board.board_coordinates[cell]
		selected_cell_coordinates.y = 0.198 # Ideal en_pawn y coord, TODO: Store somewhere else
		instance.position = selected_cell_coordinates
		add_child(instance)
		_init_enemy_piece(instance)
	GameState.change_state(GameState.State.WAITING_FOR_PIECE_SELECTION)

func _get_random_deployment_cells() -> Array[String]:
	# TODO: Handle less cells to deploy than cells available in specified cells
	var cells_to_deploy: Array[String] = []

	for file in GameState.board.FILES:
		for rank in [7, 8]:
			var cell: String = file + str(rank)
			if (GameState.board.board_data.has(cell)):
				continue
			else:
				cells_to_deploy.append(file + str(rank))
	
	cells_to_deploy.shuffle()

	var pieces_to_deploy = min(GameState.current_set, cells_to_deploy.size())

	return cells_to_deploy.slice(0, pieces_to_deploy)
