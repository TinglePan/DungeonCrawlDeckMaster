# Put this script on a Node2D that is a child of an InputControl node.
extends Node2D
class_name Hover


@export var enabled: bool
var input_control: InputController
signal on_start_hover
signal on_stop_hover


func _ready() -> void:
	input_control = get_parent() as InputController
	assert(input_control != null, "MouseInput must be a child of an InputControl node")

	
func start_hover() -> void:
	on_start_hover.emit()
	
	
func stop_hover() -> void:
	on_stop_hover.emit()