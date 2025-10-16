# scripts/managers/GameManager.gd
class_name GameManager
extends Node

# 单例模式
static var instance: GameManager

# 游戏对象引用
@export var cultivator: Cultivator
@export var cultivation_location: CultivationLocation

# 战斗系统
var combat_manager: CombatManager
var player: Player
var combat_event_manager

# 游戏定时器
var game_timer: Timer
# 精确计时器，用于更频繁地更新灵气产生
var precise_timer: Timer
# 累计时间，用于跟踪秒数
var accumulated_time: float = 0.0

func _ready() -> void:
	instance = self
	
	# 初始化游戏对象
	if not cultivator:
		cultivator = Cultivator.new()
		cultivator.set_name_info(cultivator.generate_random_name())  # 设置随机名称
	if not cultivation_location:
		cultivation_location = CultivationLocation.new()
	
	# 初始化战斗系统
	initialize_combat_system()
	
	# 初始化战斗事件管理器
	initialize_combat_events()
	
	
	# 设置游戏循环
	setup_game_loop()

func setup_game_loop() -> void:
	# 主游戏循环定时器（每秒触发一次）
	game_timer = Timer.new()
	add_child(game_timer)
	game_timer.wait_time = 1.0
	game_timer.connect("timeout", Callable(self, "_on_game_update"))
	game_timer.autostart = true
	
	# 精确更新定时器（每0.1秒触发一次）
	precise_timer = Timer.new()
	add_child(precise_timer)
	precise_timer.wait_time = 0.1
	precise_timer.connect("timeout", Callable(self, "_on_precise_update"))
	precise_timer.autostart = true
	
	# 手动启动定时器以确保它们正常工作
	game_timer.start()
	precise_timer.start()

func _on_precise_update() -> void:
	# 只有在非战斗状态下才更新修炼地灵气产生
	if not is_in_combat():
		cultivation_location.generate_qi(0.1)
	# 调试信息（每5秒输出一次）
	if int(Time.get_unix_time_from_system()) % 5 == 0:
		var combat_status = "战斗中" if is_in_combat() else "非战斗"
		var state_info = ""
		if combat_manager:
			state_info = " | 战斗状态: " + str(combat_manager.current_state)
		print("游戏状态: " + combat_status + state_info + " | 修炼地灵气: " + str(int(cultivation_location.current_qi)))

func _on_game_update() -> void:
	# 只有在非战斗状态下才累计时间
	if not is_in_combat():
		accumulated_time += 1.0
	
	# 只有在非战斗状态下才更新游戏状态
	if not is_in_combat():
		# 确保任何剩余的灵气都被计算
		cultivation_location.generate_qi(0.0)
		
		# 检查修炼地升级
		if cultivation_location.can_upgrade():
			cultivation_location.upgrade()
	
	# 更新战斗事件（战斗事件管理器应该始终更新）
	if combat_event_manager:
		combat_event_manager.update_combat_events()

# 吸收灵气
func absorb_qi(amount: float) -> void:
	var absorbed = min(amount, cultivation_location.current_qi)
	cultivation_location.current_qi -= absorbed
	cultivator.qi += absorbed

# 获取修炼者境界信息
func get_cultivator_info() -> Dictionary:
	return {
		"name": cultivator.get_name_info(),
		"level": cultivator.level,
		"stage": cultivator.stage_name,
		"current_qi": cultivator.qi,
		"required_qi": cultivator.get_required_qi()
	}

# 初始化战斗系统
func initialize_combat_system() -> void:
	# 创建战斗管理器
	combat_manager = preload("res://manager/combat/CombatManager.gd").new()
	add_child(combat_manager)
	
	# 创建玩家战斗者（基于现有修炼者）
	player = preload("res://classs/combat/Player.gd").new()
	player.set_name_info(cultivator.get_name_info())
	player.level = cultivator.level
	player.qi = cultivator.qi
	player.health_base = cultivator.health_base
	player.health_current = cultivator.health_current
	player.attack_base_min = cultivator.attack_base_min
	player.attack_base_max = cultivator.attack_base_max
	
	# 连接战斗结束信号
	combat_manager.combat_ended.connect(on_combat_ended)

# 开始战斗
func start_combat(enemy_types: Array = [], enemy_levels: Array = []) -> void:
	if not combat_manager or not player:
		push_error("战斗系统未初始化")
		return
	
	# 生成敌人
	var enemies = generate_enemies(enemy_types, enemy_levels)
	
	# 开始战斗
	combat_manager.start_combat(player, enemies)

# 开始战斗并显示UI
func start_combat_with_ui(enemy_types: Array = [], enemy_levels: Array = []) -> void:
	print("开始战斗并显示UI")
	
	# 先生成敌人
	var enemies = generate_enemies(enemy_types, enemy_levels)
	print("生成的敌人数量: ", enemies.size())
	
	# 开始战斗
	combat_manager.start_combat(player, enemies)
	print("战斗已开始，当前状态: ", combat_manager.current_state)
	
	# 获取主场景引用
	var main_scene = get_tree().current_scene
	if not main_scene:
		push_error("无法获取主场景引用")
		return
	
	print("主场景引用获取成功: ", main_scene.name)
	
	# 调用主场景的显示战斗UI方法
	if main_scene.has_method("show_combat_ui"):
		print("调用主场景的show_combat_ui方法")
		# 显示战斗UI（但不重新开始战斗）
		main_scene.call_deferred("show_combat_ui")
	else:
		push_error("主场景没有show_combat_ui方法")

# 生成敌人
func generate_enemies(enemy_types: Array, enemy_levels: Array) -> Array:
	var enemies = []
	
	# 如果没有指定敌人类型，随机生成
	if enemy_types.is_empty():
		enemy_types = [Enemy.EnemyType.BEAST, Enemy.EnemyType.DEMON, Enemy.EnemyType.SPIRIT]
	
	# 如果没有指定等级，根据修炼地等级生成
	if enemy_levels.is_empty():
		var location_level = cultivation_location.level
		var player_level = player.level
		
		# 敌人等级基于修炼地等级，但不超过玩家等级太多
		var base_level = max(1, min(location_level, player_level + 1))
		var enemy_count = min(3, max(1, min(location_level, 3)))  # 最多3个敌人
		
		for i in range(enemy_count):
			# 敌人等级在base_level-1到base_level+1之间随机
			var enemy_level = max(1, base_level - 1 + randi() % 3)
			enemy_levels.append(enemy_level)
	
	print("根据修炼地等级 ", cultivation_location.level, " 生成敌人，等级范围: ", enemy_levels)
	
	# 创建敌人
	for i in range(min(enemy_types.size(), enemy_levels.size())):
		var enemy_type = enemy_types[i % enemy_types.size()]
		var enemy_level = enemy_levels[i % enemy_levels.size()]
		
		var enemy = preload("res://classs/combat/Enemy.gd").new(enemy_type, enemy_level)
		enemies.append(enemy)
		print("生成敌人: ", enemy.get_name_info(), " 等级: ", enemy_level)
	
	return enemies

# 战斗结束处理
func _on_combat_ended(result) -> void:
	match result:
		5:  # VICTORY
			handle_combat_victory()
		6:  # DEFEAT
			handle_combat_defeat()
		7:  # ESCAPED
			handle_combat_escape()

# 处理战斗胜利
func handle_combat_victory() -> void:
	# 同步玩家状态到修炼者
	sync_player_to_cultivator()
	
	# 添加战斗奖励
	var reward_qi = 0.0
	for enemy in combat_manager.enemies:
		if enemy:
			reward_qi += enemy.qi_reward
	
	cultivator.qi += reward_qi
	
	# 记录胜利日志
	print("战斗胜利！获得灵气: " + str(reward_qi))

# 处理战斗失败
func handle_combat_defeat() -> void:
	# 同步玩家状态到修炼者
	sync_player_to_cultivator()
	
	# 失败惩罚（可选）
	cultivator.qi = max(0, cultivator.qi - 50)
	
	# 记录失败日志
	print("战斗失败，失去一些灵气")

# 处理逃跑
func handle_combat_escape() -> void:
	# 同步玩家状态到修炼者
	sync_player_to_cultivator()
	
	# 逃跑惩罚（可选）
	cultivator.qi = max(0, cultivator.qi - 20)
	
	# 记录逃跑日志
	print("成功逃跑，但失去一些灵气")

# 同步玩家状态到修炼者
func sync_player_to_cultivator() -> void:
	if not player:
		return
	
	# 同步基本属性
	cultivator.level = player.level
	cultivator.qi = player.qi
	cultivator.health_base = player.health_base
	cultivator.health_current = player.health_current
	cultivator.attack_base_min = player.attack_base_min
	cultivator.attack_base_max = player.attack_base_max

# 同步修炼者状态到玩家
func sync_cultivator_to_player() -> void:
	if not player:
		return
	
	# 同步基本属性
	player.level = cultivator.level
	player.qi = cultivator.qi
	player.health_base = cultivator.health_base
	player.health_current = cultivator.health_current
	player.attack_base_min = cultivator.attack_base_min
	player.attack_base_max = cultivator.attack_base_max

# 获取战斗管理器
func get_combat_manager() -> CombatManager:
	return combat_manager

# 获取玩家战斗者
func get_player() -> Player:
	return player

# 检查是否可以战斗
func can_start_combat() -> bool:
	return combat_manager and player and combat_manager.current_state == 0  # IDLE

# 随机遭遇战斗
func random_encounter() -> void:
	if not can_start_combat():
		return
	
	# 根据修炼者等级决定遭遇概率
	var encounter_chance = 0.1  # 10%基础概率
	encounter_chance += cultivator.level * 0.01  # 等级越高概率越大
	
	if randf() < encounter_chance:
		print("=== 随机遭遇战斗触发！概率: ", encounter_chance, " ===")
		# 随机选择敌人类型
		var enemy_types = [Enemy.EnemyType.BEAST, Enemy.EnemyType.DEMON, Enemy.EnemyType.SPIRIT]
		var random_type = enemy_types[randi() % enemy_types.size()]
		
		# 根据修炼者等级生成敌人等级
		var enemy_level = max(1, cultivator.level - 1 + randi() % 3)
		
		print("敌人类型: ", random_type, " 等级: ", enemy_level)
		print("调用 start_combat_with_ui() 方法")
		# 开始战斗并显示UI
		start_combat_with_ui([random_type], [enemy_level])

# 初始化战斗事件管理器
func initialize_combat_events() -> void:
	# 创建战斗事件管理器
	combat_event_manager = preload("res://manager/CombatEventManager.gd").new()
	add_child(combat_event_manager)
	
	# 连接战斗事件信号
	combat_event_manager.combat_event_triggered.connect(_on_combat_event_triggered)
	combat_event_manager.boss_spawned.connect(_on_boss_spawned)
	combat_event_manager.arena_unlocked.connect(_on_arena_unlocked)

# 战斗事件处理
func _on_combat_event_triggered(event_type, _data: Dictionary):
	match event_type:
		0:  # RANDOM_ENCOUNTER
			print("随机遭遇战斗！")
		1:  # BOSS_FIGHT
			print("首领战开始！")
		2:  # ARENA_BATTLE
			print("竞技场战斗！")
		3:  # QUEST_BATTLE
			print("任务战斗！")
		4:  # DUEL
			print("决斗开始！")

func _on_boss_spawned(boss_data: Dictionary):
	print("首领出现: " + boss_data.name + " (等级: " + str(boss_data.level) + ")")

func _on_arena_unlocked():
	print("竞技场已解锁！")

# 获取战斗事件管理器
func get_combat_event_manager():
	return combat_event_manager

# 检查是否在战斗中
func is_in_combat() -> bool:
	if not combat_manager:
		return false
	
	# 只有在进行中的战斗状态才算在战斗中
	var active_states = [
		CombatManager.CombatState.PREPARING,
		CombatManager.CombatState.PLAYER_TURN,
		CombatManager.CombatState.ENEMY_TURN,
		CombatManager.CombatState.ANIMATING
	]
	
	var in_combat = combat_manager.current_state in active_states
	return in_combat

# 战斗结束后重置状态
func on_combat_ended(result):
	print("战斗结束，结果: ", result)
	# 延迟重置状态，确保UI更新完成
	await get_tree().create_timer(2.0).timeout
	if combat_manager:
		combat_manager.current_state = CombatManager.CombatState.IDLE
		print("战斗状态已重置为IDLE")
