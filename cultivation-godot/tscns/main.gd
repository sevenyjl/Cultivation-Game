extends Control

# 引用修仙者类
const BaseCultivation = preload("res://entity/Base修仙者.gd")

func _ready() -> void:
	# 创建玩家队伍（修仙者对象）
	var player_team = create_player_team()
	
	# 创建敌人队伍（修仙者对象）
	var enemy_team = create_enemy_team()
	
	# 初始化战斗
	$"战斗UI".初始化战斗(player_team, enemy_team)

# 创建玩家队伍
func create_player_team() -> Array:
	var team = []
	
	# 主玩家 - 修仙者
	var player = BaseCultivation.new()
	player.name_str = "张三"
	player.realm = BaseCultivation.CultivationRealm.LIANQI
	
	# 初始化并设置生命值
	for i in 3:
		player.level_up()
	
	
	team.append(player)
	
	# 队友1 - 修仙者
	var teammate1 = BaseCultivation.new()
	teammate1.name_str = "李四"
	teammate1.realm = BaseCultivation.CultivationRealm.LIANQI
	
	# 初始化并设置生命值
	for i in 2:
		teammate1.level_up()
	
	team.append(teammate1)
	
	# 队友2 - 修仙者
	var teammate2 = BaseCultivation.new()
	teammate2.name_str = "王五"
	teammate2.realm = BaseCultivation.CultivationRealm.FANREN
	
	for i in 2:
		teammate2.level_up()
	team.append(teammate2)
	
	return team

# 创建敌人队伍
func create_enemy_team() -> Array:
	var team = []
	
	# 敌人1 - 野狼（妖兽）
	var wolf = BaseCultivation.new()
	wolf.name_str = "野狼"
	
	# 初始化并设置生命值
	wolf.realm = BaseCultivation.CultivationRealm.FANREN
	for i in 2:
		wolf.level_up()
	team.append(wolf)
	
	# 敌人2 - 哥布林（魔物）
	var goblin = BaseCultivation.new()
	goblin.name_str = "哥布林"
	goblin.realm = BaseCultivation.CultivationRealm.FANREN
	
	
	team.append(goblin)
	
	# 敌人3 - 暗影魔（隐藏Boss）
	var shadow_demon = BaseCultivation.new()
	shadow_demon.realm = BaseCultivation.CultivationRealm.ZHUJI
	for i in 3:
		shadow_demon.level_up()
	team.append(shadow_demon)
	
	return team

# 创建修仙者对象的辅助方法
func create_cultivator(character_name: String, level: int, hp: int, constitution: int, speed: int, realm: BaseCultivation.CultivationRealm) -> BaseCultivation:
	var cultivator = BaseCultivation.new()
	cultivator.name_str = character_name
	cultivator.level = level
	cultivator.constitution = constitution
	cultivator.speed = speed
	cultivator.realm = realm
	
	# 初始化并设置生命值
	cultivator._ready()
	cultivator.hp_stats.max_value = hp
	cultivator.set_current_hp(hp)
	
	return cultivator
