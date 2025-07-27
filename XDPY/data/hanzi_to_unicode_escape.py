def hanzi_to_unicode_escape(s):
    result = ''
    for ch in s:
        code = ord(ch)
        if code < 128:
            result += ch
            result += '\\u{:04x}'.format(code)
        else:
            # 非ASCII字符，转为\uXXXX格式
            result += '\\u{:04x}'.format(code)
    return result

# 示例
s = ""
print(hanzi_to_unicode_escape(s))
