extends Node2D
class_name CameraTransformController


@export var region: Area2D
@export var region_shape: CollisionShape2D
@export var drag_button: MouseButton = MouseButton.MOUSE_BUTTON_LEFT
var camera: Camera2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	camera = get_parent() as Camera2D
	align_with_region_top_left()
	assert(camera != null, "CameraTransformController must be a child of a Camera2D node")
	
	
func handle_mouse_motion(button_mask: MouseButtonMask, mouse_relative: Vector2, _mouse_position: Vector2):
	if drag_button & button_mask:
		move_in_region(-mouse_relative * camera.zoom)

		
func align_with_region_top_left() -> void:	
	var region_shape_rect: RectangleShape2D = region_shape.shape as RectangleShape2D
	if region_shape_rect == null or region_shape_rect is not RectangleShape2D:
		return
	var aabb: Rect2 = Rect2(region.global_position - region_shape_rect.extents, region_shape_rect.extents * 2.0)
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	var half_view: Vector2 = viewport_size * 0.5 / camera.zoom
	camera.global_position = aabb.position + half_view

	
func move_in_region(distance: Vector2) -> void:
	var new_position: Vector2 = camera.global_position + distance
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	var half_view: Vector2 = viewport_size * 0.5 / camera.zoom
	var region_shape_rect: RectangleShape2D = region_shape.shape as RectangleShape2D
	if region_shape_rect == null or region_shape_rect is not RectangleShape2D:
		camera.global_position = new_position
		return
	var aabb: Rect2 = Rect2(region.global_position - region_shape_rect.extents, region_shape_rect.extents * 2.0)
	var min_x = aabb.position.x + half_view.x
	var max_x = aabb.position.x + aabb.size.x - half_view.x
	var min_y = aabb.position.y + half_view.y
	var max_y = aabb.position.y + aabb.size.y - half_view.y
	if min_x > max_x:
		new_position.x = aabb.position.x + aabb.size.x * 0.5
	else:
		new_position.x = clamp(new_position.x, min_x, max_x)
	if min_y > max_y:
		new_position.y = aabb.position.y + aabb.size.y * 0.5
	else:
		new_position.y = clamp(new_position.y, min_y, max_y)
	camera.global_position = new_position