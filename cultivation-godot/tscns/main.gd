extends Control
class_name MainNode

@onready var 修炼ui=$"修炼ui"
@onready var 战斗ui=$"战斗UI"

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
	# 设置main_node引用，这对于GameData访问UI组件很重要
	GameData.set_main_node(self)
	# 初始化游戏数据
	GameData.initialize_game()
	# 初始化UI
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

func _on_背包格子10_pressed() -> void:
	GameData.player.backpack.max_slots+=10
	pass # Replace with function body.


func _on_调试豆包ai接口_pressed() -> void:
	var doubao=DouBao.new()
	add_child(doubao)
	var re=await doubao.获取ai消息("你好",DouBao.基础AIRole)
	print(re)
	pass # Replace with function body.

#endregion


func _on_随机武器生成_pressed() -> void:
	var w=Wepoen.new()
	add_child(w)
	await w.get_random_weapon()
	# 打印武器相关信息
	print("\n=== 随机生成武器信息 ===")
	print("武器名称: ", w.name_str)
	print("武器描述: ", w.desc)
	print("武器类型: ", w.weapon_type)
	print("武器品质: ", w.weapon_quality)
	print("材料类型: ", w.material_type)
	print("武器等级: ", w.level)
	print("攻击力范围: ", w.atk.min_value, " - ", w.atk.max_value)
	print("攻击成长范围: ", w.atk.min_growth, " - ", w.atk.max_growth)
	print("=======================\n")
	pass


func _on_关闭调试_pressed() -> void:
	$"调试".hide()
	pass # Replace with function body.
