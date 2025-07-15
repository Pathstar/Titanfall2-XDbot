from datetime import datetime, timedelta
import emoji
import json
import os
from Pinyin2Hanzi import dag, DefaultDagParams
from pypinyin import lazy_pinyin
import random
import re
import requests
import time
import threading
from unidecode import unidecode
import win32file
import win32con

# pip install emoji Pinyin2Hanzi pywin32 pypinyin requests unidecode

chat_history_len = 6
save_history = True
AI_limit = False


def process_entry(timestamp, player_name, command, message, say):
    """Process a new entry asynchronously."""
    if command == "no_return":
        match message:
            case "new_chat":
                # chat_history = []
                chat_history.clear()
            case _:
                print(f"无此参数 {message}")
        print(f"[XDlog] {time.strftime('%H:%M:%S')} | {player_name} : {message}")
        return

    global thread_count, thread_index
    if thread_count == 0:
        with open(state_file_path, 'w', encoding='utf-8') as f:
            f.write("1")
    start_time = time.time()
    start_strftime = time.strftime("%H:%M:%S")
    # print(f"{start_strftime} Begin: {player_name}: {command}" + (f"\n{message}" if message else ""))
    print(f"[XDlog] {start_strftime} Begin {command} | {player_name} : {message}")
    is_func = True
    py_message = ""
    thread_count += 1
    match command:
        case "init":
            py_message = next_half_or_full_hour_final()
        case "g_pinyin":
            py_message = pinyin2hanzi_converter.pinyin_groups_to_chinese(message, True)
            command = "pinyin"
            is_func = False
        case "time":
            py_message = time.strftime("%H:%M:%S")
        case "ai":
            py_message = deepseek(player_name, message, True)
        case "server":
            py_message = get_server(message[0], message[1])
        case "pinyin_add":
            py_message = pinyin2hanzi_converter.add_pinyin_mapping(message)
        case "pinyin_del":
            py_message = pinyin2hanzi_converter.del_pinyin_mapping(message)
        case "pinyin":
            py_message = pinyin2hanzi_converter.pinyin_groups_to_chinese(message, False)
        case _:
            print(f"无此方法 {command}")
            is_func = False

    end_time = time.time()
    # process_time = round(end_time - start_time, 1)
    process_time = end_time - start_time
    thread_index += 1
    result_data = {f"{end_time}_{thread_index}": {player_name: {
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

    except Exception as e:
        print("[XDlog] Failed to update result JSON:", e)

    thread_count -= 1
    if thread_count == 0:
        with open(state_file_path, 'w', encoding='utf-8') as f:
            f.write("0")
    processing_set.remove((timestamp, player_name))
    end_strftime = time.strftime("%H:%M:%S")
    print(f"[XDlog] {end_strftime} Finish {command} | {player_name} : {message} | Result: {py_message} | Used: {process_time}\n")

    if py_message == "" and is_func:
        print(f"[XDlog] Error {command} 命令返回为空 \n")


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
    print(f"{time.strftime('%H:%M:%S')} Monitoring Squirrel Messages...")

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

                        last_m_time = current_m_time
                except Exception as e:
                    print(f"{time.strftime('%H:%M:%S')} Failed to read JSON: ", e)


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
        text_emoji = "(。-ω-)zzz"
    else:
        text_emoji = random.choice(EMOJI_LIST)

    # 拼接输出
    result_str = f"{result_str}{color} {text_emoji}"

    return [result_str, seconds_to_next]


# 转拼音：
def simple_replace(text, replace_dict):
    pattern = re.compile("|".join(re.escape(k) for k in replace_dict))
    return pattern.sub(lambda m: replace_dict[m.group(0)], text)


class PinyinChineseConverter:
    def __init__(self, c_pinyin_syllables, c_uv_pinyin_list, c_dag_params, c_custom_dict, c_block_words,
                 c_temp_pinyin_dict_path):
        self.pinyin_syllables = c_pinyin_syllables
        self.uv_pinyin_list = c_uv_pinyin_list
        self.dag_params = c_dag_params
        self.block_words = c_block_words
        self.temp_pinyin_dict_path = c_temp_pinyin_dict_path
        self.temp_pinyin_dict = {}
        self.load_temp_pinyin_dict()
        self.basic_dict = c_custom_dict
        self.custom_dict = c_custom_dict | self.temp_pinyin_dict

    def reload_dict(self):
        self.custom_dict = self.basic_dict | self.temp_pinyin_dict

    def load_temp_pinyin_dict(self):
        if os.path.exists(self.temp_pinyin_dict_path):
            try:
                with open(self.temp_pinyin_dict_path, 'r', encoding='utf-8') as f:
                    data = json.load(f)
                    d = data.get("temp_pinyin_dict", {})
                    if not isinstance(d, dict):
                        print("警告：temp_pinyin_dict不是一个字典对象，已重置为空字典。")
                        self.temp_pinyin_dict = {}
                    else:
                        self.temp_pinyin_dict = d
                return True
            except Exception as e:
                print(f"加载temp_pinyin_dict时出现异常: {e}，已重置为空字典。")
                self.temp_pinyin_dict = {}
                return False
        else:
            self.temp_pinyin_dict = {}
            return False

    def save_temp_pinyin_dict(self):
        with open(self.temp_pinyin_dict_path, 'w', encoding='utf-8') as f:
            json.dump({"temp_pinyin_dict": self.temp_pinyin_dict}, f, ensure_ascii=False, indent=4)

    # 读入已有 temp_pinyin_dict

    def add_pinyin_mapping(self, s):
        s = s.strip()
        # 查找第一个汉字
        for idx, c in enumerate(s):
            is_h_cmd = False
            if c == "-" and s[idx+1] == "h":
                is_h_cmd = True
            if is_chinese(c) or is_h_cmd:
                pinyin_raw = s[:idx].rstrip()
                pin = ' '.join(pinyin_raw.split())
                if pin in self.temp_pinyin_dict:
                    str_dict = f"\"{pin}\": \"{self.temp_pinyin_dict[pin]}\""
                    print(f"[Pinyin Add] Conflict {str_dict}")
                    return f"已有: {str_dict}"
                elif pin in self.basic_dict:
                    str_dict = f"\"{pin}\": \"{self.basic_dict[pin]}\""
                    print(f"[Pinyin Add] Conflict {str_dict}")
                    return f"已有 (受保护): {str_dict}"
                else:
                    hz = s[idx + 2:].lstrip() if is_h_cmd else s[idx:]
                    self.temp_pinyin_dict[pin] = hz
                    self.custom_dict[pin] = hz
                    self.save_temp_pinyin_dict()
                    str_dict = f"\"{pin}\": \"{hz}\""
                    print(f"[Pinyin Add] Success {str_dict}")
                    return f"添加成功: {str_dict}"
        print(f"[Pinyin Add] Fail 未找到中文 {s}")
        return f"添加拼音失败：未找到中文 {s}"

    def del_pinyin_mapping(self, s):
        s = s.strip()
        # 只处理拼音部分，忽略后面是否有汉字
        pin = ' '.join(s.split())
        if pin in self.temp_pinyin_dict:
            hz = self.temp_pinyin_dict[pin]
            del self.temp_pinyin_dict[pin]
            del self.custom_dict[pin]
            self.save_temp_pinyin_dict()
            str_dict = f"\"{pin}\": \"{hz}\""
            print(f"[Pinyin Del] Success {str_dict}")
            return f"已删除: {str_dict}"
        elif pin in self.basic_dict:
            str_dict = f"\"{pin}\": \"{self.basic_dict[pin]}\""
            print(f"[Pinyin Del] Protect Fail {str_dict}")
            return f"无法删除 (受保护): {str_dict}"
        else:
            print(f"[Pinyin Del] Fail \"{pin}\"")
            return f"没有找到拼音 \"{pin}\"，无法删除"
        # unreachable
        # return "del_pinyin_mapping unreachable"

    def is_pinyin_syllable(self, word):
        return word.lower() in self.pinyin_syllables

    def split_text_by_pinyin_group(self, text):
        """
        第一步，将文本按拼音组切分，True是拼音组，False是原文
        """
        tokens = re.findall(r'[A-Za-z]+|\s+|[^A-Za-z\s]+', text)
        res = []
        i = 0
        n = len(tokens)
        while i < n:
            if tokens[i].isalpha() and self.is_pinyin_syllable(tokens[i]):
                py_group = [tokens[i].lower()]
                i += 1
                while i + 1 < n and tokens[i].isspace() and tokens[i + 1].isalpha() and self.is_pinyin_syllable(
                        tokens[i + 1]):
                    py_group.append(tokens[i + 1].lower())
                    i += 2
                res.append([True, py_group])
            else:
                buf = tokens[i]
                i += 1
                while i < n and not (tokens[i].isalpha() and self.is_pinyin_syllable(tokens[i])):
                    buf += tokens[i]
                    i += 1
                if res and res[-1][0] and buf and buf[0].isspace():
                    buf = buf[1:]
                if i < n and tokens[i].isalpha() and self.is_pinyin_syllable(tokens[i]) and buf and buf[-1].isspace():
                    buf = buf[:-1]
                if buf:
                    res.append([False, buf])
        return res

    def pinyin_group_to_chinese_candidates(self, pinyin_list, topk, result, fail_count_dict):
        """
        第二步，拼音组转成中文（递归、最大匹配）
        """
        if len(pinyin_list) == 0:
            return
        for L in range(len(pinyin_list), 0, -1):
            prefix = pinyin_list[:L]
            lowercase_prefix = [word.lower() for word in prefix]
            dag_results = dag(self.dag_params, lowercase_prefix, path_num=topk)
            print(f"[Pinyin] Loop {lowercase_prefix}")
            if dag_results:
                cand = dag_results[0].path
                result.append(cand)
                print(f"[Pinyin] Success {cand}")
                self.pinyin_group_to_chinese_candidates(pinyin_list[L:], topk, result, fail_count_dict)
                return

        print(f"[Pinyin] Fail {pinyin_list}")
        fail_count_dict["count"] += 1
        result.append([pinyin_list[0]])
        self.pinyin_group_to_chinese_candidates(pinyin_list[1:], topk, result, fail_count_dict)

    # intentionally not static
    def tokenize_with_pinyin_and_span(self, text):
        """
        第三步，转文字后进行转拼音为自定义词典做准备
        """
        tokens = []
        spans = []
        n = len(text)
        i = 0
        while i < n:
            c = text[i]
            if '\u4e00' <= c <= '\u9fff':
                py = lazy_pinyin(c)[0]
                tokens.append(py)
                spans.append((i, i + 1))
                i += 1
            else:
                j = i
                while j < n and not ('\u4e00' <= text[j] <= '\u9fff'):
                    j += 1
                tokens.append(text[i:j])
                spans.append((i, j))
                i = j
        print(f"[Pinyin] Custom {tokens}")
        return tokens, spans

    def custom_dict_replace(self, text, fail_count_dict):
        """
        第四步，在拼音串查找并替换自定义拼音短语
        """
        tokens, spans = self.tokenize_with_pinyin_and_span(text)
        n = len(tokens)
        out = []
        i = 0
        max_len = max(len(k) for k in self.custom_dict)
        while i < n:
            hit = False
            for L in range(min(max_len, n - i), 0, -1):
                phrase = ' '.join(tokens[i:i + L])
                if phrase in self.custom_dict:
                    value = self.custom_dict[phrase]
                    if isinstance(value, tuple):
                        rep = value[0]
                        minus = value[1]
                        # minus = value[1] if len(value) > 1 else None
                    else:
                        rep = value
                        minus = None
                    out.append(rep)
                    if minus:
                        fail_count_dict["count"] -= minus
                    i += L
                    hit = True
                    break
            if not hit:
                s, e = spans[i]
                out.append(text[s:e])
                i += 1
        return ''.join(out)

    def pinyin_groups_to_chinese(self, text, is_strict_mode, topk=1):
        """
        主流程：拼音组转最终中文
        """

        final_result = []
        fail_count_dict = {"count": 0}
        pinyin_len = 0
        pinyin_groups = self.split_text_by_pinyin_group(text)
        for is_pinyin_group, content in pinyin_groups:
            if is_pinyin_group:  # 转拼音
                result = []
                content = [self.uv_pinyin_list.get(p, p) for p in content]
                self.pinyin_group_to_chinese_candidates(content, topk, result, fail_count_dict)
                for chinese_part in result:
                    final_result.append(''.join(chinese_part))
                pinyin_len += len(content)
            else:
                pinyin_len += 1
                fail_count_dict["count"] += 1
                final_result.append(content)

        final_result_str = ''.join(final_result)
        process_result = self.custom_dict_replace(final_result_str, fail_count_dict)
        # 最后屏蔽词过滤
        process_white_result = simple_replace(process_result, self.block_words)
        fail_count = fail_count_dict["count"]
        print(f"[Pinyin] Count Fail/All: {fail_count}/{pinyin_len}")
        if is_strict_mode:
            if fail_count >= pinyin_len / 2.0:
                print(f"[Pinyin] Failed to Convert: {text}")
                return ""
        return process_white_result


# deepseek
def deepseek(name, message, is_success):
    global AI_limit, chat_history
    if AI_limit:
        auth = "Bearer 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"
    else:
        auth = "Bearer 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"
    if save_history:
        if is_success:
            chat_history.append({"role": "user", "content": f"name: {name}, content: {message}"})
            if len(chat_history) > chat_history_len:
                chat_history = chat_history[1:]

    messages = chat_history + [
        {
            "role": "system",
            "content": "你处于一个聊天群中，且在non-thinking(enable_thinking=False)模式，请快速响应，不进行深度思考，直接回答问题，并准守以下规则：1.请严格限制回答字数在 "
                       "160 字以内，省略思考过程；理性的问题请保证专业与准确性；感性的问题请高情商回答，富有感情和温暖。2.字符编码环境仅限最基本的符号，请使用ASCII字符；user的话包括name("
                       "中括号内是玩家的前缀，后面是玩家名字)、content(玩家的问题) "
        },
        {
            "role": "user",
            "content": f"name: {name}, content: {message}"
        }
    ]
    # messages.extend(chat_history)
    data = ""
    try:
        response = requests.post(
            url="https://openrouter.ai/api/v1/chat/completions",
            headers={
                "Authorization": auth,
                "Content-Type": "application/json",
            },
            data=json.dumps({
                # "model": "deepseek/deepseek-r1:free",
                # "model": "qwen/qwen3-14b:free",
                # "model": "qwen/qwen3-4b:free",
                # "model": "qwen/qwen-2.5-7b-instruct:free",
                # "model": "qwen/qwq-32b:free",
                # "model": "qwen/qwen3-8b:free",
                "model": "qwen/qwen3-30b-a3b:free",
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
        # content = data['choices'][0]['message']['content']
        content = data.choices[0].message.content
    except KeyError:
        print("AI响应发生错误: 'data' 结构中缺少所需的键！")
        if AI_limit:
            return ["AI响应发生错误: 到达每日限额...TvT"]
        AI_limit = True
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
                # chat_history.pop(0)  # 确保对话历史不会无限增长
                chat_history = chat_history[1:]
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
    # for key, val in emoji_map.items():
    #     emoji_text = emoji_text.replace(f":{key}:", val)
    pattern = re.compile("|".join(map(re.escape, emoji_map.keys())))
    emoji_text = pattern.sub(lambda m: emoji_map[m.group(0)], emoji_text)
    return emoji_text


def filter_data(servers):
    filtered_data = []
    for server in servers:
        #                         pvp 军备竞赛 free_for_all ？      ？     单挑       泰坦混战 幽灵猎杀
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
                    # and server["ip"] not in ["134.175.88.218", "110.42.38.53", "110.42.51.209", "101.43.230.80"]
                ]):
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
        if current_time - last_get_server_time > 10:
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
                    return f"查询模式 [{message}] 未找到任何服务器"
                filtered_data = sorted(
                    (item for item in cleaned_data),
                    key=lambda item: (-item['playerCount'], item['name'])
                )
                if cleaned_data and not filtered_data:
                    if len(cleaned_data) < 4:
                        filtered_data.append({'playerCount': -64, 'name': f'查询模式 [{message}] 未找到有人的服务器'})
                        filtered_data.extend(cleaned_data)
                    else:
                        return f"查询模式 [{message}] 未找到有人的服务器"
            case "name" | "名称" | "名字":
                cleaned_data = filter_name_mod(servers, message)
                # print("cleanedata")
                print(cleaned_data)
                # print("over")
                if not cleaned_data:
                    return f"查询名称 [{message}] 未找到任何服务器"
                else:
                    if len(cleaned_data) == 1 and cleaned_data[0]['playerCount'] == 0:
                        return f"现在没有任何人！-> {cleaned_data[0]['name']}"
                filtered_data = sorted(
                    (item for item in cleaned_data if item['playerCount'] != 0),
                    key=lambda item: (-item['playerCount'], item['name'])
                )
                if cleaned_data and not filtered_data:
                    if len(cleaned_data) < 4:
                        filtered_data.append({'playerCount': -64, 'name': f'查询模式 [{message}] 未找到有人的服务器'})
                        filtered_data.extend(cleaned_data)
                    else:
                        return f"查询模式 [{message}] 未找到有人的服务器"

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
thread_index = 0

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
# ☆★
EMOJI_LIST = [
    "(≧▽≦)/", "(=^･ω･^=)", "(｡>ω<｡)", "(｡>﹏<｡)",
    "～(つˆДˆ)つ", "(｀・ω・´)", "(ﾉ≧∀≦)ﾉ",
    "_(:з」∠)_", "(=・ω・=)", "_(≧v≦」∠)_", "(〜￣△￣)〜", "╮(￣▽￣)╭", "(・ω< )☆", "(^・ω・^)", "(｡･ω･｡)"
]


# NIGHT_EMOJI = "(。-ω-)zzz"
# 转拼音 初始化模型参数
def pinyin2hanzi_init():
    custom_dict = {
        "meng xin lei mu": "萌新泪目",
        "meng xin qiu dai": "萌新求带",

        "zhong li xing": "重力星",
        "fei huo xing": "飞火星",
        "dian zi yan": "电子烟",
        "mai chong dao": "脉冲刀",
        "zhuan huan zhe": "转换者",
        "ke lai bo": "克莱博",
        "yang lao fu": "养老服",
        "meng xin fu": "萌新服",

        "da fei jiao": "大飞脚",
        "huan dan ai": "换弹癌",
        "wo lei ge": "我嘞个",
        "zhuan pin yin": "转拼音",
        "zhuan wen zi": "转文字",
        "yue lai yue": "越来越",
        "zhun que lv": "准确率",

        "zhong li": "重力",
        "nie lei": "捏雷",
        "dian yan": "电烟",
        "di lei": "地雷",
        "ji su": "激素",
        "xiang wei": "相位",
        "yin shen": "隐身",
        "gou zhua": "钩爪",
        "han luo": "汗洛",
        "dian chong": "电冲",
        "dian bi": "电笔",
        "zi beng": "滋嘣",
        "a dun": "A盾",
        "adun": ("A盾", 2),
        "c dun": ("C盾", 1),
        "cdun": ("C盾", 2),
        "zha nan": "扎男",
        "li zi": "离子",
        "lang ren": "浪人",
        "lang meng": "狼萌",
        "meng xin": "萌新",
        "huai xiao": "坏小",

        "an dao": "按到",
        "ji ba": "几把",
        "hao ma": "好马",
        "huan dan": "换弹",
        "liu le": "溜了",
        "ma qiang": "马枪",
        "ma wan": "马完",
        "quan shi": "全是",
        "shou lei": "手雷",
        "tun zi dan": "吞子弹",
        "ye ma": "也马",
        "you kai": "又开",
        "you lai": "又来"

    }

    pinyin_syllables = {'a', 'ai', 'an', 'ang', 'ao', 'ba', 'bai', 'ban', 'bang', 'bao', 'bei', 'ben', 'beng', 'bi',
                        'bian', 'biao', 'bie', 'bin', 'bing', 'bo', 'bu', 'ca', 'cai', 'can', 'cang', 'cao', 'ce',
                        'cen', 'ceng', 'cha', 'chai', 'chan', 'chang', 'chao', 'che', 'chen', 'cheng', 'chi', 'chong',
                        'chou', 'chu', 'chuai', 'chuan', 'chuang', 'chui', 'chun', 'chuo', 'ci', 'cong', 'cou', 'cu',
                        'cuan', 'cui', 'cun', 'cuo', 'da', 'dai', 'dan', 'dang', 'dao', 'de', 'deng', 'di', 'dian',
                        'diao', 'die', 'ding', 'diu', 'dong', 'dou', 'du', 'duan', 'dui', 'dun', 'duo', 'e', 'en', 'er',
                        'fa', 'fan', 'fang', 'fei', 'fen', 'feng', 'fo', 'fou', 'fu', 'ga', 'gai', 'gan', 'gang', 'gao',
                        'ge', 'gei', 'gen', 'geng', 'gong', 'gou', 'gu', 'gua', 'guai', 'guan', 'guang', 'gui', 'gun',
                        'guo', 'ha', 'hai', 'han', 'hang', 'hao', 'he', 'hei', 'hen', 'heng', 'hong', 'hou', 'hu',
                        'hua', 'huai', 'huan', 'huang', 'hui', 'hun', 'huo', 'ji', 'jia', 'jian', 'jiang', 'jiao',
                        'jie', 'jin', 'jing', 'jiong', 'jiu', 'ju', 'juan', 'jue', 'jun', 'ka', 'kai', 'kan', 'kang',
                        'kao', 'ke', 'ken', 'keng', 'kong', 'kou', 'ku', 'kua', 'kuai', 'kuan', 'kuang', 'kui', 'kun',
                        'kuo', 'la', 'lai', 'lan', 'lang', 'lao', 'le', 'lei', 'leng', 'li', 'lia', 'lian', 'liang',
                        'liao', 'lie', 'lin', 'ling', 'liu', 'long', 'lou', 'lu', 'luan', 'lue', 'lun', 'luo', 'ma',
                        'mai', 'man', 'mang', 'mao', 'me', 'mei', 'men', 'meng', 'mi', 'mian', 'miao', 'mie', 'min',
                        'ming', 'miu', 'mo', 'mou', 'mu', 'na', 'nai', 'nan', 'nang', 'nao', 'ne', 'nei', 'nen', 'neng',
                        'ni', 'nian', 'niang', 'niao', 'nie', 'nin', 'ning', 'niu', 'nong', 'nou', 'nu', 'nuan', 'nue',
                        'nun', 'nuo', 'o', 'ou', 'pa', 'pai', 'pan', 'pang', 'pao', 'pei', 'pen', 'peng', 'pi', 'pian',
                        'piao', 'pie', 'pin', 'ping', 'po', 'pou', 'pu', 'qi', 'qia', 'qian', 'qiang', 'qiao', 'qie',
                        'qin', 'qing', 'qiong', 'qiu', 'qu', 'quan', 'que', 'qun', 'ran', 'rang', 'rao', 're', 'ren',
                        'reng', 'ri', 'rong', 'rou', 'ru', 'ruan', 'rui', 'run', 'ruo', 'sa', 'sai', 'san', 'sang',
                        'sao', 'se', 'sen', 'seng', 'sha', 'shai', 'shan', 'shang', 'shao', 'she', 'shen', 'sheng',
                        'shi', 'shou', 'shu', 'shua', 'shuai', 'shuan', 'shuang', 'shui', 'shun', 'shuo', 'si', 'song',
                        'sou', 'su', 'suan', 'sui', 'sun', 'suo', 'ta', 'tai', 'tan', 'tang', 'tao', 'te', 'teng', 'ti',
                        'tian', 'tiao', 'tie', 'ting', 'tong', 'tou', 'tu', 'tuan', 'tui', 'tun', 'tuo', 'wa', 'wai',
                        'wan', 'wang', 'wei', 'wen', 'weng', 'wo', 'wu', 'xi', 'xia', 'xian', 'xiang', 'xiao', 'xie',
                        'xin', 'xing', 'xiong', 'xiu', 'xu', 'xuan', 'xue', 'xun', 'ya', 'yan', 'yang', 'yao', 'ye',
                        'yi', 'yin', 'ying', 'yo', 'yong', 'you', 'yu', 'yuan', 'yue', 'yun', 'za', 'zai', 'zan',
                        'zang', 'zao', 'ze', 'zei', 'zen', 'zeng', 'zha', 'zhai', 'zhan', 'zhang', 'zhao', 'zhe',
                        'zhen', 'zheng', 'zhi', 'zhong', 'zhou', 'zhu', 'zhua', 'zhuai', 'zhuan', 'zhuang', 'zhui',
                        'zhun', 'zhuo', 'zi', 'zong', 'zou', 'zu', 'zuan', 'zui', 'zun', 'zuo',
                        'jve', 'lve', 'nve', 'qve', 'xve', 'yve'}

    uv_pinyin_list = {
        'jue': 'jve', 'lue': 'lve', 'nue': 'nve', 'que': 'qve', 'xue': 'xve', 'yue': 'yve'
    }

    block_words = {
        "操": "草",
        "妈": "马",

        "傻逼": "傻B",

        "码": "吗"
    }
    dag_params = DefaultDagParams()
    temp_pinyin_dict_path = 'temp/temp_dict.json'
    return PinyinChineseConverter(pinyin_syllables, uv_pinyin_list, dag_params, custom_dict, block_words,
                                  temp_pinyin_dict_path)


pinyin2hanzi_converter = pinyin2hanzi_init()
# Emoji 映射表
emoji_map = {
    ":slightly_smiling_face:": ":smiling_face_ovo:)",
    ":smiling_face_with_smiling_eyes": "0v0",
    ":grinning_face:": ":D",
    ":smiling_face_with_hearts:": "(^▽^)",
    ":face_with_tears_of_joy:": "XD",
    ":thinking_face:": "(._.)",
    ":winking_face:": "(^_~)",
    ":thumbs_up:": "(b^_^)b"
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


if __name__ == "__main__":
    # 检测文件
    monitor_file()
