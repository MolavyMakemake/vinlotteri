extends Node2D

@onready var resource_preloader = $ResourcePreloader
@onready var camera = $Camera2D

@export var n_fences: int = 10
@export var move_probability : Curve
@export var jump_probability : Curve
@export var tracks : Array

@export var track_layout: Array

@export var keys : Array = ["default", "mario"]

var n_competitors = 0
var contestants_v = []

var track_length = 0
var max_pos = 0

var rng = RandomNumberGenerator.new()
var is_waiting = true

func _ready() -> void:
	rng.randomize()
	print(rng.seed)
	
	
	track_length = 0
	for k in range(0, len(track_layout), 2):
		var fence_pos = 0
		if track_layout[k+1] > 0:
			fence_pos = track_layout[k] / track_layout[k+1]
			
			for i in range(0, track_layout[k], fence_pos):
				for y in tracks:
					var instance = resource_preloader.get_resource("fence").instantiate()
					add_child(instance)
					instance.position = Vector2(track_length + i, y)
				
		track_layout[k+1] = fence_pos
		track_length += track_layout[k]
	
	$track/finish.position.x = track_length
	
	n_competitors = min(8, len(keys))
	for i in range(n_competitors):
		var instance = resource_preloader.get_resource(keys[i]).instantiate()
		instance.position.y = tracks[i]
		add_child(instance)
		
		var contestant = Contestant.new()
		contestant.initiate(instance)
		contestants_v.push_back(contestant)

func is_fence(p: int):
	for i in range(0, len(track_layout), 2):
		if p < track_layout[i]:
			return track_layout[i+1] != 0 and p % track_layout[i+1] == 0
			
		p -= track_layout[i]
	
	return false

func _physics_process(delta: float) -> void:
	if is_waiting:
		return
	
	var mean_pos = 0.0
	var _pos_offset = 1 - 0.01 * max_pos
	for i in range(n_competitors):
		var con = contestants_v[i]
		var probability_weight = max(0, _pos_offset + 0.01 * con.position)
		var move = rng.randf() < move_probability.sample(probability_weight)
		
		if (is_fence(con.position)):
			con.jump(rng.randf() < jump_probability.sample(probability_weight))
			move = true
		
		con.tick(delta, move)
		if (con.active and con.position >= track_length):
			con.finish()
			print("Nr. ", i+1, " ", keys[i], " has finished!")
		
		mean_pos += con.position
		max_pos = max(con.position, max_pos)
		
	mean_pos /= n_competitors
	var target = mean_pos + 60 * (1 - 2.0 * mean_pos / track_length)
	camera.position.x += (target - camera.position.x) * delta
	
func _input(event):
	if is_waiting and event.is_action_pressed("begin"):
		is_waiting = false
		for con in contestants_v:
			con.ready()
