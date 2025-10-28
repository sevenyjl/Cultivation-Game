extends Node
class_name Wepoen

# 武器数据存储路径
const WEAPON_DATA_PATH = "res://entity/weapon_data.json"

# 不再需要直接引用aiConfig，因为使用DouBao.gd中的方法处理AI调用

@export var level: int = 1  # 修炼等级
@export var name_str:String="新手短剑"
@export var desc:String="新手短剑🗡️"

# 武器属性
@export var weapon_type:String = "剑"  # 武器类型(后缀)
@export var weapon_quality:String = "普通"  # 武器品质
@export var material_type:String = ""  # 材料类型(如精钢、玄铁等)

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
func get_random_weapon() -> Wepoen:
	# 尝试从JSON文件获取武器数据
	var weapon_data = _get_weapon_data_from_json().pick_random()
	if weapon_data=={}:
		print("AI 生成中")
		# 如果没有获取到数据，使用AI生成多个武器数据
		await  _generate_weapon_data_with_ai()
		print("AI 完成")
	else:
		# 如果获取到数据，应用到武器对象
		_apply_weapon_data(weapon_data)
	return self

# 从JSON文件获取武器数据
func _get_weapon_data_from_json() -> Array:
	# 使用Godot内置的FileAccess类
	var file = FileAccess.open(WEAPON_DATA_PATH, FileAccess.READ)
	if file == null:
		# 如果文件不存在，创建一个空的文件
		_create_empty_weapon_json()
		return [{}]
	
	var content = file.get_as_text()
	file.close()
	
	# 使用Godot内置的JSON类
	var weapon_data_array =  JSON.parse_string(content)
	return weapon_data_array

# 创建空的武器数据JSON文件
func _create_empty_weapon_json() -> void:
	var file = FileAccess.open(WEAPON_DATA_PATH, FileAccess.WRITE)
	if file != null:
		file.store_string("[{}]")
		file.close()
		print("已创建空的武器数据文件")

# 应用武器数据到对象
func _apply_weapon_data(data: Dictionary) -> void:
	if data.has("name_str"):
		name_str = data["name_str"]
	if data.has("desc"):
		desc = data["desc"]
	if data.has("weapon_type"):
		weapon_type = data["weapon_type"]
	if data.has("weapon_quality"):
		weapon_quality = data["weapon_quality"]
	if data.has("material_type"):
		material_type = data["material_type"]
	if data.has("level"):
		level = data["level"]
	
	# 根据等级和品质调整属性
	var quality_multiplier = get_quality_multiplier()
	atk.min_value = int(level * 2 * quality_multiplier)
	atk.max_value = int(level * 5 * quality_multiplier)
	atk.min_growth = 0.1 * level * quality_multiplier
	atk.max_growth = 0.3 * level * quality_multiplier

# 使用AI生成武器数据
func _generate_weapon_data_with_ai() -> void:
	# 计算要生成的武器数量（1-10个）
	var weapons_count = randi() % 10 + 1
	
	# 准备AI请求消息
	var prompt = "请为修仙游戏随机生成" + str(weapons_count) + "件不同的武器详细数据。需要包含以下字段：\n"
	prompt += "1. name_str: 武器名称\n"
	prompt += "2. desc: 武器描述\n"
	prompt += "3. weapon_type: 武器类型(如剑、刀、枪等)\n"
	prompt += "4. weapon_quality: 武器品质(如凡品、精品、上品、珍品、灵品、玄品、地品、天品)\n"
	prompt += "5. material_type: 材料类型(如精钢、玄铁、青铜、白银、黄金等)\n"
	prompt += "6. level: 武器等级(1-10)\n"
	prompt += "\n请以严格的JSON数组格式输出，每个元素都是一个武器对象，只包含上述字段，不要添加其他内容。"
	
	# 使用已有的DouBao类调用AI
	var doubao = DouBao.new()
	add_child(doubao)
	
	var role_words = DouBao.RoleWords.new("你是一个游戏数据生成专家，请为修仙游戏生成合理的武器数据。")
	var ai_response = await doubao.获取ai消息(prompt, role_words)
	print("生成%s个武器成功：%s" % [weapons_count, ai_response])
	var weapon_data_array = JSON.parse_string(ai_response)
	if weapon_data_array is Array and weapon_data_array.size() > 0:
		# 保存所有生成的武器数据
		for weapon_data in weapon_data_array:
			if weapon_data is Dictionary:
				_save_weapon_data_to_json(weapon_data)
		# 应用第一个武器数据到当前对象
		_apply_weapon_data(weapon_data_array[0])

# 保存武器数据到JSON文件
func _save_weapon_data_to_json(weapon_data: Dictionary) -> void:
	var file = FileAccess.open(WEAPON_DATA_PATH, FileAccess.READ)
	var weapon_data_array = []
	
	if file != null:
		var content = file.get_as_text()
		file.close()
		
		var json_parser = JSON.new()
		var error = json_parser.parse(content)
		
		if error == OK:
			var data = json_parser.get_data()
			if data is Array:
				weapon_data_array = data
	
	# 添加新的武器数据
	weapon_data_array.append(weapon_data)
	
	# 写回文件
	file = FileAccess.open(WEAPON_DATA_PATH, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(weapon_data_array))
		file.close()
		print("已保存武器数据到JSON文件")

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
