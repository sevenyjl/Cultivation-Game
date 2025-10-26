extends PanelContainer

func _ready() -> void:
	for i in %PlayerTeamList.get_children():
		i.queue_free()
	for i in %All.get_children():
		i.queue_free()
	print("ready")
	pass

func _阵容队伍拖拽结束(panelContainer:PanelContainer,位置索引:int=-1):
	for i in %PlayerTeamList.get_children().size():
		var node=%PlayerTeamList.get_children().get(i) as Node
		if node.get_global_rect().has_point(get_global_mouse_position()):
			_formation_改变(panelContainer._baseCultivation,i)
	panelContainer.回到原来位置(位置索引)
	pass

func _formation_改变(baseCultivation:BaseCultivation,index:int):
	for i in GameData.formation.size():
		for j in GameData.formation[i].size():
			if GameData.formation[i][j]==baseCultivation:
				GameData.formation[i][j]=null
	var row=index/3 as int
	var col=index%3
	var old_data=GameData.formation[row][col]
	if old_data!=null:
		old_data.是否在阵型中=false
	GameData.formation[row][col]=baseCultivation
	baseCultivation.是否在阵型中=true
	_更新阵容()

func _更新阵容():
	for hang in GameData.formation.size():
		for index in GameData.formation[hang].size():
			var node_index=hang*3+index
			var data = GameData.formation[hang][index] as BaseCultivation
			%PlayerTeamList.get_child(node_index).初始化(data)

func 初始化():
	for i in %PlayerTeamList.get_children():
		i.queue_free()
	for i in %All.get_children():
		i.queue_free()
		
	var node=preload("res://tscns/内容/阵容队伍.tscn").instantiate()
	node.初始化(GameData.player)
	node.结束拖拽.connect(_阵容队伍拖拽结束.bind(%All.get_child_count()))
	%All.add_child(node)
	# 加载人物
	for i in GameData.team_members:
		node=preload("res://tscns/内容/阵容队伍.tscn").instantiate()
		node.初始化(i)
		print(%All.get_child_count())
		node.结束拖拽.connect(_阵容队伍拖拽结束.bind(%All.get_child_count()))
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
