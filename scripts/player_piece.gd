extends Node3D

var move_tween: Tween;

func _ready() -> void:
    # Called when the node enters the scene tree
    _initialize()

func move_to(target: Vector2, target_board_cell: String, duration: float = 0.2) -> void:
    if move_tween:
        move_tween.kill()

    move_tween = create_tween()

    move_tween.tween_property(self, "global_position", target, duration) \
        .set_trans(Tween.TransitionType.TRANS_SINE) \
        .set_ease(Tween.EaseType.EASE_OUT)

    move_tween.finished.connect(func():
        on_move_finished(target_board_cell)
    )