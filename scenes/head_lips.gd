extends Node2D

@export var volume := 0.0

var initial_jaw: Vector2
var initial_upper: Vector2

var last_volume = 0

func _ready() -> void:
	initial_jaw = $Jaw.position
	initial_upper = $Upper.position

func _physics_process(delta: float) -> void:
	if volume > 600:
		volume *= 30
	if volume < 300:
		volume = 300
	var moment = 1 + last_volume + volume - 600
	$Jaw.position.y = initial_jaw.y + 2 * log(moment)
	$Upper.position.y = initial_upper.y - log(moment * 2) / 2

	last_volume = volume
