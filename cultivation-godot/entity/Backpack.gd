class_name Backpack extends Node

@export var max_slots: int = 24  # 默认最大格子数量

var item_slots: Array[Wepoen] = []

func 添加物品(weapon: Wepoen) -> bool:
	if item_slots.size() >= max_slots:
		return false
	item_slots.append(weapon)
	return true
