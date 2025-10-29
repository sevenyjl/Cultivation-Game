extends PanelContainer
class_name ItemTips

@export var default_name:String=""
@export var tips:Control
@onready var 武器背包Tips=$"AllTips/武器背包Tips"

func _process(delta: float) -> void:
	if !is_visible_in_tree():
		return
	$Label.text=default_name
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
