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
@onready var enemy_name_value: Label = $MainContainer/InfoPanel/EnemyPanel/EnemyVBox/EnemyGrid/EnemyNameValue
@onready var enemy_level_value: Label = $MainContainer/InfoPanel/EnemyPanel/EnemyVBox/EnemyGrid/EnemyLevelValue
@onready var enemy_health_bar: ProgressBar = $MainContainer/InfoPanel/EnemyPanel/EnemyVBox/EnemyHealthContainer/EnemyHealthBar
@onready var enemy_health_label: Label = $MainContainer/InfoPanel/EnemyPanel/EnemyVBox/EnemyHealthContainer/EnemyHealthLabel
@onready var enemy_attack_label: Label = $MainContainer/InfoPanel/EnemyPanel/EnemyVBox/EnemyAttackLabel
@onready var enemy_effects_container: VBoxContainer = $MainContainer/InfoPanel/EnemyPanel/EnemyVBox/EnemyEffectsContainer

# 行动按钮
@onready var attack_button: Button = $MainContainer/ActionPanel/ActionContainer/ButtonContainer/AttackButton
@onready var defend_button: Button = $MainContainer/ActionPanel/ActionContainer/ButtonContainer/DefendButton
@onready var skill_button: Button = $MainContainer/ActionPanel/ActionContainer/ButtonContainer/SkillButton
@onready var escape_button: Button = $MainContainer/ActionPanel/ActionContainer/ButtonContainer/EscapeButton

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

func _ready():
	# 初始化UI状态
	initialize_ui_state()

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
	if not combat_manager or combat_manager.enemies.is_empty():
		return
	
	# 显示第一个敌人（可以扩展为多个敌人）
	var enemy = combat_manager.enemies[0]
	if not enemy:
		return
	
	# 更新敌人基本信息
	enemy_name_value.text = enemy.get_name_info()
	enemy_level_value.text = str(enemy.level)
	
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

func _on_close_skill_pressed():
	is_skill_panel_visible = false
	skill_panel.visible = false

func _on_skill_selected(skill):
	if combat_manager and combat_manager.current_state == CombatManager.CombatState.PLAYER_TURN:
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
