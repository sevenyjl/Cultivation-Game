extends PanelContainer
var _baseCultivation:BaseCultivation

func _process(delta: float) -> void:
	if _baseCultivation==null:
		return
	$Label.text=_baseCultivation.name_str
	pass

func 初始化(baseCultivation:BaseCultivation):
	_baseCultivation=baseCultivation
	$Label.text=_baseCultivation.name_str
	pass
