extends RefCounted
class_name Juice


var is_running: bool = false
var amount_rotation: float = 0.0
var amount_scale: Vector2 = Vector2(0, 0)
var progress_time: float = 0.0
var duration: float = 0.0
var phase_scale: float
var phase_rotation: float
var current_juice_rotation: float = 0.0
var current_juice_scale: Vector2 = Vector2(0, 0)

signal on_stop_change


func _init(_phase_scale: float = 0.0, _phase_rotation: float = 0.0, rand_phase: bool = false) -> void:
	phase_scale = _phase_scale
	phase_rotation = _phase_rotation
	if rand_phase:
		phase_scale = randf() * TAU
		phase_rotation = randf() * TAU
	is_running = false
	
	
func start(_amount_rotation: float = 0.0, _amount_scale: Vector2 = Vector2(0, 0), _duration: float = 0.0) -> void:
	is_running = true
	amount_rotation = _amount_rotation
	amount_scale = _amount_scale
	duration = _duration
	progress_time = 0.0
	current_juice_rotation = 0.0
	current_juice_scale = Vector2(0, 0)
	
	
func update(delta: float) -> void:
	if not is_running:
		return
	progress_time += delta
	var progress_ratio: float = clamp(progress_time / duration, 0.0, 1.0)
	current_juice_scale = amount_scale * sin(phase_scale + 50.8 * progress_time) * pow(1 - progress_ratio, 3)  # Balatro juice recipe
	current_juice_rotation = amount_rotation * sin(phase_rotation + 40.8 * progress_time) * pow(1 - progress_ratio, 2)  # Balatro juice recipe
	if progress_ratio >= 1.0:
		current_juice_scale = Vector2(0, 0)
		current_juice_rotation = 0.0
		is_running = false
		on_stop_change.emit()
