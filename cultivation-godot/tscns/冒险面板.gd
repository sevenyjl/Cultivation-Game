extends PanelContainer

var _current_level: int = 0 # 当前层级
var _node_scene:= preload("res://tscns/组件/冒险路径节点.tscn")
var _selected_indices: Dictionary = {} # 存储每层选中的节点索引

func _process(delta: float) -> void:
	if GameData.player:
		$"主容器/左侧预留区域/修仙者信息".update_cultivator_info(GameData.player)

# 创建路径节点
func _create_path_node(has_blocked: bool = true) -> Array:
	var result:Array=[]
	# 创建节点数组
	for i in 5:
		result.append(_node_scene.instantiate())
	
	# 如果不需要阻塞节点，直接生成非阻塞节点
	if not has_blocked:
		for i in result.size():
			var node_type = randi_range(0, 3)
			if node_type == 0:
				result[i].初始化(FightPathNode.new())
			elif node_type == 1:
				result[i].初始化(RestPathNode.new())
			elif node_type == 2:
				result[i].初始化(EncounterPathNode.new())
			else:
				result[i].初始化(SecretAreaPathNode.new())
		return result
	
	# 核心改进：确保任何两个相邻节点不能同时为阻塞节点
	# 这样当玩家选择索引i时，i-1、i、i+1范围内至少有一个可通行节点
	var node_types = [0, 0, 0, 0, 0]  # 初始化5个节点类型
	
	# 首先为每个位置随机生成节点类型
	for i in 5:
		# 默认75%概率生成非阻塞节点
		if randi_range(0, 3) != 0:  # 3/4概率非阻塞
			node_types[i] = randi_range(0, 3)  # 生成非阻塞节点类型
		else:
			node_types[i] = 4  # 阻塞节点
	
	# 修正可能出现的问题：确保任意两个相邻节点不同时为阻塞
	for i in 5:
		# 检查边界情况
		if i == 0:
			# 第一个节点，如果和第二个同时为阻塞，随机修改其中一个
			if node_types[i] == 4 and node_types[i+1] == 4:
				node_types[i+1] = randi_range(0, 3)
		elif i == 4:
			# 最后一个节点，如果和前一个同时为阻塞，随机修改其中一个
			if node_types[i] == 4 and node_types[i-1] == 4:
				node_types[i-1] = randi_range(0, 3)
		else:
			# 中间节点，如果与前后都为阻塞，修改当前节点
			if node_types[i] == 4 and node_types[i-1] == 4 and node_types[i+1] == 4:
				node_types[i] = randi_range(0, 3)
	
	# 确保任何两个相邻节点不同时为阻塞
	for i in range(4):
		if node_types[i] == 4 and node_types[i+1] == 4:
			# 如果相邻两个都是阻塞，将后一个改为非阻塞
			node_types[i+1] = randi_range(0, 3)
	
	# 应用节点类型
	for i in 5:
		var node_type = node_types[i]
		if node_type == 0:
			result[i].初始化(FightPathNode.new())
		elif node_type == 1:
			result[i].初始化(RestPathNode.new())
		elif node_type == 2:
			result[i].初始化(EncounterPathNode.new())
		elif node_type == 3:
			result[i].初始化(SecretAreaPathNode.new())
		else:
			result[i].初始化(BlockedPathNode.new())
	
	return result

func _ready() -> void:
	# 获取层级容器
	var layers_vbox = $"主容器/路径显示区域/路径择容器/层数"
	# 数据清理
	for i in layers_vbox.get_children():
		i.queue_free()
	# 初始化第一层路径
	_initialize_path_nodes()

# 添加路径层级的通用方法
func _add_path_level(path_nodes: Array, level_index: int, initial_disable: bool = true) -> HBoxContainer:
	# 创建水平布局容器
	var hBoxContainer:HBoxContainer = HBoxContainer.new()
	hBoxContainer.alignment = BoxContainer.ALIGNMENT_CENTER
	hBoxContainer.add_theme_constant_override("separation", 10)
	
	# 获取层级容器并添加当前层级
	var layers_vbox = $"主容器/路径显示区域/路径择容器/层数"
	layers_vbox.add_child(hBoxContainer)
	
	# 添加节点并设置属性
	for i in range(path_nodes.size()):
		var node = path_nodes[i]
		hBoxContainer.add_child(node)
		# 存储节点索引信息
		node.set_meta("level_index", level_index)
		node.set_meta("node_index", i)
		# 连接节点选中信号
		node.connect("node_selected", _on_node_selected)
		# 设置初始禁用状态
		node.disable = initial_disable
	
	return hBoxContainer

func _initialize_path_nodes() -> void:
	# 初始化第一层路径节点
	var path_nodes = _create_path_node(false)
	# 添加第一层，初始不禁用节点
	_add_path_level(path_nodes, 0, false)

func _on_node_selected(selected_node:AdventurePathNode) -> void:
	if selected_node._data and selected_node._data._dilog:
		$"弹窗组件".打开弹窗(selected_node._data._dilog)
	if selected_node._data and selected_node._data is FightPathNode:
		# 进入战斗
		$"战斗UI".visible=true
		$"主容器".visible=false
		
		
	# 获取当前节点的层级和索引
	var current_level = selected_node.get_meta("level_index", 0)
	var node_index = selected_node.get_meta("node_index", 0)
	
	# 只有当前层级的节点可以选择，验证层级
	if current_level != _current_level:
		return
	
	# 存储选中的索引
	_selected_indices[current_level] = node_index
	
	# 禁用当前层级的所有节点，防止重复选择
	var layers_vbox = $"主容器/路径显示区域/路径择容器/层数"
	if current_level < layers_vbox.get_child_count():
		var current_level_container = layers_vbox.get_child(current_level)
		for node in current_level_container.get_children():
			node.disable = true
	
	# 计算下一层的层级
	var next_level = current_level + 1
	
	# 检查是否已经有下一层，如果有则不重复生成
	if layers_vbox.get_child_count() <= next_level:
		# 创建新的层级并使用通用方法添加
		var next_level_nodes = _create_path_node()
		var next_level_container = _add_path_level(next_level_nodes, next_level, true)
		
		# 根据当前选中节点的索引，设置下一层可达节点
		_update_next_level_accessibility(next_level_container, node_index)
		
	# 更新当前层级
	_current_level = next_level
	
	# 滚动到最底部显示最新层级
	# 获取滚动容器（假设"路径择容器"是ScrollContainer类型）
	var scroll_container = $"主容器/路径显示区域"
	if scroll_container and scroll_container.is_class("ScrollContainer"):
		# 使用call_deferred确保UI更新后再滚动
		await get_tree().process_frame
		scroll_container.set_deferred("scroll_vertical", scroll_container.get_v_scroll_bar().max_value)

func _update_next_level_accessibility(next_level_container, selected_index) -> void:
	# 计算下一层可选择的节点范围
	# 规则：选择索引为i的节点，下一层只能选择i-1、i、i+1（包含自身的相邻索引）
	var next_level_nodes = next_level_container.get_children()
	var max_index = next_level_nodes.size() - 1
	
	# 计算可选择的索引范围
	var min_available = max(0, selected_index - 1)  # 确保不小于0
	var max_available = min(max_index, selected_index + 1)  # 确保不大于最大索引
	
	# 设置节点的可访问性
	for i in range(next_level_nodes.size()):
		var node = next_level_nodes[i] as AdventurePathNode
		# 只有在允许范围内的节点才可以选择
		if i >= min_available and i <= max_available:
			node.disable = false  # 允许选择 - 这些是当前层级的可达节点
		else:
			node.disable = true  # 禁用不可选择的节点
