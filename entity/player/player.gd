extends CharacterBody2D


@export var SPEED = 10.0
@export var JUMP_VELOCITY = -800.0
@export var GRAVITY = -1000.0
@export var DAMPENING = 2.0

var bash_state = false
var in_jump_point = false
var first_jump_in_level = true
var jump_point_position = Vector2.ZERO

var move_direction = Vector2.UP
var model_rotation = 0.0

@onready var jump_point_detect: Area2D = $JumpPointDetect

@onready var dash_particles = $PlayerModel/DashParticles
@onready var swim_particles = $PlayerModel/SwimParticles

var arrow_preload: PackedScene = preload("res://entity/player/arrow.tscn")
var arrow

var can_bash = true

enum ParticleBehavior {SWIM = 0, DASH = 1}

func _ready():
	arrow = arrow_preload.instantiate()
	get_parent().add_child.call_deferred(arrow)
	arrow.set_visible(false)
	$PlayerModel/AnimationPlayer.play("swim")
	set_particle_behavior(ParticleBehavior.SWIM)
	Signals.player_moved.emit(position)


func set_first_jump_in_level():
	first_jump_in_level = true
	arrow.set_visible(true)
	jump_point_position = position
	jump_point_position.y -= 32.0
	arrow.set_position(jump_point_position)


func _physics_process(delta):
	if velocity.is_zero_approx():
		$PlayerModel.set_rotation(model_rotation)
	else:
		model_rotation = velocity.angle() + deg_to_rad(90)
		$PlayerModel.set_rotation(model_rotation)
	
	if bash_state or first_jump_in_level:
		var direction = jump_point_position - get_global_mouse_position()
		var angle = direction.angle() - deg_to_rad(90)
		arrow.set_rotation(angle)
		
		if Input.is_action_just_released("jump"):
			first_jump_in_level = false
			set_particle_behavior(ParticleBehavior.DASH)
			$DashParticleTimer.start()
			position = jump_point_position
			move_direction = direction.normalized()
			velocity = move_direction * JUMP_VELOCITY
			bash_state = false
			arrow.set_visible(false)
			Signals.player_exited_bash_state.emit()
			can_bash = false
			$BashCooldownTimer.start()
	else:
		if not is_on_floor():
			if velocity.y < 0:
				velocity = velocity.lerp(Vector2.ZERO, DAMPENING * delta)
			velocity += GRAVITY * Vector2.UP * delta
			
		if Input.is_action_pressed("left"):
			velocity += Vector2.LEFT * SPEED
		if Input.is_action_pressed("right"):
			velocity += Vector2.RIGHT * SPEED
		
		if can_bash and in_jump_point and Input.is_action_pressed("jump"):
			bash_state = true
			arrow.set_position(jump_point_position)
			arrow.set_visible(true)
			set_particle_behavior(ParticleBehavior.SWIM)
			$DashParticleTimer.stop()
			Signals.player_entered_bash_state.emit()
			velocity = Vector2.ZERO
			
		move_and_slide()
		Signals.player_moved.emit(position)


func _on_jump_point_detect_area_entered(area):
	if (area.is_in_group("jump_point")):
		in_jump_point = true
		jump_point_position = area.get_global_position()


func _on_jump_point_detect_area_exited(area):
	if (area.is_in_group("jump_point")):
		in_jump_point = false


func _on_dash_particle_timer_timeout():
	set_particle_behavior(ParticleBehavior.SWIM)


func set_particle_behavior(particle_behavior: ParticleBehavior):
	swim_particles.set_emitting(not particle_behavior)
	dash_particles.set_emitting(particle_behavior)


func _on_bash_cooldown_timer_timeout():
	can_bash = true
