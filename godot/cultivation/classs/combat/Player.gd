# scripts/combat/Player.gd
class_name Player
extends "res://classs/combat/Combatant.gd"

# 玩家特有属性
@export var experience_gain_multiplier: float = 1.0  # 经验获得倍率
@export var qi_gain_multiplier: float = 1.0  # 灵气获得倍率

# 玩家技能解锁等级
const SKILL_UNLOCK_LEVELS = {
	"基础攻击": 1,
	"灵气弹": 5,
	"护体术": 10,
	"回春术": 15,
	"雷击术": 20,
	"火球术": 25,
	"冰锥术": 30,
	"治疗术": 35,
	"护盾术": 40,
	"剑气斩": 45,
	"天雷诀": 50,
	"九阳神功": 60,
	"万剑归宗": 70,
	"天地无极": 80,
	"混沌初开": 90
}

func _init():
	# 初始化父类属性
	level = 1
	qi = 0.0
	name_info = ""
	attack_base_min = 1.0
	attack_base_max = 5.0
	health_base = 100.0
	health_current = 100.0
	health_restore_min = 5.0
	health_restore_max = 15.0
	# 初始化玩家基础属性
	speed = 120.0  # 玩家速度稍快
	defense = 5.0  # 基础防御力
	critical_chance = 0.08  # 玩家暴击率稍高
	dodge_chance = 0.08  # 玩家闪避率稍高
	
	# 根据等级解锁技能
	unlock_skills_by_level()

# 根据等级解锁技能
func unlock_skills_by_level() -> void:
	for skill_name in SKILL_UNLOCK_LEVELS:
		var required_level = SKILL_UNLOCK_LEVELS[skill_name]
		if level >= required_level:
			var skill = create_skill_by_name(skill_name)
			if skill:
				add_skill(skill)

# 根据技能名称创建技能
func create_skill_by_name(skill_name: String):
	match skill_name:
		"基础攻击":
			return create_basic_attack_skill()
		"灵气弹":
			return create_qi_blast_skill()
		"护体术":
			return create_protection_skill()
		"回春术":
			return create_recovery_skill()
		"雷击术":
			return create_lightning_skill()
		"火球术":
			return create_fireball_skill()
		"冰锥术":
			return create_ice_spike_skill()
		"治疗术":
			return create_heal_skill()
		"护盾术":
			return create_shield_skill()
		"剑气斩":
			return create_sword_qi_skill()
		"天雷诀":
			return create_heavenly_thunder_skill()
		"九阳神功":
			return create_nine_sun_skill()
		"万剑归宗":
			return create_ten_thousand_swords_skill()
		"天地无极":
			return create_heaven_earth_skill()
		"混沌初开":
			return create_chaos_skill()
		_:
			return null

# 创建基础攻击技能
func create_basic_attack_skill():
	var skill = preload("res://classs/combat/Skill.gd").new()
	skill.skill_name = "基础攻击"
	skill.description = "对敌人造成物理伤害"
	skill.damage_type = "physical"
	skill.base_damage = 1.0
	skill.damage_multiplier = 1.0
	skill.qi_cost = 0.0
	skill.cooldown = 0
	skill.target_type = "enemy"
	skill.skill_range = 1
	return skill

# 创建灵气弹技能
func create_qi_blast_skill():
	var skill = preload("res://classs/combat/Skill.gd").new()
	skill.skill_name = "灵气弹"
	skill.description = "发射灵气弹攻击敌人"
	skill.damage_type = "qi"
	skill.base_damage = 0.8
	skill.damage_multiplier = 1.2
	skill.qi_cost = 10.0
	skill.cooldown = 0
	skill.target_type = "enemy"
	skill.skill_range = 2
	return skill

# 创建护体术技能
func create_protection_skill():
	var skill = preload("res://classs/combat/Skill.gd").new()
	skill.skill_name = "护体术"
	skill.description = "提升自身防御力"
	skill.damage_type = "buff"
	skill.base_damage = 0.0
	skill.damage_multiplier = 1.0
	skill.qi_cost = 15.0
	skill.cooldown = 3
	skill.target_type = "self"
	skill.skill_range = 0
	skill.effect_type = "defense_boost"
	skill.effect_value = 10.0
	skill.effect_duration = 3
	return skill

# 创建回春术技能
func create_recovery_skill():
	var skill = preload("res://classs/combat/Skill.gd").new()
	skill.skill_name = "回春术"
	skill.description = "恢复生命值"
	skill.damage_type = "heal"
	skill.base_damage = 0.0
	skill.damage_multiplier = 1.0
	skill.qi_cost = 20.0
	skill.cooldown = 2
	skill.target_type = "self"
	skill.skill_range = 0
	skill.heal_amount = 50.0
	return skill

# 创建雷击术技能
func create_lightning_skill():
	var skill = preload("res://classs/combat/Skill.gd").new()
	skill.skill_name = "雷击术"
	skill.description = "召唤雷电攻击敌人"
	skill.damage_type = "lightning"
	skill.base_damage = 1.2
	skill.damage_multiplier = 1.5
	skill.qi_cost = 25.0
	skill.cooldown = 2
	skill.target_type = "enemy"
	skill.skill_range = 3
	return skill

# 创建火球术技能
func create_fireball_skill():
	var skill = preload("res://classs/combat/Skill.gd").new()
	skill.skill_name = "火球术"
	skill.description = "发射火球攻击敌人"
	skill.damage_type = "fire"
	skill.base_damage = 1.1
	skill.damage_multiplier = 1.3
	skill.qi_cost = 20.0
	skill.cooldown = 1
	skill.target_type = "enemy"
	skill.skill_range = 2
	return skill

# 创建冰锥术技能
func create_ice_spike_skill():
	var skill = preload("res://classs/combat/Skill.gd").new()
	skill.skill_name = "冰锥术"
	skill.description = "发射冰锥攻击敌人，有概率造成冰冻效果"
	skill.damage_type = "ice"
	skill.base_damage = 1.0
	skill.damage_multiplier = 1.2
	skill.qi_cost = 18.0
	skill.cooldown = 1
	skill.target_type = "enemy"
	skill.skill_range = 2
	skill.effect_type = "freeze"
	skill.effect_chance = 0.3
	skill.effect_duration = 2
	return skill

# 创建治疗术技能
func create_heal_skill():
	var skill = preload("res://classs/combat/Skill.gd").new()
	skill.skill_name = "治疗术"
	skill.description = "恢复大量生命值"
	skill.damage_type = "heal"
	skill.base_damage = 0.0
	skill.damage_multiplier = 1.0
	skill.qi_cost = 30.0
	skill.cooldown = 3
	skill.target_type = "self"
	skill.skill_range = 0
	skill.heal_amount = 100.0
	return skill

# 创建护盾术技能
func create_shield_skill():
	var skill = preload("res://classs/combat/Skill.gd").new()
	skill.skill_name = "护盾术"
	skill.description = "为自己施加护盾，吸收伤害"
	skill.damage_type = "buff"
	skill.base_damage = 0.0
	skill.damage_multiplier = 1.0
	skill.qi_cost = 25.0
	skill.cooldown = 4
	skill.target_type = "self"
	skill.skill_range = 0
	skill.effect_type = "shield"
	skill.effect_value = 50.0
	skill.effect_duration = 4
	return skill

# 创建剑气斩技能
func create_sword_qi_skill():
	var skill = preload("res://classs/combat/Skill.gd").new()
	skill.skill_name = "剑气斩"
	skill.description = "释放剑气攻击敌人"
	skill.damage_type = "qi"
	skill.base_damage = 1.5
	skill.damage_multiplier = 1.8
	skill.qi_cost = 40.0
	skill.cooldown = 3
	skill.target_type = "enemy"
	skill.skill_range = 2
	return skill

# 创建天雷诀技能
func create_heavenly_thunder_skill():
	var skill = preload("res://classs/combat/Skill.gd").new()
	skill.skill_name = "天雷诀"
	skill.description = "召唤天雷攻击敌人，造成大量伤害"
	skill.damage_type = "lightning"
	skill.base_damage = 2.0
	skill.damage_multiplier = 2.0
	skill.qi_cost = 60.0
	skill.cooldown = 5
	skill.target_type = "enemy"
	skill.skill_range = 3
	return skill

# 创建九阳神功技能
func create_nine_sun_skill():
	var skill = preload("res://classs/combat/Skill.gd").new()
	skill.skill_name = "九阳神功"
	skill.description = "修炼九阳神功，大幅提升攻击力和生命值"
	skill.damage_type = "buff"
	skill.base_damage = 0.0
	skill.damage_multiplier = 1.0
	skill.qi_cost = 80.0
	skill.cooldown = 6
	skill.target_type = "self"
	skill.skill_range = 0
	skill.effect_type = "power_boost"
	skill.effect_value = 50.0
	skill.effect_duration = 5
	return skill

# 创建万剑归宗技能
func create_ten_thousand_swords_skill():
	var skill = preload("res://classs/combat/Skill.gd").new()
	skill.skill_name = "万剑归宗"
	skill.description = "召唤万剑攻击所有敌人"
	skill.damage_type = "qi"
	skill.base_damage = 1.8
	skill.damage_multiplier = 2.2
	skill.qi_cost = 100.0
	skill.cooldown = 8
	skill.target_type = "all_enemies"
	skill.skill_range = 3
	return skill

# 创建天地无极技能
func create_heaven_earth_skill():
	var skill = preload("res://classs/combat/Skill.gd").new()
	skill.skill_name = "天地无极"
	skill.description = "调动天地之力，造成毁灭性伤害"
	skill.damage_type = "divine"
	skill.base_damage = 3.0
	skill.damage_multiplier = 3.0
	skill.qi_cost = 150.0
	skill.cooldown = 10
	skill.target_type = "enemy"
	skill.skill_range = 4
	return skill

# 创建混沌初开技能
func create_chaos_skill():
	var skill = preload("res://classs/combat/Skill.gd").new()
	skill.skill_name = "混沌初开"
	skill.description = "释放混沌之力，对所有敌人造成巨大伤害"
	skill.damage_type = "chaos"
	skill.base_damage = 4.0
	skill.damage_multiplier = 4.0
	skill.qi_cost = 200.0
	skill.cooldown = 15
	skill.target_type = "all_enemies"
	skill.skill_range = 5
	return skill

# 升级时解锁新技能
func level_up() -> bool:
	var result = super.level_up()
	if result:
		unlock_skills_by_level()
	return result

# 获取玩家战斗信息
func get_player_combat_info() -> Dictionary:
	var info = get_combat_info()
	info["experience_multiplier"] = experience_gain_multiplier
	info["qi_multiplier"] = qi_gain_multiplier
	info["available_skills"] = available_skills.size()
	info["usable_skills"] = get_usable_skills().size()
	return info
