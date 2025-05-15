import re
from Pinyin2Hanzi import DefaultDagParams
from Pinyin2Hanzi import dag

# 初始化模型参数
dag_params = DefaultDagParams()


# 用户 自定义拼音->汉字映射词典，用于提前替换


# 提前替换指定词组
# def preprocess_custom_words(text):
#     for pinyin_phrase, hanzi in custom_dict.items():
#         pattern = re.compile(r'\b' + re.escape(pinyin_phrase) + r'\b', flags=re.IGNORECASE)
#         text = pattern.sub(hanzi, text)
#     return text
# def preprocess_custom_words(text):
#     def replacement(match):
#         pinyin = match.group()
#         return custom_dict.get(pinyin.lower(), pinyin)  # 只替换匹配的拼音，未匹配的保持原样
#
#     pattern = re.compile(r'\b(' + '|'.join(map(re.escape, custom_dict.keys())) + r')\b', flags=re.IGNORECASE)
#     return pattern.sub(replacement, text)



def preprocess_custom_words(text_list):
    def replacement(match):
        pinyin = match.group()
        return custom_dict.get(pinyin.lower(), pinyin)  # 只替换匹配的拼音，未匹配的保持原样

    pattern = re.compile(r'\b(' + '|'.join(map(re.escape, custom_dict.keys())) + r')\b', flags=re.IGNORECASE)

    return [pattern.sub(replacement, text) for text in text_list]


# 判断一个子串是否是拼音段落
def is_pinyin_segment(segment):
    return all(re.fullmatch(r'[a-z]+', word) for word in segment.strip().split())


# 尝试将没有空格的拼音分割成拼音段落
# def split_no_space_pinyin(text):
#     # 使用拼音字典来分割拼音
#     pinyin_dict = set(["wo", "xiang", "yao", "zhuan", "pin", "yin", "ni", "neng", "zuo", "dao"])
#     n = len(text)
#
#     # dp[i]表示从i位置开始的最优切分方案
#     dp = [None] * (n + 1)
#     dp[n] = []  # 从n开始，没有拼音，返回空列表
#
#     # 动态规划从后往前计算
#     for i in range(n - 1, -1, -1):
#         for j in range(i + 1, n + 1):
#             word = text[i:j]  # 当前子串
#             if word in pinyin_dict and dp[j] is not None:
#                 dp[i] = [word] + dp[j]  # 如果找到了合法拼音，加入到dp[i]
#                 break  # 一旦找到切分，停止进一步查找
#
#     # 如果有解，返回最优分割，否则返回原拼音
#     return dp[0] if dp[0] is not None else [text]

def split_no_space_pinyin(text):
    """
    将无空格拼音字符串拆分为拼音音节列表。
    """
    result = []

    i = 0
    while i < len(text):
        # 最长匹配从后往前找
        for j in range(min(6, len(text) - i), 0, -1):  # 拼音最长为6个字符
            candidate = text[i:i + j]
            # print("text_lower " + candidate)
            if candidate in PINYIN_SYLLABLES:
                result.append(candidate)
                i += j
                break
        else:
            # 如果没有匹配的拼音，保留原字符或跳过
            result.append(text[i])
            i += 1
    return result


def is_all_pinyin(text):
    """
    判断一个字符串是否可以完整被拼音音节组成（用递归或贪心分词方式判断）
    """
    i = 0
    while i < len(text):
        for j in range(min(6, len(text) - i), 0, -1):
            if text[i:i + j] in PINYIN_SYLLABLES:
                i += j
                break
        else:
            return False
    return True


def split_pinyin_with_filter(text):
    """
    主函数：处理整段文本，拆分拼音，但保留非拼音原词不变。
    """

    words = text.split()

    final_result = []
    for word in words:
        # print("words " + word)
        word_lower = word.lower()
        if is_all_pinyin(word_lower):
            # print( "is_all_pinyin " + word )
            final_result.extend(split_no_space_pinyin(word_lower))
        else:
            final_result.append(word)
    return final_result


def convert_pinyin_list(pinyin_list, dag_params, topk, result):
    """
    递归地把 pinyin_list 转成中文词，转换失败时将列表末尾不断截短，
    成功后对剩余部分继续同样的操作；如果某个拼音单独也转不出结果，
    则把它原样加入 result。

    :param pinyin_list: 待转换的拼音列表
    :param dag_params: 调用 dag() 所需的参数模板
    :param topk: dag 搜索的 path_num
    :param result: 用于保存所有已生成的词组列表
    """

    print(f"pinyin_list  {pinyin_list}")
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
            convert_pinyin_list(pinyin_list[L:], dag_params, topk, result)
            return
            # if len(pinyin_list) == L:
            #     return
            # else:
            #     convert_pinyin_list(pinyin_list[L:], dag_params, topk, result)
        # else:
        #     if len(prefix) == 1:
        #         result.append(prefix[0])
        #         convert_pinyin_list(pinyin_list[L:], dag_params, topk, result)

    result.append([pinyin_list[0]])
    convert_pinyin_list(pinyin_list[1:], dag_params, topk, result)


# 主转换函数，增加对混合不可转换拼音的回退处理
def convert_pinyin_to_hanzi_with_preservation(text, topk=1):
    # 预处理自定义词

    # 切分成拼音块 / 标点 / 空格
    # print(text)
    tokens = re.findall(r"[a-z]+(?: [a-z]+)*|[^\sa-z]+|\s+", text, flags=re.IGNORECASE)
    result = []
    fail_count = 0
    pinyin_len = 0

    for token in tokens:
        # print("token " + token)
        stripped = token
        # if stripped and is_pinyin_segment(stripped):
            # 拆分成拼音列表
        if stripped:
            # pinyin_list = stripped.split() if ' ' in stripped else split_no_space_pinyin(stripped)
            # pinyin_list = split_no_space_pinyin(stripped)  # First split using split_no_space_pinyin
            # pinyin_list = ' '.join(pinyin_list).split()
            # pinyin_list = []
            # for word in stripped.split():
            #     pinyin_list.extend(split_no_space_pinyin(word))

            pinyin_list = stripped.split()

            # pinyin_list = split_pinyin_with_filter(stripped)
            # print(pinyin_list)
            pinyin_list = preprocess_custom_words(pinyin_list)
            pinyin_len = pinyin_len + len(pinyin_list)
            # 整体转换尝试
            # dag_results = dag(dag_params, pinyin_list, path_num=topk)
            # if dag_results:
            #     print(f"dag_results {dag_results}")
            #     cand = dag_results[0].path
            #     if all(len(w) > 0 for w in cand):
            #         result.append(cand)
            #         print(f"cand {cand}")
            #         continue
            print(f"convert_pinyin_list {pinyin_list}")
            convert_pinyin_list(pinyin_list, dag_params, topk, result)

            # 回退：逐个转换
            # sub_res = []
            # for py in pinyin_list:
            #     # print(f"py  {py}")
            #     sub = dag(dag_params, [py], path_num=topk)
            #     # print(f"[sub] {sub} ")
            #     if sub:
            #         sub_res.append(sub[0].path)  # 汉字列表
            #     else:
            #         print(f"sub_res {py}")
            #         sub_res.append(py)  # 保留原拼音
            #         fail_count += 1  # 记录失败次数

            # 根据中英文混合情况拼接，并保留周围空格
            # 规则：两个汉字之间不加空格，非汉字与汉字之间加空格
            # flat_parts = [(''.join(item) if isinstance(item, list) else item) for item in sub_res]
            # merged = ""
            # for i, part in enumerate(flat_parts):
            #     if i > 0:
            #         prev = flat_parts[i - 1]
            #         # 如果前后都是汉字，则不加空格，否则加一个空格
            #         if not (re.fullmatch(r'[\u4e00-\u9fff]+', prev) and
            #                 re.fullmatch(r'[\u4e00-\u9fff]+', part)):
            #             merged += " "
            #     merged += part

            # result.append(sub_res)
        # else:
        #     # 非拼音段直接保留（包括空格和标点）
        #     result.append(token)

    # if fail_count >= pinyin_len / 2:
    print(f"fail_count: {fail_count} pinyin_len: {pinyin_len}")
    # return ""

    # 最终扁平化
    def flatten(item):
        if isinstance(item, list):
            return ''.join(flatten(i) for i in item)
        return item

    return ''.join(flatten(r) for r in result)






# 测试
if __name__ == "__main__":
    custom_dict = {
        "zhuan pin yin": "转拼音",
        "zhun que lv": "准确率",
        "que shi": "确实",
        "zhun que": "准确",
        "cao": "草",
        "que": "却",
        "ya": "呀"
    }
    PINYIN_SYLLABLES = {'a', 'ai', 'an', 'ang', 'ao', 'ba', 'bai', 'ban', 'bang', 'bao', 'bei', 'ben', 'beng', 'bi',
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
                        'zhun', 'zhuo', 'zi', 'zong', 'zou', 'zu', 'zuan', 'zui', 'zun', 'zuo'}

    # input_text = "wo de.tian text zhende shi ??? le ni -v- , ran hou jiu mei le ya dui ba?? dui ma woxiang"
    # input_text = "i love this is cute"
    # input_text = "aaaa pinyin ya -v- pin yin"
    input_text = "test test a a a@ $ wo Cao a -- OvO ChAng shi zhuanwenzi"
    # input_text = "zhe xia zhuan Pin yin de zhun que lv ,ying gai   hen gaole"
    # input_text = "que shi"

    result = convert_pinyin_to_hanzi_with_preservation(input_text)
    print(result)
    # if result:
        # print(result)






# def convert_pinyin_to_hanzi_with_preservation(text, is_g_pinyin, topk=1):
#     # 预处理自定义词
#     # text = preprocess_custom_words(text)
#
#     # 切分成拼音块 / 标点 / 空格
#     tokens = re.findall(r"[a-z]+(?: [a-z]+)*|[^\sa-z]+|\s+", text, flags=re.IGNORECASE)
#     result = []
#     fail_count = 0
#     pinyin_len = 0
#     for token in tokens:
#         stripped = token.strip()
#         if stripped:
#             pinyin_list = split_pinyin_with_filter(stripped)
#             pinyin_len = pinyin_len + len(pinyin_list)
#             # 整体转换尝试
#             dag_results = dag(dag_params, pinyin_list, path_num=topk)
#             if dag_results:
#                 cand = dag_results[0].path
#                 if all(len(w) > 0 for w in cand):
#                     result.append(cand)
#                     continue
#
#             # 回退：逐个转换
#             sub_res = []
#             for py in pinyin_list:
#                 sub = dag(dag_params, [py], path_num=topk)
#                 if sub:
#                     sub_res.append(sub[0].path)  # 汉字列表
#                 else:
#                     sub_res.append(py)  # 保留原拼音
#                     fail_count += 1  # 记录失败次数
#
#             # 根据中英文混合情况拼接，并保留周围空格
#             # 规则：两个汉字之间不加空格，非汉字与汉字之间加空格
#             flat_parts = [(''.join(item) if isinstance(item, list) else item) for item in sub_res]
#             merged = ""
#             for i, part in enumerate(flat_parts):
#                 if i > 0:
#                     prev = flat_parts[i - 1]
#                     # 如果前后都是汉字，则不加空格，否则加一个空格
#                     if not (re.fullmatch(r'[\u4e00-\u9fff]+', prev) and
#                             re.fullmatch(r'[\u4e00-\u9fff]+', part)):
#                         merged += " "
#                 merged += part
#
#             result.append(merged)
#         else:
#             # 非拼音段直接保留（包括空格和标点）
#             result.append(token)
#
#     print(f"[XDlog] fail_count: {fail_count} pinyin_len: {pinyin_len}")
#     if is_g_pinyin:
#         if fail_count >= pinyin_len / 2:
#             print(f"Failed Trans")
#             return ""
#
#     # 最终扁平化
#     def flatten(item):
#         if isinstance(item, list):
#             return ''.join(flatten(i) for i in item)
#         return item
#
#     return ''.join(flatten(r) for r in result)