extends BaseTips

var show_操作:bool=true

func _process(delta: float) -> void:
	$"VBoxContainer/操作".visible=show_操作

func 初始化(wepoen:Wepoen):
	super.初始化(wepoen)
	# 赋值名称的value
	$"VBoxContainer/名称/Value".text="%s(%s)"%[self.data.name_str,self.data.weapon_quality]
	$"VBoxContainer/攻击力/Value".text="%s~%s"%[self.data.atk.min_value,self.data.atk.max_value]
	$"VBoxContainer/描述/Value".text=self.data.desc
