extends Node
class_name BaseCultivation

# 引入成长相关类

# 修仙者基础类
# 包含所有修仙者的基本属性和方法

# 基础属性
@export var id: String = ""
@export var name_str: String = "未命名修仙者"
@export var level: int = 1  # 修炼等级
@export var realm_level: int = 1  # 境界内等级（层）
@export var experience: int = 0  # 经验值

# 生命值系统（使用范围值类管理）
var hp_stats: RangedValue

# 速度系统（使用固定值类管理）
var speed_stats: RandomValue

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

@export var realm: CultivationRealm = CultivationRealm.FANREN

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


# 获取境界名称
func get_realm_name() -> String:
	match realm:
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
	if realm == CultivationRealm.FANREN:
		return "凡人"
	else:
		return get_realm_name() + "第" + str(realm_level) + "层"

# 死亡
func die():
	print(name_str + " 已死亡！")

# 检查是否存活
func is_alive() -> bool:
	return hp_stats.get_current_value() > 0

# 升级
func level_up():
	level += 1
	experience = 0
	
	# 检查是否需要突破境界
	if check_realm_breakthrough():
		return  # 如果突破了境界，就不执行境界内升级
	
	# 境界内升级（提升层数）
	realm_level += 1
	
	# 境界内升级时小幅提升属性
	hp_stats.grow()  # 生命值随机成长
	speed_stats.grow()  # 速度随机成长
	
	# 生命值恢复到最大
	hp_stats.current_value = hp_stats.max_value
	
	print(name_str + " 修炼到 " + get_full_realm_name() + "！")


# 检查是否需要突破境界
func check_realm_breakthrough() -> bool:
	var required_level = get_required_level_for_realm(realm + 1)
	if level >= required_level and realm < CultivationRealm.DUDIE:
		breakthrough_realm()
		return true
	return false

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

# 突破境界
func breakthrough_realm():
	if realm < CultivationRealm.DUDIE:
		var old_realm = realm
		realm = (realm + 1) as CultivationRealm
		realm_level = 1  # 突破后重置为第一层
		print(name_str + " 从 " + get_realm_name_by_realm(old_realm) + " 突破到 " + get_full_realm_name() + "！")
		
		# 境界突破时大幅提升属性（比升级提升更多）
		var breakthrough_multiplier = get_breakthrough_multiplier()
		# 使用新的生命值系统
		for i in range(15 * breakthrough_multiplier):
			hp_stats.grow()
		# 额外多次成长
		for i in range(int(3 * breakthrough_multiplier)):
			speed_stats.grow()
		print("境界突破！属性大幅提升！")

# 获取境界突破的属性提升倍数
func get_breakthrough_multiplier() -> float:
	match realm:
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

# 根据境界枚举获取境界名称
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

static func 随机生成修仙者()->BaseCultivation:
	return null
