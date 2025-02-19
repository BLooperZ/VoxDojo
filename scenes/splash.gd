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
@onready var sensei_player: AudioStreamPlayer = $Sensei/AudioStreamPlayer2
@onready var player2: AudioStreamPlayer = $AudioStreamPlayer2

@onready var spectrum_player: Node2D = $Student/Spectrum

var active_gauge = null
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

signal start_game

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#spectrum_player.record_idx = null
	spectrum_player.show_gauge()
	recorder.play()
	connect("start_game", call_start_game)

func _physics_process(delta: float) -> void:
	if spectrum_player.volume.value >= 1200 and not done:
		done = true
		start_game.emit()
		return

	if spectrum_player.volume.value >= 600:
		student.play("small")
		detected = 1.0
	elif detected > 0:
		detected -= delta
	if detected <= 0.0:
		detected = 0.0

func collapse_splash():
	$Frame19.hide()
	$Node2D.show()
	for elem in $Node2D.get_children():
		elem.freeze = false
		elem.apply_impulse(Vector2(2, 1))
	$RigidBody2D.freeze = false
	$RigidBody2D.apply_impulse(Vector2(4,3))


func call_start_game():
	#play everything collapse animation + sound
	#play sensei coming animation + sound
	#start actual game
	#spectrum_player.hide()
	collapse_splash()
	student.play('overhead')
	sensei.play("walk")
	await get_tree().create_timer(3).timeout
	var game_scene = preload("res://scenes/dojo.tscn")
	get_tree().change_scene_to_packed(game_scene)
	print("COOL")
