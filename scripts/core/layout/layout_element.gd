extends Node2D
class_name LayoutElement


@export var node: Node2D
@export var collision_shape: CollisionShape2D


func size() -> Vector2:
	if collision_shape == null:
		return Vector2.ZERO
	var shape: Shape2D = collision_shape.shape
	if shape is RectangleShape2D:
		var rect_shape: RectangleShape2D = shape as RectangleShape2D
		return rect_shape.extents * 2.0
	return Vector2.ZERO

	
func adjust_position(_position: Vector2) -> void:
	var transform_controller: TransformController = node.get_node_or_null("TransformController") as TransformController
	if transform_controller != null:
		transform_controller.start_move(_position, ChangeValue.ChangeType.SMOOTH_DAMP, Constants.DEFAULT_SMOOTH_TIME)
	else:
		node.global_position = _position
