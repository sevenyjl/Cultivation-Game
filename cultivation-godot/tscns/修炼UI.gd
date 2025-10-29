extends Control

# 修炼UI控制器
# 负责管理修炼界面的显示和Tab切换功能

# Tab按钮节点引用
@onready var 修炼_button = $"VBoxContainer/HBoxContainer/主容器/VBoxContainer/Tab标签/修炼"

# Tab内容节点引用
@onready var cultivation_content = $VBoxContainer/HBoxContainer/主容器/VBoxContainer/Tab容器/修炼内容

# 修仙者信息组件引用
@onready var cultivator_info_component = $VBoxContainer/HBoxContainer/侧边栏/修仙者信息

@onready var 外出内容=$"VBoxContainer/HBoxContainer/主容器/VBoxContainer/Tab容器/外出内容"

# 当前选中的Tab
var current_tab: int = 0
# 信号
signal tab_changed(tab_index: int)

var _当前选择的玩家:BaseCultivation
var _选中样式:StyleBox = preload("res://tscns/theme/Tab标签选择样式.tres")

func _ready():
	var tab_button=$"VBoxContainer/HBoxContainer/主容器/VBoxContainer/Tab标签".get_children()
	for i in tab_button.size():
		var button=tab_button[i] as Button
		button.pressed.connect(switch_tab.bind(i))
	# 初始化Tab显示
	switch_tab(0)

func _process(delta: float) -> void:
	pass

func _初始化玩家信息():
	_当前选择的玩家=GameData.player
	cultivator_info_component.初始化(_当前选择的玩家)
	pass

func 初始化():
	_初始化玩家信息()
	$"VBoxContainer/HBoxContainer/主容器/VBoxContainer/Tab容器/修炼内容".初始化()
	$"VBoxContainer/HBoxContainer/主容器/VBoxContainer/Tab容器/阵型内容".初始化()
	外出内容.重置选项()
	pass

# 切换Tab
func switch_tab(tab_index: int):
	var tab_button=$"VBoxContainer/HBoxContainer/主容器/VBoxContainer/Tab标签".get_children()
	var old_button=tab_button.get(current_tab) as Button
	old_button.remove_theme_stylebox_override("normal")
	old_button.remove_theme_stylebox_override("pressed")
	old_button.remove_theme_stylebox_override("hover")

	# 更新当前Tab索引并为新按钮设置选中样式
	current_tab=tab_index
	var new_button=(tab_button.get(tab_index) as Button)
	new_button.add_theme_stylebox_override("normal", _选中样式)
	new_button.add_theme_stylebox_override("pressed", _选中样式)
	new_button.add_theme_stylebox_override("hover", _选中样式)

	# 隐藏所有Tab内容
	var tab_contents=$VBoxContainer/HBoxContainer/主容器/VBoxContainer/Tab容器.get_children()
	for content in tab_contents:
		content.visible=false

	# 显示选中的Tab内容
	if tab_index>=0 and tab_index<tab_contents.size():
		tab_contents[tab_index].visible=true

	# 发送信号
	tab_changed.emit(tab_index)
