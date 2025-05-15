import requests
import json

response = requests.post(
    url="https://openrouter.ai/api/v1/chat/completions",
    headers={
        "Authorization":,
        "Content-Type": "application/json",
    },
    data=json.dumps({
        # "model": "deepseek/deepseek-r1:free",
        # "model": "qwen/qwen3-14b:free",
        "model": "qwen/qwen3-4b:free",
        "messages": [
            # {
            #     "role": "system",
            #     "content": "你是一个简洁的聊天机器人。请快速响应，不进行深度思考，仅直接回答问题，不做额外解释或铺垫，并准守以下规则。1.请严格限制回答字数在 80 "
            #                "字以内，省略思考过程，仅做简洁回答，不要包含开头介绍、无关紧要的话或额外说明。2.用户来自于游戏泰坦陨落2(Titanfall 2) "
            #                "中的玩家，内容可能与游戏有关。玩家的话包括三部分：开头中括号中是玩家的前缀，其次是玩家的名字，冒号后是玩家的话"
            # },
            {
                "role": "system",
                "content": "你是一个处在non-thinking("
                           "enable_thinking=False)模式，简洁的聊天机器人。请快速响应，不进行深度思考，仅直接回答问题，不做额外解释或铺垫，并准守以下规则。1"
                           ".请严格限制回答字数在 80 "
                           "字以内，省略思考过程，仅做简洁回答，不要包含开头介绍、无关紧要的话或额外说明。2. "
                           "环境仅限基本字符，请使用英文字符组成的颜文字代替emoji，3.用户来自于游戏泰坦陨落2(Titanfall 2) "
                           "中的玩家。玩家的话包括三部分：开头中括号中是玩家的前缀，其次是玩家的名字，冒号后是玩家的话"
            },
            {
                "role": "user",
                "content": "请问你是否没有进入non-thinking模式"
            }
        ],
        "enable_thinking": False,
        "temperature": 1.4
        # "max_tokens": 48
    })
)


def split_string_limited(s, max_length=244):
    """优化后的字符串分割方法，只允许超出一次"""
    chinese_chars = set("，。？！（）【】、；：") | set(chr(i) for i in range(0x4E00, 0x9FFF))  # 预计算汉字及标点
    s = s.replace("\n", "").replace("\r", "")  # 去除换行符
    current_length = 0
    temp_list = []
    result = []
    exceeded_once = False  # 标记是否已经超出一次

    for char in s:
        char_length = 3 if char in chinese_chars else 1
        if current_length + char_length > max_length:
            if exceeded_once:  # 如果已经超出一次，则返回空字符串
                return ""
            result.append(''.join(temp_list))
            temp_list = [char]
            current_length = char_length
            exceeded_once = True  # 标记已超出
        else:
            temp_list.append(char)
            current_length += char_length

    if temp_list:
        result.append(''.join(temp_list))

    return result




# 示例
# text = "这是一个测试字符串，\n包含English words and punctuation!"
# print(split_string_limited(text))

# 输出响应的数据
data = response.json()
print(data)
print("---\n---\n---")
try:
    content = split_string_limited(data['choices'][0]['message']['content'])
    print("AI:", content)
except KeyError:
    print("错误: 'data' 结构中缺少所需的键！")
except IndexError:
    print("错误: 'choices' 列表索引超出范围！")
except Exception as e:
    print(f"发生错误: {e}")
reasoning = data['choices'][0]['message']['reasoning']
# if content:
#     print(f"\n True")
# else:
#     print(f"\n False")
print("\n True" if content else "\n False")

# print(content)
print(reasoning)
