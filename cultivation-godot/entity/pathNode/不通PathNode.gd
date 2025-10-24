extends BasePathNode
class_name BlockedPathNode

# 阻挡原因
@export var 阻挡原因: String = "前方道路被阻断..."

func _init() -> void:
	id = "blocked_" + str(randi())
	name_str = "不通节点"
	can_selected = false
	bg_color = Color(0.5, 0.5, 0.5, 0.5)

func click() -> void:
	if can_selected:
		print("点击了不通节点：" + name_str)
	else:
		print("无法通过：" + 阻挡原因)

func 随机属性赋值()->BasePathNode:
	return self
