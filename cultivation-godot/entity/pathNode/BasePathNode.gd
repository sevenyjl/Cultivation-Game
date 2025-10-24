extends Object
class_name BasePathNode

# 默认颜色
@export var bg_color: Color = Color(0.8, 0.8, 0.8, 1.0)

@export var id: String = ""
# 路径节点名称
@export var name_str: String = "未命名路径节点":
	get:
		return name_str
	set(value):
		name_str = value
# 是否可以被选中
@export var can_selected: bool = true

func click()->void:
	if can_selected:
		print("点击了路径节点：" + name_str)

func 随机属性赋值()->BasePathNode:
	return self
