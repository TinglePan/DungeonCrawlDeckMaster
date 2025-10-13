# Put this script on a Node2D that is a child of an InputControl node.
extends Node2D
class_name MouseInput


@export var area: Node2D
@export var collision_shape: CollisionShape2D
@export var stop_propagation: bool = true
var input_control: InputControl


func _ready() -> void:
	input_control = get_parent() as InputControl
	assert(input_control != null, "MouseInput must be a child of an InputControl node")


func priority() -> int:
	return input_control.node.z_index