extends RefCounted
class_name InputState


var active_controllers: Array[InputController]
var pick_groups: Array[PickGroup]
var default_pick_group: PickGroup               = PickGroup.new("default", 1)
var mouse_button_states: Dictionary             = {
									MOUSE_BUTTON_LEFT: MouseButtonState.new(),
									MOUSE_BUTTON_RIGHT: MouseButtonState.new(),
									MOUSE_BUTTON_MIDDLE: MouseButtonState.new()
								}
var tracking_mouse_down_controllers: Dictionary = {
									   MOUSE_BUTTON_LEFT: [],
									   MOUSE_BUTTON_RIGHT: [],
									   MOUSE_BUTTON_MIDDLE: []
								   }
var hovering_controller: InputController        = null
var dragging_controllers: Array[InputController] = []
var last_active_pick_group: PickGroup            = null

signal on_hover_changed(new: InputController, old: InputController)
signal on_untargeted_mouse_down(button_index: MouseButton, mouse_position: Vector2)
signal on_untargeted_drag(button_mask: MouseButtonMask, mouse_position: Vector2)


func _init(_active_controllers: Array[InputController], _pick_groups: Array[PickGroup]):
	active_controllers = _active_controllers
	active_controllers.sort_custom(func(a, b): return a.input_priority() - b.input_priority())
	pick_groups = _pick_groups

	
func on_exit():
	for pick_group in pick_groups:
		pick_group.clear()

	
func can_receive_input(controller: InputController) -> bool:
	return controller in active_controllers


func input_controller_sort_func(a, b) -> int:
	return b.mouse_input.priority() - a.mouse_input.priority()


func find_colliding_controller(collider) -> InputController:
	for controller in active_controllers:
		if controller.mouse_input == null:
			continue
		if controller.mouse_input.area == collider:
			return controller
	return null

	
func update() -> void:
	var colliders                    = g_input_mgr.mouse_point_cast()
	var colliding_controllers: Array = []

	for collider in colliders:
		var controller: InputController = find_colliding_controller(collider)
		if controller != null:
			Utils.insert_sorted(colliding_controllers, controller, input_controller_sort_func)
	var current_hovering_controller: InputController = null
	for controller: InputController in colliding_controllers:
		if can_receive_input(controller):
			if controller.can_hover():
				current_hovering_controller = controller
				if current_hovering_controller != controller:
					break
	if current_hovering_controller != hovering_controller:
		if hovering_controller != null:
			hovering_controller.hover.stop_hover()
		if current_hovering_controller != null:
			current_hovering_controller.hover.start_hover()
		var old_hovering_controller: InputController = hovering_controller
		hovering_controller = current_hovering_controller
		on_hover_changed.emit(old_hovering_controller, hovering_controller)
#	for button_index in mouse_button_states:
#		var button_state: MouseButtonState = mouse_button_states[button_index]
#		if button_state.is_holding(Time.get_ticks_msec()):
#			for controller in dragging_controllers:
#				var mouse_position = g_input_mgr.get_global_mouse_position()
#				controller.on_mouse_motion(button_index, mouse_position)

	
func mouse_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var button_event: InputEventMouseButton = event as InputEventMouseButton
		var button_index: int = button_event.button_index
		if button_index not in mouse_button_states:
			return
		var colliders = g_input_mgr.mouse_point_cast()
		var colliding_controllers: Array = []
		for collider in colliders:
			var controller: InputController = find_colliding_controller(collider)
			if controller != null:
				Utils.insert_sorted(colliding_controllers, controller, input_controller_sort_func)
		if button_event.pressed:
			var button_state: MouseButtonState = mouse_button_states[button_index]
			button_state.down(button_event.position, Time.get_ticks_msec())
			var unhandled: bool = true
			for controller in colliding_controllers:
				if can_receive_input(controller):
					var stop_propagate: bool = controller.on_mouse_down(button_index, button_event.position)
					unhandled = false
					if stop_propagate:
						break
			if unhandled:
				untargeted_mouse_down(button_index, button_event.position)
		else:
#			find_colliding_control(colliders[0])
			var button_state: MouseButtonState = mouse_button_states[button_index]
			var notification_type: MouseButtonState.NOTIFICATION = button_state.up(button_event.position, Time.get_ticks_msec())
			var unhandled: bool = true
			for controller in colliding_controllers:
				if can_receive_input(controller) and not is_dragging(controller):
					var stop_propagate: bool = controller.on_mouse_up(button_index, button_event.position, notification_type)
					unhandled = false
					if stop_propagate:
						break
			if unhandled:
				untargeted_mouse_up(button_index, notification_type)
			tracking_mouse_down_controllers[button_index].clear()
	elif event is InputEventMouseMotion:
		var motion_event: InputEventMouseMotion = event as InputEventMouseMotion
		for button_index in mouse_button_states:
			if button_index & motion_event.button_mask:
				for controller in tracking_mouse_down_controllers[button_index]:
					controller.on_mouse_motion(button_index, motion_event.relative, motion_event.position)
		if not is_dragging_any():
			untargeted_drag(motion_event.button_mask, motion_event.relative, motion_event.position)
					
					
func track_mouse_down(button_index: MouseButton, controller: InputController):
	if not tracking_mouse_down_controllers[button_index].has(controller):
		Utils.insert_sorted(tracking_mouse_down_controllers[button_index], controller, input_controller_sort_func)
				
		
func untargeted_mouse_down(button_index: MouseButton, mouse_position: Vector2):	
	on_untargeted_mouse_down.emit(button_index, mouse_position)

		
func untargeted_mouse_up(button_index: MouseButton, notification_type: MouseButtonState.NOTIFICATION):
	if notification_type == MouseButtonState.NOTIFICATION.DRAG_END:
		cancel_dragging(button_index)
	elif button_index == MouseButton.MOUSE_BUTTON_RIGHT and notification_type == MouseButtonState.NOTIFICATION.CLICK:
		# Right click on empty space cancels current pick
		last_active_pick_group.cancel_latest_pick()


func untargeted_drag(button_mask: MouseButtonMask, mouse_relative: Vector2, mouse_position: Vector2):	
	on_untargeted_drag.emit(button_mask, mouse_relative, mouse_position)

				
func is_holding(controller: InputController) -> bool:
	var button_index: MouseButton =      controller.mouse_drag_button
	var button_state: MouseButtonState = mouse_button_states[button_index]
	if controller in tracking_mouse_down_controllers[button_index] and button_state.is_holding(Time.get_ticks_msec()):
		return true
	return false
	
	
func start_dragging(controller: InputController):
	if controller not in dragging_controllers:
		Utils.insert_sorted(dragging_controllers, controller, input_controller_sort_func)
		controller.drag.start()
	

func is_dragging(controller: InputController) -> bool:
	return controller in dragging_controllers
	
	
func is_dragging_any() -> bool:
	return dragging_controllers.size() > 0

	
func cancel_dragging(button_index: MouseButton):
	var cancel_list: Array = []
	for controller in dragging_controllers:
		if controller.drag != null and controller.mouse_drag_button == button_index:
			controller.drag.cancel()
			cancel_list.append(controller)
	for controller in cancel_list:
		dragging_controllers.erase(controller)

	
func is_hovering(controller: InputController) -> bool:
	return hovering_controller == controller and not is_dragging_any()

	
func add_input_controller(controller: InputController) -> void:
	if controller not in active_controllers:
		Utils.insert_sorted(active_controllers, controller, input_controller_sort_func)


func remove_input_controller(controller: InputController) -> void:
	if controller in active_controllers:
		active_controllers.erase(controller)
