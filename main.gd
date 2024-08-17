extends Node2D

var loader_preload = preload("res://game/loader.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	var loader = loader_preload.instantiate()
	get_parent().add_child(loader)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
