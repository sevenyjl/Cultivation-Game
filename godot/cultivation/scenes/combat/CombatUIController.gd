# scripts/scenes/combat/CombatUIController.gd
extends Control

# UI节点引用
@onready var player_panel: PanelContainer
@onready var enemy_panel: PanelContainer
@onready var action_panel: PanelContainer
@onready var skill_panel: PanelContainer
@onready var log_panel: PanelContainer
@onready var status_panel: PanelContainer

# 玩家UI元素
@onready var player_name_label: Label
@onready var player_level_label: Label
@onready var player_health_bar: ProgressBar
@onready var player_health_label: Label
@onready var player_qi_bar: ProgressBar
@onready var player_qi_label: Label
@onready var player_attack_label: Label
@onready var player_defense_label: Label
@onready var player_effects_container: VBoxContainer

# 敌人UI元素
@onready var enemy_name_label: Label
@onready var enemy_level_label: Label
@onready var enemy_health_bar: ProgressBar
@onready var enemy_health_label: Label
@onready var enemy_attack_label: Label
@onready var enemy_effects_container: VBoxContainer

# 行动按钮
@onready var attack_button: Button
@onready var defend_button: Button
@onready var skill_button: Button
@onready var escape_button: Button

# 技能选择UI
@onready var skill_list: VBoxContainer
@onready var skill_scroll: ScrollContainer
@onready var skill_buttons: Array[Button] = []

# 战斗日志
@onready var combat_log: RichTextLabel
@onready var log_scroll: ScrollContainer

# 状态显示
@onready var turn_label: Label
@onready var status_effects: VBoxContainer

# 战斗管理器引用
var combat_manager: CombatManager
var current_target: Combatant = null

# UI状态
var is_skill_panel_visible: bool = false
var is_selecting_target: bool = false

func _ready():
	# 创建UI布局
	create_ui_layout()
	
	# 连接信号
	connect_ui_signals()
	
	# 初始化UI状态
	initialize_ui_state()

func create_ui_layout():
	# 设置全屏
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	
	# 创建主容器
	var main_container = VBoxContainer.new()
	add_child(main_container)
	
	# 创建顶部信息面板
	create_info_panel(main_container)
	
	# 创建中间战斗区域
	create_combat_area(main_container)
	
	# 创建底部行动面板
	create_action_panel(main_container)
	
	# 创建技能选择面板
	create_skill_panel(main_container)
	
	# 创建战斗日志面板
	create_log_panel(main_container)
	
	# 创建状态面板
	create_status_panel(main_container)

func create_info_panel(parent: Control):
	var info_container = HBoxContainer.new()
	parent.add_child(info_container)
	
	# 玩家信息面板
	player_panel = PanelContainer.new()
	player_panel.custom_minimum_size = Vector2(300, 150)
	info_container.add_child(player_panel)
	
	var player_vbox = VBoxContainer.new()
	player_panel.add_child(player_vbox)
	
	# 玩家标题
	var player_title = Label.new()
	player_title.text = "修炼者"
	player_title.add_theme_font_size_override("font_size", 18)
	player_vbox.add_child(player_title)
	
	# 玩家信息网格
	var player_grid = GridContainer.new()
	player_grid.columns = 2
	player_vbox.add_child(player_grid)
	
	# 玩家属性标签
	player_name_label = Label.new()
	player_name_label.text = "姓名: "
	player_grid.add_child(player_name_label)
	
	var player_name_value = Label.new()
	player_name_value.name = "player_name_value"
	player_grid.add_child(player_name_value)
	
	player_level_label = Label.new()
	player_level_label.text = "境界: "
	player_grid.add_child(player_level_label)
	
	var player_level_value = Label.new()
	player_level_value.name = "player_level_value"
	player_grid.add_child(player_level_value)
	
	# 生命值条
	var health_container = VBoxContainer.new()
	player_vbox.add_child(health_container)
	
	var health_label_container = HBoxContainer.new()
	health_container.add_child(health_label_container)
	
	var health_title = Label.new()
	health_title.text = "生命值:"
	health_label_container.add_child(health_title)
	
	player_health_label = Label.new()
	player_health_label.text = "100/100"
	health_label_container.add_child(player_health_label)
	
	player_health_bar = ProgressBar.new()
	player_health_bar.max_value = 100
	player_health_bar.value = 100
	player_health_bar.show_percentage = false
	health_container.add_child(player_health_bar)
	
	# 灵气条
	var qi_container = VBoxContainer.new()
	player_vbox.add_child(qi_container)
	
	var qi_label_container = HBoxContainer.new()
	qi_container.add_child(qi_label_container)
	
	var qi_title = Label.new()
	qi_title.text = "灵气:"
	qi_label_container.add_child(qi_title)
	
	player_qi_label = Label.new()
	player_qi_label.text = "0/100"
	qi_label_container.add_child(player_qi_label)
	
	player_qi_bar = ProgressBar.new()
	player_qi_bar.max_value = 100
	player_qi_bar.value = 0
	player_qi_bar.show_percentage = false
	qi_container.add_child(player_qi_bar)
	
	# 攻击力和防御力
	var stats_container = HBoxContainer.new()
	player_vbox.add_child(stats_container)
	
	player_attack_label = Label.new()
	player_attack_label.text = "攻击: 0-0"
	stats_container.add_child(player_attack_label)
	
	player_defense_label = Label.new()
	player_defense_label.text = "防御: 0"
	stats_container.add_child(player_defense_label)
	
	# 状态效果容器
	player_effects_container = VBoxContainer.new()
	player_vbox.add_child(player_effects_container)
	
	# 敌人信息面板
	enemy_panel = PanelContainer.new()
	enemy_panel.custom_minimum_size = Vector2(300, 150)
	info_container.add_child(enemy_panel)
	
	var enemy_vbox = VBoxContainer.new()
	enemy_panel.add_child(enemy_vbox)
	
	# 敌人标题
	var enemy_title = Label.new()
	enemy_title.text = "敌人"
	enemy_title.add_theme_font_size_override("font_size", 18)
	enemy_vbox.add_child(enemy_title)
	
	# 敌人信息网格
	var enemy_grid = GridContainer.new()
	enemy_grid.columns = 2
	enemy_vbox.add_child(enemy_grid)
	
	# 敌人属性标签
	enemy_name_label = Label.new()
	enemy_name_label.text = "姓名: "
	enemy_grid.add_child(enemy_name_label)
	
	var enemy_name_value = Label.new()
	enemy_name_value.name = "enemy_name_value"
	enemy_grid.add_child(enemy_name_value)
	
	enemy_level_label = Label.new()
	enemy_level_label.text = "等级: "
	enemy_grid.add_child(enemy_level_label)
	
	var enemy_level_value = Label.new()
	enemy_level_value.name = "enemy_level_value"
	enemy_grid.add_child(enemy_level_value)
	
	# 敌人生命值条
	var enemy_health_container = VBoxContainer.new()
	enemy_vbox.add_child(enemy_health_container)
	
	var enemy_health_label_container = HBoxContainer.new()
	enemy_health_container.add_child(enemy_health_label_container)
	
	var enemy_health_title = Label.new()
	enemy_health_title.text = "生命值:"
	enemy_health_label_container.add_child(enemy_health_title)
	
	enemy_health_label = Label.new()
	enemy_health_label.text = "100/100"
	enemy_health_label_container.add_child(enemy_health_label)
	
	enemy_health_bar = ProgressBar.new()
	enemy_health_bar.max_value = 100
	enemy_health_bar.value = 100
	enemy_health_bar.show_percentage = false
	enemy_health_container.add_child(enemy_health_bar)
	
	# 敌人攻击力
	enemy_attack_label = Label.new()
	enemy_attack_label.text = "攻击: 0-0"
	enemy_vbox.add_child(enemy_attack_label)
	
	# 敌人状态效果容器
	enemy_effects_container = VBoxContainer.new()
	enemy_vbox.add_child(enemy_effects_container)

func create_combat_area(parent: Control):
	var combat_container = CenterContainer.new()
	parent.add_child(combat_container)
	
	# 这里可以添加战斗动画区域
	var combat_animation_area = ColorRect.new()
	combat_animation_area.color = Color(0.2, 0.2, 0.3, 0.8)
	combat_animation_area.custom_minimum_size = Vector2(400, 200)
	combat_container.add_child(combat_animation_area)
	
	var combat_text = Label.new()
	combat_text.text = "战斗区域"
	combat_text.add_theme_font_size_override("font_size", 24)
	combat_animation_area.add_child(combat_text)

func create_action_panel(parent: Control):
	action_panel = PanelContainer.new()
	parent.add_child(action_panel)
	
	var action_container = VBoxContainer.new()
	action_panel.add_child(action_container)
	
	# 回合信息
	turn_label = Label.new()
	turn_label.text = "等待战斗开始..."
	turn_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	turn_label.add_theme_font_size_override("font_size", 16)
	action_container.add_child(turn_label)
	
	# 行动按钮容器
	var button_container = HBoxContainer.new()
	button_container.alignment = BoxContainer.ALIGNMENT_CENTER
	action_container.add_child(button_container)
	
	# 攻击按钮
	attack_button = Button.new()
	attack_button.text = "攻击"
	attack_button.custom_minimum_size = Vector2(100, 40)
	button_container.add_child(attack_button)
	
	# 防御按钮
	defend_button = Button.new()
	defend_button.text = "防御"
	defend_button.custom_minimum_size = Vector2(100, 40)
	button_container.add_child(defend_button)
	
	# 技能按钮
	skill_button = Button.new()
	skill_button.text = "技能"
	skill_button.custom_minimum_size = Vector2(100, 40)
	button_container.add_child(skill_button)
	
	# 逃跑按钮
	escape_button = Button.new()
	escape_button.text = "逃跑"
	escape_button.custom_minimum_size = Vector2(100, 40)
	button_container.add_child(escape_button)

func create_skill_panel(parent: Control):
	skill_panel = PanelContainer.new()
	skill_panel.visible = false
	parent.add_child(skill_panel)
	
	var skill_container = VBoxContainer.new()
	skill_panel.add_child(skill_container)
	
	# 技能标题
	var skill_title = Label.new()
	skill_title.text = "选择技能"
	skill_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	skill_title.add_theme_font_size_override("font_size", 16)
	skill_container.add_child(skill_title)
	
	# 技能滚动容器
	skill_scroll = ScrollContainer.new()
	skill_scroll.custom_minimum_size = Vector2(0, 200)
	skill_container.add_child(skill_scroll)
	
	skill_list = VBoxContainer.new()
	skill_scroll.add_child(skill_list)
	
	# 关闭技能面板按钮
	var close_skill_button = Button.new()
	close_skill_button.text = "关闭"
	close_skill_button.pressed.connect(_on_close_skill_pressed)
	skill_container.add_child(close_skill_button)

func create_log_panel(parent: Control):
	log_panel = PanelContainer.new()
	parent.add_child(log_panel)
	
	var log_container = VBoxContainer.new()
	log_panel.add_child(log_container)
	
	# 日志标题
	var log_title = Label.new()
	log_title.text = "战斗日志"
	log_title.add_theme_font_size_override("font_size", 14)
	log_container.add_child(log_title)
	
	# 日志滚动容器
	log_scroll = ScrollContainer.new()
	log_scroll.custom_minimum_size = Vector2(0, 150)
	log_container.add_child(log_scroll)
	
	combat_log = RichTextLabel.new()
	combat_log.bbcode_enabled = true
	combat_log.scroll_following = true
	combat_log.fit_content = true
	log_scroll.add_child(combat_log)

func create_status_panel(parent: Control):
	status_panel = PanelContainer.new()
	parent.add_child(status_panel)
	
	var status_container = VBoxContainer.new()
	status_panel.add_child(status_container)
	
	# 状态标题
	var status_title = Label.new()
	status_title.text = "战斗状态"
	status_title.add_theme_font_size_override("font_size", 14)
	status_container.add_child(status_title)
	
	status_effects = VBoxContainer.new()
	status_container.add_child(status_effects)

func connect_ui_signals():
	# 连接按钮信号
	attack_button.pressed.connect(_on_attack_pressed)
	defend_button.pressed.connect(_on_defend_pressed)
	skill_button.pressed.connect(_on_skill_pressed)
	escape_button.pressed.connect(_on_escape_pressed)

func initialize_ui_state():
	# 初始化UI状态
	update_action_buttons(false)
	update_skill_panel()

# 设置战斗管理器
func set_combat_manager(manager: CombatManager):
	# 如果已经有战斗管理器，先断开之前的连接
	if combat_manager:
		if combat_manager.combat_log_updated.is_connected(_on_combat_log_updated):
			combat_manager.combat_log_updated.disconnect(_on_combat_log_updated)
		if combat_manager.combat_ended.is_connected(_on_combat_ended):
			combat_manager.combat_ended.disconnect(_on_combat_ended)
		if combat_manager.turn_started.is_connected(_on_turn_started):
			combat_manager.turn_started.disconnect(_on_turn_started)
		if combat_manager.action_executed.is_connected(_on_action_executed):
			combat_manager.action_executed.disconnect(_on_action_executed)
	
	combat_manager = manager
	if combat_manager:
		combat_manager.combat_log_updated.connect(_on_combat_log_updated)
		combat_manager.combat_ended.connect(_on_combat_ended)
		combat_manager.turn_started.connect(_on_turn_started)
		combat_manager.action_executed.connect(_on_action_executed)

# 更新UI
func update_ui():
	if not combat_manager:
		return
	
	update_player_info()
	update_enemy_info()
	update_turn_info()
	update_status_effects()

# 更新玩家信息
func update_player_info():
	if not combat_manager or not combat_manager.player:
		return
	
	var player = combat_manager.player
	
	# 更新玩家基本信息
	player_name_label.text = "姓名: " + player.get_name_info()
	player_level_label.text = "境界: " + player.stage_name + " (" + str(player.level) + "级)"
	
	# 更新生命值
	var max_health = player.get_combat_max_health()
	var current_health = player.get_combat_current_health()
	player_health_bar.max_value = max_health
	player_health_bar.value = current_health
	player_health_label.text = str(int(current_health)) + "/" + str(int(max_health))
	
	# 更新灵气
	var required_qi = player.get_required_qi()
	player_qi_bar.max_value = required_qi
	player_qi_bar.value = player.qi
	player_qi_label.text = str(int(player.qi)) + "/" + str(int(required_qi))
	
	# 更新攻击力和防御力
	var attack_range = player.get_combat_attack_range()
	player_attack_label.text = "攻击: " + str(int(attack_range.min)) + "-" + str(int(attack_range.max))
	player_defense_label.text = "防御: " + str(int(player.get_combat_defense()))
	
	# 更新状态效果
	update_combatant_effects(player, player_effects_container)

# 更新敌人信息
func update_enemy_info():
	if not combat_manager or combat_manager.enemies.is_empty():
		return
	
	# 显示第一个敌人（可以扩展为多个敌人）
	var enemy = combat_manager.enemies[0]
	if not enemy:
		return
	
	# 更新敌人基本信息
	enemy_name_label.text = "姓名: " + enemy.get_name_info()
	enemy_level_label.text = "等级: " + str(enemy.level)
	
	# 更新生命值
	var max_health = enemy.get_combat_max_health()
	var current_health = enemy.get_combat_current_health()
	enemy_health_bar.max_value = max_health
	enemy_health_bar.value = current_health
	enemy_health_label.text = str(int(current_health)) + "/" + str(int(max_health))
	
	# 更新攻击力
	var attack_range = enemy.get_combat_attack_range()
	enemy_attack_label.text = "攻击: " + str(int(attack_range.min)) + "-" + str(int(attack_range.max))
	
	# 更新状态效果
	update_combatant_effects(enemy, enemy_effects_container)

# 更新战斗者状态效果
func update_combatant_effects(combatant, container: VBoxContainer):
	# 清除现有效果显示
	for child in container.get_children():
		child.queue_free()
	
	# 添加当前效果
	var effects = combatant.get_effects()
	for effect in effects:
		var effect_label = Label.new()
		effect_label.text = effect.get_effect_description()
		effect_label.add_theme_font_size_override("font_size", 10)
		container.add_child(effect_label)

# 更新回合信息
func update_turn_info():
	if not combat_manager:
		return
	
	match combat_manager.current_state:
		0:  # IDLE
			turn_label.text = "等待战斗开始..."
		1:  # PREPARING
			turn_label.text = "准备战斗..."
		2:  # PLAYER_TURN
			turn_label.text = "你的回合"
		3:  # ENEMY_TURN
			turn_label.text = "敌人回合"
		4:  # ANIMATING
			turn_label.text = "执行行动中..."
		5:  # VICTORY
			turn_label.text = "战斗胜利！"
		6:  # DEFEAT
			turn_label.text = "战斗失败！"
		7:  # ESCAPED
			turn_label.text = "成功逃跑！"

# 更新行动按钮状态
func update_action_buttons(enabled: bool):
	attack_button.disabled = not enabled
	defend_button.disabled = not enabled
	skill_button.disabled = not enabled
	escape_button.disabled = not enabled

# 更新技能面板
func update_skill_panel():
	if not combat_manager or not combat_manager.player:
		return
	
	# 清除现有技能按钮
	for button in skill_buttons:
		button.queue_free()
	skill_buttons.clear()
	
	# 获取可用技能
	var skills = combat_manager.get_available_player_skills()
	
	# 创建技能按钮
	for skill in skills:
		var skill_btn = Button.new()
		skill_btn.text = skill.skill_name
		skill_btn.custom_minimum_size = Vector2(200, 30)
		skill_btn.pressed.connect(_on_skill_selected.bind(skill))
		
		# 设置技能描述
		skill_btn.tooltip_text = skill.get_skill_description()
		
		# 如果技能在冷却中，禁用按钮
		if skill.is_on_cooldown():
			skill_btn.disabled = true
			skill_btn.text += " (冷却中: " + str(skill.get_remaining_cooldown()) + ")"
		
		skill_list.add_child(skill_btn)
		skill_buttons.append(skill_btn)

# 更新状态效果显示
func update_status_effects():
	# 这里可以添加全局状态效果的显示
	pass

# 按钮事件处理
func _on_attack_pressed():
	if combat_manager and combat_manager.current_state == 2:  # PLAYER_TURN
		var target = get_current_target()
		if target:
			combat_manager.basic_attack(target)

func _on_defend_pressed():
	if combat_manager and combat_manager.current_state == 2:  # PLAYER_TURN
		combat_manager.defend()

func _on_skill_pressed():
	if combat_manager and combat_manager.current_state == 2:  # PLAYER_TURN
		is_skill_panel_visible = not is_skill_panel_visible
		skill_panel.visible = is_skill_panel_visible
		update_skill_panel()

func _on_escape_pressed():
	if combat_manager and combat_manager.current_state == 2:  # PLAYER_TURN
		combat_manager.attempt_escape()

func _on_close_skill_pressed():
	is_skill_panel_visible = false
	skill_panel.visible = false

func _on_skill_selected(skill):
	if combat_manager and combat_manager.current_state == 2:  # PLAYER_TURN
		var target = get_current_target()
		combat_manager.use_skill(skill, target)
		is_skill_panel_visible = false
		skill_panel.visible = false

# 获取当前目标
func get_current_target():
	if not combat_manager or combat_manager.enemies.is_empty():
		return null
	return combat_manager.enemies[0]  # 简化：选择第一个敌人

# 信号处理
func _on_combat_log_updated(message: String):
	combat_log.append_text(message + "\n")

func _on_combat_ended(result):
	match result:
		5:  # VICTORY
			combat_log.append_text("\n[color=green]战斗胜利！[/color]\n")
			update_action_buttons(false)
		6:  # DEFEAT
			combat_log.append_text("\n[color=red]战斗失败！[/color]\n")
			update_action_buttons(false)
		7:  # ESCAPED
			combat_log.append_text("\n[color=yellow]成功逃跑！[/color]\n")
			update_action_buttons(false)

func _on_turn_started(turn_owner: String):
	if turn_owner == "player":
		update_action_buttons(true)
		update_skill_panel()
	else:
		update_action_buttons(false)
		is_skill_panel_visible = false
		skill_panel.visible = false

func _on_action_executed(_action):
	# 行动执行后的UI更新
	update_ui()
