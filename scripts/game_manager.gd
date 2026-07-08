extends Node3D

@onready var board = $Board

var active_piece: Area3D

func _ready() -> void:
	board.piece_moving.connect(handle_piece_moving)
	
	for child in get_children():
		if child is PlayerPieceBase:
			child.piece_selected.connect(_on_piece_selected)

func _on_piece_selected(piece: Area3D) -> void:
	active_piece = piece

func handle_piece_moving(piece: PlayerPieceBase, to: Vector3, coord: String):
	for child in get_children():
		if child is PlayerPieceBase:
			if child.get_instance_id() == piece.get_instance_id():
				child.move_to(to, coord)
