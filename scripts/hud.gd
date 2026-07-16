extends CanvasLayer

@onready var pawn_deployment_control := $PawnDeploymentControl
@onready var in_game_control := $InGameControl
@onready var promotion_control := $PromotionControl
@onready var upgrades_control := $UpgradesControl
@onready var turns_left_label := $InGameControl/VBoxContainer/TurnsLeftLabel
@onready var moves_left_label := $InGameControl/VBoxContainer/MovesLeftLabel

func _ready() -> void:
	GameState.state_changed.connect(_on_state_changed)
	GameState.turns_left_changed.connect(_on_turns_left_changed)
	GameState.moves_left_changed.connect(_on_moves_left_changed)
	in_game_control.visible = false
	promotion_control.visible = false
	upgrades_control.visible = false
	turns_left_label.text = "Turns left: %s" % GameState.turns_left
	moves_left_label.text = "Moves left: %s" % GameState.moves_left

func _on_start_button_pressed() -> void:
	GameState.change_state(GameState.State.DEPLOYING_ENEMIES)

func _on_state_changed(_old_state: GameState.State, new_state: GameState.State):
	pawn_deployment_control.visible = new_state == GameState.State.INITIAL_DEPLOY or new_state == GameState.State.BETWEEN_SETS
	in_game_control.visible = new_state == GameState.State.WAITING_FOR_PIECE_SELECTION or new_state == GameState.State.WAITING_FOR_TILE_SELECTION or new_state == GameState.State.PLAYER_PIECE_MOVING or new_state == GameState.State.ENEMY_TURN
	promotion_control.visible = new_state == GameState.State.PROMOTING_PAWN
	upgrades_control.visible = new_state == GameState.State.UPGRADE_SELECTION

func _on_turns_left_changed(turns_left: int):
	turns_left_label.text = "Turns left: %s" % turns_left

func _on_moves_left_changed(moves_left: int):
	moves_left_label.text = "Moves left: %s" % moves_left