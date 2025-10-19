extends Control

# 引用人员战斗信息组件场景
const CHARACTER_COMPONENT_SCENE = preload("uid://ch5ft504adcxv")

# 是所有队伍中的最小值
var 基础速度:float=0
var 倍速:float=1.0
# 存储character_component和character_data的映射关系
var character_component_map: Dictionary = {}
var character_data_map: Dictionary = {}
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
	BattleLogContent.text = "战斗开始！"

# 战斗方阵常量 - GridContainer 实现，一行3个，共4行
const ROWS = 4
const COLS = 3

func 初始化战斗(player_formation:Array, enemy_formation:Array):
	# 清空映射字典
	character_component_map.clear()
	character_data_map.clear()
	基础速度 = 0
	# 使用缓存的节点引用
	for i in PlayerTeamList.get_children():
		i.queue_free()
	for i in EnemyTeamList.get_children():
		i.queue_free()
	# 清空速度队列中的角色名称标签
	for i in CharacterNamesContainer.get_children():
		i.queue_free()
	
	# 创建玩家队伍组件（3x4方阵）
	_process_formation(player_formation, PlayerTeamList)
	
	# 创建敌人队伍组件（3x4方阵）
	_process_formation(enemy_formation, EnemyTeamList)

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
		

func create_character_component(character_data:BaseCultivation,team_list:Control):
	# 实例化人员战斗信息组件
	var character_component = CHARACTER_COMPONENT_SCENE.instantiate()
	# 设置组件数据
	character_component.初始化人员战斗信息(character_data)
	# 存储映射关系到字典
	character_component_map[character_data] = character_component
	character_data_map[character_component] = character_data
	# 添加到队伍列表
	team_list.add_child(character_component)
	初始化速度队列(character_component)
	return character_component

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
		var enemy_data = character_data_map[enemy_component]
		添加战斗日志("[color=#FFFF00]" + character_data.name_str + " 攻击了 " + enemy_data.name_str + "[/color]")
		# 创建攻击动画
		创建攻击动画(attacker_component, enemy_component)
	else:
		# 如果没有敌人，等待0.5秒
		await get_tree().create_timer(0.5).timeout
		_是否处理速度队列=true
	# print("攻击结束")

#region 动画
# 创建攻击动画
func 创建攻击动画(attacker_component:Control, target_component:Control):
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
	
	# 创建Tween动画 - 攻击移动动画
	var tween = create_tween()
	
	# 攻击动画：移动效果 - 先执行移动，受倍速影响
	tween.tween_property(attack_label, "global_position", end_pos - Vector2(attack_label.size.x / 2, attack_label.size.y / 2), 0.5 / 倍速)
	
	# 移动完成后，触发回调函数执行并行的淡出和抖动动画
	tween.tween_callback(func():
		# 创建淡出动画，受倍速影响
		var fade_tween = create_tween()
		fade_tween.tween_property(attack_label, "modulate:a", 0.0, 0.2 / 倍速).from(1.0)
		
		# 创建抖动动画 - 与淡出并行执行，受倍速影响
		var shake_tween = create_tween()
		
		# 保存目标原始位置
		var original_position = target_component.position
		
		# 快速抖动效果：左右上下小幅度移动，受倍速影响
		shake_tween.tween_property(target_component, "position", original_position + Vector2(5, 0), 0.05 / 倍速) # 右移
		shake_tween.tween_property(target_component, "position", original_position + Vector2(-8, 0), 0.05 / 倍速) # 左移
		shake_tween.tween_property(target_component, "position", original_position + Vector2(5, 0), 0.05 / 倍速) # 右移
		shake_tween.tween_property(target_component, "position", original_position + Vector2(0, -3), 0.05 / 倍速) # 上移
		shake_tween.tween_property(target_component, "position", original_position + Vector2(0, 3), 0.05 / 倍速) # 下移
		shake_tween.tween_property(target_component, "position", original_position, 0.05 / 倍速) # 恢复原位
		
		# 监听淡出动画完成
		fade_tween.finished.connect(func():
			# 等待淡出动画完成后移除节点
			if is_instance_valid(attack_label):
				attack_label.queue_free()
			
			# 标记可以处理下一个动画
			_是否处理速度队列 = true
		)
	)

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
	# 从字典获取character_data
	var character_data = character_data_map[character_component]
	# 创建角色名称标签
	var name_label = Label.new()
	name_label.text = character_data.name_str
	name_label.add_theme_color_override("font_color",  Color.RED)
	name_label.add_theme_font_size_override("font_size", 16)
	name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	# 使用字典存储name_label和character_component的映射
	character_component_map[name_label] = character_component
	var speed = character_data.speed_stats.get_value()
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
func _速度队列处理(delta: float):
	if not _是否处理速度队列:
		return
	# 基础速度的运行时间是 5秒。就是从CharacterNamesContainer的左边开始，到右边的耗时5秒
	# 其他的速度就是基于这个基数计算，速度越快，耗时越短
	
	if CharacterNamesContainer.get_children().size() > 0 and 基础速度 > 0:
		
		# 获取容器的宽度作为移动总距离
		var container_width = CharacterNamesContainer.size.x
		
		# 遍历所有角色标签
		for i in CharacterNamesContainer.get_children():
			if i.has_meta("speed_data") and character_component_map.has(i):
				var speed = i.get_meta("speed_data")
				var character_component = character_component_map[i]
				var character_data = character_data_map[character_component]
				
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
					i.set_meta("speed_data", character_data.speed_stats.get_value())
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
			# 只添加有角色占据的组件
			if i.has_meta("is_occupied") and i.get_meta("is_occupied"):
				enemies.append(i)
	else:
		for i in PlayerTeamList.get_children():
			# 只添加有角色占据的组件
			if i.has_meta("is_occupied") and i.get_meta("is_occupied"):
				enemies.append(i)
	enemies.shuffle()
	return enemies.slice(0, number)

func _随机获取友队(character_component,number:int=1)->Array:
	var players = []
	if _是否为玩家队伍(character_component):
		for i in PlayerTeamList.get_children():
			# 只添加有角色占据的组件
			if i.has_meta("is_occupied") and i.get_meta("is_occupied"):
				players.append(i)
	else:
		for i in EnemyTeamList.get_children():
			# 只添加有角色占据的组件
			if i.has_meta("is_occupied") and i.get_meta("is_occupied"):
				players.append(i)
	players.shuffle()
	return players.slice(0, number)
#endregion
