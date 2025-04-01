extends Node2D

@onready var sprite: AnimatedSprite2D = $Sprite
@export var animation_player: AnimationPlayer = null

var spectrum

func play(animation):
	if animation_player != null and animation_player.has_animation(animation):
		animation_player.play(animation)
	sprite.play(animation)
