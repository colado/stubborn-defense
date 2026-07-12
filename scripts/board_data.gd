class_name BoardData
extends RefCounted

var position: Vector3
var piece: Node3D
var is_occupied_by_player: bool

func _init(p_piece: Node3D, p_position: Vector3 = Vector3.ZERO, p_occupied: bool = false) -> void:
    piece = p_piece
    position = p_position
    is_occupied_by_player = p_occupied