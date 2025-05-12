extends  Node2D

var show_debug = false

var results_window = {}
var retention = 1.0

func _ready() -> void:
	VoiceClassifier.voice_detected.connect(_on_voice_detected)


func reset():
	for label in results_window.keys():
		results_window[label] = 0.0
	#_on_voice_detected({'a': 0.2, 'b': 0.3})

func get_prob(vlabel):
	return results_window.get(vlabel, 0.0)
	#return results_window.get(vlabel, [0.0]).max()

func _process(delta: float) -> void:
	for label in results_window.keys():
		results_window[label] = max(0, results_window[label] - 0.2 * delta)
		if show_debug:
			for child in get_children():
				if child.label.text == label:
					child.progress.value = get_prob(label) * 1000
	queue_redraw()

func _on_voice_detected(results):
	var y = 10
	if show_debug:
		for child in get_children():
			remove_child(child)
			child.queue_free()
	for vlabel in results.keys():
		if vlabel not in results_window:
			results_window[vlabel] = 0
		results_window[vlabel] += retention * results[vlabel]
		#if len(results_window[vlabel]) > 5:
			#results_window[vlabel].remove_at(0)
		if show_debug:
			var ind = preload("res://scenes/class_ind.tscn").instantiate()
			y += 50
			add_child(ind)
			ind.position = Vector2(10, y)
			ind.label.text = vlabel
			ind.progress.value = get_prob(vlabel) * 1000
