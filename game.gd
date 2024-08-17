extends Node2D


func _ready():
	Signals.kill.connect(_on_kill)


func _on_kill():
	get_tree().reload_current_scene()
