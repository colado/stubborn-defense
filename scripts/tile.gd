class_name Tile
extends Area3D

signal clicked(tile: Tile, coord: String)

enum TileColor {
	BLACK,
	RED
}

@export var coord: String = ""
@export var tile_color: TileColor = TileColor.BLACK:
	set(value):
		tile_color = value
		if is_inside_tree():
			update_mesh()

@onready var highlight = $Highlight

var elevation_type: GlobalVars.TileElevationType
var red_mesh := preload("res://assets/red_cube.tres")
var black_mesh := preload("res://assets/black_cube.tres")

func _ready():
	input_ray_pickable = true
	monitoring = false
	monitorable = false
	update_mesh()
	highlight.visible = false

func _input_event(_camera: Camera3D, event: InputEvent, _position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if GameState.current_state == GameState.State.INITIAL_DEPLOY or GameState.current_state == GameState.State.WAITING_FOR_TILE_SELECTION or GameState.current_state == GameState.State.BETWEEN_SETS:
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			clicked.emit(self, coord)

func update_mesh():
	var mesh_instance := $Cube

	if tile_color == TileColor.RED:
		mesh_instance.mesh = red_mesh
	else:
		mesh_instance.mesh = black_mesh

func elevate():
	highlight.visible = false
	for child in get_children():
		child.position.y += 0.125
	if GameState.board.board_data.has(coord):
		GameState.board.board_data[coord].is_elevated = true
	else:
		GameState.board.board_data[coord] = BoardData.new(null, Vector3.ZERO, false, true)

func highlight_tile(state = true):
	highlight.visible = state

func reveal_highlight_type():
	var material := StandardMaterial3D.new()
	if elevation_type == GlobalVars.TileElevationType.Reveal:
		material.albedo_color = Color.BLUE
		highlight.material_override = material
	elif elevation_type == GlobalVars.TileElevationType.Upgrade:
		material.albedo_color = Color.GREEN
		highlight.material_override = material
	elif elevation_type == GlobalVars.TileElevationType.Downgrade:
		material.albedo_color = Color.YELLOW
		highlight.material_override = material
