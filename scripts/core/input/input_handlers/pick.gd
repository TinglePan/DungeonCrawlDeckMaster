
# Put this script on a Node2D that is a child of an InputControl node.
extends Node2D
class_name Pick


@export var pick_group_names: Array[String] = []
@export var cancel_on_repick: bool = true
var input_control: InputController

signal on_pick(pick_index: int)
signal on_cancel()


func _ready() -> void:
	input_control = get_parent() as InputController
	assert(input_control != null, "MouseInput must be a child of an InputControl node")
	
	
func current_pick_group() -> PickGroup:
	var input_state = g_input_mgr.current_input_state()
	for pick_group in input_state.pick_groups:
		if pick_group.name in pick_group_names:
			return pick_group
	return input_state.default_pick_group
	
	
func pick(_pick_index: int) -> void:
	on_pick.emit(_pick_index)
	
	
func cancel():
	on_cancel.emit()
