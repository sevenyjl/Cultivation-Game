# 测试脚本，用于验证修炼地的灵气生产功能
extends Node2D

func _ready():
	# 创建一个修炼地实例用于测试
	var location = CultivationLocation.new()
	
	print("初始等级: ", location.level)
	print("初始存储上限: ", location.max_qi_storage)
	print("初始生产速度: ", location.qi_generation_rate)
	print("初始灵气: ", location.current_qi)
	print("初始溢出经验: ", location.overflow_exp)
	
	# 模拟10秒的灵气生产（每0.1秒更新一次）
	for i in range(100):
		location.generate_qi(0.1)
		if i % 10 == 9:  # 每秒打印一次状态
			print("第", (i+1)/10, "秒: 灵气=", location.current_qi, ", 溢出经验=", location.overflow_exp)
	
	# 测试升级功能
	print("\n尝试升级:")
	if location.can_upgrade():
		if location.upgrade():
			print("升级成功! 新等级: ", location.level)
		else:
			print("升级失败")
	else:
		print("经验不足，无法升级。当前经验: ", location.overflow_exp, ", 升级所需经验: ", location.get_required_exp())
	
	# 再模拟一段时间的生产
	print("\n继续生产20秒:")
	for i in range(200):
		location.generate_qi(0.1)
		if i % 10 == 9:  # 每秒打印一次状态
			print("第", 10+(i+1)/10, "秒: 灵气=", location.current_qi, ", 溢出经验=", location.overflow_exp)
	
	# 再次尝试升级
	print("\n再次尝试升级:")
	if location.can_upgrade():
		if location.upgrade():
			print("升级成功! 新等级: ", location.level)
		else:
			print("升级失败")
	else:
		print("经验不足，无法升级。当前经验: ", location.overflow_exp, ", 升级所需经验: ", location.get_required_exp())
	
	print("测试完成")
	queue_free()