extends Node2D

var started = false


func _on_button_pressed() -> void:
	if not started:
		started = true
		VoiceClassifier.start()
	else:
		started = false
		VoiceClassifier.stop()
