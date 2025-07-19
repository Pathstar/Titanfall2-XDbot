import json
import os
from collections import OrderedDict

# 假设pinyin_syllables
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
                    'liao', 'lie', 'lin', 'ling', 'liu', 'long', 'lou', 'lu', 'luan', 'lue', 'lun', 'luo', 'lv', 'ma',
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

import json
import os
from collections import OrderedDict

# 路径设定
temp_dict_path = r"temp_dict.json"
# dag_char_path = r"C:\Users\kwx1412683\AppData\Local\Programs\Python\Python313\Lib\site-packages\Pinyin2Hanzi\data\dag_char.json"
# dag_phrase_path = r"C:\Users\kwx1412683\AppData\Local\Programs\Python\Python313\Lib\site-packages\Pinyin2Hanzi\data\dag_phrase.json"
dag_char_path = r"dag_char.json"
dag_phrase_path = r"dag_phrase.json"
# 1. 加载数据
with open(temp_dict_path, encoding='utf-8') as f:
    temp_data = json.load(f, object_pairs_hook=OrderedDict)

# 2. 加载dag_char和dag_phrase
if os.path.exists(dag_char_path):
    with open(dag_char_path, encoding='utf-8') as f:
        dag_char_data = json.load(f, object_pairs_hook=OrderedDict)
else:
    dag_char_data = OrderedDict()

if os.path.exists(dag_phrase_path):
    with open(dag_phrase_path, encoding='utf-8') as f:
        dag_phrase_data = json.load(f, object_pairs_hook=OrderedDict)
else:
    dag_phrase_data = OrderedDict()

# 3. 记录非法拼音
non_pinyin_keys = []

# 运行主逻辑
for pinyin_str, hanzi in temp_data.get("temp_pinyin_dict", {}).items():
    keys = pinyin_str.split()
    is_all_pinyin = all(syll in pinyin_syllables for syll in keys)
    if not is_all_pinyin:
        non_pinyin_keys.append((pinyin_str, hanzi))
        continue
    is_single = len(keys) == 1
    score = 0.1 if is_single else 0.21
    key = keys[0] if is_single else ','.join(keys)
    item = [hanzi, score]
    # 写入对应json
    if is_single:
        mapping = dag_char_data
        file_path = dag_char_path
    else:
        mapping = dag_phrase_data
        file_path = dag_phrase_path

    # 检查是否已存在此拼音
    if key in mapping:
        hanzi_list = mapping[key]
        first_hanzis = [h[0] for h in hanzi_list]
        if hanzi not in first_hanzis:
            # 不重复，插到第一个，保留后面顺序
            mapping[key] = [item] + hanzi_list
        else:
            idx = first_hanzis.index(hanzi)
            print(f"已存在拼音 {key} 和汉字 {hanzi}，原数据为 {hanzi_list[idx]}")
            act = input("按回车覆盖，否则跳过: ")
            if act.strip() == "":
                hanzi_list[idx] = item
                mapping[key] = hanzi_list
            else:
                continue
    else:
        # 没有命中，插在最前，不打乱顺序
        new_mapping = OrderedDict()
        new_mapping[key] = [item]
        for k, v in mapping.items():
            new_mapping[k] = v
        mapping.clear()
        mapping.update(new_mapping)

# 写入回来
with open(dag_char_path, 'w', encoding='utf-8') as f:
    json.dump(dag_char_data, f, ensure_ascii=False, indent=2)
with open(dag_phrase_path, 'w', encoding='utf-8') as f:
    json.dump(dag_phrase_data, f, ensure_ascii=False, indent=4)

if non_pinyin_keys:
    print("\n非拼音数据如下：")
    for k, v in non_pinyin_keys:
        print(f"{k}: {v}")
    print("请检查以上内容！")


                    # 写python。temp_dict.json的内容类似： { "temp_pinyin_dict": { "zhen de": "真的", "jia de": "假的", "ti yu sheng": "体育生", "xia ku le": "吓哭了", "qun xian bi zhi": "群贤毕至", "zha zhu": "炸猪", "li da gong": "立大功" } } 将所有数据进行处理，举例："zhen de": "真的", 以空格分割，用是否在pinyin_syllables检测是否为拼音，如果都合法则处理成："zhen,de": [["真的",0.25]] 如果被检测到有非拼音则储存起来，运行完后打印提醒 如果是单个拼音，后面数值取0.1，如果不是单个拼音，则取0.25 如果单个拼音则添加到C:\Users\kwx1412683\AppData\Local\Programs\Python\Python313\Lib\site-packages\Pinyin2Hanzi\data\dag_char.json中，其中的数据类似于： { "a": [ [ "啊", 0.1 ], [ "阿", 0.1 ], ]} 如果不是单个拼音则添加到C:\Users\kwx1412683\AppData\Local\Programs\Python\Python313\Lib\site-packages\Pinyin2Hanzi\data\dag_phrase.json 其中的数据类似于 { "a,a": [ [ "啊啊", 0.20138588289869744 ], [ "啊阿", 0.20138588289869744 ] ], } 如果拼音命中，遍历其中的列表中的第一个元素，以检测中文是否重复，如果不重复，则添加到列表第一个，如果重复，打印出来，使用input()停顿，如果按回车则进行覆盖，否则如果有内容则不进行覆盖 如果拼音没有命中，将键值对添加到最前面，不要打乱原有顺序