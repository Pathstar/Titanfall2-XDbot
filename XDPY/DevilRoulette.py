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
g_dr_prefix = "[DevilRoulette]"
ori_print = print


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
        self.hp = hp
        self.items = []
        self.magazine = []

    def say(self, message):
        self.room.say(message)

    def wait(self, sec):
        self.room.wait(sec)

    def add_item(self, item):
        self.items.append(item)

    def use_item(self, item, target=None):
        if item == "Armor":
            print(f"{self.name} 使用了护甲！")
            self.add_item("Armor Used")
        elif item == "Double Shot":
            print(f"{self.name} 使用了双倍伤害！")
            self.add_item("DoubleShot Used")
        elif item == "Swap Mag":
            print(f"{self.name} 使用了交换弹夹！")
            self.add_item("SwapMag Used")
        elif item == "Skip Turn":
            print(f"{self.name} 使用了跳过回合！")
            self.add_item("SkipTurn Used")

    # if 空弹 -> False -> 回合不交换
    def shoot_self(self):
        if not self.magazine:
            self.say("弹夹已空，无法开枪！")
            return True
        bullet = random.choice(self.magazine)
        self.magazine.remove(bullet)
        if bullet == "Live":

            self.say(f"砰！ {self.name} 开枪了，打中自己！")
            self.hp -= 1
            return True  # 实弹，结束当前回合
        else:
            self.say(f"{self.name} 开枪了，是空弹！")
            return False  # 空弹，继续当前回合

    # if 空弹 -> False -> 回合不交换
    def shoot_opponent(self, opponent):
        if not self.magazine:
            self.say("弹夹已空，无法开枪！")
            return True
        bullet = random.choice(self.magazine)
        self.magazine.remove(bullet)
        if bullet == "Live":
            self.say(f"砰！ {self.name} 开枪了，打中 {opponent.name}！")
            if "DoubleShot Used" in self.items:
                opponent.hp -= 2
                self.say("双倍伤害生效！")
                self.items.remove("DoubleShot Used")
            else:
                opponent.hp -= 1
            return True
        else:
            self.say(f"{self.name} 开枪了，是空弹！")
            return True

    def is_alive(self):
        return self.hp > 0

    def show_status(self):
        return f"{self.name} 血量: \033[31m{self.hp}\033[0m"
        # return f"{self.name} 血量: {self.hp} | 道具: {self.items}"


class DevilRoulette:

    @staticmethod
    def loop_counter(current, max_value):
        return current % (max_value + 1)

    def __init__(self, room):
        self.same_health = True
        # self.player_count = 2
        self.room = room
        self.default_health = 3
        self.max_live_bullets = 5
        self.items = None
        self.actions = None
        self.pc_name = room.pc_name

        self.player_init_list = room.player_init_list
        self.player_count = len(self.player_init_list)
        self.room_id = room.room_id
        self.players = []
        self.current_player_index = 0
        self.next_player = None
        self.magazine = []
        self.turn = 1
        self.switch_count = 0

    def say(self, message):
        self.room.say(message)

    def wait(self, sec):
        self.room.wait(sec)

    def win(self, player_status):
        self.room.win(player_status)

    def game_start(self):
        # 添加玩家
        self.items = ["Armor", "DoubleShot", "SwapMag", "SkipTurn"]
        self.actions = ["shoot_self", "shoot_opponent", "use_item"]
        for index, player_info in enumerate(self.player_init_list):
            player = DevilRoulettePlayer(self.room, **player_info)
            self.players.append(player)
            player.magazine = self.magazine
            g_dr_player_index_table[player_info["name"]]["player_index"] = index

        self.next_player = self.players[0]

        self.say(f"欢迎进入新一局的恶魔轮盘 - {' VS '.join([player.name for player in self.players])}")
        self.magazine += self.generate_magazine()
        bullets_counts = self.get_magazine_bullets()
        self.wait(2)
        self.say(f"第 1 回合，装填子弹... {str(['真'] * bullets_counts[0] + ['空'] * bullets_counts[1])}")
        self.wait(2)
        self.player_new_action()

    def player_entrance(self, player_name, choice):
        # 校验玩家是否为本次玩家
        current_player_name = self.next_player.name
        if player_name == current_player_name:
            self.player_round(self.next_player, choice)
        else:
            print(f"非{player_name}回合，现在轮到 {current_player_name} ")

    def player_new_action(self, is_continues=False):
        str_action = "\033[33m1\033[0m. 开枪（指向自己） | \033[33m2\033[0m. 开枪（指向对方） | （还没写完）3. 使用道具"
        if is_continues:
            self.say(f"{self.next_player.name} 请继续操作：{str_action}")
        else:
            self.say(f"{self.next_player.name} 请选择操作：{str_action}")

    def player_round(self, current_player, choice):
        is_switch = True
        player_name = current_player.name
        if player_name == self.pc_name:
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
                if current_player.items:
                    item = random.choice(current_player.items)
                    current_player.use_item(item, self.choose_player())
                else:
                    print(f"{g_dr_prefix} {self.pc_name}没有道具，跳过回合。")
        else:
            action = self.actions[choice - 1]
            print(f"{g_dr_prefix} {action}")
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

                # is_continue_turn = False
            # elif choice == "3":
            #     if not current_player.items:
            #         print("你没有道具！")
            #         continue
            #     print("你的道具：", current_player.items)
            #     item_choice = input("请输入要使用的道具名称：")
            #     if item_choice in current_player.items:
            #         current_player.use_item(item_choice, other_player)
            #         result = False
            #     else:
            #         print("无效的道具！")
            #         continue
            else:
                print(f"{g_dr_prefix} 无效选项！")
                return

        # 胜利检查
        self.wait(2)
        self.say(" | ".join(player.show_status() for player in self.players))

        alive_count = sum(player.is_alive() for player in self.players)
        if alive_count == 1:
            for player in self.players:
                if player.name in g_dr_player_index_table:
                    del g_dr_player_index_table[player.name]
            for player in self.players:
                if player.is_alive():
                    self.say(f"{player.name} 获胜！")
                    self.room.room_status = 3
                    self.win({player.name: player.is_alive() for player in self.players})
                    print(f"g_dr_player_index_table: {g_dr_player_index_table}")
                    return
        
        if not self.magazine:
            # 不要使用赋值，player有引用
            self.magazine += self.generate_magazine()
            # for player in self.players:
            #     player.magazine = self.magazine
            #     # self.give_items(player)
            bullets_counts = self.get_magazine_bullets()
            self.say(f"，弹夹已空，装填子弹... {str(['真'] * bullets_counts[0] + ['空'] * bullets_counts[1])}")

        if is_switch:
            # 交换
            self.switch_action()
            if self.switch_count % self.player_count == 0:
                self.turn += 1
                self.wait(1)
                # if not self.magazine:
                #     # 不要使用赋值，player有引用
                #     self.magazine += self.generate_magazine()
                #     # for player in self.players:
                #     #     player.magazine = self.magazine
                #     #     # self.give_items(player)
                #     bullets_counts = self.get_magazine_bullets()
                #     bullets_info = f"，弹夹已空，装填子弹... {str(['真'] * bullets_counts[0] + ['空'] * bullets_counts[1])}"
                # else:
                #     bullets_info = ""

                # self.say(f"第 {self.turn} 回合{bullets_info}")
                self.say(f"第 {self.turn} 回合")

            # 如果下一个是电脑，自动执行
            if self.next_player.name == self.pc_name:
                self.say("电脑回合")
                self.player_round(self.next_player, random.randint(1, 2))
                return
            else:
                # 玩家
                self.player_new_action()
        else:
            # 打向自己是空弹，当前玩家继续
            if player_name == self.pc_name:
                self.say("继续电脑回合")
                self.player_round(current_player, random.randint(1, 2))
                return
            else:
                # 玩家
                self.player_new_action(True)



    def switch_action(self):
        # 交换回合
        self.switch_count += 1
        # 死亡的话移除players player_count减少
        self.current_player_index = self.loop_counter(self.switch_count, self.player_count - 1)
        print(f"{g_dr_prefix} current_player_index: {self.current_player_index}")
        self.next_player = self.players[self.current_player_index]

    def choose_player(self):
        if self.player_count == 2:
            return self.players[1 - self.current_player_index]
        else:
            # todo
            return self.players[1 - self.current_player_index]

    def generate_magazine(self, live_bullets=None):
        if live_bullets is None:
            # live_bullets = self.get_total_health()
            # if live_bullets > self.max_live_bullets:
            #     live_bullets = self.max_live_bullets
            live_bullets = random_add_empty = random.randint(2, 3)

        # 随机可能多一个空弹
        random_add_empty = random.randint(0, 1)
        empty_bullets = live_bullets + random_add_empty
        # self.bullets["live_bullets"] = live_bullets
        # self.bullets["empty_bullets"] = empty_bullets
        magazine = ["Live"] * live_bullets + ["Empty"] * empty_bullets
        # self.say(f'装填子弹... {str(["真" if bullet == "Live" else "空" for bullet in magazine])}')
        random.shuffle(magazine)
        return magazine

    # return list: Live, Empty
    def get_magazine_bullets(self):
        live = 0
        empty = 0
        for bullet in self.magazine:
            if bullet == "Live":
                live += 1
            elif bullet == "Empty":
                empty += 1
        return [live, empty]

    def give_items(self, player):
        for _ in range(2):
            item = random.choice(self.items)
            player.add_item(item)

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

    def hack_add_health(self, player_name=None):
        self.players[0].hp += 1

    def hack_add_live_bullets(self, live_bullets=None):
        pass


class DevilRouletteRoom:
    def __init__(self, room_id, player_limit=2):
        self.room_id = room_id
        self.player_limit = player_limit
        g_dr_room_list.append(self)
        self.room_status = 0  # 0: 需要创建, 1: wait, 2: game start, 3: game over
        self.player_number = 2
        self.default_health = 3

        self.pc_name = "电脑"
        self.game = None
        self.player_init_list = []
        self.message_buffer = []

    def enter_game(self, player_name):
        if player_name not in g_dr_player_index_table:
            g_dr_player_index_table[player_name] = {
                "room_id": self.room_id
            }
            self.player_init_list.append({"name": player_name, "hp": self.default_health})
            self.handel_mode()
        else:
            self.say(f"你已经在游戏里了")

    def enter_pc(self, player_name):
        # todo should delete
        self.pc_name = player_name
        if player_name not in g_dr_player_index_table:
            g_dr_player_index_table[player_name] = {
                "room_id": self.room_id
            }
            self.player_init_list.append({"name": player_name, "hp": self.default_health})
            self.handel_mode()
        else:
            self.say(f"你已经在游戏里了")

    def start_game(self):
        global g_dr_room_index
        self.room_status = 2
        self.game = DevilRoulette(self)
        self.game.game_start()
        g_dr_room_index += 1

    def handel_mode(self):
        player_count = len(self.player_init_list)

        if player_count == 0:
            self.room_status = 0
        elif player_count == 1:
            self.room_status = 1
            self.say(f"欢迎进入游玩恶魔轮盘游戏！等待玩家中... {player_count}/{self.player_number}")
        elif player_count == self.player_number:
            self.start_game()
        elif player_count < self.player_number:
            self.say(f"欢迎进入游玩恶魔轮盘游戏！等待玩家中... {player_count}/{self.player_number}")
        else:
            self.say(f"错误：player_count: {player_count} | player_number: {self.player_number}")

    def quit_game(self, player_name):
        del g_dr_player_index_table[player_name]
        self.del_player_from_list()
        self.handel_mode()
        # print(f"玩家 {self.player_name} 进入房间 {self.room_id} 的恶魔轮盘游戏！")

    def set_room_health(self, health):
        self.default_health = health
        for player_name in self.player_init_list:
            self.player_init_list[player_name] = health

    def set_player_health(self, player_name, health):
        self.player_init_list[player_name] = health

    # 暂不考虑
    def set_player_number(self, player_number):
        self.player_number = player_number
        if len(self.player_init_list) == player_number:
            self.room_status = 2
            # start_game()

    def del_player_from_list(self, quit_player):
        for player in self.player_init_list:
            if player["name"] == quit_player:
                self.player_init_list.remove(player)
                break
        else:
            print(f"{g_dr_prefix} quit没找到 {quit_player}")

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


if __name__ == "__main__":
    def say(message):
        print(f"{message}")


    def wait(sec):
        time.sleep(sec)

    def win(sec):
        pass


    # 创建房间
    command_table = {
        "say": say,
        "wait": wait,
        "win": win
    }

    # if not g_dr_data:
    #     g_dr_data = {
    #         "chinese": {
    #             "Live": "真",
    #             "Empty": "空"
    #         }
    #     }

    test_room = DevilRouletteRoom(g_dr_room_index)
    test_room.message_buffer.clear()
    test_room.enter_game("XD")
    for buffer in test_room.message_buffer:
        command_table[buffer[0]](**buffer[1])
    test_room.message_buffer.clear()
    # print(f"g_dr_room_index: {g_dr_room_index}")
    test_room.enter_game("电脑")
    for buffer in test_room.message_buffer:
        command_table[buffer[0]](**buffer[1])
    while True:
        # print(f"g_dr_room_index: {g_dr_room_index}")
        tchoice = int(input("："))
        test_room.message_buffer.clear()
        test_room.game.player_entrance("XD", tchoice)

        for buffer in test_room.message_buffer:
            command_table[buffer[0]](**buffer[1])
