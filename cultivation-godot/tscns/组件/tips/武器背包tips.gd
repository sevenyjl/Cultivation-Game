extends PanelContainer

var _data:Wepoen

func 初始化(wepoen:Wepoen):
	_data=wepoen
	# 赋值名称的value
	$"VBoxContainer/名称/Value".text="%s(%s)"%[_data.name_str,_data.weapon_quality]
	$"VBoxContainer/攻击力/Value".text="%s~%s"%[_data.atk.min_value,_data.atk.max_value]
	$"VBoxContainer/描述/Value".text=_data.desc
