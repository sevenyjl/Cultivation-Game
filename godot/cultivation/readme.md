 请浏览当前项目的所有文件然后进行代码风格、代码规范、代码注释的学习。

 注意:
 在tscn文件中内置gd脚本格式需要特别注意！！
 eg: 
 [sub_resource type="GDScript" id="GDScript_qnwvq"]
script/source = "
# 这里都是内置gd脚本 从"到"
"

内置脚本中的"都需要转义处理
eg:
[sub_resource type="GDScript" id="GDScript_qnwvq"]
script/source = "extends Node
# 这里都是内置gd脚本代码
func add_log(message):
	game_log.text += \"[%s] %s\\n\" % [Time.get_time_string_from_system(), message]
	# 自动滚动到底部
	game_log.get_parent().scroll_vertical = game_log.get_line_count()
"
有什么问题尽管提出来