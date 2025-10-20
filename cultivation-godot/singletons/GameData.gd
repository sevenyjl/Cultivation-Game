extends Node

# 全局游戏数据管理器（单例）
# 负责存储玩家数据，并提供存档和读档功能

var player: BaseCultivation

# 存档文件路径
var save_directory: String = "user://saves/"

func 游戏初始化():
	# 先随机生成玩家
	player = BaseCultivation.new()
	player.name_str = "张三"
	for i in 3:
		player.level_up()
	pass
