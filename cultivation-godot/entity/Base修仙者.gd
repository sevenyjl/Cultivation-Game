extends Node
class_name BaseCultivation

# 修仙者基础类
# 包含所有修仙者的基本属性和方法

# 基础属性
@export var id: String = ""
@export var name_str: String = "未命名修仙者"
@export var level: int = 1  # 修炼等级
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
	
	# 升级时提升属性
	max_hp += constitution * 5
	max_mp += intelligence * 3
	strength += 2
	agility += 2
	intelligence += 2
	constitution += 2
	speed += 1
	
	# 恢复生命值和法力值
	current_hp = max_hp
	current_mp = max_mp
	
	level_changed.emit(level)
	print(name_str + " 升级到 " + str(level) + " 级！")

# 添加经验值
func add_experience(amount: int):
	experience += amount
	var required_exp = level * 100  # 每级需要100点经验
	
	if experience >= required_exp:
		level_up()

# 突破境界
func breakthrough_realm():
	if realm < CultivationRealm.DUDIE:
		realm = (realm + 1) as CultivationRealm
		realm_changed.emit(realm)
		print(name_str + " 突破到 " + get_realm_name() + "！")
		
		# 境界突破时大幅提升属性
		max_hp += constitution * 10
		max_mp += intelligence * 8
		strength += 5
		agility += 5
		intelligence += 5
		constitution += 5
		speed += 3

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
	info += "等级: " + str(level) + "\n"
	info += "境界: " + get_realm_name() + "\n"
	info += "生命值: " + str(current_hp) + "/" + str(max_hp) + "\n"
	info += "法力值: " + str(current_mp) + "/" + str(max_mp) + "\n"
	info += "力量: " + str(strength) + "\n"
	info += "敏捷: " + str(agility) + "\n"
	info += "智力: " + str(intelligence) + "\n"
	info += "体质: " + str(constitution) + "\n"
	info += "速度: " + str(speed) + "\n"
	info += "经验值: " + str(experience) + "/" + str(level * 100) + "\n"
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
