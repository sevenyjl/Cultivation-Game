extends Node
class_name BaseCultivation

# 修仙者基础类
# 包含所有修仙者的基本属性和方法

# 基础属性
@export var id: String = ""
@export var name_str: String = "未命名修仙者"
@export var level: int = 1  # 修炼等级
@export var realm_level: int = 1  # 境界内等级（层）
@export var experience: int = 0  # 经验值

# 生命值系统
@export var max_hp: int = 100
@export var current_hp: int = 100

# 法力值系统
@export var max_mp: int = 50
@export var current_mp: int = 50

# 基础属性
@export var strength: int = 10  # 力量
@export var agility: int = 10   # 敏捷
@export var intelligence: int = 10  # 智力
@export var constitution: int = 10  # 体质
@export var speed: int = 10     # 速度（影响攻击顺序）

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

# 技能和功法
var skills: Array[Dictionary] = []  # 技能列表
var techniques: Array[Dictionary] = []  # 功法列表

# 装备
var equipment: Dictionary = {
	"weapon": null,    # 武器
	"armor": null,     # 护甲
	"accessory": null  # 饰品
}

# 状态效果
var status_effects: Array[Dictionary] = []

# 可见性（用于战斗UI显示控制）
var visible: bool = true

# 信号
signal hp_changed(current_hp: int, max_hp: int)
signal mp_changed(current_mp: int, max_mp: int)
signal level_changed(new_level: int)
signal realm_changed(new_realm: CultivationRealm)
signal died(character: Node)

func _ready():
	# 初始化时确保当前值不超过最大值
	current_hp = min(current_hp, max_hp)
	current_mp = min(current_mp, max_mp)

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

# 设置生命值
func set_hp(value: int, max_value: int = -1):
	if max_value != -1:
		max_hp = max_value
	current_hp = clamp(value, 0, max_hp)
	hp_changed.emit(current_hp, max_hp)
	
	if current_hp <= 0:
		die()

# 设置法力值
func set_mp(value: int, max_value: int = -1):
	if max_value != -1:
		max_mp = max_value
	current_mp = clamp(value, 0, max_mp)
	mp_changed.emit(current_mp, max_mp)

# 恢复生命值
func heal_hp(amount: int):
	set_hp(current_hp + amount)

# 恢复法力值
func restore_mp(amount: int):
	set_mp(current_mp + amount)

# 受到伤害
func take_damage(amount: int):
	var actual_damage = calculate_damage_taken(amount)
	set_hp(current_hp - actual_damage)
	return actual_damage

# 计算受到的伤害（考虑防御力等）
func calculate_damage_taken(base_damage: int) -> int:
	# 基础防御计算，体质越高防御越高
	var defense = constitution * 2
	var actual_damage = max(1, base_damage - defense)
	return actual_damage

# 造成伤害
func deal_damage(target: Node) -> int:
	var base_damage = strength * 3
	var actual_damage = target.take_damage(base_damage)
	return actual_damage

# 死亡
func die():
	died.emit(self)
	print(name_str + " 已死亡！")

# 检查是否存活
func is_alive() -> bool:
	return current_hp > 0

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
	max_hp += constitution * 3
	max_mp += intelligence * 2
	strength += 1
	agility += 1
	intelligence += 1
	constitution += 1
	speed += 1
	
	# 恢复生命值和法力值
	current_hp = max_hp
	current_mp = max_mp
	
	level_changed.emit(level)
	print(name_str + " 修炼到 " + get_full_realm_name() + "！")

# 添加经验值
func add_experience(amount: int):
	experience += amount
	var required_exp = level * 100  # 每级需要100点经验
	
	if experience >= required_exp:
		level_up()

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

# 获取当前境界的等级范围
func get_realm_level_range() -> String:
	var current_realm_level = get_required_level_for_realm(realm)
	var next_realm_level = get_required_level_for_realm(realm + 1)
	
	if realm == CultivationRealm.DUDIE:
		return "150级以上"
	else:
		return str(current_realm_level) + "-" + str(next_realm_level - 1) + "级"

# 突破境界
func breakthrough_realm():
	if realm < CultivationRealm.DUDIE:
		var old_realm = realm
		realm = (realm + 1) as CultivationRealm
		realm_level = 1  # 突破后重置为第一层
		realm_changed.emit(realm)
		print(name_str + " 从 " + get_realm_name_by_realm(old_realm) + " 突破到 " + get_full_realm_name() + "！")
		
		# 境界突破时大幅提升属性（比升级提升更多）
		var breakthrough_multiplier = get_breakthrough_multiplier()
		max_hp += constitution * 15 * breakthrough_multiplier
		max_mp += intelligence * 12 * breakthrough_multiplier
		strength += 8 * breakthrough_multiplier
		agility += 8 * breakthrough_multiplier
		intelligence += 8 * breakthrough_multiplier
		constitution += 8 * breakthrough_multiplier
		speed += 5 * breakthrough_multiplier
		
		# 恢复生命值和法力值
		current_hp = max_hp
		current_mp = max_mp
		
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

# 学习技能
func learn_skill(skill_name: String, skill_description: String, mp_cost: int = 0):
	var skill = {
		"name": skill_name,
		"description": skill_description,
		"mp_cost": mp_cost
	}
	skills.append(skill)
	print(name_str + " 学会了技能：" + skill_name)

# 学习功法
func learn_technique(technique_name: String, technique_description: String):
	var technique = {
		"name": technique_name,
		"description": technique_description
	}
	techniques.append(technique)
	print(name_str + " 学会了功法：" + technique_name)

# 使用技能
func use_skill(skill_name: String, _target: Node = null) -> bool:
	for skill in skills:
		if skill["name"] == skill_name:
			if current_mp >= skill["mp_cost"]:
				current_mp -= skill["mp_cost"]
				mp_changed.emit(current_mp, max_mp)
				print(name_str + " 使用了技能：" + skill_name)
				return true
			else:
				print(name_str + " 法力值不足，无法使用技能：" + skill_name)
				return false
	print(name_str + " 没有学会技能：" + skill_name)
	return false

# 获取属性信息
func get_stats_info() -> String:
	var info = "=== " + name_str + " 属性信息 ===\n"
	info += "等级: " + str(level) + "级\n"
	info += "境界: " + get_full_realm_name() + "\n"
	info += "生命值: " + str(current_hp) + "/" + str(max_hp) + "\n"
	info += "法力值: " + str(current_mp) + "/" + str(max_mp) + "\n"
	info += "力量: " + str(strength) + "\n"
	info += "敏捷: " + str(agility) + "\n"
	info += "智力: " + str(intelligence) + "\n"
	info += "体质: " + str(constitution) + "\n"
	info += "速度: " + str(speed) + "\n"
	info += "经验值: " + str(experience) + "/" + str(level * 100) + "\n"
	
	# 显示下一个境界的等级要求
	var next_realm_level = get_required_level_for_realm(realm + 1)
	if realm < CultivationRealm.DUDIE:
		info += "下一境界需要: " + str(next_realm_level) + "级\n"
	
	return info

# 获取技能列表
func get_skills_info() -> String:
	if skills.is_empty():
		return name_str + " 还没有学会任何技能"
	
	var info = "=== " + name_str + " 技能列表 ===\n"
	for skill in skills:
		info += "• " + skill["name"] + " (消耗法力: " + str(skill["mp_cost"]) + ")\n"
		info += "  " + skill["description"] + "\n"
	return info

# 获取功法列表
func get_techniques_info() -> String:
	if techniques.is_empty():
		return name_str + " 还没有学会任何功法"
	
	var info = "=== " + name_str + " 功法列表 ===\n"
	for technique in techniques:
		info += "• " + technique["name"] + "\n"
		info += "  " + technique["description"] + "\n"
	return info
