extends Node2D

var effect: AudioEffectRecord  # See AudioEffect in docs
var recording: AudioStream  # See AudioStreamSample in docs

const SENSEI_VOLUME_SCALE = 10

@onready var player = $AudioStreamPlayer
@onready var sensei: Node2D = $Sensei
@onready var recorder: AudioStreamPlayer = $AudioStreamRecord
@onready var sensei_player: AudioStreamPlayer = $Sensei/AudioStreamPlayer2
@onready var player2: AudioStreamPlayer = $AudioStreamPlayer2
@export var lines: Array[AudioStream]

@onready var spectrum_player: Node2D = $Student/Spectrum

var index = 0


const MAX_MOVES = 4
const MIN_MOVES = 1

var recs: Array = []
@export var dems: Array[AudioStream]
@onready var student: Node2D = $Student
@export var intro: AudioStream
@export var cue: AudioStream

var done = false
var detected = 0.0

var last_value = 0

signal start_game

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#spectrum_player.record_idx = null
	spectrum_player.show_gauge()
	recorder.play()
	connect("start_game", call_start_game)

func _process(_delta: float) -> void:
	$PlayerHead.volume = spectrum_player.volume.value

func _physics_process(delta: float) -> void:
	if spectrum_player.volume.value >= 1250 and not done:
		done = true
		start_game.emit()

	if done:
		return

	if spectrum_player.volume.value >= 1000 and last_value >= 1000:
		student.play("small_overhead")
		if detected <= 0 and not sensei_player.is_playing():
			sensei_player.stream = lines[1]
			sensei_player.volume_db = 0 + SENSEI_VOLUME_SCALE
			sensei_player.play()
		detected = 1.0
	elif spectrum_player.volume.value >= 700 and last_value >= 700:
		student.play("smaller_overhead")
		if detected <= 0 and not sensei_player.is_playing():
			sensei_player.stream = lines[1]
			sensei_player.volume_db = 0 + SENSEI_VOLUME_SCALE
			sensei_player.play()
		detected = 1.0
	elif detected > 0:
		detected -= delta
	if detected <= 0.0:
		detected = 0.0
		if student.chore != 'idle' and not sensei_player.is_playing():
			sensei_player.stream = lines[0]
			sensei_player.volume_db = 0 + SENSEI_VOLUME_SCALE
			sensei_player.play()
			student.play("idle")
	last_value = spectrum_player.volume.value


func collapse_splash():
	$Frame19.hide()
	$Node2D.show()
	for elem in $Node2D.get_children():
		elem.freeze = false
		elem.apply_impulse(Vector2(2, 1))
	$RigidBody2D.freeze = false
	$RigidBody2D.apply_impulse(Vector2(4,3))


func call_start_game():
	#play sensei coming animation + sound
	#start actual game
	#spectrum_player.hide()
	student.play('overhead')
	await get_tree().create_timer(0.4).timeout
	collapse_splash()
	await get_tree().create_timer(1.2).timeout
	player.stream = load("res://sounds/collapse.ogg")
	player.volume_db = 6
	player.play()
	student.play("hit")
	await get_tree().create_timer(0.7).timeout
	player.volume_db = 0
	#play everything collapse animation + sound
	sensei.play("walk")
	sensei_player.stream = load("res://sounds/heardyoufirst.ogg")
	sensei_player.volume_db = 0 + SENSEI_VOLUME_SCALE
	sensei_player.play()
	await get_tree().create_timer(5.5).timeout
	var game_scene = preload("res://scenes/dojo.tscn")
	get_tree().change_scene_to_packed(game_scene)
	print("COOL")
