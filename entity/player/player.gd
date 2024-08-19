extends CharacterBody2D

@export var SPEED = 10.0
@export var JUMP_VELOCITY = -2000.0
@export var END_VELOCITY = -6200.0
@export var GRAVITY = -1200.0
@export var DAMPENING = 2.0
@export var SLOWMO_SCALE = 0.1

var bash_state = false
var in_jump_point = false
var jump_point_position = Vector2.ZERO
var end_jump: bool = false

var move_direction = Vector2.UP
var model_rotation = 0.0

@onready var jump_point_detect: Area2D = $JumpPointDetect

@onready var dash_particles = $PlayerModel/DashParticles
@onready var swim_particles = $PlayerModel/SwimParticles

var arrow_preload: PackedScene = preload("res://entity/player/arrow.tscn")
var arrow

var controls_enabled = true
var can_bash = true

enum ParticleBehavior {SWIM = 0, DASH = 1}

func _ready():
	arrow = arrow_preload.instantiate()
	get_parent().add_child.call_deferred(arrow)
	arrow.set_visible(false)
	$PlayerModel/AnimationPlayer.play("swim")
	set_particle_behavior(ParticleBehavior.SWIM)
	Signals.player_moved.emit(position)

func _physics_process(delta):
	if velocity.is_zero_approx():
		$PlayerModel.set_rotation(model_rotation)
	else:
		model_rotation = velocity.angle() + deg_to_rad(90)
		$PlayerModel.set_rotation(model_rotation)
	
	if bash_state:
		var direction: Vector2 = jump_point_position - get_global_mouse_position()
		var angle: float = direction.angle() - deg_to_rad(90)
		
		arrow.set_rotation(0.0 if end_jump else angle)
		arrow.set_position(jump_point_position)
		arrow.set_visible(true)
		
		velocity = Vector2.ZERO
	
		if Input.is_action_just_released("jump"):
			$CollisionShape2D.set_disabled(true) # Enables invincibility
			set_particle_behavior(ParticleBehavior.DASH)
			$DashParticleTimer.start()
			position = jump_point_position
				
			move_direction = direction.normalized()
			if end_jump:
				move_direction = Vector2.DOWN
				controls_enabled = false
				can_bash = false
				Signals.player_exited_lg.emit()
			else:
				controls_enabled = true
			
			velocity = move_direction * (END_VELOCITY if end_jump else JUMP_VELOCITY)
			Signals.player_exited_bash_state.emit(end_jump)
			
			end_jump = false
			bash_state = false
			arrow.set_visible(false)
			can_bash = false
			Engine.time_scale = 1
			
			$MusicPlayer.set_pitch_scale(1)
			
			#var tween = get_tree().create_tween()
			#tween.tween_property($MusicPlayer, "pitch_scale", 1.0, 0.01).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT_IN)
			
			play_shoot_sound()
			
			$BashCooldownTimer.start()
	else:
		if not is_on_floor():
			if velocity.y < 0:
				velocity = velocity.lerp(Vector2.ZERO, DAMPENING * delta)
			velocity += GRAVITY * Vector2.UP * delta
			
		if controls_enabled:
			if Input.is_action_pressed("left"):
				velocity += Vector2.LEFT * SPEED
			if Input.is_action_pressed("right"):
				velocity += Vector2.RIGHT * SPEED
		
		if can_bash and in_jump_point and Input.is_action_pressed("jump"):
			bash_state = true
			set_particle_behavior(ParticleBehavior.SWIM)
			$DashParticleTimer.stop()
			Signals.player_entered_bash_state.emit()
			# this goes here instead of in bash state check cuz 
			# i don't want it to trigger on respawn
			Engine.time_scale = SLOWMO_SCALE
			$MusicPlayer.set_pitch_scale(0.75)
		
			#var tween = get_tree().create_tween()
			#tween.tween_property($MusicPlayer, "pitch_scale", 0.75, 0.01).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT_IN)
			
		
		move_and_slide()
		Signals.player_moved.emit(position)

func _on_jump_point_detect_area_entered(area):
	if (area.is_in_group("jump_point")):
		in_jump_point = true
		jump_point_position = area.get_global_position()
		if (area.is_in_group("spawn_point")):
			Signals.new_checkpoint.emit(jump_point_position, area.get_parent().get_parent())
		if (area.is_in_group("end_point")):
			end_jump = true


func _on_jump_point_detect_area_exited(area):
	if (area.is_in_group("jump_point")):
		in_jump_point = false
		end_jump = false
		if (area.is_in_group("spawn_point")):
			can_bash = true


func _on_dash_particle_timer_timeout():
	set_particle_behavior(ParticleBehavior.SWIM)


func set_particle_behavior(particle_behavior: ParticleBehavior):
	swim_particles.set_emitting(not particle_behavior)
	dash_particles.set_emitting(particle_behavior)


func _on_bash_cooldown_timer_timeout():
	can_bash = true
	$CollisionShape2D.set_disabled(false) # Disables invincibility

func play_death_sound():
	var f = randf_range(0.92, 1.08)
	$DeathSoundPlayer.set_pitch_scale(f)
	$DeathSoundPlayer.play()

func play_shoot_sound():
	var f = randf_range(0.92, 1.08)
	$ShootSoundPlayer.set_pitch_scale(f)
	$ShootSoundPlayer.play()
