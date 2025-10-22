extends PanelContainer
class_name AutoClickButton

@onready var 进度条背景=%"进度条背景"
@onready var checkBox:CheckBox= %CheckBox
@onready var 按钮:Button = %"Button"
@export var button_text:String="按钮名称"
@export var 冷却时间:float=0.1
# 冷却相关变量
var 当前冷却:float=0  # 当前剩余冷却时间（秒）

signal 点击按钮

# 预览效果
func _notification(what: int) -> void:
	if what==NOTIFICATION_EDITOR_POST_SAVE :
		按钮.text=button_text
	pass

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	# 更新冷却时间
	if 当前冷却 > 0:
		当前冷却 -= delta*GameData.全局倍速
		
		# 更新进度条
		if 当前冷却 > 0:
			# 计算剩余时间比例
			var 剩余比例 = 当前冷却 / 冷却时间
			
			# 为了实现从右到左的效果，我们需要调整大小
			# 当剩余比例减少时，进度条从右向左收缩
			进度条背景.size.x = 按钮.size.x * 剩余比例
			
			# 更新按钮文本
			按钮.text = button_text+" (%.1f秒)" % 当前冷却
		else:
			# 如果 checkBox 勾选了 则进行点击按钮
			if checkBox.is_pressed():
				_on_打坐修炼_pressed()
			else:
				重置按钮()

# 重置按钮状态
func 重置按钮() -> void:
	按钮.disabled = false
	进度条背景.visible=false
	按钮.text = button_text
	当前冷却 = 0

# 开始按钮冷却
func 开始冷却() -> void:
	当前冷却 = 冷却时间
	进度条背景.size = 按钮.size  # 重置进度条宽度为按钮宽度
	进度条背景.visible=true
	按钮.text = button_text+" (%.1f秒)" % 当前冷却

func _on_check_box_pressed() -> void:
	if 当前冷却>0:
		return
	开始冷却()
	pass # 暂时保留，等待用户的第二个功能要求

func _on_打坐修炼_pressed() -> void:
	if 当前冷却>0:
		return
	点击按钮.emit()
	开始冷却()
