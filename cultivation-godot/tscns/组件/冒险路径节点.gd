extends PanelContainer

var _data:BasePathNode
@onready var _label:Label=$VBoxContainer/Label
var _selected: bool = false

func _ready() -> void:
	pass

func _gui_input(event: InputEvent) -> void:
	# 处理鼠标点击事件
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and _data and _data.can_selected:
		_on_clicked()

func 初始化(basePathNode:BasePathNode) -> void:
	_data = basePathNode
	# 更新标签文本
	if _label and basePathNode.has_property("name_str"):
		_label.text = basePathNode.name_str
	# 应用节点的背景颜色
	_apply_node_color()

func _apply_node_color() -> void:
	if not _data:
		return
	
	# 创建样式框
	var stylebox = StyleBoxFlat.new()
	stylebox.set_border_width_all(2)
	stylebox.border_color = Color(0.0, 0.0, 0.0, 1.0)
	
	# 应用节点的背景颜色
	if _data["bg_color"]:
		stylebox.bg_color = _data.bg_color
	else:
		stylebox.bg_color = Color(0.8, 0.8, 0.8, 1.0) # 默认颜色
	
	# 如果是选中状态，添加选中效果
	if _selected:
		stylebox.border_color = Color(1.0, 1.0, 0.0, 1.0)
		stylebox.set_border_width_all(3)
	
	# 应用样式
	add_theme_stylebox_override("panel",stylebox)

func _on_clicked() -> void:
	if _data and _data.can_selected:
		# 设置选中状态
		_selected = true
		_apply_node_color()
		# 调用节点的click方法
		if _data.has_method("click"):
			_data.click()
		# 发出选中信号
		emit_signal("node_selected", self)

func set_selected(selected: bool) -> void:
	_selected = selected
	_apply_node_color()

# 定义选中信号
signal node_selected(node)
