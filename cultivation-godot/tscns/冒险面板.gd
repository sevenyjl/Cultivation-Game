extends PanelContainer

var _current_level: int = 0 # 当前层级
var _node_scene:= preload("res://tscns/组件/冒险路径节点.tscn")

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
	for i in path_nodes:
		hBoxContainer.add_child(i)
		# 连接节点选中信号
		i.connect("node_selected", _on_node_selected)

func _on_node_selected(selected_node) -> void:
	# 生成下一层节点
	_current_level += 1
	# 检查是否已经有下一层，如果有则不重复生成
	var layers_vbox = $"主容器/路径显示区域/路径择容器/层数"
	if layers_vbox.get_child_count() <= _current_level:
		# 创建新的层级
		var next_level_nodes = _create_path_node()
		var hBoxContainer:HBoxContainer = HBoxContainer.new()
		hBoxContainer.alignment = BoxContainer.ALIGNMENT_CENTER
		hBoxContainer.add_theme_constant_override("separation", 10)
		layers_vbox.add_child(hBoxContainer)
		for node in next_level_nodes:
			hBoxContainer.add_child(node)
			# 连接节点选中信号
			node.connect("node_selected", _on_node_selected)
		
	# 滚动到最底部显示最新层级
	# 获取滚动容器（假设"路径择容器"是ScrollContainer类型）
	var scroll_container = $"主容器/路径显示区域"
	if scroll_container and scroll_container.is_class("ScrollContainer"):
		# 使用call_deferred确保UI更新后再滚动
		await get_tree().process_frame
		scroll_container.set_deferred("scroll_vertical", scroll_container.get_v_scroll_bar().max_value)
