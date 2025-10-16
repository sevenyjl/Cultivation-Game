# scripts/managers/CombatEventManager.gd
class_name CombatEventManager
extends Node

# 单例模式
static var instance: CombatEventManager

# 战斗事件类型
enum CombatEventType {
	RANDOM_ENCOUNTER,    # 随机遭遇
	BOSS_FIGHT,          # 首领战
	ARENA_BATTLE,        # 竞技场战斗
	QUEST_BATTLE,        # 任务战斗
	DUEL                 # 决斗
}

# 事件配置
@export var random_encounter_chance: float = 0.05  # 5%基础概率
@export var boss_encounter_interval: int = 10      # 每10级遇到首领
@export var arena_unlock_level: int = 5            # 竞技场解锁等级

# 战斗事件信号
signal combat_event_triggered(event_type: CombatEventType, data: Dictionary)
signal boss_spawned(boss_data: Dictionary)
signal arena_unlocked

func _ready():
	instance = self

# 检查随机遭遇
func check_random_encounter() -> bool:
	if not GameManager.instance or not GameManager.instance.can_start_combat():
		return false
	
	var encounter_chance = random_encounter_chance
	encounter_chance += GameManager.instance.cultivator.level * 0.01  # 等级越高概率越大
	
	return randf() < encounter_chance

# 触发随机遭遇
func trigger_random_encounter() -> void:
	if not GameManager.instance:
		return
	
	var enemy_types = [Enemy.EnemyType.BEAST, Enemy.EnemyType.DEMON, Enemy.EnemyType.SPIRIT]
	var random_type = enemy_types[randi() % enemy_types.size()]
	var enemy_level = max(1, GameManager.instance.cultivator.level - 1 + randi() % 3)
	
	var event_data = {
		"enemy_types": [random_type],
		"enemy_levels": [enemy_level],
		"is_random": true
	}
	
	combat_event_triggered.emit(CombatEventType.RANDOM_ENCOUNTER, event_data)
	GameManager.instance.start_combat_with_ui([random_type], [enemy_level])

# 检查首领战
func check_boss_encounter() -> bool:
	if not GameManager.instance or not GameManager.instance.can_start_combat():
		return false
	
	var level = GameManager.instance.cultivator.level
	return level > 0 and level % boss_encounter_interval == 0

# 触发首领战
func trigger_boss_encounter() -> void:
	if not GameManager.instance:
		return
	
	var boss_level = GameManager.instance.cultivator.level
	var boss_type = Enemy.EnemyType.BOSS
	
	var boss_data = {
		"name": "境界首领",
		"level": boss_level,
		"type": boss_type,
		"special_abilities": true
	}
	
	boss_spawned.emit(boss_data)
	
	var event_data = {
		"enemy_types": [boss_type],
		"enemy_levels": [boss_level],
		"is_boss": true,
		"boss_data": boss_data
	}
	
	combat_event_triggered.emit(CombatEventType.BOSS_FIGHT, event_data)
	GameManager.instance.start_combat_with_ui([boss_type], [boss_level])

# 检查竞技场解锁
func check_arena_unlock() -> bool:
	if not GameManager.instance:
		return false
	
	return GameManager.instance.cultivator.level >= arena_unlock_level

# 触发竞技场战斗
func trigger_arena_battle(difficulty: int = 1) -> void:
	if not GameManager.instance:
		return
	
	# 竞技场敌人更强
	var enemy_types = [Enemy.EnemyType.CULTIVATOR, Enemy.EnemyType.BOSS]
	var enemy_level = GameManager.instance.cultivator.level + difficulty
	
	var event_data = {
		"enemy_types": enemy_types,
		"enemy_levels": [enemy_level],
		"is_arena": true,
		"difficulty": difficulty
	}
	
	combat_event_triggered.emit(CombatEventType.ARENA_BATTLE, event_data)
	GameManager.instance.start_combat_with_ui(enemy_types, [enemy_level])

# 触发任务战斗
func trigger_quest_battle(quest_data: Dictionary) -> void:
	if not GameManager.instance:
		return
	
	var enemy_types = quest_data.get("enemy_types", [Enemy.EnemyType.BEAST])
	var enemy_levels = quest_data.get("enemy_levels", [GameManager.instance.cultivator.level])
	
	var event_data = {
		"enemy_types": enemy_types,
		"enemy_levels": enemy_levels,
		"is_quest": true,
		"quest_data": quest_data
	}
	
	combat_event_triggered.emit(CombatEventType.QUEST_BATTLE, event_data)
	GameManager.instance.start_combat_with_ui(enemy_types, enemy_levels)

# 触发决斗
func trigger_duel(opponent_data: Dictionary) -> void:
	if not GameManager.instance:
		return
	
	var event_data = {
		"opponent_data": opponent_data,
		"is_duel": true
	}
	
	combat_event_triggered.emit(CombatEventType.DUEL, event_data)
	# 决斗使用特殊的敌人生成逻辑
	generate_duel_opponent(opponent_data)

# 生成决斗对手
func generate_duel_opponent(opponent_data: Dictionary) -> void:
	var opponent = preload("res://classs/combat/Enemy.gd").new(Enemy.EnemyType.CULTIVATOR, opponent_data.get("level", 1))
	opponent.set_name_info(opponent_data.get("name", "神秘对手"))
	
	# 设置特殊属性
	opponent.ai_intelligence = 0.8  # 高智能
	opponent.ai_aggression = 0.7    # 高攻击性
	
	GameManager.instance.start_combat_with_ui([opponent], [])

# 更新战斗事件（每回合调用）
func update_combat_events() -> void:
	if not GameManager.instance or not GameManager.instance.can_start_combat():
		return
	
	# 检查随机遭遇
	if check_random_encounter():
		trigger_random_encounter()
		return
	
	# 检查首领战
	if check_boss_encounter():
		trigger_boss_encounter()
		return
	
	# 检查竞技场解锁
	if check_arena_unlock():
		arena_unlocked.emit()

# 获取事件信息
func get_event_info() -> Dictionary:
	return {
		"random_encounter_chance": random_encounter_chance,
		"boss_encounter_interval": boss_encounter_interval,
		"arena_unlock_level": arena_unlock_level,
		"can_trigger_random": check_random_encounter(),
		"can_trigger_boss": check_boss_encounter(),
		"arena_unlocked": check_arena_unlock()
	}
