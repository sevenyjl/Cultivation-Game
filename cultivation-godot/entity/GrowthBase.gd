class_name GrowthBase extends RefCounted

# 成长基类，用于处理具有成长机制的值类型
# 所有需要成长机制的值类都应继承此类

# 成长因子系统
var min_growth: float  # 最小成长值
var max_growth: float  # 最大成长值
var growth_factor: float  # 成长因子

func _init(min_growth_val: float = 20.0, max_growth_val: float = 50.0, growth_fact: float = 10.0):
	min_growth = roundf(min_growth_val * 100) / 100
	max_growth = roundf(max_growth_val * 100) / 100
	growth_factor = roundf(growth_fact * 100) / 100

# 成长方法（需要子类实现具体逻辑）
func grow() -> void:
	# 生成随机数：0 到 成长因子的一半
	var random_factor = randf_range(0, growth_factor / 2)
	
	# 更新成长范围
	min_growth = roundf((min_growth + random_factor) * 100) / 100
	max_growth = roundf((max_growth + (growth_factor - random_factor)) * 100) / 100

# 获取成长信息
func get_growth_info() -> Dictionary:
	return {
		"min_growth": min_growth,
		"max_growth": max_growth,
		"growth_factor": growth_factor
	}
