extends Control

# 修炼UI控制器
# 负责管理修炼界面的显示和Tab切换功能

# Tab按钮节点引用
@onready var tab1_button = $VBoxContainer/HBoxContainer/主容器/VBoxContainer/Tab标签/Tab1
@onready var tab2_button = $VBoxContainer/HBoxContainer/主容器/VBoxContainer/Tab标签/Tab2
@onready var tab3_button = $VBoxContainer/HBoxContainer/主容器/VBoxContainer/Tab标签/Tab3
@onready var tab4_button = $VBoxContainer/HBoxContainer/主容器/VBoxContainer/Tab标签/Tab4

# Tab内容节点引用
@onready var cultivation_content = $VBoxContainer/HBoxContainer/主容器/VBoxContainer/Tab容器/Tab内容/修炼功法内容
@onready var equipment_content = $VBoxContainer/HBoxContainer/主容器/VBoxContainer/Tab容器/Tab内容/装备道具内容
@onready var skills_content = $VBoxContainer/HBoxContainer/主容器/VBoxContainer/Tab容器/Tab内容/技能天赋内容
@onready var achievements_content = $VBoxContainer/HBoxContainer/主容器/VBoxContainer/Tab容器/Tab内容/成就系统内容

# 修仙者信息节点引用
@onready var name_label = $VBoxContainer/HBoxContainer/侧边栏/修仙者信息/VBoxContainer/名称
@onready var level_label = $VBoxContainer/HBoxContainer/侧边栏/修仙者信息/VBoxContainer/等级
@onready var hp_progress = $VBoxContainer/HBoxContainer/侧边栏/修仙者信息/VBoxContainer/生命值/ProgressBar
@onready var strength_label = $VBoxContainer/HBoxContainer/侧边栏/修仙者信息/VBoxContainer/力量
@onready var agility_label = $VBoxContainer/HBoxContainer/侧边栏/修仙者信息/VBoxContainer/敏捷
@onready var intelligence_label = $VBoxContainer/HBoxContainer/侧边栏/修仙者信息/VBoxContainer/智力
@onready var speed_label = $VBoxContainer/HBoxContainer/侧边栏/修仙者信息/VBoxContainer/速度

# 操作按钮节点引用
@onready var cultivation_button = $VBoxContainer/HBoxContainer/侧边栏/操作/VBoxContainer/打坐修炼
@onready var recovery_button = $VBoxContainer/HBoxContainer/侧边栏/操作/VBoxContainer/打坐恢复
@onready var adventure_button = $VBoxContainer/HBoxContainer/侧边栏/操作/VBoxContainer/外出探险

# 当前选中的Tab
var current_tab: int = 1

# Tab内容数组
var tab_contents: Array = []

# 信号
signal tab_changed(tab_index: int)
signal cultivation_started()
signal recovery_started()
signal adventure_started()

func _ready():
	# 初始化Tab内容数组
	tab_contents = [cultivation_content, equipment_content, skills_content, achievements_content]
	
	# 连接Tab按钮信号
	tab1_button.pressed.connect(_on_tab1_pressed)
	tab2_button.pressed.connect(_on_tab2_pressed)
	tab3_button.pressed.connect(_on_tab3_pressed)
	tab4_button.pressed.connect(_on_tab4_pressed)
	
	# 连接操作按钮信号
	cultivation_button.pressed.connect(_on_cultivation_pressed)
	recovery_button.pressed.connect(_on_recovery_pressed)
	adventure_button.pressed.connect(_on_adventure_pressed)
	
	# 初始化Tab显示
	switch_tab(1)

func _初始化玩家信息():
	update_cultivator_info(GameData.player)
	pass

func 初始化():
	_初始化玩家信息()
	pass

# Tab1按钮回调
func _on_tab1_pressed():
	switch_tab(1)

# Tab2按钮回调
func _on_tab2_pressed():
	switch_tab(2)

# Tab3按钮回调
func _on_tab3_pressed():
	switch_tab(3)

# Tab4按钮回调
func _on_tab4_pressed():
	switch_tab(4)

# 切换Tab
func switch_tab(tab_index: int):
	# 更新当前Tab
	current_tab = tab_index
	
	# 隐藏所有Tab内容
	for content in tab_contents:
		content.visible = false
	
	# 显示选中的Tab内容
	if tab_index >= 1 and tab_index <= tab_contents.size():
		tab_contents[tab_index - 1].visible = true
	
	# 更新按钮状态
	update_tab_buttons()
	
	# 发送信号
	tab_changed.emit(tab_index)

# 更新Tab按钮状态
func update_tab_buttons():
	tab1_button.button_pressed = (current_tab == 1)
	tab2_button.button_pressed = (current_tab == 2)
	tab3_button.button_pressed = (current_tab == 3)
	tab4_button.button_pressed = (current_tab == 4)

# 打坐修炼按钮回调
func _on_cultivation_pressed():
	cultivation_started.emit()
	print("开始打坐修炼...")

# 打坐恢复按钮回调
func _on_recovery_pressed():
	recovery_started.emit()
	print("开始打坐恢复...")

# 外出探险按钮回调
func _on_adventure_pressed():
	adventure_started.emit()
	print("开始外出探险...")

# 更新修仙者信息
func update_cultivator_info(cultivator: BaseCultivation):
	name_label.text = "名称：" + cultivator.name_str
	level_label.text = "境界：" + cultivator.get_full_realm_name()
	
	# 更新生命值进度条
	hp_progress.value = (float(cultivator.hp_stats.get_current_value()) / float(cultivator.hp_stats.max_value)) * 100.0
	
	# 更新属性
	strength_label.text = "力量：" + str(cultivator.strength)
	agility_label.text = "敏捷：" + str(cultivator.agility)
	intelligence_label.text = "智力：" + str(cultivator.intelligence)
	speed_label.text = "速度：" + str(cultivator.speed)

# 添加功法到列表
func add_cultivation_technique(technique_name: String, _description: String = ""):
	var technique_container = HBoxContainer.new()
	var technique_name_label = Label.new()
	var cultivate_button = Button.new()
	
	technique_name_label.text = technique_name
	technique_name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cultivate_button.text = "修炼"
	
	technique_container.add_child(technique_name_label)
	technique_container.add_child(cultivate_button)
	
	# 添加到功法列表
	var technique_list = $VBoxContainer/HBoxContainer/主容器/VBoxContainer/Tab容器/Tab内容/修炼功法内容/功法列表/功法列表容器
	technique_list.add_child(technique_container)
	
	# 连接修炼按钮信号
	cultivate_button.pressed.connect(_on_technique_cultivate_pressed.bind(technique_name))

# 功法修炼按钮回调
func _on_technique_cultivate_pressed(technique_name: String):
	print("开始修炼功法：" + technique_name)

# 添加装备到列表
func add_equipment(equipment_name: String, _equipment_type: String = ""):
	var equipment_container = HBoxContainer.new()
	var equipment_name_label = Label.new()
	var equip_button = Button.new()
	
	equipment_name_label.text = equipment_name
	equipment_name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	equip_button.text = "装备"
	
	equipment_container.add_child(equipment_name_label)
	equipment_container.add_child(equip_button)
	
	# 添加到装备列表
	var equipment_list = $VBoxContainer/HBoxContainer/主容器/VBoxContainer/Tab容器/Tab内容/装备道具内容/装备列表/装备列表容器
	equipment_list.add_child(equipment_container)
	
	# 连接装备按钮信号
	equip_button.pressed.connect(_on_equipment_equip_pressed.bind(equipment_name))

# 装备按钮回调
func _on_equipment_equip_pressed(equipment_name: String):
	print("装备：" + equipment_name)

# 添加技能到列表
func add_skill(skill_name: String, _skill_type: String = ""):
	var skill_container = HBoxContainer.new()
	var skill_name_label = Label.new()
	var learn_button = Button.new()
	
	skill_name_label.text = skill_name
	skill_name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	learn_button.text = "学习"
	
	skill_container.add_child(skill_name_label)
	skill_container.add_child(learn_button)
	
	# 添加到技能列表
	var skill_list = $VBoxContainer/HBoxContainer/主容器/VBoxContainer/Tab容器/Tab内容/技能天赋内容/技能列表/技能列表容器
	skill_list.add_child(skill_container)
	
	# 连接学习按钮信号
	learn_button.pressed.connect(_on_skill_learn_pressed.bind(skill_name))

# 技能学习按钮回调
func _on_skill_learn_pressed(skill_name: String):
	print("学习技能：" + skill_name)

# 添加成就到列表
func add_achievement(achievement_name: String, status: String = "未完成"):
	var achievement_container = HBoxContainer.new()
	var achievement_name_label = Label.new()
	var status_label = Label.new()
	
	achievement_name_label.text = achievement_name
	achievement_name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	status_label.text = status
	
	achievement_container.add_child(achievement_name_label)
	achievement_container.add_child(status_label)
	
	# 添加到成就列表
	var achievement_list = $VBoxContainer/HBoxContainer/主容器/VBoxContainer/Tab容器/Tab内容/成就系统内容/成就列表/成就列表容器
	achievement_list.add_child(achievement_container)

# 获取当前选中的Tab
func get_current_tab() -> int:
	return current_tab

# 设置Tab（外部调用）
func set_tab(tab_index: int):
	if tab_index >= 1 and tab_index <= 4:
		switch_tab(tab_index)

# 清空所有列表
func clear_all_lists():
	# 清空功法列表
	var technique_list = $VBoxContainer/HBoxContainer/主容器/VBoxContainer/Tab容器/Tab内容/修炼功法内容/功法列表/功法列表容器
	for child in technique_list.get_children():
		if child != technique_list.get_child(0):  # 保留第一个示例
			child.queue_free()
	
	# 清空装备列表
	var equipment_list = $VBoxContainer/HBoxContainer/主容器/VBoxContainer/Tab容器/Tab内容/装备道具内容/装备列表/装备列表容器
	for child in equipment_list.get_children():
		if child != equipment_list.get_child(0):  # 保留第一个示例
			child.queue_free()
	
	# 清空技能列表
	var skill_list = $VBoxContainer/HBoxContainer/主容器/VBoxContainer/Tab容器/Tab内容/技能天赋内容/技能列表/技能列表容器
	for child in skill_list.get_children():
		if child != skill_list.get_child(0):  # 保留第一个示例
			child.queue_free()
	
	# 清空成就列表
	var achievement_list = $VBoxContainer/HBoxContainer/主容器/VBoxContainer/Tab容器/Tab内容/成就系统内容/成就列表/成就列表容器
	for child in achievement_list.get_children():
		if child != achievement_list.get_child(0):  # 保留第一个示例
			child.queue_free()
