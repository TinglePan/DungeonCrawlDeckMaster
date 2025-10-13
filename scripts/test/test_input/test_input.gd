extends Node


@export var input_control_entry_1: InputControl
@export var input_control_entry_2: InputControl
@export var input_control_container_1: InputControl
@export var input_control_3: InputControl
@export var input_control_4: InputControl
@export var input_control_container_2: InputControl
var step: int


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	step = 0
	var input_state: InputState = init_input_state([input_control_entry_1, input_control_entry_2, input_control_container_1], [PickGroup.new("group1", 1)])
	g_input_mgr.push_input_state(input_state)
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("confirm"):
		match step:
			0:
				var new_input_state = InputState.new([input_control_3, input_control_4, input_control_container_2], [PickGroup.new("group2", 5)])
				g_input_mgr.push_input_state(new_input_state)
			1:
				g_input_mgr.pop_input_state()
		step += 1
		
		
func init_input_state(input_controls: Array[InputControl], pick_groups: Array[PickGroup]) -> InputState:
	var new_input_state = InputState.new(input_controls, pick_groups)
	new_input_state.on_hover_changed.connect(func(from: InputControl, to: InputControl) -> void:
		print("Hovered over: ", from, " to ", to))
	return new_input_state
