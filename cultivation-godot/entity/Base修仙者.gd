extends Node
class_name BaseCultivation

# 引入成长相关类

# 修仙者基础类
# 包含所有修仙者的基本属性和方法

# 基础属性
@export var id: String = ""
@export var name_str: String = "未命名修仙者"
@export var level: int = 1  # 修炼等级

# 灵气系统（使用范围值类管理）
var spiritual_energy: RangedValue

# 灵气吸收速度（使用随机值类管理，表示每次吸收的灵气范围）
var absorption_rate: RandomValue

# 灵气吸收冷却时间（使用随机值类管理，表示吸收间隔的时间范围，单位：秒）
var absorption_cooldown: RandomValue


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
	
	# 初始化灵气系统
	if spiritual_energy == null:
		spiritual_energy = RangedValue.new()
		spiritual_energy.min_value = 0
		# 初始最大灵气设置为升级所需值
		spiritual_energy.max_value = 100
		spiritual_energy.min_growth = 10
		spiritual_energy.max_growth = 100
		spiritual_energy.growth_factor = 100
		spiritual_energy.current_value = 0
	# 初始化灵气吸收速度
	if absorption_rate == null:
		absorption_rate = RandomValue.new()
		absorption_rate.min_value = 5
		absorption_rate.max_value = 15
		absorption_rate.min_growth = 1
		absorption_rate.max_growth = 3
		absorption_rate.growth_factor = 2
	
	# 初始化灵气吸收冷却时间
	if absorption_cooldown == null:
		absorption_cooldown = RandomValue.new()
		absorption_cooldown.min_value = 10.0
		absorption_cooldown.max_value = 30.0
		# 注意：冷却时间的成长应该是减少的，所以使用负数
		absorption_cooldown.min_growth = -0.1
		absorption_cooldown.max_growth = 0
		absorption_cooldown.growth_factor = 1
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

func _获取成长属性列表() -> Array:
	return [hp_stats, spiritual_energy, absorption_rate, absorption_cooldown, speed_stats, attack_stats, defense_stats]

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
	# 检查是否刚刚突破了境界
	var previous_realm = get_realm_by_level(level - 1)
	var current_realm = get_current_realm()
	
	if previous_realm != current_realm:
		# 境界突破，执行突破逻辑
		_on_realm_breakthrough(previous_realm, current_realm)
	for i in _获取成长属性列表():
		i.grow()
	# 灵气归零
	spiritual_energy.current_value=0
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

# 境界突破处理(提升成长因子)
func _on_realm_breakthrough(old_realm: CultivationRealm, new_realm: CultivationRealm):
	print(name_str + " 从 " + get_realm_name_by_realm(old_realm) + " 突破到 " + get_full_realm_name() + "！")
	# 提升成长因子
	for i in _获取成长属性列表():
		i.grow_factor_grow()
		i.grow()

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

#region 属性变化方法
func 应用伤害(damage: float,造成角色:BaseCultivation):
	# 应用伤害到目标
	hp_stats.current_value=(hp_stats.get_current_value() - damage)
	if !是否存活():
		死亡.emit(造成角色,self)

# 吸收灵气（多余的灵气无法溢出）
func 吸收灵气进入体内(num:float):
	print("吸收灵气")
	spiritual_energy.current_value += num
	# 检查是否超过最大灵气
	if spiritual_energy.current_value > spiritual_energy.max_value:
		spiritual_energy.current_value = spiritual_energy.max_value

#endregion 属性变化方法
#region 相关判断方法
# 检查是否存活
func 是否存活() -> bool:
	return hp_stats.get_current_value() > 0
#endregion 相关判断方法
