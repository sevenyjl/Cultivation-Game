# scripts/managers/combat/CombatManager.gd
class_name CombatManager
extends Node

# 单例模式
static var instance: CombatManager

# 战斗状态枚举
enum CombatState {
	IDLE,           # 空闲状态
	PREPARING,      # 准备阶段
	PLAYER_TURN,    # 玩家回合
	ENEMY_TURN,     # 敌人回合
	ANIMATING,      # 动画阶段
	VICTORY,        # 胜利
	DEFEAT,         # 失败
	ESCAPED         # 逃跑
}

# 战斗相关属性
@export var current_state: CombatState = CombatState.IDLE
@export var player: Player
@export var enemies: Array = []  # 敌人数组
var turn_manager
var combat_ai

# 战斗UI引用
var combat_ui: Node = null

# 战斗日志
var combat_log: Array[String] = []

# 战斗统计
var combat_stats: Dictionary = {
	"turns_taken": 0,
	"damage_dealt": 0.0,
	"damage_taken": 0.0,
	"skills_used": 0,
	"critical_hits": 0,
	"dodges": 0
}

# 战斗事件信号
signal combat_started
signal combat_ended(result: CombatState)
signal turn_started(turn_owner: String)
signal turn_ended(turn_owner: String)
signal action_executed(action: CombatAction)
signal combat_log_updated(message: String)

func _ready() -> void:
	instance = self
	turn_manager = preload("res://manager/combat/TurnManager.gd").new()
	combat_ai = preload("res://manager/combat/CombatAI.gd").new()
	add_child(turn_manager)
	add_child(combat_ai)

# 开始战斗
func start_combat(player_instance: Player, enemy_instances: Array) -> void:
	print("开始战斗 - 当前状态: ", current_state)
	
	# 如果战斗正在进行中（不是空闲或已结束状态），则不允许开始新战斗
	if current_state == CombatState.PREPARING or current_state == CombatState.PLAYER_TURN or current_state == CombatState.ENEMY_TURN or current_state == CombatState.ANIMATING:
		push_warning("战斗已在进行中，无法开始新战斗")
		return
	
	# 设置战斗参与者
	player = player_instance
	enemies = enemy_instances.duplicate()
	
	print("玩家: ", player.get_name_info() if player else "无")
	print("敌人数量: ", enemies.size())
	
	# 重置战斗状态
	reset_combat_state()
	
	# 初始化回合管理器
	turn_manager.initialize_combatants(player, enemies)
	
	# 设置战斗状态
	current_state = CombatState.PREPARING
	
	# 记录战斗开始
	add_combat_log("战斗开始！")
	add_combat_log("玩家: " + player.get_name_info())
	for enemy in enemies:
		add_combat_log("敌人: " + enemy.get_name_info())
	
	# 发出信号
	combat_started.emit()
	
	print("开始第一回合")
	# 开始第一回合
	start_next_turn()

# 重置战斗状态
func reset_combat_state() -> void:
	current_state = CombatState.IDLE
	combat_log.clear()
	combat_stats = {
		"turns_taken": 0,
		"damage_dealt": 0.0,
		"damage_taken": 0.0,
		"skills_used": 0,
		"critical_hits": 0,
		"dodges": 0
	}
	
	# 重置所有战斗者状态
	if player:
		player.reset_combat_state()
	
	for enemy in enemies:
		if enemy:
			enemy.reset_combat_state()

# 开始下一回合
func start_next_turn() -> void:
	print("开始下一回合 - 当前状态: ", current_state)
	
	if current_state == CombatState.VICTORY or current_state == CombatState.DEFEAT or current_state == CombatState.ESCAPED:
		print("战斗已结束，无法开始新回合")
		return
	
	# 获取下一个行动者
	var next_actor = turn_manager.get_next_actor()
	print("下一个行动者: ", next_actor.get_name_info() if next_actor else "无")
	
	if not next_actor:
		push_error("无法获取下一个行动者")
		return
	
	# 更新状态效果
	update_all_effects()
	
	# 检查战斗是否结束
	if check_combat_end():
		print("战斗已结束")
		return
	
	# 设置当前回合
	if next_actor == player:
		current_state = CombatState.PLAYER_TURN
		print("设置玩家回合")
		turn_started.emit("player")
		add_combat_log("玩家回合开始")
	else:
		current_state = CombatState.ENEMY_TURN
		print("设置敌人回合: ", next_actor.get_name_info())
		turn_started.emit("enemy")
		add_combat_log(next_actor.get_name_info() + " 的回合开始")
		
		# 自动执行敌人行动
		print("执行敌人行动")
		execute_enemy_action()
	
	# 更新UI
	print("更新战斗UI")
	update_combat_ui()

# 执行玩家行动
func execute_player_action(action: CombatAction) -> void:
	if current_state != CombatState.PLAYER_TURN:
		push_warning("不是玩家回合，无法执行行动")
		return
	
	execute_action(action)

# 执行敌人行动
func execute_enemy_action() -> void:
	print("开始执行敌人行动")
	
	if current_state != CombatState.ENEMY_TURN:
		push_warning("不是敌人回合，无法执行行动")
		return
	
	# 获取当前行动的敌人
	var current_enemy = turn_manager.get_current_actor()
	print("当前敌人: ", current_enemy.get_name_info() if current_enemy else "无")
	
	if not current_enemy:
		push_error("无法获取当前敌人")
		return
	
	# 使用AI选择行动
	print("AI选择行动中...")
	var action = combat_ai.choose_action(current_enemy, player, enemies)
	print("AI选择的行动: ", action.action_type if action else "无")
	
	if action:
		print("执行AI选择的行动")
		execute_action(action)
	else:
		# 如果AI没有选择行动，使用基础攻击
		print("使用基础攻击")
		var basic_action = CombatAction.new(CombatAction.ActionType.ATTACK, current_enemy, player)
		execute_action(basic_action)

# 执行行动
func execute_action(action: CombatAction) -> void:
	print("执行行动: ", action.action_type, " 行动者: ", action.actor.get_name_info() if action.actor else "无")
	
	if not action or not action.is_valid():
		push_warning("无效的行动")
		return
	
	# 设置动画状态
	current_state = CombatState.ANIMATING
	print("设置动画状态")
	
	# 执行行动
	print("执行行动逻辑")
	var result = action.execute()
	print("行动执行结果: ", result)
	
	# 检查逃跑成功
	if action.action_type == CombatAction.ActionType.ESCAPE and result.get("success", false):
		print("逃跑成功，结束战斗")
		end_combat(CombatState.ESCAPED)
		return
	
	# 更新战斗统计
	update_combat_stats(action, result)
	
	# 记录行动结果
	log_action_result(action, result)
	
	# 发出信号
	action_executed.emit(action)
	
	# 更新UI
	update_combat_ui()
	
	# 检查战斗是否结束
	if check_combat_end():
		print("战斗已结束，不进入下一回合")
		return
	
	# 延迟后开始下一回合
	print("等待1秒后开始下一回合")
	await get_tree().create_timer(1.0).timeout
	print("开始下一回合")
	start_next_turn()

# 更新所有战斗者的状态效果
func update_all_effects() -> void:
	# 更新玩家效果
	if player and player.is_alive_in_battle():
		player.update_effects()
	
	# 更新敌人效果
	for enemy in enemies:
		if enemy and enemy.is_alive_in_battle():
			enemy.update_effects()

# 检查战斗是否结束
func check_combat_end() -> bool:
	# 检查玩家是否死亡
	if not player or not player.is_alive_in_battle():
		end_combat(CombatState.DEFEAT)
		return true
	
	# 检查是否所有敌人都死亡
	var alive_enemies = 0
	for enemy in enemies:
		if enemy and enemy.is_alive_in_battle():
			alive_enemies += 1
	
	if alive_enemies == 0:
		end_combat(CombatState.VICTORY)
		return true
	
	return false

# 结束战斗
func end_combat(result: CombatState) -> void:
	current_state = result
	
	match result:
		CombatState.VICTORY:
			handle_victory()
		CombatState.DEFEAT:
			handle_defeat()
		CombatState.ESCAPED:
			handle_escape()
	
	# 发出信号
	combat_ended.emit(result)
	
	# 更新UI
	update_combat_ui()

# 处理胜利
func handle_victory() -> void:
	add_combat_log("战斗胜利！")
	
	# 计算奖励
	var total_exp = 0.0
	var total_qi = 0.0
	
	for enemy in enemies:
		if enemy:
			total_exp += enemy.experience_reward
			total_qi += enemy.qi_reward
	
	# 应用奖励
	player.qi += total_qi
	# 这里可以添加经验系统
	
	add_combat_log("获得灵气: " + str(total_qi))
	add_combat_log("获得经验: " + str(total_exp))

# 处理失败
func handle_defeat() -> void:
	add_combat_log("战斗失败...")
	# 这里可以添加失败惩罚

# 处理逃跑
func handle_escape() -> void:
	add_combat_log("成功逃跑！")
	# 这里可以添加逃跑惩罚

# 更新战斗统计
func update_combat_stats(action: CombatAction, result: Dictionary) -> void:
	combat_stats["turns_taken"] += 1
	
	if result.has("damage") and result["damage"] > 0:
		combat_stats["damage_dealt"] += result["damage"]
	
	if result.has("actual_damage") and result["actual_damage"] > 0:
		combat_stats["damage_taken"] += result["actual_damage"]
	
	if action.action_type == CombatAction.ActionType.SKILL:
		combat_stats["skills_used"] += 1
	
	if result.has("critical") and result["critical"]:
		combat_stats["critical_hits"] += 1
	
	if result.has("dodged") and result["dodged"]:
		combat_stats["dodges"] += 1

# 记录行动结果
func log_action_result(action: CombatAction, result: Dictionary) -> void:
	var message = action.get_action_description()
	
	if result.has("message"):
		message += " - " + result["message"]
	
	if result.has("damage") and result["damage"] > 0:
		message += " 造成 " + str(result["damage"]) + " 点伤害"
	
	if result.has("heal") and result["heal"] > 0:
		message += " 恢复 " + str(result["heal"]) + " 点生命值"
	
	if result.has("critical") and result["critical"]:
		message += " (暴击!)"
	
	if result.has("dodged") and result["dodged"]:
		message += " (被闪避!)"
	
	add_combat_log(message)

# 添加战斗日志
func add_combat_log(message: String) -> void:
	var timestamp = Time.get_time_string_from_system()
	var log_entry = "[" + timestamp + "] " + message
	combat_log.append(log_entry)
	combat_log_updated.emit(log_entry)
	print(log_entry)

# 更新战斗UI
func update_combat_ui() -> void:
	if combat_ui and combat_ui.has_method("update_ui"):
		combat_ui.update_ui()

# 获取战斗信息
func get_combat_info() -> Dictionary:
	return {
		"state": current_state,
		"player": player.get_combat_info() if player else {},
		"enemies": enemies.map(func(e): return e.get_combat_info() if e else {}),
		"stats": combat_stats,
		"log": combat_log
	}

# 获取当前回合的行动者
func get_current_actor():
	return turn_manager.get_current_actor()

# 获取可用的玩家技能
func get_available_player_skills() -> Array:
	if not player:
		return []
	return player.get_usable_skills()

# 获取可用的敌人
func get_available_enemies() -> Array:
	return enemies.filter(func(e): return e and e.is_alive_in_battle())

# 逃跑
func attempt_escape() -> void:
	if current_state != CombatState.PLAYER_TURN:
		push_warning("只能在玩家回合逃跑")
		return
	
	var escape_action = CombatAction.new(CombatAction.ActionType.ESCAPE, player)
	execute_action(escape_action)

# 防御
func defend() -> void:
	if current_state != CombatState.PLAYER_TURN:
		push_warning("只能在玩家回合防御")
		return
	
	var defend_action = CombatAction.new(CombatAction.ActionType.DEFEND, player)
	execute_action(defend_action)

# 使用技能
func use_skill(skill, target = null) -> void:
	if current_state != CombatState.PLAYER_TURN:
		push_warning("只能在玩家回合使用技能")
		return
	
	var skill_action = CombatAction.new(CombatAction.ActionType.SKILL, player, target, skill)
	execute_action(skill_action)

# 基础攻击
func basic_attack(target) -> void:
	if current_state != CombatState.PLAYER_TURN:
		push_warning("只能在玩家回合攻击")
		return
	
	var attack_action = CombatAction.new(CombatAction.ActionType.ATTACK, player, target)
	execute_action(attack_action)
