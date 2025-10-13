extends RefCounted
class_name MouseButtonState


enum NOTIFICATION {
	CLICK,
	DOUBLE_CLICK,
	HOLD,
	DRAG_END
}

var last_down_position: Vector2 = Vector2.ZERO
var last_down_time: int = 0
var last_click_position: Vector2 = Vector2.ZERO
var last_click_time: int = 0

func _init():
	last_down_position = Vector2.ZERO
	last_down_time = 0
	last_click_time = 0
	
	
func down(position: Vector2, time: int) -> void:
	last_down_position = position
	last_down_time = time
	
	
func up(position: Vector2, time: int) -> NOTIFICATION:
	var down_time_elapsed: int = time - last_down_time
	var click_time_elapsed: int = time - last_click_time
	var down_distance: float = position.distance_to(last_down_position)
	var click_distance: float = position.distance_to(last_click_position)
	if down_time_elapsed < Constants.MOUSE_CLICK_THRESHOLD and down_distance < Constants.MOUSE_CLICK_DISTANCE_THRESHOLD:
		last_click_time = time
		last_click_position = position
		if click_time_elapsed < Constants.MOUSE_DOUBLE_CLICK_THRESHOLD and click_distance < Constants.MOUSE_CLICK_DISTANCE_THRESHOLD:
			# Double click
			return NOTIFICATION.DOUBLE_CLICK
		else:
			# Single click
			return NOTIFICATION.CLICK
	else:
		# Drag end
		return NOTIFICATION.DRAG_END
		
		
func is_holding(time: int) -> bool:
	var down_time_elapsed: int = time - last_down_time
	return down_time_elapsed >= Constants.MOUSE_CLICK_THRESHOLD
	