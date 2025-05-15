extends Node2D

var stereo := true
var mix_rate := 44100  # This is the default mix rate on recordings
var format := 1  # This equals to the default format: 16 bits
@onready var sprite: AnimatedSprite2D = $Sprite

var spectrum

var detected = 0.0
var chore = 'idle'

var shouted = false

func timer(seconds):
	return get_tree().create_timer(seconds).timeout


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if spectrum != null and spectrum.volume.visible:
		if spectrum.volume.value > 1000:
			#if sprite.animation != 'overhead':
				#sprite.play("overhead")
			shouted = true
			detected = 1.5
		elif detected > 0:
			detected -= delta
		if detected <= 0.0:
			detected = 0.0
			idle()

func idle():
	play("idle")

func play(a_chore):
	chore = a_chore
	if sprite.animation != a_chore:
		sprite.play(chore)
