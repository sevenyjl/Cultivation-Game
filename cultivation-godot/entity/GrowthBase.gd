class_name GrowthBase extends Node

# 成长基类，用于处理具有成长机制的值类型
# 所有需要成长机制的值类都应继承此类

# 成长因子系统
var min_growth: float  # 最小成长值
var max_growth: float  # 最大成长值
var growth_factor: float  # 成长因子
var current_value:float  # 当前值

func get_current_value() -> float:
	return current_value

# 成长因子成长
func grow_factor_grow():
	growth_factor += randf_range(0, growth_factor)

# 成长方法（需要子类实现具体逻辑）
func grow() -> void:
	# 生成随机数：0 到 成长因子的一半
	var random_factor = randf_range(0, growth_factor / 2)

	# 更新成长范围，考虑负数情况
	# 如果min_growth小于0（不管max_growth是多少），则视为需要减小的值
	if min_growth < 0:
		# 向负数方向成长（减小值）
		min_growth = roundf((min_growth - (growth_factor - random_factor)) * 100) / 100
		max_growth = roundf((max_growth - random_factor) * 100) / 100
	else:
		# 正常情况，向正数方向成长
		min_growth = roundf((min_growth + random_factor) * 100) / 100
		max_growth = roundf((max_growth + (growth_factor - random_factor)) * 100) / 100
