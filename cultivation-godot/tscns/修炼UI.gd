extends Control
class_name MainNode

# 修炼UI控制器
# 负责管理修炼界面的显示和Tab切换功能

# Tab按钮节点引用
@onready var 修炼_button = $"VBoxContainer/HBoxContainer/主容器/VBoxContainer/Tab标签/修炼"

# Tab内容节点引用
@onready var cultivation_content = $VBoxContainer/HBoxContainer/主容器/VBoxContainer/Tab容器/修炼内容

# 修仙者信息组件引用
@onready var cultivator_info_component = $VBoxContainer/HBoxContainer/侧边栏/修仙者信息

# 当前选中的Tab
var current_tab: int = 0
# 信号
signal tab_changed(tab_index: int)

var _当前选择的玩家:BaseCultivation
func _ready():
	var tab_button=$"VBoxContainer/HBoxContainer/主容器/VBoxContainer/Tab标签".get_children()
	for i in tab_button.size():
		var button=tab_button[i] as Button
		button.pressed.connect(switch_tab.bind(i))
	# 初始化Tab显示
	switch_tab(0)
	GameData.mainNode=self

func _process(delta: float) -> void:
	if _当前选择的玩家:
		# 调用修仙者信息组件的更新方法
		cultivator_info_component.update_cultivator_info(_当前选择的玩家)
	pass

func _初始化玩家信息():
	_当前选择的玩家=GameData.player
	pass

func 初始化():
	_初始化玩家信息()
	$"VBoxContainer/HBoxContainer/主容器/VBoxContainer/Tab容器/修炼内容".初始化()
	pass

# 切换Tab
func switch_tab(tab_index: int):
	# 更新当前Tab
	current_tab = tab_index
	# 隐藏所有Tab内容
	var tab_contents=$VBoxContainer/HBoxContainer/主容器/VBoxContainer/Tab容器.get_children()
	for content in tab_contents:
		content.visible = false
	
	# 显示选中的Tab内容
	if tab_index >= 0 and tab_index < tab_contents.size():
		tab_contents[tab_index].visible = true
	# 发送信号
	tab_changed.emit(tab_index)

func 结束冒险():
	$VBoxContainer.visible=true
	$"冒险".visible=false
	pass

func _on_修炼内容_开始冒险() -> void:
	$VBoxContainer.visible=false
	$"冒险".visible=true
	pass # Replace with function body.
