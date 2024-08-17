extends CharacterBody2D


@export var SPEED = 300.0
@export var JUMP_VELOCITY = -800.0
@export var GRAVITY = -1000.0

var bash_state = false
var in_jump_point = false

var move_direction = Vector2.UP

@onready var jump_point_detect: Area2D = $JumpPointDetect


func _ready():
	$PlayerModel/AnimationPlayer.play("swim")


func _physics_process(delta):
	var direction = get_global_transform().origin - get_global_mouse_position()
	var angle = direction.angle() - deg_to_rad(90)
	$Polygon2D2.set_rotation(angle)
	$PlayerModel.set_rotation(angle)
	move_direction = direction.normalized()
	
	if bash_state:
		if Input.is_action_just_released("jump"):
			velocity = move_direction * JUMP_VELOCITY
			bash_state = false
			Signals.player_exited_bash_state.emit()
	else:
		if not is_on_floor():
			velocity += GRAVITY * Vector2.UP * delta
		
		if in_jump_point and Input.is_action_pressed("jump"):
			bash_state = true
			Signals.player_entered_bash_state.emit()
			velocity = Vector2.ZERO
			
		move_and_slide()
		Signals.player_moved.emit(position)


func _on_jump_point_detect_area_entered(area):
	if (area.is_in_group("jump_point")):
		in_jump_point = true


func _on_jump_point_detect_area_exited(area):
	if (area.is_in_group("jump_point")):
		in_jump_point = false
