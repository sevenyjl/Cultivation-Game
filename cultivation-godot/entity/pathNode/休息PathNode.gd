extends BasePathNode
class_name RestPathNode

# 恢复属性
@export var 恢复灵气: float = 0.0
@export var 恢复体力: float = 0.0
@export var 恢复生命: float = 0.0

func _init() -> void:
	id = "rest_" + str(randi())
	name_str = "休息节点"
	bg_color = Color(0.3, 0.8, 0.3, 1.0)

func click() -> void:
	if can_selected:
		print("点击了休息节点：" + name_str)
		print("恢复灵气：" + str(恢复灵气) + "\n恢复体力：" + str(恢复体力) + "\n恢复生命：" + str(恢复生命))
