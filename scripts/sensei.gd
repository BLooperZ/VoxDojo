extends Node2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var spectrum

func play(animation):
	animation_player.play(animation)
