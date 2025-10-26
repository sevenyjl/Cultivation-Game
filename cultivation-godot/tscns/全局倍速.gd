extends HBoxContainer

func _process(delta: float) -> void:
	if GameData:
		$SpinBox.value=GameData.全局倍速
		$HSlider.value=GameData.全局倍速
		
		$SpinBox.max_value=GameData.最大全局倍速
		$HSlider.max_value=GameData.最大全局倍速
	pass


	

func _on_spin_box_value_changed(value: float) -> void:
	GameData.全局倍速=value
	pass # Replace with function body.


func _on_h_slider_value_changed(value: float) -> void:
	GameData.全局倍速=value
	pass # Replace with function body.
