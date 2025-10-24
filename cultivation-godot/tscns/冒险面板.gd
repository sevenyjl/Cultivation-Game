extends PanelContainer

var _current_level: int = 0 # 当前层级
var _node_scene:= preload("res://tscns/组件/冒险路径节点.tscn")
var _selected_indices: Dictionary = {} # 存储每层选中的节点索引

# 创建路径节点
func _create_path_node(has_blocked: bool = true) -> Array:
	var result:Array=[]
	# 随机生成路径节点类型
	for i in 5:
		var node = _node_scene.instantiate()
		var node_type = randi_range(0, 3 if has_blocked else 4)
		if node_type == 0:
			node.初始化(FightPathNode.new())
		elif node_type == 1:
			node.初始化(RestPathNode.new())
		elif node_type == 2:
			node.初始化(AdventurePathNode.new())
		elif node_type == 3:
			node.初始化(SecretAreaPathNode.new())
		else:
			node.初始化(BlockedPathNode.new())
		result.append(node)
	return result

func _ready() -> void:
	# 获取层级容器
	var layers_vbox = $"主容器/路径显示区域/路径择容器/层数"
	# 数据清理
	for i in layers_vbox.get_children():
		i.queue_free()
	# 初始化第一层路径
	_initialize_path_nodes()

func _initialize_path_nodes() -> void:
	# 初始化第一层路径节点
	var path_nodes = _create_path_node(false)
	var hBoxContainer:HBoxContainer =HBoxContainer.new()
	hBoxContainer.alignment=BoxContainer.ALIGNMENT_CENTER
	hBoxContainer.add_theme_constant_override("separation",10)
	var layers_vbox = $"主容器/路径显示区域/路径择容器/层数"
	layers_vbox.add_child(hBoxContainer)
	for i in range(path_nodes.size()):
		var node = path_nodes[i]
		hBoxContainer.add_child(node)
		# 存储节点索引信息
		node.set_meta("level_index", 0)
		node.set_meta("node_index", i)
		# 连接节点选中信号
		node.connect("node_selected", _on_node_selected)

func _on_node_selected(selected_node:AdventurePathNode) -> void:
	# 标记节点为已选择，禁用它
	selected_node.disable=true
	
	# 获取当前节点的层级和索引
	var current_level = selected_node.get_meta("level_index", 0)
	var node_index = selected_node.get_meta("node_index", 0)
	
	# 存储选中的索引
	_selected_indices[current_level] = node_index
	
	# 计算下一层的层级
	var next_level = current_level + 1
	
	# 检查是否已经有下一层，如果有则不重复生成
	var layers_vbox = $"主容器/路径显示区域/路径择容器/层数"
	if layers_vbox.get_child_count() <= next_level:
		# 创建新的层级
		var next_level_nodes = _create_path_node()
		var hBoxContainer:HBoxContainer = HBoxContainer.new()
		hBoxContainer.alignment = BoxContainer.ALIGNMENT_CENTER
		hBoxContainer.add_theme_constant_override("separation", 10)
		layers_vbox.add_child(hBoxContainer)
		
		# 添加下一层节点并设置可访问性
		for i in range(next_level_nodes.size()):
			var node = next_level_nodes[i]
			hBoxContainer.add_child(node)
			# 存储节点索引信息
			node.set_meta("level_index", next_level)
			node.set_meta("node_index", i)
			# 连接节点选中信号
			node.connect("node_selected", _on_node_selected)
			
		# 根据当前选中节点的索引，禁用下一层中不可选择的节点
		_update_next_level_accessibility(layers_vbox.get_child(next_level), node_index)
		
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
			node.disable=false  # 允许选择
		else:
			node.disable=true  # 禁用不可选择的节点
