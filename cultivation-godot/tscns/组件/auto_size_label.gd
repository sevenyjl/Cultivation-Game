@tool
extends Label
class_name AutoSizeLabel

@export var min_font_size: int = 8  # 最小字体大小
@export var max_font_size: int = 32  # 最大字体大小

func _notification(what: int) -> void:
	if what==NOTIFICATION_EDITOR_POST_SAVE or what==NOTIFICATION_EDITOR_PRE_SAVE:
		adjust_font_size()

func _ready() -> void:
	adjust_font_size()
	# 在Godot 4.x中正确的信号连接语法
	connect("resized", adjust_font_size)
	# 也可以监听文本变化时调整字体大小
	connect("text_changed", adjust_font_size)

func adjust_font_size() -> void:
	# 二分查找最佳字体大小
	var low = min_font_size
	var high = max_font_size
	var best_size = low
	
	while low <= high:
		var mid = (low + high) / 2
		# 创建临时标签计算尺寸
		var test_label = Label.new()
		test_label.text = text
		test_label.add_theme_font_size_override("font_size", mid)
		
		# 获取文本所需最小尺寸
		var text_size = test_label.get_minimum_size()
		
		# 检查是否适合当前容器大小（Godot 4.x中使用size代替rect_size）
		if text_size.x <= size.x * 0.95 and text_size.y <= size.y * 0.95:
			best_size = mid
			low = mid + 1
		else:
			high = mid - 1
	
	# 应用找到的最佳字体大小
	add_theme_font_size_override("font_size", best_size)
