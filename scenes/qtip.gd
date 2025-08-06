extends Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var audio: AudioStreamPlayer2D = $AudioStreamPlayer2D
@export var intacts: Array[Texture2D] = []
@export var broken: Array[Texture2D] = []

var idx = 0
var init_pos

func _ready() -> void:
	init_pos = position
	reset()

func hit():
	#animation_player.play("break")
	texture = broken[idx]
	audio.play()
	animation_player.play('break')

func reset():
	idx = randi_range(1, len(intacts)) - 1
	$Sprite2D.visible = false
	$Sprite2D2.visible = false
	if idx == 2:
		#region_enabled = true
		scale = Vector2.ONE * 0.8
		position = init_pos
	else:
		scale = Vector2.ONE * 0.4
		#region_enabled = false
		if idx == 1:
			$Sprite2D.visible = true
			$Sprite2D2.visible = true
		position = init_pos + Vector2(10, -10)
		#idx = 2
	texture = intacts[idx]
	animation_player.play("default")
