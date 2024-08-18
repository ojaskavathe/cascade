extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	Signals.fix_particles.connect(_on_fix_particles)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _on_fix_particles(flag):
	if flag:
		$CPUParticles2D.set_speed_scale(10)
	else:
		$CPUParticles2D.set_speed_scale(1)
