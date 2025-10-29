extends PanelContainer

# 背包属性
@export var slots_per_row: int = 8  # 每行显示的格子数量
var _backpack:Backpack = null

# 资源引用
@onready var _item_grid: GridContainer=$ScrollContainer/ItemGrid

func bind(backpack:Backpack) -> void:
	if _backpack == backpack:
		return
	
	# 先解绑现有数据
	unbind()
	
	_backpack = backpack
	if _backpack:
		# 连接信号
		if not _backpack.添加物品信息号.is_connected(_on_items_changed):
			_backpack.添加物品信息号.connect(_on_items_changed)
		
		# 初始化UI
		_render_backpack()

func unbind() -> void:
	if _backpack:
		# 断开信号连接
		if _backpack.添加物品信息号.is_connected(_on_items_changed):
			_backpack.添加物品信息号.disconnect(_on_items_changed)
		_backpack = null

func _on_items_changed() -> void:
	# 当物品变化时更新UI
	_update_items()

func _render_backpack() -> void:
	# 初始化格子
	_initialize_slots()
	
	# 创建新的空格子
	for i in range(_backpack.max_slots):
		_item_grid.add_child(ItemTips.get_ItemTips(null))
	
	# 首次渲染物品
	_update_items()

func _update_items():
	if not _backpack:
		return
	
	for i in _backpack.item_slots.size():
		var item=_backpack.item_slots[i]
		if i < _item_grid.get_child_count():
			var itemTips=_item_grid.get_child(i) as ItemTips
			itemTips.添加item(item)

func _ready() -> void:
	# 确保网格容器的列数与脚本中的设置一致
	_item_grid.columns = slots_per_row

func _exit_tree() -> void:
	# 清理资源，断开信号连接
	unbind()

func _initialize_slots() -> void:
	# 清理现有格子（如果有）
	for slot in _item_grid.get_children():
		slot.queue_free()
