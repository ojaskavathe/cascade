extends Node2D

var confetti_preload = preload("res://entity/object/confetti_emitter.tscn")

@onready var debug_0: Node2D = $levels/Debug0
@onready var player: CharacterBody2D = $Player

var checkpoint_loc: Vector2
var current_scene

func _ready():
	Signals.kill.connect(_on_kill)
	Signals.new_checkpoint.connect(_new_checkpoint)
	
	checkpoint_loc = debug_0.get_node("Spawn").position
	player.position = checkpoint_loc
	player.jump_point_position = checkpoint_loc
	player.bash_state = true

func _on_kill():
	#get_tree().call_deferred("reload_current_scene")
	spawn_confetti(player.position)
	print("respawn: ", checkpoint_loc)
	player.position = checkpoint_loc
	player.jump_point_position = checkpoint_loc
	player.bash_state = true
	Signals.player_moved.emit(checkpoint_loc)

func spawn_confetti(pos):
	var confetti = confetti_preload.instantiate()
	confetti.set_position(pos)
	add_child.call_deferred(confetti)

func _new_checkpoint(loc, scene):
	print("new checkpoint: ", loc)
	checkpoint_loc = loc
	
	scene.get_node("BottomKillzone").get_node("KillZone").monitoring = true
