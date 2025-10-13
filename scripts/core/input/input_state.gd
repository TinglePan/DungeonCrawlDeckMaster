extends RefCounted
class_name InputState


var active_controls: Array[InputControl]
var pick_groups: Array[PickGroup]
var default_pick_group: PickGroup = PickGroup.new("default", 1)
var mouse_button_states: Dictionary          = {
									MOUSE_BUTTON_LEFT: MouseButtonState.new(),
									MOUSE_BUTTON_RIGHT: MouseButtonState.new(),
									MOUSE_BUTTON_MIDDLE: MouseButtonState.new()
								}
var tracking_mouse_down_controls: Dictionary = {
									   MOUSE_BUTTON_LEFT: [],
									   MOUSE_BUTTON_RIGHT: [],
									   MOUSE_BUTTON_MIDDLE: []
								   }
var hovering_control: InputControl = null
var dragging_controls: Array[InputControl] = []
var last_active_pick_group: PickGroup = null

signal on_hover_changed(new: InputControl, old: InputControl)


func _init(_active_controls: Array[InputControl], _pick_groups: Array[PickGroup]):
	active_controls = _active_controls
	active_controls.sort_custom(func(a, b): return a.input_priority() - b.input_priority())
	pick_groups = _pick_groups

	
func on_exit():
	for pick_group in pick_groups:
		pick_group.clear()

	
func can_receive_input(control: InputControl) -> bool:
	return control in active_controls


func input_control_sort_func(a, b) -> int:
	return b.mouse_input.priority() - a.mouse_input.priority()


func find_colliding_control(collider) -> InputControl:
	for control in active_controls:
		if control.mouse_input == null:
			continue
		if control.mouse_input.area == collider:
			return control
	return null

	
func update() -> void:
	var colliders = g_input_mgr.mouse_point_cast()
	var colliding_controls: Array = []

	for collider in colliders:
		var control: InputControl = find_colliding_control(collider)
		if control != null:
			Utils.insert_sorted(colliding_controls, control, input_control_sort_func)
	var current_hovering_control: InputControl = null
	for control: InputControl in colliding_controls:
		if can_receive_input(control):
			if control.can_hover():
				current_hovering_control = control
				if current_hovering_control != control:
					break
	if current_hovering_control != hovering_control:
		if hovering_control != null:
			hovering_control.hover.stop_hover()
		if current_hovering_control != null:
			current_hovering_control.hover.start_hover()
		on_hover_changed.emit(hovering_control, current_hovering_control)
		hovering_control = current_hovering_control

	for button_index in mouse_button_states:
		var button_state: MouseButtonState = mouse_button_states[button_index]
		if button_state.is_holding(Time.get_ticks_msec()):
			for control in dragging_controls:
				var mouse_position = g_input_mgr.get_global_mouse_position()
				control.on_mouse_motion(button_index, mouse_position)

	
func mouse_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var button_event: InputEventMouseButton = event as InputEventMouseButton
		var button_index: int = button_event.button_index
		if button_index not in mouse_button_states:
			return
		var colliders = g_input_mgr.mouse_point_cast()
		var colliding_controls: Array = []
		for collider in colliders:
			var control: InputControl = find_colliding_control(collider)
			if control != null:
				Utils.insert_sorted(colliding_controls, control, input_control_sort_func)
		if button_event.pressed:
			var button_state: MouseButtonState = mouse_button_states[button_index]
			button_state.down(button_event.position, Time.get_ticks_msec())
			for control in colliding_controls:
				if can_receive_input(control):
					var stop_propagate: bool = control.on_mouse_down(button_index, button_event.position)
					if stop_propagate:
						break
		else:
#			find_colliding_control(colliders[0])
			var button_state: MouseButtonState = mouse_button_states[button_index]
			var notification_type: MouseButtonState.NOTIFICATION = button_state.up(button_event.position, Time.get_ticks_msec())
			var unhandled: bool = true
			for control in colliding_controls:
				if can_receive_input(control) and not is_dragging(control):
					var stop_propagate: bool = control.on_mouse_up(button_index, button_event.position, notification_type)
					unhandled = false
					if stop_propagate:
						break
			if unhandled:
				if notification_type == MouseButtonState.NOTIFICATION.DRAG_END:
					cancel_dragging(button_index)
				elif button_index == MouseButton.MOUSE_BUTTON_RIGHT and notification_type == MouseButtonState.NOTIFICATION.CLICK:
				# Right click on empty space cancels current pick
					last_active_pick_group.cancel_latest_pick()
			tracking_mouse_down_controls[button_index].clear()
	elif event is InputEventMouseMotion:
		var motion_event: InputEventMouseMotion = event as InputEventMouseMotion
		for button_index in mouse_button_states:
			if button_index | motion_event.button_mask:
				for control in tracking_mouse_down_controls[button_index]:
					control.on_mouse_motion(button_index, motion_event.position)
					
					
func track_mouse_down(button_index: MouseButton, control: InputControl):
	if not tracking_mouse_down_controls[button_index].has(control):
		Utils.insert_sorted(tracking_mouse_down_controls[button_index], control, input_control_sort_func)
				
				
func is_holding(control: InputControl) -> bool:
	var button_index: MouseButton = control.mouse_drag_button
	var button_state: MouseButtonState = mouse_button_states[button_index]
	if control in tracking_mouse_down_controls[button_index] and button_state.is_holding(Time.get_ticks_msec()):
		return true
	return false
	
	
func start_dragging(control: InputControl):
	if control not in dragging_controls:
		Utils.insert_sorted(dragging_controls, control, input_control_sort_func)
		control.drag.start()
	

func is_dragging(control: InputControl) -> bool:
	return control in dragging_controls
	
	
func is_dragging_any() -> bool:
	return dragging_controls.size() > 0

	
func cancel_dragging(button_index: MouseButton):
	var cancel_list: Array = []
	for control in dragging_controls:
		if control.drag != null and control.mouse_drag_button == button_index:
			control.drag.cancel()
			cancel_list.append(control)
	for control in cancel_list:
		dragging_controls.erase(control)

	
func is_hovering(control: InputControl) -> bool:
	return hovering_control == control and not is_dragging_any()
