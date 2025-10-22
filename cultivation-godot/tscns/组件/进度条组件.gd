extends Control

# 进度条组件扩展 - 显示百分比或 current/max 格式

# 导出属性
@export_enum("百分比","v/m格式") var display_mode: int = 0 # 0: 百分比显示, 1: current/max 格式显示
