# scripts/cultivation/Cultivator.gd
class_name Cultivator
extends Resource

# 等级系统常量
const LEVEL_NAMES = ["", "炼气", "筑基", "金丹", "元婴", "化神", "炼虚", "合体", "大乘", "渡劫"]
const STAGES = {
	"炼气": {"min": 1, "max": 10},
	"筑基": {"min": 11, "max": 20},
	"金丹": {"min": 21, "max": 30},
	"元婴": {"min": 31, "max": 40},
	"化神": {"min": 41, "max": 50},
	"炼虚": {"min": 51, "max": 60},
	"合体": {"min": 61, "max": 70},
	"大乘": {"min": 71, "max": 80},
	"渡劫": {"min": 81, "max": 90}
}

# 姓氏列表
const SURNAMES = [
	"李", "王", "张", "刘", "陈", "杨", "赵", "黄", "周", "吴",
	"徐", "孙", "胡", "朱", "高", "林", "何", "郭", "马", "罗"
]

# 名字前缀列表
const NAME_PREFIXES = [
	"天", "玄", "云", "风", "雷", "火", "水", "土", "金", "木",
	"星", "月", "日", "辰", "宇", "宙", "乾", "坤", "青", "白"
]

# 名字后缀列表
const NAME_SUFFIXES = [
	"尘", "凡", "空", "虚", "无", "有", "道", "法", "术", "诀",
	"心", "意", "神", "魂", "魄", "灵", "精", "气", "元", "丹"
]

# 属性字段
@export var level: int = 1
@export var qi: float = 0.0
@export var name_info: String = ""

# 攻击力相关属性
@export var attack_base_min: float = 1.0
@export var attack_base_max: float = 5.0

# 生命值相关属性
@export var health_base: float = 100.0
@export var health_current: float = 100.0

# 生命值恢复速度相关属性
@export var health_restore_min: float = 5.0
@export var health_restore_max: float = 15.0

# 只读属性
var stage_name:
	get:
		return _get_stage_name()

# 获取当前境界名称
func _get_stage_name() -> String:
	for stage in STAGES:
		var range = STAGES[stage]
		if level >= range.min and level <= range.max:
			return stage
	return "未知"

# 设置修仙者名称
func set_name_info(new_name: String) -> void:
	name_info = new_name

# 获取修仙者名称
func get_name_info() -> String:
	if name_info == "":
		return "无名氏"
	return name_info

# 生成随机名称
func generate_random_name() -> String:
	var surname = SURNAMES[randi() % SURNAMES.size()]
	var prefix = NAME_PREFIXES[randi() % NAME_PREFIXES.size()]
	var suffix = NAME_SUFFIXES[randi() % NAME_SUFFIXES.size()]
	
	# 50%概率生成双字名
	if randf() > 0.5:
		return surname + prefix + suffix
	else:
		return surname + prefix

# 计算升级所需灵气
func get_required_qi() -> float:
	var k = floor((level - 1) / 10)
	return 50.0 * level * (level + 1) * (1 + 0.3 * k)

# 检查是否可以升级
func can_level_up() -> bool:
	return qi >= get_required_qi()

# 获取当前攻击范围
func get_attack_range() -> Dictionary:
	# 攻击力计算公式：
	# 最终攻击力 = 基础攻击力 × (1 + 等级加成) × 境界倍数
	
	# 1. 境界倍数计算
	# 每个境界增加50%的攻击力系数
	# 例：炼气(第0个境界) = 1.0，筑基(第1个境界) = 1.5，金丹(第2个境界) = 2.0
	var stage_multiplier = 1.0 + (STAGES.keys().find(stage_name) * 0.5)
	
	# 2. 等级加成计算
	# 每级提供20%的基础攻击加成
	# 例：1级 = 20%加成，2级 = 40%加成，3级 = 60%加成...
	var level_bonus = level * 0.2
	
	# 3. 计算最终的最小和最大攻击力范围
	# 将基础攻击力、等级加成和境界倍数相乘得到最终攻击力
	return {
		"min": attack_base_min * (1.0 + level_bonus) * stage_multiplier,
		"max": attack_base_max * (1.0 + level_bonus) * stage_multiplier
	}

# 获取最大生命值
func get_max_health() -> float:
	# 最大生命值计算公式：
	# 最大生命值 = 基础生命值 × (1 + 等级加成) × 境界倍数
	
	# 境界倍数计算，与攻击力相同
	var stage_multiplier = 1.0 + (STAGES.keys().find(stage_name) * 0.5)
	
	# 等级加成计算，每级提供50%的基础生命值加成
	# 例：1级 = 50%加成，2级 = 100%加成，3级 = 150%加成...
	var level_bonus = level * 0.5
	
	return health_base * (1.0 + level_bonus) * stage_multiplier

# 恢复生命值
func restore_health(amount: float) -> void:
	var max_health = get_max_health()
	health_current = min(health_current + amount, max_health)

# 受到伤害
func take_damage(amount: float) -> void:
	health_current = max(health_current - amount, 0.0)

# 检查是否存活
func is_alive() -> bool:
	return health_current > 0.0

# 获取当前恢复生命值范围
func get_health_restore_range() -> Dictionary:
	# 生命值恢复公式：
	# 恢复量 = 基础恢复量 × (1 + 等级加成) × 境界倍数
	
	# 境界倍数计算，与攻击力相同
	var stage_multiplier = 1.0 + (STAGES.keys().find(stage_name) * 0.5)
	
	# 等级加成计算，每级提供15%的基础恢复加成
	var level_bonus = level * 0.15
	
	return {
		"min": health_restore_min * (1.0 + level_bonus) * stage_multiplier,
		"max": health_restore_max * (1.0 + level_bonus) * stage_multiplier
	}

# 获取随机恢复生命值
func get_random_health_restore() -> float:
	var range = get_health_restore_range()
	return range.min + randf() * (range.max - range.min)

# 获取随机攻击力值
func get_random_attack() -> float:
	var range = get_attack_range()
	return range.min + randf() * (range.max - range.min)

# 执行升级
func level_up() -> bool:
	if can_level_up():
		qi -= get_required_qi()
		level += 1
		# 升级时基础攻击力增长公式：
		# 基础最小攻击力 = 当前基础最小攻击力 × 1.1（每级提升10%）
		# 基础最大攻击力 = 当前基础最大攻击力 × 1.15（每级提升15%）
		# 这样设计使得攻击范围随等级提升而逐渐扩大
		attack_base_min *= 1.1
		attack_base_max *= 1.15
		
		# 升级时基础生命值增长公式：
		# 基础生命值 = 当前基础生命值 × 1.25（每级提升25%）
		health_base *= 1.25
		
		# 升级时基础恢复速度增长公式：
		# 基础最小恢复速度 = 当前基础最小恢复速度 × 1.12（每级提升12%）
		# 基础最大恢复速度 = 当前基础最大恢复速度 × 1.18（每级提升18%）
		health_restore_min *= 1.12
		health_restore_max *= 1.18
		
		# 升级时恢复满生命值
		health_current = get_max_health()
		
		return true
	return false
