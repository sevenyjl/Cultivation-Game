extends Control

# 战斗UI控制器
# 负责管理战斗界面的显示和更新

# 引用修仙者类
const Base修仙者 = preload("res://entity/Base修仙者.gd")

# 引用人员战斗信息组件场景
const CHARACTER_COMPONENT_SCENE = preload("uid://ch5ft504adcxv")

# 队伍列表节点引用
@onready var player_team_list = $MainContainer/TopContainer/PlayerTeamPanel/PlayerTeamContainer/PlayerTeamScrollContainer/PlayerTeamList
@onready var enemy_team_list = $MainContainer/TopContainer/EnemyTeamPanel/EnemyTeamContainer/EnemyTeamScrollContainer/EnemyTeamList

# 战斗日志节点引用
@onready var battle_log_content = $MainContainer/BattleLogPanel/BattleLogContainer/BattleLogContent

# 速度队列节点引用
@onready var character_names_container = $MainContainer/HBoxContainer/SpeedQueuePanel/SpeedQueueContainer/SpeedQueueBar/CharacterNamesContainer

# 战斗倍速控制节点引用
@onready var speed_slider = $MainContainer/HBoxContainer/BattleSpeedPanel/BattleSpeedContainer/BattleSpeedControls/SpeedSlider
@onready var speed_input = $MainContainer/HBoxContainer/BattleSpeedPanel/BattleSpeedContainer/HBoxContainer/SpeedInput
@onready var speed_reset_button = $MainContainer/HBoxContainer/BattleSpeedPanel/BattleSpeedContainer/HBoxContainer/SpeedResetButton

# 存储当前显示的人员组件
var player_components = []
var enemy_components = []

# 队伍数据
var player_team_data: Array = []
var enemy_team_data: Array = []

# 速度队列相关变量
var speed_queue_items: Array = []  # 存储速度队列中的角色
var speed_queue_timer: Timer
var base_update_interval: float = 0.167  # 基础更新间隔（约60FPS）
var min_update_interval: float = 0.033  # 最小更新间隔（约30FPS）

# 战斗状态
enum BattleState {
	PREPARING,    # 准备阶段
	PLAYER_TURN,  # 玩家回合
	ENEMY_TURN,   # 敌人回合
	BATTLE_END    # 战斗结束
}

var battle_state: BattleState = BattleState.PREPARING
var current_turn: int = 0  # 当前回合数
var battle_timer: Timer  # 战斗计时器

# 战斗配置
var battle_speed: float = 1.0  # 战斗速度倍率
var auto_battle: bool = false  # 是否自动战斗

# 信号
signal battle_started()
signal battle_ended(victory: bool)
signal turn_changed(turn_number: int)


func _ready():
	# 创建战斗计时器
	battle_timer = Timer.new()
	battle_timer.wait_time = 2.0  # 每回合2秒
	battle_timer.timeout.connect(_on_battle_timer_timeout)
	add_child(battle_timer)
	
	# 创建速度队列计时器
	speed_queue_timer = Timer.new()
	speed_queue_timer.wait_time = base_update_interval
	speed_queue_timer.timeout.connect(_on_speed_queue_timer_timeout)
	speed_queue_timer.autostart = true
	add_child(speed_queue_timer)
	
	# 初始化倍速控制
	initialize_battle_speed_controls()

func 初始化战斗(player_data:Array, enemy_data:Array):
	self.player_team_data = player_data
	self.enemy_team_data = enemy_data
	clear_team_components()
	
	# 创建玩家队伍组件
	for i in range(player_team_data.size()):
		create_character_component(player_team_data[i], player_team_list, player_components)
	
	# 创建敌人队伍组件
	for i in range(enemy_team_data.size()):
		create_character_component(enemy_team_data[i], enemy_team_list, enemy_components)
			
	initialize_battle_log()
	
	# 初始化速度队列
	initialize_speed_queue()
	
	# 开始战斗
	start_battle()

# 开始战斗
func start_battle():
	battle_state = BattleState.PREPARING
	current_turn = 0
	
	add_battle_log("战斗开始！", "white")
	battle_started.emit()
	
	# 显示初始队伍信息
	var player_count = count_alive_characters(player_team_data)
	var enemy_count = count_alive_characters(enemy_team_data)
	add_battle_log("初始队伍: 玩家 " + str(player_count) + " 人, 敌人 " + str(enemy_count) + " 人", "yellow")
	
	# 检查是否有存活的角色
	if not check_team_alive(player_team_data):
		add_battle_log("玩家队伍全部阵亡！", "red")
		end_battle(false)
		return
	
	if not check_team_alive(enemy_team_data):
		add_battle_log("敌人队伍全部阵亡！", "green")
		end_battle(true)
		return
	
	# 开始基于速度队列的战斗
	battle_state = BattleState.PLAYER_TURN

# 开始下一回合
func start_next_turn():
	current_turn += 1
	turn_changed.emit(current_turn)
	
	add_battle_log("=== 第 " + str(current_turn) + " 回合 ===", "yellow")
	
	# 检查战斗是否结束
	if not check_team_alive(player_team_data):
		add_battle_log("玩家队伍全部阵亡！", "red")
		end_battle(false)
		return
	
	if not check_team_alive(enemy_team_data):
		add_battle_log("敌人队伍全部阵亡！", "green")
		end_battle(true)
		return
	
	# 基于速度的战斗顺序
	execute_speed_based_turn()

# 基于速度的战斗回合
func execute_speed_based_turn():
	# 获取所有存活的角色
	var all_characters = []
	
	# 添加玩家队伍
	for i in range(player_team_data.size()):
		var character = player_team_data[i]
		var hp = 0
		if character.has_method("get"):
			hp = character.current_hp
		else:
			hp = character.get("hp", 0)
		
		if hp > 0:
			all_characters.append({
				"character": character,
				"is_player": true,
				"team_index": i
			})
	
	# 添加敌人队伍
	for i in range(enemy_team_data.size()):
		var character = enemy_team_data[i]
		var hp = 0
		if character.has_method("get"):
			hp = character.current_hp
		else:
			hp = character.get("hp", 0)
		
		if hp > 0:
			all_characters.append({
				"character": character,
				"is_player": false,
				"team_index": i
			})
	
	# 按速度排序（速度高的先行动）
	all_characters.sort_custom(func(a, b): return get_character_speed(a.character) > get_character_speed(b.character))
	
	# 显示存活角色统计
	var player_alive = 0
	var enemy_alive = 0
	for char_data in all_characters:
		if char_data.is_player:
			player_alive += 1
		else:
			enemy_alive += 1
	add_battle_log("存活角色: 玩家 " + str(player_alive) + " 人, 敌人 " + str(enemy_alive) + " 人", "yellow")
	
	# 显示行动顺序
	var speed_order = "行动顺序: "
	for i in range(all_characters.size()):
		var char_name = get_character_name(all_characters[i].character)
		var speed = get_character_speed(all_characters[i].character)
		speed_order += char_name + "(" + str(speed) + ")"
		if i < all_characters.size() - 1:
			speed_order += " -> "
	add_battle_log(speed_order, "cyan")
	
	# 依次执行行动
	execute_character_actions(all_characters, 0)

# 获取角色速度
func get_character_speed(character) -> int:
	if character.has_method("get"):
		# 使用get_speed()方法获取速度
		if character.has_method("get_speed"):
			return int(character.get_speed())
		else:
			# 兼容旧版
			return character.constitution if character.has_property("constitution") else 10
	else:
		return character.get("speed", 10)

# 获取角色名称
func get_character_name(character) -> String:
	if character.has_method("get"):
		return character.name_str
	else:
		return character.get("name", "未知")

# 依次执行角色行动
func execute_character_actions(characters: Array, current_index: int):
	if current_index >= characters.size():
		# 所有角色行动完毕，开始下一回合
		start_next_turn()
		return
	
	var char_data = characters[current_index]
	var character = char_data.character
	var is_player = char_data.is_player
	var _team_index = char_data.team_index
	
	# 检查角色是否还存活
	var hp = 0
	if character.has_method("get"):
		hp = character.get_current_hp()
	else:
		hp = character.get("hp", 0)
	
	if hp <= 0:
		# 角色已死亡，跳过
		execute_character_actions(characters, current_index + 1)
		return
	
	# 执行角色行动
	var target = find_target_for_character(character, is_player)
	if target != null:
		# 显示角色行动信息
		var attacker_name = get_character_name(character)
		var target_name = get_character_name(target)
		var team_type = "玩家" if is_player else "敌人"
		add_battle_log(team_type + " " + attacker_name + " 准备攻击 " + target_name, "white")
		execute_attack(character, target, is_player)
	else:
		# 没有可攻击的目标
		var attacker_name = get_character_name(character)
		var team_type = "玩家" if is_player else "敌人"
		add_battle_log(team_type + " " + attacker_name + " 没有找到可攻击的目标", "gray")
	
	# 使用帧跳过机制代替多次await
	# 在高速战斗时减少延迟
	var frames_to_wait = max(1, int(5.0 / battle_speed))  # 高速时减少等待的帧数
	
	# 使用调用树延迟调用下一角色，避免过多的await操作
	self.call_deferred("_execute_next_character", characters, current_index + 1, frames_to_wait)

# 用于_process中跟踪等待状态的变量
var _wait_frames_remaining = 0
var _pending_next_character = null
var _pending_next_index = -1

# 延迟执行下一角色 - 使用_process而非Timer
func _execute_next_character(characters: Array, next_index: int, frames_to_wait: int):
	if frames_to_wait <= 1:
		# 如果不需要等待或只需要等待一帧，直接执行下一角色
		execute_character_actions(characters, next_index)
	else:
		# 设置等待状态，在_process中处理
		_wait_frames_remaining = frames_to_wait
		_pending_next_character = characters
		_pending_next_index = next_index

# 在_process中处理帧等待逻辑
func _process(_delta):
	# 检查是否有待处理的角色行动等待
	if _wait_frames_remaining > 0:
		_wait_frames_remaining -= 1
		if _wait_frames_remaining <= 0:
			# 等待结束，执行下一角色
			if _pending_next_character != null and _pending_next_index >= 0:
				execute_character_actions(_pending_next_character, _pending_next_index)
			# 重置等待状态
			_pending_next_character = null
			_pending_next_index = -1

# 为角色寻找目标（随机选择）
func find_target_for_character(_attacker, is_player: bool):
	if is_player:
		# 玩家角色攻击敌人
		return get_random_alive_character(enemy_team_data)
	else:
		# 敌人角色攻击玩家
		return get_random_alive_character(player_team_data)

# 执行玩家回合
func execute_player_turn():
	if not check_team_alive(player_team_data):
		return
	
	# 找到第一个存活的玩家角色
	var alive_player = get_first_alive_character(player_team_data)
	if alive_player == null:
		return
	
	# 找到第一个存活的敌人作为目标
	var alive_enemy = get_first_alive_character(enemy_team_data)
	if alive_enemy == null:
		return
	
	# 执行攻击
	execute_attack(alive_player, alive_enemy, true)
	
	# 延迟后进入敌人回合
	await get_tree().create_timer(1.0 / battle_speed).timeout
	execute_enemy_turn()

# 执行敌人回合
func execute_enemy_turn():
	if not check_team_alive(enemy_team_data):
		return
	
	battle_state = BattleState.ENEMY_TURN
	add_battle_log("敌人回合", "red")
	
	# 找到第一个存活的敌人角色
	var alive_enemy = get_first_alive_character(enemy_team_data)
	if alive_enemy == null:
		return
	
	# 找到第一个存活的玩家作为目标
	var alive_player = get_first_alive_character(player_team_data)
	if alive_player == null:
		return
	
	# 执行攻击
	execute_attack(alive_enemy, alive_player, false)
	
	# 延迟后开始下一回合
	await get_tree().create_timer(1.0 / battle_speed).timeout
	start_next_turn()

# 执行攻击
func execute_attack(attacker, target, is_player_attack: bool):
	var attacker_name = get_character_name(attacker)
	var target_name = get_character_name(target)
	
	# 计算伤害
	var damage = calculate_damage(attacker, target)
	
	# 应用伤害
	if is_player_attack:
		# 玩家攻击敌人
		var enemy_index = find_character_index(enemy_team_data, target)
		if enemy_index != -1:
			var enemy = enemy_team_data[enemy_index]
			var new_hp = 0
			if enemy.has_method("get"):
				# 修仙者对象
				new_hp = max(0, enemy.get_current_hp() - damage)
				enemy.set_current_hp(new_hp)
			else:
				# 普通字典
				new_hp = max(0, enemy.get("hp", 0) - damage)
				enemy["hp"] = new_hp
			update_enemy_character_hp(enemy_index, new_hp)
	else:
		# 敌人攻击玩家
		var player_index = find_character_index(player_team_data, target)
		if player_index != -1:
			var player = player_team_data[player_index]
			var new_hp = 0
			if player.has_method("get"):
				# 修仙者对象
				new_hp = max(0, player.get_current_hp() - damage)
				player.set_current_hp(new_hp)
			else:
				# 普通字典
				new_hp = max(0, player.get("hp", 0) - damage)
				player["hp"] = new_hp
			update_player_character_hp(player_index, new_hp)
	
	# 记录战斗日志
	var color = "blue" if is_player_attack else "red"
	add_battle_log(attacker_name + " 对 " + target_name + " 造成了 " + str(damage) + " 点伤害！", color)
	
	# 检查目标是否死亡
	var target_hp = 0
	if target.has_method("get"):
		target_hp = target.get_current_hp()
	else:
		target_hp = target.get("hp", 0)
	
	if target_hp <= 0:
		var death_color = "green" if is_player_attack else "red"
		add_battle_log(target_name + " 已死亡！", death_color)
		
		# 从速度队列中移除死亡角色
		remove_dead_character_from_queue(target)

# 计算伤害
func calculate_damage(attacker, _target) -> int:
	# 基础伤害计算
	var base_damage = 10
	# 随机波动 ±20%
	var random_factor = randf_range(0.8, 1.2)
	return int(base_damage * random_factor)

# 检查队伍是否有存活成员
func check_team_alive(team_data: Array) -> bool:
	for character in team_data:
		var hp = 0
		if character.has_method("get"):
			# 修仙者对象
			hp = character.get_current_hp()
		else:
			# 普通字典
			hp = character.get("hp", 0)
		
		if hp > 0:
			return true
	return false

# 获取第一个存活的角色
func get_first_alive_character(team_data: Array):
	for character in team_data:
		var hp = 0
		if character.has_method("get"):
			# 修仙者对象
			hp = character.get_current_hp()
		else:
			# 普通字典
			hp = character.get("hp", 0)
		
		if hp > 0:
			return character
	return null

# 随机获取一个存活的角色
func get_random_alive_character(team_data: Array):
	var alive_characters = []
	
	for character in team_data:
		var hp = 0
		if character.has_method("get"):
			# 修仙者对象
			hp = character.get_current_hp()
		else:
			# 普通字典
			hp = character.get("hp", 0)
		
		if hp > 0:
			alive_characters.append(character)
	
	if alive_characters.is_empty():
		return null
	
	# 随机选择一个存活的角色
	var random_index = randi() % alive_characters.size()
	return alive_characters[random_index]

# 查找角色在队伍中的索引
func find_character_index(team_data: Array, target) -> int:
	for i in range(team_data.size()):
		if team_data[i] == target:
			return i
	return -1

# 结束战斗
func end_battle(victory: bool):
	battle_state = BattleState.BATTLE_END
	battle_timer.stop()
	
	if victory:
		add_battle_log("战斗胜利！", "green")
	else:
		add_battle_log("战斗失败！", "red")
	
	battle_ended.emit(victory)

# 战斗计时器超时
func _on_battle_timer_timeout():
	if battle_state == BattleState.PLAYER_TURN:
		execute_enemy_turn()
	elif battle_state == BattleState.ENEMY_TURN:
		start_next_turn()

# 设置战斗速度（已废弃，使用新的set_battle_speed函数）
func set_battle_speed_old(speed: float):
	battle_speed = speed
	battle_timer.wait_time = 2.0 / speed

# 切换自动战斗
func toggle_auto_battle():
	auto_battle = !auto_battle
	add_battle_log("自动战斗: " + ("开启" if auto_battle else "关闭"), "yellow")

# 暂停/恢复战斗
func pause_battle():
	if battle_state != BattleState.BATTLE_END:
		battle_timer.paused = true
		add_battle_log("战斗已暂停", "yellow")

func resume_battle():
	if battle_state != BattleState.BATTLE_END:
		battle_timer.paused = false
		add_battle_log("战斗已恢复", "yellow")

# 停止战斗
func stop_battle():
	battle_timer.stop()
	battle_state = BattleState.BATTLE_END
	add_battle_log("战斗已停止", "yellow")

# 获取战斗状态信息
func get_battle_status() -> String:
	var status = "=== 战斗状态 ===\n"
	status += "当前回合: " + str(current_turn) + "\n"
	status += "战斗状态: "
	
	match battle_state:
		BattleState.PREPARING:
			status += "准备中"
		BattleState.PLAYER_TURN:
			status += "玩家回合"
		BattleState.ENEMY_TURN:
			status += "敌人回合"
		BattleState.BATTLE_END:
			status += "战斗结束"
	
	status += "\n自动战斗: " + ("开启" if auto_battle else "关闭") + "\n"
	status += "战斗速度: " + str(battle_speed) + "x\n"
	
	# 队伍状态
	status += "\n玩家队伍存活: " + str(count_alive_characters(player_team_data)) + "/" + str(player_team_data.size()) + "\n"
	status += "敌人队伍存活: " + str(count_alive_characters(enemy_team_data)) + "/" + str(enemy_team_data.size())
	
	return status

# 计算存活角色数量
func count_alive_characters(team_data: Array) -> int:
	var count = 0
	for character in team_data:
		var hp = 0
		if character.has_method("get"):
			hp = character.get_current_hp()
		else:
			hp = character.get("hp", 0)
		
		if hp > 0:
			count += 1
	return count

# 使用技能攻击（扩展功能）
func use_skill_attack(attacker, target, skill_name: String, is_player_attack: bool):
	var attacker_name = attacker.name_str if attacker.has_method("get") else attacker.get("name", "未知")
	var _target_name = target.name_str if attacker.has_method("get") else target.get("name", "未知")
	
	# 检查技能是否存在
	var skill_found = false
	var skill_cost = 0
	var skill_damage = 0
	
	# 这里可以扩展技能系统
	if skill_name == "火球术":
		skill_cost = 10
		skill_damage = 25
		skill_found = true
	elif skill_name == "治疗术":
		skill_cost = 15
		skill_damage = -20  # 负值表示治疗
		skill_found = true
	
	if not skill_found:
		add_battle_log(attacker_name + " 尝试使用技能 " + skill_name + " 但失败了！", "red")
		return false
	
	# 注意：BaseCultivation类不再使用MP属性，此功能可能需要进一步调整
	# 暂时跳过MP检查，直接执行技能
	add_battle_log("技能系统已简化，跳过MP检查", "yellow")
	
	# 执行技能效果
	if skill_damage > 0:
		# 攻击技能
		execute_attack_with_damage(attacker, target, skill_damage, is_player_attack)
		add_battle_log(attacker_name + " 使用了 " + skill_name + "！", "blue")
	elif skill_damage < 0:
		# 治疗技能
		execute_heal(attacker, -skill_damage, is_player_attack)
		add_battle_log(attacker_name + " 使用了 " + skill_name + "！", "green")
	
	return true

# 执行带固定伤害的攻击
func execute_attack_with_damage(attacker, target, damage: int, is_player_attack: bool):
	var attacker_name = attacker.name_str if attacker.has_method("get") else attacker.get("name", "未知")
	var target_name = target.name_str if target.has_method("get") else target.get("name", "未知")
	
	# 应用伤害
	if is_player_attack:
		var enemy_index = find_character_index(enemy_team_data, target)
		if enemy_index != -1:
			var enemy = enemy_team_data[enemy_index] as Base修仙者
			var new_hp = max(0, enemy.get_current_hp() - damage)
			enemy.set_current_hp(new_hp)
			update_enemy_character_hp(enemy_index, new_hp)
	else:
		var player_index = find_character_index(player_team_data, target)
		if player_index != -1:
			var player = player_team_data[player_index] as Base修仙者
			var new_hp = max(0, player.get_current_hp() - damage)
			player.set_current_hp(new_hp)
			update_player_character_hp(player_index, new_hp)
	
	# 记录战斗日志
	var color = "blue" if is_player_attack else "red"
	add_battle_log(attacker_name + " 对 " + target_name + " 造成了 " + str(damage) + " 点技能伤害！", color)

# 执行治疗
func execute_heal(healer, heal_amount: int, is_player_heal: bool):
	var healer_name = ""
	if healer.has_method("get"):
		healer_name = healer.name_str
	else:
		healer_name = healer.get("name", "未知")
	
	if is_player_heal:
		# 治疗玩家队伍
		for i in range(player_team_data.size()):
			var hp = 0
			var max_hp = 0
			var character_name = ""
			
			if player_team_data[i].has_method("get"):
				hp = player_team_data[i].get_current_hp()
				max_hp = player_team_data[i].hp_stats.max_value
				character_name = player_team_data[i].name_str
			else:
				hp = player_team_data[i].get("hp", 0)
				max_hp = player_team_data[i].get("max_hp", 100)
				character_name = player_team_data[i].get("name", "未知")
			
			if hp > 0:
				var old_hp = hp
				var new_hp = min(max_hp, hp + heal_amount)
				
				if player_team_data[i].has_method("get"):
					player_team_data[i].set_current_hp(new_hp)
					update_player_character_hp(i, new_hp)
				else:
					player_team_data[i].hp = new_hp
					update_player_character_hp(i, new_hp)
				
				add_battle_log(healer_name + " 治疗了 " + character_name + " " + str(new_hp - old_hp) + " 点生命值！", "green")
				break
	else:
		# 治疗敌人队伍
		for i in range(enemy_team_data.size()):
			var hp = 0
			var max_hp = 0
			var character_name = ""
			
			if enemy_team_data[i].has_method("get"):
				hp = enemy_team_data[i].get_current_hp()
				max_hp = enemy_team_data[i].hp_stats.max_value
				character_name = enemy_team_data[i].name_str
			else:
				hp = enemy_team_data[i].get("hp", 0)
				max_hp = enemy_team_data[i].get("max_hp", 100)
				character_name = enemy_team_data[i].get("name", "未知")
			
			if hp > 0:
				var old_hp = hp
				var new_hp = min(max_hp, hp + heal_amount)
				
				if enemy_team_data[i].has_method("get"):
					enemy_team_data[i].set_current_hp(new_hp)
					update_enemy_character_hp(i, new_hp)
				else:
					enemy_team_data[i].hp = new_hp
					update_enemy_character_hp(i, new_hp)
				
				add_battle_log(healer_name + " 治疗了 " + character_name + " " + str(new_hp - old_hp) + " 点生命值！", "green")
				break

# 重置战斗
func reset_battle():
	stop_battle()
	battle_state = BattleState.PREPARING
	current_turn = 0
	add_battle_log("战斗已重置", "yellow")

# 创建人员战斗信息组件
func create_character_component(character_data, parent_container: VBoxContainer, components_array: Array):
	var component = CHARACTER_COMPONENT_SCENE.instantiate()
	parent_container.add_child(component)
	components_array.append(component)
	
	# 设置组件数据 - 支持修仙者对象和普通字典
	var character_name = ""
	var hp = 0
	var max_hp = 0
	
	if character_data.has_method("get"):
		# 修仙者对象
		character_name = character_data.name_str
		hp = character_data.get_current_hp()
		max_hp = character_data.hp_stats.max_value
	else:
		# 普通字典
		character_name = character_data.get("name", "未知")
		hp = character_data.get("hp", 0)
		max_hp = character_data.get("max_hp", 0)
	
	component.set_character_data(character_name, hp, max_hp)

# 清空队伍组件
func clear_team_components():
	# 清空玩家队伍组件
	for component in player_team_list.get_children():
		if is_instance_valid(component):
			component.queue_free()
	
	# 清空敌人队伍组件
	for component in enemy_team_list.get_children():
		if is_instance_valid(component):
			component.queue_free()

# 战斗日志配置
var MAX_LOG_ENTRIES = 100  # 最大日志条目数
var _log_entries = []  # 日志条目数组

# 初始化战斗日志
func initialize_battle_log():
	battle_log_content.text = ""
	_log_entries.clear()

# 添加战斗日志条目
func add_battle_log(message: String, color: String = "white"):
	var log_entry = "[color=" + color + "]" + message + "[/color]\n"
	
	# 添加到日志条目数组
	_log_entries.append(log_entry)
	
	# 限制日志条目数量
	if _log_entries.size() > MAX_LOG_ENTRIES:
		_log_entries = _log_entries.slice(-MAX_LOG_ENTRIES)
	
	# 更新日志内容
	update_battle_log_display()

# 更新战斗日志显示
func update_battle_log_display():
	# 一次性构建日志内容
	var log_text = ""
	for entry in _log_entries:
		log_text += entry
	
	# 批量更新日志文本
	battle_log_content.text = log_text
	
	# 滚动到底部
	# 不使用await避免额外的帧等待
	battle_log_content.scroll_to_line(battle_log_content.get_line_count() - 1)

# 更新玩家队伍中指定成员的生命值
func update_player_character_hp(character_index: int, current_hp: int, max_hp: int = -1):
	if character_index >= 0 and character_index < player_team_data.size():
		if player_team_data[character_index].has_method("get"):
			# 修仙者对象
			player_team_data[character_index].set_current_hp(current_hp)
			if max_hp != -1:
				player_team_data[character_index].hp_stats.max_value = max_hp
		else:
			# 普通字典
			player_team_data[character_index].hp = current_hp
			if max_hp != -1:
				player_team_data[character_index].max_hp = max_hp
		
		# 更新对应的UI组件
		if character_index < player_components.size() and is_instance_valid(player_components[character_index]):
			player_components[character_index].update_hp(current_hp, max_hp)

# 更新敌人队伍中指定成员的生命值
func update_enemy_character_hp(character_index: int, current_hp: int, max_hp: int = -1):
	if character_index >= 0 and character_index < enemy_team_data.size():
		if enemy_team_data[character_index].has_method("get"):
			# 修仙者对象
			enemy_team_data[character_index].set_current_hp(current_hp)
			if max_hp != -1:
				enemy_team_data[character_index].hp_stats.max_value = max_hp
		else:
			# 普通字典
			enemy_team_data[character_index].hp = current_hp
			if max_hp != -1:
				enemy_team_data[character_index].max_hp = max_hp
		
		# 更新对应的UI组件
		if character_index < enemy_components.size() and is_instance_valid(enemy_components[character_index]):
			enemy_components[character_index].update_hp(current_hp, max_hp)


# 刷新敌人队伍显示
func refresh_enemy_team():
	# 清空现有敌人组件
	for component in enemy_components:
		if is_instance_valid(component):
			component.queue_free()
	enemy_components.clear()
	
	for i in range(enemy_team_data.size()):
		create_character_component(enemy_team_data[i], enemy_team_list, enemy_components)

# 添加玩家队伍成员
func add_player_character(character_name: String, hp: int, max_hp: int):
	var new_character = {
		"name": character_name,
		"hp": hp,
		"max_hp": max_hp
	}
	player_team_data.append(new_character)
	create_character_component(new_character, player_team_list, player_components)

# 添加敌人队伍成员
func add_enemy_character(character_name: String, hp: int, max_hp: int, enemy_visible: bool = true):
	var new_character = {
		"name": character_name,
		"hp": hp,
		"max_hp": max_hp,
	}
	enemy_team_data.append(new_character)
	create_character_component(new_character, enemy_team_list, enemy_components)

# 移除玩家队伍成员
func remove_player_character(character_index: int):
	if character_index >= 0 and character_index < player_team_data.size():
		player_team_data.remove_at(character_index)
		# 重新初始化玩家队伍显示
		refresh_player_team()

# 移除敌人队伍成员
func remove_enemy_character(character_index: int):
	if character_index >= 0 and character_index < enemy_team_data.size():
		enemy_team_data.remove_at(character_index)
		# 重新初始化敌人队伍显示
		refresh_enemy_team()

# 刷新玩家队伍显示
func refresh_player_team():
	# 清空现有玩家组件
	for component in player_components:
		if is_instance_valid(component):
			component.queue_free()
	player_components.clear()
	
	# 重新创建玩家组件
	for i in range(player_team_data.size()):
		create_character_component(player_team_data[i], player_team_list, player_components)

# 获取玩家队伍数据
func get_player_team_data() -> Array:
	return player_team_data

# 获取敌人队伍数据
func get_enemy_team_data() -> Array:
	return enemy_team_data

# ==================== 速度队列相关函数 ====================

# 初始化速度队列
func initialize_speed_queue():
	# 清空现有队列
	clear_speed_queue()
	
	# 添加所有存活角色到速度队列
	for i in range(player_team_data.size()):
		var character = player_team_data[i]
		var hp = 0
		if character.has_method("get"):
			hp = character.get_current_hp()
		else:
			hp = character.get("hp", 0)
		
		if hp > 0:
			add_character_to_speed_queue(character, true, i)
	
	for i in range(enemy_team_data.size()):
		var character = enemy_team_data[i]
		var hp = 0
		if character.has_method("get"):
			hp = character.get_current_hp()
		else:
			hp = character.get("hp", 0)
		
		if hp > 0:
			add_character_to_speed_queue(character, false, i)

# 清空速度队列
func clear_speed_queue():
	# 清空队列数据
	speed_queue_items.clear()
	
	# 清空UI显示
	for child in character_names_container.get_children():
		child.queue_free()

# 添加角色到速度队列
func add_character_to_speed_queue(character, is_player: bool, team_index: int):
	var character_name = get_character_name(character)
	var speed = get_character_speed(character)
	
	# 创建角色名称标签
	var name_label = Label.new()
	name_label.text = character_name
	name_label.add_theme_color_override("font_color", Color.WHITE if is_player else Color.RED)
	name_label.add_theme_font_size_override("font_size", 16)
	name_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	# 设置标签大小和位置
	name_label.size = Vector2(80, 30)
	name_label.position = Vector2(10, 15)
	
	# 添加背景
	var background = ColorRect.new()
	background.color = Color(0.2, 0.2, 0.2, 0.8) if is_player else Color(0.4, 0.2, 0.2, 0.8)
	background.size = Vector2(80, 30)
	background.position = Vector2(10, 15)
	
	character_names_container.add_child(background)
	character_names_container.add_child(name_label)
	
	# 创建队列项数据
	var queue_item = {
		"character": character,
		"is_player": is_player,
		"team_index": team_index,
		"name_label": name_label,
		"background": background,
		"progress": 0.0,  # 进度 0-1
		"speed": speed,
		"ready": false    # 是否准备就绪
	}
	
	speed_queue_items.append(queue_item)

# 速度队列计时器回调
func _on_speed_queue_timer_timeout():
	update_speed_queue()

# 速度队列更新计数器
var _speed_queue_update_counter = 0

# 更新速度队列
func update_speed_queue():
	if battle_state == BattleState.BATTLE_END:
		return
	
	# 增加更新计数器
	_speed_queue_update_counter += 1
	
	var queue_width = character_names_container.size.x
	var finish_line_x = queue_width - 20  # 终点线位置
	var update_interval = speed_queue_timer.wait_time
	
	# 优化：在高速战斗时减少UI更新频率
	var should_update_ui = true
	if battle_speed > 3.0 and _speed_queue_update_counter % 2 != 0:
		should_update_ui = false
	elif battle_speed > 5.0 and _speed_queue_update_counter % 3 != 0:
		should_update_ui = false
	
	# 检查是否有角色准备就绪
	var has_new_ready_character = false
	var has_any_ready_character = false
	
	# 首先检查是否有已经准备就绪的角色
	for item in speed_queue_items:
		if item.ready:
			has_any_ready_character = true
			break
	
	# 更新角色进度
	for item in speed_queue_items:
		if item.ready:
			continue  # 已经准备就绪的角色跳过
		
		# 保存旧进度用于比较
		var old_progress = item.progress
		
		# 更新进度（基于速度和战斗倍速）
		var speed_factor = item.speed / 30.0  # 将速度标准化到0-1
		item.progress += speed_factor * update_interval * 0.5 * battle_speed
		
		# 限制进度在0-1之间
		item.progress = clamp(item.progress, 0.0, 1.0)
		
		# 检查是否到达终点
		if item.progress >= 1.0 and old_progress < 1.0:
			item.ready = true
			has_new_ready_character = true
			has_any_ready_character = true
			
			# 更新UI（无论是否应该更新UI，新准备就绪的角色必须更新）
			item.name_label.add_theme_color_override("font_color", Color.YELLOW)
			add_battle_log(get_character_name(item.character) + " 准备就绪！", "yellow")
	
	# 只有在需要时才更新UI位置
	if should_update_ui or has_new_ready_character:
		_update_queue_ui_positions(finish_line_x)
	
	# 重置计数器
	if _speed_queue_update_counter >= 100:
		_speed_queue_update_counter = 0
	
	# 修改：如果有任何准备就绪的角色，都检查执行行动
	if has_any_ready_character:
		execute_ready_character_action()

# 批量更新队列UI位置
func _update_queue_ui_positions(finish_line_x):
	for item in speed_queue_items:
		if item.ready:
			continue
		
		# 只有当进度足够明显时才更新位置
		var target_x = 10 + (finish_line_x - 10) * item.progress
		if abs(item.name_label.position.x - target_x) > 2.0:  # 更大的阈值减少UI更新
			item.name_label.position.x = target_x
			item.background.position.x = target_x

# 获取下一个可以行动的角色
func get_next_ready_character():
	for item in speed_queue_items:
		if item.ready:
			return item
	return null

# 重置角色到起点
func reset_character_in_queue(character):
	for item in speed_queue_items:
		if item.character == character:
			item.progress = 0.0
			item.ready = false
			item.name_label.position.x = 10
			item.background.position.x = 10
			# 恢复原始颜色
			var original_color = Color.WHITE if item.is_player else Color.RED
			item.name_label.add_theme_color_override("font_color", original_color)
			break

# 移除死亡角色
func remove_dead_character_from_queue(character):
	for i in range(speed_queue_items.size() - 1, -1, -1):
		var item = speed_queue_items[i]
		if item.character == character:
			item.name_label.queue_free()
			item.background.queue_free()
			speed_queue_items.remove_at(i)
			break

# 执行准备就绪角色的行动
func execute_ready_character_action():
	var ready_item = get_next_ready_character()
	if ready_item == null:
		return
	
	# 检查角色是否还存活
	var hp = 0
	if ready_item.character.has_method("get"):
		hp = ready_item.character.get_current_hp()
	else:
		hp = ready_item.character.get("hp", 0)
	
	if hp <= 0:
		# 角色已死亡，从队列中移除
		remove_dead_character_from_queue(ready_item.character)
		return
	
	# 执行攻击
	var target = find_target_for_character(ready_item.character, ready_item.is_player)
	if target != null:
		# 显示角色行动信息
		var attacker_name = get_character_name(ready_item.character)
		var target_name = get_character_name(target)
		var team_type = "玩家" if ready_item.is_player else "敌人"
		add_battle_log(team_type + " " + attacker_name + " 攻击 " + target_name, "white")
		
		# 执行攻击
		execute_attack(ready_item.character, target, ready_item.is_player)
		
		# 检查战斗是否结束
		if not check_team_alive(player_team_data):
			add_battle_log("玩家队伍全部阵亡！", "red")
			end_battle(false)
			return
		
		if not check_team_alive(enemy_team_data):
			add_battle_log("敌人队伍全部阵亡！", "green")
			end_battle(true)
			return
	else:
		# 没有可攻击的目标
		var attacker_name = get_character_name(ready_item.character)
		var team_type = "玩家" if ready_item.is_player else "敌人"
		add_battle_log(team_type + " " + attacker_name + " 没有找到可攻击的目标", "gray")
	
	# 关键修复：角色执行完行动后，必须重置其在队列中的状态
	# 这样角色才能重新开始积累进度并再次行动
	reset_character_in_queue(ready_item.character)

# 设置玩家队伍数据
func set_player_team_data(new_team_data: Array):
	player_team_data = new_team_data
	refresh_player_team()

# 设置敌人队伍数据
func set_enemy_team_data(new_team_data: Array):
	enemy_team_data = new_team_data
	refresh_enemy_team()

# ==================== 战斗倍速控制相关函数 ====================

# 初始化战斗倍速控制
func initialize_battle_speed_controls():
	# 连接信号
	speed_slider.value_changed.connect(_on_speed_slider_changed)
	speed_input.value_changed.connect(_on_speed_input_changed)
	speed_reset_button.pressed.connect(_on_speed_reset_pressed)
	
	# 设置初始值
	update_speed_display(battle_speed)

# 滑块值改变回调
func _on_speed_slider_changed(value: float):
	battle_speed = value
	speed_input.value = value
	apply_battle_speed()

# 输入框值改变回调
func _on_speed_input_changed(value: float):
	battle_speed = value
	speed_slider.value = value
	apply_battle_speed()

# 重置按钮回调
func _on_speed_reset_pressed():
	battle_speed = 1.0
	update_speed_display(battle_speed)
	apply_battle_speed()
	add_battle_log("战斗倍速已重置为 1.0x", "yellow")

# 更新速度显示
func update_speed_display(speed: float):
	speed_slider.value = speed
	speed_input.value = speed

# 应用战斗倍速
func apply_battle_speed():
	# 更新战斗计时器
	if battle_timer:
		battle_timer.wait_time = max(0.1, 2.0 / battle_speed)  # 限制最小等待时间
	
	# 根据战斗速度动态调整速度队列计时器间隔
	# 高速时降低更新频率以提高性能
	if speed_queue_timer:
		var target_interval = base_update_interval / battle_speed
		speed_queue_timer.wait_time = clamp(target_interval, min_update_interval, base_update_interval)
	
	add_battle_log("战斗倍速设置为 " + str(battle_speed) + "x", "cyan")

# 获取当前战斗倍速
func get_battle_speed() -> float:
	return battle_speed

# 设置战斗倍速（外部调用）
func set_battle_speed(speed: float):
	# 限制倍速范围
	speed = clamp(speed, 0.5, 10.0)
	
	# 确保是0.5的倍数
	speed = round(speed * 2.0) / 2.0
	
	battle_speed = speed
	update_speed_display(battle_speed)
	apply_battle_speed()
