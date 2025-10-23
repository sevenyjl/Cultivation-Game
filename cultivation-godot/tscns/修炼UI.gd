extends Control

# 修炼UI控制器
# 负责管理修炼界面的显示和Tab切换功能

# Tab按钮节点引用
@onready var 修炼_button = $"VBoxContainer/HBoxContainer/主容器/VBoxContainer/Tab标签/修炼"

# Tab内容节点引用
@onready var cultivation_content = $VBoxContainer/HBoxContainer/主容器/VBoxContainer/Tab容器/修炼内容

# 修仙者信息节点引用
@onready var name_value = $VBoxContainer/HBoxContainer/侧边栏/修仙者信息/VBoxContainer/名称/value
@onready var realm_value = $VBoxContainer/HBoxContainer/侧边栏/修仙者信息/VBoxContainer/境界/value
@onready var hp_progress = $VBoxContainer/HBoxContainer/侧边栏/修仙者信息/VBoxContainer/生命值/value
@onready var attack_value = $VBoxContainer/HBoxContainer/侧边栏/修仙者信息/VBoxContainer/攻击力/value
@onready var defense_value = $VBoxContainer/HBoxContainer/侧边栏/修仙者信息/VBoxContainer/防御力/value
@onready var speed_value = $VBoxContainer/HBoxContainer/侧边栏/修仙者信息/VBoxContainer/速度/value
@onready var spiritual_energy_progress = $VBoxContainer/HBoxContainer/侧边栏/修仙者信息/VBoxContainer/灵气/value
@onready var absorption_rate_value = $VBoxContainer/HBoxContainer/侧边栏/修仙者信息/VBoxContainer/灵气吸收速度/value
@onready var absorption_cooldown_value = $VBoxContainer/HBoxContainer/侧边栏/修仙者信息/VBoxContainer/灵气吸收冷却/value

# 当前选中的Tab
var current_tab: int = 0
# 信号
signal tab_changed(tab_index: int)

var _当前选择的玩家:BaseCultivation
func _ready():
	var tab_button=$"VBoxContainer/HBoxContainer/主容器/VBoxContainer/Tab标签".get_children()
	for i in tab_button.size():
		var button=tab_button[i] as Button
		button.pressed.connect(switch_tab.bind(i))
	# 初始化Tab显示
	switch_tab(0)

func _process(delta: float) -> void:
	if _当前选择的玩家:
		update_cultivator_info(_当前选择的玩家)
	pass

func _初始化玩家信息():
	_当前选择的玩家=GameData.player
	pass

func 初始化():
	_初始化玩家信息()
	$"VBoxContainer/HBoxContainer/主容器/VBoxContainer/Tab容器/修炼内容".初始化()
	pass

# 切换Tab
func switch_tab(tab_index: int):
	# 更新当前Tab
	current_tab = tab_index
	# 隐藏所有Tab内容
	var tab_contents=$VBoxContainer/HBoxContainer/主容器/VBoxContainer/Tab容器.get_children()
	for content in tab_contents:
		content.visible = false
	
	# 显示选中的Tab内容
	if tab_index >= 0 and tab_index < tab_contents.size():
		tab_contents[tab_index].visible = true
	# 发送信号
	tab_changed.emit(tab_index)

# 更新修仙者信息
func update_cultivator_info(cultivator: BaseCultivation):
	# 更新名称
	name_value.text = cultivator.name_str
	
	# 更新境界
	realm_value.text = cultivator.get_full_realm_name()
	
	# 更新生命值进度条
	hp_progress.value = cultivator.hp_stats.get_current_value()
	hp_progress.max_value=cultivator.hp_stats.max_value
	
	# 更新属性范围显示（RandomValue类型，显示min_value-max_value范围）
	attack_value.text = str(cultivator.attack_stats.min_value) + "~" + str(cultivator.attack_stats.max_value)
	defense_value.text = str(cultivator.defense_stats.min_value) + "~" + str(cultivator.defense_stats.max_value)
	speed_value.text = str(cultivator.speed_stats.min_value) + "~" + str(cultivator.speed_stats.max_value)
	
	# 更新灵气进度条
	spiritual_energy_progress.value = cultivator.spiritual_energy.get_current_value()
	spiritual_energy_progress.max_value=cultivator.spiritual_energy.max_value
	
	# 更新灵气吸收速度
	absorption_rate_value.text = str(cultivator.absorption_rate.min_value) + "~" + str(cultivator.absorption_rate.max_value)
	
	# 更新灵气吸收冷却时间
	absorption_cooldown_value.text = str(cultivator.absorption_cooldown.min_value) + "~" + str(cultivator.absorption_cooldown.max_value) + "秒"
