extends Object
class_name BasePathNode

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