extends Node2D
@onready var resource_preloader = $ResourcePreloader
@onready var camera = $Camera2D

@export var track_length: int = 400
@export var n_fences: int = 10
@export var move_probability : Curve

var position_v = [0]
var competitor_v = []
var n_competitors = 1

var pos_fence = 0

func _ready() -> void:
	randomize()
	pos_fence = track_length / n_fences
	for i in range(n_fences):
		var instance = resource_preloader.get_resource("fence").instantiate()
		add_child(instance)
		instance.position.x = i * pos_fence
	
	var instance = resource_preloader.get_resource("default").instantiate()
	add_child(instance)
	instance.get_node("AnimationPlayer").play("run")
	competitor_v.push_back(instance)

func _physics_process(delta: float) -> void:
	
	var mean_pos = 0
	var max_pos = 0
	for i in range(n_competitors):
		var pos = position_v[i] + int(randf() < 0.5)
		
		if (pos % pos_fence == 0):
			print("fence!")
		
		position_v[i] = pos
		competitor_v[i].position.x = pos
		
		mean_pos += pos
		max_pos = max(pos, max_pos)
		
	var d_pos = mean_pos - camera.position.x
	camera.position.x += d_pos * delta
	
