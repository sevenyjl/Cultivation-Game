extends BasePathNode
class_name FightPathNode

# 战斗类型
enum FIGHT_TYPE {
	NORMAL, # 普通战斗
	BOSS    # Boss战斗
}

@export var 战斗类型: FIGHT_TYPE = FIGHT_TYPE.NORMAL
@export var 敌人等级: int = 1
@export var 敌人数量: int = 1
@export var 奖励经验: int = 10
@export var 奖励物品: Array = []

func _init() -> void:
	id = "fight_" + str(randi())
	name_str = "战斗节点"
	bg_color = Color(0.9, 0.3, 0.3, 1.0)

func click() -> void:
	if can_selected:
		var fight_type_text = "普通战斗"
		if 战斗类型 == FIGHT_TYPE.BOSS:
			fight_type_text = "Boss战斗"
		print("点击了战斗节点：" + name_str)
		print("战斗类型：" + fight_type_text)
		print("敌人等级：" + str(敌人等级) + "，敌人数量：" + str(敌人数量))
		print("奖励经验：" + str(奖励经验))
