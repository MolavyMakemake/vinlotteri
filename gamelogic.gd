extends Node2D
@onready var resource_preloader = $ResourcePreloader
@onready var camera = $Camera2D

@export var track_length: int = 400
@export var n_fences: int = 10
@export var move_probability : Curve
@export var tracks : Array

@export var keys : Array = ["default", "mario"]

var position_v = []
var competitor_v = []
var n_competitors = 0

var pos_fence = 0

func _ready() -> void:
	randomize()
	pos_fence = track_length / n_fences
	
	for i in range(n_fences):
		for y in tracks:
			var instance = resource_preloader.get_resource("fence").instantiate()
			add_child(instance)
			instance.position = Vector2(i * pos_fence, y)
	
	n_competitors = len(keys)
	for i in range(n_competitors):
		var instance = resource_preloader.get_resource(keys[i]).instantiate()
		add_child(instance)
		
		instance.position.y = tracks[i]
		instance.get_node("AnimationPlayer").play("run")
		
		competitor_v.push_back(instance)
		position_v.push_back(0)

func _physics_process(delta: float) -> void:
	
	var mean_pos = 0
	var max_pos = 0
	for i in range(n_competitors):
		var pos = position_v[i] + int(randf() < 0.5)
		
		if (pos % pos_fence == 0):
			print("fence!")
			
		if (pos >= track_length):
			print("finished")
		
		position_v[i] = pos
		competitor_v[i].position.x = pos
		
		mean_pos += pos
		max_pos = max(pos, max_pos)
		
	var d_pos = mean_pos / n_competitors - camera.position.x
	camera.position.x += d_pos * delta
	
