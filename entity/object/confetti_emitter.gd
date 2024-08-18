extends Node2D

func _ready():
	$ConfettiParticles.set_emitting(true)

func _on_lifetime_timeout():
	queue_free()
