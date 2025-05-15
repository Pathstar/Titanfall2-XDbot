from pypinyin import pinyin, lazy_pinyin, Style
from pypinyin_dict.phrase_pinyin_data import large_pinyin
from pypinyin_dict.pinyin_dict import PinyinDictionary

# 加载大词库
large_pinyin.load()

# 自定义词库（格式：{词语: 拼音列表}）
custom_phrases = {
    "转账": [["zhuǎn"], ["zhàng"]],
    "拼音": [["pīn"], ["yīn"]],
    "我想要": [["wǒ"], ["xiǎng"], ["yào"]],
    "转换": [["zhuǎn"], ["huàn"]]
}

# 添加自定义词库到pypinyin
PinyinDictionary.update(custom_phrases)


def pinyin_to_text(pinyin_str):
    """
    将拼音字符串转换为汉字

    参数:
        pinyin_str: 拼音字符串，如 "wo xiang yao zhuan pin yin"

    返回:
        转换后的汉字文本
    """
    # 分割拼音字符串为列表
    pinyin_list = pinyin_str.split()

    try:
        # 使用自定义词库进行转换
        result = lazy_pinyin(pinyin_list, style=Style.NORMAL, errors=lambda x: x)
        # 将拼音列表转换为可能的汉字组合
        # 这里简单处理，实际应用中可能需要更复杂的算法
        # 例如使用语言模型或更高级的拼音转汉字算法

        # 由于pypinyin主要设计用于汉字转拼音，反向转换有限制
        # 这里我们做一个简单的演示，实际应用中可能需要其他方法

        # 更准确的方法是使用pinyin.get()获取所有候选
        chars = []
        for py in pinyin_list:
            # 获取该拼音对应的所有汉字候选
            candidates = pinyin(py, style=Style.NORMAL, heteronym=True)[0]
            if candidates:
                # 简单选择第一个候选（实际应用中可以更智能选择）
                chars.append(candidates[0])
            else:
                chars.append(py)  # 如果没有找到，保留原拼音

        return ''.join(chars)

    except Exception as e:
        return f"转换出错: {str(e)}"


# 测试示例
test_pinyin = "wo xiang yao zhuan pin yin"
result = pinyin_to_text(test_pinyin)
print(f"拼音 '{test_pinyin}' 转换为汉字: {result}")

# 另一个测试
test_pinyin2 = "ni hao shi jie"
result2 = pinyin_to_text(test_pinyin2)
print(f"拼音 '{test_pinyin2}' 转换为汉字: {result2}")