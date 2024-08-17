extends Node2D

var stack_height = 0
var unit_height = -720.0
var loaded_levels := []
var level_groups := []

var base_preload = preload("res://game/base.tscn")
var player_preload = preload("res://entity/player/player.tscn")
var camera_preload = preload("res://entity/player/camera.tscn")
var bottom_kill_zone_preload = preload("res://entity/object/bottom_kill_zone.tscn")
var filler = preload("res://level/filler.tscn")

@onready var permanent := $Permanent
@onready var ephemeral := $Ephemeral

var kill_zone
var player
var camera

func _ready():
	Signals.kill.connect(_on_kill)
	init()

func _on_kill():
	loaded_levels.clear()
	
	for child in ephemeral.get_children():
		child.queue_free()
	
	stack_height = 0
	
	var level_groups_copy = level_groups.duplicate()
	level_groups.clear()
	
	for level_group in level_groups_copy:
		load_next_level_group(level_group)
	
	loaded_levels[0].set_process_mode(ProcessMode.PROCESS_MODE_INHERIT)
	
	setup_player()

func init():
	var base = base_preload.instantiate()
	permanent.add_child(base)
	
	kill_zone = bottom_kill_zone_preload.instantiate()
	permanent.add_child(kill_zone)
	
	load_next_level_group([
		"res://level/debug_1.tscn"
	])
	
	loaded_levels[0].set_process_mode(ProcessMode.PROCESS_MODE_INHERIT)
	
	load_next_level_group([
		"res://level/debug_2.tscn"
	])
	
	camera = camera_preload.instantiate()
	camera.set_position(Vector2(640, -400))
	permanent.add_child.call_deferred(camera)
	
	setup_player()

func setup_player():
	var spawn_pos = Vector2(640, -400)
	player = player_preload.instantiate()
	player.set_position(spawn_pos)
	ephemeral.add_child.call_deferred(player)
	await player.ready
	
	player.set_first_jump_in_level()
	camera.tracking = spawn_pos
	camera.tracking_flag = true
	camera._on_player_entered_bash_state()


func load_next_level_group(level_group):
	level_groups.append(level_group)
	
	for level_to_load in level_group:
		var loaded_level = load(level_to_load)
		load_next_level(loaded_level)
		
	load_next_level(filler)


func load_next_level(loaded_level):
	var loaded_level_instance = loaded_level.instantiate()
	stack_height += 1
	var total_height = unit_height * stack_height
	loaded_level_instance.set_position(Vector2(0, total_height))
	loaded_level_instance.set_process_mode(ProcessMode.PROCESS_MODE_DISABLED)
	ephemeral.add_child(loaded_level_instance)
	loaded_levels.append(loaded_level_instance)
	
	
