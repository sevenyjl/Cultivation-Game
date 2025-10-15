# scripts/combat/CombatEffect.gd
class_name CombatEffect
extends Resource

# 效果类型枚举
enum EffectType {
	BUFF,           # 增益效果
	DEBUFF,         # 减益效果
	DOT,            # 持续伤害
	HOT,            # 持续治疗
	SHIELD,         # 护盾
	STUN,           # 眩晕
	FREEZE,         # 冰冻
	BURN,           # 燃烧
	BLEED,          # 流血
	POISON,         # 中毒
	REGENERATION,   # 再生
	BERSERKER,      # 狂暴
	INVISIBLE,      # 隐身
	IMMUNE,         # 免疫
	CURSE,          # 诅咒
	BLESSING        # 祝福
}

# 效果基本属性
@export var effect_type: String = ""  # 效果类型字符串
@export var effect_value: float = 0.0  # 效果数值
@export var duration: int = 0  # 持续时间（回合数）
var source  # 效果来源
@export var is_permanent: bool = false  # 是否永久效果

# 效果状态
var current_duration: int = 0  # 当前剩余时间
var is_active: bool = true  # 是否激活
var tick_count: int = 0  # 已触发的次数

# 构造函数
func _init(effect_type_param: String = "", effect_value_param: float = 0.0, duration_param: int = 0, source_param = null):
	self.effect_type = effect_type_param
	self.effect_value = effect_value_param
	self.duration = duration_param
	self.source = source_param
	self.current_duration = duration_param

# 应用效果到目标
func apply_to(target) -> void:
	if not target or not is_active:
		return
	
	match effect_type:
		"attack_boost", "attack_debuff":
			apply_attack_modifier(target)
		"defense_boost", "defense_debuff":
			apply_defense_modifier(target)
		"speed_boost", "speed_debuff":
			apply_speed_modifier(target)
		"shield":
			apply_shield(target)
		"stun", "freeze":
			apply_control_effect(target)
		"burn", "bleed", "poison":
			apply_dot_effect(target)
		"regeneration":
			apply_hot_effect(target)
		"berserker":
			apply_berserker_effect(target)
		"invisible":
			apply_invisible_effect(target)
		"immune":
			apply_immune_effect(target)
		"curse", "blessing":
			apply_curse_blessing_effect(target)
		_:
			apply_generic_effect(target)

# 从目标移除效果
func remove_from(target) -> void:
	if not target:
		return
	
	match effect_type:
		"attack_boost", "attack_debuff":
			remove_attack_modifier(target)
		"defense_boost", "defense_debuff":
			remove_defense_modifier(target)
		"speed_boost", "speed_debuff":
			remove_speed_modifier(target)
		"shield":
			remove_shield(target)
		"stun", "freeze":
			remove_control_effect(target)
		"burn", "bleed", "poison":
			remove_dot_effect(target)
		"regeneration":
			remove_hot_effect(target)
		"berserker":
			remove_berserker_effect(target)
		"invisible":
			remove_invisible_effect(target)
		"immune":
			remove_immune_effect(target)
		"curse", "blessing":
			remove_curse_blessing_effect(target)
		_:
			remove_generic_effect(target)

# 每回合更新效果
func tick(target) -> void:
	if not target or not is_active:
		return
	
	# 减少持续时间
	if not is_permanent and current_duration > 0:
		current_duration -= 1
	
	# 执行效果
	match effect_type:
		"burn", "bleed", "poison":
			tick_dot_effect(target)
		"regeneration":
			tick_hot_effect(target)
		"shield":
			tick_shield_effect(target)
		_:
			tick_generic_effect(target)
	
	tick_count += 1

# 检查效果是否过期
func is_expired() -> bool:
	if is_permanent:
		return false
	return current_duration <= 0

# 应用攻击力修正
func apply_attack_modifier(_target) -> void:
	# 这里可以修改目标的攻击力属性
	# 由于攻击力是计算属性，我们通过效果值来影响
	pass

# 移除攻击力修正
func remove_attack_modifier(_target) -> void:
	pass

# 应用防御力修正
func apply_defense_modifier(target) -> void:
	# 修改目标的防御力
	target.defense += effect_value
	pass

# 移除防御力修正
func remove_defense_modifier(target) -> void:
	target.defense -= effect_value
	pass

# 应用速度修正
func apply_speed_modifier(target) -> void:
	target.speed += effect_value
	pass

# 移除速度修正
func remove_speed_modifier(target) -> void:
	target.speed -= effect_value
	pass

# 应用护盾
func apply_shield(_target) -> void:
	# 护盾值存储在效果中，在受到伤害时检查
	pass

# 移除护盾
func remove_shield(_target) -> void:
	pass

# 应用控制效果
func apply_control_effect(_target) -> void:
	# 眩晕、冰冻等效果
	pass

# 移除控制效果
func remove_control_effect(_target) -> void:
	pass

# 应用持续伤害效果
func apply_dot_effect(_target) -> void:
	pass

# 移除持续伤害效果
func remove_dot_effect(_target) -> void:
	pass

# 应用持续治疗效果
func apply_hot_effect(_target) -> void:
	pass

# 移除持续治疗效果
func remove_hot_effect(_target) -> void:
	pass

# 应用狂暴效果
func apply_berserker_effect(target) -> void:
	# 提升攻击力，降低防御力
	target.attack_base_min *= 1.5
	target.attack_base_max *= 1.5
	target.defense *= 0.5
	pass

# 移除狂暴效果
func remove_berserker_effect(target) -> void:
	target.attack_base_min /= 1.5
	target.attack_base_max /= 1.5
	target.defense /= 0.5
	pass

# 应用隐身效果
func apply_invisible_effect(_target) -> void:
	# 隐身效果，降低被攻击概率
	pass

# 移除隐身效果
func remove_invisible_effect(_target) -> void:
	pass

# 应用免疫效果
func apply_immune_effect(_target) -> void:
	# 免疫特定类型的伤害
	pass

# 移除免疫效果
func remove_immune_effect(_target) -> void:
	pass

# 应用诅咒/祝福效果
func apply_curse_blessing_effect(_target) -> void:
	pass

# 移除诅咒/祝福效果
func remove_curse_blessing_effect(_target) -> void:
	pass

# 应用通用效果
func apply_generic_effect(_target) -> void:
	pass

# 移除通用效果
func remove_generic_effect(_target) -> void:
	pass

# 持续伤害效果每回合触发
func tick_dot_effect(target) -> void:
	if not target.is_alive_in_battle():
		return
	
	var damage = effect_value
	target.take_combat_damage(damage, effect_type)
	pass

# 持续治疗效果每回合触发
func tick_hot_effect(target) -> void:
	if not target.is_alive_in_battle():
		return
	
	var heal = effect_value
	target.restore_combat_health(heal)
	pass

# 护盾效果每回合触发
func tick_shield_effect(_target) -> void:
	# 护盾值可能每回合减少
	pass

# 通用效果每回合触发
func tick_generic_effect(_target) -> void:
	pass

# 获取效果描述
func get_effect_description() -> String:
	var desc = ""
	
	match effect_type:
		"attack_boost":
			desc = "攻击力提升 " + str(effect_value)
		"attack_debuff":
			desc = "攻击力降低 " + str(abs(effect_value))
		"defense_boost":
			desc = "防御力提升 " + str(effect_value)
		"defense_debuff":
			desc = "防御力降低 " + str(abs(effect_value))
		"speed_boost":
			desc = "速度提升 " + str(effect_value)
		"speed_debuff":
			desc = "速度降低 " + str(abs(effect_value))
		"shield":
			desc = "护盾 " + str(effect_value) + " 点"
		"stun":
			desc = "眩晕"
		"freeze":
			desc = "冰冻"
		"burn":
			desc = "燃烧，每回合造成 " + str(effect_value) + " 点伤害"
		"bleed":
			desc = "流血，每回合造成 " + str(effect_value) + " 点伤害"
		"poison":
			desc = "中毒，每回合造成 " + str(effect_value) + " 点伤害"
		"regeneration":
			desc = "再生，每回合恢复 " + str(effect_value) + " 点生命值"
		"berserker":
			desc = "狂暴状态"
		"invisible":
			desc = "隐身"
		"immune":
			desc = "免疫"
		"curse":
			desc = "诅咒"
		"blessing":
			desc = "祝福"
		_:
			desc = effect_type + " " + str(effect_value)
	
	if duration > 0 and not is_permanent:
		desc += " (" + str(current_duration) + "回合)"
	elif is_permanent:
		desc += " (永久)"
	
	return desc

# 获取效果信息
func get_effect_info() -> Dictionary:
	return {
		"effect_type": effect_type,
		"effect_value": effect_value,
		"duration": duration,
		"current_duration": current_duration,
		"is_permanent": is_permanent,
		"is_active": is_active,
		"tick_count": tick_count,
		"source": source.get_name_info() if source else "未知"
	}

# 设置效果为不活跃
func deactivate() -> void:
	is_active = false

# 设置效果为活跃
func activate() -> void:
	is_active = true

# 延长效果持续时间
func extend_duration(extra_duration: int) -> void:
	if not is_permanent:
		current_duration += extra_duration

# 减少效果持续时间
func reduce_duration(reduction: int) -> void:
	if not is_permanent:
		current_duration = max(0, current_duration - reduction)
