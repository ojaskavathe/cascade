extends Path2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var moving_jump_point: Node2D = $PathFollow2D/MovingJumpPoint

func _ready() -> void:
	animation_player.stop()
	Signals.player_entered_carriage.connect(_start_move)
	Signals.player_exited_carriage.connect(_stop_move)
	Signals.kill.connect(_reset)

func _start_move():
	animation_player.play()

func _stop_move():
	animation_player.pause()

func _reset():
	animation_player.stop()
