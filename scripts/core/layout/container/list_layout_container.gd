extends BaseLayoutContainer
class_name ListLayoutContainer


enum Direction {
	HORIZONTAL,
	VERTICAL
}

@export var direction: Direction = Direction.HORIZONTAL
@export var reference_area: Area2D
@export var reference_area_shape: CollisionShape2D
@export var gap: float = 12.0
@export var margin: float = 0.0
@export var hover_extrude_factor: float = 0.3  # Factor to extrude the hovered element (0.0 - no extrude, 1.0 - extrude by element size)


func update_layout() -> void:
	var n_elements: int = content_elements.size()
	if n_elements == 0:
		return
	var reference_area_size: Vector2 = reference_area_shape.shape.extents * 2.0
	var element_size: Vector2 = content_elements[0].size()
	var real_gap: float = 0.0
	var input_state = g_input_mgr.current_input_state()
	var is_after_hovered_element: bool = false
	if direction == Direction.HORIZONTAL:
		var left_center_global_position: Vector2 = Vector2(reference_area.global_position.x - reference_area_shape.shape.extents.x, reference_area.global_position.y)
		real_gap = min(gap, (reference_area_size.x - 2 * margin - element_size.x * n_elements) / (n_elements - 1))
		var i: int = 0
		for content_element in content_elements:
			var element_global_position: Vector2 = Vector2(left_center_global_position.x + margin + element_size.x / 2.0 + (element_size.x + real_gap) * i, left_center_global_position.y)
			if is_after_hovered_element and real_gap < 0.0:
				element_global_position.x += -real_gap
			if input_state.hovering_controller != null and input_state.hovering_controller.node == content_element.node:
				is_after_hovered_element = true
				element_global_position.y -= hover_extrude_factor * element_size.y
			content_element.adjust_position(element_global_position)
			i += 1
	else:
		var top_center_global_position: Vector2 = Vector2(reference_area.global_position.x, reference_area.global_position.y - reference_area_shape.shape.extents.y)
		real_gap = min(gap, (reference_area_size.y - 2 * margin - element_size.y * n_elements) / (n_elements - 1))
		var i: int = 0
		for content_element in content_elements:
			var element_global_position: Vector2 = Vector2(top_center_global_position.x, top_center_global_position.y + margin + element_size.y / 2.0 + (element_size.y + real_gap) * i)
			if is_after_hovered_element and real_gap < 0.0:
				element_global_position.y += real_gap + element_size.y
			if input_state.hovering_control.node == content_element.node:
				is_after_hovered_element = true
				element_global_position.x += hover_extrude_factor * element_size.x
			content_element.adjust_position(element_global_position)
			i += 1
