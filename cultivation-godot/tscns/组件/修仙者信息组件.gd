extends PanelContainer

# 修仙者信息组件
# 负责显示修仙者的详细属性信息

# 修仙者信息节点引用
@onready var name_value = $VBoxContainer/名称/value
@onready var realm_value = $VBoxContainer/境界/value
@onready var hp_progress = $VBoxContainer/生命值/value
@onready var attack_value = $VBoxContainer/攻击力/value
@onready var defense_value = $VBoxContainer/防御力/value
@onready var speed_value = $VBoxContainer/速度/value
@onready var spiritual_energy_progress = $VBoxContainer/灵气/value
@onready var absorption_rate_value = $VBoxContainer/灵气吸收速度/value
@onready var absorption_cooldown_value = $VBoxContainer/灵气吸收冷却/value
@onready var health_regen_rate_value = $VBoxContainer/生命恢复速度/value
@onready var health_regen_cooldown_value = $VBoxContainer/生命恢复冷却/value

var cultivator:BaseCultivation

func 初始化(cultivator:BaseCultivation):
	self.cultivator=cultivator
	%"法宝".添加item(cultivator.wepoen)
	%"法宝".tips.show_操作=false
	pass


# 更新修仙者信息
# @param cultivator: 修仙者对象，包含所有属性信息
func _process(d):
	if cultivator:
		# 更新名称
		name_value.text = cultivator.name_str
		
		# 更新境界
		realm_value.text = cultivator.get_full_realm_name()
		
		# 更新生命值进度条
		hp_progress.value = cultivator.hp_stats.get_current_value()
		hp_progress.max_value = cultivator.hp_stats.max_value
		
		# 更新属性范围显示（RandomValue类型，显示min_value-max_value范围）
		attack_value.text = str(cultivator.attack_stats.min_value) + "-" + str(cultivator.attack_stats.max_value)
		defense_value.text = str(cultivator.defense_stats.min_value) + "-" + str(cultivator.defense_stats.max_value)
		speed_value.text = str(cultivator.speed_stats.min_value) + "-" + str(cultivator.speed_stats.max_value)
		
		# 更新灵气进度条
		spiritual_energy_progress.value = cultivator.spiritual_energy.get_current_value()
		spiritual_energy_progress.max_value = cultivator.spiritual_energy.max_value
		
		# 更新灵气吸收速度
		absorption_rate_value.text = str(cultivator.absorption_rate.min_value) + "-" + str(cultivator.absorption_rate.max_value)
		
		# 更新灵气吸收冷却时间
		absorption_cooldown_value.text = str(cultivator.absorption_cooldown.min_value) + ".0-" + str(cultivator.absorption_cooldown.max_value) + ".0秒"
		
		# 更新生命恢复速度
		health_regen_rate_value.text = str(cultivator.health_regen_rate.min_value) + "-" + str(cultivator.health_regen_rate.max_value)
		
		# 更新生命恢复冷却时间
		health_regen_cooldown_value.text = str(cultivator.health_regen_cooldown.min_value) + ".0-" + str(cultivator.health_regen_cooldown.max_value) + ".0秒"
