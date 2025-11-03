untyped
globalize_all_functions

global const int SAY_MAX_LEN = 255
global const int MAX_TIME = 65536

// ---------------- Tool ----------------
global table<var, bool> lazyInitTable = {}
global table<var, float> timeLimitTable = {}
global table toggleTable = {} 


// 麦克风等级 0: disable, 1: open 2: alwaysOpen
global int microMode = 2
int openMicroIndex = 0

global bool isBubbleExist = false
global array pinMessageBuffer = []

bool isBubbleNotProcess = true
int pinMessageCounter = 0


// ---------------- XD Py tool ----------------
void function MicroPlaySound(string path, float volume, string fromPlayerName=""){
    // if () todo
	switch(microMode){
		case 0:
			return
		case 1:
			PyProcess( "run_micro_sound", path, fromPlayerName, "say_team ", false, { ["volume"]=volume } )
			break
		case 2:
			PyProcess( "run_micro_sound", path, fromPlayerName, "say_team ", false, { ["volume"]=volume, ["microMode"]=microMode } )
			OpenMicro(5)
			break
	}
}

void function OpenMicro(float sec){
	openMicroIndex ++
	int localOpenMicroIndex = openMicroIndex
	if ( !isTalk ){
		isTalk = true
		GetLocalClientPlayer().ClientCommand("+pushtotalk")	
	}
	wait sec
	if ( localOpenMicroIndex == openMicroIndex ){
		isTalk = false
		GetLocalClientPlayer().ClientCommand("-pushtotalk")
	}
}

bool function isPinMessageHasBuffer(){
	return pinMessageBuffer.len() != 0
}

void function PinMessage(str) {
    pinMessageCounter++;
    pinMessageBuffer.append(str);
	StartPinMessageThread()
}

// 由于窗口无法不换行，所以这里添加不换行无法送显
void function PinMessage_Nowrap(str) {
	local pinMessageBufferLen = pinMessageBuffer.len()

	if ( pinMessageBufferLen == 0 ){
		PinMessage(str)
	} else {
    	pinMessageBuffer[pinMessageBufferLen] += str;
	}
}


void function StartPinMessageThread(){
    if (isBubbleExist && isBubbleNotProcess) {
        isBubbleNotProcess = false;
        thread PinMessage_DebounceAndFlush();
    }
}

void function PinMessage_DebounceAndFlush() { 
    int localCounter = pinMessageCounter;
    while (true) {
        wait 1;
        PinMessageSend(pinMessageBuffer);
        if (localCounter == pinMessageCounter) {
            isBubbleNotProcess = true;
            return;
        } else {
            localCounter = pinMessageCounter;
        }
        
    }
}


void function PinMessageSend(message_list){
    if( message_list.len() == 0 ) return;
    PyProcess("bubble_send", message_list, "", "", false);
    message_list.clear();
}

bool ornull function SetPinMessageStatus(cmd){
	if ( cmd.len() > 0 ){
		local s = cmd.slice(0,1)
		if (s == "t"){
			isBubbleExist = true
		} else if (s == "f") {
			isBubbleExist = false
		} else return null;
	}
    PyProcess("set_bubble_status", cmd, "", "", false)
	return isBubbleExist
}


// return is_visible
void function PinMessageToggle(){
	isBubbleExist = !isBubbleExist
    PyProcess("set_bubble_toggle", isBubbleExist, "", "", true)
}


// ---------------- XD tool ----------------

void function xdGameTimePrint(text){
	print("[" + (GetScoreEndTime() - Time()) + "] " + text)
}


void function xdObituary(text){
	if ( isAutoPrintRestrictedMod == 1 || isAutoPrintRestrictedMod == 3 ){
		GetLocalClientPlayer().ClientCommand(text)
	} else {
		xdGameTimePrint(text)
	}
}



// ---------------- tool ----------------


// 逻辑处理
void function CreateToggleState(key, trueFunc, falseFunc){
	toggleTable[key] <- [false, trueFunc, falseFunc]
}

// bool
bool function ToggleState(key){
	if ( toggleTable.rawin(key) ) {
		local toggleList = toggleTable[key]

		if ( toggleList[0] ){
			// turn to false, falseFunc
			if ( toggleList.len() == 3 ){
				toggleList[2]()
			}
			toggleList[0] = false
			return false
		} else {
			if ( toggleList.len() == 3 ){
				toggleList[1]()
			}
			toggleList[0] = true
			return true
		}
	}

	toggleTable[key] <- [true]
	return true
}

function GetToggleStateTrueFunc(key){
	if ( toggleTable.rawin(key) ) {
		local toggleList = toggleTable[key]
		if ( toggleList.len() == 3 ){
			return toggleList[2]
		}
	}
	
	PrintXDlog("Failed GetToggleStateTrueFunc: " + key)
	return noneFunc
}

function GetToggleStateFalseFunc(key){
	if ( toggleTable.rawin(key) ) {
		local toggleList = toggleTable[key]
		if ( toggleList.len() == 3 ){
			return toggleList[1]
		}
	}

	PrintXDlog("Failed GetToggleStateFalseFunc: " + key)
	return noneFunc
}

bool function GetToggleState(key){
	if ( toggleTable.rawin(key) ) {
		if ( toggleTable[key][0] ) return true;
		return false
	}

	return false
}

function noneFunc(){
	return
}



// limit was reachable
// if isTimeBlocked(playerName) return
bool function isTimeBlocked(str, limit = 1.0){
	if ( str in timeLimitTable ) {
        float passingTime = Time() - timeLimitTable[str]
		if ( passingTime > limit ) {
			timeLimitTable[str] = Time()
			return false
		} else {
            print("[XDlog] isTimeBlocked: " + str + " | Time: " + passingTime)
			return true
		}
	} else {
		timeLimitTable[str] <- Time()
		return false
	}
	// unreachable
	return false
}

bool function isTimeAllowed(str, limit = 1.0){
	if ( str in timeLimitTable ) {
        float passingTime = Time() - timeLimitTable[str]
		if ( passingTime > limit ) {
			timeLimitTable[str] = Time()
			return true
		} else {
            print("[XDlog] isTimeBlocked: " + str + " | Time: " + passingTime)
			return false
		}
	} else {
		timeLimitTable[str] <- Time()
		return true
	}
	// unreachable
	return true
}

// return ishasLazyInit
bool function LazyInit(initName){
	if ( initName in lazyInitTable ) return true;
	lazyInitTable[initName] <- true
	return false
}

bool function hasLazyInit(initName){
	if ( initName in lazyInitTable ) return true;
	return false
}


// 工具相关
float function GetGameTime(){
	return GetScoreEndTime() - Time()
}

function GetWeaponNameByClass(weaponClassName){
	return GetWeaponInfoFileKeyField_Global( weaponClassName, "shortprintname" )
}

// 游戏工具

void function jumpTimes(time, waitTime=0.01){
	for ( int i=0; i<time; i++ ){
		GetLocalClientPlayer().ClientCommand("+jump")
		wait waitTime
		GetLocalClientPlayer().ClientCommand("-jump")
		wait waitTime
	}
}


// 字符串处理

function cleanDotAndDash(str){
	local result = ""
	foreach (char in str) {
		char = format("%c", char)
		if (char != "." && char != "-") {
			result += char
		}
	}
	return result
}


// 类型处理

bool function strToBool(str) {
	if (type(str) == "bool") return bool(str)
	switch (str) {
		case "true":
		case "开":
			return true;
		case "false":
		case "关":
			return false;
	}
	return false;
}





// ---------------- table tool ----------------

float function getFloat(table<string, float> t, string key, float defaultValue){
	if ( key in t ){
		return t[key]
	}
	return defaultValue
}

function getVar(table t, key, defaultValue) {
	if ( key in t ){
		return t[key]
	}
	return defaultValue
}
