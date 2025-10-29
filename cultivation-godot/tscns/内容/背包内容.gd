extends PanelContainer

# 背包属性
@export var slots_per_row: int = 8  # 每行显示的格子数量
var _backpack:Backpack

# 资源引用
@onready var _item_grid: GridContainer=$ScrollContainer/ItemGrid

func _process(delta: float) -> void:
	if _backpack:
		if _backpack.max_slots!=_item_grid.get_child_count():
			print("格子不一样了")
			await 初始化(_backpack)
	pass

func 初始化(backpack:Backpack):
	_backpack=backpack
	_backpack.添加物品信息号.connect(更新格子)
	_initialize_slots()
	await get_tree().process_frame
	# 创建新的空格子
	for i in range(_backpack.max_slots):
		_item_grid.add_child(ItemTips.get_ItemTips(null))
	更新格子()


func 更新格子():
	for i in _backpack.item_slots.size():
		var item=_backpack.item_slots[i]
		var itemTips=_item_grid.get_child(i) as ItemTips
		itemTips.添加item(item)

func _ready() -> void:
	# 确保网格容器的列数与脚本中的设置一致
	_item_grid.columns = slots_per_row
	# 初始化格子
	_initialize_slots()


func _initialize_slots() -> void:
	# 清理现有格子（如果有）
	for slot in _item_grid.get_children():
		slot.queue_free()
