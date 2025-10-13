extends Node2D


var input_state_stack: Array[InputState] = []


func _input(event: InputEvent) -> void:
	var state: InputState = current_input_state()
	if state != null:
		state.mouse_input(event)
		
	
func _process(_delta: float) -> void:
	var state: InputState = current_input_state()
	if state != null:
		state.update()


func current_input_state() -> InputState:
	if input_state_stack.size() == 0:
		return null
	return input_state_stack[input_state_stack.size() - 1]


func push_input_state(state: InputState):
	var c: InputState = current_input_state()
	if c != null:
		c.on_exit()
	input_state_stack.append(state)


func pop_input_state() -> InputState:
	if input_state_stack.size() == 0:
		return null
	var c = input_state_stack.pop_back()
	c.on_exit()
	return c

	
func mouse_point_cast() -> Array:
	var parameters = PhysicsPointQueryParameters2D.new()
	parameters.position = get_global_mouse_position()
	parameters.collide_with_areas = true
	var objects: Array[Dictionary] = get_world_2d().direct_space_state.intersect_point(parameters)
	return objects.map(func (x): return x["collider"] as Node2D)
