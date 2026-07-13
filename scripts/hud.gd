extends CanvasLayer

@onready var start_button := $StartButton

func _ready() -> void:
	GameState.state_changed.connect(_on_state_changed)

func _on_start_button_pressed() -> void:
	GameState.change_state(GameState.State.WAITING_FOR_PIECE_SELECTION)

func _on_state_changed(_old_state: GameState.State, new_state: GameState.State):
	if new_state != GameState.State.INITIAL_DEPLOY:
		start_button.visible = false