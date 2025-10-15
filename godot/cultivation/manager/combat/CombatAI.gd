# scripts/managers/combat/CombatAI.gd
class_name CombatAI
extends Node

# AI决策类型
enum AIDecisionType {
	ATTACK,     # 攻击
	SKILL,      # 使用技能
	DEFEND,     # 防御
	HEAL,       # 治疗
	BUFF,       # 增益
	DEBUFF      # 减益
}

# AI配置
@export var ai_aggression_threshold: float = 0.5  # 攻击性阈值
@export var ai_heal_threshold: float = 0.3  # 治疗阈值
@export var ai_skill_usage_chance: float = 0.7  # 技能使用概率

func _init():
	pass

# 选择行动
func choose_action(enemy, player, all_enemies: Array) -> CombatAction:
	if not enemy or not enemy.is_alive_in_battle():
		return null
	
	# 获取可用技能
	var available_skills = enemy.get_usable_skills()
	
	# 决策权重
	var decision_weights = calculate_decision_weights(enemy, player, available_skills)
	
	# 选择最佳决策
	var decision = select_best_decision(decision_weights)
	
	# 创建对应的行动
	return create_action_from_decision(enemy, player, all_enemies, decision, available_skills)

# 计算决策权重
func calculate_decision_weights(enemy, player, available_skills: Array) -> Dictionary:
	var weights = {
		AIDecisionType.ATTACK: 0.0,
		AIDecisionType.SKILL: 0.0,
		AIDecisionType.DEFEND: 0.0,
		AIDecisionType.HEAL: 0.0,
		AIDecisionType.BUFF: 0.0,
		AIDecisionType.DEBUFF: 0.0
	}
	
	# 基础攻击权重
	weights[AIDecisionType.ATTACK] = calculate_attack_weight(enemy, player)
	
	# 技能权重
	weights[AIDecisionType.SKILL] = calculate_skill_weight(enemy, player, available_skills)
	
	# 防御权重
	weights[AIDecisionType.DEFEND] = calculate_defend_weight(enemy, player)
	
	# 治疗权重
	weights[AIDecisionType.HEAL] = calculate_heal_weight(enemy, player, available_skills)
	
	# 增益权重
	weights[AIDecisionType.BUFF] = calculate_buff_weight(enemy, player, available_skills)
	
	# 减益权重
	weights[AIDecisionType.DEBUFF] = calculate_debuff_weight(enemy, player, available_skills)
	
	return weights

# 计算攻击权重
func calculate_attack_weight(enemy, player) -> float:
	if not player or not player.is_alive_in_battle():
		return 0.0
	
	# 基础攻击性
	var weight = enemy.ai_aggression
	
	# 如果玩家生命值低，增加攻击权重
	var player_health_ratio = player.get_combat_current_health() / player.get_combat_max_health()
	if player_health_ratio < 0.5:
		weight += 0.3
	
	# 如果敌人生命值低，增加攻击权重
	var enemy_health_ratio = enemy.get_combat_current_health() / enemy.get_combat_max_health()
	if enemy_health_ratio < 0.3:
		weight += 0.2
	
	return weight

# 计算技能权重
func calculate_skill_weight(enemy, _player, available_skills: Array) -> float:
	if available_skills.is_empty():
		return 0.0
	
	# 基础技能使用概率
	var weight = enemy.ai_intelligence * ai_skill_usage_chance
	
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
	
	return min(weight, 1.0)

# 计算防御权重
func calculate_defend_weight(enemy, player) -> float:
	if not player or not player.is_alive_in_battle():
		return 0.0
	
	var weight = 0.0
	
	# 如果敌人生命值很低，增加防御权重
	var enemy_health_ratio = enemy.get_combat_current_health() / enemy.get_combat_max_health()
	if enemy_health_ratio < 0.2:
		weight += 0.4
	
	# 如果玩家攻击力很高，增加防御权重
	var player_attack = player.get_combat_attack_range()
	var avg_player_attack = (player_attack.min + player_attack.max) / 2.0
	var enemy_defense = enemy.get_combat_defense()
	
	if avg_player_attack > enemy_defense * 2.0:
		weight += 0.3
	
	return min(weight, 1.0)

# 计算治疗权重
func calculate_heal_weight(enemy, player, available_skills: Array) -> float:
	var weight = 0.0
	
	# 检查是否有治疗技能
	var has_heal_skill = false
	for skill in available_skills:
		if skill.damage_type == "heal" or skill.heal_amount > 0:
			has_heal_skill = true
			break
	
	if not has_heal_skill:
		return 0.0
	
	# 如果敌人生命值低，增加治疗权重
	var enemy_health_ratio = enemy.get_combat_current_health() / enemy.get_combat_max_health()
	if enemy_health_ratio < ai_heal_threshold:
		weight += 0.8
	
	# 如果玩家攻击力很高，增加治疗权重
	if player:
		var player_attack = player.get_combat_attack_range()
		var avg_player_attack = (player_attack.min + player_attack.max) / 2.0
		if avg_player_attack > enemy.get_combat_defense():
			weight += 0.2
	
	return min(weight, 1.0)

# 计算增益权重
func calculate_buff_weight(enemy, _player, available_skills: Array) -> float:
	var weight = 0.0
	
	# 检查是否有增益技能
	var has_buff_skill = false
	for skill in available_skills:
		if skill.effect_type in ["attack_boost", "defense_boost", "speed_boost", "power_boost"]:
			has_buff_skill = true
			break
	
	if not has_buff_skill:
		return 0.0
	
	# 如果敌人没有增益效果，增加增益权重
	if not enemy.has_effect_type("attack_boost") and not enemy.has_effect_type("defense_boost"):
		weight += 0.3
	
	# 如果战斗刚开始，增加增益权重
	# 这里可以根据回合数来判断
	weight += 0.1
	
	return min(weight, 1.0)

# 计算减益权重
func calculate_debuff_weight(enemy, player, available_skills: Array) -> float:
	if not player or not player.is_alive_in_battle():
		return 0.0
	
	var weight = 0.0
	
	# 检查是否有减益技能
	var has_debuff_skill = false
	for skill in available_skills:
		if skill.effect_type in ["attack_debuff", "defense_debuff", "speed_debuff", "bleed", "burn", "poison"]:
			has_debuff_skill = true
			break
	
	if not has_debuff_skill:
		return 0.0
	
	# 如果玩家没有减益效果，增加减益权重
	if not player.has_effect_type("attack_debuff") and not player.has_effect_type("defense_debuff"):
		weight += 0.4
	
	# 如果玩家攻击力很高，增加减益权重
	var player_attack = player.get_combat_attack_range()
	var avg_player_attack = (player_attack.min + player_attack.max) / 2.0
	if avg_player_attack > enemy.get_combat_defense():
		weight += 0.2
	
	return min(weight, 1.0)

# 选择最佳决策
func select_best_decision(weights: Dictionary) -> AIDecisionType:
	var best_decision = AIDecisionType.ATTACK
	var best_weight = 0.0
	
	for decision in weights:
		if weights[decision] > best_weight:
			best_weight = weights[decision]
			best_decision = decision
	
	# 如果所有权重都很低，默认选择攻击
	if best_weight < 0.1:
		return AIDecisionType.ATTACK
	
	return best_decision

# 根据决策创建行动
func create_action_from_decision(enemy, player, all_enemies: Array, decision: AIDecisionType, available_skills: Array) -> CombatAction:
	match decision:
		AIDecisionType.ATTACK:
			return create_attack_action(enemy, player)
		AIDecisionType.SKILL:
			return create_skill_action(enemy, player, all_enemies, available_skills)
		AIDecisionType.DEFEND:
			return create_defend_action(enemy)
		AIDecisionType.HEAL:
			return create_heal_action(enemy, available_skills)
		AIDecisionType.BUFF:
			return create_buff_action(enemy, available_skills)
		AIDecisionType.DEBUFF:
			return create_debuff_action(enemy, player, available_skills)
		_:
			return create_attack_action(enemy, player)

# 创建攻击行动
func create_attack_action(enemy, player) -> CombatAction:
	return CombatAction.new(CombatAction.ActionType.ATTACK, enemy, player)

# 创建技能行动
func create_skill_action(enemy, player, all_enemies: Array, available_skills: Array) -> CombatAction:
	# 过滤掉基础攻击技能
	var non_basic_skills = available_skills.filter(func(s): return s.skill_name != "基础攻击")
	
	if non_basic_skills.is_empty():
		return create_attack_action(enemy, player)
	
	# 选择最佳技能
	var best_skill = select_best_skill(enemy, player, non_basic_skills)
	if not best_skill:
		return create_attack_action(enemy, player)
	
	# 选择目标
	var target = select_skill_target(enemy, player, all_enemies, best_skill)
	
	return CombatAction.new(CombatAction.ActionType.SKILL, enemy, target, best_skill)

# 创建防御行动
func create_defend_action(enemy) -> CombatAction:
	return CombatAction.new(CombatAction.ActionType.DEFEND, enemy)

# 创建治疗行动
func create_heal_action(enemy, available_skills: Array) -> CombatAction:
	var heal_skills = available_skills.filter(func(s): return s.damage_type == "heal" or s.heal_amount > 0)
	
	if heal_skills.is_empty():
		return create_attack_action(enemy, null)
	
	var best_heal_skill = heal_skills[0]
	return CombatAction.new(CombatAction.ActionType.SKILL, enemy, enemy, best_heal_skill)

# 创建增益行动
func create_buff_action(enemy, available_skills: Array) -> CombatAction:
	var buff_skills = available_skills.filter(func(s): return s.effect_type in ["attack_boost", "defense_boost", "speed_boost", "power_boost"])
	
	if buff_skills.is_empty():
		return create_attack_action(enemy, null)
	
	var best_buff_skill = buff_skills[0]
	return CombatAction.new(CombatAction.ActionType.SKILL, enemy, enemy, best_buff_skill)

# 创建减益行动
func create_debuff_action(enemy, player, available_skills: Array) -> CombatAction:
	var debuff_skills = available_skills.filter(func(s): return s.effect_type in ["attack_debuff", "defense_debuff", "speed_debuff", "bleed", "burn", "poison"])
	
	if debuff_skills.is_empty():
		return create_attack_action(enemy, player)
	
	var best_debuff_skill = debuff_skills[0]
	return CombatAction.new(CombatAction.ActionType.SKILL, enemy, player, best_debuff_skill)

# 选择最佳技能
func select_best_skill(_enemy, _player, skills: Array):
	if skills.is_empty():
		return null
	
	# 简单的技能选择逻辑
	# 优先选择高伤害技能
	var best_skill = skills[0]
	var best_damage = 0.0
	
	for skill in skills:
		var estimated_damage = skill.base_damage * skill.damage_multiplier
		if estimated_damage > best_damage:
			best_damage = estimated_damage
			best_skill = skill
	
	return best_skill

# 选择技能目标
func select_skill_target(enemy, player, all_enemies: Array, skill) -> Combatant:
	match skill.target_type:
		"player":
			return player if player and player.is_alive_in_battle() else null
		"self":
			return enemy
		"enemy":
			# 选择生命值最低的敌人
			var lowest_health_enemy = null
			var lowest_health = 999999.0
			
			for e in all_enemies:
				if e and e.is_alive_in_battle():
					var health_ratio = e.get_combat_current_health() / e.get_combat_max_health()
					if health_ratio < lowest_health:
						lowest_health = health_ratio
						lowest_health_enemy = e
			
			return lowest_health_enemy
		"all_players":
			return player  # 对于群体技能，返回玩家作为代表
		"all_enemies":
			return all_enemies[0] if not all_enemies.is_empty() else null
		_:
			return player
