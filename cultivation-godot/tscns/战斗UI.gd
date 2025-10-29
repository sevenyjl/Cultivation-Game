extends Control

# 定义战斗结束信号
signal 战斗结束(结果)

# 引用人员战斗信息组件场景
const CHARACTER_COMPONENT_SCENE = preload("uid://ch5ft504adcxv")

# 是所有队伍中的最小值
var 基础速度:float=0
var 倍速:float=1.0
# 存data，compoent
var character_component_map: Dictionary = {}
# 存速度队列label，componet
var label_character_component_map:Dictionary={}
# 战斗是否正在进行中
var _战斗进行中:bool = false
# 战斗日志配置
const MAX_BATTLE_LOG_LINES = 1000 # 最大战斗日志行数，超过将移除最早的日志

# 缓存唯一命名节点引用
@onready var SpeedSlider = %SpeedSlider
@onready var SpeedInput = %SpeedInput
@onready var SpeedResetButton = %SpeedResetButton
@onready var PlayerTeamList = %PlayerTeamList
@onready var EnemyTeamList = %EnemyTeamList
@onready var CharacterNamesContainer = %CharacterNamesContainer
@onready var BattleLogContent = %BattleLogContent

func _ready() -> void:
	# 初始化倍速控制UI组件
	# 使用缓存的节点引用
	SpeedSlider.value = 倍速
	SpeedInput.value = 倍速
	
	# 连接信号
	SpeedSlider.value_changed.connect(_on_speed_slider_changed)
	SpeedInput.value_changed.connect(_on_speed_input_changed)
	SpeedResetButton.pressed.connect(_on_speed_reset_pressed)
	
	# 初始化战斗日志
	BattleLogContent.bbcode_enabled = true
	BattleLogContent.text = "" # 初始为空，在初始化战斗时添加战斗开始日志

# 战斗方阵常量 - GridContainer 实现，一行3个，共4行
const ROWS = 4
const COLS = 3

func 初始化战斗(player_formation:Array, enemy_formation:Array):
	# 清空映射字典
	character_component_map.clear()
	label_character_component_map.clear()
	BattleLogContent.text = ""
	基础速度 = 0
	_战斗进行中 = true
	# 使用缓存的节点引用
	for i in PlayerTeamList.get_children():
		i.queue_free()
	for i in EnemyTeamList.get_children():
		i.queue_free()
	for i in %"掉落物品".get_children():
		i.queue_free()
	# 清空速度队列中的角色名称标签
	for i in CharacterNamesContainer.get_children():
		i.queue_free()
	
	# 创建玩家队伍组件（3x4方阵）
	_process_formation(player_formation, PlayerTeamList)
	
	# 创建敌人队伍组件（3x4方阵）
	_process_formation(enemy_formation, EnemyTeamList)
	
	# 初始化战斗日志
	添加战斗日志("战斗开始！")

func _process_formation(formation:Array, team_list:Control):
	# 处理方阵数据 - 确保每个GridContainer位置都有组件
	for row in range(ROWS):
		for col in range(COLS):
			# 检查是否有角色数据
			var has_character = false
			var character_data = null
			if row < formation.size() and col < formation[row].size():
				character_data = formation[row][col]
				has_character = character_data != null
			
			if has_character:
				# 创建角色组件并设置方阵位置信息
				var character_component = create_character_component(character_data, team_list)
				# 存储方阵位置信息
				character_component.set_meta("formation_pos", Vector2(col, row))
				character_component.set_meta("is_occupied", true)
			else:
				# 创建空白站位组件以保证GridContainer排版
				var empty_component = create_empty_component(team_list)
				empty_component.set_meta("formation_pos", Vector2(col, row))
				empty_component.set_meta("is_occupied", false)

func create_empty_component(team_list:Control) -> Control:
	# 创建空白占位组件
	var empty_component = Control.new()
	# 设置与角色组件相同的最小尺寸
	empty_component.custom_minimum_size = Vector2(120, 80)
	empty_component.size_flags_horizontal = SIZE_EXPAND_FILL
	empty_component.size_flags_vertical = SIZE_EXPAND_FILL
	
	# 添加到队伍列表
	team_list.add_child(empty_component)
	return empty_component
		
func _on_死亡_sinal(攻击者:BaseCultivation,死亡者:BaseCultivation):
	# 从速度队列中移除死亡者
	_移除速度队列(死亡者)
	# 检查战斗是否结束
	检查战斗结束()
	pass

func _信号移除(character_data:BaseCultivation):
	# 如果BaseCultivation有死亡信号，则解除连接
	if character_data.死亡.is_connected(_on_死亡_sinal.bind()):
		character_data.死亡.disconnect(_on_死亡_sinal.bind())

func create_character_component(character_data:BaseCultivation,team_list:Control):
	_信号移除(character_data)
	# 绑定死亡信号到处理函数
	character_data.死亡.connect(_on_死亡_sinal.bind())

	# 实例化人员战斗信息组件
	var character_component = CHARACTER_COMPONENT_SCENE.instantiate()
	# 设置组件数据
	character_component.初始化人员战斗信息(character_data)
	# 存储映射关系到字典
	character_component_map[character_data] = character_component
	# 添加到队伍列表
	print(character_component)
	team_list.add_child(character_component)
	初始化速度队列(character_component)
	return character_component
#region 攻击相关
func 开始攻击(character_data):
	# print("开始攻击")
	_是否处理速度队列=false
	# 获取对应的UI组件
	var attacker_component = character_component_map[character_data]
	# 随机获取一个敌人
	var enemies = _随机获取敌人(attacker_component)
	if enemies.size() > 0:
		var enemy_component = enemies[0]
		# 添加战斗日志
		var enemy_data = enemy_component.character_data
		添加战斗日志("[color=#FFFF00]" + character_data.name_str + " 攻击了 " + enemy_data.name_str + "[/color]")
		# 创建攻击动画
		创建攻击动画(attacker_component, enemy_component)
	else:
		# 如果没有敌人，等待0.5秒
		await get_tree().create_timer(0.5).timeout
		_是否处理速度队列=true
	# print("攻击结束")

func 伤害动画(attacker_component:Control, target_component:Control)->Tween:
	var tween = create_tween()
	# 获取攻击者和目标的人物数据
	var attacker_data = attacker_component.character_data
	var target_data = target_component.character_data
	var attack_power = attacker_data.获取攻击力()
	var defense_power = target_data.defense_stats.get_current_value()
	# 计算伤害值（攻击值 - 防御值）
	var damage = max(1, roundf((attack_power - defense_power) * 100) / 100)
	# 应用伤害到目标
	target_data.应用伤害(damage,attacker_data)
	# 计算目标的可见位置
	var end_pos = _get_visible_position(target_component)
	
	# 创建伤害Label节点
	var damage_label = Label.new()
	damage_label.text = str(damage)
	damage_label.add_theme_color_override("font_color", Color(1, 1, 0)) # 低伤害黄色
	damage_label.add_theme_font_size_override("font_size", 20)
	damage_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	damage_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	damage_label.size = Vector2(60, 30)
	# 添加到场景根节点
	add_child(damage_label)
	# 初始时隐藏伤害标签，等待攻击动画完成后再显示
	damage_label.modulate.a = 0.0
	damage_label.global_position = end_pos - Vector2(damage_label.size.x / 2, damage_label.size.y / 2)
	
	tween.tween_property(damage_label, "modulate:a", 1.0, 0.1 / 倍速).from(0.0)
	# 伤害标签向上浮动
	tween.tween_property(damage_label, "global_position", 
		damage_label.global_position - Vector2(0, 30), 0.6 / 倍速)
	# 最后淡出
	tween.tween_property(damage_label, "modulate:a", 0.0, 0.2 / 倍速)
	tween.finished.connect(func():
		if is_instance_valid(damage_label):
			damage_label.queue_free()
	)
	return tween

func 被攻击抖动动画(target_component:Control)->Tween:
	var tween = create_tween()
	tween.tween_property(target_component, "position", target_component.position + Vector2(5, 0), 0.05 / 倍速) # 右移
	tween.tween_property(target_component, "position", target_component.position - Vector2(5, 0), 0.05 / 倍速) # 左移
	tween.tween_property(target_component, "position", target_component.position + Vector2(0, 3), 0.05 / 倍速) # 上移
	tween.tween_property(target_component, "position", target_component.position - Vector2(0, 3), 0.05 / 倍速) # 下移
	tween.tween_property(target_component, "position", target_component.position, 0.05 / 倍速) # 恢复原位
	return tween

# 创建攻击动画
func 创建攻击动画(attacker_component:Control, target_component:Control):
	# 创建攻击Label节点
	var attack_tween = 攻击动画(attacker_component, target_component)
	attack_tween.finished.connect(func():
		var damage_tween = 伤害动画(attacker_component, target_component)
		var 被攻击抖动动画_tween = 被攻击抖动动画(target_component)
		await 被攻击抖动动画_tween.finished
		await damage_tween.finished
		_是否处理速度队列 = true
	)

func 攻击动画(attacker_component:Control, target_component:Control)->Tween:
	var tween = create_tween()
	# 创建攻击Label节点
	var attack_label = Label.new()
	attack_label.text = "攻击"
	attack_label.add_theme_color_override("font_color", Color.YELLOW)
	attack_label.add_theme_font_size_override("font_size", 20)
	attack_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	attack_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	attack_label.size = Vector2(60, 30)
	# 添加到场景根节点（确保能覆盖所有UI元素）
	add_child(attack_label)
	# 计算攻击者和目标的可见位置，考虑滚动容器的可视区域
	var start_pos = _get_visible_position(attacker_component)
	var end_pos = _get_visible_position(target_component)
	# 设置攻击标签的初始位置
	attack_label.global_position = start_pos - Vector2(attack_label.size.x / 2, attack_label.size.y / 2)
	# 攻击动画：移动效果 - 先执行移动，受倍速影响
	tween.tween_property(attack_label, "global_position", end_pos - Vector2(attack_label.size.x / 2, attack_label.size.y / 2), 0.5 / 倍速)
	# 创建淡出动画，受倍速影响
	tween.tween_property(attack_label, "modulate:a", 0.0, 0.2 / 倍速).from(1.0)
	tween.finished.connect(func ():
		if is_instance_valid(attack_label):
			attack_label.queue_free()
	)
	return tween

# 获取考虑滚动容器可视区域的组件位置
func _get_visible_position(component: Control) -> Vector2:
	# 获取组件的全局位置中心
	var component_global_pos = component.global_position
	var component_center = component_global_pos + Vector2(component.size.x / 2, component.size.y / 2)
	# 如果在可视区域内或没有滚动容器，返回组件的实际中心位置
	return component_center
#endregion

func _process(delta: float) -> void:
	_速度队列处理(delta)

#region 速度队列倍速
var _是否处理速度队列:bool = true

func 初始化速度队列(character_component):
	_是否处理速度队列=true
	# 从字典获取character_data
	var character_data =character_component.character_data
	# 创建角色名称标签
	var name_label = Label.new()
	name_label.text = character_data.name_str
	name_label.add_theme_color_override("font_color",  Color.RED)
	name_label.add_theme_font_size_override("font_size", 16)
	name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	# 使用字典存储name_label和character_component的映射
	label_character_component_map[name_label] = character_component
	var speed_stats=character_data.speed_stats as RandomValue
	var speed = speed_stats.get_current_value()
	if 基础速度 == 0:
		基础速度 = speed
	else:
		基础速度 = min(基础速度, speed)
	# 存储speed_data到字典
	name_label.set_meta("speed_data", speed)
	# 设置标签大小和位置
	name_label.size = Vector2(80, 30)
	name_label.position = Vector2(10, 15)
	# 使用缓存的节点引用
	CharacterNamesContainer.add_child(name_label)

func _移除速度队列(character_data:BaseCultivation):
	# 从速度队列中移除死亡者的名称标签
	for label in CharacterNamesContainer.get_children():
		if label.text == character_data.name_str:
			label.queue_free()
			break

func _速度队列处理(delta: float):
	if not _是否处理速度队列:
		return
	if _战斗进行中:
		检查战斗结束()
	if not _战斗进行中:
		return
	# 基础速度的运行时间是 5秒。就是从CharacterNamesContainer的左边开始，到右边的耗时5秒
	# 其他的速度就是基于这个基数计算，速度越快，耗时越短
	
	if CharacterNamesContainer.get_children().size() > 0 and 基础速度 > 0:
		
		# 获取容器的宽度作为移动总距离
		var container_width = CharacterNamesContainer.size.x
		
		# 遍历所有角色标签
		for i in CharacterNamesContainer.get_children():
			if i.has_meta("speed_data") and label_character_component_map.has(i):
				var speed = i.get_meta("speed_data")
				var character_component = label_character_component_map[i]
				var character_data = character_component.character_data
				
				# 计算该角色完成整个路程所需的时间（秒）
				# 基础速度需要5秒，其他速度根据比例计算
				var total_time = 5.0/倍速 * (基础速度 / speed)
				
				# 计算每秒移动的距离
				var distance_per_second = (container_width - i.size.x) / total_time
				
				# 根据delta时间更新位置
				i.position.x += distance_per_second * delta
				
				# 检查是否到达或超过终点
				if i.position.x >= container_width - i.size.x:
					# 触发攻击
					开始攻击(character_data)
					# 重置速度
					i.set_meta("speed_data", character_data.speed_stats.get_current_value())
					# 重置位置到左边起点
					i.position.x = CharacterNamesContainer.position.x


# 处理速度滑块变化
func _on_speed_slider_changed(value: float) -> void:
	倍速 = value
	# 同步更新输入框的值
	SpeedInput.value = value

# 处理速度输入框变化
func _on_speed_input_changed(value: float) -> void:
	倍速 = value
	# 同步更新滑块的值
	SpeedSlider.value = value

# 处理重置按钮点击
func _on_speed_reset_pressed() -> void:
	倍速 = 1.0
	SpeedSlider.value = 1.0
	SpeedInput.value = 1.0

#endregion

#region 战斗日志方法
func 添加战斗日志(text: String) -> void:
	# 追加新的战斗日志内容
	BattleLogContent.append_text("\n" + text)
	
	# 检查是否超过最大日志行数限制
	while BattleLogContent.get_line_count() > MAX_BATTLE_LOG_LINES:
		# 获取第一行文本的结束位置
		var first_line_end = BattleLogContent.get_line_offset(1)
		# 移除第一行（包括换行符）
		BattleLogContent.text = BattleLogContent.text.substr(first_line_end)
	
	# 自动滚动到底部，确保最新的日志可见
	BattleLogContent.scroll_to_line(BattleLogContent.get_line_count() - 1)

func 检查战斗结束():
	# 如果战斗已经结束，不再检查
	if not _战斗进行中:
		printerr("不应该没有结束呀")
		return
	
	# 检查玩家和敌人的存活情况
	var 玩家存活数 = 0
	var 敌人存活数 = 0
	
	# 统计玩家存活数
	for i in PlayerTeamList.get_children():
		if i.has_meta("is_occupied") and i.get_meta("is_occupied"):
			var player_data = i.character_data
			if player_data.hp_stats.get_current_value() > 0:
				玩家存活数 += 1
	
	# 统计敌人存活数
	for i in EnemyTeamList.get_children():
		if i.has_meta("is_occupied") and i.get_meta("is_occupied"):
			var enemy_data = i.character_data
			if enemy_data.hp_stats.get_current_value() > 0:
				敌人存活数 += 1
	
	# 判断战斗结果
	if 玩家存活数 == 0:
		# 玩家全灭，战斗失败
		_战斗结束("失败")
	elif 敌人存活数 == 0:
		# 敌人全灭，战斗胜利
		_战斗结束("胜利")

func _战斗结束(结果:String):
	# 标记战斗结束
	_战斗进行中 = false
	# 停止速度队列处理
	_是否处理速度队列 = false
	
	var 弹窗node=$PanelContainer.duplicate() as PanelContainer
	弹窗node.visible=true
	# 根据结果添加战斗日志
	if 结果 == "胜利":
		# todo 将所有敌人的物品给加入到 %"掉落物品" 中呈现，并加入到玩家背包中（调用Backpack的 添加物品 方法）
		for i in EnemyTeamList.get_children():
			if i.has_meta("is_occupied") and i.get_meta("is_occupied"):
				var player_data = i.character_data
				if player_data.wepoen:
					GameData.player.backpack.添加物品(player_data.wepoen)
					var itemTips=preload("uid://q4dsd2o5ecm7").instantiate() as ItemTips
					%"掉落物品".add_child(itemTips)
					await get_tree().process_frame
					itemTips.tips=itemTips.武器背包Tips
					itemTips.武器背包Tips.初始化(player_data.wepoen)
				
				for item in player_data.backpack.item_slots:
					GameData.player.backpack.添加物品(item)
					var itemTips=preload("uid://q4dsd2o5ecm7").instantiate() as ItemTips
					%"掉落物品".add_child(itemTips)
					await get_tree().process_frame
					if item is Wepoen:
						itemTips.tips=itemTips.武器背包Tips
						itemTips.武器背包Tips.初始化(player_data.wepoen)
			
			
		弹窗node.get_node("VBoxContainer/战斗胜利！").visible=true
		添加战斗日志("[color=#00FF00]战斗胜利！[/color]")
	else:
		弹窗node.get_node("VBoxContainer/战斗失败！").visible=true
		添加战斗日志("[color=#FF0000]战斗失败！[/color]")
	
	GameData.mainNode.打开弹窗(弹窗node)
	# 发射战斗结束信号
	战斗结束.emit(结果)

#endregion

#region 常用方法
func _是否为玩家队伍(character_component)->bool:
	return character_component.get_parent() == PlayerTeamList

func _是否为敌人队伍(character_component)->bool:
	return character_component.get_parent() == EnemyTeamList

func _随机获取敌人(character_component,number:int=1)->Array:
	var enemies = []
	if _是否为玩家队伍(character_component):
		for i in EnemyTeamList.get_children():
			# 只添加有角色占据且存活的组件
			if i.has_meta("is_occupied") and i.get_meta("is_occupied"):
				var enemy_data =i.character_data
				if enemy_data.hp_stats.get_current_value() > 0:
					enemies.append(i)
	else:
		for i in PlayerTeamList.get_children():
			# 只添加有角色占据且存活的组件
			if i.has_meta("is_occupied") and i.get_meta("is_occupied"):
				var enemy_data = i.character_data
				if enemy_data.hp_stats.get_current_value() > 0:
					enemies.append(i)
	enemies.shuffle()
	return enemies.slice(0, number)

func _随机获取友队(character_component,number:int=1)->Array:
	var players = []
	if _是否为玩家队伍(character_component):
		for i in PlayerTeamList.get_children():
			# 只添加有角色占据且存活的组件
			if i.has_meta("is_occupied") and i.get_meta("is_occupied"):
				var player_data = i.character_data
				if player_data.hp_stats.get_current_value() > 0:
					players.append(i)
	else:
		for i in EnemyTeamList.get_children():
			# 只添加有角色占据且存活的组件
			if i.has_meta("is_occupied") and i.get_meta("is_occupied"):
				var player_data = i.character_data
				if player_data.hp_stats.get_current_value() > 0:
					players.append(i)
	players.shuffle()
	return players.slice(0, number)
#endregion


func _on_关闭弹窗_pressed() -> void:
	GameData.mainNode.关闭弹窗()
	GameData.mainNode.结束战斗()
