extends Node2D
class_name TransformControl


enum MoveAxis {
	X,
	Y
}

@export var node: Node2D
@export var rotate_on_move: bool
@export var rotate_on_move_limit: float = PI / 8  # Limit rotation speed when following movement direction
@export var rotate_on_move_factor: float = 0.00015  # Factor to multiply velocity to get rotation speed
@export var hover_scale_factor: float = 0.05  # Scale factor when hovering (1 + factor)
@export var drag_scale_factor: float = 0.1  # Scale factor when dragging (1 + factor)

var input_control: InputControl

var change_position_value: ChangeValue
var change_rotation_value: ChangeValue
var change_scale_value: ChangeValue
var juice: Juice
var is_changing: bool = false

signal on_stop_change


func _ready() -> void:
	assert(node != null)
	input_control = node.get_node_or_null("InputControl")
	
	change_position_value = ChangeValue.new(node.global_position)
	change_rotation_value = ChangeValue.new(node.rotation)
	change_scale_value = ChangeValue.new(node.scale)
	
	juice = Juice.new(0.0, 0.0, true)
	is_changing = false

		
func _process(delta: float) -> void:
	var rotation_mod_target_value: float = 0.0
	var scale_mod_target_mult: Vector2 = Vector2.ONE
	var is_changing_now: bool = false
	
	if input_control != null:
		var input_state: InputState = g_input_mgr.current_input_state()
		if input_state.is_dragging(input_control) or input_state.is_holding(input_control):
			scale_mod_target_mult += Vector2.ONE * drag_scale_factor
		elif input_state.is_hovering(input_control):
			scale_mod_target_mult += Vector2.ONE * hover_scale_factor
		
	if juice != null and juice.is_running:
		juice.update(delta)
		rotation_mod_target_value += juice.current_juice_rotation
		scale_mod_target_mult += juice.current_juice_scale

	if change_position_value.is_changing() or is_changing:
		is_changing_now = true
		change_position_value.update(delta)

	if rotate_on_move:
		var rotate_mod = clamp(rotate_on_move_factor * change_position_value.velocity.x / delta, -rotate_on_move_limit, rotate_on_move_limit)
		rotation_mod_target_value += rotate_mod
	if change_rotation_value.mod_target_value != rotation_mod_target_value:
		if change_rotation_value.is_changing():
			change_rotation_value.update_mod_target_value(rotation_mod_target_value)
		else:
			change_rotation_value.start_change(change_rotation_value.target_value, ChangeValue.ChangeType.SMOOTH_DAMP, Constants.DEFAULT_SMOOTH_TIME, rotation_mod_target_value)
	if change_rotation_value.is_changing() or is_changing:
		is_changing_now = true
		change_rotation_value.update(delta)

	var scale_mod_target_value: Vector2 = (scale_mod_target_mult - Vector2.ONE) * change_scale_value.target_value
	if change_scale_value.mod_target_value != scale_mod_target_value:
		if change_scale_value.is_changing():
			change_scale_value.update_mod_target_value(scale_mod_target_value)
		else:
			change_scale_value.start_change(change_scale_value.target_value, ChangeValue.ChangeType.SMOOTH_DAMP, Constants.DEFAULT_SMOOTH_TIME, scale_mod_target_value)
	if change_scale_value.is_changing() or is_changing:
		is_changing_now = true
		change_scale_value.update(delta)
	
	if is_changing_now or is_changing:
		node.global_position = change_position_value.current_value
		node.rotation = change_rotation_value.current_value
		node.scale = change_scale_value.current_value
		
	if is_changing_now != is_changing:
		is_changing = is_changing_now
		if not is_changing:
			on_stop_change.emit()

			
func start_move(target_position: Vector2, change_type: ChangeValue.ChangeType, change_time: float) -> void:
	change_position_value.start_change(target_position, change_type, change_time)
	
	
func start_move_along_axis(target_position: float, change_type: ChangeValue.ChangeType, change_time: float, axis: MoveAxis) -> void:
	match axis:
		MoveAxis.X:
			change_position_value.start_change(Vector2(target_position, change_position_value.current_value.y), change_type, change_time)
		MoveAxis.Y:
			change_position_value.start_change(Vector2(change_position_value.current_value.x, target_position), change_type, change_time)
		_:
			push_error("Invalid axis")
	
			
func start_rotate(target_rotation: float, change_type: ChangeValue.ChangeType, change_time: float) -> void:
	change_rotation_value.start_change(target_rotation, change_type, change_time)
	
	
func start_scale(target_scale: Vector2, change_type: ChangeValue.ChangeType, change_time: float) -> void:
	change_scale_value.start_change(target_scale, change_type, change_time)
	
	
func start_juice(amount_rotation: float = 0.0, amount_scale: Vector2 = Vector2(0, 0), duration: float = 0.0) -> void:
	if juice != null:
		juice.start(amount_rotation, amount_scale, duration)
	
	
func wait_for_stop():
	if is_changing:
		await on_stop_change
