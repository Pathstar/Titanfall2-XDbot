import os
import json
import time

json_file_path = r'D:\SystemApps\Steam\steamapps\common\Titanfall2\R2Northstar\save_data\Northstar.Client\XD.json'

player_name = "Pathstar_XD"
last_command = ""

while True:
    command = input("command: ")
    if command == "":
        command = last_command
    else:
        last_command = command
    message = input("message: ")
    # 检查文件是否存在，如果不存在则新建空JSON文件
    # if not os.path.exists(json_file_path):
    #     with open(json_file_path, 'w', encoding='utf-8') as f:
    #        json.dump({}, f, indent=4)
    data = {}
    # # 读取原有内容
    # with open(json_file_path, 'r', encoding='utf-8') as f:
    #     try:
    #         data = json.load(f)
    #     except json.JSONDecodeError:
    #         data = {}

    # 生成本次要写入的数据
    new_entry = {
        player_name: {
            "command": command,
            "message": message,
            "say": "say "
        }
    }
    # 写入或追加到data字典
    data[str(time.time())] = new_entry

    # 保存回JSON文件
    with open(json_file_path, 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=4, ensure_ascii=False)

    print(f"已写入：{json.dumps(data, indent=4, ensure_ascii=False)}")
