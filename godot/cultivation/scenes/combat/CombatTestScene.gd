# scripts/scenes/combat/CombatTestScene.gd
extends Node2D

# 战斗管理器引用
var combat_manager
var player: Player
var enemy: Enemy

# UI控制器
var combat_ui: Control

func _ready():
	# 创建战斗管理器
	combat_manager = preload("res://manager/combat/CombatManager.gd").new()
	add_child(combat_manager)
	
	# 创建UI控制器
	create_combat_ui()
	
	# 创建测试战斗者
	create_test_combatants()
	
	# 开始测试战斗
	start_test_combat()

func create_combat_ui():
	# 加载战斗UI场景
	var combat_ui_scene = preload("res://scenes/combat/CombatUI.tscn")
	combat_ui = combat_ui_scene.instantiate()
	add_child(combat_ui)
	
	# 设置战斗管理器
	combat_ui.set_combat_manager(combat_manager)

func create_test_combatants():
	# 创建玩家
	player = preload("res://classs/combat/Player.gd").new()
	player.set_name_info("测试玩家")
	
	# 创建敌人
	enemy = preload("res://classs/combat/Enemy.gd").new(Enemy.EnemyType.BEAST, 5)
	enemy.set_name_info("测试妖兽")

func start_test_combat():
	# 开始战斗
	combat_manager.start_combat(player, [enemy])
