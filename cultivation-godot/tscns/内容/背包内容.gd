extends PanelContainer

# 背包属性
@export var max_slots: int = 24  # 默认最大格子数量
@export var slots_per_row: int = 8  # 每行显示的格子数量
var backpack:Backpack

# 资源引用
var slot_scene: PackedScene = preload("res://tscns/组件/装备带tips.tscn")
@onready var _item_grid: GridContainer=$ScrollContainer/ItemGrid

func 初始化(backpack:Backpack):
	self.backpack=backpack
	for i in self.backpack.size():
		var node=_item_grid.get_child(i)
		node.default_name=self.backpack.item_slots[i].name_str

func _ready() -> void:
	# 确保网格容器的列数与脚本中的设置一致
	_item_grid.columns = slots_per_row
	# 初始化格子
	_initialize_slots()


func _initialize_slots() -> void:
	# 清理现有格子（如果有）
	for slot in _item_grid.get_children():
		slot.queue_free()
	# 创建新的空格子
	for i in range(max_slots):
		var slot = slot_scene.instantiate()
		slot.name = "Slot_%d" % i
		slot.default_name = ""
		_item_grid.add_child(slot)
