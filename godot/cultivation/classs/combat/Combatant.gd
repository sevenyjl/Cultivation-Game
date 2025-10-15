# scripts/combat/Combatant.gd
class_name Combatant
extends Cultivator

# 战斗相关属性
@export var speed: float = 100.0  # 速度，影响行动顺序
@export var defense: float = 0.0  # 防御力，减少受到的伤害
@export var critical_chance: float = 0.05  # 暴击率
@export var critical_multiplier: float = 1.5  # 暴击倍率
@export var dodge_chance: float = 0.05  # 闪避率

# 战斗状态
var is_alive_in_combat: bool = true
var current_effects: Array = []  # 当前状态效果
var combat_position: Vector2 = Vector2.ZERO  # 战斗中的位置

# 技能列表
var available_skills: Array = []

# 获取战斗中的最大生命值
func get_combat_max_health() -> float:
	return get_max_health()

# 获取战斗中的当前生命值
func get_combat_current_health() -> float:
	return health_current

# 获取战斗中的攻击力范围
func get_combat_attack_range() -> Dictionary:
	var base_range = get_attack_range()
	# 可以在这里添加战斗中的攻击力修正
	return base_range

# 获取战斗中的防御力
func get_combat_defense() -> float:
	return defense

# 获取战斗中的速度
func get_combat_speed() -> float:
	return speed

# 检查是否存活（战斗专用）
func is_alive_in_battle() -> bool:
	return is_alive_in_combat and health_current > 0.0

# 受到战斗伤害
func take_combat_damage(damage: float, _damage_type: String = "physical") -> float:
	if not is_alive_in_battle():
		return 0.0
	
	# 计算实际伤害（考虑防御力）
	var actual_damage = max(0.0, damage - get_combat_defense())
	
	# 应用伤害
	take_damage(actual_damage)
	
	# 检查是否死亡
	if health_current <= 0.0:
		is_alive_in_combat = false
	
	return actual_damage

# 恢复战斗中的生命值
func restore_combat_health(amount: float) -> float:
	if not is_alive_in_battle():
		return 0.0
	
	var max_health = get_combat_max_health()
	var old_health = health_current
	health_current = min(health_current + amount, max_health)
	var actual_restore = health_current - old_health
	
	return actual_restore

# 添加状态效果
func add_effect(effect) -> void:
	if effect:
		current_effects.append(effect)
		effect.apply_to(self)

# 移除状态效果
func remove_effect(effect) -> void:
	if effect in current_effects:
		effect.remove_from(self)
		current_effects.erase(effect)

# 更新状态效果（每回合调用）
func update_effects() -> void:
	var effects_to_remove = []
	
	for effect in current_effects:
		effect.tick(self)
		if effect.is_expired():
			effects_to_remove.append(effect)
	
	# 移除过期的效果
	for effect in effects_to_remove:
		remove_effect(effect)

# 获取所有状态效果
func get_effects() -> Array:
	return current_effects.duplicate()

# 检查是否有特定类型的效果
func has_effect_type(effect_type: String) -> bool:
	for effect in current_effects:
		if effect.effect_type == effect_type:
			return true
	return false

# 获取特定类型的效果
func get_effects_by_type(effect_type: String) -> Array:
	var effects = []
	for effect in current_effects:
		if effect.effect_type == effect_type:
			effects.append(effect)
	return effects

# 计算暴击
func calculate_critical() -> bool:
	return randf() < critical_chance

# 计算闪避
func calculate_dodge() -> bool:
	return randf() < dodge_chance

# 获取最终伤害倍率（考虑暴击）
func get_damage_multiplier() -> float:
	if calculate_critical():
		return critical_multiplier
	return 1.0

# 添加技能
func add_skill(skill) -> void:
	if skill and not skill in available_skills:
		available_skills.append(skill)

# 移除技能
func remove_skill(skill) -> void:
	if skill in available_skills:
		available_skills.erase(skill)

# 获取可用技能
func get_available_skills() -> Array:
	return available_skills.duplicate()

# 获取可用的技能（过滤掉冷却中的）
func get_usable_skills() -> Array:
	var usable_skills = []
	for skill in available_skills:
		if skill.can_use(self):
			usable_skills.append(skill)
	return usable_skills

# 重置战斗状态（战斗开始时调用）
func reset_combat_state() -> void:
	is_alive_in_combat = true
	current_effects.clear()
	# 确保生命值不超过最大值
	health_current = min(health_current, get_combat_max_health())

# 获取战斗信息
func get_combat_info() -> Dictionary:
	return {
		"name": get_name_info(),
		"level": level,
		"stage": stage_name,
		"health": health_current,
		"max_health": get_combat_max_health(),
		"attack_range": get_combat_attack_range(),
		"defense": get_combat_defense(),
		"speed": get_combat_speed(),
		"is_alive": is_alive_in_battle(),
		"effects": current_effects.size()
	}
