extends Area3D
class_name PlayerPiece

var move_tween: Tween;
var current_board_tile: String
var piece_type: int

signal piece_selected(piece: Area3D)

func _ready() -> void:
	current_board_tile = GameState.board.get_nearest_tile(global_position)
	print(piece_type, " ", position, " ", current_board_tile)

func move_to(target: Vector3, target_board_tile: String, duration: float = 0.2) -> void:
	# Make sure vertical position is not changed
	var normalized_target_location = Vector3(target.x, position.y, target.z)
	if move_tween:
		move_tween.kill()

	move_tween = create_tween()

	move_tween.tween_property(self, "global_position", normalized_target_location, duration) \
		.set_trans(Tween.TransitionType.TRANS_SINE) \
		.set_ease(Tween.EaseType.EASE_OUT)

	move_tween.finished.connect(func():
		on_move_finished(target_board_tile)
	)

func on_move_finished(coord: String):
	current_board_tile = coord

func _input_event(_camera, event, _position, _normal, _shape_idx) -> void:
	if (event is InputEventMouseButton or event is InputEventScreenTouch) and event.pressed:
		piece_selected.emit(self)
