# scripts/managers/GameManager.gd
class_name GameManager
extends Node

# 单例模式
static var instance: GameManager

# 游戏对象引用
@export var cultivator: Cultivator
@export var cultivation_location: CultivationLocation

# 游戏定时器
var game_timer: Timer
# 精确计时器，用于更频繁地更新灵气产生
var precise_timer: Timer
# 累计时间，用于跟踪秒数
var accumulated_time: float = 0.0

func _ready() -> void:
	instance = self
	
	# 初始化游戏对象
	if not cultivator:
		cultivator = Cultivator.new()
		cultivator.set_name(cultivator.generate_random_name())  # 设置随机名称
	if not cultivation_location:
		cultivation_location = CultivationLocation.new()
	
	# 设置游戏循环
	setup_game_loop()

func setup_game_loop() -> void:
	# 主游戏循环定时器（每秒触发一次）
	game_timer = Timer.new()
	add_child(game_timer)
	game_timer.wait_time = 1.0
	game_timer.connect("timeout", Callable(self, "_on_game_update"))
	game_timer.autostart = true
	
	# 精确更新定时器（每0.1秒触发一次）
	precise_timer = Timer.new()
	add_child(precise_timer)
	precise_timer.wait_time = 0.1
	precise_timer.connect("timeout", Callable(self, "_on_precise_update"))
	precise_timer.autostart = true
	
	# 手动启动定时器以确保它们正常工作
	game_timer.start()
	precise_timer.start()

func _on_precise_update() -> void:
	# 精确更新修炼地灵气产生（每0.1秒）
	cultivation_location.generate_qi(0.1)

func _on_game_update() -> void:
	# 累计时间
	accumulated_time += 1.0
	
	# 每秒更新游戏状态
	cultivation_location.generate_qi(0.0)  # 确保任何剩余的灵气都被计算
	
	# 检查修炼地升级
	if cultivation_location.can_upgrade():
		cultivation_location.upgrade()
	
	# 可以添加更多游戏逻辑更新...

# 吸收灵气
func absorb_qi(amount: float) -> void:
	var absorbed = min(amount, cultivation_location.current_qi)
	cultivation_location.current_qi -= absorbed
	cultivator.qi += absorbed

# 获取修炼者境界信息
func get_cultivator_info() -> Dictionary:
	return {
		"name": cultivator.get_name(),
		"level": cultivator.level,
		"stage": cultivator.stage_name,
		"current_qi": cultivator.qi,
		"required_qi": cultivator.get_required_qi()
	}
