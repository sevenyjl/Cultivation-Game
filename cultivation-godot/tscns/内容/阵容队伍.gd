extends PanelContainer
var _baseCultivation:BaseCultivation


func _ready() -> void:
	# 启用鼠标和触摸检测
	set_mouse_filter(MOUSE_FILTER_STOP)

func 初始化(baseCultivation:BaseCultivation):
	_baseCultivation=baseCultivation
	$VBoxContainer/Label.text=baseCultivation.name_str
	pass

func _process(delta: float) -> void:
	_drag_process()
	pass
	
#region 拖拽相关

var dragging = false
var drag_offset = Vector2.ZERO
var old_parent
signal 结束拖拽(panelContainer:PanelContainer)
func _drag_process():
	if dragging:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			global_position = get_global_mouse_position()+drag_offset
		else:
			_结束拖拽()

# 处理用户输入事件
func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:  # 按下左键
				if dragging:
					return
				old_parent=self.get_parent()
				reparent(get_tree().root)
				dragging = true
				# 记录拖拽时的偏移
				drag_offset = global_position - get_global_mouse_position()
			else:  # 松开左键
				_结束拖拽()

func 回到原来位置(index:int=-1):
	if old_parent:
		reparent(old_parent)
		if old_parent is Node:
			old_parent.move_child(self,index)

func _结束拖拽():
	结束拖拽.emit(self)
	dragging = false
#endregion
