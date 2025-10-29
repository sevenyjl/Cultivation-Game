extends PanelContainer
class_name BaseTips

@export var data=null

func 初始化(data):
	self.data=data
	pass

static func get_BaseTips(item)->BaseTips:
	if item is Wepoen:
		var result= preload("res://tscns/组件/tips/武器背包tips.tscn").instantiate() as BaseTips
		result.初始化(item)
		return result;
	var result=BaseTips.new()
	result.data=item
	return result
