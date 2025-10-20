extends BaseLayoutContainer
class_name GridLayoutContainer


@export var n_columns: int = 2
@export var h_gap: float = 12.0
@export var v_gap: float = 18.0
@export var reference_area: Area2D
@export var reference_area_shape: CollisionShape2D


func update_layout() -> void:
	var n_elements: int = content_elements.size()
	if n_elements == 0:
		return
	var element_size: Vector2 = content_elements[0].size()
	var start_global_position: Vector2 = Vector2(reference_area.global_position.x, reference_area.global_position.y - reference_area_shape.shape.extents.y)
	var i: int = 0
	for content_element in content_elements:
		# warning-ignore:integer_division
		var row_index: int = int(i / n_columns)
		var column_index: int = i % n_columns
		var element_global_position: Vector2 = Vector2(start_global_position.x + (element_size.x + h_gap) * (column_index - (n_columns - 1.0) / 2), start_global_position.y + (element_size.y + v_gap) * row_index + element_size.y / 2.0)
		content_element.adjust_position(element_global_position)
		i += 1
