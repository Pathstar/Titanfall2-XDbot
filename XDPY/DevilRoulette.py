import random
import time

# {
#     name:{
#         room_id
#         index
#     }
# }

# 退出：如果开始游戏，人数<3,删除所有人，else删除该玩家的g_dr_player_index_table，不然要删除房间init，修改房间状态，squirrel do the same
# 30秒未做决定自动执行


g_dr_player_index_table = {}
g_dr_room_index = 0
g_dr_room_list = []
# g_dr_return_message = {}
g_dr_data = {}
g_dr_prefix = "[Debug]"
g_items = ['magnifier', 'healing', 'drug', 'pop_and_skip', 'double_damage', 'handcuff', 'converter']
g_settings = ["player_hp", "items_distribute_num", "min_live_bullet_num", "empty_ratio_percent"]
# color_reset 可以传值设置
color_reset = "\033[0m"
# end_color = "" if color_reset == "\033[0m" else "\033[0m"
# ori_print = print


# 全量道具介绍
item_introduce = {

}

localize_dict = {
    "Live": "实弹",
    "Empty": "空弹",
    "back": "返回",
    "save": "保存",
    "player_hp": "生命值",
    "items_distribute_num": "道具数",
    "min_live_bullet_num": "实弹数",
    "empty_ratio_percent": "空弹比",
    "magnifier": "放大镜",
    "healing": "香烟",
    "drug": "过期药品",
    "pop_and_skip": "啤酒",
    "double_damage": "手锯",
    "handcuff": "手铐",
    "converter": "逆转器"
}


# LOCALIZE = {
#
# }
#
# LOCALIZE = {
#
# }

def LOCALIZE(name):
    return localize_dict.get(name, name)


def color_red(text):
    return f"\033[31m{str(text)}{color_reset}"


def color_yellow(text):
    return f"\033[33m{str(text)}{color_reset}"


# command: <string, kwarg>
# def dr_return_buffer(room_id, command):
#     if room_id not in g_dr_return_message:
#         g_dr_return_message[room_id] = []
#
#     g_dr_return_message[room_id].append(command)


class DevilRoulettePlayer:
    def __init__(self, room, name, hp):
        self.room = room
        self.name = name
        self.max_hp = hp
        self.hp = hp
        # self.items = ["quit"]
        self.items = []
        self.magazine = []
        self.damage = 1

        self.using_items = {}
        self.activity = {}

    def say(self, message):
        self.room.say(message)

    def wait(self, sec):
        self.room.wait(sec)

    def add_item(self, item):
        self.items.append(item)

    # def use_item(self, item, target=None):
    #     if item == "Armor":
    #         print(f"{self.name} 使用了护甲！")
    #         self.add_item("Armor Used")
    #     elif item == "Double Shot":
    #         print(f"{self.name} 使用了双倍伤害！")
    #         self.add_item("DoubleShot Used")
    #     elif item == "Swap Mag":
    #         print(f"{self.name} 使用了交换弹夹！")
    #         self.add_item("SwapMag Used")
    #     elif item == "Skip Turn":
    #         print(f"{self.name} 使用了跳过回合！")
    #         self.add_item("SkipTurn Used")

    # if 空弹 -> False -> 回合不交换
    def shoot_self(self):
        damage = self.damage
        if not self.magazine:
            self.say("弹夹已空，无法开枪！")
            return True
        # bullet = random.choice(self.magazine)
        # self.magazine.remove(bullet)
        bullet = self.magazine.pop(0)
        if "double_damage" in self.using_items:
            del self.using_items["double_damage"]
            damage *= 2
        if bullet == "Live":
            self.hp -= damage
            self.say(f"砰！ {self.name} 开枪了，打中自己！")
            return True  # 实弹，结束当前回合
        else:
            self.say(f"{self.name} 开枪了，是空弹！")
            return False  # 空弹，继续当前回合

    # if 空弹 -> False -> 回合不交换
    def shoot_opponent(self, opponent):
        damage = self.damage
        if not self.magazine:
            self.say("弹夹已空，无法开枪！")
            return True
        # bullet = random.choice(self.magazine)
        # self.magazine.remove(bullet)
        bullet = self.magazine.pop(0)
        if "double_damage" in self.using_items:
            del self.using_items["double_damage"]
            damage *= 2
        if bullet == "Live":
            opponent.hp -= damage
            self.say(f"砰！ {self.name} 开枪了，打中 {opponent.name}！")
            return True
        else:
            self.say(f"{self.name} 开枪了，是空弹！")
            return True

    def is_alive(self):
        return self.hp > 0

    def hp_and_max(self):
        return f"{color_red(self.hp)}/{self.max_hp}"

    def show_status(self):
        return f"{self.name} 血量: {self.hp_and_max()}"
        # return f"{self.name} 血量: {self.hp} | 道具: {self.items}"

    def choose_item(self):
        if self.has_items():
            self.activity["choosing_item"] = True
            self.say(f"{self.show_items()}")
        else:
            return f"{self.name} 道具: 无"

    def show_items(self):
        return f"{self.name} 请选择道具: {color_yellow(1)}. {LOCALIZE('back')} | {' | '.join([f'{color_yellow(i + 2)}. {LOCALIZE(item)}' for i, item in enumerate(self.items)])}"

        # return f"{self.name} 道具: {' | '.join([f"\033[33m{i+1}\033[0m. {item}" for i, item in enumerate(self.items)])}"
        # return f"{self.name} 道具: {self.items}"

    def show_status_and_items(self, format_num=0):
        return f"{self.name:<{format_num}} 血量: {self.hp_and_max()} | 道具: {'、'.join([f'{LOCALIZE(item)}' for i, item in enumerate(self.items)])}"

        # return f"{self.name} 血量: {color_red(self.hp)} | 道具: {' | '.join([f'{color_yellow(i + 1)}. {LOCALIZE(item, item)}' for i, item in enumerate(self.items)])}"

    # def format_show_status_and_items(self):

    # @property
    def has_items(self):
        return len(self.items) > 0
        # return len(self.items) > 1


class DevilRoulette:

    @staticmethod
    def loop_counter(current, max_value):
        return current % (max_value + 1)

    def __init__(self, room):
        # 配置 init
        self.same_health = True
        # self.player_count = 2
        self.room = room
        self.room_id = room.room_id
        self.player_info_list = room.player_info_list
        self.player_count = len(self.player_info_list)

        # 变量相关
        setting_dict = room.setting_dict
        self.player_hp = setting_dict["player_hp"]
        self.items_distribute_num = setting_dict["items_distribute_num"]
        self.min_live_bullet_num = setting_dict["min_live_bullet_num"]
        self.empty_ratio_percent = setting_dict["empty_ratio_percent"]
        self.ban_items = room.ban_items

        self.handle_items = {}
        self.actions = None
        self.handle_actions = {}
        self.handle_pc_actions = {}
        self.pc_name = room.pc_name
        self.format_num = 0

        # 游戏相关
        self.players = []
        self.current_player_index = 0
        self.next_player = None
        self.magazine = []
        self.turn = 1
        self.switch_count = 0

    def param_check(self, param_name, param, min_num=None, max_num=None):
        return self.room.param_check(param_name, param, min_num, max_num)

    def say(self, message):
        self.room.say(message)

    def wait(self, sec):
        self.room.wait(sec)

    def win(self, player_status):
        self.room.win(player_status)

    def game_start(self):
        """
        初始化添加玩家，如果游戏想要真的开始要调用此方法
        :return:
        """
        # self.items = ["Armor", "DoubleShot", "SwapMag", "SkipTurn"] 改成从房间配置传来
        self.items_distribute_num = self.param_check("items_distribute_num", self.items_distribute_num, 0, 7)
        self.min_live_bullet_num = self.param_check("min_live_bullet_num", self.min_live_bullet_num, 1, 8)

        empty_ratio_percent = self.empty_ratio_percent
        if empty_ratio_percent > 80:
            self.say(f"{LOCALIZE('empty_ratio_percent')} 最高为 80% (现在为{empty_ratio_percent})，已修改为80%")
            empty_ratio_percent = 80
        self.empty_ratio_percent = max(0, empty_ratio_percent)

        self.actions = ["shoot_self", "shoot_opponent", "view_item"]
        self.handle_items = {
            # "quit": self.item_quit,
            "magnifier": self.item_magnifier,
            "healing": self.item_healing,
            "drug": self.item_drug,
            "pop_and_skip": self.item_pop_and_skip,
            "double_damage": self.item_double_damage,
            "handcuff": self.item_handcuff,
            "converter": self.item_converter
        }
        self.handle_actions = {}

        # 创建玩家，分发
        for index, player_info in enumerate(self.player_info_list):
            player = DevilRoulettePlayer(self.room, **player_info)
            # 分发道具
            player.items += self.generate_random_items()
            self.players.append(player)
            # 创建弹夹链接
            player.magazine = self.magazine
            g_dr_player_index_table[player_info["name"]]["player_index"] = index

        self.next_player = self.players[0]
        self.format_num = max(len(player.name) for player in self.players)

        self.say(f"欢迎进入新一局的恶魔轮盘 - {' VS '.join([player.name for player in self.players])}")
        self.magazine += self.generate_magazine()
        # bullets_counts = self.get_magazine_bullets()
        self.wait(2)
        self.say(f"第 1 回合，装填子弹... {self.display_magazine()}")
        self.wait(2)
        for player in self.players:
            self.say(player.show_status_and_items(self.format_num))
        self.wait(2)
        self.player_new_action()

    def player_entrance(self, player_name, choice):
        """
        主入口，开始后一致调用此方法即可
        :param player_name:
        :param choice:
        :return:
        """
        # 校验玩家是否为本次玩家
        current_player_name = self.next_player.name
        if player_name == current_player_name:
            self.player_round(self.next_player, choice)
        else:
            print(f"非{player_name}回合，现在轮到 {current_player_name} ")

    def player_new_action(self, is_continues=False):
        next_player = self.next_player
        str_action = f"{color_yellow(1)}. 打自己 | {color_yellow(2)}. 打对方 | {color_yellow(3)}. 使用道具{'(目前没有道具)' if not next_player.has_items() else ''}"
        if is_continues:
            self.say(f"{next_player.name} 请继续操作：{str_action}")
        else:
            self.say(f"{next_player.name} 请选择操作：{str_action}")

    def player_round(self, current_player: DevilRoulettePlayer, choice: int):
        is_switch = True
        player_name = current_player.name
        player_activity = current_player.activity

        if "choosing_item" in player_activity:
            # 道具页面
            items = current_player.items
            print(f"{g_dr_prefix} current_player.items: {items}")

            # choice 过大限制
            # if len(items)=3 4为极限可以的值
            if choice >= len(items) + 2:
                self.say(f"超出道具选择范围")
                return

            # choice 过小为退出
            if choice < 2:
                # 退出
                del player_activity["choosing_item"]
                self.player_new_action()
                return

            # expect choice >= 2
            item_index = choice - 2
            item = items[item_index]

            use_item_kwargs = {
                "player": current_player,
                "item_index": item_index,
                "item": item
            }
            if item in self.handle_items:
                self.handle_items[item](use_item_kwargs)
            else:
                self.item_none(use_item_kwargs)
            # item_handler = self.handle_items.get(item, self.item_none)
            # item_handler(kwargs)
            # return new kwargs key
            self.wait(1)
            # ↓ 继续选择
            if "action" in use_item_kwargs:
                use_item_action = use_item_kwargs["action"]
                if use_item_action == "back":
                    del player_activity["choosing_item"]
                    self.player_new_action()
                elif use_item_action == "continue":
                    self.say(current_player.show_items())
            # else:
            #     del player_activity["choosing_item"]
            #     self.player_new_action()
            return

        else:
            # 选择行动
            if player_name == self.pc_name:
                # 电脑行动
                self.wait(2)
                # action = random.choice(["shoot_self", "shoot_opponent", "use_item"])
                action = self.actions[choice - 1]
                if action == "shoot_self":
                    self.say(f"{player_name} 拿枪指向了自己！")
                    self.wait(2)
                    if not current_player.shoot_self():
                        is_switch = False
                elif action == "shoot_opponent":
                    choose_player = self.choose_player()
                    self.say(f"{player_name} 拿枪指向了{choose_player.name}！")
                    self.wait(2)
                    current_player.shoot_opponent(choose_player)
                else:
                    return
                    # if current_player.items:
                    #     item = random.choice(current_player.items)
                    #     current_player.use_item(item, self.choose_player())
                    # else:
                    #     print(f"{g_dr_prefix} {self.pc_name}没有道具，跳过回合。")
            else:
                # 玩家行动
                if choice > len(self.actions):
                    self.say("超出选择范围")
                    return
                action = self.actions[choice - 1]
                # print(f"{g_dr_prefix} {action}")
                if action == "shoot_self":
                    # 空弹不交换
                    self.say(f"{player_name} 拿枪指向了自己！")
                    self.wait(2)
                    if not current_player.shoot_self():
                        is_switch = False
                elif action == "shoot_opponent":
                    choose_player = self.choose_player()
                    self.say(f"{player_name} 拿枪指向了{choose_player.name}！")
                    self.wait(2)
                    current_player.shoot_opponent(self.choose_player())
                #  玩家进入道具菜单
                elif action == "view_item":
                    if current_player.has_items():
                        current_player.choose_item()
                        return
                    else:
                        self.say("当前没有道具")
                        return
                    # if not current_player.items:
                    #     print("你没有道具！")
                    #     return
                    # print("你的道具：", current_player.items)
                    # item_choice = input("请输入要使用的道具名称：")
                    # if item_choice in current_player.items:
                    #     current_player.use_item(item_choice, other_player)
                    #     result = False
                    # else:
                    #     print("无效的道具！")
                    #     return
                else:
                    print(f"{g_dr_prefix} 无效选项！")
                    return

        # 1. 胜利检查
        self.wait(2)
        self.say(" | ".join(player.show_status() for player in self.players))
        if self.check_win():
            self.wait(1)
            self.win_action()
            return

        # 2. 弹夹检查
        self.check_magazine()
        # if not self.magazine:
        #     # 不要使用赋值，player有引用
        #     self.magazine += self.generate_magazine()
        #     # for player in self.players:
        #     #     player.magazine = self.magazine
        #     #     # self.give_items(player)
        #     # bullets_counts = self.get_magazine_bullets()
        #     self.say(f"弹夹已空，装填子弹... {self.display_magazine()}")

        # 3. 交换检查，如果是电脑，继续统计结果
        if is_switch:
            self.handle_player_switch()
        else:
            # 打向自己是空弹，当前玩家继续
            if player_name == self.pc_name:
                self.say("继续电脑回合")
                self.player_round(current_player, random.randint(1, 2))
                return
            else:
                # 玩家
                self.player_new_action(True)

    def check_win(self):
        # alive_count = sum(player.is_alive() for player in self.players)
        return sum(player.is_alive() for player in self.players) == 1

    def check_magazine(self):
        if not self.magazine:
            # 不要使用赋值，player有引用
            self.magazine += self.generate_magazine()
            self.say(f"弹夹已空，装填子弹... {self.display_magazine()}")

    def win_action(self):
        for player in self.players:
            if player.name in g_dr_player_index_table:
                del g_dr_player_index_table[player.name]
        for player in self.players:
            if player.is_alive():
                if player.name == self.pc_name:
                    self.say(f"{player.name} 获胜！")
                else:
                    self.say(f"恭喜 {player.name} 获胜！")
                self.room.status = "finished"
                self.win({player.name: player.is_alive() for player in self.players})
                print(f"{g_dr_prefix} g_dr_player_index_table: {g_dr_player_index_table}")
                return

    def handle_player_switch(self, is_continues=False):
        # 交换
        self.switch_action()
        if self.switch_count % self.player_count == 0:
            self.turn += 1
            self.wait(1)
            self.say(f"第 {self.turn} 回合")

        # 如果下一个是电脑，自动执行
        if self.next_player.name == self.pc_name:
            self.say("电脑回合")
            self.player_round(self.next_player, random.randint(1, 2))
        else:
            # 玩家
            self.player_new_action(is_continues)

    def switch_action(self):
        """
            # 交换回合
        :return:
        """
        self.switch_count += 1
        # 死亡的话移除players player_count减少
        self.current_player_index = self.loop_counter(self.switch_count, self.player_count - 1)
        self.next_player = self.players[self.current_player_index]
        print(f"{g_dr_prefix} current_player_index: {self.current_player_index} {self.next_player.name}")
        if "handcuff" in self.next_player.using_items:
            handcuff_player = self.next_player
            del handcuff_player.using_items["handcuff"]
            self.wait(1)
            self.say(f"{handcuff_player.name} 的手被铐住了！无法行动")
            self.switch_action()

    def choose_player(self):
        """
            # 选择一名玩家进行射击 多人需重写
        :return: class: player
        """
        if self.player_count == 2:
            return self.players[1 - self.current_player_index]
        else:
            return self.players[1 - self.current_player_index]

    # --------------- handle_items ---------------
    # kwargs = {
    #     "player": current_player, class
    #     "item_index": item_index, int
    #     "item": item str
    # }

    def item_quit(self, kwargs):
        kwargs["player"].activity["choosing_item"] = False
        self.player_new_action()
        kwargs["action"] = "back"

    def item_magnifier(self, kwargs):
        player = kwargs["player"]

        del player.items[kwargs["item_index"]]
        self.say_use_item_and_wait(player.name, kwargs["item"])
        bullet = self.magazine[0]
        bullet_name = LOCALIZE(bullet)
        self.say(f"下一发子弹为：{bullet_name}！")
        kwargs["action"] = "back"

    def item_healing(self, kwargs):
        heal_hp = 1
        player = kwargs["player"]
        if player.hp == player.max_hp:
            self.say(f"血量已满！无法使用")
            kwargs["action"] = "continue"
            return

        del player.items[kwargs["item_index"]]
        self.say_use_item_and_wait(player.name, kwargs["item"])
        new_hp = player.hp + heal_hp
        if new_hp > player.max_hp:
            new_hp = player.max_hp
        player.hp = new_hp
        self.say(f"{player.name} 恢复了 {heal_hp} 点血！现在血量为 {player.hp_and_max()}")
        kwargs["action"] = "back"

    def item_drug(self, kwargs):
        """
        可能的血量下降 -> check_win -> win_action
        :param kwargs:
        :return:
        """
        # heal_hp = 0
        player = kwargs["player"]

        del player.items[kwargs["item_index"]]
        self.say_use_item_and_wait(player.name, kwargs["item"])
        if random.getrandbits(1):  # 返回 1 或 0
            heal_hp = 2
            new_hp = player.hp + heal_hp
            if new_hp > player.max_hp:
                new_hp = player.max_hp
            player.hp = new_hp
            self.say(f"药品生效！{player.name} 恢复了 2 点血！现在血量为 {player.hp_and_max()}")
            kwargs["action"] = "back"
            return
        else:
            heal_hp = -1
            player.hp += heal_hp
            self.say(f"药品失效！{player.name} 扣除了 1 点血！现在血量为 {player.hp_and_max()}")

            if self.check_win():
                self.wait(2)
                self.win_action()
                return
        # unreachable
        kwargs["action"] = "back"

    def item_pop_and_skip(self, kwargs):
        """
        子弹数 -1 -> check_magazine
        :param kwargs:
        :return:
        """
        player = kwargs["player"]

        del player.items[kwargs["item_index"]]
        self.say_use_item_and_wait(player.name, kwargs["item"])

        bullet = self.magazine.pop(0)
        print(f"弹出子弹 {bullet}")
        self.say(f"{player.name} 弹出了下一颗子弹，是{LOCALIZE(bullet)}！")
        self.check_magazine()
        kwargs["action"] = "back"

    def item_double_damage(self, kwargs):
        """

        :param kwargs:
        :return:
        """
        player = kwargs["player"]

        del player.items[kwargs["item_index"]]
        self.say_use_item_and_wait(player.name, kwargs["item"])
        player.using_items["double_damage"] = True
        self.say(f"{player.name} 的下一发子弹将造成双倍伤害！")
        kwargs["action"] = "back"

    def item_handcuff(self, kwargs):
        player = kwargs["player"]

        del player.items[kwargs["item_index"]]
        self.say_use_item_and_wait(player.name, kwargs["item"])
        choose_player = self.choose_player()
        choose_player.using_items["handcuff"] = True
        self.say(f"{player.name} 将 {choose_player.name} 的手铐住了，禁止 1 回合！")
        kwargs["action"] = "back"

    # def item_query(self, kwargs):
    #     player = kwargs["player"]
    #     del player.items[kwargs["item_index"]]
    #     bullet = self.magazine[0]
    #     bullet_name = LOCALIZE(bullet, bullet)
    #     self.say(f"下一发子弹为：{bullet_name}！")

    def item_converter(self, kwargs):
        player = kwargs["player"]

        del player.items[kwargs["item_index"]]
        self.say_use_item_and_wait(player.name, kwargs["item"])
        bullet = self.magazine[0]
        if bullet == "Live":
            self.magazine[0] = "Empty"
            print(f"{g_dr_prefix} Live -> Empty")
        elif bullet == "Empty":
            self.magazine[0] = "Live"
            print(f"{g_dr_prefix} Empty -> Live")
        # bullet_name = LOCALIZE(bullet, bullet)
        self.say(f"下一发子弹已被转换！")
        kwargs["action"] = "back"

    def item_none(self, kwargs):
        self.say(f"错误：没有这个道具 {kwargs.get('item', '')}")
        kwargs["action"] = "continue"

    def say_use_item_and_wait(self, player_name, item):
        self.say(f"{player_name} 使用了 {LOCALIZE(item)}！{item_introduce.get(item, '')}")
        self.wait(1)

    def generate_magazine(self, live_bullets=None):
        """
            # 生成弹夹，请使用append或者+=，不要直接给self.magazine赋值，否则玩家无法收到弹夹
        :param live_bullets:
        :return: array: magazine
        """
        if live_bullets is None:
            min_live_bullet_num = self.min_live_bullet_num
            # live_bullets = self.get_total_health()
            # if live_bullets > self.max_live_bullets:
            #     live_bullets = self.max_live_bullets
            live_bullets = random.randint(min_live_bullet_num, min_live_bullet_num+1)

        # 随机可能多一个空弹
        empty_ratio_percent = self.empty_ratio_percent

        # 根据占比计算空弹数量
        if empty_ratio_percent > 0:
            empty_bullets = int((empty_ratio_percent * live_bullets) / (100 - empty_ratio_percent))
            empty_bullets += random.randint(0, 1)
        else:
            empty_bullets = 0
        # random_add_empty = random.randint(0, 1)
        # empty_bullets = live_bullets + random_add_empty
        # self.bullets["live_bullets"] = live_bullets
        # self.bullets["empty_bullets"] = empty_bullets
        magazine = ["Live"] * live_bullets + ["Empty"] * empty_bullets
        # self.say(f'装填子弹... {str(["真" if bullet == "Live" else "空" for bullet in magazine])}')
        random.shuffle(magazine)
        return magazine

    def get_magazine_bullets(self):
        """
        get当前真假子弹数
        :return: list<int>: [Live, Empty]
        """
        live = 0
        empty = 0
        for bullet in self.magazine:
            if bullet == "Live":
                live += 1
            elif bullet == "Empty":
                empty += 1
        return [live, empty]

    def display_magazine(self):
        bullets_counts = self.get_magazine_bullets()
        return str(['实'] * bullets_counts[0] + ['空'] * bullets_counts[1])

    def generate_random_items(self, num=None):
        num = self.items_distribute_num if num is None else num
        return random.sample(g_items, num)
        # for _ in range(2):
        #     item = random.choice(self.items)
        #     player.add_item(item)

    def is_current_player(self, player_name):
        if player_name == self.next_player.name:
            return True
        return False

    def find_player_by_name(self, player_name):
        for player in self.players:
            if player_name == player.name:
                return

    def get_total_health(self):
        return sum([player.hp for player in self.players])

    def item_shuffle_magazine(self):
        self.magazine = self.generate_magazine()

    def hack_show_magazine(self):
        return str(self.magazine)

    def hack_add_health(self, player):
        # player.hp += 1
        pass
    
    def hack_add_live_bullets(self, live_bullets=None):
        pass


class DevilRouletteRoom:
    def __init__(self, room_id, player_limit=2):
        self.room_id = room_id
        self.player_limit = player_limit
        g_dr_room_list.append(self)
        self.status = "waiting"  # 0: 需要创建, 1: wait, 2: game start, 3: game over

        # index -> name -> value; do not remove and del
        self.setting_dict = {
            "player_hp": 3,
            "items_distribute_num": 3,
            "min_live_bullet_num": 2,
            "empty_ratio_percent": 50
        }
        self.player_number = 2
        # self.player_hp = 3
        # self.items_distribute_num = 3
        # self.min_live_bullet_num = 2
        self.ban_items = {}

        self.pc_name = "电脑"
        self.game = None
        # 需保证入场循序
        self.player_info_list = []
        self.player_dict = {}
        self.message_buffer = []

    def enter_game(self, player_name: str, is_pc=False):
        """
        new Room后使用此方法添加一个玩家
        :param is_pc:
        :param player_name:
        :return:
        """
        # 改成判断不是已经进入的玩家，允许在一个房间未玩完又进入新的房间
        # if player_name not in g_dr_player_index_table:
        # if self.is_player_in_room(player_name):
        print(f"[Debug] self.player_info_list: {self.player_info_list}")
        print(f"[Debug] self.player_dict: {self.player_dict}")
        if player_name in self.player_dict:
            if is_pc:
                print(f"[DR] player_dict: {self.player_dict}")
                self.say(f"这个电脑已经在房间里了")
            else:
                self.say(f"你已经在房间里啦，正在等待另一位玩家...")
            return

        if is_pc:
            self.pc_name = player_name

        g_dr_player_index_table[player_name] = {
            "room_id": self.room_id
        }
        self.player_info_list.append({"name": player_name})
        self.player_dict[player_name] = {}
        self.handel_mode(player_name)

    def enter_pc(self, player_name: str):
        """
        new Room后使用此方法添加一个电脑
        :param player_name:
        :return:
        """
        self.pc_name = player_name
        if self.is_player_in_room(player_name):
            self.say(f"这个电脑已经在房间里了")
            return
        # if player_name not in g_dr_player_index_table:
        g_dr_player_index_table[player_name] = {
            "room_id": self.room_id
        }
        self.player_info_list.append({"name": player_name})
        self.player_dict[player_name] = {}
        self.handel_mode(player_name)

    def start_game(self):
        """
        开始游戏，增加room index，再次使用room_index应当为创建新房间
        :return:
        """
        global g_dr_room_index
        self.status = "playing"
        self.setting_dict["player_hp"] = self.param_check("player_hp", self.setting_dict["player_hp"], 1, 10)
        for player_info in self.player_info_list:
            if "hp" not in player_info:
                player_info["hp"] = self.setting_dict["player_hp"]
        self.game = DevilRoulette(self)
        self.game.game_start()
        g_dr_room_index += 1

    def handel_mode(self, player_name=None):
        player_count = len(self.player_info_list)

        if player_count == 0:
            self.status = "waiting"
        elif player_count == 1:
            self.status = "waiting"
            self.say(f"欢迎进入游玩恶魔轮盘游戏！等待玩家中... {player_count}/{self.player_number}")
            # 检查松鼠中是否有不在该房间的玩家占位
            self.check(self.player_info_list)
            if player_name:
                self.player_dict[player_name]["host"] = "in_game"
        elif player_count == self.player_number:
            self.start_game()
        elif player_count < self.player_number:
            self.say(f"欢迎进入游玩恶魔轮盘游戏！等待玩家中... {player_count}/{self.player_number}")
        else:
            self.say(f"错误：游玩人数: {player_count} 大于房间限制人数: {self.player_number}")

    def quit_game(self, player_name: str):
        """
        删除 全局信息
        删除 init list 信息
        删除 player dict 信息
        重新检测房间状态
        :param player_name:
        :return:
        """
        del g_dr_player_index_table[player_name]
        self.del_player_from_list(player_name)
        del self.player_dict[player_name]
        self.handel_mode(player_name)
        # print(f"玩家 {self.player_name} 进入房间 {self.room_id} 的恶魔轮盘游戏！")

    def is_player_in_room(self, player_name: str) -> bool:
        return next((player for player in self.player_info_list if player["name"] == player_name), None) is not None

    # ---------------- Setting ----------------
    def setting_entry(self, player_name: str, choice: int):

        def show_setting(name):
            self.say(
                f"{name} 请选择设置: {color_yellow(1)}. {LOCALIZE('save')} | {' | '.join([f'{color_yellow(i + 2)}. {LOCALIZE(setting)}' for i, setting in enumerate(g_settings)])}")

        player_data = self.player_dict[player_name]
        if "host" not in player_data:
            return
        host_action = player_data["host"]
        if host_action == "in_game":
            # 选择 1 进入设置
            if choice == 1:
                show_setting(player_name)
                player_data["host"] = "in_setting"
            return
        elif host_action == "in_setting":
            # 选择要设置的参数
            if choice <= 1:
                # todo delay begin
                self.say(f"设置已保存！")
                player_data["host"] = "in_game"
                return
            elif choice <= len(g_settings) + 1:
                # 2 -> index 0
                setting_name = g_settings[choice - 2]
                self.say(
                    f"{player_name} 请使用 [{color_yellow('数字')}] 设置参数 {LOCALIZE(setting_name)} | 现在为 ({self.setting_dict.get(setting_name, 'error')})")
                player_data["host"] = setting_name
                return
        elif host_action in self.setting_dict:
            # 设置参数
            temp_num = self.setting_dict[host_action]
            self.setting_dict[host_action] = choice
            if choice == temp_num:
                self.say(f"{LOCALIZE(host_action)} 的值与先前一致 ({temp_num})")
                self.wait(1)
                show_setting(player_name)
            else:
                self.say(f"{LOCALIZE(host_action)} 成功设置为 {choice} ")
                self.wait(1)
                show_setting(player_name)
            player_data["host"] = "in_setting"
            return
        else:
            # error
            print(f"{g_dr_prefix} setting_entry error | {player_name} | {host_action} | {choice}")
            show_setting(player_name)
            player_data["host"] = "in_setting"
            return

    def set_room_health(self, health):
        self.setting_dict["player_hp"] = health
        for player_info in self.player_info_list:
            if "hp" in player_info:
                del player_info["hp"]

    def set_player_health(self, player_name, health):
        self.find_player_by_name(player_name)["hp"] = health

    def find_player_by_name(self, player_name):
        for player in self.player_info_list:
            if player["name"] == player_name:
                return player

    # 暂不考虑
    def set_player_number(self, player_number):
        self.player_number = player_number
        if len(self.player_info_list) == player_number:
            self.status = "waiting"
            # start_game()

    def del_player_from_list(self, quit_player):
        for player in self.player_info_list:
            if player["name"] == quit_player:
                self.player_info_list.remove(player)
                break
        else:
            print(f"{g_dr_prefix} quit没找到 {quit_player}")

    def param_check(self, param_name, param, min_num=None, max_num=None):
        localized_name = LOCALIZE(param_name)
        if max_num is not None and param > max_num:
            self.say(f"{localized_name} 最高为 {max_num}（现在为 {param}），已修改为 {max_num}")
            self.wait(1)
            return max_num
        if min_num is not None and param < min_num:
            self.say(f"{localized_name} 最小为 {min_num}（现在为 {param}），已修改为 {min_num}")
            self.wait(1)
            return min_num
        return param
    # def return_buffer(self, command):
    #     self.message_buffer.append(command)

    def say(self, message):
        # self.return_buffer({"say": {"message": message}})
        self.message_buffer.append(["say", {"message": message}])

    def wait(self, sec):
        # self.return_buffer({"sleep": {"sec": sec}})
        self.message_buffer.append(["wait", {"sec": sec}])

    def win(self, player_status):
        # self.return_buffer({"sleep": {"sec": sec}})
        self.message_buffer.append(["win", {"player_status": player_status}])

    def check(self, player_info_list):
        self.message_buffer.append(["check", {"player_info_list": player_info_list}])


if __name__ == "__main__":
    def main():
        def cmd_clear():
            try:
                import os
                os.system('cls' if os.name == 'nt' else 'clear')
            except Exception as e:
                pass
            finally:
                print()

        cmd_clear()
        if color_reset == "\033[0m":
            start_color = ""
            end_color = ""
        else:
            start_color = color_reset
            end_color = "\033[0m"

        def say(message):
            print(f"{start_color}{message}{end_color}")

        def wait(sec):
            time.sleep(sec)

        def win(player_status):
            print(player_status)

        def check(player_info_list):
            print(player_info_list)

        # 创建房间
        command_table = {
            "say": say,
            "wait": wait,
            "win": win,
            "check": check
        }

        def get_message(room):
            for buffer in room.message_buffer:
                command_table[buffer[0]](**buffer[1])
            room.message_buffer.clear()
        # if not g_dr_data:
        #     g_dr_data = {
        #         "chinese": {
        #             "Live": "真",
        #             "Empty": "空"
        #         }
        #     }
        arrow = "-> "
        test_room = DevilRouletteRoom(g_dr_room_index)
        test_room.message_buffer.clear()
        test_room.enter_game("XD")
        get_message(test_room)

        print("输入 1 进入设置，Enter开始")
        str_choice = input(arrow)
        if str_choice != "":
            tchoice = int(str_choice)
            while True:
                try:
                    test_room.setting_entry("XD", tchoice)
                    get_message(test_room)
                    tchoice = int(input(arrow))
                    if tchoice == 1:
                        test_room.setting_entry("XD", tchoice)
                        get_message(test_room)
                        break
                except Exception as e:
                    break

        # print(f"g_dr_room_index: {g_dr_room_index}")
        test_room.enter_game("电脑")
        get_message(test_room)
        while True:
            try:
                # print(f"g_dr_room_index: {g_dr_room_index}")
                tchoice = int(input(arrow))
                test_room.game.player_entrance("XD", tchoice)
                get_message(test_room)
            except Exception as eee:
                print("fail")
                continue


    main()


