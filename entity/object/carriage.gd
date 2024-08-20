extends Path2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var moving_jump_point: Node2D = $PathFollow2D/MovingJumpPoint

func _ready() -> void:
	animation_player.stop()
	Signals.kill.connect(_reset)

func _reset():
	animation_player.stop()
