# Put this script on a Node2D that is a child of an InputControl node.
extends Node2D
class_name Drag


var input_control: InputController
var start_position: Vector2
var record_z_index_before_dragging: int
signal on_start
signal on_stop


func _ready() -> void:
	input_control = get_parent() as InputController
	assert(input_control != null, "MouseInput must be a child of an InputControl node")

	
func is_mouse_drag_start(button_state: MouseButtonState, mouse_position: Vector2) -> bool:
	var distance: Vector2 = mouse_position - button_state.last_down_position
	if distance.length() >= Constants.MOUSE_DRAG_DISTANCE_THRESHOLD:
		return true
	return false
	
	
func drag(mouse_position: Vector2):
	var node: Node2D                           = input_control.node
	var transform_control: TransformController = node.get_node("TransformControl")
	if transform_control != null:
		transform_control.start_move(mouse_position, ChangeValue.ChangeType.SMOOTH_DAMP, Constants.DRAG_MOVE_SMOOTH_TIME)
	else:
		node.global_position = mouse_position
		
		
func start():
	var node: Node2D = input_control.node
	start_position = node.global_position
	record_z_index_before_dragging = node.z_index
	node.z_index = Constants.DRAG_Z_INDEX
	on_start.emit()

		
func cancel():
	var node: Node2D                           = input_control.node
	var transform_control: TransformController = node.get_node("TransformControl")
	if transform_control != null:
		transform_control.start_move(start_position, ChangeValue.ChangeType.SMOOTH_DAMP, Constants.DRAG_MOVE_SMOOTH_TIME)
	else:
		node.global_position = start_position
	stop()

	
func stop():
	var node: Node2D = input_control.node
	node.z_index = record_z_index_before_dragging
	on_stop.emit()