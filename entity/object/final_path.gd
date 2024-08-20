extends Path2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	animation_player.stop()
	Signals.entered_final.connect(_entered_final)
	Signals.kill.connect(_reset)

func _entered_final():
	animation_player.play()

func _reset():
	animation_player.stop()

func _process(delta: float) -> void:
	pass
