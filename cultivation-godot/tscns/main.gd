extends Control
class_name MainNode

#region 外部方法
func 打开弹窗(node:PanelContainer):
	$"弹窗/Slot".add_child(node)
	$"弹窗".visible=true
	pass

func 关闭弹窗():
	for i in $"弹窗/Slot".get_children():
		i.queue_free()
	$"弹窗".visible=false
	pass

func 进入战斗(enemy_formation:Array):
	$"战斗UI".visible=true
	$"修炼ui".visible=false
	$"战斗UI".初始化战斗(GameData.formation, enemy_formation)
	pass
	
func 结束战斗():
	$"战斗UI".visible=false
	$"修炼ui".visible=true
	pass
#endregion

# 引用修仙者类
const BaseCultivation = preload("res://entity/Base修仙者.gd")

func _ready() -> void:
	GameData.游戏初始化()
	$"修炼ui".初始化()
	GameData.mainNode=self

	pass

# 创建玩家队伍（4x3方阵）
func create_player_formation() -> Array:
	# 初始化4x3的二维数组
	var formation = []
	for row in range(4):
		formation.append([])
		for col in range(3):
			formation[row].append(null)
	
	# 主玩家 - 修仙者（放置在方阵位置）
	var player = BaseCultivation.new()
	player.name_str = "张三"
	
	# 初始化并设置生命值
	for i in 3:
		player.level_up()
	
	formation[0][1] = player  # 第一排中间位置
	
	# 队友1 - 修仙者
	var teammate1 = BaseCultivation.new()
	teammate1.name_str = "李四"
	teammate1.level = 12  # 对应炼气期第2层
	
	formation[1][0] = teammate1  # 第二排左侧
	
	# 队友2 - 修仙者
	var teammate2 = BaseCultivation.new()
	teammate2.name_str = "王五"
	teammate2.level = 5  # 对应凡人第5层
	formation[1][2] = teammate2  # 第二排右侧
	
	return formation

# 创建敌人队伍（4x3方阵）
func create_enemy_formation() -> Array:
	# 初始化4x3的二维数组
	var formation = []
	for row in range(4):
		formation.append([])
		for col in range(3):
			formation[row].append(null)
	
	# 敌人1 - 野狼（妖兽）
	var wolf = BaseCultivation.new()
	wolf.name_str = "野狼"
	wolf.level = 3  # 对应凡人第3层
	formation[0][2] = wolf  # 第一排右侧位置
	
	# 敌人2 - 哥布林（魔物）
	var goblin = BaseCultivation.new()
	goblin.name_str = "哥布林"
	goblin.level = 2  # 对应凡人第2层
	
	formation[1][1] = goblin  # 第二排中间位置
	
	# 敌人3 - 暗影魔（隐藏Boss）
	var shadow_demon = BaseCultivation.new()
	shadow_demon.level = 22  # 对应筑基期第2层
	formation[2][1] = shadow_demon  # 第三排中间位置
	
	return formation
