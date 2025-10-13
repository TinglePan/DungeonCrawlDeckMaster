extends Object
class_name Utils


# Standard smooth damp function adapted from Unity
static func smooth_damp(current: float, target: float, current_velocity: float, smooth_time: float, damp_ratio: float = 1.0, max_speed: float = INF, delta: float = 0.016) -> Array:
	smooth_time = max(0.0001, smooth_time) * Constants.SMOOTH_TIME_MOD
	var omega: float = (2.0 * damp_ratio) / smooth_time
	var x: float = omega * delta
	var e: float = 1.0 / (1.0 + x + 0.48 * x * x + 0.235 * x * x * x)
	var change: float = current - target
	var record_target: float = target
	var change_limit: float = max_speed * smooth_time
	change = clamp(change, -change_limit, change_limit)
	target = current - change
	var temp: float = (current_velocity + omega * change) * delta
	current_velocity = (current_velocity - omega * temp) * e
	var output: float = target + (change + temp) * e
	if (record_target - current > 0.0) == (output > record_target):
		output = record_target
		current_velocity = (output - record_target) / delta
	return [output, current_velocity]
	
	
static func smooth_damp_variant(current: Variant, target: Variant, current_velocity: Variant, smooth_time: float, damp_ratio: float = 1.0, max_speed: float = INF, delta: float = 0.016) -> Array:
	match typeof(current):
		TYPE_INT:
			var result: Array = smooth_damp(float(current), float(target), float(current_velocity), smooth_time, damp_ratio, max_speed, delta)
			return [int(result[0]), result[1]]
		TYPE_FLOAT:
			return smooth_damp(current, target, current_velocity, smooth_time, damp_ratio, max_speed, delta)
		TYPE_VECTOR2:
			var result_x: Array = smooth_damp(current.x, target.x, current_velocity.x, smooth_time, damp_ratio, max_speed, delta)
			var result_y: Array = smooth_damp(current.y, target.y, current_velocity.y, smooth_time, damp_ratio, max_speed, delta)
			return [Vector2(result_x[0], result_y[0]), Vector2(result_x[1], result_y[1])]
		TYPE_VECTOR3:
			var result_x: Array = smooth_damp(current.x, target.x, current_velocity.x, smooth_time, damp_ratio, max_speed, delta)
			var result_y: Array = smooth_damp(current.y, target.y, current_velocity.y, smooth_time, damp_ratio, max_speed, delta)
			var result_z: Array = smooth_damp(current.z, target.z, current_velocity.z, smooth_time, damp_ratio, max_speed, delta)
			return [Vector3(result_x[0], result_y[0], result_z[0]), Vector3(result_x[1], result_y[1], result_z[1])]
		TYPE_VECTOR2I:
			var result: Array = smooth_damp_variant(Vector2(current), Vector2(target), Vector2(current_velocity), smooth_time, damp_ratio, max_speed, delta)
			return [Vector2i(result[0]), Vector2i(result[1])]
		TYPE_VECTOR3I:
			var result: Array = smooth_damp_variant(Vector3(current), Vector3(target), Vector3(current_velocity), smooth_time, damp_ratio, max_speed, delta)
			return [Vector3i(result[0]), Vector3i(result[1])]
		_:
			push_error("Unsupported type for smooth_damp_variant")
			return [current, current_velocity]


static func get_magnitude(x: Variant) -> Variant:
	match typeof(x):
		TYPE_INT:
			return abs(x)
		TYPE_FLOAT:
			return abs(x)
		TYPE_VECTOR2:
			return x.length()
		TYPE_VECTOR3:
			return x.length()
		TYPE_VECTOR2I:
			return x.length()
		TYPE_VECTOR3I:
			return x.length()
		_:
			return null
	
			
static func insert_sorted(arr: Array, value: Variant, cmp_func: Callable) -> void:
	var index: int = 0
	while index < arr.size() and cmp_func.call(value, arr[index]) > 0:
		index += 1
	arr.insert(index, value)
