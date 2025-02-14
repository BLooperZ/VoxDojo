extends Node2D


const VU_COUNT = 1
const FREQ_MAX = 11050.0

const WIDTH = 800
const HEIGHT = 250
const HEIGHT_SCALE = 8.0
const MIN_DB = 60
const ANIMATION_SPEED = 0.1

var spectrum: AudioEffectSpectrumAnalyzerInstance
var effect: AudioEffectRecord = null
var min_values = []
var max_values = []
@onready var volume: TextureProgressBar = $TextureProgressBar

@export var bus_name: String = 'Record'
@export var spectrum_idx: int = 0
@export var record_idx: int = -1

func _draw():
	var w = WIDTH / VU_COUNT
	for i in range(VU_COUNT):
		var min_height = min_values[i]
		var max_height = max_values[i]
		var height = lerp(min_height, max_height, ANIMATION_SPEED)
		volume.value = height * 8


func hide_gauge():
	volume.visible = false

func show_gauge():
	volume.visible = true

func _process(_delta):
	
	if effect != null and not effect.is_recording_active():
		#volume.visible = false
		min_values.fill(0.0)
		max_values.fill(0.0)
		queue_redraw()
		return

	var data = []
	var prev_hz = 0

	#volume.visible = true

	for i in range(1, VU_COUNT + 1):
		var hz = i * FREQ_MAX / VU_COUNT
		#print(spectrum.get_magnitude_for_frequency_range(prev_hz, hz))
		var magnitude = spectrum.get_magnitude_for_frequency_range(prev_hz, hz).length()
		var energy = clampf((MIN_DB + linear_to_db(magnitude)) / MIN_DB, 0, 1)
		var height = energy * HEIGHT * HEIGHT_SCALE
		data.append(height)
		prev_hz = hz

	for i in range(VU_COUNT):
		if data[i] > max_values[i]:
			max_values[i] = data[i]
		else:
			max_values[i] = lerp(max_values[i], data[i], ANIMATION_SPEED)

		if data[i] <= 0.0:
			min_values[i] = lerp(min_values[i], 0.0, ANIMATION_SPEED)

	# Sound plays back continuously, so the graph needs to be updated every frame.
	queue_redraw()


func _ready():
	var idx = AudioServer.get_bus_index(bus_name)
	spectrum = AudioServer.get_bus_effect_instance(idx, spectrum_idx)
	if record_idx > 0:
		effect = AudioServer.get_bus_effect(idx, 0)
	#print(spectrum)
	min_values.resize(VU_COUNT)
	max_values.resize(VU_COUNT)
	min_values.fill(0.0)
	max_values.fill(0.0)
