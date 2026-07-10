@tool
extends Node3D

var board_coordinates: Dictionary[String, Vector3] = {}
var board_data: Dictionary[String, BoardData] = {}

signal piece_moving(piece: PlayerPiece, to: Vector3, to_coord: String)

func _ready() -> void:
	for tile in get_children():
		if tile is Tile:
			tile.clicked.connect(_on_tile_clicked)

	populate_board_coordinates()

func _on_tile_clicked(_tile: Tile, coord: String) -> void:
	print(GameState.selected_piece)
	if GameState.selected_piece != null:
		update_board_data(GameState.selected_piece.current_board_tile, coord, GameState.selected_piece.piece_type, true)
		piece_moving.emit(GameState.selected_piece, board_coordinates[coord], coord)


func update_board_data(from: String, to: String, piece_type: PieceType.Value, is_player: bool):
	if board_data.has(from):
		board_data.erase(from)

	board_data[to] = BoardData.new(piece_type, board_coordinates[to], is_player)

func populate_board_coordinates() -> void:
	var start_x := -0.87
	var start_y := 0.28
	var start_z := 0.878
	var step := 0.25

	var letters := ["a", "b", "c", "d", "e", "f", "g", "h"]

	var z := start_z
	for row in range(letters.size()): # a, b, c, ... h
		var x := start_x
		for col in range(1, 9): # 1 to 8
			var coord := "%s%d" % [letters[row], col]
			board_coordinates[coord] = Vector3(x, start_y, z)
			x += step
		z -= step

	print(board_coordinates["b5"])
