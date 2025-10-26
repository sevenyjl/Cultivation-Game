extends PanelContainer
var _baseCultivation:BaseCultivation

func _ready() -> void:
	pass
	
func _process(delta: float) -> void:
	if _baseCultivation==null:
		return
	pass

func 初始化(baseCultivation:BaseCultivation):
	_baseCultivation=baseCultivation
	if baseCultivation==null:
		$Label.text="空"
	else:
		$Label.text=_baseCultivation.name_str
