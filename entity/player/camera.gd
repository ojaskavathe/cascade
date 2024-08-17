extends Camera2D

var camera_tween_start
var camera_tween_end

@export var randomStrength: float = 24.0
@export var shakeFade: float = 20.0

var rng = RandomNumberGenerator.new()
var shake_strength: float = 0.0
var player_in_bash_state = false

var tracking = Vector2(0, 0)
var tracking_flag = false

func _ready():
	Signals.player_moved.connect(_on_player_moved)
	Signals.player_entered_bash_state.connect(_on_player_entered_bash_state)
	Signals.player_exited_bash_state.connect(_on_player_exited_bash_state)

func _process(delta):
	if tracking_flag:
		var transform_clamped = Transform2D(0, tracking)
		set_global_transform(transform_clamped)
		tracking_flag = false
	
	if shake_strength > 0:
		shake_strength = lerpf(shake_strength, 0.0, shakeFade * delta)
		offset = randomOffset()
	
	position_smoothing_speed = lerpf(position_smoothing_speed, 4.0, 0.5 * delta)

func _on_player_moved(new_position):
	tracking = new_position
	tracking_flag = true

func _on_player_entered_bash_state():
	if is_instance_valid(camera_tween_end):
		camera_tween_end.kill()
	
	var tween = get_tree().create_tween()
	tween.tween_property(self, "zoom", Vector2(1.0, 1.0), 0.2).set_trans(Tween.TRANS_SINE)
	camera_tween_start = tween
	
func _on_player_exited_bash_state():
	if is_instance_valid(camera_tween_start):
		camera_tween_start.kill()
	
	var tween = get_tree().create_tween()
	tween.tween_property(self, "zoom", Vector2(0.75, 0.75), 0.2).set_trans(Tween.TRANS_SINE)
	camera_tween_end = tween
	
	position_smoothing_speed = 0
	
	apply_shake()

func apply_shake():
	shake_strength = randomStrength
	
func randomOffset(n = 1) -> Vector2:
	return Vector2(rng.randf_range(-shake_strength/n, shake_strength/n), rng.randf_range(-shake_strength/n, shake_strength/n))
