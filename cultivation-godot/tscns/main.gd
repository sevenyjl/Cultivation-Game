extends Control

# 引用修仙者类

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
	player.level = 3
	player.max_hp = 150
	player.current_hp = 150
	player.max_mp = 80
	player.current_mp = 80
	player.strength = 15
	player.agility = 12
	player.intelligence = 18
	player.constitution = 14
	player.speed = 20  # 主角速度较高
	player.realm = BaseCultivation.CultivationRealm.LIANQI
	
	# 学习技能
	player.learn_skill("火球术", "发射一个火球攻击敌人", 10)
	player.learn_skill("治疗术", "恢复生命值", 15)
	player.learn_technique("基础心法", "提升修炼效率的基础功法")
	
	team.append(player)
	
	# 队友1 - 修仙者
	var teammate1 = BaseCultivation.new()
	teammate1.name_str = "李四"
	teammate1.level = 2
	teammate1.max_hp = 120
	teammate1.current_hp = 120
	teammate1.max_mp = 60
	teammate1.current_mp = 60
	teammate1.strength = 12
	teammate1.agility = 15
	teammate1.intelligence = 14
	teammate1.constitution = 12
	teammate1.speed = 18  # 敏捷型角色，速度较高
	teammate1.realm = BaseCultivation.CultivationRealm.LIANQI
	
	# 学习技能
	teammate1.learn_skill("风刃术", "发射风刃攻击敌人", 8)
	teammate1.learn_technique("轻身术", "提升移动速度的功法")
	
	team.append(teammate1)
	
	# 队友2 - 修仙者
	var teammate2 = BaseCultivation.new()
	teammate2.name_str = "王五"
	teammate2.level = 1
	teammate2.max_hp = 100
	teammate2.current_hp = 100
	teammate2.max_mp = 50
	teammate2.current_mp = 50
	teammate2.strength = 10
	teammate2.agility = 10
	teammate2.intelligence = 12
	teammate2.constitution = 10
	teammate2.speed = 12  # 新手角色，速度一般
	teammate2.realm = BaseCultivation.CultivationRealm.FANREN
	
	# 学习技能
	teammate2.learn_skill("基础攻击", "基础物理攻击", 0)
	
	team.append(teammate2)
	
	return team

# 创建敌人队伍
func create_enemy_team() -> Array:
	var team = []
	
	# 敌人1 - 野狼（妖兽）
	var wolf = BaseCultivation.new()
	wolf.name_str = "野狼"
	wolf.level = 2
	wolf.max_hp = 80
	wolf.current_hp = 80
	wolf.max_mp = 20
	wolf.current_mp = 20
	wolf.strength = 12
	wolf.agility = 16
	wolf.intelligence = 6
	wolf.constitution = 10
	wolf.speed = 22  # 野狼速度快
	wolf.realm = BaseCultivation.CultivationRealm.FANREN
	
	# 学习技能
	wolf.learn_skill("撕咬", "用利齿撕咬敌人", 0)
	wolf.learn_skill("狼嚎", "发出震慑敌人的嚎叫", 5)
	
	team.append(wolf)
	
	# 敌人2 - 哥布林（魔物）
	var goblin = BaseCultivation.new()
	goblin.name_str = "哥布林"
	goblin.level = 1
	goblin.max_hp = 60
	goblin.current_hp = 60
	goblin.max_mp = 30
	goblin.current_mp = 30
	goblin.strength = 8
	goblin.agility = 12
	goblin.intelligence = 10
	goblin.constitution = 8
	goblin.speed = 15  # 哥布林速度中等
	goblin.realm = BaseCultivation.CultivationRealm.FANREN
	
	# 学习技能
	goblin.learn_skill("投掷", "投掷石块攻击", 0)
	goblin.learn_skill("毒液", "喷射毒液攻击", 8)
	
	team.append(goblin)
	
	# 敌人3 - 暗影魔（隐藏Boss）
	var shadow_demon = BaseCultivation.new()
	shadow_demon.name_str = "暗影魔"
	shadow_demon.level = 5
	shadow_demon.max_hp = 200
	shadow_demon.current_hp = 200
	shadow_demon.max_mp = 120
	shadow_demon.current_mp = 120
	shadow_demon.strength = 20
	shadow_demon.agility = 18
	shadow_demon.intelligence = 25
	shadow_demon.constitution = 18
	shadow_demon.speed = 25  # Boss级速度
	shadow_demon.realm = BaseCultivation.CultivationRealm.ZHUJI
	
	# 学习技能
	shadow_demon.learn_skill("暗影箭", "发射暗影能量箭", 15)
	shadow_demon.learn_skill("暗影护盾", "召唤暗影护盾", 20)
	shadow_demon.learn_skill("暗影传送", "瞬间移动到敌人身后", 25)
	shadow_demon.learn_technique("暗影心法", "提升暗影系技能威力")
	
	team.append(shadow_demon)
	
	return team

# 创建修仙者对象的辅助方法
func create_cultivator(character_name: String, level: int, hp: int, mp: int, strength: int, agility: int, intelligence: int, constitution: int, speed: int, realm: BaseCultivation.CultivationRealm) -> BaseCultivation:
	var cultivator = BaseCultivation.new()
	cultivator.name_str = character_name
	cultivator.level = level
	cultivator.max_hp = hp
	cultivator.current_hp = hp
	cultivator.max_mp = mp
	cultivator.current_mp = mp
	cultivator.strength = strength
	cultivator.agility = agility
	cultivator.intelligence = intelligence
	cultivator.constitution = constitution
	cultivator.speed = speed
	cultivator.realm = realm
	return cultivator
