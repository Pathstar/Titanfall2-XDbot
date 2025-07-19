import json


choice = input("choice: ")
# 一份缩进4放这，一份无缩进覆盖并备份
if choice == "1":
    with open('dag_phrase_old.json', encoding='utf-8') as f:
        data = json.load(f)  # 自动解码

    with open('dag_phrase.json', 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False)
else:
    with open('dag_char_old.json', encoding='utf-8') as f:
        data = json.load(f)
    with open('dag_char.json', 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False)
