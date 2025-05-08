extends  Node2D

var show_debug = true

var results_window = {}

func _ready() -> void:
	VoiceClassifier.voice_detected.connect(_on_voice_detected)

	#_on_voice_detected({'a': 0.2, 'b': 0.3})

func _on_voice_detected(results):
	var y = 10
	if show_debug:
		for child in get_children():
			remove_child(child)
			child.queue_free()
	for vlabel in results.keys():
		if vlabel not in results_window:
			results_window[vlabel] = []
		results_window[vlabel].append(results[vlabel])
		if len(results_window[vlabel]) > 5:
			results_window[vlabel].remove_at(0)
		if show_debug:
			var ind = preload("res://scenes/class_ind.tscn").instantiate()
			y += 50
			add_child(ind)
			ind.position = Vector2(10, y)
			ind.label.text = vlabel
			ind.progress.value = results_window[vlabel].max() * 1000
