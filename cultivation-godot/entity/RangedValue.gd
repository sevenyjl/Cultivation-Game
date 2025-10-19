class_name RangedValue extends GrowthBase

# 范围值类，用于处理具有最小值和最大值的属性
# 支持随机成长机制

var min_value: float  # 最小值
var max_value: float  # 最大值
var update_min_value: bool = false  # 是否更新最小值

# 成长方法
func grow() -> void:
	# 调用父类方法更新成长因子
	super.grow()
	
	# 根据新的成长范围增加属性值
	var growth_amount = randf_range(min_growth, max_growth)
	if update_min_value:
		var tempData=randf_range(0, growth_amount/2)
		min_value = roundf((min_value + tempData) * 100) / 100
		max_value = roundf((max_value + growth_amount - tempData) * 100) / 100
	else:
		max_value = roundf((max_value + growth_amount) * 100) / 100
	
	# 更新当前值（按比例增长）
	var ratio = current_value / (max_value - growth_amount) if (max_value - growth_amount) != 0 else 1
	current_value = roundf((max_value * ratio) * 100) / 100
