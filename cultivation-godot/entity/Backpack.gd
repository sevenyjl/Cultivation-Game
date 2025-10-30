class_name Backpack extends Node

@export var max_slots: int = 24  # 默认最大格子数量

# 细粒度信号
signal inventory_changed  # 背包整体变化时触发
signal item_added(item)   # 物品添加时触发
signal item_removed(item) # 物品移除时触发

var item_slots: Array = []

func remove_item(data):
	if item_slots.has(data):
		item_slots.erase(data)
		item_removed.emit(data)
		inventory_changed.emit()

func add_item(data) -> bool:
	if item_slots.size() >= max_slots:
		return false
	item_slots.append(data)
	if data.get_parent():
		data.reparent(self)
	else:
		add_child(data)
	item_added.emit(data)
	inventory_changed.emit()
	return true

# 添加获取物品列表的方法
func get_items() -> Array:
	return item_slots.duplicate()

# 检查是否包含特定物品
func has_item(data) -> bool:
	return item_slots.has(data)
