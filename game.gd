extends Node2D

var confetti_preload = preload("res://entity/object/confetti_emitter.tscn")

@onready var first_level: Node2D = $LevelGroups/LG_0/levels/Debug0
@onready var player: CharacterBody2D = $Player

var checkpoint_loc: Vector2

func _ready():
	Signals.kill.connect(_on_kill)
	Signals.new_checkpoint.connect(_new_checkpoint)
	
	checkpoint_loc = first_level.get_node("SpawnJumpPoint").position
	
	player.position = checkpoint_loc
	player.jump_point_position = checkpoint_loc
	player.bash_state = true

func _on_kill():
	# get_tree().call_deferred("reload_current_scene")
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
