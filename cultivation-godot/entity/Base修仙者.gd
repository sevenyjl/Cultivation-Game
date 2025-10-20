extends Node
class_name BaseCultivation

# 引入成长相关类

# 修仙者基础类
# 包含所有修仙者的基本属性和方法

# 基础属性
@export var id: String = ""
@export var name_str: String = "未命名修仙者"
@export var level: int = 1  # 修炼等级
@export var experience: int = 0  # 经验值

# 生命值系统（使用范围值类管理）
var hp_stats: RangedValue

# 速度系统（使用固定值类管理）
var speed_stats: RandomValue

# 攻击力
var attack_stats: RandomValue

# 防御力
var defense_stats: RandomValue

# 修炼境界
enum CultivationRealm {
	FANREN,      # 凡人
	LIANQI,      # 炼气期
	ZHUJI,       # 筑基期
	JINDAN,      # 金丹期
	YUANYING,    # 元婴期
	HUASHEN,     # 化神期
	LIANXU,      # 炼虚期
	HEHE,        # 合体期
	DACHENG,     # 大乘期
	DUDIE        # 渡劫期
}

# 移除了直接的realm属性，改为通过等级动态计算

signal 死亡(攻击角色:BaseCultivation,死亡角色:BaseCultivation)

func _init() -> void:
	if hp_stats == null:
		hp_stats = RangedValue.new()
		hp_stats.min_value = 0
		hp_stats.max_value = 100
		hp_stats.current_value = 100
		hp_stats.min_growth = 20
		hp_stats.max_growth = 50
		hp_stats.growth_factor = 10
	if speed_stats == null:
		speed_stats = RandomValue.new()
		speed_stats.min_value = 10
		speed_stats.max_value = 15
		speed_stats.min_growth = 5
		speed_stats.max_growth = 10
		speed_stats.growth_factor = 5
	if attack_stats == null:
		attack_stats = RandomValue.new()
		attack_stats.min_value = 20
		attack_stats.max_value = 30
		attack_stats.min_growth = 5
		attack_stats.max_growth = 10
		attack_stats.growth_factor = 5
	if defense_stats == null:
		defense_stats = RandomValue.new()
		defense_stats.min_value = 0
		defense_stats.max_value = 10
		defense_stats.min_growth = 1
		defense_stats.max_growth = 3
		defense_stats.growth_factor = 2

# 根据等级获取当前境界
func get_current_realm() -> CultivationRealm:
	if level < 10:
		return CultivationRealm.FANREN
	elif level < 20:
		return CultivationRealm.LIANQI
	elif level < 35:
		return CultivationRealm.ZHUJI
	elif level < 50:
		return CultivationRealm.JINDAN
	elif level < 70:
		return CultivationRealm.YUANYING
	elif level < 90:
		return CultivationRealm.HUASHEN
	elif level < 110:
		return CultivationRealm.LIANXU
	elif level < 130:
		return CultivationRealm.HEHE
	elif level < 150:
		return CultivationRealm.DACHENG
	else:
		return CultivationRealm.DUDIE

# 获取境界内的层数
func get_realm_level() -> int:
	var current_realm = get_current_realm()
	var start_level = get_required_level_for_realm(current_realm)
	
	# 对于凡人，层数从1开始计算
	if current_realm == CultivationRealm.FANREN:
		return level
	else:
		# 其他境界，层数从1开始计算
		return level - start_level + 1

# 获取境界名称
func get_realm_name() -> String:
	return get_realm_name_by_realm(get_current_realm())

# 根据境界枚举获取对应的境界名称
func get_realm_name_by_realm(target_realm: CultivationRealm) -> String:
	match target_realm:
		CultivationRealm.FANREN:
			return "凡人"
		CultivationRealm.LIANQI:
			return "炼气期"
		CultivationRealm.ZHUJI:
			return "筑基期"
		CultivationRealm.JINDAN:
			return "金丹期"
		CultivationRealm.YUANYING:
			return "元婴期"
		CultivationRealm.HUASHEN:
			return "化神期"
		CultivationRealm.LIANXU:
			return "炼虚期"
		CultivationRealm.HEHE:
			return "合体期"
		CultivationRealm.DACHENG:
			return "大乘期"
		CultivationRealm.DUDIE:
			return "渡劫期"
		_:
			return "未知境界"

# 获取完整的境界显示名称（包含层数）
func get_full_realm_name() -> String:
	var current_realm = get_current_realm()
	var realm_level = get_realm_level()
	
	# 凡人也显示层数
	return get_realm_name_by_realm(current_realm) + "第" + str(realm_level) + "层"

# 升级
func level_up():
	level += 1
	experience = 0
	
	# 检查是否刚刚突破了境界
	var previous_realm = get_realm_by_level(level - 1)
	var current_realm = get_current_realm()
	
	if previous_realm != current_realm:
		# 境界突破，执行突破逻辑
		_on_realm_breakthrough(previous_realm, current_realm)
	else:
		# 境界内升级
		# 境界内升级时小幅提升属性
		hp_stats.grow()  # 生命值随机成长
		speed_stats.grow()  # 速度随机成长
		attack_stats.grow()  # 攻击力随机成长
		defense_stats.grow()  # 防御力随机成长
		
		# 生命值恢复到最大
		hp_stats.current_value = hp_stats.max_value
	
	print(name_str + " 修炼到 " + get_full_realm_name() + "！")


# 根据等级获取对应的境界
func get_realm_by_level(target_level: int) -> CultivationRealm:
	if target_level < 10:
		return CultivationRealm.FANREN
	elif target_level < 20:
		return CultivationRealm.LIANQI
	elif target_level < 35:
		return CultivationRealm.ZHUJI
	elif target_level < 50:
		return CultivationRealm.JINDAN
	elif target_level < 70:
		return CultivationRealm.YUANYING
	elif target_level < 90:
		return CultivationRealm.HUASHEN
	elif target_level < 110:
		return CultivationRealm.LIANXU
	elif target_level < 130:
		return CultivationRealm.HEHE
	elif target_level < 150:
		return CultivationRealm.DACHENG
	else:
		return CultivationRealm.DUDIE

# 境界突破处理
func _on_realm_breakthrough(old_realm: CultivationRealm, new_realm: CultivationRealm):
	print(name_str + " 从 " + get_realm_name_by_realm(old_realm) + " 突破到 " + get_full_realm_name() + "！")
	
	# 境界突破时大幅提升属性（比升级提升更多）
	var breakthrough_multiplier = get_breakthrough_multiplier(new_realm)
	# 使用新的生命值系统
	for i in range(int(15 * breakthrough_multiplier)):
		hp_stats.grow()
	# 额外多次成长
	for i in range(int(3 * breakthrough_multiplier)):
		speed_stats.grow()
	for i in range(int(3 * breakthrough_multiplier)):
		attack_stats.grow()
	for i in range(int(breakthrough_multiplier)):
		defense_stats.grow()
	# 生命值恢复到最大
	hp_stats.current_value = hp_stats.max_value
	print("境界突破！属性大幅提升！")

# 获取境界对应的等级要求
func get_required_level_for_realm(target_realm: CultivationRealm) -> int:
	match target_realm:
		CultivationRealm.FANREN:
			return 1
		CultivationRealm.LIANQI:
			return 10    # 炼气期需要10级
		CultivationRealm.ZHUJI:
			return 20    # 筑基期需要20级
		CultivationRealm.JINDAN:
			return 35    # 金丹期需要35级
		CultivationRealm.YUANYING:
			return 50    # 元婴期需要50级
		CultivationRealm.HUASHEN:
			return 70    # 化神期需要70级
		CultivationRealm.LIANXU:
			return 90    # 炼虚期需要90级
		CultivationRealm.HEHE:
			return 110   # 合体期需要110级
		CultivationRealm.DACHENG:
			return 130   # 大乘期需要130级
		CultivationRealm.DUDIE:
			return 150   # 渡劫期需要150级
		_:
			return 999

# breakthrough_realm()方法已移除，境界突破现在通过升级时自动检测和处理

# 获取境界突破的属性提升倍数
func get_breakthrough_multiplier(target_realm: CultivationRealm) -> float:
	match target_realm:
		CultivationRealm.LIANQI:
			return 1.0    # 炼气期突破，基础倍数
		CultivationRealm.ZHUJI:
			return 1.2    # 筑基期突破，1.2倍
		CultivationRealm.JINDAN:
			return 1.5    # 金丹期突破，1.5倍
		CultivationRealm.YUANYING:
			return 2.0    # 元婴期突破，2倍
		CultivationRealm.HUASHEN:
			return 2.5    # 化神期突破，2.5倍
		CultivationRealm.LIANXU:
			return 3.0    # 炼虚期突破，3倍
		CultivationRealm.HEHE:
			return 3.5    # 合体期突破，3.5倍
		CultivationRealm.DACHENG:
			return 4.0    # 大乘期突破，4倍
		CultivationRealm.DUDIE:
			return 5.0    # 渡劫期突破，5倍
		_:
			return 1.0

static func 随机生成修仙者()->BaseCultivation:
	return null

#region 属性变化方法
func 应用伤害(damage: float,造成角色:BaseCultivation):
	# 应用伤害到目标
	hp_stats.current_value=(hp_stats.get_current_value() - damage)
	if !是否存活():
		死亡.emit(造成角色,self)


#endregion 属性变化方法
#region 相关判断方法
# 检查是否存活
func 是否存活() -> bool:
	return hp_stats.get_current_value() > 0
#endregion 相关判断方法
