class_name FixedValue extends GrowthBase

# 固定值类，用于处理单一的数值型属性
# 支持随机成长机制，但只有一个固定值而不是范围

var value: float  # 当前值

func _init(initial_value: float = 10.0, min_growth_val: float = 20.0, max_growth_val: float = 50.0, growth_fact: float = 10.0):
	super(min_growth_val, max_growth_val, growth_fact)
	value = roundf(initial_value * 100) / 100

# 获取当前值
func get_value() -> float:
	return value

# 设置当前值
func set_value(new_value: float):
	value = roundf(new_value * 100) / 100

# 重写成长方法
func grow() -> void:
	# 调用父类方法更新成长因子
	super.grow()
	
	# 根据成长范围增加属性值
	var growth_amount = randf_range(min_growth, max_growth)
	
	# 更新当前值
	value = roundf((value + growth_amount) * 100) / 100

# 获取值信息
func get_info() -> Dictionary:
	var base_info = get_growth_info()
	base_info["value"] = value
	return base_info
