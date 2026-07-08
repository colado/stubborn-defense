class_name BoardData
extends RefCounted

var position: Vector3
var unit: PieceType.Value
var is_occupied_by_player: bool

func _init(p_unit: PieceType.Value, p_position: Vector3 = Vector3.ZERO, p_occupied: bool = false) -> void:
    unit = p_unit
    position = p_position
    is_occupied_by_player = p_occupied