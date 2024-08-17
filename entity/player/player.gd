extends CharacterBody2D


@export var SPEED = 10.0
@export var JUMP_VELOCITY = -800.0
@export var GRAVITY = -1000.0

var bash_state = false
var in_jump_point = false
var jump_point_position = Vector2.ZERO

var move_direction = Vector2.UP

@onready var jump_point_detect: Area2D = $JumpPointDetect

@onready var dash_particles = $PlayerModel/DashParticles
@onready var swim_particles = $PlayerModel/SwimParticles

var arrow_preload: PackedScene = preload("res://entity/player/arrow.tscn")
var arrow


func _ready():
	arrow = arrow_preload.instantiate()
	get_parent().add_child.call_deferred(arrow)
	arrow.set_visible(false)
	$PlayerModel/AnimationPlayer.play("swim")
	swim_particles.set_emitting(true)

func _physics_process(delta):
	if velocity.is_zero_approx():
		$PlayerModel.set_rotation(0.0)
	else:
		var model_rotation = velocity.angle() + deg_to_rad(90)
		$PlayerModel.set_rotation(model_rotation)
	
	if bash_state:
		var direction = jump_point_position - get_global_mouse_position()
		var angle = direction.angle() - deg_to_rad(90)
		arrow.set_rotation(angle)
		
		if Input.is_action_just_released("jump"):
			swim_particles.set_emitting(false)
			dash_particles.set_emitting(true)
			$DashParticleTimer.start()
			position = jump_point_position
			move_direction = direction.normalized()
			velocity = move_direction * JUMP_VELOCITY
			bash_state = false
			arrow.set_visible(false)
			Signals.player_exited_bash_state.emit()
	else:
		if not is_on_floor():
			velocity += GRAVITY * Vector2.UP * delta
			
		if Input.is_action_pressed("left"):
			velocity += Vector2.LEFT * SPEED
		if Input.is_action_pressed("right"):
			velocity += Vector2.RIGHT * SPEED
		
		if in_jump_point and Input.is_action_pressed("jump"):
			bash_state = true
			arrow.set_position(jump_point_position)
			arrow.set_visible(true)
			Signals.player_entered_bash_state.emit()
			velocity = Vector2.ZERO
			
		move_and_slide()
		Signals.player_moved.emit(position)


func _on_jump_point_detect_area_entered(area):
	if (area.is_in_group("jump_point")):
		in_jump_point = true
		jump_point_position = area.get_position()


func _on_jump_point_detect_area_exited(area):
	if (area.is_in_group("jump_point")):
		in_jump_point = false


func _on_dash_particle_timer_timeout():
	swim_particles.set_emitting(true)
	dash_particles.set_emitting(false)
