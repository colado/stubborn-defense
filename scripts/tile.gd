class_name Tile
extends Area3D

signal clicked(tile: Tile, coord: String)

@export var coord: String = ""

func _ready() -> void:
    input_ray_pickable = true
    monitoring = false
    monitorable = false

func _input_event(camera: Camera3D, event: InputEvent, position: Vector3, normal: Vector3, shape_idx: int) -> void:
    if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
        clicked.emit(self, coord)