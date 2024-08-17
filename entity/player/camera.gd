extends Camera2D

var camera_tween_start
var camera_tween_end

@export var shake_strength: float = 80.0
var rng = RandomNumberGenerator.new()

var player_in_bash_state = false

var tracking = Vector2(0, 0)
var tracking_flag = false

func _ready():
	Signals.player_moved.connect(_on_player_moved)
	Signals.player_entered_bash_state.connect(_on_player_entered_bash_state)
	Signals.player_exited_bash_state.connect(_on_player_exited_bash_state)

func _process(_delta):
	if tracking_flag:
		var transform_clamped = Transform2D(0, tracking)
		set_global_transform(transform_clamped)
		tracking_flag = false

func _on_player_moved(new_position):
	tracking = new_position
	tracking_flag = true

func _on_player_entered_bash_state():
	if is_instance_valid(camera_tween_end):
		camera_tween_end.kill()
	
	var tween = get_tree().create_tween()
	tween.tween_property(self, "zoom", Vector2(0.8, 0.8), 0.2).set_trans(Tween.TRANS_BOUNCE)
	camera_tween_start = tween
	
func _on_player_exited_bash_state():
	if is_instance_valid(camera_tween_start):
		camera_tween_start.kill()
	
	var tween = get_tree().create_tween().set_parallel()
	tween.tween_property(self, "zoom", Vector2(0.6, 0.6), 0.2).set_trans(Tween.TRANS_BOUNCE)
	#tween.tween_property(self, "offset", randomOffset(), 0.2).set_trans(Tween.TRANS_BOUNCE)
	tween.set_parallel(false)
	#tween.tween_property(self, "offset", Vector2(0, 0), 0.2).set_trans(Tween.TRANS_BOUNCE)
	camera_tween_end = tween

func randomOffset(n = 1) -> Vector2:
	return Vector2(rng.randf_range(-shake_strength/n, shake_strength/n), rng.randf_range(-shake_strength/n, shake_strength/n))
