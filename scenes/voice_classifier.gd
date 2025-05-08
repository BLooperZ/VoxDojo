extends Button

# Create a callback function and pass it to JavaScript
var _callback = JavaScriptBridge.create_callback(_on_results_received)

var started = false
var recognizer = null

signal voice_detected(results)


func _ready() -> void:
	var window = JavaScriptBridge.get_interface("window")
	if window == null:
		print("JavaScriptBridge is not available.")
		return
	# Set the `window.onbeforeunload` DOM event listener.
	window.godotCallback = _callback

	window.createModel()


func initialize() -> void:
	if recognizer != null:
		# Already initialized
		return

	# Ensure JavaScriptBridge is available
	if not JavaScriptBridge:
		print("JavaScriptBridge is not available.")
		return

	recognizer = JavaScriptBridge.get_interface("speechModel")
	# Call the `start` function defined in the JavaScript context
	if recognizer:
		print("Recognizer initialize")
	else:
		print("Recognizer is not available.")


func start() -> void:
	if recognizer == null:
		initialize()
		if recognizer == null:
			print("Recognizer is not available")
			return
	print("Start recognizing")
	recognizer.start()

func stop() -> void:
	if recognizer == null:
		print("Recognizer is not available")
		return
	print("Stop recognizing")
	recognizer.stop()

func get_labels():
	var labels = JavaScriptBridge.eval("JSON.stringify(Object.keys(window.classLabels));")
	print(labels)
	return labels

func _on_results_received(args):
	var json_results = args[0]

	# Call the `window.console.log()` method.
	print("Results received from JavaScript: " + str(json_results))

	# Parse the JSON string into a Godot Dictionary
	var results = JSON.parse_string(json_results)
	voice_detected.emit(results)
	for label in results.keys():
		print("Label: %s, Score: %.2f" % [label, results[label]])
