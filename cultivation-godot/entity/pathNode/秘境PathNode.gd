extends BasePathNode
class_name SecretAreaPathNode

# 秘境相关属性
@export var 秘境名称: String = "未知秘境"
@export var 秘境描述: String = "一个神秘的空间..."
@export var 秘境ID: String = ""
@export var 进入等级要求: int = 1

func _init() -> void:
	id = "secret_" + str(randi())
	name_str = "秘境节点"
	bg_color = Color(0.5, 0.3, 0.8, 1.0)

func click() -> void:
	if can_selected:
		print("点击了秘境节点：" + name_str)
		print("秘境名称：" + 秘境名称 + "\n" + 秘境描述)
		print("进入等级要求：" + str(进入等级要求))
