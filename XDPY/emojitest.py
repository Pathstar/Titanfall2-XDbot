import re
import emoji
from unidecode import unidecode


# 判断是否为中文字符
def is_chinese(char):
    return '\u4e00' <= char <= '\u9fff'


# 非 ASCII 转换（保留中文）
def convert_non_ascii_except_chinese(text):
    return ''.join(char if is_chinese(char) or ord(char) < 128 else unidecode(char) for char in text)


# Emoji 映射表
emoji_map = {
    "grinning_face": ":D",
    "smiling_face_with_hearts": "(^_^)",
    "face_with_tears_of_joy": "XD",
    "thinking_face": "(._.)",
    "winking_face": "(^_~)",
    "thumbs_up": "(b^_^)b"
}


# Emoji 转换
def emoji_to_ascii(text):
    emoji_text = emoji.demojize(text)  # 将 emoji 转为名称
    for key, val in emoji_map.items():
        emoji_text = emoji_text.replace(f":{key}:", val)
    return emoji_text


# 优化后的字符串分割方法
def split_string_limited(s, max_length=244):
    """优化后的字符串分割方法，转换非 ASCII 字符和 emoji，同时限制长度"""
    chinese_chars = set("，。？！（）【】、；：") | set(chr(i) for i in range(0x4E00, 0x9FFF))  # 预计算汉字及标点
    s = s.replace("\n", "").replace("\r", "")  # 去除换行符

    # 先转换非 ASCII 字符和 emoji
    s = convert_non_ascii_except_chinese(s)
    s = emoji_to_ascii(s)

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


# 测试代码
text = "你好 😊 𝒜𝒮𝒞𝒾𝒾 🚀"
print(split_string_limited(text))
