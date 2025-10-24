extends BasePathNode
class_name AdventurePathNode

# 奇遇事件类型
enum EVENT_TYPE {
	ITEM_FIND,     # 发现物品
	NPC_ENCOUNTER, # 遇到NPC
	MYSTERY_EVENT, # 神秘事件
	REWARD_CHEST,  # 奖励宝箱
	TRAP           # 陷阱
}

@export var 事件类型: EVENT_TYPE = EVENT_TYPE.MYSTERY_EVENT
@export var 事件描述: String = "这里发生了一些神秘的事情..."
@export var 奖励物品: Array = []
@export var 惩罚值: float = 0.0

func _init() -> void:
	id = "adventure_" + str(randi())
	name_str = "奇遇节点"
	bg_color = Color(0.9, 0.7, 0.2, 1.0)

func click() -> void:
	if can_selected:
		print("点击了奇遇节点：" + name_str)
		print("事件类型：" + EVENT_TYPE.keys()[事件类型] + "\n" + 事件描述)
