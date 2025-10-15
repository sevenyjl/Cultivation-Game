# scripts/combat/CombatAction.gd
class_name CombatAction
extends Resource

# 行为类型枚举
enum ActionType {
	ATTACK,     # 攻击
	SKILL,      # 技能
	DEFEND,     # 防御
	ITEM,       # 使用物品
	ESCAPE      # 逃跑
}

# 行为基本属性
@export var action_type: ActionType = ActionType.ATTACK
var actor  # 执行者
var target  # 目标
var skill  # 使用的技能（如果是技能行为）
@export var priority: int = 0  # 优先级（用于排序）

# 行为结果
var result: Dictionary = {}
var is_executed: bool = false
var execution_time: float = 0.0  # 执行时间（用于动画）

# 构造函数
func _init(action_type_param: ActionType, actor_param, target_param = null, skill_param = null):
	self.action_type = action_type_param
	self.actor = actor_param
	self.target = target_param
	self.skill = skill_param
	self.priority = calculate_priority()

# 计算优先级
func calculate_priority() -> int:
	if not actor:
		return 0
	
	# 基础优先级基于速度
	var base_priority = int(actor.get_combat_speed())
	
	# 根据行为类型调整优先级
	match action_type:
		ActionType.ATTACK:
			base_priority += 10
		ActionType.SKILL:
			base_priority += 5
		ActionType.DEFEND:
			base_priority += 15
		ActionType.ITEM:
			base_priority += 20
		ActionType.ESCAPE:
			base_priority += 25
	
	return base_priority

# 执行行为
func execute() -> Dictionary:
	if is_executed:
		return result
	
	result = {"success": false, "message": "", "damage": 0.0, "heal": 0.0, "effects": []}
	
	if not actor or not actor.is_alive_in_battle():
		result["message"] = "执行者已死亡"
		is_executed = true
		return result
	
	match action_type:
		ActionType.ATTACK:
			execute_attack()
		ActionType.SKILL:
			execute_skill()
		ActionType.DEFEND:
			execute_defend()
		ActionType.ITEM:
			execute_item()
		ActionType.ESCAPE:
			execute_escape()
	
	is_executed = true
	return result

# 执行攻击
func execute_attack() -> void:
	if not target or not target.is_alive_in_battle():
		result["message"] = "目标已死亡"
		return
	
	# 计算攻击力
	var attack_range = actor.get_combat_attack_range()
	var damage = attack_range.min + randf() * (attack_range.max - attack_range.min)
	
	# 应用暴击
	if actor.calculate_critical():
		damage *= actor.critical_multiplier
		result["critical"] = true
	
	# 检查目标闪避
	if target.calculate_dodge():
		result["dodged"] = true
		result["message"] = "攻击被闪避"
		return
	
	# 应用伤害
	var actual_damage = target.take_combat_damage(damage, "physical")
	result["damage"] = damage
	result["actual_damage"] = actual_damage
	result["success"] = true
	result["message"] = "造成 " + str(actual_damage) + " 点伤害"

# 执行技能
func execute_skill() -> void:
	if not skill:
		result["message"] = "没有指定技能"
		return
	
	if not skill.can_use(actor):
		result["message"] = "技能无法使用"
		return
	
	# 使用技能
	var skill_result = skill.use_skill(actor, target)
	result = skill_result
	
	if skill_result["success"]:
		result["message"] = "使用了技能: " + skill.skill_name
	else:
		result["message"] = skill_result.get("message", "技能使用失败")

# 执行防御
func execute_defend() -> void:
	# 防御行为：提升防御力，减少受到的伤害
	var defense_boost = 20.0  # 防御提升20点
	
	# 创建防御效果
	var effect = preload("res://classs/combat/CombatEffect.gd").new()
	effect.effect_type = "defense_boost"
	effect.effect_value = defense_boost
	effect.duration = 1  # 持续1回合
	effect.source = actor
	
	actor.add_effect(effect)
	
	result["success"] = true
	result["message"] = "进入防御状态"
	result["effects"] = [{"type": "defense_boost", "value": defense_boost, "duration": 1}]

# 执行使用物品
func execute_item() -> void:
	# 这里可以扩展物品系统
	result["message"] = "物品系统暂未实现"
	result["success"] = false

# 执行逃跑
func execute_escape() -> void:
	# 逃跑成功率基于速度差异
	var escape_chance = 0.3  # 基础逃跑率30%
	
	# 如果有目标，根据速度差异调整逃跑率
	if target:
		var speed_diff = actor.get_combat_speed() - target.get_combat_speed()
		escape_chance += speed_diff * 0.01  # 每点速度差异增加1%逃跑率
	
	escape_chance = clamp(escape_chance, 0.1, 0.9)  # 限制在10%-90%之间
	
	if randf() < escape_chance:
		result["success"] = true
		result["message"] = "成功逃跑"
	else:
		result["success"] = false
		result["message"] = "逃跑失败"

# 获取行为描述
func get_action_description() -> String:
	if not actor:
		return "无效行为"
	
	var desc = actor.get_name_info() + " "
	
	match action_type:
		ActionType.ATTACK:
			desc += "攻击"
			if target:
				desc += " " + target.get_name_info()
		ActionType.SKILL:
			desc += "使用技能"
			if skill:
				desc += " " + skill.skill_name
			if target:
				desc += " 对 " + target.get_name_info()
		ActionType.DEFEND:
			desc += "防御"
		ActionType.ITEM:
			desc += "使用物品"
		ActionType.ESCAPE:
			desc += "逃跑"
	
	return desc

# 检查行为是否有效
func is_valid() -> bool:
	if not actor or not actor.is_alive_in_battle():
		return false
	
	match action_type:
		ActionType.ATTACK:
			return target != null and target.is_alive_in_battle()
		ActionType.SKILL:
			return skill != null and skill.can_use(actor) and (target != null or skill.target_type == "self")
		ActionType.DEFEND:
			return true
		ActionType.ITEM:
			return true  # 物品系统暂未实现
		ActionType.ESCAPE:
			return true
	
	return false

# 获取行为执行时间
func get_execution_time() -> float:
	match action_type:
		ActionType.ATTACK:
			return 1.0
		ActionType.SKILL:
			return 1.5
		ActionType.DEFEND:
			return 0.5
		ActionType.ITEM:
			return 1.0
		ActionType.ESCAPE:
			return 0.8
	
	return 1.0

# 获取行为信息
func get_action_info() -> Dictionary:
	return {
		"action_type": action_type,
		"actor_name": actor.get_name_info() if actor else "未知",
		"target_name": target.get_name_info() if target else "无",
		"skill_name": skill.skill_name if skill else "无",
		"priority": priority,
		"is_executed": is_executed,
		"is_valid": is_valid(),
		"execution_time": get_execution_time()
	}
