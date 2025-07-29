import time
import json
import os
from functools import reduce

# 假设这些是你的全局变量等（根据你的实际代码补充/调整！）
thread_count = 0
chat_history = []
result_file_path = "result.json"
state_file_path = "state.txt"
processing_set = set()

# ----------------- 命令注册框架 -----------------
class CommandHandler:
    registry = {}

    @classmethod
    def register(cls, name):
        def wrapper(handler_cls):
            cls.registry[name] = handler_cls()
            return handler_cls
        return wrapper

    def handle(self, timestamp, player_name, command, message, say):
        raise NotImplementedError

# ----------------- 各命令逻辑 -----------------

def convert_pinyin_to_hanzi_with_preservation(msg, flag):
    # 你自己的实现
    return f"PinyinConverted({msg}, flag={flag})"

def deepseek(player_name, message, flag):
    # 你自己的实现
    return f"AIResult({player_name}, {message}, {flag})"

@CommandHandler.register("g_pinyin")
class GPinyinHandler(CommandHandler):
    def handle(self, timestamp, player_name, command, message, say):
        py_message = convert_pinyin_to_hanzi_with_preservation(message, True)
        return {"command": "pinyin", "py_message": py_message}

@CommandHandler.register("pinyin")
class PinyinHandler(CommandHandler):
    def handle(self, timestamp, player_name, command, message, say):
        py_message = convert_pinyin_to_hanzi_with_preservation(message, False)
        return {"py_message": py_message}

@CommandHandler.register("time")
class TimeHandler(CommandHandler):
    def handle(self, timestamp, player_name, command, message, say):
        py_message = time.strftime("%H:%M:%S")
        return {"py_message": py_message}

@CommandHandler.register("ai")
class AiHandler(CommandHandler):
    def handle(self, timestamp, player_name, command, message, say):
        py_message = deepseek(player_name, message, True)
        return {"py_message": py_message}

@CommandHandler.register("sum")
class SumHandler(CommandHandler):
    def handle(self, timestamp, player_name, command, message, say):
        args = (message or '').strip().split()
        if len(args) < 2:
            return {'py_message': "[SUM] 用法: sum 加|乘 数字 ..."}
        mode, numbers = args[0], args[1:]
        try:
            nums = list(map(float, numbers))
        except Exception:
            return {'py_message': "[SUM] 参数必须是数字"}
        if mode == "加":
            result = sum(nums)
            expr = '+'.join(str(int(x) if x.is_integer() else x) for x in nums)
            return {'py_message': f"[SUM] {expr}={result}"}
        elif mode == "乘":
            result = reduce(lambda a, b: a * b, nums, 1)
            expr = '*'.join(str(int(x) if x.is_integer() else x) for x in nums)
            return {'py_message': f"[SUM] {expr}={result}"}
        else:
            return {'py_message': "[SUM] 只支持 '加' 或 '乘'"}

# ========== 主分发入口 ==========
def process_entry(timestamp, player_name, command, message, say):
    global thread_count
    start_time = time.time()
    start_strftime = time.strftime("%H:%M:%S")
    print(f"[XDlog] {start_strftime} Begin: {player_name}: {command} {message}")

    py_message = ""
    is_none_func = False

    if command == "new_chat":
        chat_history.clear()
        return

    thread_count += 1
    handler = CommandHandler.registry.get(command)
    if handler:
        try:
            result = handler.handle(timestamp, player_name, command, message, say)
            py_message = result.get("py_message", "")
            command = result.get("command", command)
        except Exception as e:
            print(f"命令[{command}]处理出错: {e}")
            is_none_func = True
    else:
        print(f"无此方法 {command}")
        is_none_func = True

    end_time = time.time()
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
        if not is_none_func:
            print(f"[XDlog] \n {command} 返回为空 \n")

    thread_count -= 1
    if thread_count == 0:
        with open(state_file_path, 'w', encoding='utf-8') as f:
            f.write("0")
    processing_set.discard((timestamp, player_name))  # 用discard更安全

# ========== 示例测试 ==========
if __name__ == "__main__":
    # 示例如何调用
    ts = time.time()
    process_entry(ts, "player1", "sum", "加 1 2 3", "")
    process_entry(ts, "player1", "sum", "乘 2 3 4", "")
    process_entry(ts, "player1", "g_pinyin", "hello world", "")
    process_entry(ts, "player1", "ai", "你好", "")
    process_entry(ts, "player2", "time", "", "")
    process_entry(ts, "player3", "new_chat", "", "")
    process_entry(ts, "player4", "不存在命令", "", "")
