extends PanelContainer

# 背包属性
@export var slots_per_row: int = 5  # 每行显示的格子数量
var _backpack:Backpack = null

# 节流相关变量
var _dirty: bool = false
var _throttle_timer: Timer
var _throttle_interval: float = 0.1  # 10Hz更新频率

# 资源引用
@onready var _item_grid: GridContainer=$ScrollContainer/ItemGrid

func _ready() -> void:
	# 确保网格容器的列数与脚本中的设置一致
	_item_grid.columns = slots_per_row
	
	# 创建节流定时器
	_throttle_timer = Timer.new()
	_throttle_timer.wait_time = _throttle_interval
	_throttle_timer.connect("timeout", _throttled_update)
	add_child(_throttle_timer)

func bind(backpack:Backpack) -> void:
	if _backpack == backpack:
		return
	
	# 先解绑现有数据
	unbind()
	
	_backpack = backpack
	if _backpack:
		# 连接信号 - 使用新的细粒度信号
		_backpack.inventory_changed.connect(_on_items_changed)
		
		# 初始化UI
		_render_backpack()

func unbind() -> void:
	if _backpack:
		# 断开信号连接
		if _backpack.has_signal("inventory_changed"):
			_backpack.inventory_changed.disconnect(_on_items_changed)
		_backpack = null
	# 停止定时器
	if is_instance_valid(_throttle_timer):
		_throttle_timer.stop()

func _on_items_changed() -> void:
	# 当物品变化时设置脏标记
	_set_dirty()

# 设置脏标记并启动节流定时器
func _set_dirty() -> void:
	_dirty = true
	# 如果定时器没有运行，则启动它
	if is_instance_valid(_throttle_timer) and not _throttle_timer.is_processing():
		_throttle_timer.start()

# 节流后的更新方法
func _throttled_update() -> void:
	if _dirty:
		_update_items()
		_dirty = false
	if is_instance_valid(_throttle_timer):
		_throttle_timer.stop()

func _render_backpack() -> void:
	if not _backpack:
		return
	
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
	
	for i in range(_backpack.item_slots.size()):
		var item = _backpack.item_slots[i]
		if i < _item_grid.get_child_count():
			var itemTips = _item_grid.get_child(i) as ItemTips
			if itemTips:
				itemTips.添加item(item)

func _exit_tree() -> void:
	# 清理资源，断开信号连接
	unbind()

func _initialize_slots() -> void:
	# 清理现有格子（如果有）
	for slot in _item_grid.get_children():
		slot.queue_free()
