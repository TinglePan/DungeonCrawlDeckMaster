extends Node2D
class_name InputController


@export var mouse_input: MouseInput
@export var pick: Pick
@export var mouse_pick_button: MouseButton = MouseButton.MOUSE_BUTTON_LEFT
@export var mouse_unpick_button: MouseButton = MouseButton.MOUSE_BUTTON_RIGHT
@export var drag: Drag
@export var mouse_drag_button: MouseButton = MouseButton.MOUSE_BUTTON_LEFT
@export var drop: Drop
@export var hover: Hover

var node: Node2D


func _ready() -> void:
	node = get_parent() as Node2D
	assert(node != null, "InputControl must be a child of a Node2D node")

	
func input_priority() -> int:
	if mouse_input != null:
		return mouse_input.priority()
	return 0


# returns true to stop propagation
func on_mouse_down(button_index: MouseButton, _mouse_position: Vector2) -> bool:
	if mouse_input != null:
		var input_state: InputState = g_input_mgr.current_input_state()
		if pick != null or drag != null or drop != null:
			input_state.track_mouse_down(button_index, self)
			return mouse_input.stop_propagation
	return false
	
	
# returns true to stop propagation
func on_mouse_up(button_index: MouseButton, _mouse_position: Vector2, notification_type: MouseButtonState.NOTIFICATION) -> bool:
	if mouse_input != null:
		match notification_type:
			MouseButtonState.NOTIFICATION.CLICK:
				if pick != null:
					var pick_group: PickGroup = pick.current_pick_group()
					if button_index == mouse_pick_button:
						pick_group.pick(pick)
						return mouse_input.stop_propagation
					elif button_index == mouse_unpick_button:
						pick_group.cancel(pick)
						return mouse_input.stop_propagation
			MouseButtonState.NOTIFICATION.DOUBLE_CLICK:
				if pick != null:
					var pick_group: PickGroup = pick.current_pick_group()
					if button_index == mouse_pick_button:
						pick_group.pick(pick)
						return mouse_input.stop_propagation
					elif button_index == mouse_unpick_button:
						pick_group.cancel(pick)
						return mouse_input.stop_propagation
			MouseButtonState.NOTIFICATION.DRAG_END:
				if drop != null:
					if button_index == mouse_drag_button:
						var input_state: InputState = g_input_mgr.current_input_state()
						drop.drop(input_state.dragging_controllers)
						return mouse_input.stop_propagation
	return false
	
	
func on_mouse_motion(button_index: MouseButton, _mouse_relative: Vector2, mouse_position: Vector2) -> void:
	if mouse_input != null:
		if drag != null and button_index == mouse_drag_button:
			var input_state: InputState = g_input_mgr.current_input_state()
			if not input_state.is_dragging(self):
				var button_state: MouseButtonState = input_state.mouse_button_states[button_index]
				if drag.is_mouse_drag_start(button_state, mouse_position):
					input_state.start_dragging(self)
			else:
				drag.drag(mouse_position)
		
		
func can_hover() -> bool:
	if mouse_input != null:
		if hover != null and hover.enabled:
			return true
	return false
