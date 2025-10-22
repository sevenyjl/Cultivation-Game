extends PanelContainer

func 初始化() -> void:
	%"修炼".点击按钮.connect(func():
		_冷却完成(%"修炼",GameData.player.absorption_cooldown)
		var 灵气吸收量=GameData.player.absorption_rate.get_current_value()
		GameData.player.吸收灵气进入体内(灵气吸收量)
	)

func _冷却完成(comp:AutoClickButton,属性:GrowthBase):
	var 冷却时间 = 属性.get_current_value()
	print("冷却时间:",冷却时间)
	comp.冷却时间=冷却时间
