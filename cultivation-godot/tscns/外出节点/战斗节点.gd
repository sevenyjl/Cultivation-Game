extends PanelContainer

# 战斗节点属性
var is_boss_battle: bool = false  # 是否为BOSS战
var battle_level:int=1
# 难度系数 1-8 越高代表可能的敌人越多
@export_range(1,8,1) var difficulty_multiplier: int = 1 
var formation = \
[
	[null,null,null],
	[null,null,null],
	[null,null,null],
	[null,null,null],
]

func _ready() -> void:
	# 默认生成普通战斗
	pass

# 根据难度和等级生成战斗
func generate_battle(is_boss: bool) -> void:
	battle_level = min(1,randi_range(GameData.player.level-4,GameData.player.level+4))
	var battle_name = "%s%d" % ["BOSS战斗" if is_boss_battle else "普通战斗", battle_level]
	$VBoxContainer/Label.text=battle_name
	var 敌人数量=randi_range(1,difficulty_multiplier)
	if is_boss_battle:
		# 先生成boss
		var boss=_generate_boss()
		var array=_get_available_positions().pick_random()
		if array!=null:
			formation[array.y][array.x]=boss
			add_child(boss)
		敌人数量-=1
		pass
	else:
		pass
	# 生成普通敌人
	for i in range(敌人数量):
		var array=_get_available_positions().pick_random()
		if array!=null:
			var enemy=_create_enemy()
			formation[array.y][array.x]=enemy
			add_child(enemy)

	# 更新UI显示
	_update_ui_display()

# 生成BOSS
func _generate_boss() -> BaseCultivation:
	var boss:BaseCultivation = BaseCultivation.new()
	var lv=min(1,randi_range(battle_level,battle_level+2))
	boss.name_str = "%s级BOSS" % lv
	for i in lv:
		boss.level_up()
	return boss

# 创建普通敌人
func _create_enemy() -> BaseCultivation:
	var enemy = BaseCultivation.new()
	var lv=min(1,randi_range(battle_level-3,battle_level+1))
	enemy.name_str = "怪物"
	for i in lv:
		enemy.level_up()
	return enemy

# 获取可用位置
func _get_available_positions() -> Array[Vector2]:
	var positions:Array[Vector2] = []
	for y in range(formation.size()):
		for x in range(formation[y].size()):
			positions.append(Vector2(x, y))
	return positions

# 更新UI显示
func _update_ui_display() -> void:
	# 这里可以更新节点的标题或其他UI元素
	# 例如：如果有标题标签，可以设置标题为battle_name
	pass


func _on_选择_pressed() -> void:
	GameData.mainNode.进入战斗(formation)
	pass # Replace with function body.
