extends PanelContainer
var _baseCultivation:BaseCultivation
var _is_drag_over: bool = false

func _ready() -> void:
	# 启用鼠标进入和退出检测
	set_mouse_filter(MOUSE_FILTER_STOP)
	
func _process(delta: float) -> void:
	if _baseCultivation==null:
		return
	$Label.text=_baseCultivation.name_str
	pass

func 初始化(baseCultivation:BaseCultivation):
	_baseCultivation=baseCultivation
	$Label.text=_baseCultivation.name_str
	pass

func _on_gui_input(event: InputEvent) -> void:
	# 处理鼠标事件
	if event is InputEventMouseMotion:
		# 检查是否有拖拽操作正在进行
		if event.button_mask & MOUSE_BUTTON_LEFT:
			# 检查是否是从阵容队伍拖入的
			if self.get_global_rect().has_point(event.global_position):
				if !_is_drag_over:
					_is_drag_over = true
					# 可以在这里添加视觉反馈，比如改变边框颜色
			else:
				_is_drag_over = false
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed == false:
		# 鼠标左键释放，检查是否在容器内释放
		if self.get_global_rect().has_point(event.global_position) and _is_drag_over:
			print("拖入阵容了")
			# 重置拖拽状态
			_is_drag_over = false
		else:
			_is_drag_over = false
	
	# 处理触摸事件（手机拖拽）
	elif event is InputEventScreenDrag:
		if self.get_global_rect().has_point(event.global_position):
			if !_is_drag_over:
				_is_drag_over = true
		else:
			_is_drag_over = false
	elif event is InputEventScreenTouch and event.pressed == false:
		if self.get_global_rect().has_point(event.global_position) and _is_drag_over:
			print("拖入阵容了")
			_is_drag_over = false
	else:
		_is_drag_over = false
