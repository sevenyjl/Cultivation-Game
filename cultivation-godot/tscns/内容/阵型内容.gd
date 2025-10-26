extends PanelContainer

func _ready() -> void:
	for i in %PlayerTeamList.get_children():
		i.queue_free()
	for i in %All.get_children():
		i.queue_free()
	print("ready")
	pass


func 初始化():
	for i in %PlayerTeamList.get_children():
		i.queue_free()
	for i in %All.get_children():
		i.queue_free()
		
	var node=preload("res://tscns/内容/阵容队伍.tscn").instantiate()
	node.初始化(GameData.player)
	%All.add_child(node)
	# 加载人物
	for i in GameData.team_members:
		node=preload("res://tscns/内容/阵容队伍.tscn").instantiate()
		node.初始化(i)
		%All.add_child(node)
	# 初始化阵容
	for hang in GameData.formation.size():
		for index in GameData.formation[hang].size():
			var temp_tscn=preload("res://tscns/内容/阵容位置.tscn").instantiate()
			if GameData.formation[hang][index]==null:
				%PlayerTeamList.add_child(temp_tscn)
			else:
				var data = GameData.formation[hang][index] as BaseCultivation
				temp_tscn.初始化(data)
				%PlayerTeamList.add_child(temp_tscn)
			pass
			
	pass
