extends PanelContainer
var _baseCultivation:BaseCultivation

func 初始化(baseCultivation:BaseCultivation):
	_baseCultivation=baseCultivation
	$VBoxContainer/Label.text=baseCultivation.name_str
	pass
