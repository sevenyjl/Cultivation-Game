# scripts/scenes/combat/SkillSelectionUI.gd
extends Control

# UI节点引用
@onready var skill_grid: GridContainer
@onready var skill_scroll: ScrollContainer
@onready var target_selection: VBoxContainer
@onready var skill_info: VBoxContainer
@onready var confirm_button: Button
@onready var cancel_button: Button

# 技能相关
var available_skills: Array = []
var selected_skill = null
var selected_target = null
var combat_manager: CombatManager = null

# 信号
signal skill_selected(skill: Skill, target: Combatant)
signal selection_cancelled

func _ready():
	create_ui_layout()
	connect_signals()

func create_ui_layout():
	# 设置全屏
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	# 创建主容器
	var main_container = VBoxContainer.new()
	add_child(main_container)
	
	# 创建标题
	var title = Label.new()
	title.text = "选择技能"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 20)
	main_container.add_child(title)
	
	# 创建技能选择区域
	create_skill_selection_area(main_container)
	
	# 创建目标选择区域
	create_target_selection_area(main_container)
	
	# 创建技能信息区域
	create_skill_info_area(main_container)
	
	# 创建按钮区域
	create_button_area(main_container)

func create_skill_selection_area(parent: Control):
	var skill_container = VBoxContainer.new()
	parent.add_child(skill_container)
	
	# 技能标题
	var skill_title = Label.new()
	skill_title.text = "可用技能:"
	skill_title.add_theme_font_size_override("font_size", 16)
	skill_container.add_child(skill_title)
	
	# 技能滚动容器
	skill_scroll = ScrollContainer.new()
	skill_scroll.custom_minimum_size = Vector2(0, 200)
	skill_container.add_child(skill_scroll)
	
	# 技能网格
	skill_grid = GridContainer.new()
	skill_grid.columns = 3
	skill_scroll.add_child(skill_grid)

func create_target_selection_area(parent: Control):
	target_selection = VBoxContainer.new()
	parent.add_child(target_selection)
	
	# 目标标题
	var target_title = Label.new()
	target_title.text = "选择目标:"
	target_title.add_theme_font_size_override("font_size", 16)
	target_selection.add_child(target_title)
	
	# 目标按钮容器
	var target_container = HBoxContainer.new()
	target_container.alignment = BoxContainer.ALIGNMENT_CENTER
	target_selection.add_child(target_container)

func create_skill_info_area(parent: Control):
	skill_info = VBoxContainer.new()
	parent.add_child(skill_info)
	
	# 技能信息标题
	var info_title = Label.new()
	info_title.text = "技能信息:"
	info_title.add_theme_font_size_override("font_size", 16)
	skill_info.add_child(info_title)
	
	# 技能描述标签
	var skill_desc = RichTextLabel.new()
	skill_desc.name = "skill_description"
	skill_desc.custom_minimum_size = Vector2(0, 100)
	skill_desc.bbcode_enabled = true
	skill_info.add_child(skill_desc)

func create_button_area(parent: Control):
	var button_container = HBoxContainer.new()
	button_container.alignment = BoxContainer.ALIGNMENT_CENTER
	parent.add_child(button_container)
	
	# 确认按钮
	confirm_button = Button.new()
	confirm_button.text = "确认"
	confirm_button.custom_minimum_size = Vector2(100, 40)
	confirm_button.disabled = true
	button_container.add_child(confirm_button)
	
	# 取消按钮
	cancel_button = Button.new()
	cancel_button.text = "取消"
	cancel_button.custom_minimum_size = Vector2(100, 40)
	button_container.add_child(cancel_button)

func connect_signals():
	confirm_button.pressed.connect(_on_confirm_pressed)
	cancel_button.pressed.connect(_on_cancel_pressed)

# 设置战斗管理器
func set_combat_manager(manager: CombatManager):
	combat_manager = manager
	update_available_skills()
	update_target_selection()

# 更新可用技能
func update_available_skills():
	if not combat_manager or not combat_manager.player:
		return
	
	# 清除现有技能按钮
	for child in skill_grid.get_children():
		child.queue_free()
	
	# 获取可用技能
	available_skills = combat_manager.get_available_player_skills()
	
	# 创建技能按钮
	for skill in available_skills:
		create_skill_button(skill)

# 创建技能按钮
func create_skill_button(skill):
	var skill_button = Button.new()
	skill_button.text = skill.skill_name
	skill_button.custom_minimum_size = Vector2(150, 40)
	skill_button.pressed.connect(_on_skill_button_pressed.bind(skill))
	
	# 设置技能描述
	skill_button.tooltip_text = skill.get_skill_description()
	
	# 如果技能在冷却中，禁用按钮
	if skill.is_on_cooldown():
		skill_button.disabled = true
		skill_button.text += " (冷却中: " + str(skill.get_remaining_cooldown()) + ")"
	
	skill_grid.add_child(skill_button)

# 更新目标选择
func update_target_selection():
	if not combat_manager:
		return
	
	# 清除现有目标按钮
	for child in target_selection.get_children():
		if child.name != "选择目标:":
			child.queue_free()
	
	# 获取可用目标
	var targets = get_available_targets()
	
	# 创建目标按钮
	for target in targets:
		create_target_button(target)

# 获取可用目标
func get_available_targets() -> Array:
	var targets = []
	
	if combat_manager and combat_manager.enemies:
		for enemy in combat_manager.enemies:
			if enemy and enemy.is_alive_in_battle():
				targets.append(enemy)
	
	return targets

# 创建目标按钮
func create_target_button(target):
	var target_button = Button.new()
	target_button.text = target.get_name_info()
	target_button.custom_minimum_size = Vector2(120, 40)
	target_button.pressed.connect(_on_target_button_pressed.bind(target))
	
	# 添加到目标容器
	var target_container = target_selection.get_child(1)  # 获取目标按钮容器
	target_container.add_child(target_button)

# 更新技能信息显示
func update_skill_info():
	var desc_label = skill_info.get_node("skill_description")
	if not selected_skill:
		desc_label.text = "请选择一个技能"
		return
	
	desc_label.text = selected_skill.get_skill_description()

# 技能按钮点击事件
func _on_skill_button_pressed(skill):
	selected_skill = skill
	update_skill_info()
	update_confirm_button()

# 目标按钮点击事件
func _on_target_button_pressed(target):
	selected_target = target
	update_confirm_button()

# 更新确认按钮状态
func update_confirm_button():
	confirm_button.disabled = not (selected_skill and selected_target)

# 确认按钮点击事件
func _on_confirm_pressed():
	if selected_skill and selected_target:
		skill_selected.emit(selected_skill, selected_target)
		hide()

# 取消按钮点击事件
func _on_cancel_pressed():
	selection_cancelled.emit()
	hide()

# 显示技能选择UI
func show_skill_selection():
	visible = true
	selected_skill = null
	selected_target = null
	update_available_skills()
	update_target_selection()
	update_skill_info()
	update_confirm_button()

# 隐藏技能选择UI
func hide_skill_selection():
	visible = false
