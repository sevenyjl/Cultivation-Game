extends Node
class_name Wepoen

@export var level: int = 1  # 修炼等级
@export var name_str:String="新手短剑"
@export var desc:String="新手短剑🗡️"
var atk:RandomValue

func _init() -> void:
	# 初始化 atk
	atk=RandomValue.new()
	atk.min_value=1
	atk.max_value=10
	atk.min_growth=0.1
	atk.max_growth=0.3
	atk.growth_factor=1.2
	add_child(atk)
	pass
