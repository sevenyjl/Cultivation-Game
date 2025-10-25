extends PanelContainer

var formation = \
[
	[null,null,null],
	[null,null,null],
	[null,null,null],
	[null,null,null],
]

func _ready() -> void:
	var base=BaseCultivation.new()
	base.name_str="怪物1"
	add_child(base)
	formation[0][0]=base
	pass

func _on_选择_pressed() -> void:
	GameData.mainNode.进入战斗(formation)
	pass # Replace with function body.
