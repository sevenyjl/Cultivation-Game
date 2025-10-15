# scripts/locations/CultivationLocation.gd
class_name CultivationLocation
extends Resource

# 属性字段
@export var level: int = 1
@export var current_qi: float = 0.0
@export var overflow_exp: float = 0.0

# 计算属性
var max_qi_storage:
	get:
		return 100.0 * pow(1.5, level - 1)

var qi_generation_rate:
	get:
		# 修正计算方式，避免递归
		if level == 1:
			return 2.0*10
		else:
			# 根据公式 V(R) = V(R-1) × (1 + 0.3) + 2 递推计算
			var rate = 2.0
			for i in range(2, level + 1):
				rate = rate * 1.3 + 2.0
			return rate*10

# 获取升级所需经验
func get_required_exp() -> float:
	return 200.0 * level * (level + 1)

# 生产灵气
func generate_qi(delta_time: float = 1.0) -> void:
	var generated = qi_generation_rate * delta_time
	current_qi += generated
	
	# 处理溢出经验
	if current_qi > max_qi_storage:
		overflow_exp += current_qi - max_qi_storage
		current_qi = max_qi_storage

# 检查是否可以升级
func can_upgrade() -> bool:
	return overflow_exp >= get_required_exp()

# 执行升级
func upgrade() -> bool:
	if can_upgrade():
		overflow_exp -= get_required_exp()
		level += 1
		return true
	return false
