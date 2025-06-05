extends Node2D

@onready var sprite: AnimatedSprite2D = $Sprite
@export var animation_player: AnimationPlayer = null
@onready var puppet = $Node2D2

var spectrum

func _process(_delta: float):
	if spectrum != null:
		$Node2D2.volume = spectrum.volume.value

func play(animation):
	puppet.play(animation)
	if animation_player != null and animation_player.has_animation(animation):
		animation_player.play(animation)
	sprite.play(animation)
