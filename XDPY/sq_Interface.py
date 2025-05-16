import win32file
import win32con
import os
import json
import time
import threading
import re
from Pinyin2Hanzi import DefaultDagParams
from Pinyin2Hanzi import dag
import requests
import emoji
from unidecode import unidecode
from datetime import datetime

chat_history_len = 10
save_history = True


def process_entry(timestamp, player_name, command, message, say):
    """Process a new entry asynchronously."""
    global thread_count
    start_time = time.time()
    start_strftime = time.strftime("%H:%M:%S")
    # print(f"{start_strftime} Begin: {player_name}: {command}" + (f"\n{message}" if message else ""))
    print(f"[XDlog] {start_strftime} Begin: {player_name}: {command} {message}")
    isNoneFunc = False
    py_message = ""

    match command:
        case "new_chat":
            # chat_history = []
            chat_history.clear()
            return
        case _:
            thread_count += 1
            match command:
                case "g_pinyin":
                    py_message = convert_pinyin_to_hanzi_with_preservation(message, True)
                    command = "pinyin"
                    isNoneFunc = True
                case "pinyin":
                    py_message = convert_pinyin_to_hanzi_with_preservation(message, False)
                case "time":
                    py_message = time.strftime("%H:%M:%S")
                case "ai":
                    py_message = deepseek(player_name, message, True)
                case _:
                    print(f"无此方法 {command}")
                    isNoneFunc = True

    end_time = time.time()
    # process_time = round(end_time - start_time, 1)
    process_time = end_time - start_time
    result_data = {end_time: {player_name: {
        "command": command,
        "message": message,
        "pyMessage": py_message,
        "say": say,
        "process_time": process_time
    }}}
    try:
        if os.path.exists(result_file_path):
            with open(result_file_path, 'r', encoding='utf-8') as f:
                existing_data = json.load(f)
        else:
            existing_data = {}

        existing_data.update(result_data)

        with open(result_file_path, 'w', encoding='utf-8') as f:
            json.dump(existing_data, f, ensure_ascii=False, indent=4)
        end_strftime = time.strftime("%H:%M:%S")
        print(f"[XDlog] {end_strftime} Finish: {player_name}: {message} use: {process_time}\n{py_message} ")
    except Exception as e:
        print("[XDlog] Failed to update result JSON:", e)

    if py_message == "":
        if not isNoneFunc:
            print(f"[XDlog] \n {command} 返回为空 \n")

    thread_count -= 1
    if thread_count == 0:
        with open(state_file_path, 'w', encoding='utf-8') as f:
            f.write("0")
    processing_set.remove((timestamp, player_name))


def monitor_file():
    """Monitor file changes."""
    global thread_count
    h_dir = win32file.CreateFile(
        watch_dir,
        win32con.GENERIC_READ,
        win32con.FILE_SHARE_READ | win32con.FILE_SHARE_WRITE | win32con.FILE_SHARE_DELETE,
        None,
        win32con.OPEN_EXISTING,
        win32con.FILE_FLAG_BACKUP_SEMANTICS,
        None
    )

    last_m_time = os.path.getmtime(json_file_path)
    print(f"{time.strftime('%H:%M:%S')} Monitoring file changes...")

    while True:
        results = win32file.ReadDirectoryChangesW(
            h_dir,
            1024,
            False,
            win32con.FILE_NOTIFY_CHANGE_LAST_WRITE,
            None,
            None
        )

        for action, filename in results:
            if filename == target_file:
                try:
                    current_m_time = os.path.getmtime(json_file_path)
                    if current_m_time != last_m_time:
                        with open(json_file_path, 'r', encoding='utf-8') as f:
                            data = json.load(f)

                        for timestamp, player_info in data.items():
                            for player_name, details in player_info.items():
                                if (timestamp, player_name) not in processing_set:
                                    processing_set.add((timestamp, player_name))
                                    threading.Thread(target=process_entry,
                                                     args=(
                                                         timestamp, player_name,
                                                         details["command"], details["message"], details["say"]
                                                     )).start()
                                    thread_count = thread_count + 1
                                    if thread_count == 1:
                                        with open(state_file_path, 'w', encoding='utf-8') as f:
                                            f.write("1")

                        last_m_time = current_m_time
                except Exception as e:
                    print(f"{time.strftime('%H:%M:%S')} Failed to read JSON:", e)


# 转拼音：

# 提前替换指定词组
def preprocess_custom_words(text):
    def replacement(match):
        pinyin = match.group()
        return custom_dict.get(pinyin.lower(), pinyin)  # 只替换匹配的拼音，未匹配的保持原样

    pattern = re.compile(r'\b(' + '|'.join(map(re.escape, custom_dict.keys())) + r')\b', flags=re.IGNORECASE)
    return pattern.sub(replacement, text)


def convert_pinyin_list(pinyin_list, dag_params, topk, result, fail_count_dict):
    if len(pinyin_list) == 0:
        return

    # 从整个列表开始，不断缩短末尾，直到能成功匹配
    for L in range(len(pinyin_list), 0, -1):
        prefix = pinyin_list[:L]
        lowercase_prefix = [word.lower() for word in prefix]
        dag_results = dag(dag_params, lowercase_prefix, path_num=topk)
        if dag_results:
            cand = dag_results[0].path
            result.append(cand)
            print(f"result  {result}")
            convert_pinyin_list(pinyin_list[L:], dag_params, topk, result, fail_count_dict)
            return

    fail_count_dict["count"] += 1
    result.append([pinyin_list[0]])
    convert_pinyin_list(pinyin_list[1:], dag_params, topk, result, fail_count_dict)


# 主转换函数，增加对混合不可转换拼音的回退处理
def convert_pinyin_to_hanzi_with_preservation(text, is_g_pinyin, topk=1):
    # 预处理自定义词
    text = preprocess_custom_words(text)

    tokens = re.findall(r"[a-z]+(?: [a-z]+)*|[^\sa-z]+|\s+", text, flags=re.IGNORECASE)
    result = []
    fail_count_dict = {"count": 0}
    pinyin_len = 0

    for token in tokens:
        stripped = token
        if stripped:
            pinyin_list = stripped.split()
            # pinyin_list = split_pinyin_with_filter(stripped)
            pinyin_len = pinyin_len + len(pinyin_list)
            convert_pinyin_list(pinyin_list, dag_params, topk, result, fail_count_dict)

    fail_count = fail_count_dict["count"]
    print(f"[XDlog] fail_count: {fail_count} pinyin_len: {pinyin_len}")
    if is_g_pinyin:
        if fail_count >= pinyin_len / 2:
            print(f"Failed Trans")
            return ""

    # 最终扁平化
    def flatten(item):
        if isinstance(item, list):
            return ''.join(flatten(i) for i in item)
        return item

    return ''.join(flatten(r) for r in result)


# deepseek
def deepseek(name, message, is_success):
    global AILimit
    if AILimit:
        Auth = ""
    else:
        Auth = ""
    if save_history:
        if is_success:
            chat_history.append({"role": "user", "content": f"name: {name}, content: {message}"})
            if len(chat_history) > chat_history_len:
                chat_history.pop(0)

    messages = [
        {
            "role": "system",
            "content": "你是一个简洁的聊天机器人，处在non-thinking(enable_thinking=False)模式。请快速响应，不进行深度思考，直接回答问题,并准守以下规则。1.请严格限制回答字数在 80 字以内，省略思考过程，仅做简洁回答。内容尽量幽默有趣，引人开心2. 字符编码环境仅限最基本的字符，不要使用emoji，如需使用，请使用最基本的英文字符组成的颜文字代替emoji，3.用户来自于游戏泰坦陨落2(Titanfall 2) 中的玩家，但问题也有很大可能与泰坦陨落2无关，若无关则不要提及，请仔细辨别。user的话包括name，其中中括号是玩家的前缀，后面是玩家名字，content后面是玩家的问题"
        },
        {
            "role": "user",
            "content": f"name: {name}, content: {message}"
        }
    ]
    messages.extend(chat_history)
    response = requests.post(
        url="https://openrouter.ai/api/v1/chat/completions",
        headers={

            "Authorization": Auth,
            "Content-Type": "application/json",
        },
        data=json.dumps({
            # "model": "deepseek/deepseek-r1:free",
            # "model": "qwen/qwen3-14b:free",
            "model": "qwen/qwen3-4b:free",
            "messages": messages,
            "enable_thinking": False,
            "temperature": 1.4
            # "max_tokens": 48
        })
    )

    data = response.json()
    print(data)
    print("---\n\n---")
    try:
        content = split_string_limited(data['choices'][0]['message']['content'])
    except KeyError:
        print("AI响应发生错误: 'data' 结构中缺少所需的键！")
        if AILimit:
            return ["AI响应发生错误: 到达每日限额...TvT"]
        AILimit = True
        print(f"\n\n\n\n\n\n\n\n\n\n第一个号超出限额\n\n")
        max_retries = 3
        retries = 0
        while retries < max_retries:
            content = deepseek(name, message, False)
            if content:
                return content
            retries += 1
            print(f"重试 {retries}/{max_retries}...")
        return ["重试3次后失败..."]

    except IndexError:
        return ["AI响应发生错误: 'choices' 列表索引超出范围！"]
    except Exception as e:
        print(f"AI响应发生错误: {e}")
        return [f"AI响应发生错误: {e.__class__.__name__}"]

    if content:
        if save_history:
            chat_history.append({"role": "assistant", "content": content})
            if len(chat_history) > chat_history_len:
                chat_history.pop(0)  # 确保对话历史不会无限增长
        return content
    else:
        content = deepseek(name, message, False)
        if content:
            return content
        else:
            return ["重试后失败..."]


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


# 判断是否为中文字符
def is_chinese(char):
    return '\u4e00' <= char <= '\u9fff'


# 非 ASCII 转换（保留中文）
def convert_non_ascii_except_chinese(text):
    return ''.join(char if is_chinese(char) or ord(char) < 128 else unidecode(char) for char in text)


# Emoji 转换
def emoji_to_ascii(text):
    emoji_text = emoji.demojize(text)  # 将 emoji 转为名称
    for key, val in emoji_map.items():
        emoji_text = emoji_text.replace(f":{key}:", val)
    return emoji_text


_print = print
# 自定义print，同时写入日志文件
def print(*args, **kwargs):
    message = " ".join(map(str, args))
    with open(log_file_path, "a", encoding="utf-8") as log_file:
        log_file.write(message + "\n")
    _print(*args, **kwargs)
    return print


# 获取当前日期，格式：YYYY-MM-DD
log_filename = datetime.now().strftime("%Y-%m-%d") + ".txt"
# 指定日志目录
log_dir = os.path.join(os.path.dirname(__file__), "XDlogs")
# 创建日志文件夹（如果不存在）
os.makedirs(log_dir, exist_ok=True)
# 日志文件完整路径
log_file_path = os.path.join(log_dir, log_filename)

json_file_path = r'D:\SystemApps\Steam\steamapps\common\Titanfall2\R2Northstar\save_data\Northstar.Client\XD.json'
result_file_path = r'D:\SystemApps\Steam\steamapps\common\Titanfall2\R2Northstar\save_data\Northstar.Client\py_XD.json'
state_file_path = r'D:\SystemApps\Steam\steamapps\common\Titanfall2\R2Northstar\save_data\Northstar.Client\state.txt'
watch_dir = os.path.dirname(json_file_path)
target_file = os.path.basename(json_file_path)

processing_set = set()
thread_count = 0
AILimit = False
chat_history = []
if __name__ == "__main__":
    # 转拼音 初始化模型参数
    custom_dict = {
        "meng xin lei mu": "萌新泪目",
        "meng xin qiu dai": "萌新求带",
        "zhuan pin yin": "转拼音",
        "zhun que lv": "准确率",
        "que shi": "确实",
        "zhun que": "准确",
        "cao": "草",
        "que": "却",
        "ya": "呀"
    }
    # Emoji 映射表
    emoji_map = {
        "grinning_face": ":D",
        "smiling_face_with_hearts": "(^▽^)",
        "face_with_tears_of_joy": "XD",
        "thinking_face": "(._.)",
        "winking_face": "(^_~)",
        "thumbs_up": "(b^_^)b"
    }
    # 将 转化为ASCII表情 例如"grinning_face": ":D",

    dag_params = DefaultDagParams()
    # 检测文件
    monitor_file()
