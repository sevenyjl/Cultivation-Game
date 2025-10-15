# scripts/combat/Skill.gd
class_name Skill
extends Resource

# 技能基本属性
@export var skill_name: String = ""
@export var description: String = ""
@export var damage_type: String = "physical"  # 伤害类型：physical, qi, fire, ice, lightning, dark, spirit, evil, divine, chaos
@export var base_damage: float = 1.0  # 基础伤害倍率
@export var damage_multiplier: float = 1.0  # 伤害倍率
@export var qi_cost: float = 0.0  # 灵气消耗
@export var cooldown: int = 0  # 冷却回合数
@export var target_type: String = "enemy"  # 目标类型：enemy, player, self, all_enemies, all_players
@export var skill_range: int = 1  # 技能范围

# 治疗效果
@export var heal_amount: float = 0.0  # 治疗量

# 状态效果
@export var effect_type: String = ""  # 效果类型：buff, debuff, bleed, burn, freeze, etc.
@export var effect_value: float = 0.0  # 效果数值
@export var effect_duration: int = 0  # 效果持续时间（回合数）
@export var effect_chance: float = 1.0  # 效果触发概率

# 技能状态
var current_cooldown: int = 0  # 当前冷却时间
var is_usable: bool = true  # 是否可用

# 技能等级（用于技能升级）
@export var skill_level: int = 1
@export var max_level: int = 10

# 技能解锁等级
@export var unlock_level: int = 1

# 检查技能是否可以使用
func can_use(caster) -> bool:
	if not is_usable:
		return false
	
	if current_cooldown > 0:
		return false
	
	if caster.qi < qi_cost:
		return false
	
	return true

# 使用技能
func use_skill(caster, target) -> Dictionary:
	if not can_use(caster):
		return {"success": false, "message": "技能无法使用"}
	
	# 消耗灵气
	caster.qi -= qi_cost
	
	# 设置冷却
	current_cooldown = cooldown
	
	var result = {"success": true, "damage": 0.0, "heal": 0.0, "effects": []}
	
	# 计算伤害
	if base_damage > 0.0:
		var damage = calculate_damage(caster, target)
		result["damage"] = damage
		
		# 应用伤害
		if target and target.is_alive_in_battle():
			var actual_damage = target.take_combat_damage(damage, damage_type)
			result["actual_damage"] = actual_damage
	
	# 计算治疗
	if heal_amount > 0.0:
		var heal = calculate_heal(caster, target)
		result["heal"] = heal
		
		# 应用治疗
		if target and target.is_alive_in_battle():
			var actual_heal = target.restore_combat_health(heal)
			result["actual_heal"] = actual_heal
	
	# 应用状态效果
	if effect_type != "" and effect_value != 0.0:
		var effect_result = apply_effect(caster, target)
		result["effects"].append(effect_result)
	
	return result

# 计算伤害
func calculate_damage(caster, target) -> float:
	if not caster or not target:
		return 0.0
	
	# 获取攻击力范围
	var attack_range = caster.get_combat_attack_range()
	var base_attack = attack_range.min + randf() * (attack_range.max - attack_range.min)
	
	# 计算最终伤害
	var damage = base_attack * base_damage * damage_multiplier
	
	# 应用暴击
	if caster.calculate_critical():
		damage *= caster.critical_multiplier
	
	# 应用闪避
	if target.calculate_dodge():
		damage = 0.0
	
	return damage

# 计算治疗量
func calculate_heal(caster, target) -> float:
	if not caster or not target:
		return 0.0
	
	# 基础治疗量
	var heal = heal_amount
	
	# 可以根据施法者属性调整治疗量
	# 例如：治疗量 = 基础治疗量 * (1 + 施法者等级 * 0.1)
	heal *= (1.0 + caster.level * 0.1)
	
	return heal

# 应用状态效果
func apply_effect(caster, target) -> Dictionary:
	if not caster or not target:
		return {"success": false}
	
	# 检查效果触发概率
	if randf() > effect_chance:
		return {"success": false, "message": "效果未触发"}
	
	# 创建效果对象
	var effect = preload("res://classs/combat/CombatEffect.gd").new()
	effect.effect_type = effect_type
	effect.effect_value = effect_value
	effect.duration = effect_duration
	effect.source = caster
	
	# 应用效果到目标
	target.add_effect(effect)
	
	return {
		"success": true,
		"effect_type": effect_type,
		"effect_value": effect_value,
		"duration": effect_duration
	}

# 更新冷却时间
func update_cooldown() -> void:
	if current_cooldown > 0:
		current_cooldown -= 1
		if current_cooldown <= 0:
			is_usable = true

# 重置技能状态
func reset_skill() -> void:
	current_cooldown = 0
	is_usable = true

# 升级技能
func level_up_skill() -> bool:
	if skill_level >= max_level:
		return false
	
	skill_level += 1
	
	# 升级时提升技能效果
	base_damage *= 1.1
	damage_multiplier *= 1.05
	heal_amount *= 1.1
	effect_value *= 1.1
	
	return true

# 获取技能信息
func get_skill_info() -> Dictionary:
	return {
		"name": skill_name,
		"description": description,
		"damage_type": damage_type,
		"base_damage": base_damage,
		"damage_multiplier": damage_multiplier,
		"qi_cost": qi_cost,
		"cooldown": cooldown,
		"current_cooldown": current_cooldown,
		"target_type": target_type,
		"range": skill_range,
		"heal_amount": heal_amount,
		"effect_type": effect_type,
		"effect_value": effect_value,
		"effect_duration": effect_duration,
		"effect_chance": effect_chance,
		"skill_level": skill_level,
		"max_level": max_level,
		"unlock_level": unlock_level,
		"is_usable": is_usable
	}

# 获取技能描述（用于UI显示）
func get_skill_description() -> String:
	var desc = description + "\n"
	
	if base_damage > 0.0:
		desc += "伤害: " + str(base_damage) + "x\n"
	
	if heal_amount > 0.0:
		desc += "治疗: " + str(heal_amount) + "\n"
	
	if qi_cost > 0.0:
		desc += "灵气消耗: " + str(qi_cost) + "\n"
	
	if cooldown > 0:
		desc += "冷却: " + str(cooldown) + "回合\n"
	
	if effect_type != "":
		desc += "效果: " + effect_type + "\n"
	
	return desc

# 检查技能是否在冷却中
func is_on_cooldown() -> bool:
	return current_cooldown > 0

# 获取剩余冷却时间
func get_remaining_cooldown() -> int:
	return current_cooldown

# 设置技能不可用
func set_unusable() -> void:
	is_usable = false

# 设置技能可用
func set_usable() -> void:
	is_usable = true
