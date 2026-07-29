extends Node3D
class_name Piece

var current_cell: String
var piece_type: int
var move_tween: Tween
var is_elevated := false

func _ready() -> void:
	current_cell = GameState.board.get_nearest_tile(position)

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

func on_move_finished(_coord: String):
	# Implemented in subclasses
	pass

func handle_getting_captured():
	GameState.board.board_data.erase(current_cell)
	queue_free()