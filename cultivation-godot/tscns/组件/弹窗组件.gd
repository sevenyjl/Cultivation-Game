extends Panel

signal 关闭弹窗()

func 打开弹窗(node:Node):
	self.visible=true
	for i in $"弹窗/VBoxContainer/Slot".get_children():
		i.queue_free()
	$"弹窗/VBoxContainer/Slot".add_child(node)

func _on_关闭弹窗_pressed() -> void:
	self.visible=false
	关闭弹窗.emit()
	pass # Replace with function body.
