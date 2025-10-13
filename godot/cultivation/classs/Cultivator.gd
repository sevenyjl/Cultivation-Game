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

# 执行升级
func level_up() -> bool:
	if can_level_up():
		qi -= get_required_qi()
		level += 1
		return true
	return false
