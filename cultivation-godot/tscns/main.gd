extends Control
class_name MainNode

@onready var 修炼ui=$"修炼ui"

#region 外部方法
func 打开弹窗(node:PanelContainer):
	$"弹窗/Slot".add_child(node)
	$"弹窗".visible=true
	pass

func 关闭弹窗():
	for i in $"弹窗/Slot".get_children():
		i.queue_free()
	$"弹窗".visible=false
	pass

func 进入战斗(enemy_formation:Array):
	$"战斗UI".visible=true
	$"修炼ui".visible=false
	$"战斗UI".初始化战斗(GameData.formation, enemy_formation)
	pass
	
func 结束战斗():
	$"战斗UI".visible=false
	$"修炼ui".visible=true
	修炼ui.外出内容.重置选项()
	pass
#endregion


func _ready() -> void:
	GameData.mainNode=self
	GameData.游戏初始化()
	$"修炼ui".初始化()
	pass

#region 调试相关
func _on_button_pressed() -> void:
	var list=get_orphan_node_ids()
	for id in list:
		var obj=instance_from_id(id)
		if obj:
			prints(obj, obj.owner, obj.get_script())
			if obj.get_script():
				print(obj.get_script().resource_path)
	pass # Replace with function body.
#endregion
