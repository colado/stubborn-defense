class_name Tile
extends Area3D

signal clicked(tile: Tile, coord: String)

@export var coord: String = ""

func _ready() -> void:
	input_ray_pickable = true
	monitoring = false
	monitorable = false

func _input_event(_camera: Camera3D, event: InputEvent, _position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if GameState.State.WAITING_FOR_TILE_SELECTION and event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		clicked.emit(self, coord)
