class_name FixedValue extends GrowthBase

# 固定值类，用于处理单一的数值型属性
# 支持随机成长机制，但只有一个固定值而不是范围

# 重写成长方法
func grow() -> void:
	# 调用父类方法更新成长因子
	super.grow()
	# 根据成长范围增加属性值
	var growth_amount = randf_range(min_growth, max_growth)
	# 更新当前值
	current_value = roundf((current_value + growth_amount) * 100) / 100
