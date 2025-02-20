extends Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var audio: AudioStreamPlayer2D = $AudioStreamPlayer2D
@export var intacts: Array[Texture2D] = []
@export var broken: Array[Texture2D] = []

var idx = 0


func _ready() -> void:
	reset()

func hit():
	#animation_player.play("break")
	texture = broken[idx]
	audio.play()

func reset():
	idx = randi_range(1, len(intacts)) - 1
	texture = intacts[idx]
	#animation_player.play("default")
