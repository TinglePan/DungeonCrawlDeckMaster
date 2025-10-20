extends RefCounted
class_name ChangeValue


enum ChangeType {
	NONE,
	LINEAR,
	SMOOTH_DAMP
}

var current_value: Variant
var target_value: Variant
var mod_target_value: Variant
var velocity: Variant
var change_type: ChangeType
var change_time: float
var progress_time: float

signal on_stop_change


func _init(init_value: Variant) -> void:
	current_value = init_value
	target_value = init_value
	progress_time = 0.0
	mod_target_value = zero()
	velocity = zero()
	
	
func zero() -> Variant:
	match typeof(current_value):
		TYPE_INT:
			return 0
		TYPE_FLOAT:
			return 0.0
		TYPE_VECTOR2I:
			return Vector2i.ZERO
		TYPE_VECTOR3I:
			return Vector3i.ZERO
		TYPE_VECTOR2:
			return Vector2.ZERO
		TYPE_VECTOR3:
			return Vector3.ZERO
		_:
			return null
			
			
func is_changing() -> bool:
	var actual_target_value = target_value + mod_target_value
	return Utils.get_magnitude(current_value - actual_target_value) > Constants.EPSILON_2D_MOVE or Utils.get_magnitude(velocity) > Constants.EPSILON_2D_MOVE
	
	
func start_change(_target_value: Variant, _change_type: ChangeType, _change_time: float, _mod_target_value: Variant = zero()) -> void:
	target_value = _target_value
	mod_target_value = _mod_target_value
	change_type = _change_type
	change_time = _change_time
	progress_time = 0.0
	if change_time <= 0.0:
		change_time = 0.0
		change_type = ChangeType.NONE
	on_actual_target_value_changed()
			
		
func update_mod_target_value(mod: Variant) -> void:
	mod_target_value = mod
	on_actual_target_value_changed()
	
	
func on_actual_target_value_changed():
	var actual_target_value = target_value + mod_target_value
	match change_type:
		ChangeType.LINEAR:
			var start_value = current_value
			var distance = actual_target_value - start_value
			velocity = distance / change_time
		_:
			pass
	
	
func update(delta: float) -> void:
	var actual_target_value = target_value + mod_target_value
	progress_time += delta
	match change_type:
		ChangeType.NONE:
			progress_time = change_time
			current_value = actual_target_value
			velocity = zero()
			on_stop_change.emit()
		ChangeType.LINEAR:
			var new_value = current_value + velocity * delta
			if Utils.get_magnitude(new_value - actual_target_value) < Constants.EPSILON_2D_MOVE or progress_time >= change_time:
				new_value = actual_target_value
				velocity = zero()
				on_stop_change.emit()
			current_value = new_value
		ChangeType.SMOOTH_DAMP:
			var result: Array = Utils.smooth_damp_variant(current_value, actual_target_value, velocity, change_time, Constants.DEFAULT_DAMP_RATIO, INF, delta)
			var new_value = result[0]
			var new_velocity = result[1]
			if Utils.get_magnitude(new_value - actual_target_value) <= Constants.EPSILON_2D_MOVE and Utils.get_magnitude(new_velocity) <= Constants.EPSILON_2D_MOVE or progress_time >= change_time:
				new_value = actual_target_value
				new_velocity = zero()
				on_stop_change.emit()
			current_value = new_value
			velocity = new_velocity
			
