# Put this script on a Node2D that is a child of an InputControl node.
extends Node2D
class_name Drop


var input_control: InputControl
signal on_drop(controls: Array[InputControl])


func _ready() -> void:
	input_control = get_parent() as InputControl
	assert(input_control != null, "MouseInput must be a child of an InputControl node")
	
	
func can_drop(control: InputControl) -> bool:
	if control.drag == null:
		return false
	return true


func drop(controls: Array) -> void:
	var dropped_controls: Array[InputControl] = []
	for control in controls:
		if can_drop(control):
			control.drag.stop()
			dropped_controls.append(control)
	for control in dropped_controls:
		controls.erase(control)
	if dropped_controls.size() > 0:
		on_drop.emit(dropped_controls)
	
