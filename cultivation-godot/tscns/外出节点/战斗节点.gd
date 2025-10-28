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
	battle_level = max(1,randi_range(GameData.player.level-4,GameData.player.level+4))
	var battle_name = "%s%d" % ["BOSS战斗" if is_boss_battle else "普通战斗", battle_level]
	$VBoxContainer/Label.text=battle_name
	var 敌人数量=randi_range(1,difficulty_multiplier)
	if is_boss_battle:
		# 先生成boss
		var boss=_generate_boss()
		var array=_get_available_positions().pick_random()
		if array!=null:
			formation[array.y][array.x]=boss
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

	# 更新UI显示
	_update_ui_display()

# 生成BOSS
func _generate_boss() -> BaseCultivation:
	var boss:BaseCultivation = BaseCultivation.new()
	add_child(boss)
	var lv=max(1,randi_range(battle_level,battle_level+2))
	boss.name_str = "%s级BOSS" % lv
	for i in lv:
		boss.level_up()
	# 为BOSS生成并装备武器
	# 注意：由于get_random_weapon是异步的，这里使用同步调用（如果异步调用会导致战斗生成延迟）
	# 但为了确保武器数据正确，我们会在创建后立即调用生成武器的方法
	boss.wepoen.get_random_weapon()
	# 为BOSS武器设置更高的品质（50%概率获得高品质武器）
	if randi() % 2 == 0:
		boss.wepoen.weapon_quality = ["珍品", "灵品", "玄品"].pick_random()
	# 根据BOSS等级调整武器等级
	boss.wepoen.level = max(1, lv - randi_range(0, 2))
	# 重新应用武器数据以更新属性
	boss.wepoen._apply_weapon_data({"level": boss.wepoen.level, "weapon_quality": boss.wepoen.weapon_quality})
	return boss

# 创建普通敌人
func _create_enemy() -> BaseCultivation:
	var enemy = BaseCultivation.new()
	add_child(enemy)
	var lv=max(1,randi_range(battle_level-3,battle_level+1))
	enemy.name_str = "怪物"
	for i in lv:
		enemy.level_up()
	# 为普通敌人生成并装备武器
	enemy.wepoen.get_random_weapon()
	# 根据敌人等级调整武器等级
	enemy.wepoen.level = max(1, lv - randi_range(0, 3))
	# 重新应用武器数据以更新属性
	enemy.wepoen._apply_weapon_data({"level": enemy.wepoen.level, "weapon_quality": enemy.wepoen.weapon_quality})
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
