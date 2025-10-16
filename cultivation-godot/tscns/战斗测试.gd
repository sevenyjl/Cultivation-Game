extends Node

# 战斗系统测试脚本
# 演示自动战斗功能

@onready var battle_ui = $战斗UI

func _ready():
	print("=== 战斗系统测试 ===\n")
	
	# 创建测试队伍数据
	var player_team = create_test_player_team()
	var enemy_team = create_test_enemy_team()
	
	# 连接战斗UI信号
	battle_ui.battle_started.connect(_on_battle_started)
	battle_ui.battle_ended.connect(_on_battle_ended)
	battle_ui.turn_changed.connect(_on_turn_changed)
	
	# 初始化战斗
	battle_ui.初始化战斗(player_team, enemy_team)

# 创建测试玩家队伍
func create_test_player_team() -> Array:
	var team = []
	
	# 玩家1 - 修仙者
	var player1 = {
		"name": "张三",
		"hp": 120,
		"max_hp": 120,
		"mp": 80,
		"max_mp": 80,
		"strength": 15,
		"agility": 12,
		"intelligence": 18,
		"constitution": 14
	}
	team.append(player1)
	
	# 玩家2 - 队友
	var player2 = {
		"name": "李四",
		"hp": 100,
		"max_hp": 100,
		"mp": 60,
		"max_mp": 60,
		"strength": 12,
		"agility": 15,
		"intelligence": 14,
		"constitution": 12
	}
	team.append(player2)
	
	return team

# 创建测试敌人队伍
func create_test_enemy_team() -> Array:
	var team = []
	
	# 敌人1 - 野狼
	var enemy1 = {
		"name": "野狼",
		"hp": 80,
		"max_hp": 80,
		"mp": 20,
		"max_mp": 20,
		"strength": 10,
		"agility": 14,
		"intelligence": 6,
		"constitution": 12,
		"visible": true
	}
	team.append(enemy1)
	
	# 敌人2 - 哥布林
	var enemy2 = {
		"name": "哥布林",
		"hp": 60,
		"max_hp": 60,
		"mp": 30,
		"max_mp": 30,
		"strength": 8,
		"agility": 12,
		"intelligence": 10,
		"constitution": 8,
		"visible": true
	}
	team.append(enemy2)
	
	# 敌人3 - 隐藏Boss
	var enemy3 = {
		"name": "暗影魔",
		"hp": 150,
		"max_hp": 150,
		"mp": 100,
		"max_mp": 100,
		"strength": 20,
		"agility": 16,
		"intelligence": 25,
		"constitution": 18,
		"visible": false  # 隐藏状态
	}
	team.append(enemy3)
	
	return team

# 战斗开始回调
func _on_battle_started():
	print("战斗开始！")

# 战斗结束回调
func _on_battle_ended(victory: bool):
	if victory:
		print("战斗胜利！")
	else:
		print("战斗失败！")
	
	# 显示最终状态
	print("\n" + battle_ui.get_battle_status())

# 回合变化回调
func _on_turn_changed(turn_number: int):
	print("第 " + str(turn_number) + " 回合开始")

# 测试战斗控制功能
func _input(event):
	if event.is_action_pressed("ui_accept"):  # 按空格键
		test_battle_controls()

func test_battle_controls():
	print("\n=== 测试战斗控制功能 ===")
	
	# 测试战斗状态
	print(battle_ui.get_battle_status())
	
	# 测试战斗速度调整
	battle_ui.set_battle_speed(2.0)
	print("战斗速度设置为 2x")
	
	# 测试暂停/恢复
	battle_ui.pause_battle()
	await get_tree().create_timer(1.0).timeout
	battle_ui.resume_battle()
	print("测试暂停/恢复功能")
	
	# 测试自动战斗切换
	battle_ui.toggle_auto_battle()
	print("切换自动战斗状态")
