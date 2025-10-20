extends Node


@export var input_control: InputController


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	assert(input_control != null)
	assert(input_control.drop != null)
	input_control.drop.on_drop.connect(func(dropped_controls: Array[InputController]) -> void:
		print("Dropped on: ", input_control.name)
		for dropped_control in dropped_controls:
			print("Dropped controls: ", dropped_control.node.name))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
