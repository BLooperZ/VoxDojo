extends Node2D

var effect: AudioEffectRecord
var stereo := false
var mix_rate := 44100
var format := 1

# Reference to the TextureProgressBar
@onready var progress_bar = $TextureProgressBar

func _ready() -> void:
	var idx = AudioServer.get_bus_index("Record")
	effect = AudioServer.get_bus_effect(idx, 0)
	effect.set_recording_active(true)
	print("START")

func _physics_process(delta):
	var recording = get_recording()
	if recording != null:
		var volume = calculate_volume(recording, 1)
		update_progress_bar(volume)

func get_recording():
	var recording = effect.get_recording()
	if recording == null:
		return null
	recording.set_mix_rate(mix_rate)
	recording.set_format(format)
	recording.set_stereo(stereo)
	return recording

func calculate_volume(audio_stream, window_size):
	var buffer = audio_stream.get_data()
	buffer = buffer.slice(-mix_rate * window_size)
	print(buffer)
	if buffer.size() == 0:
		return 0
	var sum = 0.0
	for i in range(buffer.size()):
		var v = buffer[i] - 128
		sum += v * v
	var rms = sqrt(sum / buffer.size())
	print("RMS Volume: ", rms)  # Add this line
	return rms

func update_progress_bar(volume):
	# Map the volume to the progress bar range (0 to 100)
	progress_bar.value = volume * 10
