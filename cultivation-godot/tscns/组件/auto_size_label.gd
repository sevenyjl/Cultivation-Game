@tool
extends Label
class_name AutoSizeLabel

@export var min_font_size: int = 8  # 最小字体大小
@export var max_font_size: int = 32  # 最大字体大小
@export var padding_percentage: float = 0.9  # 预留边距百分比，0.9表示使用90%的空间
var _tempLabel

func _notification(what: int) -> void:
	if what == NOTIFICATION_EDITOR_POST_SAVE or what == NOTIFICATION_EDITOR_PRE_SAVE:
		adjust_font_size()

func _ready() -> void:
	adjust_font_size()
	# 监听大小变化信号
	connect("resized", adjust_font_size)

func adjust_font_size() -> void:
	# 安全检查：确保size有效且不为零
	if size.x <= 0 or size.y <= 0:
		return

	# 初始化临时标签
	if _tempLabel == null:
		_tempLabel = Label.new()
		_tempLabel.text = text
		_tempLabel.visible = false  # 隐藏临时标签
		add_child(_tempLabel)
	else:
		_tempLabel.text = text  # 更新文本
	
	# 二分查找最佳字体大小
	var low = min_font_size
	var high = max_font_size
	var best_size = low
	var best_ratio = 0.0
	var target_ratio = padding_percentage
	
	# 执行二分搜索
	while low <= high:
		var mid = int((low + high) / 2)
		# 设置临时标签的字体大小
		_tempLabel.add_theme_font_size_override("font_size", mid)
		# 获取文本尺寸
		var text_size = _tempLabel.get_minimum_size()
		# 计算比例（取宽高比例中的较大值）
		var width_ratio = text_size.x / size.x
		var height_ratio = text_size.y / size.y
		var current_ratio = max(width_ratio, height_ratio)
		# 调试信息
		# 如果当前比例小于等于目标比例，尝试更大的字体
		if current_ratio <= target_ratio:
			# 记录当前最佳值
			best_size = mid
			best_ratio = current_ratio
			low = mid + 1
		else:
			# 字体太大，尝试更小的
			high = mid - 1
	# 确保最佳大小在有效范围内
	best_size = clamp(best_size, min_font_size, max_font_size)
	# 应用最佳字体大小
	add_theme_font_size_override("font_size", best_size)
 	
