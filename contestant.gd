class_name Contestant
	
var instance: Node2D
var animation: AnimationPlayer

var position: int = 0
var timeout: float = -1

var active: bool = false

func initiate(_instance: Node2D):
	instance = _instance
	animation = _instance.get_node("AnimationPlayer")
	animation.play("prepare")

	position = 0
	timeout = -1

func ready():
	active = true
	animation.play("run")

func jump(_success: bool):
	if false and _success:
		animation.play("jump")
	else:
		timeout = 1
		position += 1
		animation.play("fall")
		
	animation.queue("run")
	
func tick(_delta: float, _move: bool):
	timeout -= _delta
	
	if active:
		position += int(timeout <= 0 and _move)
		instance.position.x = position

func finish():
	active = false
	animation.play("finish")
