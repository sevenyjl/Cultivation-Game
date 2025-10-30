extends PanelContainer

func _process(delta: float) -> void:
	if GameData.player:
		# 检查是否在战斗中（通过战斗UI的可见性）
		var is_in_battle = GameData.mainNode.战斗ui.visible
		# 获取所有按钮组件并设置disable状态
		for button in [%"修炼", %"突破", %"恢复"]:
			if button:
				# 战斗中禁用所有按钮
				button.disable = is_in_battle

func 初始化() -> void:
	%"修炼".点击按钮.connect(func():
		_冷却完成(%"修炼",GameData.player.absorption_cooldown)
		var 灵气吸收量=GameData.player.absorption_rate.get_current_value()
		GameData.player.absorb_spiritual_energy(灵气吸收量)
	)
	%"突破".点击按钮.connect(func():
		GameData.player.level_up()
	)
	%"恢复".点击按钮.connect(func():
		_冷却完成(%"恢复",GameData.player.health_regen_cooldown)
		var 生命恢复量=GameData.player.health_regen_rate.get_current_value()
		GameData.player.恢复生命(生命恢复量)
	)

func _冷却完成(comp:AutoClickButton,属性:GrowthBase):
	var 冷却时间 = 属性.get_current_value()
	comp.冷却时间=冷却时间
