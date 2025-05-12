extends Node2D

@onready var gauges := $HBoxContainer
@export var gauge_scene: PackedScene

var effect: AudioEffectRecord  # See AudioEffect in docs
var recording: AudioStream  # See AudioStreamSample in docs

var stereo := true
var mix_rate := 44100  # This is the default mix rate on recordings
var format := 1  # This equals to the default format: 16 bits

@onready var player = $AudioStreamPlayer
@onready var sensei: Node2D = $Sensei
@onready var recorder: AudioStreamPlayer = $AudioStreamRecord
@onready var sensei_player: AudioStreamPlayer = $Sensei/AudioStreamPlayer3
@onready var player2: AudioStreamPlayer = $AudioStreamPlayer2

@onready var spectrum_player: Node2D = $Student/Spectrum
@onready var spectrum_sensei: Node2D = $Sensei/Spectrum

@onready var player_projector: Sprite2D = $Projector2
@onready var sensei_projector: Sprite2D = $Projector
@onready var qtip_player: Sprite2D = $Qtip2
@onready var qtip_sensei: Sprite2D = $Qtip
@onready var now_you: Control = $NowYou
@onready var just_listen: Control = $JustListen
@onready var classifications := $Indicators


var SENSEI_COLOR = Color.RED
var NEUTRAL_COLOR = Color.ORANGE
var PLAYER_COLOR = Color.html('#09C6FA')

var index = 0


const MAX_MOVES = 3
const MIN_MOVES = 1

@export var dems: Array[FightMove]
@onready var student: Node2D = $Student
@export var intro: AudioStream
@export var cue: AudioStream

const SENSEI_VOLUME_SCALE = 8

signal player_made_correct_move

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Dark.hide()
	$Dark2.hide()
	spectrum_player.hide_gauge()
	spectrum_sensei.hide_gauge()
	player_projector.hide()
	sensei_projector.hide()
	student.spectrum = spectrum_player
	sensei.spectrum = spectrum_sensei
	now_you.hide()
	just_listen.hide()
	call_deferred("main_loop")
	var idx = AudioServer.get_bus_index("Record")
	effect = AudioServer.get_bus_effect(idx, 0)
	dems.append_array(dems)

	VoiceClassifier.initialize()

var num_attempts = 3
var player_did = false
var player_active = false
var current_label = null

func main_loop():
	await main_loop_inner()
	var game_scene = load("res://scenes/splash.tscn")
	get_tree().change_scene_to_packed(game_scene)

func main_loop_inner():
	var participating = false
	for num_moves in range(MIN_MOVES, MAX_MOVES + 1):
		for i in range(4 - num_moves):
			participating = false
			create_gauges(0)

			qtip_player.reset()
			qtip_sensei.reset()
			dems.shuffle()

			for j in range(num_attempts):
				await sensei_turn(num_moves, j)
				var success = await player_turn(num_moves)
				await feedback_snarky(success)
				if success:
					participating = true
					break
			if not participating:
				print("Player not participating")
				# TODO: play sensei commenting about it
				return
	# TODO: celebrate success


func sensei_turn(num_moves, attempt):
	player_did = false
	sensei_projector.show()
	await wait_for_demonstration(attempt)
	await play_demonstration(num_moves)
	sensei_projector.hide()


func player_turn(num_moves):
	player_active = true
	player_projector.show()
	#await wait_for_performance()
	var success = await record_performance(num_moves)
	player_projector.hide()
	player_active = false
	return success


func _process(_delta: float) -> void:
	if not player_turn or current_label == null:
		return
	if student.shouted:
		if VoiceClassifier.recognizer != null and classifications.get_prob(current_label) < 0.2:
			return
		student.shouted = false
		player_did = true
		print('Awesome, did it')
		player_made_correct_move.emit()


func feedback_snarky(success):
	player.pitch_scale = 0.55
	player.stream = load("res://sounds/cue5.ogg")
	await timer(0.1)
	player.play()
	await timer(0.2)
	if success:
		if randf() < 0.2:
			sensei_player.stream = load("res://sounds/goodagain2.ogg")
			sensei_player.volume_db = 8 + SENSEI_VOLUME_SCALE
		else:
			sensei_player.stream = load("res://sounds/louder.ogg")
			sensei_player.volume_db = 4 + SENSEI_VOLUME_SCALE
	else:
		if randf() < 0.1:
			sensei_player.stream = load("res://sounds/louder.ogg")
			sensei_player.volume_db = 4 + SENSEI_VOLUME_SCALE
		else:
			sensei_player.stream = load("res://sounds/diaphgram.ogg")
			sensei_player.volume_db = 4 + SENSEI_VOLUME_SCALE
	sensei_player.play()
	sensei_player.volume_db = 0
	await timer(2)
	player.pitch_scale = 1

func timer(seconds):
	return get_tree().create_timer(seconds).timeout

func countdown(time, interval):
	for i in range(time, 0, -1):
		print('Counting down ', i)
		#label.text = 'Counting down ' + str(i)
		await timer(interval)

func wait_for_demonstration(attempt):
	player.stream = load("res://sounds/2gongs.ogg")
	player.play()
	if attempt == 0:
		just_listen.show()
	else:
		now_you.show()
	print('wait_for_demonstration')
	$Dark.show()
	#label.text = 'Get ready for demonstration'
	#sensei_indicator.visible = false
	create_gauges(0, Color.ORANGE)
	#gauges.get_child(0).set_head("sensei")
	#gauges.get_child(0).start(2.1, Color.ORANGE)
	#gauges.get_child(0).started = false
	if attempt == 0:
		sensei_player.stream = load("res://sounds/listen.ogg")
	else:
		sensei_player.stream = load("res://sounds/nowyou.ogg")
	sensei_player.volume_db = 4 + SENSEI_VOLUME_SCALE
	sensei_player.play()
	await timer(1.1)
	player.volume_db = -4
	player.stream = intro
	player.play()
	sensei.play("idle")
	#gauges.get_child(0).start(2.1, Color.ORANGE)
	await countdown(2, 1)
	player.stop()
	just_listen.hide()
	now_you.hide()
	sensei_player.volume_db = 0 + SENSEI_VOLUME_SCALE
	player.volume_db = 0
	$Dark.hide()
	#sensei_indicator.visible = true


func play_demonstration(count):
	print('play_demonstration')
	create_gauges(count, Color.RED)
	#label.text = 'Starting demonstration'
	spectrum_sensei.show_gauge()
	for i in range(count):
		if i < gauges.get_child_count():
			var gauge = gauges.get_child(i)
			gauge.set_head("sensei")
			gauge.start(2, Color.RED)
			gauge.started = false
			await play_short(cue, 0.55)
			#gauge.start(2, Color.RED)
			await perform_clip(sensei, dems[i], 2)
			gauge.set_head(null)
			gauge.cut()
	sensei.play("hit")
	spectrum_sensei.hide_gauge()
	qtip_sensei.hit()
	await timer(0.5)
	sensei.play("listen")


func play_short(clip, duration=null):
	player.stream = clip
	player.play()
	player.pitch_scale = 1.15
	player.volume_db = -4
	var finish = player.finished
	if duration != null:
		finish = timer(duration)
	await finish
	player.pitch_scale = 1
	player.volume_db = 0
	player.stop()

func perform_clip(indicator, clip, duration=null):
	print("HERE")
	sensei_player.stream = clip.sound
	sensei_player.volume_db = 0 + SENSEI_VOLUME_SCALE
	sensei_player.play()
	var finish = sensei_player.finished
	if duration != null:
		finish = timer(duration)
	update_indicator(indicator, clip)
	await finish
	sensei_player.stop()
	sensei_player.stream = null

func wait_for_performance():
	player.stream = load("res://sounds/2gongs.ogg")
	player.play()
	now_you.show()
	print('wait_for_performance')
	#label.text = 'Get ready for performance'
	#student_indicator.visible = false
	create_gauges(1)
	$Dark2.show()
	sensei_player.stream = load("res://sounds/nowyou.ogg")
	sensei_player.volume_db = 4 + SENSEI_VOLUME_SCALE
	sensei_player.play()
	gauges.get_child(0).set_head("player")
	gauges.get_child(0).start(2.1, Color.ORANGE)
	gauges.get_child(0).started = false
	await timer(1.1)
	player.stream = intro
	player.volume_db = -4
	player.play()
	gauges.get_child(0).start(2.1, Color.ORANGE)
	await countdown(2, 1)
	player.stop()
	now_you.hide()
	sensei_player.volume_db = 0
	player.volume_db = 0
	$Dark2.hide()
	#student_indicator.visible = true

func record_performance(count):
	print('record_performance')
	#label.text = 'Starting performance'
	create_gauges(count, PLAYER_COLOR)
	recorder.play()
	spectrum_player.show_gauge()
	var score = 0
	for i in range(count):
		player_did = false
		classifications.reset()
		student.shouted = false
		current_label = dems[i].label
		print("Current label: " + current_label)
		print('start recording')
		var gauge = gauges.get_child(i)
		gauge.set_head("player")
		gauge.start(12, PLAYER_COLOR)
		gauge.started = false
		await play_short(cue, 0.55)
		gauge.start(12, PLAYER_COLOR)
		VoiceClassifier.start()
		var timeout = timer(12)
		timeout.connect(player_made_correct_move.emit)
		player_did = false
		await player_made_correct_move
		timeout.disconnect(player_made_correct_move.emit)
		update_indicator(null, dems[i])
		print('stop recording')
		VoiceClassifier.stop()
		gauge.set_head(null)
		if player_did:
			gauge.cut()
			score += 1
		else:
			break

	recorder.stop()
	spectrum_player.hide_gauge()
	student.play("hit")
	print(str(score) + ' / ' + str(count))
	var success = score == count
	if success:
		qtip_player.hit()
	await timer(0.5)
	student.idle()
	return success

func create_gauges(num: int, color: Color = Color.GREEN) -> void:
	for gauge in gauges.get_children():
		gauges.remove_child(gauge)
		gauge.queue_free()
	index = 0
	var gauge = null
	for i in range(num):
		gauge = gauge_scene.instantiate()
		gauges.add_child(gauge)
		gauge.set_color(color)
	if gauge != null:
		gauge.next_mark.hide()

func update_indicator(indicator, clip):
	if indicator != null:
		print(indicator)
		indicator.play(clip.chore)
	#indicator.material_override.albedo_color = color
