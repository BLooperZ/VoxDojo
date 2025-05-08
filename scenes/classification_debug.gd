extends Node2D

@onready var label: Label = $Label
@onready var progress: TextureProgressBar = $TextureProgressBar
#
#
#func _ready() -> void:
	#VoiceClassifier.voice_detected.connect(_on_voice_detected)
#
#func _on_voice_detected(results):
	#for vlabel in results.keys():
		#if vlabel == label:
			#progress.value = results[label] * 1000
