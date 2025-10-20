extends Node


@export var layout_container: BaseLayoutContainer
@export var layout_elements: Array[LayoutElement] = []
@export var layout_container_2: BaseLayoutContainer
@export var layout_elements_2: Array[LayoutElement] = []
@export var camera_transform_controller: CameraTransformController


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("Ready")
	var input_state = InputState.new([], [PickGroup.new("group1", 1)])
	g_input_mgr.push_input_state(input_state)
	for layout_element in layout_elements:
		print("Adding layout element: ", layout_element.name)
		layout_container.add(layout_element)
		var node: Node2D = layout_element.node as Node2D
		var input_controller: InputController = node.get_node_or_null("InputController") as InputController
		if input_controller != null:
			input_state.add_input_controller(input_controller)
	input_state.on_hover_changed.connect(handle_hover_changed)
	for layout_element in layout_elements_2:
		print("Adding layout element 2: ", layout_element.name)
		layout_container_2.add(layout_element)
		
	input_state.on_untargeted_drag.connect(camera_transform_controller.handle_mouse_motion)
#		var node: Node2D = layout_element.node as Node2D
#		var input_controller: InputController = node.get_node_or_null("InputController") as InputController
#		if input_controller != null:
#			input_state.add_input_controller(input_controller)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("mouse_left"):
		layout_container.update_layout()
		layout_container_2.update_layout()
		
		
func handle_hover_changed(from: InputController, to: InputController) -> void:
	if from != null:
		var from_layout_element: LayoutElement = from.node.get_node_or_null("LayoutElement") as LayoutElement
		if from_layout_element != null and layout_elements.has(from_layout_element):
			layout_container.update_layout()
	if to != null:
		var to_layout_element: LayoutElement = to.node.get_node_or_null("LayoutElement") as LayoutElement
		if to_layout_element != null and layout_elements.has(to_layout_element):
			layout_container.update_layout()
