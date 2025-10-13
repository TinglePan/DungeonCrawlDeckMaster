extends Node2D

@export var control: TransformControl
var step: int
#var has_started: bool = false
#var test_value: float = 0.0
#var test_value_velocity: float = 0.0
#var start_time: int


# Called when the node enters the scene tree for the first time.
func _ready():
#	start_time = Time.get_ticks_msec()
#	step = 0
	step = 9


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
#	var res = copied_smooth_damp(test_value, 100.0, test_value_velocity, 1, INF, _delta)
#	test_value = res[0]
#	test_value_velocity = res[1]
#	if Utils.get_magnitude(test_value - 100.0) < Constants.EPSILON and Utils.get_magnitude(test_value_velocity) < Constants.EPSILON:
#		test_value = 100.0
#		test_value_velocity = 0.0
#		print("Done in ", Time.get_ticks_msec() - start_time, " ms")
	if Input.is_action_just_pressed("mouse_left"):
		var node_global_position: Vector2 = control.node.global_position
		var start_time: int = Time.get_ticks_msec()
		match step:
			0:
				control.start_move(node_global_position + Vector2(100, 100), ChangeValue.ChangeType.SMOOTH_DAMP, 0.5)
			1:
				control.start_move(node_global_position - Vector2(200, 200), ChangeValue.ChangeType.LINEAR, 0.5)
			2:
				control.start_move(node_global_position + Vector2(100, 100), ChangeValue.ChangeType.NONE, 0.5)
			3:
				control.start_rotate(30.0 / 360 * TAU, ChangeValue.ChangeType.SMOOTH_DAMP, 0.5)
			4:
				control.start_rotate(-60.0 / 360 * TAU, ChangeValue.ChangeType.LINEAR, 0.5)
			5:
				control.start_rotate(0, ChangeValue.ChangeType.NONE, 0.5)
			6:
				control.start_scale(control.node.scale * 2, ChangeValue.ChangeType.SMOOTH_DAMP, 0.5)
			7:
				control.start_scale(control.node.scale * 2, ChangeValue.ChangeType.LINEAR, 0.5)
			8:
				control.start_scale(control.node.scale * 0.25, ChangeValue.ChangeType.NONE, 0.5)
			_:
				control.start_juice(30.0 / 360 * TAU, Vector2(0.5, 0.5), 0.5)
		await control.wait_for_stop()
		print("Move took ", Time.get_ticks_msec() - start_time, " ms")
		step += 1

	
#func copied_smooth_damp(current: float, target: float, currentVelocity: float, smoothTime: float, maxSpeed: float, deltaTime: float) -> Array:
#	smoothTime = max(0.0001, smoothTime)
#	var num: float = 2.0 / smoothTime;
#	var num2: float = num * deltaTime;
#	var num3: float = 1.0 / (1.0 + num2 + 0.48 * num2 * num2 + 0.235 * num2 * num2 * num2);
#	var num4: float = current - target;
#	var num5: float = target;
#	var num6: float = maxSpeed * smoothTime;
#	num4 = clamp(num4, -num6, num6);
#	target = current - num4;
#	var num7: float = (currentVelocity + num * num4) * deltaTime;
#	currentVelocity = (currentVelocity - num * num7) * num3;
#	var num8: float = target + (num4 + num7) * num3
#	if (num5 - current > 0) == (num8 > num5):
#		num8 = num5
#		currentVelocity = (num8 - num5) / deltaTime
#	return [num8, currentVelocity]
