extends Node2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var head: Node2D = $Head
var chore := 'idle'
var volume := 0

func _process(delta: float):
	$Label.text = animation_player.current_animation
	head.volume = volume


func play(a_chore):
	chore = a_chore
	$Label2.text = chore
	if animation_player.current_animation != a_chore:
		animation_player.clear_queue()
		animation_player.stop()
		animation_player.play(chore)
