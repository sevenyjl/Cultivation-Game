extends PanelContainer

# 人员战斗信息组件
# 用于显示单个战斗人员的基本信息

@onready var name_label = $MainContainer/NameContainer/value
@onready var hp_progress_bar = $MainContainer/HPContainer/value

# 人员数据
var character_data:BaseCultivation

func _process(delta):
	if character_data == null:
		return
	name_label.text = character_data.name_str
	# 更新进度条
	var hp_stats = character_data.hp_stats as RangedValue
	if hp_stats.max_value > 0:
		hp_progress_bar.value = (float(hp_stats.get_current_value()) / float(hp_stats.max_value)) * 100.0
	else:
		hp_progress_bar.value = 0.0

func 初始化人员战斗信息(character_data:BaseCultivation):
	self.character_data = character_data
