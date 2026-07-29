class_name Board
extends Node3D

const FILES := ["a", "b", "c", "d", "e", "f", "g", "h"]

enum TileElevationState {
	Off,
	Highlighted,
	Revealed,
	Elevated
}

signal tiles_turn_over()

@onready var template := $Tile_a1/Highlight
var board_coordinates: Dictionary[String, Vector3] = {}
var board_positions_to_coordinates: Dictionary[Vector3, String] = {}
var board_data: Dictionary[String, BoardData] = {}
var current_tile_elevation_state := TileElevationState.Off
var tiles: Array = []

@export var generate := false:
	set(value):
		if value:
			generate = false
			generate_highlights()

func _ready() -> void:
	GameState.board = self
	populate_board_coordinates()
	_assign_tile_elevation_types()
	GameState.state_changed.connect(_on_state_change)

func _on_state_change(_old_state: GameState.State, new_state: GameState.State) -> void:
	if (new_state == GameState.State.TILES_TURN):
		if current_tile_elevation_state == TileElevationState.Off or current_tile_elevation_state == TileElevationState.Elevated:
			tiles = get_random_tiles()
			for tile in tiles:
				tile.highlight_tile()
			current_tile_elevation_state = TileElevationState.Highlighted
		elif current_tile_elevation_state == TileElevationState.Highlighted:
			for tile in tiles:
				tile.reveal_highlight_type()
			current_tile_elevation_state = TileElevationState.Revealed
		elif current_tile_elevation_state == TileElevationState.Revealed:
			for tile in tiles:
				if GameState.board.board_data.has(tile.coord) and GameState.board.board_data[tile.coord].piece != null:
					tile.elevate()
				else: 
					tile.highlight_tile(false)
			current_tile_elevation_state = TileElevationState.Elevated

		tiles_turn_over.emit()


func get_random_tiles(count := 3) -> Array:
	var _tiles: Array = []
	for child in get_children():
		if child.name.begins_with("Tile"):
			_tiles.append(child)

	if _tiles.size() < count:
		push_warning("Only %d tiles available, requested %d" % [_tiles.size(), count])
		count = _tiles.size()

	_tiles.shuffle()
	return _tiles.slice(0, count)


func _assign_tile_elevation_types() -> void:
	var _tiles: Array = []
	for child in get_children():
		if child.name.begins_with("Tile"):
			_tiles.append(child)

	var values: Array[GlobalVars.TileElevationType] = []
	for i in range(8):
		values.append(GlobalVars.TileElevationType.Reveal)
	for i in range(28):
		values.append(GlobalVars.TileElevationType.Upgrade)
	for i in range(28):
		values.append(GlobalVars.TileElevationType.Downgrade)

	if _tiles.size() != values.size():
		push_warning("Tile count (%d) does not match value pool size (%d)" % [_tiles.size(), values.size()])

	values.shuffle()

	var count = min(_tiles.size(), values.size())
	for i in range(count):
		print(values[i])
		_tiles[i].set("elevation_type", values[i])

func generate_highlights():
	for child in get_children():
		if !child.name.begins_with("Tile_"):
			continue

		if child.has_node("Highlight"):
			child.get_node("Highlight").visible = false
			continue

		var highlight = template.duplicate()
		highlight.visible = false
		child.add_child(highlight)

func cell_to_coords(cell: String) -> Vector2i:
	var file := cell.substr(0, 1)
	var rank := int(cell.substr(1, 1))
	return Vector2i(FILES.find(file), rank - 1)

func coords_to_cell(coords: Vector2i) -> String:
	if coords.x < 0 or coords.x > 7 or coords.y < 0 or coords.y > 7:
		return ""
	return "%s%d" % [FILES[coords.x], coords.y + 1]

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
