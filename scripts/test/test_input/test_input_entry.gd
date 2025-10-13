extends Node


@export var input_control: InputControl


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	assert(input_control != null)
	assert(input_control.pick != null)
	input_control.pick.on_pick.connect(func(pick_index: int) -> void:
		print("Picked: ", input_control.name, " with index ", pick_index))
	input_control.pick.on_cancel.connect(func() -> void:
		print("Unpicked: ", input_control.name))
	assert(input_control.drag != null)
	input_control.drag.on_stop.connect(func() -> void:
		print("Drag stopped: ", input_control.name))
	assert(input_control.hover != null and input_control.hover.enabled)
	input_control.hover.on_start_hover.connect(func() -> void:
		print("Start hover: ", input_control.name))
	input_control.hover.on_stop_hover.connect(func() -> void:
		print("Stop hover: ", input_control.name))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
