extends Node2D

var loader_preload = preload("res://game/loader.tscn")

func _ready():
	var loader = loader_preload.instantiate()
	get_parent().add_child.call_deferred(loader)
	await loader.ready
	queue_free()
