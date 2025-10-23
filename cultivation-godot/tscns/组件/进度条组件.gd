@tool
extends ProgressBar
class_name ProgressBarPro

var _AutoSizeLabel:AutoSizeLabel

# 导出属性
@export_enum("百分比","v/m格式") var display_mode: int = 0 # 0: 百分比显示, 1: current/max 格式显示

func _process(delta: float) -> void:
	_update_info()
	
func _update_info():
	if _AutoSizeLabel==null:
		_AutoSizeLabel=AutoSizeLabel.new()
		_AutoSizeLabel.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
		_AutoSizeLabel.vertical_alignment=VERTICAL_ALIGNMENT_CENTER
		add_child(_AutoSizeLabel)
	if display_mode==1:
		_AutoSizeLabel.visible=true
		self.show_percentage=false
	else:
		_AutoSizeLabel.visible=false
		self.show_percentage=true
	_AutoSizeLabel.size=self.size
	_AutoSizeLabel.text="%s/%s"%[value,max_value]
	add_theme_font_size_override("font_size",_AutoSizeLabel.get_theme_font_size("font_size"))

func _notification(what: int) -> void:
	if what==NOTIFICATION_EDITOR_POST_SAVE or what==NOTIFICATION_EDITOR_PRE_SAVE:
		_update_info()
