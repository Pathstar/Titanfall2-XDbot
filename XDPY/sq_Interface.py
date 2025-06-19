import random
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
from datetime import datetime, timedelta

chat_history_len = 5
save_history = True
AILimit = False


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
                case "server":
                    py_message = get_server(message[0], message[1])
                case "init":
                    py_message = next_half_or_full_hour_final()
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
        print(f"[XDlog] {end_strftime} Finish: {player_name}: {message} use: {process_time}\n{py_message}\n")
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
                                    if thread_count == 0:
                                        with open(state_file_path, 'w', encoding='utf-8') as f:
                                            f.write("1")

                        last_m_time = current_m_time
                except Exception as e:
                    print(f"{time.strftime('%H:%M:%S')} Failed to read JSON:", e)


def next_half_or_full_hour_final():
    now = datetime.now()
    # now = datetime(2024, 6, 30, 23, 40, 0)
    h, m = now.hour, now.minute
    if m < 30:
        next_time = now.replace(minute=30, second=0, microsecond=0)
        flag = False
    else:
        next_time = (now.replace(minute=0, second=0, microsecond=0) + timedelta(hours=1))
        flag = True
    seconds_to_next = int((next_time - now).total_seconds())
    # seconds_to_next = 0
    if flag:
        result_str = next_time.strftime("\x1b[33m%H:%M:%S\x1b[0m 整！")
    else:
        result_str = next_time.strftime("\x1b[33m%H:%M:%S\x1b[0m！")

    # 随机颜色
    color = random.choice(COLORS)

    # 判断是否为凌晨0点~6点
    if 0 <= next_time.hour < 6 and random.random() < 0.99:
        text_emoji = NIGHT_EMOJI
    else:
        text_emoji = random.choice(EMOJI_LIST)

    # 拼接输出
    result_str = f"{result_str}{color} {text_emoji}"

    return [result_str, seconds_to_next]


def preprocess_custom_words(text, pinyin_len_dict, fail_count_dict):
    # custom_keys_set = set(custom_dict.keys())
    # custom_keys_set = sorted(custom_dict.keys(), key=lambda x: custom_dict[x][1], reverse=True)
    pattern = re.compile(r'\b(' + '|'.join(map(re.escape, custom_dict)) + r')\b', flags=re.IGNORECASE)

    def replacement(match):
        pinyin = match.group()
        pinyin_lower = pinyin.lower()
        if pinyin_lower in custom_dict:
            values = custom_dict[pinyin_lower]
            fail_count_dict["count"] -= 1
            pinyin_len_dict["count"] += values[1]
            return values[0]
        return pinyin

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
            print(f"[Pinyin]: {result}")
            convert_pinyin_list(pinyin_list[L:], dag_params, topk, result, fail_count_dict)
            return

    fail_count_dict["count"] += 1
    result.append([pinyin_list[0]])
    convert_pinyin_list(pinyin_list[1:], dag_params, topk, result, fail_count_dict)


# 主转换函数，增加对混合不可转换拼音的回退处理
def convert_pinyin_to_hanzi_with_preservation(text, is_g_pinyin, topk=1):
    # 预处理自定义词
    fail_count_dict = {"count": 0}
    pinyin_len_dict = {"count": 0}
    text = preprocess_custom_words(text, pinyin_len_dict, fail_count_dict)

    tokens = re.findall(r"[a-z]+(?: [a-z]+)*|[^\sa-z]+|\s+", text, flags=re.IGNORECASE)
    result = []

    for token in tokens:
        stripped = token
        if stripped:
            pinyin_list = stripped.split()
            # pinyin_list = split_pinyin_with_filter(stripped)
            pinyin_len_dict["count"] += len(pinyin_list)
            convert_pinyin_list(pinyin_list, dag_params, topk, result, fail_count_dict)

    fail_count = fail_count_dict["count"]
    print(f"[XDlog] fail_count: {fail_count} pinyin_len: {pinyin_len_dict['count']}")
    if is_g_pinyin:
        if fail_count >= pinyin_len_dict["count"] / 2:
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
            "content": "你是一个聊天机器人，处在non-thinking(enable_thinking=False)模式。请快速响应，不进行深度思考，直接回答问题，并准守以下规则：1.请严格限制回答字数在 160 字以内，省略思考过程；理性的问题请保证专业与准确性；感性的问题请高情商回答，富有感情和温暖。2.字符编码环境仅限最基本的符号，请使用ASCII字符；user的话包括name(中括号内是玩家的前缀，后面是玩家名字)、content(玩家的问题)"
        },
        {
            "role": "user",
            "content": f"name: {name}, content: {message}"
        }
    ]
    messages.extend(chat_history)
    data = ""
    try:
        response = requests.post(
            url="https://openrouter.ai/api/v1/chat/completions",
            headers={
                "Authorization": Auth,
                "Content-Type": "application/json",
            },
            data=json.dumps({
                # "model": "deepseek/deepseek-r1:free",
                # "model": "qwen/qwen3-14b:free",
                # "model": "qwen/qwen3-4b:free",
                "model": "qwen/qwen-2.5-7b-instruct:free",
                "messages": messages,
                "enable_thinking": False,
                "temperature": 1.4,
                "max_tokens": 512
            })
        )
        data = response.json()
    except requests.exceptions.Timeout:
        print("请求超时")
    except requests.exceptions.ConnectionError:
        print("网络连接错误")
    except requests.exceptions.HTTPError as err:
        print(f"HTTP错误: {err}")
    except requests.exceptions.RequestException as err:
        print(f"请求异常: {err}")

    print(data)
    print("---\n")
    try:
        content = data['choices'][0]['message']['content']
    except KeyError:
        print("AI响应发生错误: 'data' 结构中缺少所需的键！")
        if AILimit:
            return ["AI响应发生错误: 到达每日限额...TvT"]
        AILimit = True
        print(f"\n\n\n\n\n\n\n\n\n\nReach First API Limit 第一个号超出限额\n\n")
        max_retries = 3
        retries = 0
        while retries < max_retries:
            content = deepseek(name, message, False)
            if content:
                return content
            retries += 1
            print(f"响应发生错误重试 {retries}/{max_retries}...")
        return ["重试3次后失败..."]

    except IndexError:
        return ["AI响应发生错误: 'choices' 列表索引超出范围！"]
    except Exception as e:
        print(f"AI响应发生错误: {e}")
        return [f"AI响应发生错误: {e.__class__.__name__}"]

    if content:
        content = split_string_limited(content)
        if save_history:
            chat_history.append({"role": "assistant", "content": content})
            if len(chat_history) > chat_history_len:
                chat_history.pop(0)  # 确保对话历史不会无限增长
        return content
    else:
        print("[XDlog] 返回为空重试...")
        content = deepseek(name, message, False)
        if content:
            return content
        else:
            return ["AI重试响应后失败..."]


def split_string_limited(s, max_length=244):
    """优化后的字符串分割方法，转换非 ASCII 字符和 emoji，同时限制长度"""
    s = s.replace("\n", "").replace("\r", "")  # 去除换行符

    # 先转换非 ASCII 字符和 emoji
    s = emoji_to_ascii(s)
    s = convert_non_ascii_except_chinese(s)

    current_length = 0
    temp_list = []
    result = []
    # exceeded_once = False  # 标记是否已经超出一次

    for char in s:
        char_length = 3 if char in chinese_chars else 1
        if current_length + char_length > max_length:
            # if exceeded_once:  # 如果已经超出一次，则返回空字符串
            #     return ""
            result.append(''.join(temp_list))
            temp_list = [char]
            current_length = char_length
            # exceeded_once = True  # 标记已超出
        else:
            temp_list.append(char)
            current_length += char_length

    if temp_list:
        result.append(''.join(temp_list))

    print("[XDlog] 长度: ", " ".join(str(len(substring)) for substring in result))
    return result


# 判断是否为中文字符
def is_chinese(char):
    return '\u4e00' <= char <= '\u9fff'


# 非 ASCII 转换（保留中文）
def convert_non_ascii_except_chinese(text):
    return ''.join(char if char in chinese_chars or ord(char) < 128 else unidecode(char) for char in text)


# Emoji 转换
def emoji_to_ascii(text):
    emoji_text = emoji.demojize(text)  # 将 emoji 转为名称
    print(f"[XDlog] emoji: {emoji_text}")
    for key, val in emoji_map.items():
        emoji_text = emoji_text.replace(f":{key}:", val)
    return emoji_text


def filter_data(servers):
    filtered_data = []
    for server in servers:
        #                         pvp 军备竞赛 freeforall ？      ？     单挑       泰坦混战 幽灵猎杀
        if (server["playlist"] in ["ps", "gg", "ffa", "fra", "mfd", "coliseum", "tffa", "hidden"]
                and server["name"] not in [
                    "[CN]坏逼们的服务器 #基于KD越高越容易丢子弹的萌新服",
                    "[萌新专用]KD高踢出KD低加血-半夜咳嗽狼萌新服",
                    "[NSCN] 北极星CN官方18k空速铁对铁#1",
                    "[CN]坏逼们的服务器#超机动铁对铁",
                    "[CN]坏逼们的服务器#感染军团对战 <ZDJ>",
                    "[CN]坏逼们的服务器#恐怖炸猪人",
                    "【超好玩】技能狂",
                    "【超好玩】透视自瞄",
                    "【超好玩】9级帝王混战"

                    # 【超好玩】纯净版消耗战 【超好玩】技能狂 【超好玩】狙击战,超级机动铁驭 [摸鱼服]摸了
                ]  # and server["ip"] not in ["134.175.88.218", "110.42.38.53", "110.42.51.209", "101.43.230.80"]
        ):
            filtered_data.append({
                "playerCount": server["playerCount"],
                "name": server["name"]
            })
    return filtered_data


def get_server(query_type, message):
    try:
        global last_get_server_time
        file_name = "servers.json"
        filtered_data = []
        # test = False
        current_time = time.time()
        if current_time - last_get_server_time > 15:
            last_get_server_time = current_time
            response = requests.get("https://nscn.wolf109909.top/client/servers")
            servers = response.json()
            with open(file_name, "w") as file:
                json.dump(servers, file, indent=4)
                # json.dump(servers, file)
                print("[XDlog] Get服务器...")
                # print("\n\n\nget\n\n\n")
        else:
            with open(file_name, "r") as file:
                servers = json.load(file)
                print("[XDlog] 内存读取...")
                # test = True
        match query_type:
            case "mode" | "模式":
                cleaned_data = filter_server_mod(servers, message)
                if not cleaned_data:
                    return f"查询模式 [{message}] 未找到有人的服务器"
                filtered_data = sorted(
                    (item for item in cleaned_data),
                    key=lambda item: (-item['playerCount'], item['name'])
                )
            case "name" | "名称" | "名字":
                cleaned_data = filter_name_mod(servers, message)
                if not cleaned_data:
                    return f"查询名称 [{message}] 未找到有人的服务器"
                else:
                    if len(cleaned_data) == 1 and cleaned_data[0]['playerCount'] == 0:
                        return f"现在没有任何人！-> {cleaned_data[0]['name']}"
                filtered_data = sorted(
                    (item for item in cleaned_data if item['playerCount'] != 0),
                    key=lambda item: (-item['playerCount'], item['name'])
                )
        # if test:
        #     filtered_data.append({
        #         "playerCount": -1,
        #         "name": "内存读取"
        #     })
        if not filtered_data:
            return ""
        else:
            return filtered_data
    except Exception as e:
        print(e)
        return f"Get NS服务器错误: {e.__class__.__name__}"


def filter_server_mod(servers, message):
    filtered_data = []
    match message:
        case "xd":
            xd_banned_names = {
                "[CN]坏逼们的服务器 #基于KD越高越容易丢子弹的萌新服",
                "[萌新专用]KD高踢出KD低加血-半夜咳嗽狼萌新服",
                "[NSCN] 北极星CN官方18k空速铁对铁#1",
                "[CN]坏逼们的服务器#超机动铁对铁",
                "[CN]坏逼们的服务器#感染军团对战 <ZDJ>",
                "[CN]坏逼们的服务器#恐怖炸猪人",
                "【超好玩】技能狂",
                "【超好玩】透视自瞄",
                "【超好玩】9级帝王混战"
            }
            xd_playlists = {"ps", "gg", "ffa", "fra", "mfd", "coliseum", "tffa", "hidden"}
            for server in servers:
                name = server["name"]
                playlist = server["playlist"]
                player_count = server["playerCount"]
                if (
                        playlist in xd_playlists and
                        name not in xd_banned_names and
                        player_count != 0
                ):
                    filtered_data.append({
                        "playerCount": player_count,
                        "name": name
                    })
            return filtered_data
        case "xdall":
            for server in servers:
                player_count = server["playerCount"]
                if player_count != 0:
                    filtered_data.append({
                        "playerCount": player_count,
                        "name": server["name"]
                    })
            return filtered_data
    # 普通模式分支
    for server_key in trans_to_gamemode:
        if message in server_key:
            filtered_list = trans_to_gamemode[server_key]
            break
    else:
        # message不在server_key里，playlist直接查找
        for server in servers:
            playlist = server["playlist"]
            player_count = server["playerCount"]
            if message in playlist and player_count != 0:
                filtered_data.append({
                    "playerCount": player_count,
                    "name": server["name"]
                })
        return filtered_data
    flist_set = set(filtered_list)
    for server in servers:
        playlist = server["playlist"]
        player_count = server["playerCount"]
        if playlist in flist_set and player_count != 0:
            filtered_data.append({
                "playerCount": player_count,
                "name": server["name"]
            })
    return filtered_data


def filter_name_mod(servers, message):
    # 预处理关键词，只保留非空字符串，全部转小写
    keywords = [kw for kw in message.lower().split() if kw]
    if len(keywords) > 9:
        return [{"playerCount": -1, "name": "参数最多支持8个"}]
    filtered_data = []
    # 按长度降序排，避免短关键词被包含在长关键词里导致重叠
    keywords.sort(key=len, reverse=True)
    for server in servers:
        name = server["name"]
        name_lower = name.lower()
        # 检查所有关键词都包含
        if any(kw in name_lower for kw in keywords):
            # 生成高亮的name（不会用正则，每次尽量长关键词优先匹配）
            highlight = []
            i = 0
            N = len(name)
            while i < N:
                match = None
                for kw in keywords:
                    lkw = len(kw)
                    if lkw == 0:
                        continue
                    if name_lower[i:i + lkw] == kw:
                        match = lkw
                        break
                if match:
                    highlight.append('\x1b[33m')
                    highlight.append(name[i:i + match])
                    highlight.append('\x1b[0m')
                    i += match
                else:
                    highlight.append(name[i])
                    i += 1
            filtered_data.append({
                "playerCount": server["playerCount"],
                "name": ''.join(highlight)
            })
    return filtered_data


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
last_get_server_time = 0

processing_set = set()
thread_count = 0
chat_history = []

# 彩色列表
COLORS = [
    "\033[38;2;254;208;175m",
    "\033[38;2;135;206;235m",
    "\033[38;2;240;128;128m",
    "\033[38;2;175;238;238m",
    "\033[38;2;254;219;193m",
    "\033[38;2;216;191;216m",
    "\033[38;2;144;238;144m",
    "\033[38;2;205;214;210m",
    "\033[38;2;221;160;221m",
    "\033[38;2;248;131;121m",
    "\033[38;2;254;198;195m",
    "\033[38;2;194;245;194m",
    "\033[38;2;173;216;230m",
    "\033[38;2;254;250;195m",
    "\033[38;2;199;245;190m"
]
EMOJI_LIST = [
    "(≧▽≦)/", "(=^･ω･^=)", "(｡>ω<｡)", "(｡>﹏<｡)",
    "～(つˆДˆ)つ", "(｀・ω・´)", "(ﾉ≧∀≦)ﾉ"
]
NIGHT_EMOJI = "(。-ω-)zzz"
# 转拼音 初始化模型参数
custom_dict = {
    "meng xin lei mu": ("萌新泪目", 3),
    "meng xin qiu dai": ("萌新求带", 3),

    "zhong li xing": ("重力星", 2),
    "fei huo xing": ("飞火星", 2),
    "dian zi yan": ("电子烟", 2),
    "mai chong dao": ("脉冲刀", 2),
    "zhuan huan zhe": ("转换者", 2),
    "ke lai bo": ("克莱博", 2),
    "yang lao fu": ("养老服", 2),
    "meng xin fu": ("萌新服", 2),

    "zhuan pin yin": ("转拼音", 2),
    "zhuan wen zi": ("转文字", 2),
    "yue lai yue": ("越来越", 2),
    "zhun que lv": ("准确率", 2),

    "zhong li": ("重力", 1),
    "nie lei": ("捏雷", 1),
    "dian yan": ("电烟", 1),
    "di lei": ("地雷", 1),
    "ji su": ("激素", 1),
    "yin shen": ("隐身", 1),
    "gou zhua": ("钩爪", 1),
    "han luo": ("汗洛", 1),
    "dian chong": ("电冲", 1),
    "dian bi": ("电笔", 1),
    "zi beng": ("滋嘣", 1),
    "a dun": ("А盾", 1),
    "adun": ("А盾", 1),
    "c dun": ("Ϲ盾", 1),
    "cdun": ("Ϲ盾", 1),
    "r101": ("Ŕ301", 1),
    "r201": ("Ŕ201", 1),
    "r301": ("Ŕ101", 1),
    "r97": ("Ŕ97", 1),
    "p2016": ("Р2016", 1),
    "re45": ("ŔЕ45", 1),
    "l star": ("LStar", 1),
    "zha nan": ("扎男", 1),
    "li zi": ("离子", 1),
    "lang ren": ("浪人", 1),
    "lang meng": ("狼萌", 1),
    "meng xin": ("萌新", 1),
    "huai xiao": ("坏小", 1),
    "ma le": ("马了", 1),

    "da yue": ("大约", 1),
    "bu que": ("不缺", 1),
    "que que": ("确确", 1),
    "zhu que": ("准确", 1),
    "ming que": ("明确", 1),
    "zhun que": ("准确", 1),
    "que bao": ("确保", 1),
    "que fa": ("缺乏", 1),
    "que shao": ("缺少", 1),
    "que shi": ("确实", 1),
    "que qie": ("确切", 1),
    "que de": ("缺德", 1),
    "que xi": ("缺席", 1),
    "que qin": ("缺勤", 1),
    "que wei": ("缺位", 1),
    "que yi": ("缺一", 1),

    "xi yue": ("喜悦", 1),
    "yin yue": ("音乐", 1),
    "yue ding": ("约定", 1),
    "yue du": ("阅读", 1),
    "yue er": ("悦耳", 1),
    "yue fen": ("月份", 1),
    "yue guo": ("越过", 1),
    "yue jin": ("跃进", 1),
    "yue jie": ("越界", 1),
    "yue lai": ("越来", 1),
    "yue liang": ("月亮", 1),
    "yue mu": ("悦目", 1),
    "yue shu": ("约束", 1),
    "yue yu": ("越狱", 1),
    "yue yue": ("跃跃", 1),

    "cao": ("草", 0),
    "ya": ("呀", 0),

    "que": ("却", 0),
    "yue": ("月", 0)

}
# Ϲ 希腊字母
# АВ ДЕFGНІЈКLМNОРQ ЅТUVWХYZ 西里尔字母
# ＡＢＣＤＥＦＧＨＩＪＫＬＭＮＯＰＱＲＳＴＵＶＷＸＹＺ 全角拉丁字母（Fullwidth Latin Letters）
# input_text = "Á B́ Ć D́ É F́ Ǵ H́ Í J́ Ḱ Ĺ Ḿ Ń Ó Ṕ Q́ Ŕ Ś T́ Ú V́ Ẃ X́ Ý Ź" 拉丁大写字母带锐音符 抑扬符 ААᎪ𝔸 Č
# input_text = "zhong li xing.ΑААᎪ𝔸 tai tan dian yan dian zi yan С LStar Ŕ97 chong feng qiang dian bi liu dan ke lai bo"
# input_text = "mai chong dao ji su yin shen gou zhua fen shen shuang chong san chong"
# input_text = "li zi lie yan qiang li lang ren jun tuan di wang bei ji xing yang lao fu wu qi"

# Emoji 映射表
emoji_map = {
    "slightly_smiling_face": ":)",
    "smiling_face_with_smiling_eyes": "0v0",
    "grinning_face": ":D",
    "smiling_face_with_hearts": "(^▽^)",
    "face_with_tears_of_joy": "XD",
    "thinking_face": "(._.)",
    "winking_face": "(^_~)",
    "thumbs_up": "(b^_^)b"
}
chinese_chars = set("，。？！（）【】、；：") | set(chr(i) for i in range(0x4E00, 0x9FFF))
# 将 转化为ASCII表情 例如"grinning_face": ":D",

trans_to_gamemode = {
    "铁对铁pvp": ["ps", "gg", "ffa", "fra", "mfd", "coliseum", "hidden"],
    "泰坦争斗ttdm": ["tffa", "ttdm"],
    "消耗战att": ["aitdm"],
    "边境防御": ["fd_easy", "fd_normal", "fd_hard", "fd_insane", "fd_master", "private_match"],
    "边境防御简单边境": ["fd_easy"],
    "边境防御普通边境防御一般": ["fd_normal"],
    "边境防御困难": ["fd_hard"],
    "边境防御疯狂": ["fd_insane"],
    "边境防御大师": ["fd_master"]
}

dag_params = DefaultDagParams()

if __name__ == "__main__":
    
    # 检测文件
    monitor_file()
