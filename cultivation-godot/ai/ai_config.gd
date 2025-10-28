class_name AIConfig extends Node

# 单例实例
var DOU_BAO_CONFIG: Dictionary = {
	"API_KEY" = "",
	"MODEL_NAME" = "doubao-1-5-pro-32k-250115",
	"BASE_URL" = "https://ark.cn-beijing.volces.com/api/v3/chat/completions",
	"TIMEOUT" = 30
}

# 配置文件路径
const config_path = "res://ai/ai_config.cfg"

# 初始化方法
func _init() -> void:
	# 尝试从配置文件加载API密钥
	load_config()

# 加载配置方法
func load_config() -> void:
	var config = ConfigFile.new()
	# 从文件加载数据
	var err = config.load(config_path)
	# 如果文件没有加载，忽略它
	if err != OK:
		printerr("配置文件加载错误，请配置")
		return
	# 迭代所有小节
	var section="DouBao"
	var doubao_config=config.get_section_keys(section)
	if doubao_config==null || doubao_config.is_empty():
		printerr("配置文件错误，请配置")
		return
	DOU_BAO_CONFIG["API_KEY"] = config.get_value(section, "API_KEY")
	if DOU_BAO_CONFIG["API_KEY"]==null || DOU_BAO_CONFIG["API_KEY"]=="":
		printerr("请配置豆包API密钥")
		return
	DOU_BAO_CONFIG["MODEL_NAME"] = config.get_value(section, "MODEL_NAME","doubao-1-5-pro-32k-250115")
	DOU_BAO_CONFIG["BASE_URL"] = config.get_value(section, "BASE_URL","https://ark.cn-beijing.volces.com/api/v3/chat/completions")
	DOU_BAO_CONFIG["TIMEOUT"] = config.get_value(section, "TIMEOUT",30)


# 创建默认配置文件
func create_default_config_file() -> void:
	var config = ConfigFile.new()
	# 设置默认配置
	config.set_value("DouBao", "API_KEY", "YOUR_ACTUAL_API_KEY_HERE")
	config.set_value("DouBao", "MODEL_NAME", DOU_BAO_CONFIG["MODEL_NAME"])
	config.set_value("DouBao", "BASE_URL", DOU_BAO_CONFIG["BASE_URL"])
	config.set_value("DouBao", "TIMEOUT", DOU_BAO_CONFIG["TIMEOUT"])
	
	# 保存配置文件
	var err = config.save(config_path)
	if err != OK:
		printerr("无法创建默认配置文件")
	else:
		print("已创建默认配置文件，请在", config_path, "中设置实际的API密钥")
