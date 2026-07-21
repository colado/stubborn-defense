class_name Board
extends Node3D

const FILES := ["a", "b", "c", "d", "e", "f", "g", "h"]

var board_coordinates: Dictionary[String, Vector3] = {}
var board_positions_to_coordinates: Dictionary[Vector3, String] = {}
var board_data: Dictionary[String, BoardData] = {}

func cell_to_coords(cell: String) -> Vector2i:
	var file := cell.substr(0, 1)
	var rank := int(cell.substr(1, 1))
	return Vector2i(FILES.find(file), rank - 1)

func coords_to_cell(coords: Vector2i) -> String:
	if coords.x < 0 or coords.x > 7 or coords.y < 0 or coords.y > 7:
		return ""
	return "%s%d" % [FILES[coords.x], coords.y + 1]

func _ready() -> void:
	GameState.board = self
	populate_board_coordinates()

func update_board_data(from: String, to: String, piece: Node3D, is_player: bool):
	if board_data.has(from):
		board_data.erase(from)

	board_data[to] = BoardData.new(piece, board_coordinates[to], is_player)

func populate_board_coordinates() -> void:
	var start_x := -0.87
	var start_y := 0.28
	var start_z := 0.878
	var step := 0.25

	var letters := ["a", "b", "c", "d", "e", "f", "g", "h"]

	var x := start_x
	for row in range(letters.size()):   # file -> X
		var z := start_z
		for col in range(1, 9):         # rank -> Z (decreasing)
			var coord := "%s%d" % [letters[row], col]
			board_coordinates[coord] = Vector3(x, start_y, z)
			z -= step
		x += step

func get_nearest_tile(pos: Vector3, tolerance: float = 0.15) -> String:
	var closest_coord := ""
	var closest_dist := INF

	for coord in board_coordinates.keys():
		var cell_pos: Vector3 = board_coordinates[coord]
		var dist := Vector2(pos.x, pos.z).distance_to(Vector2(cell_pos.x, cell_pos.z))
		if dist < closest_dist:
			closest_dist = dist
			closest_coord = coord

	if closest_dist <= tolerance:
		return closest_coord
	return ""