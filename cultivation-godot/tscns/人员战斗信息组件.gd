extends PanelContainer

# 人员战斗信息组件
# 用于显示单个战斗人员的基本信息

@onready var name_label = $MainContainer/NameLabel
@onready var hp_label = $MainContainer/HPContainer/HPLabel
@onready var hp_progress_bar = $MainContainer/HPContainer/HPProgressBar

# 人员数据
var character_data = {
	"name": "未设置",
	"hp": 100,
	"max_hp": 100
}

func _ready():
	update_display()

# 设置人员数据
func set_character_data(character_name: String, current_hp: int, max_hp: int):
	character_data.name = character_name
	character_data.hp = current_hp
	character_data.max_hp = max_hp
	update_display()

# 更新生命值
func update_hp(current_hp: int, max_hp: int = -1):
	character_data.hp = current_hp
	if max_hp != -1:
		character_data.max_hp = max_hp
	update_display()

# 更新显示
func update_display():
	name_label.text = "名称: " + character_data.name
	hp_label.text = "生命值: " + str(character_data.hp) + "/" + str(character_data.max_hp)
	
	# 更新进度条
	if character_data.max_hp > 0:
		hp_progress_bar.value = (float(character_data.hp) / float(character_data.max_hp)) * 100.0
	else:
		hp_progress_bar.value = 0.0

# 获取人员名称
func get_character_name() -> String:
	return character_data.name

# 获取当前生命值
func get_current_hp() -> int:
	return character_data.hp

# 获取最大生命值
func get_max_hp() -> int:
	return character_data.max_hp
