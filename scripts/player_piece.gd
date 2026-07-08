extends Area3D
class_name PlayerPieceBase

var move_tween: Tween;

signal piece_selected(int)

func _ready() -> void:
    pass

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

func on_move_finished(target_board_cell: String):
    # update board and main
    # 	board.MovePiece(currentBoardCell, targetBoardCell, unit, true);
    # currentBoardCell = targetBoardCell;
    # if (this is Pawn) CanPromote();
    # main.UseMoves(1);
    # EmitSignal(SignalName.PlayerMoved);
    # if (main.MovesLeft == 0)
    # {
    # 	main.ResetMoves();
    # }
    pass

func _input_event(camera, event, position, normal, shape_idx) -> void:
    if (event is InputEventMouseButton or event is InputEventScreenTouch) and event.pressed:
        print("reached ", get_instance_id())
        piece_selected.emit(self)