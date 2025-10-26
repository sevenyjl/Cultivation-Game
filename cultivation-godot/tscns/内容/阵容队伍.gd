extends PanelContainer
var _baseCultivation:BaseCultivation
var _is_dragging: bool = false

func _ready() -> void:
	# 启用鼠标和触摸检测
	set_mouse_filter(MOUSE_FILTER_STOP)

func 初始化(baseCultivation:BaseCultivation):
	_baseCultivation=baseCultivation
	$VBoxContainer/Label.text=baseCultivation.name_str
	pass

func _on_gui_input(event: InputEvent) -> void:
	# 处理鼠标拖拽
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed == true:
		# 检测鼠标按下在本控件内
		if self.get_global_rect().has_point(event.global_position):
			if !get_viewport().gui_is_dragging():  # 仅当没有其他拖拽操作时才允许开始拖拽
				_is_dragging = true
				# 开始拖拽操作
				set_drag_preview(self.duplicate())
