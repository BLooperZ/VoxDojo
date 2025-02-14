extends Control

@export var seconds: float

@onready var progress = $TextureProgressBar
@onready var started = false
@onready var ended = false
var remaining

@onready var sensei_head: Sprite2D = $Frame16
@onready var player_head: Sprite2D = $Frame17
@onready var next_mark: Sprite2D = $Sprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	reset(seconds)

func set_head(head_name):
	sensei_head.hide()
	player_head.hide()
	if head_name == 'sensei':
		sensei_head.show()
	elif head_name == 'player':
		player_head.show()

func set_color(color: Color):
	progress.tint_progress = color
	next_mark.modulate = color

func reset(time):
	ended = false
	started = false
	seconds = time
	var total_time = seconds * 1000
	progress.scale = 0.25 * Vector2.ONE
	progress.set_max(total_time)
	progress.set_value(total_time)
	progress.tint_progress = Color.CADET_BLUE
	remaining = total_time

func start(time: int, color: Color = Color.GREEN) -> void:
	reset(time)
	set_color(color)
	started = true
	progress.scale = 0.35 * Vector2.ONE

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if started and not ended:
		remaining = max(0, remaining - 1000 * delta)
		progress.set_value(remaining)
		if remaining <= 0:
			ended = true
			progress.scale = 0.25 * Vector2.ONE
			next_mark.modulate = Color.html("#3B3838")
