class_name RandomValue extends RangedValue

func _init() -> void:
	update_min_value = true

func get_current_value() -> float:
	return randf_range(min_value, max_value)
