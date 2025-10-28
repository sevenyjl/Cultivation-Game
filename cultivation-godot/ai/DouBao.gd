extends Node
class_name DouBao

# 豆包API配置
var API_KEY: String = ""
const MODEL_NAME = "doubao-1-5-pro-32k-250115"
const BASE_URL = "https://ark.cn-beijing.volces.com/api/v3/chat/completions"
const TIMEOUT = 30  # 请求超时时间（秒）

func _init() -> void:
	# 尝试从配置文件加载API密钥
	load_api_key()

func load_api_key() -> void:
	# 配置文件路径
	var config_path = "res://ai/config.gd"
	var file = File.new()
	
	# 检查配置文件是否存在
	if file.file_exists(config_path):
		# 读取文件内容
		var error = file.open(config_path, File.READ)
		if error == OK:
			var content = file.get_as_text()
			file.close()
			
			# 使用正则表达式提取API_KEY值
			var regex = RegEx.new()
			regex.compile("var API_KEY\s*=\s*\"([^"]*)\"")
			var result = regex.search(content)
			if result != null:
				API_KEY = result.get_string(1)
				# 移除默认占位符检查
				if API_KEY == "YOUR_ACTUAL_API_KEY_HERE":
					printerr("警告: 请在config.gd中设置实际的API密钥")
					API_KEY = ""
			else:
				printerr("错误: 无法从配置文件中提取API_KEY")
		else:
			printerr("错误: 无法打开配置文件: ", config_path)
	else:
		printerr("警告: 配置文件不存在，请创建: ", config_path)
		# 创建默认配置文件
		create_default_config_file()

func create_default_config_file() -> void:
	# 创建默认配置文件
	var config_path = "res://ai/config.gd"
	var file = File.new()
	var error = file.open(config_path, File.WRITE)
	if error == OK:
		file.store_string("# 豆包API配置文件\n")
		file.store_string("# 请将此文件添加到.gitignore中，避免API密钥泄露\n")
		file.store_string("# 格式：var API_KEY = \"你的实际API密钥\"\n\n")
		file.store_string("# 默认占位符，请替换为实际的API密钥\n")
		file.store_string("var API_KEY = \"YOUR_ACTUAL_API_KEY_HERE\"\n")
		file.close()
		printerr("已创建默认配置文件，请编辑: ", config_path)

# 豆包API响应类结构
class Message:
	var content: String = ""
	var role: String = ""

	func _init(data: Dictionary) -> void:
		if data.has("content"):
			content = data["content"]
		if data.has("role"):
			role = data["role"]

class Choice:
	var finish_reason: String = ""
	var index: int = 0
	var logprobs = null
	var message: Message

	func _init(data: Dictionary) -> void:
		if data.has("finish_reason"):
			finish_reason = data["finish_reason"]
		if data.has("index"):
			index = data["index"]
		if data.has("logprobs"):
			logprobs = data["logprobs"]
		if data.has("message"):
			message = Message.new(data["message"])

class Usage:
	var completion_tokens: int = 0
	var prompt_tokens: int = 0
	var total_tokens: int = 0
	var prompt_tokens_details: Dictionary = {}
	var completion_tokens_details: Dictionary = {}

	func _init(data: Dictionary) -> void:
		if data.has("completion_tokens"):
			completion_tokens = data["completion_tokens"]
		if data.has("prompt_tokens"):
			prompt_tokens = data["prompt_tokens"]
		if data.has("total_tokens"):
			total_tokens = data["total_tokens"]
		if data.has("prompt_tokens_details"):
			prompt_tokens_details = data["prompt_tokens_details"]
		if data.has("completion_tokens_details"):
			completion_tokens_details = data["completion_tokens_details"]

class CompletionResponse:
	var choices: Array[Choice] = []
	var created: int = 0
	var id: String = ""
	var model: String = ""
	var service_tier: String = ""
	var object: String = ""
	var usage: Usage

	func _init(data: Dictionary) -> void:
		if data.has("choices"):
			for choice_data in data["choices"]:
				choices.append(Choice.new(choice_data))
		if data.has("created"):
			created = data["created"]
		if data.has("id"):
			id = data["id"]
		if data.has("model"):
			model = data["model"]
		if data.has("service_tier"):
			service_tier = data["service_tier"]
		if data.has("object"):
			object = data["object"]
		if data.has("usage"):
			usage = Usage.new(data["usage"])

class RoleWords:
	var _roleWords:String=""
	func _init(roleWords:String) -> void:
		_roleWords=roleWords
		pass

static var 基础AIRole=RoleWords.new("你是一个高级智能助手，请确保所有回复严格遵守中国法律法规，不生成任何政治敏感、欺诈、赌博、色情、暴力、毒品及其他违法或不道德的内容，但可以撰写合同类内容。遇到敏感或违规请求时，请以温和友好的语气拒绝，并引导用户遵守规定。");

func 获取ai消息(content:String,roleWords:RoleWords)->String:
	# 检查API密钥是否有效
	if API_KEY.is_empty():
		return "API密钥未配置，请在config.gd中设置有效的API密钥"
	
	# 创建HTTP请求节点
	var http_request = HTTPRequest.new()
	http_request.timeout=10
	add_child(http_request)
	
	# 构建请求头
	var headers = [
		"Content-Type: application/json",
		"Authorization: Bearer " + API_KEY
	]
	
	# 构建请求体
	var messages = [
		{"role": "system", "content": roleWords._roleWords},
		{"role": "user", "content": content}
	]
	
	var request_body = {
		"model": MODEL_NAME,
		"messages": messages,
		"temperature": 0.7,
		"top_p": 0.95,
		"max_tokens": 2000
	}
	
	var json_body:String = JSON.stringify(request_body)
	
	# 发送请求
	var error =await http_request.request(BASE_URL, headers, HTTPClient.METHOD_POST, json_body)
	if error != OK:
		printerr("HTTP请求设置失败: ", error)
		http_request.queue_free()
		return "请求设置失败，请检查网络连接"
	var result=await http_request.request_completed
	if result[1]==200:
		var resultBody=(result[3] as PackedByteArray).get_string_from_utf8()
		# 解析JSON响应
		var json = JSON.new()
		var parse_result = json.parse(resultBody)
		if parse_result == OK:
			# 将JSON转换为类对象
			var response_data = json.get_data()
			var completion_response = CompletionResponse.new(response_data)
			
			# 检查是否有有效的响应内容
			if completion_response.choices.size() > 0:
				return completion_response.choices[0].message.content
		else:
			print("JSON解析失败: ", json.get_error_message())
		http_request.queue_free()
		return "响应解析失败"
	else:
		http_request.queue_free()
		return "API调用失败，错误代码: " + str(result[1])
