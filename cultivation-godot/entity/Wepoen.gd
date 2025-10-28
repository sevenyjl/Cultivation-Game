extends Node
class_name Wepoen

@export var level: int = 1  # 修炼等级
@export var name_str:String="新手短剑"
@export var desc:String="新手短剑🗡️"

# 武器属性
@export var weapon_type:String = "剑"  # 武器类型(后缀)
@export var weapon_quality:String = "普通"  # 武器品质
@export var material_type:String = ""  # 材料类型(如精钢、玄铁等)
@export var feature_type:String = ""  # 特性描述(如短、长、重等)

var atk:RandomValue

func _init() -> void:
	# 初始化 atk
	atk=RandomValue.new()
	atk.min_value=1
	atk.max_value=10
	atk.min_growth=0.1
	atk.max_growth=0.3
	atk.growth_factor=1.2
	add_child(atk)
	pass

# 获取随机武器方法
static func get_random_weapon() -> Wepoen:
	var weapon = Wepoen.new()
	weapon._init()
	
	# 随机生成武器名称
	weapon._randomize_weapon_name()
	
	return weapon

# 随机生成武器名称的内部方法
func _randomize_weapon_name() -> void:
	# 材料类型
	var materials = ["", "精钢", "玄铁", "青铜", "白银", "黄金", "水晶", "琉璃", "翡翠", "钻石", "秘银", "灵木", "炎铜", "寒铁"]
	# 特性描述
	var features = ["", "短", "长", "大", "细", "重", "轻", "锋利", "坚固", "轻盈", "沉重", "精致", "粗糙", "华丽", "朴素"]
	# 武器类型后缀
	var weapon_types = ["剑", "刀", "枪", "棍", "斧", "锤", "叉", "戟", "镰", "鞭", "弓", "杖", "扇", "轮", "刺"]
	# 武器品质修饰词
	var qualities = ["凡品", "精品", "上品", "珍品", "灵品", "玄品", "地品", "天品"]
	# 武器描述模板
	var desc_templates = {
		"凡品": ["平凡无奇的武器，适合初学者使用。", "普通材料打造，随处可见。", "品质一般，但还算实用。"],
		"精品": ["做工精细的武器，比普通货色强上不少。", "选用上等材料打造，手感舒适。", "匠人精心打造的良品，有一定威名。"],
		"上品": ["上品武器，蕴含微弱灵气。", "使用特殊工艺锻造，锋利无比。", "在修真界小有名气的好剑。"],
		"珍品": ["珍稀武器，灵气盎然，持有者实力倍增。", "经过名师淬炼，品质卓越。", "修真者们梦寐以求的珍品。"],
		"灵品": ["灵性十足的武器，可与主人产生共鸣。", "蕴含强大灵力，非一般修士所能驾驭。", "传说中的灵兵，得之可斩妖除魔。"],
		"玄品": ["玄妙非凡的宝器，拥有不可思议的力量。", "上古技艺锻造，蕴含天地法则。", "玄器出世，风云变色，可断金石。"],
		"地品": ["地阶法宝，威力无边，可移山填海。", "采天地灵气，吸日月精华所铸。", "地品灵物，出世必引无数修士争夺。"],
		"天品": ["天阶圣物，只应天上有，人间难得一见。", "蕴含天道之力，可毁天灭地。", "传说中的神器，得之可纵横天下。"]
	}
	
	# 随机选择武器属性
	weapon_quality = qualities[randi() % qualities.size()]
	material_type = materials[randi() % materials.size()]
	feature_type = features[randi() % features.size()]
	weapon_type = weapon_types[randi() % weapon_types.size()]
	
	# 构建武器名称
	var weapon_name = ""
	
	# 添加品质修饰词（除了普通品质外）
	if weapon_quality != "普通":
		weapon_name += weapon_quality
	
	# 添加材料前缀（如果有）
	if material_type != "":
		weapon_name += material_type
	
	# 添加特性描述（如果有）
	if feature_type != "":
		weapon_name += feature_type
	
	# 添加武器类型
	weapon_name += weapon_type
	
	# 随机调整等级
	level = randi() % 5 + 1  # 随机等级1-5
	if level > 1:
		weapon_name += "(" + str(level) + "级)"
	
	# 更新名称和描述
	name_str = weapon_name
	
	# 根据武器品质和类型生成描述
	var quality_templates = desc_templates.get(weapon_quality, ["这是一件神秘的武器。"])
	var base_desc = quality_templates[randi() % quality_templates.size()]
	
	# 添加武器特性描述（如果有）
	var feature_desc = ""
	if feature_type != "":
		if feature_type == "短":
			feature_desc = "短小精悍，便于携带。"
		elif feature_type == "长":
			feature_desc = "长可及远，威力无穷。"
		elif feature_type == "重":
			feature_desc = "沉重无比，非大力士不能挥动。"
		elif feature_type == "锋利":
			feature_desc = "削铁如泥，吹毛断发。"
		elif feature_type == "坚固":
			feature_desc = "坚固耐用，永不磨损。"
		elif feature_type == "轻盈":
			feature_desc = "轻盈灵动，使用如臂指使。"
		elif feature_type == "精致":
			feature_desc = "做工精致，堪称艺术品。"
		elif feature_type == "华丽":
			feature_desc = "华丽非凡，光彩夺目。"
	
	# 添加材料描述（如果有）
	var material_desc = ""
	if material_type != "":
		material_desc = "由" + material_type + "锻造而成，品质非凡。"
	
	# 组合描述文本
	var desc_parts = [name_str]
	desc_parts.append(base_desc)
	if feature_desc != "":
		desc_parts.append(feature_desc)
	if material_desc != "":
		desc_parts.append(material_desc)
	
	desc = "\n".join(desc_parts)
	
	# 根据等级和品质调整属性
	var quality_multiplier = get_quality_multiplier()
	atk.min_value = int(level * 2 * quality_multiplier)
	atk.max_value = int(level * 5 * quality_multiplier)
	atk.min_growth = 0.1 * level * quality_multiplier
	atk.max_growth = 0.3 * level * quality_multiplier

# 根据品质获取属性倍数
func get_quality_multiplier() -> float:
	var multiplier_map = {
		"凡品": 1.0,
		"精品": 1.2,
		"上品": 1.5,
		"珍品": 2.0,
		"灵品": 2.5,
		"玄品": 3.0,
		"地品": 3.5,
		"天品": 4.0
	}
	
	return multiplier_map.get(weapon_quality, 1.0)
