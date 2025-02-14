extends Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var audio: AudioStreamPlayer2D = $AudioStreamPlayer2D


func hit():
	animation_player.play("break")
	audio.play()

func reset():
	animation_player.play("default")
