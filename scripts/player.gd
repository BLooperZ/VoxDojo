extends Node2D

var effect: AudioEffectRecord  # See AudioEffect in docs

var stereo := true
var mix_rate := 44100  # This is the default mix rate on recordings
var format := 1  # This equals to the default format: 16 bits
@onready var sprite: AnimatedSprite2D = $Sprite

var spectrum

var detected = 0.0
var chore = 'idle'

var shouted = false

func timer(seconds):
	return get_tree().create_timer(seconds).timeout

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var idx = AudioServer.get_bus_index("Record")
	effect = AudioServer.get_bus_effect(idx, 0)

func get_rms_volume(buffer):
	var sum = 0.0
	for sample in buffer:
		var sam = sample - 128
		sum += 2 * abs(sam)
	return sum / (buffer.size() * 256)

# Preprocess the signal to normalize it
func preprocess_signal(buffer):
	var normalized_buffer = []
	for value in buffer:
		normalized_buffer.append(2 * value / 255 - 1)
	return normalized_buffer

# Calculate the Zero-Crossing Rate (ZCR)
func calculate_zcr(buffer):
	var zcr = 0.0
	for i in range(1, buffer.size()):
		if (buffer[i] * buffer[i - 1] < 0):
			zcr += 1
	return zcr / buffer.size()

# Calculate the Short-Time Energy (STE)
func calculate_ste(buffer):
	var energy = 0.0
	for value in buffer:
		energy += pow(value, 2)
	return energy / buffer.size()

func classify_audio(buffer):
	var threshold_ste = 0.7 # Example threshold for STE (tune this value based on your data)
	var threshold_zcr = 0.06
	
	var normalized_buffer = preprocess_signal(buffer)
	var zcr = calculate_zcr(normalized_buffer)
	var ste = calculate_ste(normalized_buffer)

	var is_speech = ste > threshold_ste and zcr > threshold_zcr
	return is_speech

func get_recording():
	return null
	#var recording = effect.get_recording()
	#if recording == null:
		#return null
	#recording.set_mix_rate(mix_rate)
	#recording.set_format(format)
	#recording.set_stereo(stereo)
	#return recording

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if spectrum != null and spectrum.volume.visible:
		if spectrum.volume.value > 1000:
			if sprite.animation != 'overhead':
				sprite.play("overhead")
			shouted = true
			detected = 1.5
		elif detected > 0:
			detected -= delta
		if detected <= 0.0:
			detected = 0.0
			idle()

func idle():
	play("idle")

func play(a_chore):
	chore = a_chore
	sprite.play(chore)
