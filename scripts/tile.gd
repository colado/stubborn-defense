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

var red_mesh = preload("res://assets/red_cube.tres")
var black_mesh = preload("res://assets/black_cube.tres")


func _ready():
	input_ray_pickable = true
	monitoring = false
	monitorable = false
	update_mesh()

func _input_event(_camera: Camera3D, event: InputEvent, _position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if GameState.current_state == GameState.State.INITIAL_DEPLOY or GameState.current_state == GameState.State.WAITING_FOR_TILE_SELECTION or GameState.current_state == GameState.State.BETWEEN_SETS:
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			clicked.emit(self, coord)

func update_mesh():
	var mesh_instance = $Cube

	if tile_color == TileColor.RED:
		mesh_instance.mesh = red_mesh
	else:
		mesh_instance.mesh = black_mesh