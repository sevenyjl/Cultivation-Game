# scripts/combat/Enemy.gd
class_name Enemy
extends "res://classs/combat/Combatant.gd"

# 敌人类型枚举 - 现在使用Cultivator的类型系统
enum EnemyType {
	BEAST,      # 妖兽
	DEMON,      # 魔物
	SPIRIT,     # 灵体
	CULTIVATOR, # 邪修
	BOSS        # 首领
}

# 敌人特有属性
@export var enemy_type: EnemyType = EnemyType.BEAST
@export var experience_reward: float = 100.0  # 击败后获得的经验
@export var qi_reward: float = 50.0  # 击败后获得的灵气
@export var ai_aggression: float = 0.5  # AI攻击性 (0.0-1.0)
@export var ai_intelligence: float = 0.5  # AI智能程度 (0.0-1.0)

# 敌人类型到Cultivator类型的映射
const ENEMY_TYPE_TO_CULTIVATOR_TYPE = {
	EnemyType.BEAST: Cultivator.CultivatorType.BEAST,
	EnemyType.DEMON: Cultivator.CultivatorType.DEMON,
	EnemyType.SPIRIT: Cultivator.CultivatorType.SPIRIT,
	EnemyType.CULTIVATOR: Cultivator.CultivatorType.CULTIVATOR,
	EnemyType.BOSS: Cultivator.CultivatorType.BOSS
}

# 敌人名称配置
const ENEMY_NAMES = {
	EnemyType.BEAST: ["野狼", "山猪", "毒蛇", "猛虎", "巨熊", "火狐", "冰狼", "雷豹"],
	EnemyType.DEMON: ["小魔", "恶鬼", "血魔", "暗影", "邪灵", "魔将", "鬼王", "魔王"],
	EnemyType.SPIRIT: ["风灵", "火灵", "水灵", "土灵", "雷灵", "冰灵", "光灵", "暗灵"],
	EnemyType.CULTIVATOR: ["邪修", "魔修", "鬼修", "血修", "毒修", "暗修", "邪道", "魔道"],
	EnemyType.BOSS: ["妖王", "魔王", "鬼王", "邪王", "魔尊", "妖尊", "鬼尊", "邪尊"]
}

func _init(enemy_type_param: EnemyType = EnemyType.BEAST, enemy_level: int = 1):
	# 初始化父类属性 - 使用与Cultivator相同的基础值
	level = 1
	qi = 0.0
	name_info = ""
	attack_base_min = 1.0
	attack_base_max = 5.0
	health_base = 100.0
	health_current = 100.0
	health_restore_min = 5.0
	health_restore_max = 15.0
	self.enemy_type = enemy_type_param
	level = enemy_level
	
	# 设置Cultivator类型
	cultivator_type = ENEMY_TYPE_TO_CULTIVATOR_TYPE[enemy_type_param]
	
	# 根据敌人类型和等级初始化属性
	initialize_enemy_stats()
	
	# 生成随机名称
	generate_enemy_name()
	
	# 根据等级解锁技能
	unlock_enemy_skills()

# 初始化敌人属性 - 基于Cultivator成长体系
func initialize_enemy_stats() -> void:
	# 模拟Cultivator的成长过程，从1级成长到目标等级
	# 这样可以确保敌人遵循与玩家相同的成长规律
	for current_level in range(1, level):
		# 模拟升级过程，使用Cultivator的成长因子
		simulate_level_up(current_level)
	
	# 设置固定属性（这些不随等级变化）
	speed = get_base_speed()
	defense = get_base_defense()
	
	# 设置当前生命值为最大值
	health_current = get_max_health()
	
	# 设置奖励
	experience_reward = get_exp_multiplier() * level * 50.0
	qi_reward = get_qi_multiplier() * level * 25.0
	
	# 根据敌人类型调整特殊属性
	adjust_type_specific_stats()

# 模拟敌人升级过程
func simulate_level_up(_current_level: int) -> void:
	# 使用与Cultivator相同的成长公式，通过继承获得成长因子
	
	# 攻击力成长（参考Cultivator的level_up函数）
	attack_base_min *= 1.1 * get_growth_factors().attack_factor
	attack_base_max *= 1.15 * get_growth_factors().attack_factor
	
	# 生命值成长
	health_base *= 1.25 * get_growth_factors().health_factor
	
	# 恢复力成长
	health_restore_min *= 1.12 * get_growth_factors().restore_factor
	health_restore_max *= 1.18 * get_growth_factors().restore_factor

# 调整类型特定属性
func adjust_type_specific_stats() -> void:
	match enemy_type:
		EnemyType.BEAST:
			critical_chance = 0.1
			dodge_chance = 0.05
			ai_aggression = 0.7
			ai_intelligence = 0.3
		EnemyType.DEMON:
			critical_chance = 0.08
			dodge_chance = 0.03
			ai_aggression = 0.8
			ai_intelligence = 0.4
		EnemyType.SPIRIT:
			critical_chance = 0.12
			dodge_chance = 0.15
			ai_aggression = 0.4
			ai_intelligence = 0.8
		EnemyType.CULTIVATOR:
			critical_chance = 0.06
			dodge_chance = 0.08
			ai_aggression = 0.6
			ai_intelligence = 0.7
		EnemyType.BOSS:
			critical_chance = 0.15
			dodge_chance = 0.1
			ai_aggression = 0.9
			ai_intelligence = 0.8

# 生成敌人名称
func generate_enemy_name() -> void:
	var names = ENEMY_NAMES[enemy_type]
	var base_name = names[randi() % names.size()]
	
	# 根据等级添加前缀
	var level_prefix = ""
	if level >= 20:
		level_prefix = "高级"
	elif level >= 10:
		level_prefix = "中级"
	elif level >= 5:
		level_prefix = "初级"
	
	# 根据敌人类型添加后缀
	var type_suffix = ""
	match enemy_type:
		EnemyType.BEAST:
			type_suffix = "妖兽"
		EnemyType.DEMON:
			type_suffix = "魔物"
		EnemyType.SPIRIT:
			type_suffix = "灵体"
		EnemyType.CULTIVATOR:
			type_suffix = "邪修"
		EnemyType.BOSS:
			type_suffix = "首领"
	
	name_info = level_prefix + base_name + type_suffix

# 根据等级解锁敌人技能
func unlock_enemy_skills() -> void:
	# 所有敌人都有的基础攻击
	add_skill(create_basic_attack_skill())
	
	# 根据敌人类型和等级解锁特殊技能
	match enemy_type:
		EnemyType.BEAST:
			if level >= 3:
				add_skill(create_feral_strike_skill())
			if level >= 8:
				add_skill(create_roar_skill())
			if level >= 15:
				add_skill(create_berserker_rage_skill())
		EnemyType.DEMON:
			if level >= 2:
				add_skill(create_dark_blast_skill())
			if level >= 6:
				add_skill(create_curse_skill())
			if level >= 12:
				add_skill(create_demon_fire_skill())
		EnemyType.SPIRIT:
			if level >= 4:
				add_skill(create_spirit_blast_skill())
			if level >= 10:
				add_skill(create_phase_skill())
			if level >= 18:
				add_skill(create_spirit_burst_skill())
		EnemyType.CULTIVATOR:
			if level >= 5:
				add_skill(create_evil_qi_skill())
			if level >= 12:
				add_skill(create_drain_skill())
			if level >= 20:
				add_skill(create_dark_art_skill())
		EnemyType.BOSS:
			# BOSS有更多技能
			add_skill(create_power_strike_skill())
			if level >= 5:
				add_skill(create_area_attack_skill())
			if level >= 10:
				add_skill(create_heal_skill())
			if level >= 15:
				add_skill(create_ultimate_skill())

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
	skill.target_type = "player"
	skill.skill_range = 1
	return skill

# 创建野性打击技能（妖兽）
func create_feral_strike_skill():
	var skill = preload("res://classs/combat/Skill.gd").new()
	skill.skill_name = "野性打击"
	skill.description = "野兽的凶猛攻击，有概率造成流血效果"
	skill.damage_type = "physical"
	skill.base_damage = 1.3
	skill.damage_multiplier = 1.2
	skill.qi_cost = 0.0
	skill.cooldown = 2
	skill.target_type = "player"
	skill.skill_range = 1
	skill.effect_type = "bleed"
	skill.effect_chance = 0.3
	skill.effect_duration = 3
	return skill

# 创建咆哮技能（妖兽）
func create_roar_skill():
	var skill = preload("res://classs/combat/Skill.gd").new()
	skill.skill_name = "咆哮"
	skill.description = "发出震耳欲聋的咆哮，降低敌人攻击力"
	skill.damage_type = "debuff"
	skill.base_damage = 0.0
	skill.damage_multiplier = 1.0
	skill.qi_cost = 0.0
	skill.cooldown = 4
	skill.target_type = "player"
	skill.skill_range = 2
	skill.effect_type = "attack_debuff"
	skill.effect_value = -20.0
	skill.effect_duration = 3
	return skill

# 创建狂暴技能（妖兽）
func create_berserker_rage_skill():
	var skill = preload("res://classs/combat/Skill.gd").new()
	skill.skill_name = "狂暴"
	skill.description = "进入狂暴状态，大幅提升攻击力"
	skill.damage_type = "buff"
	skill.base_damage = 0.0
	skill.damage_multiplier = 1.0
	skill.qi_cost = 0.0
	skill.cooldown = 6
	skill.target_type = "self"
	skill.skill_range = 0
	skill.effect_type = "attack_boost"
	skill.effect_value = 50.0
	skill.effect_duration = 5
	return skill

# 创建黑暗冲击技能（魔物）
func create_dark_blast_skill():
	var skill = preload("res://classs/combat/Skill.gd").new()
	skill.skill_name = "黑暗冲击"
	skill.description = "释放黑暗能量攻击敌人"
	skill.damage_type = "dark"
	skill.base_damage = 1.2
	skill.damage_multiplier = 1.3
	skill.qi_cost = 0.0
	skill.cooldown = 2
	skill.target_type = "player"
	skill.skill_range = 2
	return skill

# 创建诅咒技能（魔物）
func create_curse_skill():
	var skill = preload("res://classs/combat/Skill.gd").new()
	skill.skill_name = "诅咒"
	skill.description = "诅咒敌人，降低其防御力"
	skill.damage_type = "debuff"
	skill.base_damage = 0.0
	skill.damage_multiplier = 1.0
	skill.qi_cost = 0.0
	skill.cooldown = 3
	skill.target_type = "player"
	skill.skill_range = 2
	skill.effect_type = "defense_debuff"
	skill.effect_value = -15.0
	skill.effect_duration = 4
	return skill

# 创建魔火技能（魔物）
func create_demon_fire_skill():
	var skill = preload("res://classs/combat/Skill.gd").new()
	skill.skill_name = "魔火"
	skill.description = "召唤魔火攻击敌人，造成持续伤害"
	skill.damage_type = "fire"
	skill.base_damage = 1.4
	skill.damage_multiplier = 1.5
	skill.qi_cost = 0.0
	skill.cooldown = 4
	skill.target_type = "player"
	skill.skill_range = 2
	skill.effect_type = "burn"
	skill.effect_chance = 0.5
	skill.effect_duration = 3
	return skill

# 创建灵体冲击技能（灵体）
func create_spirit_blast_skill():
	var skill = preload("res://classs/combat/Skill.gd").new()
	skill.skill_name = "灵体冲击"
	skill.description = "释放灵体能量攻击敌人"
	skill.damage_type = "spirit"
	skill.base_damage = 1.1
	skill.damage_multiplier = 1.4
	skill.qi_cost = 0.0
	skill.cooldown = 1
	skill.target_type = "player"
	skill.skill_range = 3
	return skill

# 创建相位技能（灵体）
func create_phase_skill():
	var skill = preload("res://classs/combat/Skill.gd").new()
	skill.skill_name = "相位移动"
	skill.description = "瞬间移动到敌人身边，提升下次攻击伤害"
	skill.damage_type = "buff"
	skill.base_damage = 0.0
	skill.damage_multiplier = 1.0
	skill.qi_cost = 0.0
	skill.cooldown = 3
	skill.target_type = "self"
	skill.skill_range = 0
	skill.effect_type = "next_attack_boost"
	skill.effect_value = 100.0
	skill.effect_duration = 1
	return skill

# 创建灵体爆发技能（灵体）
func create_spirit_burst_skill():
	var skill = preload("res://classs/combat/Skill.gd").new()
	skill.skill_name = "灵体爆发"
	skill.description = "释放灵体能量，对所有敌人造成伤害"
	skill.damage_type = "spirit"
	skill.base_damage = 1.6
	skill.damage_multiplier = 1.8
	skill.qi_cost = 0.0
	skill.cooldown = 5
	skill.target_type = "all_players"
	skill.skill_range = 3
	return skill

# 创建邪气技能（邪修）
func create_evil_qi_skill():
	var skill = preload("res://classs/combat/Skill.gd").new()
	skill.skill_name = "邪气攻击"
	skill.description = "使用邪气攻击敌人"
	skill.damage_type = "evil"
	skill.base_damage = 1.3
	skill.damage_multiplier = 1.3
	skill.qi_cost = 0.0
	skill.cooldown = 2
	skill.target_type = "player"
	skill.skill_range = 2
	return skill

# 创建吸取技能（邪修）
func create_drain_skill():
	var skill = preload("res://classs/combat/Skill.gd").new()
	skill.skill_name = "生命吸取"
	skill.description = "吸取敌人生命值恢复自己"
	skill.damage_type = "drain"
	skill.base_damage = 0.8
	skill.damage_multiplier = 1.0
	skill.qi_cost = 0.0
	skill.cooldown = 3
	skill.target_type = "player"
	skill.skill_range = 1
	skill.heal_amount = 30.0
	return skill

# 创建邪术技能（邪修）
func create_dark_art_skill():
	var skill = preload("res://classs/combat/Skill.gd").new()
	skill.skill_name = "邪术"
	skill.description = "使用邪恶法术攻击敌人"
	skill.damage_type = "evil"
	skill.base_damage = 1.8
	skill.damage_multiplier = 2.0
	skill.qi_cost = 0.0
	skill.cooldown = 5
	skill.target_type = "player"
	skill.skill_range = 3
	return skill

# 创建强力打击技能（BOSS）
func create_power_strike_skill():
	var skill = preload("res://classs/combat/Skill.gd").new()
	skill.skill_name = "强力打击"
	skill.description = "BOSS的强力攻击"
	skill.damage_type = "physical"
	skill.base_damage = 1.5
	skill.damage_multiplier = 1.5
	skill.qi_cost = 0.0
	skill.cooldown = 1
	skill.target_type = "player"
	skill.skill_range = 1
	return skill

# 创建范围攻击技能（BOSS）
func create_area_attack_skill():
	var skill = preload("res://classs/combat/Skill.gd").new()
	skill.skill_name = "范围攻击"
	skill.description = "对所有敌人造成范围伤害"
	skill.damage_type = "physical"
	skill.base_damage = 1.2
	skill.damage_multiplier = 1.3
	skill.qi_cost = 0.0
	skill.cooldown = 3
	skill.target_type = "all_players"
	skill.skill_range = 2
	return skill

# 创建治疗技能（BOSS）
func create_heal_skill():
	var skill = preload("res://classs/combat/Skill.gd").new()
	skill.skill_name = "自我治疗"
	skill.description = "恢复自身生命值"
	skill.damage_type = "heal"
	skill.base_damage = 0.0
	skill.damage_multiplier = 1.0
	skill.qi_cost = 0.0
	skill.cooldown = 4
	skill.target_type = "self"
	skill.skill_range = 0
	skill.heal_amount = 80.0
	return skill

# 创建终极技能（BOSS）
func create_ultimate_skill():
	var skill = preload("res://classs/combat/Skill.gd").new()
	skill.skill_name = "终极技能"
	skill.description = "BOSS的终极攻击，造成巨大伤害"
	skill.damage_type = "ultimate"
	skill.base_damage = 2.5
	skill.damage_multiplier = 2.5
	skill.qi_cost = 0.0
	skill.cooldown = 8
	skill.target_type = "player"
	skill.skill_range = 3
	return skill

# 注意：get_max_health(), get_attack_range(), get_health_restore_range() 等方法
# 现在直接继承自Cultivator，会自动使用正确的成长因子

# 获取敌人战斗信息
func get_enemy_combat_info() -> Dictionary:
	var info = get_combat_info()
	info["enemy_type"] = enemy_type
	info["experience_reward"] = experience_reward
	info["qi_reward"] = qi_reward
	info["ai_aggression"] = ai_aggression
	info["ai_intelligence"] = ai_intelligence
	return info
