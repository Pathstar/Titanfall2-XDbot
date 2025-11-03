import os
import json
import time

# json_file_path = r'D:\SystemApps\Steam\steamapps\common\Titanfall2\R2Northstar\save_data\Northstar.Client\XD.json'
# json_file_folder = os.path.dirname(json_file_path)

ttf_data_path = r'D:\SystemApps\Steam\steamapps\common\Titanfall2\R2Northstar\save_data\Northstar.Client'
result_file_path = os.path.join(ttf_data_path, 'py_XD.json')
# player_name = "Pathstar_XD"
# 
isHasPy_file_path = os.path.join(ttf_data_path, "data", "isHasPy.txt")

last_command = ""

# 检查文件是否存在，如果不存在则新建空JSON文件
# if not os.path.exists(json_file_folder):
#     os.makedirs(json_file_folder)
#     if not os.path.exists(json_file_path):
#         with open(json_file_path, 'w', encoding='utf-8') as f:
#             json.dump({}, f, indent=4)


# command = input("command: ")
# if command == "":
#     command = last_command
# else:
#     last_command = command
# # 读取原有内容
# with open(json_file_path, 'r', encoding='utf-8') as f:
#     try:
#         data = json.load(f)
#     except json.JSONDecodeError:
#         data = {}

# 生成本次要写入的数据
# new_entry = {
#     "player_name": player_name,
#     "command": "py_command",
#     "message": message,
#     "say": "say ",
#     "is_return": False,
#     "option": {},
#     "is_system": True
# }
is_system = True
say = True
player_name = "[Python]"


def send_command(command, cmd_type):
    global is_system, say, last_command
    # if command.startswith("t@xd"):
    #     command = command[5:].strip()
    # elif command.startswith("@xd"):
    #     command = command[4:].strip()

    if command == "/sys":
        is_system = not is_system
        print(f"is_system: {is_system}")
        return
    if command == "/say":
        say = not say
        print(f"say: {'say ' if say else 'say_team '}")
        return

    if command.strip() == "":
        command = last_command
    else:
        last_command = command

    result_data = {f"{time.time()}_0": {player_name: {
        "is_over": True,
        "command": cmd_type,
        # "message": message,
        "pyMessage": command,
        "say": "say " if say else "say_team ",
        # "process_time": -1,
        "is_system": is_system
    }}}

    try:
        with open(result_file_path, 'r', encoding='utf-8') as f:
            existing_data = json.load(f)
        existing_data.update(result_data)
        with open(result_file_path, 'w', encoding='utf-8') as f:
            # noinspection PyTypeChecker
            json.dump(existing_data, f, ensure_ascii=False, indent=4)
        print(f"已写入：{json.dumps(existing_data, indent=4, ensure_ascii=False)}")
        
        with open(isHasPy_file_path, 'w') as f:
            pass  # 不写入任何内容，保持为空
    except FileNotFoundError:
        with open(result_file_path, 'w', encoding='utf-8') as f:
            # noinspection PyTypeChecker
            json.dump(result_data, f, ensure_ascii=False, indent=4)
        print(f"[XDlog] \033[33mWarning result JSON NOT found, created\033[0m")
    except Exception as e:
        print(f"[XDlog] \033[31mError Failed to update result JSON: {e}\033[0m")


if __name__ == '__main__':
    while True:
        message = input("> ")
        send_command(message, "py_command")

    # # 写入或追加到data字典
    # data[str(time.time())] = result_data

    # # 保存回JSON文件
    # with open(json_file_path, 'w', encoding='utf-8') as f:
    #     json.dump(data, f, indent=4, ensure_ascii=False)

    # print(f"已写入：{json.dumps(data, indent=4, ensure_ascii=False)}")
