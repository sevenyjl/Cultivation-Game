# scripts/managers/combat/TurnManager.gd
class_name TurnManager
extends Node

# 回合相关属性
var combatants: Array = []  # 所有战斗者
var current_turn_index: int = 0  # 当前回合索引
var turn_order: Array = []  # 回合顺序
var turn_count: int = 0  # 回合计数

# 回合事件信号
signal turn_order_updated
signal turn_changed(actor, turn_number)

func _init():
	pass

# 初始化战斗者
func initialize_combatants(player, enemies: Array) -> void:
	combatants.clear()
	turn_order.clear()
	current_turn_index = 0
	turn_count = 0
	
	# 添加玩家
	if player:
		combatants.append(player)
	
	# 添加敌人
	for enemy in enemies:
		if enemy:
			combatants.append(enemy)
	
	# 计算回合顺序
	calculate_turn_order()

# 计算回合顺序（基于速度）
func calculate_turn_order() -> void:
	turn_order.clear()
	
	# 创建包含战斗者和其速度的数组
	var speed_list = []
	for combatant in combatants:
		if combatant and combatant.is_alive_in_battle():
			speed_list.append({
				"combatant": combatant,
				"speed": combatant.get_combat_speed(),
				"initiative": combatant.get_combat_speed() + randf() * 10.0  # 添加随机因素
			})
	
	# 按先攻值排序（从高到低）
	speed_list.sort_custom(func(a, b): return a.initiative > b.initiative)
	
	# 提取战斗者顺序
	for item in speed_list:
		turn_order.append(item.combatant)
	
	# 发出信号
	turn_order_updated.emit()

# 获取下一个行动者
func get_next_actor():
	if turn_order.is_empty():
		return null
	
	# 如果当前回合索引超出范围，重新计算回合顺序
	if current_turn_index >= turn_order.size():
		current_turn_index = 0
		turn_count += 1
		calculate_turn_order()
	
	# 获取当前行动者
	var current_actor = turn_order[current_turn_index]
	
	# 如果当前行动者已死亡，跳过到下一个
	while current_actor and not current_actor.is_alive_in_battle():
		current_turn_index += 1
		if current_turn_index >= turn_order.size():
			current_turn_index = 0
			turn_count += 1
			calculate_turn_order()
		
		if turn_order.is_empty():
			return null
		
		current_actor = turn_order[current_turn_index]
	
	# 移动到下一个行动者
	current_turn_index += 1
	
	# 发出信号
	turn_changed.emit(current_actor, turn_count)
	
	return current_actor

# 获取当前行动者
func get_current_actor():
	if turn_order.is_empty() or current_turn_index == 0:
		return null
	
	var index = current_turn_index - 1
	if index < 0 or index >= turn_order.size():
		return null
	
	return turn_order[index]

# 获取回合顺序
func get_turn_order() -> Array:
	return turn_order.duplicate()

# 获取当前回合数
func get_turn_count() -> int:
	return turn_count

# 获取当前回合索引
func get_current_turn_index() -> int:
	return current_turn_index

# 重置回合管理器
func reset() -> void:
	combatants.clear()
	turn_order.clear()
	current_turn_index = 0
	turn_count = 0

# 添加战斗者
func add_combatant(combatant) -> void:
	if combatant and not combatant in combatants:
		combatants.append(combatant)
		calculate_turn_order()

# 移除战斗者
func remove_combatant(combatant) -> void:
	if combatant in combatants:
		combatants.erase(combatant)
		calculate_turn_order()

# 检查是否所有战斗者都已行动
func all_combatants_acted() -> bool:
	return current_turn_index >= turn_order.size()

# 获取下一个回合的行动者列表
func get_next_turn_order() -> Array:
	var next_turn = []
	var temp_index = current_turn_index
	
	# 如果当前回合已结束，开始新回合
	if temp_index >= turn_order.size():
		temp_index = 0
	
	# 收集下一个回合的所有行动者
	for i in range(turn_order.size()):
		var index = (temp_index + i) % turn_order.size()
		var combatant = turn_order[index]
		if combatant and combatant.is_alive_in_battle():
			next_turn.append(combatant)
	
	return next_turn

# 获取回合信息
func get_turn_info() -> Dictionary:
	return {
		"turn_count": turn_count,
		"current_index": current_turn_index,
		"turn_order": turn_order.map(func(c): return c.get_name_info() if c else "未知"),
		"current_actor": get_current_actor().get_name_info() if get_current_actor() else "无",
		"next_actor": get_next_actor().get_name_info() if get_next_actor() else "无"
	}

# 强制设置当前行动者
func set_current_actor(combatant) -> void:
	if not combatant or not combatant in turn_order:
		return
	
	var index = turn_order.find(combatant)
	if index != -1:
		current_turn_index = index

# 跳过当前行动者
func skip_current_actor() -> void:
	if current_turn_index > 0:
		current_turn_index -= 1  # 回退到当前行动者
	get_next_actor()  # 移动到下一个

# 检查战斗者是否在当前回合中
func is_combatant_in_turn(combatant) -> bool:
	return combatant in turn_order

# 获取战斗者的回合位置
func get_combatant_turn_position(combatant) -> int:
	return turn_order.find(combatant)

# 重新排序回合（用于速度变化）
func recalculate_turn_order() -> void:
	calculate_turn_order()
