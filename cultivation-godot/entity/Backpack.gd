class_name Backpack extends Node

@export var max_slots: int = 24  # 默认最大格子数量

signal 添加物品信息号

var item_slots: Array = []

func 移除物品(data):
	item_slots.erase(data)
	
func 添加物品(data) -> bool:
	if item_slots.size() >= max_slots:
		return false
	item_slots.append(data)
	if data.get_parent():
		data.reparent(self)
	else:
		add_child(data)
	添加物品信息号.emit()
	return true
