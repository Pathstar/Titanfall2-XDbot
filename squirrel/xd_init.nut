untyped

global function XD_PlayerInit
global function ModeListToStr
global function SavePlayersUID
global function collectPlayerUID

global table playersUID = {}
const string UIDJsonPath = "UID.json"
bool isUIDJsonLoad = false
// globalize_all_functions

void function XD_PlayerInit(){
	entity localPlayer = GetLocalClientPlayer()
	localPlayerName = localPlayer.GetPlayerName()
	localPlayerNameWithClan = localPlayer.GetPlayerNameWithClanTag()
	CreateAndShowNSCNRui()
	registerButton()
	thread PyXD_Init()
	GetLocalClientPlayer().ClientCommand("+showscores")
	mapName = GetMapName() 
	// config
	if (realAFK) {
		ModeListToStr("AFK", false)
	}
	thread CreateAndShowCoordinateRui()
	thread CreateAndShowTimeRui()
	thread CreateAndShowZeroPointRui()
	thread CreateTookDamageRui()


	// custom
	// AFKMode = 1	
	
	// BotCommand("sudo flutter 0.1 0.1 1000 duck")

	// 滋嘣
	// BotCommand("cmd flutter 1 1000 weaponSelectPrimary1")
	// BotCommand("sudo flutter 0.05 0.1 1000 attack")

	// 拉重力星
	// BotCommand("cmd flutter 0.4 1000 weaponSelectPrimary1")
	// wait 0.2
	// BotCommand("sudo flutter 0.2 0.2 1000 offhand0")


	//  攻击
	// BotCommand("sudo flutter 0.5 0.1 1000 attack")

	// double lstar
	// BotCommand("cmd flutter 7.5 1000 weaponSelectPrimary2")
	// wait 4.5
	// BotCommand("cmd flutter 7.5 1000 weaponSelectPrimary0")
	// BotCommand("sudo flutter 0.1 1 1000 offhand0")



	wait 1
	array playerList = GetPlayerArray()
	foreach ( player in GetPlayerArray() ){
		playerClanInGame[player.GetPlayerNameWithClanTag()] <- true
	}

	if ( playerList.len() == 1 ) thread NoPlayerAutoQuit();

	// load uid
	LoadPlayersUID()
	AddCallback_GameStateEnter( eGameState.WinnerDetermined, OnGameStateWinnerDeterminedXD )
}




void function ModeListToStr(string mode, bool isDel){
	string strTopText = topText
	if ( isDel ){
		local index = NSCNPlayerInfoRUIList.find(mode)
		if ( index != -1 ) {
			NSCNPlayerInfoRUIList.remove(index)
		}
		foreach ( mode in NSCNPlayerInfoRUIList ){
			strTopText += " " + mode
		}
	} else {
		NSCNPlayerInfoRUIList.append(mode)
		foreach ( mode in NSCNPlayerInfoRUIList ){
			strTopText += " " + mode
		}
	}
	RuiSetString(NSCNPlayerInfoRUI, "msgText", strTopText)
}




void function CreateAndShowNSCNRui(){
	string playerName = GetLocalClientPlayer().GetPlayerName()
	string playerUID = NSGetLocalPlayerUID()
	NSCNPlayerInfoRUI = RuiCreate($"ui/cockpit_console_text_top_left.rpak", clGlobal.topoFullScreen, RUI_DRAW_HUD, -1)
	RuiSetString(NSCNPlayerInfoRUI, "msgText", topText)
	RuiSetInt(NSCNPlayerInfoRUI, "lineNum", 1)
	RuiSetFloat(NSCNPlayerInfoRUI, "msgFontSize", 20)
	RuiSetFloat2(NSCNPlayerInfoRUI, "msgPos", <0.02,0,0.0>)
	RuiSetFloat(NSCNPlayerInfoRUI, "msgAlpha", 1)
	// RuiSetFloat(NSCNPlayerInfoRUI, "thicken", settings.bold)
	RuiSetFloat(NSCNPlayerInfoRUI, "thicken", 0.0)
	RuiSetFloat3(NSCNPlayerInfoRUI, "msgColor", <0.5, 0.5, 1.0>)	
}

void function CreateAndShowZeroPointRui(){
	RuiParams_Struct zeroPointRuiParams
	zeroPointRuiParams.pos = WorldToScreenPos( <0, 0, 0> )
		// ☆●♥♡◎¤℗❤✪☁⊹
	zeroPointRuiParams.text = "¤"
	zeroPointRuiParams.fontSize = 30.0
	// zeroPointRuiParams.alpha = 0
	WorldRuiCreate("zeroPoint", zeroPointRuiParams )
	showWorldRui(zeroPointRuiParams)
}

void function CreateAndShowCoordinateRui(){
	vector location = GetLocalClientPlayer().GetOrigin()
	RuiParams_Struct coordinateRuiParams
	coordinateRuiParams.pos = <0.02, 0.04, 0>
	coordinateRuiParams.text = string(location)

	local coordinateRui = WorldRuiCreate("coordinate", coordinateRuiParams )
	// local locationRui = ruiTable["location"]
	vector lastLocation = <0,0,0>
	while (true){
		wait 0.5
		location = GetLocalClientPlayer().GetOrigin()
		if ( lastLocation.z > 5000 && location.z < lastLocation.z && !isTimeBlocked("bwFly", 10) && AFKMode == 1 ){
			if ( isTimeAllowed("XDBOT_WHEEL_DOWN_JUMPS") ){
				string color = "[36m"
				string strHeight = " [33m" + lastLocation.z + color + " "
				array bwFly = [
					"被指令大手子一键送上天，直达" + strHeight + "米！连云层都懵了",
					"被指令大手子精准制导弹飞至" + strHeight + "米高空！NASA表示已锁定目标",
					"被指令大手子弹射到" + strHeight + "米！成功解锁“高空孤独症”成就",
					"被指令大手子弹飞至" + strHeight + "米！顺便和国际空间站打了个招呼",
					"被指令大手子的一记神秘力量送上" + strHeight + "米！地心引力表示放弃治疗",
					"被指令大手子弹飞！飞行高度:" + strHeight + "米！已超越鸟类尊严",
					"被指令大手子弹到了" + strHeight + "米的高空！简直了简直了"
					"被指令大手子弹到了" + strHeight + "米的高空！你是不是见是不是见是不是见是不是见是不是见是不是见是不是见"
					"被指令大手子弹到了" + strHeight + "米的高空！我捅死你捅死你捅死你捅死你捅死你捅死你捅死你捅死你捅死你"
				]
				xdObituary(say + color + bwFly.getrandom())
			} else {
				timeLimitTable["XDBOT_WHEEL_DOWN_JUMPS"] = Time()
			}

		}
		if ( lastLocation != location ){
			RuiSetString( coordinateRui, "msgText", string(location) )
			lastLocation = location
		}
	}
}

void function CreateAndShowTimeRui(){
	string strftime = formatDayStrftime(GetUnixTimeParts())


	RuiParams_Struct timeRuiParams
	timeRuiParams.pos = <0.02, 0.08, 0>
	timeRuiParams.text = strftime

	local timeRui = WorldRuiCreate("time", timeRuiParams )
	// 时间校准 快0-0.1秒
	while (true){
		wait 0.1
		if ( formatDayStrftime(GetUnixTimeParts()) != strftime ){
			RuiSetString( timeRui, "msgText", formatDayStrftime(GetUnixTimeParts()))
			break
		}
	}
	while (true){
		wait 1
		strftime = formatDayStrftime(GetUnixTimeParts())
		RuiSetString( timeRui, "msgText", strftime)
		// print(strftime)
		// if ( strftime == "23:45:00" ){
		// 	GetLocalClientPlayer().ClientCommand("say 新年倒计时15分钟！")
		// }
	
		// if ( strftime == "23:50:00" ){
		// 	GetLocalClientPlayer().ClientCommand("say 新年倒计时10分钟！")
		// }
	
		// if ( strftime == "23:55:00" ){
		// 	GetLocalClientPlayer().ClientCommand("say 新年倒计时5分钟！")
		// }
	
	
		// if ( strftime == "23:59:00" ){
		// 	GetLocalClientPlayer().ClientCommand("say 新年倒计时1分钟！")
		// }
	
		// if ( strftime == "23:59:50" ){
		// 	GetLocalClientPlayer().ClientCommand("say 新年倒计时10秒！")
		// }
	
	
		// if ( strftime == "00:00:00" ){
		// 	GetLocalClientPlayer().ClientCommand("say 2026 新年快乐！！！！111!!!!1!!!!!!!111!!")
		// }
	}
}

void function CreateTookDamageRui(){
	RuiParams_Struct TookDamageRuiParams
	TookDamageRuiParams.pos = <0.02, 0.06, 0>
	// TookDamageRuiParams.text = ""
	WorldRuiCreate("tookDamage", TookDamageRuiParams )
	// 时间校准 快0-0.1秒
	// while (true){
	// 	wait 0.1
	// 	if ( formatDayStrftime(GetUnixTimeParts()) != strftime ){
	// 		RuiSetString( timeRui, "msgText", formatDayStrftime(GetUnixTimeParts()))
	// 		break 
	// 	}
	// }
	// while (true){
	// 	wait 1
	// 	RuiSetString( timeRui, "msgText", formatDayStrftime(GetUnixTimeParts()))
	// }
}




void function NoPlayerAutoQuit(){
	wait 60
	local oriStatus = isAutoPrintRestrictedMod
	if ( GetPlayerArray().len() == 1 ) {
		GetLocalClientPlayer().ClientCommand(say + XDbot + "自动退出游戏")
		for (int i = 0; i<10; i++) {
			wait 1
			if ( oriStatus != isAutoPrintRestrictedMod ){
				PrintXDlog("自动退出已取消")
				return
			}
		}
		GetLocalClientPlayer().ClientCommand("disconnect")
	}
}


void function SaveMessages() {
	if ( messageTableList.len() == 0 ) return;
	string msgText = ""
	foreach(message in messageTableList ){
		msgText += message["time"] + " " + message["fromPlayerName"] + ": " + message["message"] + "\n"
	}
	fileName = "chat_history/" + formatStrftime(GetUnixTimeParts()) + ".txt"
	NSSaveFile(fileName, msgText)
}

void function SavePlayersUID(){
	if ( !isUIDJsonLoad ) return;
	print("[XDSave] SavePlayersUID");
	NSSaveJSONFile(UIDJsonPath, playersUID);
}


void function LoadPlayersUID(){
	NSLoadJSONFile(UIDJsonPath, OnLoadPlayersUIDJSONSuccess, OnLoadPlayersUIDJSONFailure)
}

void function OnLoadPlayersUIDJSONSuccess(table jsonData){
	isUIDJsonLoad = true
	playersUID = jsonData
	if ( isTimeAllowed("collectAllPlayerUIDInit", MAX_TIME) ){
		collectAllPlayerUID()
	}
}

void function OnLoadPlayersUIDJSONFailure(){
	NSChatWrite(1, "\n[38;2;125;125;254m[XDlog] UID JSON 加载失败, 继续加载")
	thread Thread_OnLoadPlayersUIDJSONRetry()
}

void function Thread_OnLoadPlayersUIDJSONRetry(){
	if ( NSDoesFileExist(UIDJsonPath) ){
		wait 1
		LoadPlayersUID()
		return
	} else {
		if ( NSDoesFileExist(UIDJsonPath) ){
			return
		}
		SavePlayersUID()
		wait 1
		LoadPlayersUID()
	}
}





// playerUID = {
// 	1234567: {
// 		"playername": [ 
// 			[ date, [time(), time()] ],
// 			[ date, [time(), time()] ]
// 			[ date, [time(), time()] ]
// 		],
// 		"playername": [ 
// 			[ date, [time(), time()] ],
// 			[ date, [time(), time()] ]
// 			[ date, [time(), time()] ]
// 		]
			

// 	}
// }
void function collectAllPlayerUID(){
	local dateInfoNow = formatDateAndTime(GetUnixTimeParts())
	foreach(player in GetPlayerArray()){
		collectPlayerUID(player, dateInfoNow)
	}
	print("[XDlog] collectAllPlayerUID")
}

void function collectPlayerUID(entity player, dateInfoNow=false){
	if ( dateInfoNow == false ) {
		dateInfoNow = formatDateAndTime(GetUnixTimeParts())
	}
	string playerNameClan = player.GetPlayerNameWithClanTag()
	local uid = XDGetUID(player)
	if ( playersUID.rawin(uid) ){
		local playerNameInfo = playersUID[uid]
		if ( playerNameInfo.rawin(playerNameClan) ){
			local dateInfo = playerNameInfo[playerNameClan] // all date
			local lastSeenDateInfo = dateInfo[dateInfo.len()-1] // [ date, [time(), time()] ]
			if ( lastSeenDateInfo[0] == dateInfoNow[0] ) { 
				lastSeenDateInfo[1].append(dateInfoNow[1])
				return
			}
			dateInfo.append( UIDAppendNewDate(dateInfoNow) )
			return
		}
		playerNameInfo[playerNameClan] <- [ UIDAppendNewDate(dateInfoNow) ]
		return
	}
	playersUID[uid] <- {
		[playerNameClan] = [ UIDAppendNewDate(dateInfoNow) ]
	}
}


function UIDAppendNewDate(dateInfoNow) {
	return [ dateInfoNow[0], [dateInfoNow[1]] ]
}


void function OnGameStateWinnerDeterminedXD() {
	print("[XDlog] Game Over")
	SavePlayersUID()
	SaveMessages()
}



// void function Thread_GameEndCallbackStart(){
// 	while(true){
// 		float gameTimeRemain = GetGameTime()
// 		if ( gameTimeRemain > 1 ){
// 			break
// 		}
// 		wait 1
// 	}
// 	float gameTimeRemain = GetGameTime()
// 	print("[XDlog] Thread_GameEndCallbackStart " + gameTimeRemain)
// 	wait gameTimeRemain
// 	GameEnd_Callback()
// } 