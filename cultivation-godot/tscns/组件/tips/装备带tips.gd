extends PanelContainer
class_name ItemTips

@export var default_name:String=""
var tips:BaseTips
var item

static func get_ItemTips(item)->ItemTips:
	var result=preload("uid://q4dsd2o5ecm7").instantiate() as ItemTips
	result.添加item(item)
	return result

func 添加item(item):
	移除item()
	self.item=item
	if item:
		self.tips = BaseTips.get_BaseTips(item)
		tips.visible=false
		if tips.get_parent():
			tips.reparent(get_node("AllTips"))
		else:
			get_node("AllTips").add_child(tips)

func 移除item():
	if tips:
		tips.visible=false
		tips.queue_free()
	tips=null
	item=null

func _process(delta: float) -> void:
	if !is_visible_in_tree():
		return
	$Label.text=default_name
	if item:
		$Label.text=item.name_str
	if tips==null:
		return
	var global_show_inside_id=get_tree().root.get_meta("global_show_inside_id","")
	if global_show_inside_id!="" and  global_show_inside_id!=str(get_instance_id()):
		return
	var is_mouse_inside=self.get_meta("is_mouse_inside",false)
	if self.get_global_rect().has_point(get_global_mouse_position()):
		if is_mouse_inside:
			# 在显示中
			pass
		else:
			self.set_meta("is_mouse_inside",true)
			get_tree().root.set_meta("global_show_inside_id",str(get_instance_id()))
			tips.visible=true
			# tips位置自动处理 放在出框
			var mouse_pos = get_global_mouse_position()
			
			# 先设置tips为可见，以便获取其大小
			tips.visible = true
			
			# 获取tips的大小和窗口大小
			# 使用custom_minimum_size作为预估大小，如果获取不到则使用默认值
			var tips_size = tips.custom_minimum_size
			if tips_size.x <= 0 or tips_size.y <= 0:
				# 默认大小估计，基于武器背包tips.tscn中的大小
				tips_size = Vector2(300, 170)
			
			var viewport_size = get_viewport_rect().size
			
			# 计算初始位置，默认显示在鼠标右侧下方
			var final_pos = mouse_pos
			
			# 检查宽度是否会超出窗口边界，如果是则放在鼠标左侧
			if final_pos.x + tips_size.x > viewport_size.x:
				final_pos.x = mouse_pos.x - tips_size.x
			
			# 检查高度是否会超出窗口边界，如果是则放在鼠标上方
			if final_pos.y + tips_size.y > viewport_size.y:
				final_pos.y = mouse_pos.y - tips_size.y
			
			# 确保tips不会显示在窗口外（最小位置为0）
			final_pos.x = max(0, final_pos.x)
			final_pos.y = max(0, final_pos.y)
			
			# 设置最终位置
			tips.global_position = final_pos
			pass
	else:
		if is_mouse_inside:
			if tips.get_global_rect().has_point(get_global_mouse_position()):
				# 认为任然在
				pass
			else:
				self.set_meta("is_mouse_inside",false)
				get_tree().root.set_meta("global_show_inside_id","")
				tips.visible=false
				pass
		else:
			# 本来就不在
			pass
	pass
