class_name CombatCultivation extends BaseCultivation

# 战斗修仙者类
# 继承自基础修仙者，添加战斗相关属性和方法

# 攻击力系统（使用范围值类管理，支持随机取值）
var attack_stats: RangedValue

func _init() -> void:
	super()  # 调用父类初始化
	if attack_stats == null:
		attack_stats = RangedValue.new(5, 15, 10, 5, 15, 8)  # 初始攻击力范围5-15

# 获取攻击力（随机值，在最小值和最大值之间）
func get_attack() -> float:
	if attack_stats != null:
		return attack_stats.get_random_value()
	return 10

# 获取攻击力最小值
func get_min_attack() -> float:
	if attack_stats != null:
		return attack_stats.min_value
	return 5

# 获取攻击力最大值
func get_max_attack() -> float:
	if attack_stats != null:
		return attack_stats.max_value
	return 15

# 升级 - 重写父类方法
func level_up():
	super()  # 调用父类升级逻辑
	
	# 如果没有突破境界（父类方法没有提前返回），添加攻击力成长
	if attack_stats != null:
		attack_stats.grow()

# 突破境界 - 重写父类方法
func breakthrough_realm():
	if realm < CultivationRealm.DUDIE:
		# 先记录原始突破倍数
		var breakthrough_multiplier = get_breakthrough_multiplier()
		
		# 调用父类突破逻辑
		super()
		
		# 添加攻击力大幅提升
		if attack_stats != null:
			for i in range(10 * breakthrough_multiplier):
				attack_stats.grow()