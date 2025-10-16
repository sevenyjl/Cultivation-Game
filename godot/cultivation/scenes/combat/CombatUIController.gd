# scripts/scenes/combat/CombatUIController.gd
extends Control

# UI节点引用
@onready var player_panel: PanelContainer = $MainContainer/InfoPanel/PlayerPanel
@onready var enemy_panel: PanelContainer = $MainContainer/InfoPanel/EnemyPanel
@onready var action_panel: PanelContainer = $MainContainer/ActionPanel
@onready var skill_panel: PanelContainer = $MainContainer/SkillPanel
@onready var log_panel: PanelContainer = $MainContainer/LogPanel
@onready var status_panel: PanelContainer = $MainContainer/StatusPanel

# 玩家UI元素
@onready var player_name_value: Label = $MainContainer/InfoPanel/PlayerPanel/PlayerVBox/PlayerGrid/PlayerNameValue
@onready var player_level_value: Label = $MainContainer/InfoPanel/PlayerPanel/PlayerVBox/PlayerGrid/PlayerLevelValue
@onready var player_health_bar: ProgressBar = $MainContainer/InfoPanel/PlayerPanel/PlayerVBox/HealthContainer/PlayerHealthBar
@onready var player_health_label: Label = $MainContainer/InfoPanel/PlayerPanel/PlayerVBox/HealthContainer/HealthLabelContainer/PlayerHealthLabel
@onready var player_qi_bar: ProgressBar = $MainContainer/InfoPanel/PlayerPanel/PlayerVBox/QiContainer/PlayerQiBar
@onready var player_qi_label: Label = $MainContainer/InfoPanel/PlayerPanel/PlayerVBox/QiContainer/QiLabelContainer/PlayerQiLabel
@onready var player_attack_label: Label = $MainContainer/InfoPanel/PlayerPanel/PlayerVBox/StatsContainer/PlayerAttackLabel
@onready var player_defense_label: Label = $MainContainer/InfoPanel/PlayerPanel/PlayerVBox/StatsContainer/PlayerDefenseLabel
@onready var player_effects_container: VBoxContainer = $MainContainer/InfoPanel/PlayerPanel/PlayerVBox/PlayerEffectsContainer

# 敌人UI元素
@onready var enemy_list: VBoxContainer = $MainContainer/InfoPanel/EnemyPanel/EnemyVBox/EnemyScroll/EnemyList

# 行动按钮
@onready var attack_button: Button = $MainContainer/ActionPanel/ActionContainer/ButtonContainer/AttackButton
@onready var defend_button: Button = $MainContainer/ActionPanel/ActionContainer/ButtonContainer/DefendButton
@onready var skill_button: Button = $MainContainer/ActionPanel/ActionContainer/ButtonContainer/SkillButton
@onready var escape_button: Button = $MainContainer/ActionPanel/ActionContainer/ButtonContainer/EscapeButton
@onready var auto_combat_toggle: CheckButton = $MainContainer/ActionPanel/ActionContainer/ButtonContainer/AutoCombatToggle

# 速度控制UI
@onready var speed_1x_button: Button = $MainContainer/ActionPanel/ActionContainer/SpeedControlContainer/Speed1xButton
@onready var speed_2x_button: Button = $MainContainer/ActionPanel/ActionContainer/SpeedControlContainer/Speed2xButton
@onready var speed_5x_button: Button = $MainContainer/ActionPanel/ActionContainer/SpeedControlContainer/Speed5xButton
@onready var speed_10x_button: Button = $MainContainer/ActionPanel/ActionContainer/SpeedControlContainer/Speed10xButton
@onready var speed_100x_button: Button = $MainContainer/ActionPanel/ActionContainer/SpeedControlContainer/Speed100xButton

# 技能选择UI
@onready var skill_list: VBoxContainer = $MainContainer/SkillPanel/SkillContainer/SkillScroll/SkillList
@onready var skill_scroll: ScrollContainer = $MainContainer/SkillPanel/SkillContainer/SkillScroll
@onready var skill_buttons: Array[Button] = []

# 战斗日志
@onready var combat_log: RichTextLabel = $MainContainer/LogPanel/LogContainer/LogScroll/CombatLog
@onready var log_scroll: ScrollContainer = $MainContainer/LogPanel/LogContainer/LogScroll

# 状态显示
@onready var turn_label: Label = $MainContainer/ActionPanel/ActionContainer/TurnLabel
@onready var status_effects: VBoxContainer = $MainContainer/StatusPanel/StatusContainer/StatusEffects

# 战斗管理器引用
var combat_manager: CombatManager
var current_target: Combatant = null

# UI状态
var is_skill_panel_visible: bool = false
var is_selecting_target: bool = false
var is_auto_combat_enabled: bool = false
var current_combat_speed: float = 1.0  # 当前战斗速度倍数

func _ready():
	# 初始化UI状态
	initialize_ui_state()

func initialize_ui_state():
	# 初始化UI状态
	update_action_buttons(false)
	update_skill_panel()
	update_speed_buttons()

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
		
		# 从玩家数据中恢复自动战斗状态
		if combat_manager.player:
			is_auto_combat_enabled = combat_manager.player.get_auto_combat_enabled()
			auto_combat_toggle.button_pressed = is_auto_combat_enabled
			print("从玩家数据恢复自动战斗状态: ", is_auto_combat_enabled)
		
		# 立即更新UI
		update_ui()

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
	player_name_value.text = player.get_name_info()
	player_level_value.text = player.stage_name + " (" + str(player.level) + "级)"
	
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
	if not combat_manager:
		return
	
	# 清除现有敌人UI
	for child in enemy_list.get_children():
		child.queue_free()
	
	# 为每个活着的敌人创建UI
	for i in range(combat_manager.enemies.size()):
		var enemy = combat_manager.enemies[i]
		if enemy and enemy.is_alive_in_battle():
			create_enemy_ui(enemy, i)
	
	# 更新所有敌人UI数据
	update_all_enemies_ui()

# 更新所有敌人UI数据
func update_all_enemies_ui():
	if not combat_manager:
		return
	
	for i in range(enemy_list.get_child_count()):
		var enemy_container = enemy_list.get_child(i)
		if enemy_container and enemy_container.name.begins_with("enemy_"):
			var enemy_index = int(enemy_container.name.split("_")[1])
			if enemy_index < combat_manager.enemies.size():
				var enemy = combat_manager.enemies[enemy_index]
				if enemy and enemy.is_alive_in_battle():
					update_enemy_ui_data(enemy, enemy_container)

# 创建敌人UI
func create_enemy_ui(enemy: Combatant, index: int):
	var enemy_container = PanelContainer.new()
	enemy_container.custom_minimum_size = Vector2(0, 100)
	enemy_container.name = "enemy_" + str(index)
	
	var vbox = VBoxContainer.new()
	vbox.name = "vbox"
	enemy_container.add_child(vbox)
	
	# 敌人标题
	var title_label = Label.new()
	title_label.text = "敌人 " + str(index + 1) + ": " + enemy.get_name_info()
	title_label.add_theme_font_size_override("font_size", 14)
	title_label.name = "title"
	vbox.add_child(title_label)
	
	# 等级信息
	var level_label = Label.new()
	level_label.text = "等级: " + str(enemy.level)
	level_label.name = "level"
	vbox.add_child(level_label)
	
	# 生命值标签（简化）
	var health_label = Label.new()
	health_label.text = "生命值: 0/0"
	health_label.name = "health_label"
	vbox.add_child(health_label)
	
	# 生命值条
	var health_bar = ProgressBar.new()
	health_bar.name = "health_bar"
	health_bar.show_percentage = false
	vbox.add_child(health_bar)
	
	# 攻击力标签
	var attack_label = Label.new()
	attack_label.text = "攻击: 0-0"
	attack_label.name = "attack"
	vbox.add_child(attack_label)
	
	# 状态效果容器
	var effects_container = VBoxContainer.new()
	effects_container.name = "effects"
	vbox.add_child(effects_container)
	
	# 更新敌人数据
	update_enemy_ui_data(enemy, enemy_container)
	
	# 添加到敌人列表
	enemy_list.add_child(enemy_container)

# 更新敌人UI数据
func update_enemy_ui_data(enemy: Combatant, container: PanelContainer):
	if not enemy or not container:
		return
	
	var vbox = container.get_node("vbox")
	if not vbox:
		print("错误：找不到vbox节点")
		return
	
	# 更新生命值
	var health_label = vbox.get_node("health_label")
	var health_bar = vbox.get_node("health_bar")
	var attack_label = vbox.get_node("attack")
	var effects_container = vbox.get_node("effects")
	
	if health_label and health_bar:
		var max_health = enemy.get_combat_max_health()
		var current_health = enemy.get_combat_current_health()
		health_bar.max_value = max_health
		health_bar.value = current_health
		health_label.text = "生命值: " + str(int(current_health)) + "/" + str(int(max_health))
	else:
		print("错误：找不到health_label或health_bar节点")
	
	# 更新攻击力
	if attack_label:
		var attack_range = enemy.get_combat_attack_range()
		attack_label.text = "攻击: " + str(int(attack_range.min)) + "-" + str(int(attack_range.max))
	else:
		print("错误：找不到attack_label节点")
	
	# 更新状态效果
	if effects_container:
		update_combatant_effects(enemy, effects_container)
	else:
		print("错误：找不到effects_container节点")

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
	
	print("更新回合信息 - 当前状态: ", combat_manager.current_state)
	
	match combat_manager.current_state:
		CombatManager.CombatState.IDLE:
			turn_label.text = "等待战斗开始..."
		CombatManager.CombatState.PREPARING:
			turn_label.text = "准备战斗..."
		CombatManager.CombatState.PLAYER_TURN:
			turn_label.text = "你的回合"
		CombatManager.CombatState.ENEMY_TURN:
			turn_label.text = "敌人回合"
		CombatManager.CombatState.ANIMATING:
			turn_label.text = "执行行动中..."
		CombatManager.CombatState.VICTORY:
			turn_label.text = "战斗胜利！"
		CombatManager.CombatState.DEFEAT:
			turn_label.text = "战斗失败！"
		CombatManager.CombatState.ESCAPED:
			turn_label.text = "成功逃跑！"
		_:
			turn_label.text = "未知状态: " + str(combat_manager.current_state)
	
	print("回合标签设置为: ", turn_label.text)

# 更新行动按钮状态
func update_action_buttons(enabled: bool):
	attack_button.disabled = not enabled or is_auto_combat_enabled
	defend_button.disabled = not enabled or is_auto_combat_enabled
	skill_button.disabled = not enabled or is_auto_combat_enabled
	escape_button.disabled = not enabled or is_auto_combat_enabled
	auto_combat_toggle.disabled = not enabled

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
	if combat_manager and combat_manager.current_state == CombatManager.CombatState.PLAYER_TURN:
		var target = get_current_target()
		if target:
			combat_manager.basic_attack(target)

func _on_defend_pressed():
	if combat_manager and combat_manager.current_state == CombatManager.CombatState.PLAYER_TURN:
		combat_manager.defend()

func _on_skill_pressed():
	if combat_manager and combat_manager.current_state == CombatManager.CombatState.PLAYER_TURN:
		is_skill_panel_visible = not is_skill_panel_visible
		skill_panel.visible = is_skill_panel_visible
		update_skill_panel()

func _on_escape_pressed():
	if combat_manager and combat_manager.current_state == CombatManager.CombatState.PLAYER_TURN:
		combat_manager.attempt_escape()

func _on_auto_combat_toggled(button_pressed: bool):
	# 切换自动战斗状态
	is_auto_combat_enabled = button_pressed
	
	# 保存状态到玩家数据
	if combat_manager and combat_manager.player:
		combat_manager.player.set_auto_combat_enabled(button_pressed)
	
	update_action_buttons(true)
	
	if is_auto_combat_enabled:
		print("自动战斗已启用")
		turn_label.text = "自动战斗模式 - 你的回合"
		
		# 如果当前是玩家回合且启用了自动战斗，立即执行自动行动
		if combat_manager and combat_manager.current_state == CombatManager.CombatState.PLAYER_TURN:
			print("立即执行玩家自动行动")
			combat_manager.execute_player_auto_action()
	else:
		print("自动战斗已禁用")
		turn_label.text = "你的回合"

func _on_close_skill_pressed():
	is_skill_panel_visible = false
	skill_panel.visible = false

func _on_skill_selected(skill):
	if combat_manager and combat_manager.current_state == CombatManager.CombatState.PLAYER_TURN:
		var target = get_current_target()
		combat_manager.use_skill(skill, target)
		is_skill_panel_visible = false
		skill_panel.visible = false

# 获取当前目标（随机选择活着的敌人）
func get_current_target():
	if not combat_manager or combat_manager.enemies.is_empty():
		return null
	
	# 获取所有活着的敌人
	var alive_enemies = []
	for enemy in combat_manager.enemies:
		if enemy and enemy.is_alive_in_battle():
			alive_enemies.append(enemy)
	
	if alive_enemies.is_empty():
		return null
	
	# 随机选择一个活着的敌人
	var random_index = randi() % alive_enemies.size()
	return alive_enemies[random_index]

# 更新速度按钮状态
func update_speed_buttons():
	# 重置所有按钮状态
	speed_1x_button.disabled = false
	speed_2x_button.disabled = false
	speed_5x_button.disabled = false
	speed_10x_button.disabled = false
	speed_100x_button.disabled = false
	
	# 高亮当前选中的速度
	match current_combat_speed:
		1.0:
			speed_1x_button.disabled = true
		2.0:
			speed_2x_button.disabled = true
		5.0:
			speed_5x_button.disabled = true
		10.0:
			speed_10x_button.disabled = true
		100.0:
			speed_100x_button.disabled = true

# 设置战斗速度
func set_combat_speed(speed: float):
	current_combat_speed = speed
	update_speed_buttons()
	
	# 通知战斗管理器更新速度
	if combat_manager:
		combat_manager.set_combat_speed(speed)
	
	print("战斗速度设置为: x", speed)

# 速度按钮事件处理
func _on_speed_1x_pressed():
	set_combat_speed(1.0)

func _on_speed_2x_pressed():
	set_combat_speed(2.0)

func _on_speed_5x_pressed():
	set_combat_speed(5.0)

func _on_speed_10x_pressed():
	set_combat_speed(10.0)

func _on_speed_100x_pressed():
	set_combat_speed(100.0)

# 信号处理
func _on_combat_log_updated(message: String):
	combat_log.append_text(message + "\n")

func _on_combat_ended(result):
	match result:
		CombatManager.CombatState.VICTORY:
			combat_log.append_text("\n[color=green]战斗胜利！[/color]\n")
			update_action_buttons(false)
		CombatManager.CombatState.DEFEAT:
			combat_log.append_text("\n[color=red]战斗失败！[/color]\n")
			update_action_buttons(false)
		CombatManager.CombatState.ESCAPED:
			combat_log.append_text("\n[color=yellow]成功逃跑！[/color]\n")
			update_action_buttons(false)

func _on_turn_started(turn_owner: String):
	print("回合开始信号 - 回合所有者: ", turn_owner)
	
	# 更新回合信息
	update_turn_info()
	
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
