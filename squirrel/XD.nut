
global function PrintMessageList
global function playerQuitGame
global function printHistoryMessage
global function HistroyMessageUp
global function HistroyMessageDown
global function SayHistroyMessage
global function GetRandomColor
global function PyXD_Init
global function LoadChatJsonData
global isPinyinOpen = 2
// global table<string,var> XD_table = {}
global controlList = []
// key_9功能删掉后和删除↓列表
global localMessageHistory = [["","say "],["","say "],["","say "],["","say "],["","say "],["","say "]]
global int isControl = 0
global isMoveList = [false,false,false,false,false,false,false,false ,false,false,false,false,false,false]

global float printMessageLastTime = 0

global messageList = []
global bool cmdStop = false
global bool sudoStop = false

global board <- [
    ["    ", "    ", "    "],
    ["    ", "    ", "    "],
    ["    ", "    ", "    "]
];
// global pinyinTable = {}  COMPILE ERROR Too many table / class properties
global float printBoardTime = 0

global array tempOp = []

global int TicTacToeState = 0
global int TicTacToeCount = 0
global string TicTacToeFirstPlayer = ""
global string TicTacToeSecondPlayer = ""
global bool isTicTacToeFirst = true

global int historyMessageIndex = 0
global historyMessageText = ["","say "]
global lastStringRui = null

global bool isShouldPy = true 
global bool pyState = false
global int pyWaitCount = 0
global float lastPyTime = 0 



void function ClearKillCountFromRecordObituary(entity victim){
	string victimName = victim.GetPlayerName()
	for (int i = 0; i < playerObituary.len(); i++) {
		if ( playerObituary[i][0] == victimName ){
			playerObituary[i][2] = 0
			// 可能有多个 不能break
		}
    }
	for (int i = 0; i < playerTotalObituary.len(); i++) {
		if ( playerTotalObituary[i][0] == victimName ){
			playerTotalObituary[i][1] = 0
			break
		}
    }
	// 如果箭头的那个人复活，则往左挪
	if ( IsWatchingSpecReplay() && isMeleePrint == false && victimName == arrowPlayerNow ){
		thread specMoveleft()
	}
	// for ( int i = player.e.recentDamageHistory.len() - 1; i >= 0; i-- )
	// {
	// 	DamageHistoryStruct history = player.e.recentDamageHistory[ i ]

	// 	if ( history.time > removeTime )
	// 		return

	// 	player.e.recentDamageHistory.remove( i )
	// }
			// if ( victimName == "Spacedog20062022" ){
		// 	localPlayer.ClientCommand("say " + "复活了")
		// }
}

void function leftGameClearKillCountFromRecordObituary(string PlayerNameClan){
	local start2 = PlayerNameClan.find("] ")
	string leftGamePlayerName = PlayerNameClan
	if (start2 != null ){
		leftGamePlayerName = PlayerNameClan.slice(start2 + 2)
	}
	for (int i = 0; i < playerObituary.len(); i++) {
		if ( playerObituary[i][0] == leftGamePlayerName ){
			playerObituary[i][2] = 0
			// 可能有多个 不能break
		}
    }
	for (int i = 0; i < playerTotalObituary.len(); i++) {
		if ( playerTotalObituary[i][0] == leftGamePlayerName ){
			playerTotalObituary[i][1] = 0
			return
		}
    }
}

int function getObituaryIndex(attackerName, weaponName, victimName) {
	int index = -1
	if ( weaponName == "磁吸地雷" ) {
		local isLandmineDuplicate = false
		foreach ( landmineName in landmineBlackList ){
			if ( attackerName == landmineName ) {
				isLandmineDuplicate = true
				break
			}
		}
		if (!isLandmineDuplicate) {
			landmineBlackList.push(attackerName);
			// isPrintLandmine = true
		}
	}
    // for (int i = 0; i < playerObituary.len(); i++) {
	// 	local playerNameObituary = playerObituary[i][0]
	// 	local playerWeaponNameObituary = playerObituary[i][1]
    //     if ( playerNameObituary == attackerName && playerWeaponNameObituary == weaponName) {
    //         index = i
    //     }
	// 	if ( playerNameObituary == victimName ){
	// 		playerObituary[i][2] = 0
	// 	}
    // }
	for (int i = 0; i < playerObituary.len(); i++) {
        if ( playerObituary[i][0] == attackerName && playerObituary[i][1] == weaponName) {
            index = i
			break
        }
    }
	for (int i = 0; i < playerObituary.len(); i++) {
		if ( playerObituary[i][0] == victimName ){
			playerObituary[i][2] = 0
			// 可能有多个 不能break
		}
    }
    return index
}
int function getTotalObituaryIndex(attackerName, weaponName, victimName, entity localPlayer) {
	int index = -1
	bool isFindVictim = false
    for (int i = 0; i < playerTotalObituary.len(); i++) {
        if ( playerTotalObituary[i][0] == attackerName ) {
            index = i
			break
        }
    }
	for (int i = 0; i < playerTotalObituary.len(); i++) {
		if ( playerTotalObituary[i][0] == victimName ){
			isFindVictim = true
			local playerTotalKillInRow = playerTotalObituary[i][1]
			if ( playerTotalKillInRow >= 10 && playerTotalKillInRow < 15 ){
				if ( weaponName != "invalid" ){
					if ( attackerName != "" ){
						// 目前看来只会是自杀
						if ( isAutoPrintRestrictedMod == 1 || isAutoPrintRestrictedMod == 3 ){
							localPlayer.ClientCommand("say 我们有救了！" + attackerName + "使用「" + weaponName + "」中断了" + victimName + "的" + playerTotalKillInRow + "连杀！" )
						} else {
							print("我们有救了！" + attackerName + "使用「" + weaponName + "」中断了" + victimName + "的" + playerTotalKillInRow + "连杀！")
						}
					} else {
						if ( isAutoPrintRestrictedMod == 1 || isAutoPrintRestrictedMod == 3 ){
							localPlayer.ClientCommand("say 我们有救了！" + victimName + "使用「" + weaponName + "」中断了TA自己的" + playerTotalKillInRow + "连杀！" )
						} else {
							print("我们有救了！" + victimName + "使用「" + weaponName + "」中断了TA自己的" + playerTotalKillInRow + "连杀！" )
						}
					}
				} else {
					if ( isAutoPrintRestrictedMod == 1 || isAutoPrintRestrictedMod == 3 ){
						localPlayer.ClientCommand("say 最终，无人能够终结" + victimName + "的" + playerTotalKillInRow + "连杀"  )
					} else {
						print("最终，无人能够终结" + victimName + "的" + playerTotalKillInRow + "连杀")
					}
				}


			} else if ( playerTotalKillInRow >= 15 ){
				if ( weaponName != "invalid" ){
					if ( attackerName != "" ){
						if ( isAutoPrintRestrictedMod == 1 || isAutoPrintRestrictedMod == 3 ){
							localPlayer.ClientCommand("say 一刻也没有为" + victimName + "哀悼！" + attackerName + "使用「" + weaponName + "」中断了TA的" + playerTotalKillInRow + "连杀！结束了罪恶的一生" )
						} else {
							print("一刻也没有为" + victimName + "哀悼！" + attackerName + "使用「" + weaponName + "」中断了TA的" + playerTotalKillInRow + "连杀！结束了罪恶的一生")
						}
					} else {
						if ( isAutoPrintRestrictedMod == 1 || isAutoPrintRestrictedMod == 3 ){
							localPlayer.ClientCommand("say 一刻也没有为" + victimName + "哀悼！TA自己使用「" + weaponName + "」中断了TA自己的" + playerTotalKillInRow + "连杀！结束了罪恶的一生" )
						} else {
							print("一刻也没有为" + victimName + "哀悼！TA自己使用「" + weaponName + "」中断了TA自己的" + playerTotalKillInRow + "连杀！结束了罪恶的一生")
						}
					}
				} else {
					if ( isAutoPrintRestrictedMod == 1 || isAutoPrintRestrictedMod == 3 ){
						localPlayer.ClientCommand("say 最终，无人能够终结" + victimName + "的" + playerTotalKillInRow + "连杀"  )
					} else {
						print("最终，无人能够终结" + victimName + "的" + playerTotalKillInRow + "连杀")
					}
				}
			}
			playerTotalObituary[i][1] = 0
			playerTotalObituary[i][2] = Time()
			break
		}
    }
	if ( !isFindVictim ) {
		playerTotalObituary.append([victimName, 0, Time()]);
	}
    return index
}

int function isWeaponValid(weaponName){
	for (int i = 0; i < weaponValidList.len(); i++) {
        if ( weaponName == weaponValidList[i][0] ) {
            return i
        }
	}
	return -1
}



string function checkAShieldOrCover( entity attacker ){
	array <entity> offhand = attacker.GetOffhandWeapons()
	if ( offhand.len() > 1 && offhand[1] != null ){
		if ( offhand[1].GetWeaponClassName() == "mp_weapon_deployable_cover"){
			return "A盾"
		}
		if ( offhand[1].GetWeaponClassName() == "mp_ability_cloak"){
			return "隐身"
		}
	}
	return ""
}

void function specMoveright(){
	wait 2.5
	GetLocalClientPlayer().ClientCommand("+moveright")
	wait 0.001
	GetLocalClientPlayer().ClientCommand("-moveright")
}

void function specMoveleft(){
	GetLocalClientPlayer().ClientCommand("+moveleft")
	wait 0.001
	GetLocalClientPlayer().ClientCommand("-moveleft")
}

bool function isStopOiiai(){
	if(!isMeleePrint){
		GetLocalClientPlayer().ClientCommand("-forward")
		GetLocalClientPlayer().ClientCommand("-duck")
		GetLocalClientPlayer().ClientCommand("-left")
		GetLocalClientPlayer().ClientCommand("-right")
		GetLocalClientPlayer().ClientCommand("-moveleft")
		GetLocalClientPlayer().ClientCommand("-moveright")
		GetLocalClientPlayer().ClientCommand("-offhand1")
		return true
	}
	return false
}

void function xdoiiaioiiiiai(entity localPlayer, bool isSay){
	if (isSay){
		localPlayer.ClientCommand("say \"" + GetRandomColor() + "oiiaioiiiiai~[0m\"");
	}
	wait 4
	if ( isStopOiiai() ) return
	GetLocalClientPlayer().ClientCommand("+jump")
	wait 0.01
	GetLocalClientPlayer().ClientCommand("-jump")
	GetLocalClientPlayer().ClientCommand("+forward")
	GetLocalClientPlayer().ClientCommand("+left")
	GetLocalClientPlayer().ClientCommand("+duck")
	for(int i=0; i>20; i++){
		GetLocalClientPlayer().ClientCommand("+forward")
		wait 0.1
		GetLocalClientPlayer().ClientCommand("-forward")
		wait 0.8
		if ( isStopOiiai() ) return
	}
	GetLocalClientPlayer().ClientCommand("+jump")
	GetLocalClientPlayer().ClientCommand("-duck")
	GetLocalClientPlayer().ClientCommand("-forward")
	wait 0.01
	GetLocalClientPlayer().ClientCommand("-jump")
	GetLocalClientPlayer().ClientCommand("+forward")
	wait 5
	if ( isStopOiiai() ) return
	GetLocalClientPlayer().ClientCommand("-forward")
	wait 5
	if ( isStopOiiai() ) return
	GetLocalClientPlayer().ClientCommand("+forward")
	GetLocalClientPlayer().ClientCommand("+jump")
	GetLocalClientPlayer().ClientCommand("-left")
	GetLocalClientPlayer().ClientCommand("+right")
	GetLocalClientPlayer().ClientCommand("-forward")
	wait 0.01
	GetLocalClientPlayer().ClientCommand("+duck")
	GetLocalClientPlayer().ClientCommand("-jump")
	// GetLocalClientPlayer().ClientCommand("+offhand0")
	wait 0.01
	// GetLocalClientPlayer().ClientCommand("-offhand0")
	GetLocalClientPlayer().ClientCommand("-offhand1")
	GetLocalClientPlayer().ClientCommand("+forward")
	wait 5
	if ( isStopOiiai() ) return
	GetLocalClientPlayer().ClientCommand("-right")
	GetLocalClientPlayer().ClientCommand("+left")
}

// void function lastPlayerEnterGame(string playerName){
// 	lastPlayerEnterGameName = [playerName, Time()]
// }萌新服不一定有进入游戏标志
void function setIsYangLaoFu(){
	AFKMode = 1
	print(  " !!!!isYangLaoFuisYangLaoFuisYangLaoFuisYangLaoFuisYangLaoFuisYangLaoFu!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" )
	wait 10
	isYangLaoFu = true
	if ( isMeleePrint ){
		for(int i=0; i<30; i++){
			if (MengXinFuAFKInit("-")) return
			wait 1
			if (MengXinFuAFKInit("+")) return
			wait 0.5
		}
		GetLocalClientPlayer().ClientCommand("+offhand1")
		wait 0.01
		GetLocalClientPlayer().ClientCommand("-offhand1")
		xdoiiaioiiiiai(GetLocalClientPlayer(), false)
	}
	if ( !isMeleePrint ){
		GetLocalClientPlayer().ClientCommand("-forward")
		GetLocalClientPlayer().ClientCommand("-duck")
		GetLocalClientPlayer().ClientCommand("-left")
		GetLocalClientPlayer().ClientCommand("-right")
		GetLocalClientPlayer().ClientCommand("-moveleft")
		GetLocalClientPlayer().ClientCommand("-moveright")
		GetLocalClientPlayer().ClientCommand("-offhand1")
		return
	}
}

void function preventInvaild(string attackerName){
	preventSecondInvaild[attackerName] <- Time()
	// if( preventSecondInvaild.rawin( attackerName )) {
		print(preventSecondInvaild[attackerName])	
	// }
	wait 5
	delete preventSecondInvaild[attackerName]

}

void function setIsMengXinFu(){
	if ( !isMengXinFu ){
		AFKMode = 1
		print( " !!!!isMengXinFuisMengXinFuisMengXinFuisMengXinFuisMengXinFuisMengXinFuisMengXinFuisMengXinFuisMengXinFu!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" )
		wait 2
		isMengXinFu = true
		if ( isMeleePrint ){
			for(int i=0; i<30; i++){
				if (MengXinFuAFKInit("-")) return
				wait 1
				if (MengXinFuAFKInit("+")) return
				wait 0.5
			}
			xdoiiaioiiiiai(GetLocalClientPlayer(), false)
		}
		if ( !isMeleePrint ){
			GetLocalClientPlayer().ClientCommand("-forward")
			GetLocalClientPlayer().ClientCommand("-duck")
			GetLocalClientPlayer().ClientCommand("-left")
			GetLocalClientPlayer().ClientCommand("-right")
			GetLocalClientPlayer().ClientCommand("-moveleft")
			GetLocalClientPlayer().ClientCommand("-moveright")
			GetLocalClientPlayer().ClientCommand("-offhand1")
			return
		}
	}
}

// void function uniqueListPush(array List)

void function checkInvalidBan(string playerName){
	wait 0.1
	if ( lastPlayerInvalid[2] && isMengXinFu ){
		// 结束时可能会invalid避免一下 (X+battletime) - (X+passtime)
		// y剩余时间 = X + battletime - X - passtime, X无法求解
		if (GetScoreEndTime() - Time() > -7){
			if( !preventSecondInvaild.rawin( playerName )) {
				GetLocalClientPlayer().ClientCommand("say 【XDbot】超级大笨蛋 " + playerName + " 在被踢后尝试再次加入，未果")
				thread XDPlaySound( "music_s2s_00a_intro" )
				print("【Ban】invalid 无击杀判定为再次加入: " + (Time() - lastPlayerInvalid[1]) + " expect 0.1" )
			}
			// bool isNotInAlreadyBan = true
			// foreach( banPlayerName in alreadyBanMXFList ){
			// 	if(playerName == banPlayerName ){
			// 		isNotInAlreadyBan = false
			// 	}
			// }
			// if ( isNotInAlreadyBan ){
			// 	alreadyBanMXFList.push(playerName)
			// }
			// 结束时间
			// [SCRIPT CL] [info] time: 0:-747
			// [SCRIPT CL] [info] time: 0:-748
			// [SCRIPT CL] [info] time: 0:-749
			// [SCRIPT CL] [info] time: 0:-750
			// [SCRIPT CL] [info] time: 0:-751
		}
	}
}

void function checkInvalidBanNotVeryPossible(string playerName, killInRow){
	wait 0.1
	if ( lastPlayerInvalid[2] && isMengXinFu){
		if (GetScoreEndTime() - Time() > -7){
			GetLocalClientPlayer().ClientCommand("say 【XDbot】大笨蛋 " + playerName + " 被踢出了游戏！")
			thread XDPlaySound( "music_s2s_00a_intro" )
			// alreadyBanMXFList.push(playerName)
			print("【Ban】invalid有击杀记录: " + killInRow + " 连杀" )
			thread preventInvaild(playerName)
		}
	}
}

int function indexPlayerHasKill(string playerName){
    for (int i = 0; i < playerTotalObituary.len(); i++) {
        if ( playerTotalObituary[i][0] == playerName ) {
			return i
        }
    }
	return -1
}

void function recordObituary(string attackerName, string weaponName, string victimName, entity attacker, entity victim, bool isHeadShot){
	entity localPlayer = GetLocalClientPlayer()
	local localPlayerName = localPlayer.GetPlayerName()
	if ( IsWatchingSpecReplay() && isMeleePrint == false && victimName == arrowPlayerNow ){
		thread specMoveright()
	}
	if ( attackerName == localPlayerName ){
		print( "kill, " + attackerName + " |" + weaponName + "| " + victimName )
	} else if ( victimName == localPlayerName ){
		print( "death, " + attackerName + " |" + weaponName + "| " + victimName )
		if( attackerName != "" ){
			if ( weaponName == "Melee" && (isAutoPrintRestrictedMod == 1 || isAutoPrintRestrictedMod == 3) ){
				switch (attackerName) {
					case "Quietmirror":
						// for (int i = 0; i < 5; i++) {
							localPlayer.ClientCommand("say 【XDbot】: 被杂鱼镜子肘击！Man!!!")
						// }
						break
					case "xlxlxl24":
						localPlayer.ClientCommand("say 【XDbot】: 被笨蛋小龙肘击！Man!!!")
						break
					case "ButterfI1es":
						localPlayer.ClientCommand("say 【XDbot】: 被飞翔的河南人肘击！Man!!!")
						break
					case "cmggy":
						localPlayer.ClientCommand("say 【XDbot】: 被吸爱慕积极歪肘击！Man!!!")
						break
					default:
						localPlayer.ClientCommand("say 【XDbot】: 被" + attackerName + "肘击！Man!!!");
						break
				}
			}
			if ( weaponName == "Execution" && (isAutoPrintRestrictedMod == 1 || isAutoPrintRestrictedMod == 3) ){
				switch (attackerName) {
					case "Quietmirror":
						// for (int i = 0; i < 5; i++) {
							localPlayer.ClientCommand("say bruh，被杂鱼镜子处决力_(:з」∠)_")
						// }
						break
					case "xlxlxl24":
						localPlayer.ClientCommand("say bruh，被笨蛋小龙处决力_(:з」∠)_")
						break
					case "ButterfI1es":
						localPlayer.ClientCommand("say bruh，被笨蛋540处决力_(:з」∠)_")
						break
					default:
						localPlayer.ClientCommand("say bruh，被笨蛋" + attackerName + "处决力_(:з」∠)_");
						break
				}
			}
			if ( AFKMode == 5 ){
				deathCount2 ++
				local constAgain = ""
				local num = deathCount2 - 1
				local num4Count = 0
				while ( num >= 4 ){
					num = num - 4
					num4Count ++
				}
				for (local i = 1; i <= num4Count; i++) {
					constAgain += "叕"
				}
				switch ( num ) {
					case 1:
						constAgain += "又"
						break
					case 2:
						constAgain += "双"
						break
					case 3:
						constAgain += "叒"
						break
					default:
						break
				}
				localPlayer.ClientCommand("say 【XDbot】: " + constAgain + "似了")
				local headShotString = ""
				if ( isHeadShot ){
					headShotString = "爆头"
				}
				if ( attacker.IsPlayer() ) {
					localPlayer.ClientCommand("say 【XDbot】: 挂机写代码被" + attacker.GetPlayerName() + "使用「" +  weaponName + "」" + headShotString + "攻击");
				}
	
	
				// weaponLocalizationName[attacker.GetActiveWeapon().GetWeaponClassName()] 不存在方法
				// ObitStringData obitStringData
				// Assert( typeof( obitStringData.weaponLocalizedName ) == "string" ) 空
				// localPlayer.ClientCommand("say 被" + obitStringData.weaponLocalizedName + "打死了");
			}
			if( (isMengXinFu || isYangLaoFu) && isMeleePrint){
				thread xdoiiaioiiiiai(localPlayer, true)
			}
		} else {
			if( (isMengXinFu || isYangLaoFu) && isMeleePrint){
				thread xdoiiaioiiiiai(localPlayer, false)
			}
		}
	} else {
		print( attackerName + " |" + weaponName + "| " + victimName )
	}
	// 00 11 01 10
	// 1: 开始分析 关闭近战 2.旧模式 不分析 关闭近战 3.体现分析最混乱的一集
	if (AFKMode == 1){
		if(	isMengXinFu && weaponName == "invalid"){
			// foreach(banPlayerName in alreadyBanMXFList ){
			// 	if(playerName == banPlayerName){
			// 		print("invalid 因被ban过所以判定为再次加入")
			// 		GetLocalClientPlayer().ClientCommand("say 【XDbot】超级大笨蛋 " + playerName + " 在被踢后尝试再次加入，未果")
			// 		thread XDPlaySound( "music_s2s_00a_intro" )
			// 		return
			// 	}
			// }
			lastPlayerInvalid = [victimName, Time(), true]
			int banIndex = indexPlayerHasKill(victimName)
			if ( banIndex == -1 ){
				print("一进来就来了个尝试重进的")
				thread checkInvalidBan(victimName)
			} else {
				// 有index 此时拿到的还没有因为invalid清除连杀
				local banPlayerKillInRow = playerTotalObituary[banIndex][1]
				if(banPlayerKillInRow == 0) {
					// 这个时候还没清除连杀 可能为 我进入 他似了产生index 然后又kill被踢
					print("有index击杀数为0, 可能似了第一个kill，可能重进的")
					thread checkInvalidBan(victimName)
				} else {
					// 有index有连杀 防止invalid后面无击杀漏判 但是如果前面没kill突然来了个无击杀会误判成再次加入，但还是没有见过
					// print("invalid有击杀记录，不可能是重进，判定为被ban")
					thread checkInvalidBanNotVeryPossible(victimName, banPlayerKillInRow)
				}
			}
			// if (victimName == lastPlayerEnterGameName[0] && Time() - lastPlayerEnterGameName[1] < 0.5 ){
			// 	// 萌新服进入游戏被invalid
			// 	localPlayer.ClientCommand("say 【XDbot】超级大笨蛋 " + victimName + " 在被踢后尝试再次加入，未果")
			// 	thread XDPlaySound( "music_s2s_00a_intro" )
			// 	print("萌新服进入invalid判定用时：" + (Time() - lastPlayerEnterGameName[1]) )
			// }萌新服不一定有进入游戏标志
		}
		// 养老服的
		if ( isYangLaoFu && attacker == null ){
			// burn Tried to Flee the Battle
			// [SCRIPT CL] [info]     attacker: entity (0: class C_World [0])
			// [SCRIPT CL] [info]     attacker classname: class C_World
			// print("null attacker  " + weaponName + " " + Time())
			NullAttackerBan()
		}
	}
	if ( victim != null && attacker != null && victim.IsPlayer() && !attacker.IsTitan()  ){
// [SCRIPT CL] [info] ------------------------------------------
// [SCRIPT CL] [info]  FULL OBITUARY INFO COULD NOT BE RESOLVED
// [SCRIPT CL] [info]     attacker: null
// [SCRIPT CL] [info]     victim: entity (5: player [5])
// [SCRIPT CL] [info]     victim classname: player
// [SCRIPT CL] [info]     victimOwner: null
// [SCRIPT CL] [info]     scriptDamageType: 66560
// [SCRIPT CL] [info]     damageSourceId: 95
// [SCRIPT CL] [info]     sourceDisplayName: CAR
// [SCRIPT CL] [info] ------------------------------------------
// [SCRIPT CL] [info]  |CAR| tong-zhi-233
// [SCRIPT CL] [info] SCRIPT ERROR: [CLIENT] Given object is not an entity (type = null)
// [SCRIPT CL] [info]  -> if ( victim.IsPlayer() && !attacker.IsTitan()  ){
		// if ( attackerName == null ){
		// 	print("null")
		// }
		// if ( attackerName == "" ){
		// 	print("kong")
		// } 自杀时为空
		if ( weaponName == "Archer" ){
			weaponName = "炸彈無人機"
		}




		// if ( attackerName == "" && attacker.IsPlayer() && attacker.GetPlayerName() != victim.GetPlayerName() ){
		// 	print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" + attackerName + " |" + weaponName + "| " + victimName + "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" + "自杀时有实际攻击者" + attacker.GetPlayerName() )
		// 	local WarningText = "!!!!!!" + attackerName + " |" + weaponName + "| " + victimName + "!!!!!!!!!!" + "自杀时有实际攻击者" + attacker.GetPlayerName()



		// 关于自杀清空 有击杀后自杀一定可以被清零 没问题
		local index = getObituaryIndex(attackerName, weaponName, victimName)
		local indexTotal = getTotalObituaryIndex(attackerName, weaponName, victimName, localPlayer)

		local playerWeaponKillInRowCount = 0
		local playerKillInRowCount = 0
		bool isRealAlive = true
		if ( IsWatchingReplay() ){
			if ( indexTotal != -1 ){
				if ( Time() - playerTotalObituary[indexTotal][2] <= 4 ){
					isRealAlive = false
					// 上一次死亡少于4秒，似了
				}
			}
		} else {
			isRealAlive = IsAlive(attacker)
		}


		if ( attackerName != "" && attacker.IsPlayer() ) {
			// if ( !IsAlive(attacker) ){
			// 	if ( weaponName != "炸彈無人機" ){
			// 		print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" + attackerName + " |" + weaponName + "| " + victimName + "似了但是kill" + attacker.GetPlayerName() )
			// 	}
			// }
			// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!ARTnend |CAR| WTQtrs似了但是killARTnend
			// if ( IsAlive(attacker) )
			if ( AFKMode == 1 ){
				// 判定kill
				if (isYangLaoFu) {
					// kill - left game
					setLastGlobalkill(attacker.GetPlayerNameWithClanTag(), Time())
				}
				if (isMengXinFu) {
					// invalid - kill
					if (attackerName == lastPlayerInvalid[0]){
						if(Time() - lastPlayerInvalid[1] < 0.1){
							lastPlayerInvalid[2] = false
							localPlayer.ClientCommand("say 【XDbot】大笨蛋 " + attackerName + " 被踢出了游戏！")
							thread XDPlaySound( "music_s2s_00a_intro" )
							// alreadyBanMXFList.push(attackerName)
							print("【Ban】invalid 到有击杀ban用时: " + (Time() - lastPlayerInvalid[1]) + " expect 0")
							thread preventInvaild( attackerName )
							// 萌新服击杀时 先invalid 同时立即 产生击杀
							// [SCRIPT CL] [info] invalid ban用时: 0
							// [21:08:57] [SCRIPT CL] [info] XyLove47 |CAR| moyoyakrtiger
							// [21:08:57] [NORTHSTAR] [info] [BOT] Pathstar_XD
							// [21:08:58] [SCRIPT CL] [info] ABHHJN |Melee| hua1339
							// [21:08:59] [SCRIPT CL] [info] XyLove47 has left the game
						}
					}
				}
				
			}
			if ( isRealAlive ) {
				if (index == -1) {
					// 此玩家新的击杀
					if ( weaponName != "炸彈無人機"){
						playerObituary.append([attackerName, weaponName, 1]);
						playerWeaponKillInRowCount = 1
						if ( weaponName == "Predator Cannon" ){
							if ( isAutoPrintRestrictedMod == 1 || isAutoPrintRestrictedMod == 3 ){
								localPlayer.ClientCommand("say " + "太残暴了！" + attackerName + "使用神器「无赖装甲」开启了TA的屠杀！" )
							} else {
								print("太残暴了！" + attackerName + "使用神器「无赖装甲」开启了TA的屠杀！")
							}
						}
					}
					// index = playerObituary.len() - 1;
				} else {
					playerObituary[index][2] ++
					playerWeaponKillInRowCount = playerObituary[index][2]
				}

				if (indexTotal == -1) {
					playerTotalObituary.append([attackerName, 1, 0]);
					playerKillInRowCount = 1
					return
				} else {
					if ( weaponName != "Predator Cannon" ){
						playerTotalObituary[indexTotal][1] ++
						playerKillInRowCount = playerTotalObituary[indexTotal][1]
					}
				}
			}
			// if (  attacker.IsPlayer() && attackerName == "" ){
			// 	print("kongaaaaaaaaaaaaa")
			// }  居然也可以
		} else {
			return
		}

		// test
		// if ( attackerName == localPlayerName ) {
		// 	print(attackerName + "使用「" + weaponName + "」" + "达成了" + playerWeaponKillInRowCount + "连杀！总共已经" + playerKillInRowCount + "连杀了！")
		// }


		// if ( attacker == "Spacedog20062022" ){
		// 	if ( weaponName == "Frag Grenade" ){
		// 		localPlayer.ClientCommand("say " + "太强了！" + "Spacedog20062022使用了捏雷炸死了一个人！")
		// 	}
		// }
		// if ( victim == "Spacedog20062022" ){
		// 	localPlayer.ClientCommand("say " + "诶你怎么似了")
		// }

		if ( weaponName == "炸彈無人機" ) {
			local isBuObituaryDuplicate = false
			for (local i = 0; i < buObituary.len(); i++) {
				if ( attackerName == buObituary[i][0] ){
					if ( Time() - buObituary[i][1] > 6 ){
						buObituary[i][1] = Time()
						buObituary[i][2] = 1
					} else {
						buObituary[i][1] = Time()
						buObituary[i][2] ++
						local buKill = buObituary[i][2]
						if ( buKill >= 3 ) {
							// if ( attackerName != "" && attacker.IsPlayer() )  不需要 已经return了
							local KillInRowWord = ""
							if ( IsAlive(attacker) ){
								if (playerKillInRowCount >= 10 && playerKillInRowCount <= 14) {
									KillInRowWord = "总共已经" + playerKillInRowCount + "连杀了！我们还有救吗"
								} else if (playerKillInRowCount >= 15 && playerKillInRowCount <= 19) {
									KillInRowWord = "总共已经" + playerKillInRowCount + "连杀了！我们没救了"
								} else if (playerKillInRowCount >= 20) {
									KillInRowWord = "总共已经" + playerKillInRowCount + "连杀了！我们真的没救了"
								}
							}
							if ( isAutoPrintRestrictedMod == 1 || isAutoPrintRestrictedMod == 3 ){
								localPlayer.ClientCommand("say " + attackerName + "使用神器「炸弹无人机」连续炸死了" + buKill + "个人！" + KillInRowWord)
							} else {
								print(attackerName + "使用神器「炸弹无人机」连续炸死了" + buKill + "个人！")
							}
						}
					}
					isBuObituaryDuplicate = true
					break
				}
			}
			if ( !isBuObituaryDuplicate ){
				buObituary.append( [attackerName, Time(), 1] );
			}
		}

		// 下面的都是连杀 所以如果死了就跳过 死亡复活和击杀回放提前都是4秒 某人提前我4秒似了并最快时间复活 我看回放正好到我似了某人复活 于是乎某人复活后若四秒内拿到5连杀则不会被提醒 而且看起来根本不可能 但是似乎这个条件节省的资源极其少所以我还是注释掉吧
		// 而且似乎看来我不打算改了 根据死亡时间暂停记录四秒太麻烦了
		// if ( !IsAlive(attacker) ){
		// 	return
		// }
		local Offhand1String = ""

		if ( weaponName == "Pulse Blade" ){
			if ( playerWeaponKillInRowCount >= 3 ) {
				string meijiuleText = ""
				if (AFKMode == 1)  {             //之后改成地图判断 为了幽灵猎杀最好是服务器判断
					switch ( playerKillInRowCount )	{
						case 5:
							meijiuleText = "总共已经" + playerKillInRowCount + "连杀了！我们还有救吗"
							break
						case 10:
							meijiuleText = "总共已经" + playerKillInRowCount + "连杀了！我们真的还有救吗"
							break
						case 15:
							meijiuleText = "总共已经" + playerKillInRowCount + "连杀了！我们真的真的还有救吗"
							break
						default:
							break
					}
				}
				if ( isAutoPrintRestrictedMod == 1 || isAutoPrintRestrictedMod == 3 ){
					localPlayer.ClientCommand("say " + attackerName + "使用「脉冲刀」连续清空了" + playerWeaponKillInRowCount + "个人的分数！" + meijiuleText)
				} else {
					print(attackerName + "使用「脉冲刀」连续清空了" + playerWeaponKillInRowCount + "个人的分数！" + meijiuleText)
				}
			}
			return
		}
		if ( weaponName == "Smart Pistol" ) {
			if ( playerWeaponKillInRowCount >= 3 ) {
				if ( isAutoPrintRestrictedMod == 1 || isAutoPrintRestrictedMod == 3 ){
					localPlayer.ClientCommand("say " + attackerName + "使用神器「自瞄小手枪」连续锁了" + playerWeaponKillInRowCount + "个人！")
				} else {
					print(attackerName + "使用神器「自瞄小手枪」连续锁了" + playerWeaponKillInRowCount + "个人！")
				}
			}
			return
		}
		if ( weaponName == "SCP-018" ) {
			if ( playerWeaponKillInRowCount >= 3 ) {
				if ( isAutoPrintRestrictedMod == 1 || isAutoPrintRestrictedMod == 3 ){
					localPlayer.ClientCommand("say " + attackerName + "使用神器「SCP-018」连续弹死了" + playerWeaponKillInRowCount + "个人！")
				} else {
					print(attackerName + "使用神器「SCP-018」连续弹死了" + playerWeaponKillInRowCount + "个人！")
				}
			}
			return
		}

		if ( weaponName == "閃光彈" ){
			if ( isAutoPrintRestrictedMod == 1 || isAutoPrintRestrictedMod == 3 ){
				localPlayer.ClientCommand("say " + attackerName + "竟然使用神器「闪光弹」炸死了" + playerWeaponKillInRowCount + "个人！我们的眼睛没救了！")
			} else {
				print(attackerName + "竟然使用神器「闪光弹」炸死了" + playerWeaponKillInRowCount + "个人！我们的眼睛没救了！")
			}
			return
		}

		// 村规连杀
		switch ( playerWeaponKillInRowCount ) {
			case 3:
				switch(weaponName){
					case "磁吸地雷":
						string YouJiuMaKillInRow = ""
						if (playerKillInRowCount >= 5 && playerKillInRowCount != playerWeaponKillInRowCount){
							if ( playerKillInRowCount < 10 ){
								YouJiuMaKillInRow = "总共已经" + playerKillInRowCount + "连杀了！"
							} else if (playerKillInRowCount < 15){
								YouJiuMaKillInRow = "总共已经" + playerKillInRowCount + "连杀了！我们还有救吗"
							} else if (playerKillInRowCount < 20){
								YouJiuMaKillInRow = "总共已经" + playerKillInRowCount + "连杀了！我们没救了！"
							} else {
								YouJiuMaKillInRow = "总共已经" + playerKillInRowCount + "连杀了！我们真的没救了！"
							}
						}
						Offhand1String = checkAShieldOrCover(attacker)
						if ( isAutoPrintRestrictedMod == 1 || isAutoPrintRestrictedMod == 3 ){
							localPlayer.ClientCommand("say " + attackerName + "使用神器「" + Offhand1String + "地雷」" + "达成了" + playerWeaponKillInRowCount + "连杀！" + "是地雷战，我们没救了！" + YouJiuMaKillInRow )
						} else {
							print(attackerName + "使用神器「" + Offhand1String + "地雷」" + "达成了" + playerWeaponKillInRowCount + "连杀！" + "是地雷战，我们没救了！" + YouJiuMaKillInRow )
						}
						return
					case "Frag Grenade":
						string YouJiuMaKillInRow = ""
						if (playerKillInRowCount >= 5 && playerKillInRowCount != playerWeaponKillInRowCount){
							if ( playerKillInRowCount < 10 ){
								YouJiuMaKillInRow = "总共已经" + playerKillInRowCount + "连杀了！"
							} else if (playerKillInRowCount < 15){
								YouJiuMaKillInRow = "总共已经" + playerKillInRowCount + "连杀了！我们还有救吗"
							} else if (playerKillInRowCount < 20){
								YouJiuMaKillInRow = "总共已经" + playerKillInRowCount + "连杀了！我们没救了！"
							} else {
								YouJiuMaKillInRow = "总共已经" + playerKillInRowCount + "连杀了！我们真的没救了！"
							}
						}
						Offhand1String = checkAShieldOrCover(attacker)
						if ( isAutoPrintRestrictedMod == 1 || isAutoPrintRestrictedMod == 3 ){
							localPlayer.ClientCommand("say " + attackerName + "使用神器「" + Offhand1String + "手雷」" + "达成了" + playerWeaponKillInRowCount + "连杀！" + "要吃雷了！" + YouJiuMaKillInRow)
						} else {
							print(attackerName + "使用神器「" + Offhand1String + "手雷」" + "达成了" + playerWeaponKillInRowCount + "连杀！" + "要吃雷了！" + YouJiuMaKillInRow)
						}
						return
					case "Melee":
						string YouJiuMaKillInRow = ""
						if (playerKillInRowCount >= 5 && playerKillInRowCount != playerWeaponKillInRowCount){
							if ( playerKillInRowCount < 10 ){
								YouJiuMaKillInRow = "总共已经" + playerKillInRowCount + "连杀了！"
							} else if (playerKillInRowCount < 15){
								YouJiuMaKillInRow = "总共已经" + playerKillInRowCount + "连杀了！我们还有救吗"
							} else if (playerKillInRowCount < 20){
								YouJiuMaKillInRow = "总共已经" + playerKillInRowCount + "连杀了！我们没救了！"
							} else {
								YouJiuMaKillInRow = "总共已经" + playerKillInRowCount + "连杀了！我们真的没救了！"
							}
						}
						array <entity> weapons = attacker.GetMainWeapons()
						if( weapons[0].GetWeaponClassName() == "mp_weapon_sniper" ){
							if ( isAutoPrintRestrictedMod == 1 || isAutoPrintRestrictedMod == 3 ){
								localPlayer.ClientCommand("say " + "克莱伯从入门到拳脚精通！" + attackerName + "放弃了克莱伯，使用「肘击」" + "达成了" + playerWeaponKillInRowCount + "连杀！" + YouJiuMaKillInRow)
							} else {
								print("克莱伯从入门到拳脚精通！" + attackerName + "放弃了克莱伯，使用「肘击」" + "达成了" + playerWeaponKillInRowCount + "连杀！" + YouJiuMaKillInRow)
							}
						} else{
							if ( isAutoPrintRestrictedMod == 1 || isAutoPrintRestrictedMod == 3 ){
								localPlayer.ClientCommand("say " + attackerName + "拳脚精通！使用「肘击」" + "达成了" + playerWeaponKillInRowCount + "连杀！" + YouJiuMaKillInRow)
							} else {
								print(attackerName + "拳脚精通！使用「肘击」" + "达成了" + playerWeaponKillInRowCount + "连杀！" + YouJiuMaKillInRow)
							}
						}
						return
					default:
						local weaponIndex = isWeaponValid(weaponName)
						if ( weaponIndex != -1 ) {
							array <entity> offhand = attacker.GetOffhandWeapons()
							if ( offhand.len() > 1 && offhand[1] != null ){
								if ( offhand[1].GetWeaponClassName() == "mp_weapon_deployable_cover"){
									Offhand1String = "A盾"
									local weaponNameLocal = weaponValidList[weaponIndex][1]
									// local weaponIntro = weaponValidList[weaponIndex][2]
									if ( playerKillInRowCount == playerWeaponKillInRowCount ){
										if ( isAutoPrintRestrictedMod == 1 || isAutoPrintRestrictedMod == 3 ){
											localPlayer.ClientCommand("say " + attackerName + "使用神器「" + Offhand1String + weaponNameLocal + "」" + "达成了" + playerWeaponKillInRowCount + "连杀！鲨疯了！" )
										} else {
											print(attackerName + "使用神器「" + Offhand1String + weaponNameLocal + "」" + "达成了" + playerWeaponKillInRowCount + "连杀！鲨疯了！" )
										}
									} else {
										if ( playerKillInRowCount >= 10 && playerKillInRowCount < 15 ){
											if ( isAutoPrintRestrictedMod == 1 || isAutoPrintRestrictedMod == 3 ){
												localPlayer.ClientCommand("say " + attackerName + "使用神器「" + Offhand1String + weaponNameLocal + "」" + "达成了" + playerWeaponKillInRowCount + "连杀！总共已经" + playerKillInRowCount + "连杀了！我们还有救吗")
											} else {
												print(attackerName + "使用神器「" + Offhand1String + weaponNameLocal + "」" + "达成了" + playerWeaponKillInRowCount + "连杀！总共已经" + playerKillInRowCount + "连杀了！我们还有救吗")
											}
										} else if ( playerKillInRowCount >= 15 ){
											if ( isAutoPrintRestrictedMod == 1 || isAutoPrintRestrictedMod == 3 ){
												localPlayer.ClientCommand("say " + attackerName + "使用神器「" + Offhand1String + weaponNameLocal + "」" + "达成了" + playerWeaponKillInRowCount + "连杀！总共已经" + playerKillInRowCount + "连杀了！我们真的没救了")
											} else {
												print(attackerName + "使用神器「" + Offhand1String + weaponNameLocal + "」" + "达成了" + playerWeaponKillInRowCount + "连杀！总共已经" + playerKillInRowCount + "连杀了！我们真的没救了")
											}
										} else {
											if ( isAutoPrintRestrictedMod == 1 || isAutoPrintRestrictedMod == 3 ){
												localPlayer.ClientCommand("say " + attackerName + "使用神器「" + Offhand1String + weaponNameLocal + "」" + "达成了" + playerWeaponKillInRowCount + "连杀！总共已经" + playerKillInRowCount + "连杀了！" )
											} else {
												print(attackerName + "使用神器「" + Offhand1String + weaponNameLocal + "」" + "达成了" + playerWeaponKillInRowCount + "连杀！总共已经" + playerKillInRowCount + "连杀了！" )
											}
										}
									}
									return
								}
							}
						}
				}
				break
				// 可能是正常武器三连杀 不能return
				// return
			case 5:
				Offhand1String = checkAShieldOrCover(attacker)

				local weaponIndex = isWeaponValid(weaponName)
				if ( weaponIndex != -1 ) {
					local weaponNameLocal = weaponValidList[weaponIndex][1]
					local weaponIntro = weaponValidList[weaponIndex][2]
					if ( playerKillInRowCount == playerWeaponKillInRowCount ){
						if ( isAutoPrintRestrictedMod == 1 || isAutoPrintRestrictedMod == 3 ){
							localPlayer.ClientCommand("say " + attackerName + "使用神器「" + Offhand1String + weaponNameLocal + "」" + "达成了" + playerWeaponKillInRowCount + "连杀！" + weaponIntro )
						} else {
							print(attackerName + "使用神器「" + Offhand1String + weaponNameLocal + "」" + "达成了" + playerWeaponKillInRowCount + "连杀！" + weaponIntro )
						}
					} else {
						if ( playerKillInRowCount >= 10 && playerKillInRowCount < 15 ){
							if ( isAutoPrintRestrictedMod == 1 || isAutoPrintRestrictedMod == 3 ){
								localPlayer.ClientCommand("say " + attackerName + "使用神器「" + Offhand1String + weaponNameLocal + "」" + "达成了" + playerWeaponKillInRowCount + "连杀！" + weaponIntro + "总共已经" + playerKillInRowCount + "连杀了！我们还有救吗")
							} else {
								print(attackerName + "使用神器「" + Offhand1String + weaponNameLocal + "」" + "达成了" + playerWeaponKillInRowCount + "连杀！" + weaponIntro + "总共已经" + playerKillInRowCount + "连杀了！我们还有救吗")
							}
						} else if ( playerKillInRowCount >= 15 ){
							if ( isAutoPrintRestrictedMod == 1 || isAutoPrintRestrictedMod == 3 ){
								localPlayer.ClientCommand("say " + attackerName + "使用神器「" + Offhand1String + weaponNameLocal + "」" + "达成了" + playerWeaponKillInRowCount + "连杀！" + weaponIntro + "总共已经" + playerKillInRowCount + "连杀了！我们真的没救了")
							} else {
								print(attackerName + "使用神器「" + Offhand1String + weaponNameLocal + "」" + "达成了" + playerWeaponKillInRowCount + "连杀！" + weaponIntro + "总共已经" + playerKillInRowCount + "连杀了！我们真的没救了")
							}
						} else {
							if ( isAutoPrintRestrictedMod == 1 || isAutoPrintRestrictedMod == 3 ){
								localPlayer.ClientCommand("say " + attackerName + "使用神器「" + Offhand1String + weaponNameLocal + "」" + "达成了" + playerWeaponKillInRowCount + "连杀！" + weaponIntro + "总共已经" + playerKillInRowCount + "连杀了！" )
							} else {
								print(attackerName + "使用神器「" + Offhand1String + weaponNameLocal + "」" + "达成了" + playerWeaponKillInRowCount + "连杀！" + weaponIntro + "总共已经" + playerKillInRowCount + "连杀了！" )
							}
						}
					}
					return
				}
				break
			case 10:
				Offhand1String = checkAShieldOrCover(attacker)

				local weaponIndex = isWeaponValid(weaponName)
				if ( weaponIndex != -1 ) {
					local weaponNameLocal = weaponValidList[weaponIndex][1]
					local weaponIntro = weaponValidList[weaponIndex][2]
					if ( playerKillInRowCount == playerWeaponKillInRowCount ){
						if ( isAutoPrintRestrictedMod == 1 || isAutoPrintRestrictedMod == 3 ){
							localPlayer.ClientCommand("say " + attackerName + "使用神器「" + Offhand1String + weaponNameLocal + "」" + "达成了" + playerWeaponKillInRowCount + "连杀！" + weaponIntro + "我们还有救吗")
						} else {
							print(attackerName + "使用神器「" + Offhand1String + weaponNameLocal + "」" + "达成了" + playerWeaponKillInRowCount + "连杀！" + weaponIntro + "我们还有救吗")
						}
					} else {
						if (  playerKillInRowCount < 15 ){
							if ( isAutoPrintRestrictedMod == 1 || isAutoPrintRestrictedMod == 3 ){
								localPlayer.ClientCommand("say " + attackerName + "使用神器「" + Offhand1String + weaponNameLocal + "」" + "达成了" + playerWeaponKillInRowCount + "连杀！" + weaponIntro + "总共已经" + playerKillInRowCount + "连杀了！我们还有救吗")
							} else {
								print(attackerName + "使用神器「" + Offhand1String + weaponNameLocal + "」" + "达成了" + playerWeaponKillInRowCount + "连杀！" + weaponIntro + "总共已经" + playerKillInRowCount + "连杀了！我们还有救吗")
							}
						} else {
							if ( isAutoPrintRestrictedMod == 1 || isAutoPrintRestrictedMod == 3 ){
								localPlayer.ClientCommand("say " + attackerName + "使用神器「" + Offhand1String + weaponNameLocal + "」" + "达成了" + playerWeaponKillInRowCount + "连杀！" + weaponIntro + "总共已经" + playerKillInRowCount + "连杀了！我们没救了")
							} else {
								print(attackerName + "使用神器「" + Offhand1String + weaponNameLocal + "」" + "达成了" + playerWeaponKillInRowCount + "连杀！" + weaponIntro + "总共已经" + playerKillInRowCount + "连杀了！我们没救了")
							}
						}
					}
					return
				}
				break
			case 15:
				Offhand1String = checkAShieldOrCover(attacker)

				local weaponIndex = isWeaponValid(weaponName)
				if ( weaponIndex != -1 ) {
					local weaponNameLocal = weaponValidList[weaponIndex][1]
					local weaponIntro = weaponValidList[weaponIndex][2]
					if ( playerKillInRowCount == playerWeaponKillInRowCount ){
						if ( isAutoPrintRestrictedMod == 1 || isAutoPrintRestrictedMod == 3 ){
							localPlayer.ClientCommand("say " + attackerName + "使用神器「" + Offhand1String + weaponNameLocal + "」" + "达成了" + playerWeaponKillInRowCount + "连杀！" + weaponIntro + "我们真的没救了")
						} else {
							print(attackerName + "使用神器「" + Offhand1String + weaponNameLocal + "」" + "达成了" + playerWeaponKillInRowCount + "连杀！" + weaponIntro + "我们真的没救了")
						}
					} else {
						if ( isAutoPrintRestrictedMod == 1 || isAutoPrintRestrictedMod == 3 ){
							localPlayer.ClientCommand("say " + attackerName + "使用神器「" + Offhand1String + weaponNameLocal + "」" + "达成了" + playerWeaponKillInRowCount + "连杀！" + weaponIntro + "总共已经" + playerKillInRowCount + "连杀了！我们真的没救了")
						} else {
							print(attackerName + "使用神器「" + Offhand1String + weaponNameLocal + "」" + "达成了" + playerWeaponKillInRowCount + "连杀！" + weaponIntro + "总共已经" + playerKillInRowCount + "连杀了！我们真的没救了")
						}
					}
					return
				}
				break
			default:
				break
		}

		// 正常武器一切连杀 没有其他处理了 break换成return
		switch ( playerKillInRowCount )	{
			case 5:
				array <entity> offhand = attacker.GetOffhandWeapons()
				if ( offhand.len() > 1 && offhand[1] != null ){
					if ( offhand[1].GetWeaponClassName() == "mp_weapon_deployable_cover"){
						Offhand1String = "使用神装「A盾」"
						if ( isAutoPrintRestrictedMod == 1 || isAutoPrintRestrictedMod == 3 ){
							localPlayer.ClientCommand("say " + attackerName + Offhand1String + "达成了" + playerKillInRowCount + "连杀！无人能破！")
						} else {
							print(attackerName + Offhand1String + "达成了" + playerKillInRowCount + "连杀！无人能破！")
						}
						return
					}
				}
				if (AFKMode == 1){
					localPlayer.ClientCommand("say " + attackerName + " 达成了" + playerKillInRowCount + "连杀！")
				} else {
					print("---" + attackerName + " 达成了" + playerKillInRowCount + "连杀！")
				}
				return
			case 10:
				array <entity> offhand = attacker.GetOffhandWeapons()
				if ( offhand.len() > 1 && offhand[1] != null ){
					if ( offhand[1].GetWeaponClassName() == "mp_weapon_deployable_cover"){
						Offhand1String = "使用神装「A盾」"
						if ( isAutoPrintRestrictedMod == 1 || isAutoPrintRestrictedMod == 3 ){
							localPlayer.ClientCommand("say " + attackerName + Offhand1String + "达成了" + playerKillInRowCount + "连杀！鲨疯了！我们还有救吗")
						} else {
							print(attackerName + Offhand1String + "达成了" + playerKillInRowCount + "连杀！鲨疯了！我们还有救吗")
						}
						return
					}
				}
				if ( isAutoPrintRestrictedMod == 1 || isAutoPrintRestrictedMod == 3 ){
					localPlayer.ClientCommand("say " + attackerName + "达成了" + playerKillInRowCount + "连杀！无人能挡！")
				} else {
					print(attackerName + "达成了" + playerKillInRowCount + "连杀！无人能挡！")
				}
				return
			case 15:
				array <entity> offhand = attacker.GetOffhandWeapons()
				if ( offhand.len() > 1 && offhand[1] != null ){
					if ( offhand[1].GetWeaponClassName() == "mp_weapon_deployable_cover"){
						Offhand1String = "使用神装「A盾」"
						if ( isAutoPrintRestrictedMod == 1 || isAutoPrintRestrictedMod == 3 ){
							localPlayer.ClientCommand("say " + attackerName + Offhand1String + "达成了" + playerKillInRowCount + "连杀！鲨疯了！我们没救了！")
						} else {
							print(attackerName + Offhand1String + "达成了" + playerKillInRowCount + "连杀！鲨疯了！我们没救了！")
						}
						return
					}
				}
				if ( isAutoPrintRestrictedMod == 1 || isAutoPrintRestrictedMod == 3 ){
					localPlayer.ClientCommand("say " + attackerName + "达成了" + playerKillInRowCount + "连杀！诛天灭地！我们没救了！")
				} else {
					print(attackerName + "达成了" + playerKillInRowCount + "连杀！诛天灭地！我们没救了！")
				}
				return
			case 20:
				array <entity> offhand = attacker.GetOffhandWeapons()
				if ( offhand.len() > 1 && offhand[1] != null ){
					if ( offhand[1].GetWeaponClassName() == "mp_weapon_deployable_cover"){
						Offhand1String = "使用神装「A盾」"
						if ( isAutoPrintRestrictedMod == 1 || isAutoPrintRestrictedMod == 3 ){
							localPlayer.ClientCommand("say " + attackerName + Offhand1String + "达成了" + playerKillInRowCount + "连杀！鲨疯了！我们真的没救了！")
						} else {
							print(attackerName + Offhand1String + "达成了" + playerKillInRowCount + "连杀！鲨疯了！我们真的没救了！")
						}
						return
					}
				}
				if ( isAutoPrintRestrictedMod == 1 || isAutoPrintRestrictedMod == 3 ){
					localPlayer.ClientCommand("say " + attackerName + "达成了" + playerKillInRowCount + "连杀！我们真的没救了！")
				} else {
					print(attackerName + "达成了" + playerKillInRowCount + "连杀！我们真的没救了！")
				}
				return
			default:
				break
		}
	}
}

void function killedToZero(entity attacker) {
	entity localPlayer = GetLocalClientPlayer()
	killedInRow = 0
	deathCount ++
	if ( attacker.IsPlayer() ) {
		local attackerName = attacker.GetPlayerName()
		if ( attackerName != localPlayer.GetPlayerName() ){
			// 用离手武器 能源炮 炸药包等被打死时localPlayer.GetActiveWeapon().GetWeaponClassName()会报错
			// if(localPlayer.GetActiveWeapon() == null ) {
			// 	print( "died: " + deathCount + ", attacker: "  + attackerName + ", attacker use: " + attacker.GetActiveWeapon().GetWeaponClassName() + ", I use: null" )
			// } else {
			// 	print( "died: " + deathCount + ", attacker: "  + attackerName + ", attacker use: " + attacker.GetActiveWeapon().GetWeaponClassName() + ", I use: " + localPlayer.GetActiveWeapon().GetWeaponClassName())
			// } 被飞火星打死依然会
			// print(localPlayer.GetActiveWeapon().GetWeaponClassName())
			// print( "died: " + deathCount + ", attacker: "  + attackerName + ", attacker use: " + attacker.GetActiveWeapon().GetWeaponClassName())  我也不知道 最后被扎了好像也寄了
			attackerNameLine += "; " + deathCount + "、" + attackerName
			// if ( AFKMode == 1 || AFKMode == 4  ){
			// 	print("diedAttackby: " + deathCount + attackerName)
			// }
		}
	}

}

void function killedCount(entity victim, entity localPlayer) {
	// victim already IsPlayer()
	if ( !IsWatchingReplay() && IsAlive(localPlayer) ){
		killedByMeVictimName = victim.GetPlayerName()
		if ( (AFKMode == 2 || AFKMode == 3) && killedByMeVictimName == arrowPlayerNow ) {
			isAfkVictimName = true
			if ( isAutoPrintRestrictedMod == 0 ){
				localPlayer.ClientCommand("retry")
			}else {
				localPlayer.ClientCommand("disconnect")
			}
			AFKMode = 0
		}
		killed ++
		killedInRow ++
		// print( "kill: " + killed + ", victim: "  + victimName )
		// 相反的，我用离手武器打死别人，别人拿不到武器名称，谁被离手武器打死了谁拿不到
		// print(victim.GetActiveWeapon().GetWeaponClassName())

		if ( isAutoFa ) {
			if ( killedInRow >= 13 && killedInRow <= 17 ) {
				localPlayer.ClientCommand("fa")
			} else if ( killedInRow >= 18 ) {
				localPlayer.ClientCommand("26627")
			}
		}
	}
	if ( AFKMode == 5 ){
		switch(killedInRow) {
			case 0:
				// 同一刻死会是这样的
				break
			case 1:
				local randomChoice = int(Time() * 1000) % 2 + 1;  // 1-2
				switch ( randomChoice  ){
					case 1:
						localPlayer.ClientCommand("say 1杀！一箭穿心！");
						break
					case 2:
						localPlayer.ClientCommand("say 一破！卧龙出山！");
						break
					default:
						break
				}
				break;
			case 2:
				local randomChoice = int(Time() * 1000) % 2 + 1;  // 1-2
				switch ( randomChoice  ){
					case 1:
						localPlayer.ClientCommand("say 2杀！二连击破！");
						break
					case 2:
						localPlayer.ClientCommand("say 双连！一战成名！");
						break
					default:
						break
				}
				break;
			case 3:
				local randomChoice = int(Time() * 1000) % 2 + 1;  // 1-2
				switch ( randomChoice  ){
					case 1:
						localPlayer.ClientCommand("say 3杀！三连绝杀！");
						break
					case 2:
						localPlayer.ClientCommand("say 三连！举世皆惊！");
						break
					default:
						break
				}
				break;
			case 4:
				local randomChoice = int(Time() * 1000) % 2 + 1;  // 1-2
				switch ( randomChoice  ){
					case 1:
						localPlayer.ClientCommand("say 4杀！四连横扫！");
						break
					case 2:
						localPlayer.ClientCommand("say 四连！天下无敌！");
						break
					default:
						break
				}
				break;
			case 5:
				localPlayer.ClientCommand("say 5杀！五连斩绝！");
				break;
			case 6:
				localPlayer.ClientCommand("say 6杀！六连狂袭！");
				break;
			case 7:
				localPlayer.ClientCommand("say 7杀！七连破敌！");
				break;
			case 8:
				localPlayer.ClientCommand("say 8杀！八连歼灭！");
				break;
			case 9:
				localPlayer.ClientCommand("say 9杀！九连无双！");
				break;
			case 10:
				localPlayer.ClientCommand("say 10杀！十连霸绝！");
				break;
			default:
				local randomChoice = int(Time() * 1000) % 4 + 1;
				switch ( randomChoice  ){
					case 1:
						localPlayer.ClientCommand("say " + killedInRow + "杀！无双-万军取首！");
						break
					case 2:
						localPlayer.ClientCommand("say " + killedInRow + "杀！无双-癫狂屠戮！");
						break
					case 3:
						localPlayer.ClientCommand("say " + killedInRow + "杀！无双-诛天灭地！");
						break
					case 4:
						localPlayer.ClientCommand("say " + killedInRow + "杀！无双-无人能挡！");
						break
				}
				break;
		}
	}
}



string function formatTime(float seconds) {
    int minutes = int(seconds / 60)
    float remainingSeconds = seconds % 60;

    if (minutes == 0){
        return format("%d秒", remainingSeconds);
    } else {
        return format("%d分%d秒", minutes, remainingSeconds);
    }
    return format("%d分%d秒", minutes, remainingSeconds);
     
}

void function restartXDbot(string say){
    GetLocalClientPlayer().ClientCommand(say + "【XDbot】好的！正在重启...")
    wait 2
    GetLocalClientPlayer().ClientCommand(say + "【XDbot】重启完成！")
}


void function playerQuitGame(string PlayernameClan){
    if(isControl != 0){
        int controlIndexCount = 0
        while (controlIndexCount < controlList.len() ) {
            if( PlayernameClan == controlList[controlIndexCount] ){
                controlList.remove(controlIndexCount)
                isControl --
                break
            } else {
                controlIndexCount ++
            }
        }
    }
}

void function ShowHistroyMessage(text, float msgPosX, float msgPosY){
    // SetTimedEventNotification(2.0, text)
    print ("【HistroyMessage】" + text )
    ruiCount++
	int localRuiCount = ruiCount
    string message = string(text)
    float right = (GetScreenSize()[1] / 9.0) * 16.0
	float down = GetScreenSize()[1]
	float xOffset = (GetScreenSize()[0] - right) / 2

	float startTime = Time()
	float FADE_TIME = 1
	if ( lastStringRui == null ){
		local aspectRatioFixTopo = RuiTopology_CreatePlane( <xOffset, 0, 0>, <right, 0, 0>, <0, down, 0>, false )
		var rui = RuiCreate( $"ui/cockpit_console_text_top_left.rpak", aspectRatioFixTopo, RUI_DRAW_HUD, 1)
		lastStringRui = rui

		RuiSetFloat2( rui, "msgPos", <msgPosX, msgPosY, 0> )
		RuiSetString( rui, "msgText", message )
		RuiSetFloat3( rui, "msgColor", <0.5, 0.5, 1> )
		RuiSetFloat( rui, "msgFontSize", 24)
		RuiSetFloat( rui, "msgAlpha", 1.0 )
	
		while ( Time() - startTime <= FADE_TIME )
		{
			if (localRuiCount != ruiCount){
                return	
			}
			float alpha = 1 - (Time() - startTime) * (1/FADE_TIME)
			if (rui){
				RuiSetFloat( rui, "msgAlpha", alpha )
			}
			WaitFrame()
		}
        if (localRuiCount == ruiCount){
            RuiSetFloat( rui, "msgAlpha", 0 )
		}
	} else {
		RuiSetFloat2( lastStringRui, "msgPos", <msgPosX, msgPosY, 0> )
		RuiSetString( lastStringRui, "msgText", message )
		RuiSetFloat( lastStringRui, "msgAlpha", 1.0 )
		while ( Time() - startTime <= FADE_TIME )
		{
			if (localRuiCount != ruiCount){
                return	
			}
			float alpha = 1 - (Time() - startTime) * (1/FADE_TIME)
			if (lastStringRui){
				RuiSetFloat( lastStringRui, "msgAlpha", alpha )
			}
			WaitFrame()
		}
        if (localRuiCount == ruiCount){
            RuiSetFloat( lastStringRui, "msgAlpha", 0 )
		}
	}
}


void function HistroyMessageUp(){
    if ( historyMessageIndex < localMessageHistory.len() - 1 ){
        historyMessageIndex ++
    }
    historyMessageText = localMessageHistory[historyMessageIndex]
    if ( localMessageHistory[historyMessageIndex][1].len() == 9 ) { 
        thread ShowHistroyMessage("[TEAM] " + historyMessageText[0], 0.05, 0.8)
    } else {
        thread ShowHistroyMessage(historyMessageText[0], 0.05, 0.8)
    }
}

void function HistroyMessageDown(){
    if ( historyMessageIndex > 0 ){
        historyMessageIndex --
    }

    historyMessageText = localMessageHistory[historyMessageIndex]
    // sayteam
    if ( localMessageHistory[historyMessageIndex][1].len() == 9 ) { 
        thread ShowHistroyMessage("[TEAM] " + historyMessageText[0], 0.05, 0.8)
    } else {
        thread ShowHistroyMessage(historyMessageText[0], 0.05, 0.8)
    }
    
    
}

void function SayHistroyMessage(){
    if ( isMeleePrint ){
        GetLocalClientPlayer().ClientCommand( historyMessageText[1] + historyMessageText[0] )
    } else {
        string color = GetRandomColor()
        GetLocalClientPlayer().ClientCommand( historyMessageText[1] + "\"" + color + historyMessageText[0] + "[0m\"")
    }
}

void function printHistoryMessage(int mode){
    GetLocalClientPlayer().ClientCommand( localMessageHistory[historyMessageIndex][1] + localMessageHistory[historyMessageIndex][0] )
}

void function PyXD_Init(){
    // NSSaveFile("py_XD.json", {})
}

void function PrintMessageList(){
    float time = Time()
    if ( time - printMessageLastTime > 5 ) {
        printMessageLastTime = time
        array msgs = ["\n"]
        int msgLen = 1 // "\n".len() = 1
        int msgsIndex = 0
        foreach(message in messageList ){
            string msgText = message + "\n"
            msgLen += msgText.len()
            if ( msgLen > 1023 ){
                msgLen = 1
                msgs.push("\n")
                msgsIndex ++
            }
            msgs[msgsIndex] += msgText
        }
        foreach(msg in msgs){
            print(msg)
        }
        string playerMsg = "\n"
        foreach ( player in GetPlayerArray() ){
            playerMsg += player.GetPlayerNameWithClanTag() + ": " + PlayerXPDisplayGenAndLevel(player.GetGen(), player.GetLevel()) + "\n"
        }
        print(playerMsg)
    }
    print("Now: " + Time() )
}

string function GetRandomColor(){
    int randomColor = int(Time() * 10) % 15 + 1
    string color = "" 
    print("【color】" + randomColor)
    switch(randomColor) {
        case 1:
            // color = "[38;2;254;218;185m";  // 淡桃色 (Peach Puff)
            color = "[38;2;254;208;165m";  // 淡桃色 (Peach Puff)
            break;
        case 2:
            color = "[38;2;135;206;235m";  // 浅天蓝色 (Sky Blue)
            break;
        case 3:
            color = "[38;2;240;128;128m";  // 淡珊瑚色 (Light Coral)
            break;
        case 4:
            color = "[38;2;165;238;238m";  // 浅绿松石色 (Turquoise)
            break;
        case 5:
            color = "[38;2;254;209;173m";  // 浅橙色 (Papaya Whip)
            break;
        case 6:
            color = "[38;2;216;171;216m";  // 淡紫罗兰色 (Thistle)
            break;
        case 7:
            color = "[38;2;144;238;144m";  // 淡黄绿色 (Spring Green)
            break;
        case 8:
            // color = "[38;2;245;254;250m";  // 粉青色 (Mint Cream)
            color = "[38;2;165;204;200m";  // 粉青色 (Mint Cream)
            break;
        case 9:
            color = "[38;2;221;160;221m";  // 柔和丁香紫 (Plum)
            break;
        case 10:
            color = "[38;2;248;131;121m";  // 珊瑚粉色 (Coral Pink)
            break;
        case 11:
            // color = "[38;2;254;228;225m";  // 浅玫瑰色 (Misty Rose)
            color = "[38;2;254;188;185m";  // 浅玫瑰色 (Misty Rose)
            break;
        case 12:
            // color = "[38;2;204;245;204m";  // 柔雾绿色 (Sea Mist)
            color = "[38;2;184;245;184m";  // 柔雾绿色 (Sea Mist)
            break;
        case 13:
            color = "[38;2;173;216;230m";  // 柔蓝 (Soft Blue)
            break;
        case 14:
            // color = "[38;2;254;250;205m";  // 粉彩黄 (Lemon Chiffon)
            color = "[38;2;254;250;165m"; 
            break;
        case 15:
            // color = "[38;2;210;245;190m";  // 柔草绿 (Light Lime)
            color = "[38;2;189;245;180m";  // 柔草绿 (Light Lime)
            break;
        default:
            color = "[38;2;254;254;254m";  // 默认白色
            break;
    }
    return color
}

void function ReplayHello(string say, string text){

    // string text = ""
    // string text = " 未知指令！可圈xd help进行查询~"
    string color = GetRandomColor()
    int randomChoice = int(Time() * 10) % 11 + 1
    switch(randomChoice) {
        case 1:
            GetLocalClientPlayer().ClientCommand(say + "\" " + color + "yay! (≧▽≦)/ [0m\"" + text);
            return;
        case 2:
            GetLocalClientPlayer().ClientCommand(say + "\" " + color + "喵~ (=^･ω･^=) [0m\"" + text);
            return;
        case 3:
            GetLocalClientPlayer().ClientCommand(say + "\" " + color + "诶嘿~ (｡>ω<｡) [0m\"" + text);
            return;
        case 4:
            GetLocalClientPlayer().ClientCommand(say + "\" " + color + "咕噜咕噜 (｡>﹏<｡) [0m\"" + text);
            return;
        case 5:
            GetLocalClientPlayer().ClientCommand(say + "\" " + color + "诶？(⊙_⊙)？ [0m\"" + text);
            return;
        case 6:
            GetLocalClientPlayer().ClientCommand(say + "\" " + color + "偷偷观察 (｀・ω・´) [0m\"" + text);
            return;
        case 7:
            GetLocalClientPlayer().ClientCommand(say + "\" " + color + "诶嘿嘿 (￣ω￣) [0m\"" + text);
            return;
        case 8:
            GetLocalClientPlayer().ClientCommand(say + "\" " + color + "害羞 (*/ω＼*) [0m\"" + text);
            return;
        case 9:
            GetLocalClientPlayer().ClientCommand(say + "\" " + color + "快乐摸鱼 (。-ω-)zzz [0m\"" + text);
            return;
        case 10:
            GetLocalClientPlayer().ClientCommand(say + "\" " + color + "诶嘿，被发现了！(๑>ω<๑) [0m\"" + text);
            return;
        case 11:
            GetLocalClientPlayer().ClientCommand(say + "\" " + color + "正在偷偷rua小雌驹... (๑>ω<๑) [0m\"" + text);
            return;
        default:
            GetLocalClientPlayer().ClientCommand(say + "\" " + color + "今天也要开心哦！(≧▽≦)/ [0m[0m\"" + text);
            return;
    }
}

bool function ReplyBot(string command, string say, string fromPlayerName){
    if( fromPlayerName == GetLocalClientPlayer().GetPlayerNameWithClanTag() ){
        switch ( command ){
            case "sudo stop":
                sudoStop = true
                cmdStop = true
                entity localPlayer = GetLocalClientPlayer()
                localPlayer.ClientCommand("-forward")
                localPlayer.ClientCommand("-back")
                localPlayer.ClientCommand("-moveleft")
                localPlayer.ClientCommand("-moveright")
                localPlayer.ClientCommand("-left")
                localPlayer.ClientCommand("-right")
                localPlayer.ClientCommand("-offhand0")
                localPlayer.ClientCommand("-offhand1")
                localPlayer.ClientCommand("-duck")

                // for (int i = 0; i < 6; i++){
                //     isMoveList[i] = false
                // }
                // command = "[38;2;125;125;254m" + command
                return true
            case "sudo oiiai":
                entity localPlayer = GetLocalClientPlayer()
                localPlayer.ClientCommand("+forward")
                localPlayer.ClientCommand("+left")
                localPlayer.ClientCommand("+duck")
                return true
            case "sudo 结束井字棋":
                TicTacToeState = 0
                TicTacToeCount = 0
                isTicTacToeFirst = true
                board = [
                    ["    ", "    ", "    "],
                    ["    ", "    ", "    "],
                    ["    ", "    ", "    "]
                ]
                return true
            // case "sudo quit":
            // case "sudo quit!":
            // case "sudo 撤退":
            // case "sudo 撤退！":
            //     string color = GetRandomColor()
            //     GetLocalClientPlayer().ClientCommand( say + "\" 好的！撤退！！！" + color + "(≧▽≦)/ [0m\"")
            //     wait 1
            //     GetLocalClientPlayer().ClientCommand("disconnect")
            //     return true
        }

        if (command.len()>=4){
            string isSudo = command.slice(0,4)
            switch (isSudo){
                case "sudo":
                    thread xdSudoCommand(command.slice(4))
                    // command = "[38;2;125;125;254m" + command
                    return true
                    break
                // case "stop":
                //     sudoStop = true
                //     entity localPlayer = GetLocalClientPlayer()
                //     localPlayer.ClientCommand("-forward")
                //     localPlayer.ClientCommand("-back")
                //     localPlayer.ClientCommand("-moveleft")
                //     localPlayer.ClientCommand("-moveright")
                //     localPlayer.ClientCommand("-left")
                //     localPlayer.ClientCommand("-right")
                //     for (int i = 0; i < 6; i++){
                //         isMoveList[i] = false
                //     }
            }
            
        }
    }
    switch (command){
        // local idx = message.tolower().find("world"); // 使用 tolower() 转为小写后查找

        case "help":
            GetLocalClientPlayer().ClientCommand(say + "目前的命令有 xd [AI (询问AI的话)、meow、meme、pinyin (拼音)、roll、time、yay、查询等级/装备 (模糊名称)、打开/关闭连杀播报、进入/退出操控模式、井字棋...]")
            return true
        case "meow":
            local start2 = fromPlayerName.find("] ")
            string fromPlayerNameNoClan = fromPlayerName
            if (start2 != null ){
                fromPlayerNameNoClan = fromPlayerName.slice(start2 + 2)
            }
            GetLocalClientPlayer().ClientCommand(say + "【XDbot】好的 " + fromPlayerNameNoClan + "，(=^･ω･^=)喵~")
            return true
        case "meme":
            // int randomChoice = int(Time() * 10) % 8 + 1
            array memeList = [
                "【XDbot】人生的阴影太多了……嘿嘿嘿 好凉快啊",
                "【XDbot】我是麻辣香锅里的半瓣花椒，表面只是众多食材中的陪衬，实际上我才是最阴狠毒辣的，就算再重的红油，也挡不住我的邪恶。",
                "【XDbot】生活给我了一拳 但我出的是布",
                "【XDbot】阿姆斯特朗回旋加速喷气式阿姆斯特炮，发射！",
                "我在高考中违规使用了奇物「AK-47」，取消了共计173名考生的考试资格及38名老师的监考资格！连杀最终被中国武警使用「88式狙击步枪」终结，KD高达211！你也来试试吧!",
                "【XDbot】后天的努力很重要...所以今天和明天休息！"
                "【XDbot】meme还在收集...集思广益...欢迎投稿！"
            ]
            GetLocalClientPlayer().ClientCommand(say + memeList.getrandom());

            // switch(randomChoice) {
            //     case 1:
            //         GetLocalClientPlayer().ClientCommand(say + "【XDbot】人生的阴影太多了……嘿嘿嘿 好凉快啊");
            //         break;
            //     case 2:
            //         GetLocalClientPlayer().ClientCommand(say + "【XDbot】我是麻辣香锅里的半瓣花椒，表面只是众多食材中的陪衬，实际上我才是最阴狠毒辣的，就算再重的红油，也挡不住我的邪恶。");
            //         break;
            //     case 3:
            //         GetLocalClientPlayer().ClientCommand(say + "【XDbot】生活给我了一拳 但我出的是布");
            //         break;
            //     case 4:
            //         GetLocalClientPlayer().ClientCommand(say + "【XDbot】道心不稳，影响飞升~");
            //         break;
            //     case 5:
            //         GetLocalClientPlayer().ClientCommand(say + "【XDbot】阿姆斯特朗回旋加速喷气式阿姆斯特炮，发射！");
            //         break;
            //     case 6:
            //         GetLocalClientPlayer().ClientCommand(say + "我在高考中违规使用了奇物「AK-47」，取消了共计173名考生的考试资格及38名老师的监考资格！连杀最终被中国武警使用「88式狙击步枪」终结，KD高达211！你也来试试吧!");
            //         break;
            //     case 7:
            //         GetLocalClientPlayer().ClientCommand(say + "诶嘿嘿...（吸溜）rua小雌驹！ruarua狐！");
            //         break;
            // }
            // GetLocalClientPlayer().ClientCommand(say + "meme还在收集...集思广益...欢迎投稿！")
            return true
        case "roll":
            // fromPlayer = GetEntByIndex(0)
            // fromPlayerIndex = -1
            // messageType = 1 fromPlayer为 null 则变成server
            int randomChoice = int(Time() * 100) % 6 + 1
            local start2 = fromPlayerName.find("] ")
            string fromPlayerNameNoClan = fromPlayerName
            if (start2 != null ){
                fromPlayerNameNoClan = fromPlayerName.slice(start2 + 2)
            }
            
            GetLocalClientPlayer().ClientCommand(say + "【XDbot】" + fromPlayerNameNoClan + " 摇到了 [33m" + randomChoice + "[0m 点！")
            return true
        case "time":

            // local playerData = {}
            // playerData["message"] <- "time"
            // local timeplayerData = {}
            // // XD_table[fromPlayerName] <- playerData
            // float time = Time()
            PyProcess(command, "", fromPlayerName, say, true)

            // Time() - GetScoreEndTime()) 这俩都无限增大导致无法知道过去多少时间
            // GetLocalClientPlayer().ClientCommand(say + "【XDbot】游戏时间已经过去了 [33m" + formatTime(Time()) + "[0m ！")
            print("Time: " + Time() + " GetScoreEndTime() - Time(): " + (GetScoreEndTime() - Time()) )
            return true
        case "yay":
            int randomChoice = int(Time() * 10) % 18 + 1
            int randomColor = int(Time() * 10) % 15 + 1
            string color = "" 
            // 1.051 1.001 接收信息时间会这样
            switch(randomColor) {
                case 1:
                    // color = "[38;2;254;218;185m";  // 淡桃色 (Peach Puff)
                    color = "[38;2;254;208;175m";  // 淡桃色 (Peach Puff)
                    break;
                case 2:
                    color = "[38;2;135;206;235m";  // 浅天蓝色 (Sky Blue)
                    break;
                case 3:
                    color = "[38;2;240;128;128m";  // 淡珊瑚色 (Light Coral)
                    break;
                case 4:
                    color = "[38;2;175;238;238m";  // 浅绿松石色 (Turquoise)
                    break;
                case 5:
                    color = "[38;2;254;219;193m";  // 浅橙色 (Papaya Whip)
                    break;
                case 6:
                    color = "[38;2;216;191;216m";  // 淡紫罗兰色 (Thistle)
                    break;
                case 7:
                    color = "[38;2;144;238;144m";  // 淡黄绿色 (Spring Green)
                    break;
                case 8:
                    // color = "[38;2;245;254;250m";  // 粉青色 (Mint Cream)
                    color = "[38;2;205;214;210m";  // 粉青色 (Mint Cream)
                    break;
                case 9:
                    color = "[38;2;221;160;221m";  // 柔和丁香紫 (Plum)
                    break;
                case 10:
                    color = "[38;2;248;131;121m";  // 珊瑚粉色 (Coral Pink)
                    break;
                case 11:
                    // color = "[38;2;254;228;225m";  // 浅玫瑰色 (Misty Rose)
                    color = "[38;2;254;198;195m";  // 浅玫瑰色 (Misty Rose)
                    break;
                case 12:
                    // color = "[38;2;204;245;204m";  // 柔雾绿色 (Sea Mist)
                    color = "[38;2;194;245;194m";  // 柔雾绿色 (Sea Mist)
                    break;
                case 13:
                    color = "[38;2;173;216;230m";  // 柔蓝 (Soft Blue)
                    break;
                case 14:
                    // color = "[38;2;254;250;205m";  // 粉彩黄 (Lemon Chiffon)
                    color = "[38;2;254;250;195m"; 

                    break;
                case 15:
                    // color = "[38;2;210;245;190m";  // 柔草绿 (Light Lime)
                    color = "[38;2;199;245;190m";  // 柔草绿 (Light Lime)
                    break;
                default:
                    color = "[38;2;254;254;254m";  // 默认白色
                    break;
            }
            switch(randomChoice) {
                case 1:
                    GetLocalClientPlayer().ClientCommand(say + "\" " + color + "yay! (≧▽≦)/ [0m\"");
                    return true;
                case 2:
                    GetLocalClientPlayer().ClientCommand(say + "\" " + color + "喵~ (=^･ω･^=) [0m\"");
                    return true;
                case 3:
                    GetLocalClientPlayer().ClientCommand(say + "\" " + color + "开心！(^▽^) [0m\"");
                    return true;
                case 4:
                    GetLocalClientPlayer().ClientCommand(say + "\" " + color + "蹦蹦跳跳 (ﾉ≧∀≦)ﾉ*:･ﾟ☆ [0m\"");
                    return true;
                case 5:
                    GetLocalClientPlayer().ClientCommand(say + "\" " + color + "诶嘿~ (｡>ω<｡) [0m\"");
                    return true;
                case 6:
                    GetLocalClientPlayer().ClientCommand(say + "\" " + color + "发射爱心 ♡(>ω<) [0m\"");
                    return true;
                case 7:
                    GetLocalClientPlayer().ClientCommand(say + "\" " + color + "咕噜咕噜 (｡>﹏<｡) [0m\"");
                    return true;
                case 8:
                    GetLocalClientPlayer().ClientCommand(say + "\" " + color + "被萌到了！(⁄ˊ⁄ω⁄ˋ⁄) [0m\"");
                    return true;
                case 9:
                    GetLocalClientPlayer().ClientCommand(say + "\" " + color + "开心到转圈圈 ～(つˆДˆ)つ [0m\"");
                    return true;
                // case 10:
                //     GetLocalClientPlayer().ClientCommand(say + "\" " + color + "诶？(⊙_⊙)？ [0m\"");
                //     return true;
                case 10:
                    GetLocalClientPlayer().ClientCommand(say + "\" " + color + "偷偷观察 (｀・ω・´) [0m\"");
                    return true;
                case 11:
                    GetLocalClientPlayer().ClientCommand(say + "\" " + color + "诶嘿嘿 (￣ω￣) [0m\"");
                    return true;
                case 12:
                    GetLocalClientPlayer().ClientCommand(say + "\" " + color + "开心炸了！(ﾉ≧∀≦)ﾉ [0m\"");
                    return true;
                case 13:
                    GetLocalClientPlayer().ClientCommand(say + "\" " + color + "害羞 (*/ω＼*) [0m\"");
                    return true;
                case 14:
                    GetLocalClientPlayer().ClientCommand(say + "\" " + color + "快乐摸鱼 (。-ω-)zzz [0m\"");
                    return true;
                case 15:
                    GetLocalClientPlayer().ClientCommand(say + "\" " + color + "诶嘿，被发现了？(๑>ω<๑) [0m\"");
                    return true;
                case 16:
                    GetLocalClientPlayer().ClientCommand(say + "\" " + color + "开心到飞起 ～(つˆДˆ)つ [0m\"");
                    return true;
                case 17:
                    GetLocalClientPlayer().ClientCommand(say + "\" " + color + "诶嘿嘿...小雌驹！ (≧▽≦)/ [0m\"");
                    return true;
                default:
                    GetLocalClientPlayer().ClientCommand(say + "\" " + color + "今天也要开心哦！(≧▽≦)/ [0m[0m\"");
                    return true;
            }
            return true
            
        // 
        // 欢迎您！[38;5;81m Pathstar_XD[0m
        //     您现在正在 [38;5;11m[0m 中进行游玩  script_ui EmitUISound("superspectre_step_light_solidmetal_3p")
        //     交流群：[38;5;11mQQ群747829812[0m
        //     [38;5;208m您可以在聊天框输入 !help 获取帮助[0m
        case "开启连杀播报":
        case "打开连杀播报":
            bool op = CheckOP(fromPlayerName)
            if (op){
                setAutoPrintRestrictedMod(1, say)
            } else {
                GetLocalClientPlayer().ClientCommand(say + "【XDbot】暂无权限...")
            }
            return true
        case "关闭连杀播报":
            bool op = CheckOP(fromPlayerName)
            if (op){
                setAutoPrintRestrictedMod(0, say)
            } else {
                GetLocalClientPlayer().ClientCommand(say + "【XDbot】暂无权限...")
            }
            return true
        case "开启bot":
        case "打开bot":
            bool op = CheckOP(fromPlayerName)
            if (op){
                GetLocalClientPlayer().ClientCommand(say + "【XDbot】好的！正在开机...")
            } else {
                GetLocalClientPlayer().ClientCommand(say + "【XDbot】暂无权限...")
            }
            return true
        case "关闭bot":
            bool op = CheckOP(fromPlayerName)
            if (op){
                GetLocalClientPlayer().ClientCommand(say + "【XDbot】好的！正在关闭...")
            } else {
                GetLocalClientPlayer().ClientCommand(say + "【XDbot】暂无权限...")
            }
            return true
        case "重启bot":
            bool op = CheckOP(fromPlayerName)
            if (op){
                thread restartXDbot(say)
            } else {
                GetLocalClientPlayer().ClientCommand(say + "【XDbot】暂无权限...")
            }
            return true
        case "root":
        case "进入操控模式":
            bool op = CheckOP(fromPlayerName)
            local start2 = fromPlayerName.find("] ")
            string fromPlayerNameNoClan = fromPlayerName
            if (start2 != null ){
                fromPlayerNameNoClan = fromPlayerName.slice(start2 + 2)
            }
            if (op){
                GetLocalClientPlayer().ClientCommand(say + "【XDbot】好的 " + fromPlayerNameNoClan + "！进入操控模式...控制方式查询：@xd 操控模式 help")
                controlList.push(fromPlayerName)
                isControl ++
            } else {
                GetLocalClientPlayer().ClientCommand(say + "【XDbot】暂无权限...")
            }
            return true
        case "退出操控模式":
            bool op = CheckOP(fromPlayerName)
            local start2 = fromPlayerName.find("] ")
            string fromPlayerNameNoClan = fromPlayerName
            if (start2 != null ){
                fromPlayerNameNoClan = fromPlayerName.slice(start2 + 2)
            }
            if (op){
                bool isNotFindPlayer = true
                int controlIndexCount = 0
                while (controlIndexCount < controlList.len() ) {
                    if( fromPlayerName == controlList[controlIndexCount] ){
                        controlList.remove(controlIndexCount)
                        isControl --
                        isNotFindPlayer = false
                        GetLocalClientPlayer().ClientCommand(say + "【XDbot】好的 " + fromPlayerNameNoClan + "！退出操控模式...")
                        return true
                    } else {
                        controlIndexCount ++
                    }
                }
                if ( isNotFindPlayer ){
                    GetLocalClientPlayer().ClientCommand(say + "【XDbot】" + fromPlayerNameNoClan + "还没有进入操控模式捏")
                }
            } else {
                GetLocalClientPlayer().ClientCommand(say + "【XDbot】暂无权限...")
            }
            return true
        case "操控模式 help":
            GetLocalClientPlayer().ClientCommand(say + "格式：[命令 时间] 前/后/左/右/左转/右转/停/跳/蹲/开火/停火/重火力/技能/重生/走/跑/退出；cmd [任意控制台命令]...")
            return true
        case "tictactoe":
            switch(TicTacToeState){
                case 0:
                    GetLocalClientPlayer().ClientCommand( say + "欢迎加入井字棋，等待下一名玩家...")
                    TicTacToeFirstPlayer = fromPlayerName
                    TicTacToeState = 1
                    return true
                case 1:
                    GetLocalClientPlayer().ClientCommand( say + "格式：[圈xd 横 纵]，例如：圈xd 1 3  「" + TicTacToeFirstPlayer + " VS " + fromPlayerName + "」！")
                    printBoard(1.1, say)
                    TicTacToeSecondPlayer = fromPlayerName
                    TicTacToeState = 2
                    return true
                case 2:
                    return false
            }
            return true
        case "井字棋":
            switch(TicTacToeState){
                case 0:
                    GetLocalClientPlayer().ClientCommand( say + "欢迎加入井字棋，等待下一名玩家...")
                    TicTacToeFirstPlayer = fromPlayerName
                    TicTacToeState = 1
                    return true
                case 1:
                    GetLocalClientPlayer().ClientCommand( say + "格式：圈xd 横 纵，例如：圈xd 1 3   " + TicTacToeFirstPlayer + " VS " + fromPlayerName + "！")
                    printBoard(1.1, say)
                    TicTacToeSecondPlayer = fromPlayerName
                    TicTacToeState = 2
                    return true
                case 2:
                    return false
            }
            return true
        case "井字棋棋盘":
            if ( fromPlayerName == GetLocalClientPlayer().GetPlayerNameWithClanTag() ){
                printBoard(1.1, say); // 打印更新后的棋盘
            } else {
                printBoard(0, say);
            }
            return true
        // case "撤退":
        case "撤退！":
            // if ( fromPlayerName == GetLocalClientPlayer().GetPlayerNameWithClanTag() ){
            if ( CheckOP(fromPlayerName) ){
                string color = GetRandomColor()
                GetLocalClientPlayer().ClientCommand( say + "\"【XDbot】好的！撤退！！！" + color + "(≧▽≦)/ [0m\"")
                wait 1
                GetLocalClientPlayer().ClientCommand("disconnect")
                return true
            } else {
                GetLocalClientPlayer().ClientCommand( say + "【XDbot】不要！")
            }
            return true
        default:
            // local genStart = command.find("查询等级")
            // // print("genStart" + string(genStart) + "  " + command.len())
            // 
            // if(genStart != null){
                // print (command.slice(0, 12))

            local strPart = command
            local numPart = ""
            local index = command.find(" ")
            // if (index == null) {
            //     return [command, null]; // 如果没有空格，返回整个字符串和 null
            // }
            // return [command.slice(0, index), command.slice(index + 1)];

            if (index != null) {
                strPart = command.slice(0, index)
                numPart = trim( command.slice(index + 1) )
            }
            // try {
            //     // 分割字符串
            //     local parts = split(command, " ");
                
            //     // 检查分割后的部分数量
            //     // if (parts.len() != 2) {
            //     //     throw "输入格式不正确，应为'字符串 数字'";
            //     // }
            //     if (parts.len() == 2){
            //         strPart = parts[0]
            //         numPart = parts[1]

            //         // if (strPart == "cmd"){
            //         //     GetLocalClientPlayer().ClientCommand(numPart)
            //         //     break
            //         // }
            //         // try {
            //         //     time = float(numPart)
            //         // }
            //         // catch (err){
            //         //     print("2222   " + err)
            //         // }
            //     }
            // }
            // catch (err) {
            //     print("default1111   " + err)
            // }
            switch(strPart){
                case "ai":
                    if ( numPart.len() > 2 && numPart.slice(0, 3) == "set" ){
                        switch( trimVar(numPart.slice(3)) ){
                            case "new_chat":
                            case "newchat":
                            case "new chat":
                                PyProcess("new_chat", "", fromPlayerName, say, false)
                                GetLocalClientPlayer().ClientCommand(say + "【XDAI】开启新聊天！")
                                return true
                            case "清除上下文":
                                PyProcess("new_chat", "", fromPlayerName, say, false)
                                GetLocalClientPlayer().ClientCommand(say + "【XDAI】清除上下文成功！")
                                return true
                            case "打开上下文":
                                return true
                            case "关闭上下文":
                                return true
                            case "上下文长度":
                                return true
                        }
                    }
                    if ( numPart == "" ){
                        GetLocalClientPlayer().ClientCommand(say + "【XDAI】请输入想对DeepSeek AI说的话捏")
                    } else {
                        PyProcess(strPart, numPart, fromPlayerName, say, true)
                    }
                    return true
                case "level":
                case "xp":
                case "querygen":
                case "查询等级":
                    if ( numPart == "" ){
                        local start2 = fromPlayerName.find("] ")
                        string playerName = fromPlayerName
                        if (start2 != null ){
                            playerName = fromPlayerName.slice(start2 + 2)
                        }
                        // print("1111111111111111111111111" + fromPlayerNameNoClan)
                        foreach (player in GetPlayerArray()){
                            if (playerName == player.GetPlayerName()){
                                // print("looooooooooooooooooooop" + player.GetPlayerName())
                                // GetLocalClientPlayer().ClientCommand( say + "【XDbot】您的等级为：G" + player.GetGen() + "." + (player.GetLevel()-1) )
                                GetLocalClientPlayer().ClientCommand( say + "【XDbot】您的等级为：" + PlayerXPDisplayGenAndLevel(player.GetGen(), player.GetLevel()) )
                                return true
                            }
                        }
                    } else {
                        // 我嘞个一个中文3长度 slice也会影响
                        local playerName = numPart
                        // print("aaaaaaaaaaaaaaa" + playerName)
                        foreach (player in GetPlayerArray()){
                            if (player.GetPlayerNameWithClanTag().tolower().find(playerName) != null ){
                                GetLocalClientPlayer().ClientCommand( say + "【XDbot】" + player.GetPlayerName() + " 的等级为：" + PlayerXPDisplayGenAndLevel(player.GetGen(), player.GetLevel()) )
                                return true
                            }
                        }
                        GetLocalClientPlayer().ClientCommand( say + "【XDbot】诶呀！(⊙_⊙) 找不到这个玩家捏" )
                        return false
                    }
                    break
                case "weapon":
                case "queryequipment":
                case "查询配装":
                case "查询装备":
                    if ( numPart == ""){
                        // 居然不需要numPart = " " 应该是分了很多part
                        // local start2 = fromPlayerName.find("] ")
                        // string playerName = fromPlayerName
                        // if (start2 != null ){
                        //     playerName = fromPlayerName.slice(start2 + 2)
                        // }
                        // print ( playerName )
                        foreach (player in GetPlayerArray()){
                            if (fromPlayerName == player.GetPlayerNameWithClanTag()){
                                string playerName = player.GetPlayerName()
                                array <entity> weapons = player.GetMainWeapons()
                                array <entity> offhands = player.GetOffhandWeapons()
                                string weapontext = ""
                                int weaponsLen = weapons.len()
                                int offhandsLen = offhands.len()
                                //  如果offhand 为 4 打印[2]
                                // if (offhandsLen == 4 ){
                                //     offhandsLen --
                                // }
                                // 全部是-1 -2是去掉一个
                                for (int i = offhandsLen - 2; i >= 0; i--) {
                                    // 最后一个是拳头
                                    // print(offhandsLen + " aaaaaaaaaa " + i) 重火力 技能 强化？ 拳头
                                    string weaponClassName = offhands[i].GetWeaponClassName()
                                    print(weaponClassName)
                                    if (weaponClassName == "mp_ability_burncardweapon"){
                                        continue
                                    }
                                    string weaponChineseName = getWeaponChinese(playerName, weaponClassName)
                                    if ( weaponChineseName == "" ){
                                        weapontext += GetWeaponInfoFileKeyField_GlobalString( weaponClassName, "shortprintname" ) + "、"
                                    } else {
                                        weapontext += weaponChineseName + "、"
                                    }
                                    // weapontext += GetObitFromDamageSourceID(offhands[i].GetWeaponType())
                                }
                                for (int j = 0; j < weaponsLen; j++){
                                    // local weaponClassName = weapon.GetWeaponClassName().toupper();
                                    // weaponClassName = weaponClassName.slice(9)
                                    
                                    // weapontext += Localize("#WPN" + weaponClassName) + "、" 只有转换者可以
                                    //从ServerCallback_WeaponXPAdded cl_weapon_xp 出现的神   

                                    if ( j == weaponsLen - 1){
                                        string weaponClassName = weapons[j].GetWeaponClassName()
                                        string weaponChineseName = getWeaponChinese(playerName, weaponClassName)
                                        if ( weaponChineseName == "" ){
                                            weapontext += GetWeaponInfoFileKeyField_GlobalString( weaponClassName, "shortprintname" )
                                        } else {
                                            weapontext += weaponChineseName
                                        }
                                    } else {
                                        string weaponClassName = weapons[j].GetWeaponClassName()
                                        string weaponChineseName = getWeaponChinese(playerName, weaponClassName)
                                        if ( weaponChineseName == "" ){
                                            weapontext += GetWeaponInfoFileKeyField_GlobalString( weaponClassName, "shortprintname" ) + "、"
                                        } else {
                                            weapontext += weaponChineseName + "、"
                                        }
                                    }

                                }
                                if (weapontext == ""){
                                    GetLocalClientPlayer().ClientCommand( say + "【XDbot】似了查不到配装捏，等活了再查吧uwu" )
                                    return true
                                }
                                GetLocalClientPlayer().ClientCommand( say + "【XDbot】您的配装为：" + weapontext )
                                return true
                            }
                        }
                    } else {
                        local playerName = numPart
                        foreach (player in GetPlayerArray()){
                            if (player.GetPlayerNameWithClanTag().tolower().find(playerName) != null ){
                                string playerName = player.GetPlayerName()
                                array <entity> weapons = player.GetMainWeapons()
                                array <entity> offhands = player.GetOffhandWeapons()
                                string weapontext = ""
                                int weaponsLen = weapons.len()
                                int offhandsLen = offhands.len()
                                // if (offhandsLen == 4 ){
                                //     offhandsLen --
                                // }
                                // for(int i = 0; i < offhandsLen - 1; i++){
                                for (int i = offhandsLen - 2; i >= 0; i--) {
                                    string weaponClassName = offhands[i].GetWeaponClassName()
                                    print(weaponClassName)
                                    if (weaponClassName == "mp_ability_burncardweapon"){
                                        continue
                                    }
                                    string weaponChineseName = getWeaponChinese(playerName, weaponClassName)
                                    if ( weaponChineseName == "" ){
                                        weapontext += GetWeaponInfoFileKeyField_GlobalString( weaponClassName, "shortprintname" ) + "、"
                                    } else {
                                        weapontext += weaponChineseName + "、"
                                    }
                                }
                                for (int j = 0; j < weaponsLen; j++){
                                    if ( j == weaponsLen - 1){
                                        string weaponClassName = weapons[j].GetWeaponClassName()
                                        string weaponChineseName = getWeaponChinese(playerName, weaponClassName)
                                        if ( weaponChineseName == "" ){
                                            weapontext += GetWeaponInfoFileKeyField_GlobalString( weaponClassName, "shortprintname" )
                                        } else {
                                            weapontext += weaponChineseName
                                        }
                                    } else {
                                        string weaponClassName = weapons[j].GetWeaponClassName()
                                        string weaponChineseName = getWeaponChinese(playerName, weaponClassName)
                                        if ( weaponChineseName == "" ){
                                            weapontext += GetWeaponInfoFileKeyField_GlobalString( weaponClassName, "shortprintname" ) + "、"
                                        } else {
                                            weapontext += weaponChineseName + "、"
                                        }
                                    }

                                }
                                if (weapontext == ""){
                                    GetLocalClientPlayer().ClientCommand( say + "【XDbot】似了查不到配装捏，等活了再查吧uwu" )
                                    return true
                                }
                                GetLocalClientPlayer().ClientCommand( say + "【XDbot】" + playerName + "的配装为：" + weapontext )
                                return true
                            }
                        }
                        GetLocalClientPlayer().ClientCommand( say + "【XDbot】诶呀！(⊙_⊙) 找不到这个玩家捏" )
                        return false
                    }
                case "cmd":
                    if ( CheckOP(fromPlayerName) ){
                        thread executiveCMD(numPart, say)
                    } else {
                        GetLocalClientPlayer().ClientCommand(say + "【XDbot】暂无权限...")
                    }
                    return true
                case "pinyin":
                    switch ( numPart ){
                        case "open":
                            isPinyinOpen = 1
                            GetLocalClientPlayer().ClientCommand(say + "【XDbot】转文字破损版 已开启...")
                            return true
                        case "stop":
                            isPinyinOpen = 0
                            GetLocalClientPlayer().ClientCommand(say + "【XDbot】转文字破损版 已关闭...")
                            return true
                    }
                    
                    
                        // if(pinyinTable.rawin(pinyin)){
                        //     TransToChinese += pinyinTablep[pinyin]
                        // } too long table
                    // foreach(pinyin in pinyinList){
                    //     local pinyinTrans = getPinyinChar(pinyin)
                    //     if ( pinyinTrans.len() > 1 ){
                    //         TransToChinese += pinyinTrans
                    //     } else{
                    //         TransToChinese += (" " + pinyinTrans[0] + " " )
                    //     }
                    // }
                    // print(type(pinyinList))  // [SCRIPT CL] [info] array
                    // print(pinyinList.len())  // [SCRIPT CL] [info] 0
                    
                    if ( numPart == "" ){
                        GetLocalClientPlayer().ClientCommand(say + "【转文字破损版】请输入拼音捏")
                    } else {
                        // local pinyinList = split(numPart, " ")
                        // local TransToChinese = getPinyinChar( pinyinList, false )
                        PyProcess(strPart, numPart, fromPlayerName, say, true)

                        // GetLocalClientPlayer().ClientCommand(say + "【转文字破损版】" + fromPlayerName + "：" + TransToChinese)
                    }
                    return true
                case "oldpinyin":
                    if ( numPart == "" ){
                        GetLocalClientPlayer().ClientCommand(say + "【转文字破损版】请输入拼音捏")
                    } else {
                        local pinyinList = split(numPart, " ")
                        local TransToChinese = getPinyinChar( pinyinList, false )
                        GetLocalClientPlayer().ClientCommand(say + "【转文字破损版】" + fromPlayerName + "：" + TransToChinese)
                    }
                    return true
                case "whisper":
                    local playerName = numPart
                    if ( playerName == "" ){
                        GetLocalClientPlayer().ClientCommand( say + "【XDbot】输入想要私聊的玩家名..." )
                    }
                    foreach (player in GetPlayerArray()){
                        if (player.GetPlayerNameWithClanTag().tolower().find(playerName) != null ){
                            // Chat_PrivateMessage(GetLocalClientPlayer(), player, "测试", true)
                            // NSSendMessage(0,0,"测试",true)
                            return true
                        }
                    }
                    GetLocalClientPlayer().ClientCommand( say + "【XDbot】诶呀！(⊙_⊙) 找不到这个玩家捏" )
                    return false
                default:
                    if ( TicTacToeState == 1 ){
                        if ( fromPlayerName == TicTacToeFirstPlayer ){
                            switch(strPart){
                                case "quit":
                                case "exit":
                                case "退出":
                                    GetLocalClientPlayer().ClientCommand(say + "好的，退出游戏...")
                                    TicTacToeState = 0
                                    TicTacToeCount = 0
                                    isTicTacToeFirst = true
                                    board = [
                                        ["    ", "    ", "    "],
                                        ["    ", "    ", "    "],
                                        ["    ", "    ", "    "]
                                    ]
                                    return true
                            }
                        }
                    }
                    if ( TicTacToeState == 2 ){
                        if ( isTicTacToeFirst ){
                            if ( fromPlayerName == TicTacToeFirstPlayer ){
                                switch(strPart){
                                    case "quit":
                                    case "exit":
                                    case "退出":
                                        GetLocalClientPlayer().ClientCommand(say + "好的，退出游戏...")
                                        TicTacToeState = 0
                                        TicTacToeCount = 0
                                        isTicTacToeFirst = true
                                        board = [
                                            ["    ", "    ", "    "],
                                            ["    ", "    ", "    "],
                                            ["    ", "    ", "    "]
                                        ]
                                        return true
                                }
                                if( placePiece( fromPlayerName, strPart, numPart, say, " X " ) ) return false
                            }
                        } else {
                            if ( fromPlayerName == TicTacToeSecondPlayer ){
                                switch(strPart){
                                    case "quit":
                                    case "exit":
                                    case "退出":
                                        GetLocalClientPlayer().ClientCommand(say + "好的，退出游戏...")
                                        TicTacToeState = 0
                                        TicTacToeCount = 0
                                        isTicTacToeFirst = true
                                        board = [
                                            ["    ", "    ", "    "],
                                            ["    ", "    ", "    "],
                                            ["    ", "    ", "    "]
                                        ]
                                        return true
                                }
                                if( placePiece( fromPlayerName, strPart, numPart, say, " O " ) ) return false
                            }
                        }
                    }
            }
    }
    if ( getMeleePrint() ){
        if(command == "uwu"){
            ReplayHello(say, "")
            tempOp.push(fromPlayerName)
            return true
        }
    }
    ReplayHello(say, " 未知指令！可圈xd help进行查询~")
    return false

}

// print(" X | O |   ")
// print("---|---|---")
// print("   | X | O ")
// print("---|---|---")
// print(" O |   | X ")



// @xd 井字棋
// @xd 井字棋棋盘
// 打印棋盘的函数
void function printBoard(float waitTime, string say) {
    // time
    float time = Time()
    if ( time - printBoardTime < 1.1 ){
        wait 1.1
    }
    printBoardTime = time
    if (waitTime != 0 ){
        wait waitTime
    }

    foreach(row in board) {
        local rowStr = "";
        for(local i = 0; i < row.len(); i++) {
            rowStr += row[i];
            if(i < row.len() - 1) {
                rowStr += " | ";
            }
        }
        GetLocalClientPlayer().ClientCommand( say + "•  " + rowStr);
        GetLocalClientPlayer().ClientCommand( say + "· " + "-----|-----|-----");
    }
}

// 检查是否有玩家胜利的函数
//  · -----|-----|-----
// •   O  |      |  O 
bool function checkWin(player) {
    // 检查行与列
    for (local i = 0; i < 3; i++) {
        if (board[i][0] == player && board[i][1] == player && board[i][2] == player) return true;
        if (board[0][i] == player && board[1][i] == player && board[2][i] == player) return true;
    }
    // 检查对角线
    if (board[0][0] == player && board[1][1] == player && board[2][2] == player) return true;
    if (board[0][2] == player && board[1][1] == player && board[2][0] == player) return true;
    return false;
}

// 接收玩家名字与信息的函数
bool function placePiece(string playerName, across, vertical, string say, string XO) {
    int row
    int col
    try{
        row = int(across) - 1; // 将行索引从1转换为0索引
        col = int(vertical) - 1;
        if ( row < 0 || row > 2 || col < 0 || col > 2 ){
            GetLocalClientPlayer().ClientCommand( say + "位置超过棋盘大小");
            return true
        }
    } catch(err){
        // GetLocalClientPlayer().ClientCommand( say + "位置非数字");
        return false
    }

    if (board[col][row] == "    ") { // 检查位置是否为空
        board[col][row] = XO; // 根据玩家分配棋子
        isTicTacToeFirst = !isTicTacToeFirst
        TicTacToeCount ++
    } else {
        GetLocalClientPlayer().ClientCommand( say + "位置已被占用，选个其他地方");
        return true
    }
    if ( playerName == GetLocalClientPlayer().GetPlayerNameWithClanTag() ){
        printBoard(1.1, say); // 打印更新后的棋盘
    } else {
        printBoard(0, say);
    }
    
    // 检查是否获胜
    if (TicTacToeCount > 4 && checkWin(XO)) {
        wait 1.1
        GetLocalClientPlayer().ClientCommand( say + playerName + "获胜！");
        TicTacToeState = 0
        TicTacToeCount = 0
        isTicTacToeFirst = true
        board = [
            ["    ", "    ", "    "],
            ["    ", "    ", "    "],
            ["    ", "    ", "    "]
        ]
        return true
    }else if ( TicTacToeCount == 9 ){
        
        wait 1.1
        GetLocalClientPlayer().ClientCommand( say + "平局！");
        TicTacToeState = 0
        TicTacToeCount = 0
        isTicTacToeFirst = true
        board = [
            ["    ", "    ", "    "],
            ["    ", "    ", "    "],
            ["    ", "    ", "    "]
        ]
        
    }
    return true
}

void function executiveCMD(cmd, string say){
    if ( cmd.find("bind") != null ) {
        GetLocalClientPlayer().ClientCommand(say + "【XDbot】命令禁用...")
        return
    }
    switch( cmd ){
        case "disconnect":
            string color = GetRandomColor()
            GetLocalClientPlayer().ClientCommand( say + "\"【XDbot】好吧" + color + "TvT [0mdisconnect... \"")
            wait 2
            if(isMeleePrint){
                GetLocalClientPlayer().ClientCommand("disconnect")
            }
            return
        case "quit":
            string color = GetRandomColor()
            GetLocalClientPlayer().ClientCommand( say + "\"【XDbot】好吧" + color + "TvT [0m关闭TTF... \"")
            wait 2
            if(isMeleePrint){
                GetLocalClientPlayer().ClientCommand("quit")
            }
            return
        case "retry":
            string color = GetRandomColor()
            GetLocalClientPlayer().ClientCommand( say + "\"【XDbot】尝试重进！" + color + "(。-ω-)zzz [0m \"")
            wait 2
            if(isMeleePrint){
               GetLocalClientPlayer().ClientCommand("retry")
            }
            return
    }
    GetLocalClientPlayer().ClientCommand(cmd)
}


void function controlBot(string fromPlayerName, string message, string say){
    if ( isControl != 0 ) {
        int controlIndexCount2 = 0
        // todo bool state and stop 2. pausebind "PAUSE" "pause"
        while (controlIndexCount2 < controlList.len() ) {
            if( fromPlayerName == controlList[controlIndexCount2] ){
                float time = -2.33
                local strPart = message
                try {
                    // 分割字符串
                    local parts = split(message, " ");
                    
                    // 检查分割后的部分数量
                    // if (parts.len() != 2) {
                    //     throw "输入格式不正确，应为'字符串 数字'";
                    // }
                    if (parts.len() == 2){
                        strPart = parts[0];
                        local numPart = parts[1];
    
                        if (strPart == "cmd"){
                            thread executiveCMD(numPart, say)
                            break
                        }
                        try {
                            time = float(numPart)
                        }
                        catch (err){
                            print("2222   " + err)
                        }
                    }

                    
                    // 尝试将第二部分转换为浮点数

                }
                catch (err) {
                    print("1111   " + err)
                }
                if(time == -1){
                    time = 10000
                }
                switch (strPart){
                    case "w":
                    case "前":
                        if(time == -2.33){
                            time = 10
                        }
                        thread executivePersistentCmd("forward", time, 0)
                        break
                    case "s":
                    case "后":
                        if(time == -2.33){
                            time = 10
                        }
                        thread executivePersistentCmd("back", time, 1)
                        break
                    case "a":
                    case "左":
                        if(time == -2.33){
                            time = 10
                        }
                        thread executivePersistentCmd("moveleft", time, 2)
                        break
                    case "d":
                    case "右":
                        if(time == -2.33){
                            time = 10
                        }
                        thread executivePersistentCmd("+moveright", time, 3)
                        break 
                    // case ""
                    case "left":
                    case "左转":
                        if(time == -2.33){
                            time = 1
                        }
                        thread executivePersistentCmd("left", time, 4)
                        break
                    case "right":
                    case "右转":
                        if(time == -2.33){
                            time = 1
                        }
                        thread executivePersistentCmd("right", time, 5)
                        break
                    case "stop":
                    case "停":
                        cmdStop = true
                        entity localPlayer = GetLocalClientPlayer()
                        localPlayer.ClientCommand("-forward")
                        localPlayer.ClientCommand("-back")
                        localPlayer.ClientCommand("-moveleft")
                        localPlayer.ClientCommand("-moveright")
                        localPlayer.ClientCommand("-left")
                        localPlayer.ClientCommand("-right")
                        localPlayer.ClientCommand("-offhand0")
                        localPlayer.ClientCommand("-offhand1")
                        localPlayer.ClientCommand("-duck")
                        for (int i = 0; i < 6; i++){
                            isMoveList[i] = false
                        }
                        break
                    case "jump":
                    case "跳":
                        if(time == -2.33){
                            time = 1
                        }
                        int time2 = time.tointeger()
                        thread executiveDoubleJump("jump", time2)
                        break
                    case "melee":
                    case "肘击":
                    case "近战":
                        if(time == -2.33){
                            time = 0.01
                        }
                        thread executiveFlutterCmd("melee", time)
                        break
                    case "throw":
                    case "fireinthehole":
                    case "扔":
                    case "重火力":
                        if(time == -2.33){
                            time = 0.01
                        }
                        thread executivePersistentCmd("offhand0", time, 6)
                        break
                    case "tac":
                    case "tactical":
                    case "技能":
                        if(time == -2.33){
                            time = 1
                        }
                        thread executiveSingleCmd("offhand1")
                        break
                    case "fire":
                    case "attack":
                    case "开火":
                        if(time == -2.33){
                            time = 3
                        }
                        thread executiveFlutterCmd("attack", time)
                        break
                    case "停火":
                        GetLocalClientPlayer().ClientCommand("-attack")
                        break
                    case "duck":
                    case "蹲":
                        if(time == -2.33){
                            time = 3
                        }
                        thread executivePersistentCmd("duck", time, 7)
                        break
                    case "walk":
                    case "静步":
                    case "走":
                        GetLocalClientPlayer.ClientCommand("+walk")
                        break
                    case "run":
                    case "跑":
                        GetLocalClientPlayer.ClientCommand("-walk")
                        break
                    case "weapon0":
                    case "主武器":
                        GetLocalClientPlayer().ClientCommand("weaponSelectPrimary0")
                        break
                    case "weapon1":
                    case "副武器":
                        GetLocalClientPlayer().ClientCommand("weaponSelectPrimary1")
                        break
                    case "weapon2":
                    case "手枪":
                        GetLocalClientPlayer().ClientCommand("weaponSelectPrimary2")
                        break
                    case "oiiai":
                        entity localPlayer = GetLocalClientPlayer()
                        localPlayer.ClientCommand("+forward")
                        localPlayer.ClientCommand("+left")
                        localPlayer.ClientCommand("+duck")
                        break
                    case "respawn":
                    case "重生":
                        GetLocalClientPlayer().ClientCommand("CC_RespawnPlayer Pilot")
                        break
                    case "quit":
                    case "exit":
                    case "退出":
                        controlList.remove(controlIndexCount2)
                        isControl --
                        local start3 = fromPlayerName.find("] ")
                        string fromPlayerNameNoClan = fromPlayerName
                        if (start3 != null ){
                            fromPlayerNameNoClan = fromPlayerName.slice(start3 + 2)
                        }
                        GetLocalClientPlayer().ClientCommand(say + "【XDbot】好的 " + fromPlayerNameNoClan + "！退出操控模式...")
                        break
                    // case "撤退！":
                    //     string color = GetRandomColor()
                    //     GetLocalClientPlayer().ClientCommand( say + "\" 好的！撤退！！！" + color + "(≧▽≦)/ [0m\"")
                    //     wait 1
                    //     GetLocalClientPlayer().ClientCommand("disconnect")
                    //     break
                }
                break
            } else {
                controlIndexCount2 ++
            }
        }
    }
}

bool function CheckOP(string fromPlayerName){
    local start2 = fromPlayerName.find("] ")
    if (start2 != null ){
        fromPlayerName = fromPlayerName.slice(start2 + 2)
    }
    switch(fromPlayerName){
        // uwu
            return true
        // default:
    }
    if ( getMeleePrint()){
        foreach ( temp in tempOp ){
            if ( fromPlayerName == temp ){
                return true
            }
        }
    }
    return false
}

void function executiveDoubleJump(string text, int time){
    if (time > 10){
        time = 10
    }
    for (int i=0; i<time; i++){
        GetLocalClientPlayer().ClientCommand("+" + text)
        wait 0.01
        GetLocalClientPlayer().ClientCommand("-" + text)
        wait 0.99
    }
}


void function executiveSingleCmd(string text){
    GetLocalClientPlayer().ClientCommand("+" + text)
    wait 0.01
    GetLocalClientPlayer().ClientCommand("-" + text)
}

void function isMoveStateDetected(int index){
    isMoveList[index] = true
    wait 0.2
    isMoveList[index] = false
}

void function executivePersistentCmd(string text, float time, int index){
    isMoveList[index] = true
    if (time < 0.01){
        time = 0.01
    }
//     float loop = frequency/0.1
//     //        0.14           1        2次     2： j= 2    loop = 1.4  j+1 >=? loop wait loop - j          0.1         1 等不等于无所谓 
//     for (int j = 0 ; j <= loop; j++){
// // 0.11 0.01                 
//         if (sudoStop){
//             GetLocalClientPlayer().ClientCommand("-" + command)
//             thread threadWaitSudoStop()
//             return
//         }
//         if ( j + 1 >= loop ){
//             wait (loop - j)/10
//             // print((loop - j)/10)
//             break
//         }
    GetLocalClientPlayer().ClientCommand("+" + text)
    float loop = time/0.1
    for (int i = 0; i <= loop; i++){
        if (i == 0){
            thread isMoveStateDetected(index)
            // 线程 检查0.2s检测i大小
        }
        if( isMoveList[index] && i > 2 ){
            return
        }
        if ( i + 1 >= loop ){
            wait (loop - i)/10
            break
        }
        wait 0.1
        // 如果 检测开启 检测i大小 如果i大于3 break
        if (cmdStop){
            GetLocalClientPlayer().ClientCommand("-" + text)
            thread threadWaitCmdStop()
            return
        }
    }
    GetLocalClientPlayer().ClientCommand("-" + text)
}

void function executiveFlutterCmd(string text, float time){
    cmdStop = false
    if (time < 0.01){
        time = 0.01
    }
    for (int i = 0; i < time/(1.0/60); i++){
        GetLocalClientPlayer().ClientCommand("+" + text)
        wait 1/120
        GetLocalClientPlayer().ClientCommand("-" + text)
        wait 1/120
        if (cmdStop){
            thread threadWaitCmdStop()
            return
        }
    }

}

void function threadWaitCmdStop(){
    wait 0.2
    cmdStop = false
}

void function threadWaitSudoStop(){
    wait 0.2
    sudoStop = false
}

void function xdSudoCommand(string command){
    sudoStop = false
    // cmdStop = false
    try {
        local parts = split(command, " ");
        if (parts.len() == 3){
            local strPart = parts[0]
            local command = parts[1]
            local timePart = parts[2]
            if(strPart == "continuous"){
                float time = 1
                try {
                    time = float(timePart)
                }
                catch (err){
                    print("2222sudo   " + err)
                }
                GetLocalClientPlayer().ClientCommand("+" + command)
                for (int i = 0; i < time/0.1; i++){
                    if (sudoStop){
                        thread threadWaitSudoStop()
                        break
                    }
                    wait 0.1
                    // print ("0.1")
                }
                GetLocalClientPlayer().ClientCommand("-" + command)
            }
        }
        if (parts.len() == 5){
            local strPart = parts[0]
            local command = parts[1]
            local numPart = parts[2]
            local numPart2 = parts[3]
            local timePart = parts[4]
            if(strPart == "flutter"){
                float time = 1
                try {
                    time = float(timePart)
                }
                catch (err){
                    print("2222 timePart  " + err)
                }
                float frequency = 1.0/120
                try {
                    frequency = float(numPart)
                }
                catch (err2){
                    print("2222frequency   " + err2)
                }
                float frequency2 = 1.0/120
                try {
                    frequency2 = float(numPart2)
                }
                catch (err3){
                    print("3333frequency   " + err2)
                }
                float loop0 = time/(frequency+frequency2)
                for (float i = 0; i < loop0; i++){
                    GetLocalClientPlayer().ClientCommand("+" + command)
                    if( frequency < 0.1 ){
                        wait frequency
                        if (sudoStop){
                            GetLocalClientPlayer().ClientCommand("-" + command)
                            thread threadWaitSudoStop()
                            return
                        }
                    } else {
                        float loop = frequency/0.1
                        //        0.14           1        2次     2： j= 2    loop = 1.4  j+1 >=? loop wait loop - j          0.1         1 等不等于无所谓 
                        for (int j = 0 ; j <= loop; j++){
// 0.11 0.01                 
                            if (sudoStop){
                                GetLocalClientPlayer().ClientCommand("-" + command)
                                thread threadWaitSudoStop()
                                return
                            }
                            if ( j + 1 >= loop ){
                                wait (loop - j)/10
                                // print((loop - j)/10)
                                break
                            }
                            wait 0.1
                            // print("0.1")

                        }
                    }
                    GetLocalClientPlayer().ClientCommand("-" + command)
                    if( frequency2 < 0.1 ){
                        wait frequency2
                        if (sudoStop){
                            thread threadWaitSudoStop()
                            return
                        }
                    } else {
                        float loop2 = frequency2/0.1
                        for (int k = 0 ; k <= loop2; k++){   
                            if (sudoStop){
                                thread threadWaitSudoStop()
                                return
                            }  
                            if ( k + 1 >= loop2 ){
                                wait (loop2 - k)/10
                                // print((loop2 - k)/10)
                                break
                            }
                            wait 0.1
                            print("0.1")

                        }
                    }

                }
            }


        }

        
        // 尝试将第二部分转换为浮点数

    }
    catch (err) {
        print("1111   " + err)
    }
}










void function CloseDetectPy(){
    wait 0.1
    NSLoadFile("state.txt", OnFileSuccess, OnFileFailure)
}

void function OnFileSuccess( string data )
{
    if (data == "0"){
        pyState = false
    }
}

void function DetectPyReturn(){
    while(true){
        wait 0.2
        if ( pyState ){
            NSLoadJSONFile("py_XD.json", OnPyMessageJSONSuccess, OnJSONFailure)
        } else {
            pyWaitCount = 0
            return
        }
    }
}

// 循环加载 py 在len不等于0 时 有数据时 读取state 看需不需要isshoudpy true，return 
void function OnPyMessageJSONSuccess( table jsonData )
{
    if( jsonData.len() == 0 ){
        pyWaitCount ++
        if(pyWaitCount % 100 == 0){
            print("[XDPY] 等待返回..... " + pyWaitCount)
        }
        if( pyWaitCount == 600 ){
            print("[XDPY] !!!!!!响应超时..... " + pyWaitCount)
            GetLocalClientPlayer().ClientCommand("say 【XDbot】py接口超时响应...")
        }
    } else {
        NSSaveFile("py_XD.json", "{}")
        foreach (keyTime, valueTime in jsonData)
        {
            foreach(keyName, value in valueTime){
                local command = value["command"]
                switch(command){
                    case "pinyin":
                        local TransToChinese = value["pyMessage"]
                        if ( TransToChinese != "" ){
                            GetLocalClientPlayer().ClientCommand(value["say"] + "【转文字Beta】" + keyName + "：" + TransToChinese)
                        }
                        break
                    case "time":
                        GetLocalClientPlayer().ClientCommand(value["say"] + "【XDbot】现在是 北京时间 [33m" + value["pyMessage"] + " [0m！")
                        break
                    case "ai":
                        foreach (idx, content in value["pyMessage"]){
                            if (idx == 0){
                                GetLocalClientPlayer().ClientCommand(value["say"] + "【XDAI】" + content)
                            }else {
                                GetLocalClientPlayer().ClientCommand(value["say"] + content)
                            }
                        }

                }
            }
        }
        
        thread CloseDetectPy()
    }

}




void function LoadChatJsonData(string jsonPath){
    NSLoadJSONFile(jsonPath, OnPyMessageJSONSuccess, OnJSONFailure)
}

void function PyProcess(command, message, fromPlayerName, say, needReturn){
    float time = Time()
    if ( time == lastPyTime ){
        wait 0.01
    }
    lastPyTime = time
    table<string,var> XD_table = {}
    XD_table[string(Time())] <- { [fromPlayerName] = {["command"] = command, ["message"] = message, ["say"] = say} }
    NSSaveJSONFile("XD.json", XD_table)
    if (needReturn && !pyState){
        pyState = true
        thread DetectPyReturn()
    }
}


void function globalTransToChinese(string playerNameClan, string message, string say){
    // print("PinyinState() " + PinyinState())
    local pinyinList = split(message, " ")
    if ( pinyinList.len() > 1 && ( ( pinyinList[1].len() < 7 && isAlphabet(pinyinList[1].slice(0,1)) ) || ( pinyinList[0].len() < 7 && isAlphabet(pinyinList[0].slice(0,1)) ) ) ){
        // local TransToChinese = getPinyinChar( pinyinList, true )
        // // print( "TransToChinese" + TransToChinese )
        // if ( TransToChinese != false  ){
        //     GetLocalClientPlayer().ClientCommand(say + "【转文字破损版】" + playerNameClan + "：" + TransToChinese)
        // }
        PyProcess("g_pinyin", message, playerNameClan, say, true)
    }
}

string function trim(string command){
    if( command.len() > 0 && command.slice(0,1) == " " ){
        command = command.slice(1)
        while (command.len() > 0 && command.slice(0,1) == " ") {
            command = command.slice(1)
        }
        return command
    }
    return command
}

function trimVar(command){
    if( command.len() > 0 && command.slice(0,1) == " " ){
        command = command.slice(1)
        while (command.len() > 0 && command.slice(0,1) == " ") {
            command = command.slice(1)
        }
        return command
    }
    return command
}

bool function isAlphabet(char) {
    // 检查字符是否在大小写字母范围内
    return ((char >= "A" && char <= "Z") || (char >= "a" && char <= "z"));
}

bool function PinyinState(){
	switch (isPinyinOpen){
		case 2:
			if( isAutoPrintRestrictedMod == 1 || isAutoPrintRestrictedMod == 3 ){
				return true
			}
			return false
		case 1:
			return true
		case 0:
			return false
		default:
			return false
	}
	return false
}


void function OnFileFailure()
{
    NSChatWrite(1, "\n[38;2;125;125;254m[XDlog] FILE 加载失败")
}


void function OnJSONSuccess( table jsonData )
{
    print("JSON 加载成功!")
    foreach (key, value in jsonData)
    {
        print(key + ": " + value)
    }

}

void function OnJSONFailure()
{
    NSChatWrite(1, "\n[38;2;125;125;254m[XDlog] JSON 加载失败")
}











void function AddCallback_OnReceivedSayTextMessage( ClClient_MessageStruct functionref (ClClient_MessageStruct) callbackFunc )
{
	NsCustomCallbacksClient.OnReceivedSayTextMessageCallbacks.append(callbackFunc)
}





// ClClient_MessageStruct function MyChatFilter(ClClient_MessageStruct message)
// {
//     if (message.message.find("nft") != null)
//     {
//         message.shouldBlock = true
//     }

//     message.message = StringReplace(message.message, "yes", "no", true, true)

//     return message
// }

// void function MyModInit()
// {
//     AddCallback_OnReceivedSayTextMessage(MyChatFilter)
// }











function getPinyinChar(pinyinList, bool isWrongCheck) {
    int wrong = 0
    local TransToChinese = ""
    foreach (index, pinyin in pinyinList ){
        pinyin = pinyin.tolower()
        local pinyinTrans = ""
        bool isTrans = false
        switch(pinyin) {
            case "a": pinyinTrans = "阿"; isTrans = true; break;
            case "ai": pinyinTrans = "爱"; isTrans = true; break;
            case "an": pinyinTrans = ["白", "摆", "百"].getrandom(); isTrans = true; break;
            case "ang": pinyinTrans = "昂"; isTrans = true; break;
            case "ao": pinyinTrans = "嗷"; isTrans = true; break;
            case "ba": pinyinTrans = ["吧", "八"].getrandom(); isTrans = true; break;
            case "bai": pinyinTrans = ["白", "摆", "百"].getrandom(); isTrans = true; break;
            case "ban": pinyinTrans = ["半", "办", "般"].getrandom(); isTrans = true; break;
            case "bang": pinyinTrans = "帮"; isTrans = true; break;
            case "bao": pinyinTrans = ["包", "爆", "饱"].getrandom(); isTrans = true; break;
            case "bei": pinyinTrans = "被"; isTrans = true; break;
            case "ben": pinyinTrans = ["本", "笨"].getrandom(); isTrans = true; break;
            case "beng": pinyinTrans = ["崩", "蹦"].getrandom(); isTrans = true; break;
            case "bi": pinyinTrans = "比"; isTrans = true; break;
            case "bian": pinyinTrans = "边"; isTrans = true; break;
            case "biao": pinyinTrans = ["表", "标"].getrandom(); isTrans = true; break;
            case "bie": pinyinTrans = "别"; isTrans = true; break;
            case "bin": pinyinTrans = ["宾", "彬"].getrandom(); isTrans = true; break;
            case "bing": pinyinTrans = "并"; isTrans = true; break;
            case "bo": pinyinTrans = "波"; isTrans = true; break;
            case "bu": pinyinTrans = "不"; isTrans = true; break;
            case "ca": pinyinTrans = "擦"; isTrans = true; break;
            case "cai": pinyinTrans = ["才", "猜"].getrandom(); isTrans = true; break;
            case "can": pinyinTrans = ["惨", "残"].getrandom(); isTrans = true; break;
            case "cang": pinyinTrans = "藏"; isTrans = true; break;
            case "cao": pinyinTrans = "草"; isTrans = true; break;
            case "ce": pinyinTrans = "测"; isTrans = true; break;
            case "cen": pinyinTrans = "参"; isTrans = true; break;
            case "ceng": pinyinTrans = "曾"; isTrans = true; break;
            case "cha": pinyinTrans = ["差", "查"].getrandom(); isTrans = true; break;
            case "chai": pinyinTrans = "拆"; isTrans = true; break;
            case "chan": pinyinTrans = "颤"; isTrans = true; break;
            case "chang": pinyinTrans = ["长", "常"].getrandom(); isTrans = true; break;
            case "chao": pinyinTrans = "超"; isTrans = true; break;
            case "che": pinyinTrans = "车"; isTrans = true; break;
            case "chen": pinyinTrans = "趁"; isTrans = true; break;
            case "cheng": pinyinTrans = "成"; isTrans = true; break;
            case "chi": pinyinTrans = "吃"; isTrans = true; break;
            case "chong": pinyinTrans = "冲"; isTrans = true; break;
            case "chou": pinyinTrans = "抽"; isTrans = true; break;
            case "chu": pinyinTrans = "出"; isTrans = true; break;
            case "chua": pinyinTrans = "歘"; isTrans = true; break;
            case "chuai": pinyinTrans = "踹"; isTrans = true; break;
            case "chuan": pinyinTrans = "穿"; isTrans = true; break;
            case "chuang": pinyinTrans = "床"; isTrans = true; break;
            case "chui": pinyinTrans = ["吹", "锤"].getrandom(); isTrans = true; break;
            case "chun": pinyinTrans = ["春", "蠢"].getrandom(); isTrans = true; break;
            case "chuo": pinyinTrans = "戳"; isTrans = true; break;
            case "ci": pinyinTrans = ["此", "刺"].getrandom(); isTrans = true; break;
            case "cong": pinyinTrans = "从"; isTrans = true; break;
            case "cou": pinyinTrans = "凑"; isTrans = true; break;
            case "cu": pinyinTrans = "粗"; isTrans = true; break;
            case "cuan": pinyinTrans = "窜"; isTrans = true; break;
            case "cui": pinyinTrans = "脆"; isTrans = true; break;
            case "cun": pinyinTrans = "村"; isTrans = true; break;
            case "cuo": pinyinTrans = "搓"; isTrans = true; break;
            case "da": pinyinTrans = ["打", "大"].getrandom(); isTrans = true; break;
            case "dai": pinyinTrans = "带"; isTrans = true; break;
            case "dan": pinyinTrans = ["但", "蛋"].getrandom(); isTrans = true; break;
            case "dang": pinyinTrans = "当"; isTrans = true; break;
            case "dao": pinyinTrans = "到"; isTrans = true; break;
            case "de": pinyinTrans = "的"; isTrans = true; break;
            case "dei": pinyinTrans = "得"; isTrans = true; break;
            case "den": pinyinTrans = "扽"; isTrans = true; break;
            case "deng": pinyinTrans = ["等", "登"].getrandom(); isTrans = true; break;
            case "di": pinyinTrans = ["第", "地", "滴"].getrandom(); isTrans = true; break;
            case "dia": pinyinTrans = "嗲"; isTrans = true; break;
            case "dian": pinyinTrans = "点"; isTrans = true; break;
            case "diao": pinyinTrans = "掉"; isTrans = true; break;
            case "die": pinyinTrans = ["叠", "跌", "蝶"].getrandom(); isTrans = true; break;
            case "ding": pinyinTrans = ["定", "顶"].getrandom(); isTrans = true; break;
            case "diu": pinyinTrans = "丢"; isTrans = true; break;
            case "dong": pinyinTrans = "动"; isTrans = true; break;
            case "dou": pinyinTrans = "都"; isTrans = true; break;
            case "du": pinyinTrans = "堵"; isTrans = true; break;
            case "duan": pinyinTrans = "断"; isTrans = true; break;
            case "dui": pinyinTrans = "对"; isTrans = true; break;
            case "dun": pinyinTrans = "顿"; isTrans = true; break;
            case "duo": pinyinTrans = "多"; isTrans = true; break;
            case "e": pinyinTrans = "饿"; isTrans = true; break;
            case "ei": pinyinTrans = "诶"; isTrans = true; break;
            case "en": pinyinTrans = "嗯"; isTrans = true; break;
            case "eng": pinyinTrans = "嗯"; isTrans = true; break;
            case "er": pinyinTrans = "而"; isTrans = true; break;
            case "fa": pinyinTrans = "发"; isTrans = true; break;
            case "fan": pinyinTrans = "反"; isTrans = true; break;
            case "fang": pinyinTrans = "放"; isTrans = true; break;
            case "fei": pinyinTrans = "非"; isTrans = true; break;
            case "fen": pinyinTrans = "分"; isTrans = true; break;
            case "feng": pinyinTrans = "风"; isTrans = true; break;
            case "fo": pinyinTrans = "佛"; isTrans = true; break;
            case "fou": pinyinTrans = "否"; isTrans = true; break;
            case "fu": pinyinTrans = "服"; isTrans = true; break;
            case "ga": pinyinTrans = "嘎"; isTrans = true; break;
            case "gai": pinyinTrans = "该"; isTrans = true; break;
            case "gan": pinyinTrans = ["干", "感"].getrandom(); isTrans = true; break;
            case "gang": pinyinTrans = "刚"; isTrans = true; break;
            case "gao": pinyinTrans = "高"; isTrans = true; break;
            case "ge": pinyinTrans = "个"; isTrans = true; break;
            case "gei": pinyinTrans = "给"; isTrans = true; break;
            case "gen": pinyinTrans = "跟"; isTrans = true; break;
            case "geng": pinyinTrans = "更"; isTrans = true; break;
            case "gong": pinyinTrans = "攻"; isTrans = true; break;
            case "gou": pinyinTrans = "够"; isTrans = true; break;
            case "gu": pinyinTrans = "咕"; isTrans = true; break;
            case "gua": pinyinTrans = ["挂", "呱"].getrandom(); isTrans = true; break;
            case "guai": pinyinTrans = "怪"; isTrans = true; break;
            case "guan": pinyinTrans = "关"; isTrans = true; break;
            case "guang": pinyinTrans = "光"; isTrans = true; break;
            case "gui": pinyinTrans = "规"; isTrans = true; break;
            case "gun": pinyinTrans = "滚"; isTrans = true; break;
            case "guo": pinyinTrans = "过"; isTrans = true; break;
            case "ha": pinyinTrans = "哈"; isTrans = true; break;
            case "hai": pinyinTrans = "还"; isTrans = true; break;
            case "han": pinyinTrans = "汗"; isTrans = true; break;
            case "hang": pinyinTrans = "行"; isTrans = true; break;
            case "hao": pinyinTrans = "好"; isTrans = true; break;
            case "he": pinyinTrans = "和"; isTrans = true; break;
            case "hei": pinyinTrans = "黑"; isTrans = true; break;
            case "hen": pinyinTrans = "很"; isTrans = true; break;
            case "heng": pinyinTrans = "横"; isTrans = true; break;
            case "hong": pinyinTrans = "红"; isTrans = true; break;
            case "hou": pinyinTrans = "后"; isTrans = true; break;
            case "hu": pinyinTrans = "户"; isTrans = true; break;
            case "hua": pinyinTrans = "话"; isTrans = true; break;
            case "huai": pinyinTrans = "坏"; isTrans = true; break;
            case "huan": pinyinTrans = "欢"; isTrans = true; break;
            case "huang": pinyinTrans = "黄"; isTrans = true; break;
            case "hui": pinyinTrans = "会"; isTrans = true; break;
            case "hun": pinyinTrans = "混"; isTrans = true; break;
            case "huo": pinyinTrans = "或"; isTrans = true; break;
            case "ji": pinyinTrans = ["几", "及"].getrandom(); isTrans = true; break;
            case "jia": pinyinTrans = "加"; isTrans = true; break;
            case "jian": pinyinTrans = "间"; isTrans = true; break;
            case "jiang": pinyinTrans = "将"; isTrans = true; break;
            case "jiao": pinyinTrans = "教"; isTrans = true; break;
            case "jie": pinyinTrans = "结"; isTrans = true; break;
            case "jin": pinyinTrans = "今"; isTrans = true; break;
            case "jing": pinyinTrans = "经"; isTrans = true; break;
            case "jiong": pinyinTrans = "窘"; isTrans = true; break;
            case "jiu": pinyinTrans = "就"; isTrans = true; break;
            case "ju": pinyinTrans = ["局", "狙"].getrandom(); isTrans = true; break;
            case "juan": pinyinTrans = "卷"; isTrans = true; break;
            case "jue": pinyinTrans = "决"; isTrans = true; break;
            case "jun": pinyinTrans = "均"; isTrans = true; break;
            case "ka": pinyinTrans = "卡"; isTrans = true; break;
            case "kai": pinyinTrans = "开"; isTrans = true; break;
            case "kan": pinyinTrans = "看"; isTrans = true; break;
            case "kang": pinyinTrans = "康"; isTrans = true; break;
            case "kao": pinyinTrans = "靠"; isTrans = true; break;
            case "ke": pinyinTrans = "可"; isTrans = true; break;
            case "ken": pinyinTrans = "肯"; isTrans = true; break;
            case "keng": pinyinTrans = "坑"; isTrans = true; break;
            case "kong": pinyinTrans = "空"; isTrans = true; break;
            case "kou": pinyinTrans = "口"; isTrans = true; break;
            case "ku": pinyinTrans = "苦"; isTrans = true; break;
            case "kua": pinyinTrans = "跨"; isTrans = true; break;
            case "kuai": pinyinTrans = "快"; isTrans = true; break;
            case "kuan": pinyinTrans = "宽"; isTrans = true; break;
            case "kuang": pinyinTrans = "况"; isTrans = true; break;
            case "kui": pinyinTrans = "亏"; isTrans = true; break;
            case "kun": pinyinTrans = "困"; isTrans = true; break;
            case "kuo": pinyinTrans = "扩"; isTrans = true; break;
            case "la": pinyinTrans = ["啦", "拉"].getrandom(); isTrans = true; break;
            case "lai": pinyinTrans = "来"; isTrans = true; break;
            case "lan": pinyinTrans = "烂"; isTrans = true; break;
            case "lang": pinyinTrans = "浪"; isTrans = true; break;
            case "lao": pinyinTrans = "老"; isTrans = true; break;
            case "le": pinyinTrans = "了"; isTrans = true; break;
            case "lei": pinyinTrans = "类"; isTrans = true; break;
            case "leng": pinyinTrans = "冷"; isTrans = true; break;
            case "li": pinyinTrans = "里"; isTrans = true; break;
            case "lia": pinyinTrans = "俩"; isTrans = true; break;
            case "lian": pinyinTrans = "连"; isTrans = true; break;
            case "liang": pinyinTrans = "两"; isTrans = true; break;
            case "liao": pinyinTrans = "聊"; isTrans = true; break;
            case "lie": pinyinTrans = "猎"; isTrans = true; break;
            case "lin": pinyinTrans = "临"; isTrans = true; break;
            case "ling": pinyinTrans = ["零", "领"].getrandom(); isTrans = true; break;
            case "liu": pinyinTrans = ["零", "留"].getrandom(); isTrans = true; break;
            case "lo": pinyinTrans = "咯"; isTrans = true; break;
            case "long": pinyinTrans = "龙"; isTrans = true; break;
            case "lou": pinyinTrans = "漏"; isTrans = true; break;
            case "lu": pinyinTrans = "路"; isTrans = true; break;
            case "luan": pinyinTrans = "乱"; isTrans = true; break;
            case "lun": pinyinTrans = "论"; isTrans = true; break;
            case "luo": pinyinTrans = "落"; isTrans = true; break;
            case "lv": pinyinTrans = ["绿", "率"].getrandom(); isTrans = true; break;
            case "lve": pinyinTrans = "略"; isTrans = true; break;
            case "ma": pinyinTrans = "吗"; isTrans = true; break;
            case "mai": pinyinTrans = "买"; isTrans = true; break;
            case "man": pinyinTrans = "满"; isTrans = true; break;
            case "mang": pinyinTrans = ["忙", "盲"].getrandom(); isTrans = true; break;
            case "mao": pinyinTrans = ["猫", "冒"].getrandom(); isTrans = true; break;
            case "me": pinyinTrans = "么"; isTrans = true; break;
            case "mei": pinyinTrans = "没"; isTrans = true; break;
            case "men": pinyinTrans = "们"; isTrans = true; break;
            case "meng": pinyinTrans = "萌"; isTrans = true; break;
            case "mi": pinyinTrans = "米"; isTrans = true; break;
            case "mian": pinyinTrans = "面"; isTrans = true; break;
            case "miao": pinyinTrans = ["喵", "秒", "妙"].getrandom(); isTrans = true; break;
            case "mie": pinyinTrans = ["咩", "灭"].getrandom(); isTrans = true; break;
            case "min": pinyinTrans = "敏"; isTrans = true; break;
            case "ming": pinyinTrans = "明"; isTrans = true; break;
            case "miu": pinyinTrans = "谬"; isTrans = true; break;
            case "mo": pinyinTrans = ["摸", "么"].getrandom(); isTrans = true; break;
            case "mou": pinyinTrans = "某"; isTrans = true; break;
            case "mu": pinyinTrans = "目"; isTrans = true; break;
            case "na": pinyinTrans = "那"; isTrans = true; break;
            case "nai": pinyinTrans = "乃"; isTrans = true; break;
            case "nan": pinyinTrans = "难"; isTrans = true; break;
            case "nang": pinyinTrans = "囊"; isTrans = true; break;
            case "nao": pinyinTrans = "脑"; isTrans = true; break;
            case "ne": pinyinTrans = "呢"; isTrans = true; break;
            case "nei": pinyinTrans = "内"; isTrans = true; break;
            case "nen": pinyinTrans = "嫩"; isTrans = true; break;
            case "neng": pinyinTrans = "能"; isTrans = true; break;
            case "ni": pinyinTrans = "你"; isTrans = true; break;
            case "nian": pinyinTrans = "年"; isTrans = true; break;
            case "niang": pinyinTrans = "娘"; isTrans = true; break;
            case "niao": pinyinTrans = "鸟"; isTrans = true; break;
            case "nie": pinyinTrans = "捏"; isTrans = true; break;
            case "nin": pinyinTrans = "您"; isTrans = true; break;
            case "ning": pinyinTrans = "宁"; isTrans = true; break;
            case "niu": pinyinTrans = "牛"; isTrans = true; break;
            case "nong": pinyinTrans = "弄"; isTrans = true; break;
            case "nou": pinyinTrans = "耨"; isTrans = true; break;
            case "nu": pinyinTrans = "努"; isTrans = true; break;
            case "nuan": pinyinTrans = "暖"; isTrans = true; break;
            case "nuo": pinyinTrans = "挪"; isTrans = true; break;
            case "nv": pinyinTrans = "女"; isTrans = true; break;
            case "nve": pinyinTrans = "虐"; isTrans = true; break;
            case "o": pinyinTrans = ["哦", "噢"].getrandom(); isTrans = true; break;
            case "ou": pinyinTrans = "欧"; isTrans = true; break;
            default:
                switch(pinyin){
                    case "pa": pinyinTrans = "怕"; isTrans = true; break;
                    case "pai": pinyinTrans = "派"; isTrans = true; break;
                    case "pan": pinyinTrans = "盘"; isTrans = true; break;
                    case "pang": pinyinTrans = "旁"; isTrans = true; break;
                    case "pao": pinyinTrans = "跑"; isTrans = true; break;
                    case "pei": pinyinTrans = "配"; isTrans = true; break;
                    case "pen": pinyinTrans = "喷"; isTrans = true; break;
                    case "peng": pinyinTrans = "碰"; isTrans = true; break;
                    case "pi": pinyinTrans = "皮"; isTrans = true; break;
                    case "pian": pinyinTrans = ["片", "偏"]; isTrans = true; break;
                    case "piao": pinyinTrans = "飘"; isTrans = true; break;
                    case "pie": pinyinTrans = "撇"; isTrans = true; break;
                    case "pin": pinyinTrans = "拼"; isTrans = true; break;
                    case "ping": pinyinTrans = "平"; isTrans = true; break;
                    case "po": pinyinTrans = "破"; isTrans = true; break;
                    case "pou": pinyinTrans = "剖"; isTrans = true; break;
                    case "pu": pinyinTrans = "普"; isTrans = true; break;
                    case "qi": pinyinTrans = "起"; isTrans = true; break;
                    case "qia": pinyinTrans = "恰"; isTrans = true; break;
                    case "qian": pinyinTrans = "前"; isTrans = true; break;
                    case "qiang": pinyinTrans = ["强", "枪"].getrandom(); isTrans = true; break;
                    case "qiao": pinyinTrans = ["巧", "敲", "桥"].getrandom(); isTrans = true; break;
                    case "qie": pinyinTrans = "且"; isTrans = true; break;
                    case "qin": pinyinTrans = "勤"; isTrans = true; break;
                    case "qing": pinyinTrans = "请"; isTrans = true; break;
                    case "qiong": pinyinTrans = "穷"; isTrans = true; break;
                    case "qiu": pinyinTrans = "求"; isTrans = true; break;
                    case "qu": pinyinTrans = "去"; isTrans = true; break;
                    case "quan": pinyinTrans = "全"; isTrans = true; break;
                    case "que": pinyinTrans = ["却", "确"].getrandom(); isTrans = true; break;
                    case "qun": pinyinTrans = "群"; isTrans = true; break;
                    case "ran": pinyinTrans = "然"; isTrans = true; break;
                    case "rang": pinyinTrans = "让"; isTrans = true; break;
                    case "rao": pinyinTrans = "绕"; isTrans = true; break;
                    case "re": pinyinTrans = "热"; isTrans = true; break;
                    case "ren": pinyinTrans = ["人", "认"].getrandom(); isTrans = true; break;
                    case "reng": pinyinTrans = "扔"; isTrans = true; break;
                    case "ri": pinyinTrans = "日"; isTrans = true; break;
                    case "rong": pinyinTrans = "容"; isTrans = true; break;
                    case "rou": pinyinTrans = ["揉", "揉", "肉"].getrandom(); isTrans = true; break;
                    case "ru": pinyinTrans = "如"; isTrans = true; break;
                    case "ruan": pinyinTrans = "软"; isTrans = true; break;
                    case "rui": pinyinTrans = "锐"; isTrans = true; break;
                    case "run": pinyinTrans = "润"; isTrans = true; break;
                    case "ruo": pinyinTrans = ["弱", "若"].getrandom(); isTrans = true; break;
                    case "sa": pinyinTrans = "撒"; isTrans = true; break;
                    case "sai": pinyinTrans = "塞"; isTrans = true; break;
                    case "san": pinyinTrans = "三"; isTrans = true; break;
                    case "sang": pinyinTrans = "桑"; isTrans = true; break;
                    case "sao": pinyinTrans = "扫"; isTrans = true; break;
                    case "se": pinyinTrans = "色"; isTrans = true; break;
                    case "sen": pinyinTrans = "森"; isTrans = true; break;
                    case "seng": pinyinTrans = "僧"; isTrans = true; break;
                    case "sha": pinyinTrans = "杀"; isTrans = true; break;
                    case "shai": pinyinTrans = "筛"; isTrans = true; break;
                    case "shan": pinyinTrans = ["闪", "删"].getrandom(); isTrans = true; break;
                    case "shang": pinyinTrans = "上"; isTrans = true; break;
                    case "shao": pinyinTrans = "少"; isTrans = true; break;
                    case "she": pinyinTrans = "射"; isTrans = true; break;
                    case "shei": pinyinTrans = "谁"; isTrans = true; break;
                    case "shen": pinyinTrans = "什"; isTrans = true; break;
                    case "sheng": pinyinTrans = ["声", "剩"].getrandom(); isTrans = true; break;
                    case "shi": pinyinTrans = "是"; isTrans = true; break;
                    case "shou": pinyinTrans = "手"; isTrans = true; break;
                    case "shu": pinyinTrans = ["数", "薯"].getrandom(); isTrans = true; break;
                    case "shua": pinyinTrans = "刷"; isTrans = true; break;
                    case "shuai": pinyinTrans = "甩"; isTrans = true; break;
                    case "shuan": pinyinTrans = "栓"; isTrans = true; break;
                    case "shuang": pinyinTrans = ["爽", "双"].getrandom(); isTrans = true; break;
                    case "shui": pinyinTrans = "水"; isTrans = true; break;
                    case "shun": pinyinTrans = "瞬"; isTrans = true; break;
                    case "shuo": pinyinTrans = "说"; isTrans = true; break;
                    case "si": pinyinTrans = "似"; isTrans = true; break;
                    case "song": pinyinTrans = "送"; isTrans = true; break;
                    case "sou": pinyinTrans = "搜"; isTrans = true; break;
                    case "su": pinyinTrans = "速"; isTrans = true; break;
                    case "suan": pinyinTrans = "算"; isTrans = true; break;
                    case "sui": pinyinTrans = "随"; isTrans = true; break;
                    case "sun": pinyinTrans = "损"; isTrans = true; break;
                    case "suo": pinyinTrans = "所"; isTrans = true; break;
                    case "ta": pinyinTrans = "他"; isTrans = true; break;
                    case "tai": pinyinTrans = "太"; isTrans = true; break;
                    case "tan": pinyinTrans = "弹"; isTrans = true; break;
                    case "tang": pinyinTrans = "糖"; isTrans = true; break;
                    case "tao": pinyinTrans = "套"; isTrans = true; break;
                    case "te": pinyinTrans = "特"; isTrans = true; break;
                    case "teng": pinyinTrans = "疼"; isTrans = true; break;
                    case "ti": pinyinTrans = "提"; isTrans = true; break;
                    case "tian": pinyinTrans = "天"; isTrans = true; break;
                    case "tiao": pinyinTrans = "跳"; isTrans = true; break;
                    case "tie": pinyinTrans = ["铁", "贴"].getrandom(); isTrans = true; break;
                    case "ting": pinyinTrans = ["停", "听"].getrandom(); isTrans = true; break;
                    case "tong": pinyinTrans = "同"; isTrans = true; break;
                    case "tou": pinyinTrans = "头"; isTrans = true; break;
                    case "tu": pinyinTrans = "图"; isTrans = true; break;
                    case "tuan": pinyinTrans = "团"; isTrans = true; break;
                    case "tui": pinyinTrans = ["推", "退"].getrandom(); isTrans = true; break;
                    case "tun": pinyinTrans = "吞"; isTrans = true; break;
                    case "tuo": pinyinTrans = "坨"; isTrans = true; break;
                    case "wa": pinyinTrans = "哇"; isTrans = true; break;
                    case "wai": pinyinTrans = "外"; isTrans = true; break;
                    case "wan": pinyinTrans = "玩"; isTrans = true; break;
                    case "wang": pinyinTrans = "忘"; isTrans = true; break;
                    case "wei": pinyinTrans = "为"; isTrans = true; break;
                    case "wen": pinyinTrans = "问"; isTrans = true; break;
                    case "weng": pinyinTrans = "嗡"; isTrans = true; break;
                    case "wo": pinyinTrans = "我"; isTrans = true; break;
                    case "wu": pinyinTrans = "无"; isTrans = true; break;
                    case "xi": pinyinTrans = "戏"; isTrans = true; break;
                    case "xia": pinyinTrans = "下"; isTrans = true; break;
                    case "xian": pinyinTrans = "现"; isTrans = true; break;
                    case "xiang": pinyinTrans = ["想", "像"].getrandom(); isTrans = true; break;
                    case "xiao": pinyinTrans = "小"; isTrans = true; break;
                    case "xie": pinyinTrans = ["些", "谢"].getrandom(); isTrans = true; break;
                    case "xin": pinyinTrans = "新"; isTrans = true; break;
                    case "xing": pinyinTrans = "行"; isTrans = true; break;
                    case "xiong": pinyinTrans = "凶"; isTrans = true; break;
                    case "xiu": pinyinTrans = "休"; isTrans = true; break;
                    case "xu": pinyinTrans = "需"; isTrans = true; break;
                    case "xuan": pinyinTrans = ["选", "悬"].getrandom(); isTrans = true; break;
                    case "xue": pinyinTrans = "学"; isTrans = true; break;
                    case "xun": pinyinTrans = "循"; isTrans = true; break;
                    case "ya": pinyinTrans = ["呀", "鸭"].getrandom(); isTrans = true; break;
                    case "yan": pinyinTrans = ["眼", "盐"].getrandom(); isTrans = true; break;
                    case "yang": pinyinTrans = "样"; isTrans = true; break;
                    case "yao": pinyinTrans = "要"; isTrans = true; break;
                    case "ye": pinyinTrans = "也"; isTrans = true; break;
                    case "yi": pinyinTrans = "一"; isTrans = true; break;
                    case "yin": pinyinTrans = "因"; isTrans = true; break;
                    case "ying": pinyinTrans = "应"; isTrans = true; break;
                    case "yo": pinyinTrans = "哟"; isTrans = true; break;
                    case "yong": pinyinTrans = "用"; isTrans = true; break;
                    case "you": pinyinTrans = ["有", "又"].getrandom(); isTrans = true; break;
                    case "yu": pinyinTrans = "于"; isTrans = true; break;
                    case "yuan": pinyinTrans = "圆"; isTrans = true; break;
                    case "yue": pinyinTrans = "越"; isTrans = true; break;
                    case "yun": pinyinTrans = "云"; isTrans = true; break;
                    case "za": pinyinTrans = "咋"; isTrans = true; break;
                    case "zai": pinyinTrans = ["在", "再"].getrandom(); isTrans = true; break;
                    case "zan": pinyinTrans = "咱"; isTrans = true; break;
                    case "zang": pinyinTrans = "脏"; isTrans = true; break;
                    case "zao": pinyinTrans = "早"; isTrans = true; break;
                    case "ze": pinyinTrans = "则"; isTrans = true; break;
                    case "zei": pinyinTrans = "贼"; isTrans = true; break;
                    case "zen": pinyinTrans = "怎"; isTrans = true; break;
                    case "zeng": pinyinTrans = "增"; isTrans = true; break;
                    case "zha": pinyinTrans = ["扎", "炸"].getrandom(); isTrans = true; break;
                    case "zhai": pinyinTrans = "摘"; isTrans = true; break;
                    case "zhan": pinyinTrans = "站"; isTrans = true; break;
                    case "zhang": pinyinTrans = "长"; isTrans = true; break;
                    case "zhao": pinyinTrans = "找"; isTrans = true; break;
                    case "zhe": pinyinTrans = "这"; isTrans = true; break;
                    case "zhei": pinyinTrans = "这"; isTrans = true; break;
                    case "zhen": pinyinTrans = "真"; isTrans = true; break;
                    case "zheng": pinyinTrans = "整"; isTrans = true; break;
                    case "zhi": pinyinTrans = ["只", "之"].getrandom(); isTrans = true; break;
                    case "zhong": pinyinTrans = ["终", "中"].getrandom(); isTrans = true; break;
                    case "zhou": pinyinTrans = "周"; isTrans = true; break;
                    case "zhu": pinyinTrans = "主"; isTrans = true; break;
                    case "zhua": pinyinTrans = "抓"; isTrans = true; break;
                    case "zhuai": pinyinTrans = "拽"; isTrans = true; break;
                    case "zhuan": pinyinTrans = "转"; isTrans = true; break;
                    case "zhuang": pinyinTrans = "装"; isTrans = true; break;
                    case "zhui": pinyinTrans = "追"; isTrans = true; break;
                    case "zhun": pinyinTrans = "准"; isTrans = true; break;
                    case "zhuo": pinyinTrans = "捉"; isTrans = true; break;
                    case "zi": pinyinTrans = "子"; isTrans = true; break;
                    case "zong": pinyinTrans = "总"; isTrans = true; break;
                    case "zou": pinyinTrans = "走"; isTrans = true; break;
                    case "zu": pinyinTrans = "组"; isTrans = true; break;
                    case "zuan": pinyinTrans = "钻"; isTrans = true; break;
                    case "zui": pinyinTrans = "最"; isTrans = true; break;
                    case "zun": pinyinTrans = "尊"; isTrans = true; break;
                    case "zuo": pinyinTrans = ["做", "作"].getrandom(); isTrans = true; break;
                    default: pinyinTrans = [pinyin]; isTrans = false; break;
                }
        }
        if ( isTrans ){
            TransToChinese += pinyinTrans
        } else{
            wrong ++
            TransToChinese += (" " + pinyinTrans[0] + " " )
        }
        if( isWrongCheck && wrong > pinyinList.len()/2 ){
            return false
        }
    }
    return TransToChinese
}