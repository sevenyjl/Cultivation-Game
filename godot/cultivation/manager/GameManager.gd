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
	# 精确更新修炼地灵气产生（每0.1秒）
	cultivation_location.generate_qi(0.1)

func _on_game_update() -> void:
	# 累计时间
	accumulated_time += 1.0
	
	# 每秒更新游戏状态
	cultivation_location.generate_qi(0.0)  # 确保任何剩余的灵气都被计算
	
	# 检查修炼地升级
	if cultivation_location.can_upgrade():
		cultivation_location.upgrade()
	
	# 更新战斗事件
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
	combat_manager.combat_ended.connect(_on_combat_ended)

# 开始战斗
func start_combat(enemy_types: Array = [], enemy_levels: Array = []) -> void:
	if not combat_manager or not player:
		push_error("战斗系统未初始化")
		return
	
	# 生成敌人
	var enemies = generate_enemies(enemy_types, enemy_levels)
	
	# 开始战斗
	combat_manager.start_combat(player, enemies)

# 生成敌人
func generate_enemies(enemy_types: Array, enemy_levels: Array) -> Array:
	var enemies = []
	
	# 如果没有指定敌人类型，随机生成
	if enemy_types.is_empty():
		enemy_types = [Enemy.EnemyType.BEAST, Enemy.EnemyType.DEMON, Enemy.EnemyType.SPIRIT]
	
	# 如果没有指定等级，根据玩家等级生成
	if enemy_levels.is_empty():
		var base_level = max(1, player.level - 2)
		for i in range(1, 4):  # 生成1-3个敌人
			enemy_levels.append(base_level + randi() % 3)
	
	# 创建敌人
	for i in range(min(enemy_types.size(), enemy_levels.size())):
		var enemy_type = enemy_types[i % enemy_types.size()]
		var enemy_level = enemy_levels[i % enemy_levels.size()]
		
		var enemy = preload("res://classs/combat/Enemy.gd").new(enemy_type, enemy_level)
		enemies.append(enemy)
	
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
		# 随机选择敌人类型
		var enemy_types = [Enemy.EnemyType.BEAST, Enemy.EnemyType.DEMON, Enemy.EnemyType.SPIRIT]
		var random_type = enemy_types[randi() % enemy_types.size()]
		
		# 根据修炼者等级生成敌人等级
		var enemy_level = max(1, cultivator.level - 1 + randi() % 3)
		
		start_combat([random_type], [enemy_level])

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
