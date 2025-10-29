extends PanelContainer

func 重置选项():
	for i in $HBoxContainer.get_children():
		i.queue_free()
	for i in 3:
		var tscn=preload("res://tscns/外出节点/战斗节点.tscn").instantiate()
		$HBoxContainer.add_child(tscn)
		tscn.generate_battle(randi_range(0,1)==0)
	pass
