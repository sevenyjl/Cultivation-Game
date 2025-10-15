# scripts/scenes/combat/CombatAnimationController.gd
extends Node2D

# 动画节点引用
@onready var player_sprite: Sprite2D
@onready var enemy_sprite: Sprite2D
@onready var effect_container: Node2D
@onready var damage_label: Label

# 动画参数
var animation_speed: float = 1.0
var is_animating: bool = false

# 动画队列
var animation_queue: Array = []

func _ready():
	create_animation_nodes()

func create_animation_nodes():
	# 创建玩家精灵
	player_sprite = Sprite2D.new()
	player_sprite.position = Vector2(200, 100)
	player_sprite.scale = Vector2(2.0, 2.0)
	add_child(player_sprite)
	
	# 创建敌人精灵
	enemy_sprite = Sprite2D.new()
	enemy_sprite.position = Vector2(600, 100)
	enemy_sprite.scale = Vector2(2.0, 2.0)
	add_child(enemy_sprite)
	
	# 创建效果容器
	effect_container = Node2D.new()
	add_child(effect_container)
	
	# 创建伤害数字标签
	damage_label = Label.new()
	damage_label.add_theme_font_size_override("font_size", 24)
	damage_label.add_theme_color_override("font_color", Color.RED)
	add_child(damage_label)

# 播放攻击动画
func play_attack_animation(attacker, target, damage: float = 0.0):
	if is_animating:
		queue_animation("attack", attacker, target, damage)
		return
	
	is_animating = true
	
	# 确定攻击者和目标的位置
	var attacker_pos = get_combatant_position(attacker)
	var target_pos = get_combatant_position(target)
	
	# 播放攻击动画
	var tween = create_tween()
	tween.set_parallel(true)
	
	# 攻击者向前移动
	tween.tween_property(get_combatant_sprite(attacker), "position", 
		target_pos + (attacker_pos - target_pos).normalized() * 50, 0.3)
	
	# 攻击者回到原位
	tween.tween_property(get_combatant_sprite(attacker), "position", 
		attacker_pos, 0.3).set_delay(0.3)
	
	# 目标受击效果
	if damage > 0:
		tween.tween_callback(show_damage_number.bind(target_pos, damage)).set_delay(0.3)
		tween.tween_callback(play_hit_effect.bind(target_pos)).set_delay(0.3)
	
	# 动画完成
	tween.tween_callback(_on_animation_finished).set_delay(0.6)

# 播放技能动画
func play_skill_animation(caster, target, skill, damage: float = 0.0):
	if is_animating:
		queue_animation("skill", caster, target, damage, skill)
		return
	
	is_animating = true
	
	var caster_pos = get_combatant_position(caster)
	var target_pos = get_combatant_position(target)
	
	# 根据技能类型播放不同动画
	match skill.damage_type:
		"fire":
			play_fire_animation(caster_pos, target_pos, damage)
		"ice":
			play_ice_animation(caster_pos, target_pos, damage)
		"lightning":
			play_lightning_animation(caster_pos, target_pos, damage)
		"qi":
			play_qi_animation(caster_pos, target_pos, damage)
		_:
			play_generic_skill_animation(caster_pos, target_pos, damage)

# 播放火焰动画
func play_fire_animation(caster_pos: Vector2, target_pos: Vector2, damage: float):
	# 创建火焰效果
	var fire_effect = create_fire_effect()
	fire_effect.position = caster_pos
	effect_container.add_child(fire_effect)
	
	# 火焰飞向目标
	var tween = create_tween()
	tween.tween_property(fire_effect, "position", target_pos, 0.5)
	tween.tween_callback(show_damage_number.bind(target_pos, damage)).set_delay(0.5)
	tween.tween_callback(play_hit_effect.bind(target_pos)).set_delay(0.5)
	tween.tween_callback(fire_effect.queue_free).set_delay(0.5)
	tween.tween_callback(_on_animation_finished).set_delay(0.5)

# 播放冰霜动画
func play_ice_animation(_caster_pos: Vector2, target_pos: Vector2, damage: float):
	# 创建冰霜效果
	var ice_effect = create_ice_effect()
	ice_effect.position = target_pos
	effect_container.add_child(ice_effect)
	
	var tween = create_tween()
	tween.tween_callback(show_damage_number.bind(target_pos, damage)).set_delay(0.3)
	tween.tween_callback(play_hit_effect.bind(target_pos)).set_delay(0.3)
	tween.tween_callback(ice_effect.queue_free).set_delay(1.0)
	tween.tween_callback(_on_animation_finished).set_delay(1.0)

# 播放雷电动画
func play_lightning_animation(_caster_pos: Vector2, target_pos: Vector2, damage: float):
	# 创建雷电效果
	var lightning_effect = create_lightning_effect()
	lightning_effect.position = target_pos
	effect_container.add_child(lightning_effect)
	
	var tween = create_tween()
	tween.tween_callback(show_damage_number.bind(target_pos, damage)).set_delay(0.2)
	tween.tween_callback(play_hit_effect.bind(target_pos)).set_delay(0.2)
	tween.tween_callback(lightning_effect.queue_free).set_delay(0.5)
	tween.tween_callback(_on_animation_finished).set_delay(0.5)

# 播放灵气动画
func play_qi_animation(caster_pos: Vector2, target_pos: Vector2, damage: float):
	# 创建灵气效果
	var qi_effect = create_qi_effect()
	qi_effect.position = caster_pos
	effect_container.add_child(qi_effect)
	
	var tween = create_tween()
	tween.tween_property(qi_effect, "position", target_pos, 0.4)
	tween.tween_callback(show_damage_number.bind(target_pos, damage)).set_delay(0.4)
	tween.tween_callback(play_hit_effect.bind(target_pos)).set_delay(0.4)
	tween.tween_callback(qi_effect.queue_free).set_delay(0.4)
	tween.tween_callback(_on_animation_finished).set_delay(0.4)

# 播放通用技能动画
func play_generic_skill_animation(caster_pos: Vector2, target_pos: Vector2, damage: float):
	# 创建通用效果
	var effect = create_generic_effect()
	effect.position = caster_pos
	effect_container.add_child(effect)
	
	var tween = create_tween()
	tween.tween_property(effect, "position", target_pos, 0.3)
	tween.tween_callback(show_damage_number.bind(target_pos, damage)).set_delay(0.3)
	tween.tween_callback(play_hit_effect.bind(target_pos)).set_delay(0.3)
	tween.tween_callback(effect.queue_free).set_delay(0.3)
	tween.tween_callback(_on_animation_finished).set_delay(0.3)

# 播放受击效果
func play_hit_effect(pos: Vector2):
	# 创建受击效果
	var hit_effect = create_hit_effect()
	hit_effect.position = pos
	effect_container.add_child(hit_effect)
	
	var tween = create_tween()
	tween.tween_property(hit_effect, "modulate:a", 0.0, 0.5)
	tween.tween_callback(hit_effect.queue_free).set_delay(0.5)

# 显示伤害数字
func show_damage_number(pos: Vector2, damage: float):
	var damage_text = Label.new()
	damage_text.text = str(int(damage))
	damage_text.add_theme_font_size_override("font_size", 24)
	damage_text.add_theme_color_override("font_color", Color.RED)
	damage_text.position = pos
	add_child(damage_text)
	
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(damage_text, "position", pos + Vector2(0, -50), 1.0)
	tween.tween_property(damage_text, "modulate:a", 0.0, 1.0)
	tween.tween_callback(damage_text.queue_free).set_delay(1.0)

# 获取战斗者位置
func get_combatant_position(combatant) -> Vector2:
	# 简化：根据战斗者类型返回位置
	if combatant and combatant.get_name_info().contains("玩家"):
		return Vector2(200, 100)
	else:
		return Vector2(600, 100)

# 获取战斗者精灵
func get_combatant_sprite(combatant) -> Sprite2D:
	if combatant and combatant.get_name_info().contains("玩家"):
		return player_sprite
	else:
		return enemy_sprite

# 创建火焰效果
func create_fire_effect() -> Node2D:
	var effect = Node2D.new()
	var sprite = Sprite2D.new()
	sprite.texture = preload("res://icon.svg")  # 使用默认图标
	sprite.modulate = Color.ORANGE_RED
	sprite.scale = Vector2(0.5, 0.5)
	effect.add_child(sprite)
	return effect

# 创建冰霜效果
func create_ice_effect() -> Node2D:
	var effect = Node2D.new()
	var sprite = Sprite2D.new()
	sprite.texture = preload("res://icon.svg")
	sprite.modulate = Color.CYAN
	sprite.scale = Vector2(1.0, 1.0)
	effect.add_child(sprite)
	return effect

# 创建雷电效果
func create_lightning_effect() -> Node2D:
	var effect = Node2D.new()
	var sprite = Sprite2D.new()
	sprite.texture = preload("res://icon.svg")
	sprite.modulate = Color.YELLOW
	sprite.scale = Vector2(0.8, 0.8)
	effect.add_child(sprite)
	return effect

# 创建灵气效果
func create_qi_effect() -> Node2D:
	var effect = Node2D.new()
	var sprite = Sprite2D.new()
	sprite.texture = preload("res://icon.svg")
	sprite.modulate = Color.MAGENTA
	sprite.scale = Vector2(0.6, 0.6)
	effect.add_child(sprite)
	return effect

# 创建通用效果
func create_generic_effect() -> Node2D:
	var effect = Node2D.new()
	var sprite = Sprite2D.new()
	sprite.texture = preload("res://icon.svg")
	sprite.modulate = Color.WHITE
	sprite.scale = Vector2(0.7, 0.7)
	effect.add_child(sprite)
	return effect

# 创建受击效果
func create_hit_effect() -> Node2D:
	var effect = Node2D.new()
	var sprite = Sprite2D.new()
	sprite.texture = preload("res://icon.svg")
	sprite.modulate = Color.WHITE
	sprite.scale = Vector2(1.2, 1.2)
	effect.add_child(sprite)
	return effect

# 队列动画
func queue_animation(type: String, attacker, target, damage: float = 0.0, skill = null):
	animation_queue.append({
		"type": type,
		"attacker": attacker,
		"target": target,
		"damage": damage,
		"skill": skill
	})

# 处理动画队列
func process_animation_queue():
	if not animation_queue.is_empty() and not is_animating:
		var animation = animation_queue.pop_front()
		match animation.type:
			"attack":
				play_attack_animation(animation.attacker, animation.target, animation.damage)
			"skill":
				play_skill_animation(animation.attacker, animation.target, animation.skill, animation.damage)

# 动画完成回调
func _on_animation_finished():
	is_animating = false
	process_animation_queue()

# 设置动画速度
func set_animation_speed(speed: float):
	animation_speed = speed
