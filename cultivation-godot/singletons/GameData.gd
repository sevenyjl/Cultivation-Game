extends Node

# 全局游戏数据管理器（单例）
# 负责存储玩家数据，并提供存档和读档功能

var player: BaseCultivation
var formation = \
[
	[null,null,null],
	[null,null,null],
	[null,null,null],
	[null,null,null],
]

# 队友集合
var team_members:Array[BaseCultivation] = [
]



#region 其他信息
var mainNode:MainNode
#endregion
# 最大倍速10倍速，最小1倍速
var 全局倍速:int=1
var 最大全局倍速:int=20

# 存档文件路径
var save_directory: String = "user://saves/"

func 游戏初始化():
	# 先随机生成玩家
	player = BaseCultivation.new()
	player.name_str = "张三"
	for i in 10:
		player.level_up(true)
	# 玩家初始化阵型位置
	formation[0][0]=player
	player.backpack.添加物品(Wepoen.new())
	mainNode.add_child(player)
	pass
