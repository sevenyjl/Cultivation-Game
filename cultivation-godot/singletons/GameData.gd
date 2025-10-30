extends Node

# 全局游戏数据管理器（单例）
# 负责存储玩家数据，并提供存档和读档功能

# 细粒度信号
signal player_changed  # 玩家数据变化时触发
signal team_members_changed  # 队伍成员变化时触发
signal formation_changed  # 阵型变化时触发
signal global_speed_changed  # 全局倍速变化时触发

var player: BaseCultivation
var formation: Array = [
	[null,null,null],
	[null,null,null],
	[null,null,null],
	[null,null,null],
]

# 队友集合
var team_members: Array[BaseCultivation] = []

# 最大倍速10倍速，最小1倍速
var _global_speed: int = 1
var _max_global_speed: int = 20

# 存档文件路径
var save_directory: String = "user://saves/"

# 主节点引用
var _main_node: Node

# 属性访问器
func get_global_speed() -> int:
	return _global_speed

func set_global_speed(value: int) -> void:
	value = clamp(value, 1, _max_global_speed)
	if _global_speed != value:
		_global_speed = value
		global_speed_changed.emit()

# 主节点访问器
func get_main_node() -> Node:
	return _main_node

func set_main_node(node: Node) -> void:
	_main_node = node

# 初始化游戏
func initialize_game() -> void:
	# 先随机生成玩家
	player = BaseCultivation.new()
	player.name_str = "张三"
	for i in 10:
		player.level_up(true)
	# 玩家初始化阵型位置
	formation[0][0] = player
	#player.backpack.max_slots=100
	#for i in 100:
		#player.backpack.add_item(await Wepoen.new().get_random_weapon())
	if _main_node:
		_main_node.add_child(player)
	# 触发初始化完成信号
	player_changed.emit()

# 添加队友
func add_team_member(member: BaseCultivation) -> void:
	if not team_members.has(member):
		team_members.append(member)
		team_members_changed.emit()

# 移除队友
func remove_team_member(member: BaseCultivation) -> void:
	if team_members.has(member):
		team_members.erase(member)
		team_members_changed.emit()

# 更新阵型
func set_formation_position(row: int, col: int, member: BaseCultivation) -> void:
	if row >= 0 and row < formation.size() and col >= 0 and col < formation[row].size():
		formation[row][col] = member
		formation_changed.emit()
