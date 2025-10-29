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
			tips.global_position=get_global_mouse_position()
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
