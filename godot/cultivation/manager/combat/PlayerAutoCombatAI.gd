# scripts/managers/combat/PlayerAutoCombatAI.gd
class_name PlayerAutoCombatAI
extends Node

# 玩家自动战斗AI决策类型
enum PlayerAIDecisionType {
	ATTACK,     # 攻击
	SKILL,      # 使用技能
	DEFEND,     # 防御
	HEAL,       # 治疗
	ESCAPE      # 逃跑
}

# AI配置
@export var ai_aggression: float = 0.7  # 攻击性（0.0-1.0）
@export var ai_caution: float = 0.3    # 谨慎性（0.0-1.0）
@export var ai_skill_usage: float = 0.6  # 技能使用倾向（0.0-1.0）
@export var ai_heal_threshold: float = 0.3  # 治疗阈值
@export var ai_escape_threshold: float = 0.1  # 逃跑阈值

# 自动战斗设置
var auto_combat_settings: Dictionary = {
	"prefer_attack": true,      # 优先攻击
	"use_skills": true,         # 使用技能
	"auto_heal": true,          # 自动治疗
	"auto_escape": true,        # 自动逃跑
	"skill_priority": "damage", # 技能优先级：damage, heal, buff, debuff
	"target_priority": "weakest" # 目标优先级：weakest, strongest, random
}

func _init():
	pass

# 为玩家选择行动
func choose_player_action(player: Player, enemies: Array) -> CombatAction:
	print("=== PlayerAutoCombatAI.choose_player_action ===")
	print("玩家存在: ", player != null)
	print("玩家存活: ", player.is_alive_in_battle() if player else false)
	print("敌人数量: ", enemies.size())
	
	if not player or not player.is_alive_in_battle():
		print("玩家不存在或已死亡，返回null")
		return null
	
	# 获取可用技能
	var available_skills = player.get_usable_skills()
	print("可用技能数量: ", available_skills.size())
	
	# 计算决策权重
	var decision_weights = calculate_decision_weights(player, enemies, available_skills)
	print("决策权重: ", decision_weights)
	
	# 选择最佳决策
	var decision = select_best_decision(decision_weights)
	
	# 创建对应的行动
	return create_action_from_decision(player, enemies, decision, available_skills)

# 计算决策权重
func calculate_decision_weights(player: Player, enemies: Array, available_skills: Array) -> Dictionary:
	var weights = {
		PlayerAIDecisionType.ATTACK: 0.0,
		PlayerAIDecisionType.SKILL: 0.0,
		PlayerAIDecisionType.DEFEND: 0.0,
		PlayerAIDecisionType.HEAL: 0.0,
		PlayerAIDecisionType.ESCAPE: 0.0
	}
	
	# 基础攻击权重
	weights[PlayerAIDecisionType.ATTACK] = calculate_attack_weight(player, enemies)
	
	# 技能权重
	weights[PlayerAIDecisionType.SKILL] = calculate_skill_weight(player, enemies, available_skills)
	
	# 防御权重
	weights[PlayerAIDecisionType.DEFEND] = calculate_defend_weight(player, enemies)
	
	# 治疗权重
	weights[PlayerAIDecisionType.HEAL] = calculate_heal_weight(player, enemies, available_skills)
	
	# 逃跑权重
	weights[PlayerAIDecisionType.ESCAPE] = calculate_escape_weight(player, enemies)
	
	return weights

# 计算攻击权重
func calculate_attack_weight(player: Player, enemies: Array) -> float:
	if enemies.is_empty():
		return 0.0
	
	# 基础攻击性
	var weight = ai_aggression
	
	# 如果敌人生命值低，增加攻击权重
	var weakest_enemy = get_weakest_enemy(enemies)
	if weakest_enemy:
		var enemy_health_ratio = weakest_enemy.get_combat_current_health() / weakest_enemy.get_combat_max_health()
		if enemy_health_ratio < 0.3:
			weight += 0.3
	
	# 如果玩家生命值高，增加攻击权重
	var player_health_ratio = player.get_combat_current_health() / player.get_combat_max_health()
	if player_health_ratio > 0.7:
		weight += 0.2
	
	return min(weight, 1.0)

# 计算技能权重
func calculate_skill_weight(player: Player, enemies: Array, available_skills: Array) -> float:
	if not auto_combat_settings["use_skills"] or available_skills.is_empty():
		return 0.0
	
	# 基础技能使用倾向
	var weight = ai_skill_usage
	
	# 根据技能类型调整权重
	for skill in available_skills:
		if skill.skill_name == "基础攻击":
			continue  # 跳过基础攻击
		
		match skill.damage_type:
			"physical", "qi", "fire", "ice", "lightning", "dark", "spirit", "evil":
				weight += 0.1  # 攻击技能
			"heal":
				weight += 0.2  # 治疗技能
			"buff":
				weight += 0.15  # 增益技能
			"debuff":
				weight += 0.15  # 减益技能
	
	# 如果敌人很强，增加技能使用权重
	var strongest_enemy = get_strongest_enemy(enemies)
	if strongest_enemy:
		var enemy_attack = strongest_enemy.get_combat_attack_range()
		var player_defense = player.get_combat_defense()
		if (enemy_attack.min + enemy_attack.max) / 2.0 > player_defense * 1.5:
			weight += 0.2
	
	return min(weight, 1.0)

# 计算防御权重
func calculate_defend_weight(player: Player, enemies: Array) -> float:
	var weight = 0.0
	
	# 如果玩家生命值很低，增加防御权重
	var player_health_ratio = player.get_combat_current_health() / player.get_combat_max_health()
	if player_health_ratio < 0.2:
		weight += 0.4
	
	# 如果敌人攻击力很高，增加防御权重
	var strongest_enemy = get_strongest_enemy(enemies)
	if strongest_enemy:
		var enemy_attack = strongest_enemy.get_combat_attack_range()
		var player_defense = player.get_combat_defense()
		if (enemy_attack.min + enemy_attack.max) / 2.0 > player_defense * 2.0:
			weight += 0.3
	
	# 谨慎性影响
	weight += ai_caution * 0.2
	
	return min(weight, 1.0)

# 计算治疗权重
func calculate_heal_weight(player: Player, enemies: Array, available_skills: Array) -> float:
	if not auto_combat_settings["auto_heal"]:
		return 0.0
	
	# 检查是否有治疗技能
	var has_heal_skill = false
	for skill in available_skills:
		if skill.damage_type == "heal" or skill.heal_amount > 0:
			has_heal_skill = true
			break
	
	if not has_heal_skill:
		return 0.0
	
	var weight = 0.0
	
	# 如果玩家生命值低，增加治疗权重
	var player_health_ratio = player.get_combat_current_health() / player.get_combat_max_health()
	if player_health_ratio < ai_heal_threshold:
		weight += 0.8
	
	# 如果敌人攻击力很高，增加治疗权重
	var strongest_enemy = get_strongest_enemy(enemies)
	if strongest_enemy:
		var enemy_attack = strongest_enemy.get_combat_attack_range()
		var player_defense = player.get_combat_defense()
		if (enemy_attack.min + enemy_attack.max) / 2.0 > player_defense:
			weight += 0.2
	
	return min(weight, 1.0)

# 计算逃跑权重
func calculate_escape_weight(player: Player, enemies: Array) -> float:
	if not auto_combat_settings["auto_escape"]:
		return 0.0
	
	var weight = 0.0
	
	# 如果玩家生命值极低，增加逃跑权重
	var player_health_ratio = player.get_combat_current_health() / player.get_combat_max_health()
	if player_health_ratio < ai_escape_threshold:
		weight += 0.6
	
	# 如果敌人太强，增加逃跑权重
	var strongest_enemy = get_strongest_enemy(enemies)
	if strongest_enemy:
		var enemy_attack = strongest_enemy.get_combat_attack_range()
		var player_attack = player.get_combat_attack_range()
		var enemy_health = strongest_enemy.get_combat_max_health()
		var player_health = player.get_combat_max_health()
		
		# 如果敌人攻击力是玩家的2倍以上，且生命值比玩家多
		if (enemy_attack.min + enemy_attack.max) / 2.0 > (player_attack.min + player_attack.max) * 2.0 and enemy_health > player_health:
			weight += 0.4
	
	return min(weight, 1.0)

# 选择最佳决策
func select_best_decision(weights: Dictionary) -> PlayerAIDecisionType:
	var best_decision = PlayerAIDecisionType.ATTACK
	var best_weight = 0.0
	
	for decision in weights:
		if weights[decision] > best_weight:
			best_weight = weights[decision]
			best_decision = decision
	
	# 如果所有权重都很低，默认选择攻击
	if best_weight < 0.1:
		return PlayerAIDecisionType.ATTACK
	
	return best_decision

# 根据决策创建行动
func create_action_from_decision(player: Player, enemies: Array, decision: PlayerAIDecisionType, available_skills: Array) -> CombatAction:
	match decision:
		PlayerAIDecisionType.ATTACK:
			return create_attack_action(player, enemies)
		PlayerAIDecisionType.SKILL:
			return create_skill_action(player, enemies, available_skills)
		PlayerAIDecisionType.DEFEND:
			return create_defend_action(player)
		PlayerAIDecisionType.HEAL:
			return create_heal_action(player, available_skills)
		PlayerAIDecisionType.ESCAPE:
			return create_escape_action(player)
		_:
			return create_attack_action(player, enemies)

# 创建攻击行动
func create_attack_action(player: Player, enemies: Array) -> CombatAction:
	var target = select_attack_target(player, enemies)
	return CombatAction.new(CombatAction.ActionType.ATTACK, player, target)

# 创建技能行动
func create_skill_action(player: Player, enemies: Array, available_skills: Array) -> CombatAction:
	# 过滤掉基础攻击技能
	var non_basic_skills = available_skills.filter(func(s): return s.skill_name != "基础攻击")
	
	if non_basic_skills.is_empty():
		return create_attack_action(player, enemies)
	
	# 选择最佳技能
	var best_skill = select_best_skill(player, enemies, non_basic_skills)
	if not best_skill:
		return create_attack_action(player, enemies)
	
	# 选择目标
	var target = select_skill_target(player, enemies, best_skill)
	
	return CombatAction.new(CombatAction.ActionType.SKILL, player, target, best_skill)

# 创建防御行动
func create_defend_action(player: Player) -> CombatAction:
	return CombatAction.new(CombatAction.ActionType.DEFEND, player)

# 创建治疗行动
func create_heal_action(player: Player, available_skills: Array) -> CombatAction:
	var heal_skills = available_skills.filter(func(s): return s.damage_type == "heal" or s.heal_amount > 0)
	
	if heal_skills.is_empty():
		return create_attack_action(player, [])
	
	var best_heal_skill = heal_skills[0]
	return CombatAction.new(CombatAction.ActionType.SKILL, player, player, best_heal_skill)

# 创建逃跑行动
func create_escape_action(player: Player) -> CombatAction:
	return CombatAction.new(CombatAction.ActionType.ESCAPE, player)

# 选择攻击目标
func select_attack_target(_player: Player, enemies: Array) -> Combatant:
	# 获取所有活着的敌人
	var alive_enemies = []
	for enemy in enemies:
		if enemy and enemy.is_alive_in_battle():
			alive_enemies.append(enemy)
	
	if alive_enemies.is_empty():
		return null
	
	# 随机选择一个活着的敌人
	var random_index = randi() % alive_enemies.size()
	return alive_enemies[random_index]

# 选择技能目标
func select_skill_target(player: Player, enemies: Array, skill) -> Combatant:
	match skill.target_type:
		"player":
			return player
		"self":
			return player
		"enemy":
			return select_attack_target(player, enemies)
		"all_enemies":
			# 选择活着的敌人
			var alive_enemies = []
			for enemy in enemies:
				if enemy and enemy.is_alive_in_battle():
					alive_enemies.append(enemy)
			return alive_enemies[0] if not alive_enemies.is_empty() else null
		_:
			return select_attack_target(player, enemies)

# 选择最佳技能
func select_best_skill(_player: Player, _enemies: Array, skills: Array) -> Skill:
	if skills.is_empty():
		return null
	
	# 根据技能优先级选择
	match auto_combat_settings["skill_priority"]:
		"damage":
			return select_damage_skill(skills)
		"heal":
			return select_heal_skill(skills)
		"buff":
			return select_buff_skill(skills)
		"debuff":
			return select_debuff_skill(skills)
		_:
			return select_damage_skill(skills)

# 选择伤害技能
func select_damage_skill(skills: Array) -> Skill:
	var damage_skills = skills.filter(func(s): return s.damage_type in ["physical", "qi", "fire", "ice", "lightning", "dark", "spirit", "evil"])
	
	if damage_skills.is_empty():
		return skills[0]
	
	# 选择伤害最高的技能
	var best_skill = damage_skills[0]
	var best_damage = 0.0
	
	for skill in damage_skills:
		var estimated_damage = skill.base_damage * skill.damage_multiplier
		if estimated_damage > best_damage:
			best_damage = estimated_damage
			best_skill = skill
	
	return best_skill

# 选择治疗技能
func select_heal_skill(skills: Array) -> Skill:
	var heal_skills = skills.filter(func(s): return s.damage_type == "heal" or s.heal_amount > 0)
	
	if heal_skills.is_empty():
		return skills[0]
	
	# 选择治疗量最高的技能
	var best_skill = heal_skills[0]
	var best_heal = 0.0
	
	for skill in heal_skills:
		var heal_amount = skill.heal_amount if skill.heal_amount > 0 else skill.base_damage * skill.damage_multiplier
		if heal_amount > best_heal:
			best_heal = heal_amount
			best_skill = skill
	
	return best_skill

# 选择增益技能
func select_buff_skill(skills: Array) -> Skill:
	var buff_skills = skills.filter(func(s): return s.effect_type in ["attack_boost", "defense_boost", "speed_boost", "power_boost"])
	
	if buff_skills.is_empty():
		return skills[0]
	
	return buff_skills[0]

# 选择减益技能
func select_debuff_skill(skills: Array) -> Skill:
	var debuff_skills = skills.filter(func(s): return s.effect_type in ["attack_debuff", "defense_debuff", "speed_debuff", "bleed", "burn", "poison"])
	
	if debuff_skills.is_empty():
		return skills[0]
	
	return debuff_skills[0]

# 获取最弱的敌人
func get_weakest_enemy(enemies: Array) -> Combatant:
	if enemies.is_empty():
		return null
	
	var weakest_enemy = null
	var lowest_health = 999999.0
	
	for enemy in enemies:
		if enemy and enemy.is_alive_in_battle():
			var health_ratio = enemy.get_combat_current_health() / enemy.get_combat_max_health()
			if health_ratio < lowest_health:
				lowest_health = health_ratio
				weakest_enemy = enemy
	
	return weakest_enemy

# 获取最强的敌人
func get_strongest_enemy(enemies: Array) -> Combatant:
	if enemies.is_empty():
		return null
	
	var strongest_enemy = null
	var highest_attack = 0.0
	
	for enemy in enemies:
		if enemy and enemy.is_alive_in_battle():
			var attack_range = enemy.get_combat_attack_range()
			var avg_attack = (attack_range.min + attack_range.max) / 2.0
			if avg_attack > highest_attack:
				highest_attack = avg_attack
				strongest_enemy = enemy
	
	return strongest_enemy

# 设置自动战斗设置
func set_auto_combat_setting(key: String, value) -> void:
	if key in auto_combat_settings:
		auto_combat_settings[key] = value

# 获取自动战斗设置
func get_auto_combat_setting(key: String):
	return auto_combat_settings.get(key, null)
