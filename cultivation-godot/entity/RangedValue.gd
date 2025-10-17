class_name RangedValue extends GrowthBase

# 范围值类，用于处理具有最小值和最大值的属性
# 支持随机成长机制

var min_value: float  # 最小值
var max_value: float  # 最大值
var current_value: float  # 当前值

func _init(min_val: float = 0.0, max_val: float = 100.0, current_val: float = 100.0,
	   min_growth_val: float = 20.0, max_growth_val: float = 50.0, growth_fact: float = 10.0):
	super(min_growth_val, max_growth_val, growth_fact)
	min_value = roundf(min_val * 100) / 100
	max_value = roundf(max_val * 100) / 100
	current_value = roundf(current_val * 100) / 100

# 获取当前值
func get_value() -> float:
	return current_value

# 设置当前值（保持在min和max之间）
func set_value(value: float):
	current_value = clamp(roundf(value * 100) / 100, min_value, max_value)

# 成长方法
func grow() -> void:
	# 调用父类方法更新成长因子
	super.grow()
	
	# 根据新的成长范围增加属性值
	var growth_amount = randf_range(min_growth, max_growth)
	
	# 更新值范围
	min_value = roundf((min_value + growth_amount) * 100) / 100
	max_value = roundf((max_value + growth_amount) * 100) / 100
	
	# 更新当前值（按比例增长）
	var ratio = current_value / (max_value - growth_amount) if (max_value - growth_amount) != 0 else 1
	current_value = roundf((max_value * ratio) * 100) / 100

# 获取范围信息
func get_range_info() -> Dictionary:
	var base_info = get_growth_info()
	base_info["min"] = min_value
	base_info["max"] = max_value
	base_info["current"] = current_value
	return base_info
