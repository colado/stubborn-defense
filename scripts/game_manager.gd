extends Node3D

@onready var board = $Board
@onready var red_pawn = $RedPawn
@onready var red_king = $RedKing

var active_piece: Area3D

func _ready() -> void:
	board.piece_moving.connect(handle_piece_moving)
	red_pawn.position = red_king.position

	
	for child in get_children():
		if child is PlayerPiece:
			child.piece_selected.connect(_on_piece_selected)

func _on_piece_selected(piece: Area3D) -> void:
	active_piece = piece

func handle_piece_moving(piece: PlayerPiece, to: Vector3, coord: String):
	for child in get_children():
		if child is PlayerPiece:
			if child.get_instance_id() == piece.get_instance_id():
				child.move_to(to, coord)
