untyped
globalize_all_functions









// 没事尝试把color和pos改成 vector, 能不能放进table中

// <string, array<int>>

global struct RuiParams_Struct {
	var rui
	vector pos = <0, 0, 0>
	var text = ""
	float fontSize = 20
	float alpha = 1
	vector color = <0.5, 0.5, 1>
	float time = 8
	float frequency = 0.01
	float startTime
	int index = 0
}
global table<var, RuiParams_Struct> ruiTable = {} 



function WorldRuiCreate( ruiName, RuiParams_Struct params ) {
	if ( ruiName in ruiTable ){
		PrintXDlog(ruiName + " rui already exist")
		return
	}
	// float fontSize = getFloat(kwargs, "fontSize", 20.0)
	// float alpha = getFloat(kwargs, "alpha", 1.0)
	// float colorR = getFloat(kwargs, "colorR", 0.5)
	// float colorG = getFloat(kwargs, "colorG", 0.5)
	// float colorB = getFloat(kwargs, "colorB", 1.0)
	var rui = RuiCreate( $"ui/cockpit_console_text_top_left.rpak", aspectRatioFixTopo, RUI_DRAW_HUD, 1)
	params.rui = rui
	ruiTable[ruiName] <- params

	// RuiSetInt( rui, "maxLines", 1 );
	// RuiSetInt( rui, "lineNum", 0 );
	RuiSetFloat2( rui, "msgPos", params.pos)
	RuiSetString( rui, "msgText", params.text)
	RuiSetFloat3( rui, "msgColor", params.color)
	RuiSetFloat( rui, "msgFontSize", params.fontSize)
	RuiSetFloat( rui, "msgAlpha", params.alpha)
	RuiSetFloat( rui, "thicken", 0.0 )
	return rui
}

// -1：无限
// 目前无法更新打断

RuiParams_Struct function GetRuiParamByName(ruiName){
	if ( ruiName in ruiTable  ){
		return ruiTable[ruiName]
	}
	RuiParams_Struct getNull
	return getNull
}

bool function stopRui(ruiName) {
	if ( ruiName in ruiTable  ){
		ruiTable[ruiName].index ++
		return true
	}
	return false
}


// 持续时间 修改方法 
// posX posY posZ text colorR colorG colorB fontSize alpha
// time frequency
// PulseFunc: params
void function RuiPulse(void functionref(RuiParams_Struct) PulseFunc, RuiParams_Struct params){
	if ( params.rui == null ) return
	// WaitFrame() = 0.0001 but not necessary 
	local localRuiCount = params.index
	float waitTime = params.frequency
	float fadeTime = params.time
	if (fadeTime == -1){
		while ( true ) {
			if (localRuiCount != params.index){
				return
			}
			PulseFunc(params)
			wait waitTime
		}
	} else {
		float startTime = Time()
		params.startTime = startTime
		while ( Time()-startTime <= fadeTime ) {
			if (localRuiCount != params.index){
				return
			}
			PulseFunc(params)
			wait waitTime
		}
	}
}


void function ruiPulse_LinearFadeFunc ( RuiParams_Struct params ) {
	local rui = params.rui
	vector pos = params.pos
	local alpha = 0.99 - (Time()-params.startTime) * (1/params.time)
	RuiSetFloat( rui, "msgAlpha", alpha)
	RuiSetFloat2( rui, "msgPos", WorldToScreenPos( pos ) )
	float maxFontSize = 100
	RuiSetFloat( rui, "msgFontSize", clamp(DistanceFontSize( VectorDistance(GetLocalViewPlayer().GetOrigin(), pos), maxFontSize ), 30, maxFontSize) )	
}

// param must be var
// local func = function( params ) {}
// local func = function(): (params) {}

void function showWorldRui(RuiParams_Struct params){
	RuiPulse(ruiPulse_LinearFadeFunc, params)
}

float function VectorDistance(vector a, vector b) {
    return sqrt(pow(a.x - b.x, 2) + pow(a.y - b.y, 2) + pow(a.z - b.z, 2));
}

float function DistanceFontSize(float distance, float maxFontSize) {
    return maxFontSize - distance * 0.02
}


vector function VarToVector(v){
	return <v.x, v.y, v.z>
}




















// // global tool
// float function VectorDistance(vector a, vector b) {
//     return sqrt(pow(a.x - b.x, 2) + pow(a.y - b.y, 2) + pow(a.z - b.z, 2));
// }


// // Specialized tools 
// float function DistanceFontSize(float distance, float maxFontSize) {
//     return maxFontSize - distance * 0.02
// }

// void function DeathIndicator(entity player, string text ) {
// 	deathIndicatderCount ++
// 	int localRuiCount = deathIndicatderCount
// 	// float right = (GetScreenSize()[1] / 9.0) * 16.0
// 	// float down = GetScreenSize()[1]
// 	// float xOffset = (GetScreenSize()[0] - right) / 2


// 	// float msgPosX = 0.525 + modNumber/100.0
// 	// float msgPosY = 0.5 + height/100.0
	
// 	// print("[XDlog] " + player.GetOrigin() + <0,0,player.GetBoundingMaxs().z> )
	
// 	float startTime = Time()
// 	float FADE_TIME = 30
// 	lastDeathPlayerPos = player.GetOrigin() + <0, 0, 60>
// 	print("[XDpos] " + lastDeathPlayerPos )
// 	float maxFontSize = 100
// 	float minFontSize = 30
// 	deathDistance = VectorDistance(player.GetOrigin(), lastDeathPlayerPos)
// 	deathFontSize = DistanceFontSize( deathDistance, maxFontSize )
// 	isDeathIndicatderFade = false
// 	if ( deathIndicatderLastRui == null ){
// 		var rui = RuiCreate( $"ui/cockpit_console_text_top_left.rpak", aspectRatioFixTopo, RUI_DRAW_HUD, 1)
// 		deathIndicatderLastRui = rui

// 		// RuiSetInt( rui, "maxLines", 1 );
// 		// RuiSetInt( rui, "lineNum", 0 );

// 		RuiSetFloat2( rui, "msgPos", WorldToScreenPos( lastDeathPlayerPos ) )
// 		RuiSetString( rui, "msgText", text )
// 		RuiSetFloat3( rui, "msgColor", <0.5, 0.5, 1> )
// 		RuiSetFloat( rui, "msgFontSize", clamp(deathFontSize, minFontSize, maxFontSize) )
// 		RuiSetFloat( rui, "msgAlpha", 1.0 )
// 		// RuiSetFloat( rui, "thicken", 0.0 )


// 		while ( Time() - startTime <= FADE_TIME )
// 		{
// 			if (localRuiCount != deathIndicatderCount){
//                 return	
// 			}
// 			// vector posOffset = <0, 0.01, 0>
// 			// posOffset.y += Graph( Time() - startTime, 0, FADE_TIME, 0, -0.05 )
// 			if (rui){
// 				float alpha = 1 - (Time() - startTime) * (1/FADE_TIME)
// 				RuiSetFloat( rui, "msgAlpha", alpha )
// 				RuiSetFloat2( rui, "msgPos", WorldToScreenPos( lastDeathPlayerPos ) )
// 				// print(VectorFontSize( VectorDistance(player.GetOrigin(), playerPos), minFontSize, maxFontSize ))
// 				deathDistance = VectorDistance(GetLocalViewPlayer().GetOrigin(), lastDeathPlayerPos)
// 				deathFontSize = DistanceFontSize( deathDistance, maxFontSize )
// 				RuiSetFloat( rui, "msgFontSize", clamp(deathFontSize, minFontSize, maxFontSize) )
// 			}
// 			// RuiSetFloat2( rui, "msgPos", WorldToScreenPos(msgPos) + posOffset )
// 			WaitFrame()
// 		}
		
// 		if (localRuiCount == deathIndicatderCount){
//             RuiSetFloat( rui, "msgAlpha", 0 )
// 			isDeathIndicatderFade = true
// 		}
// 		// RuiDestroyIfAlive(rui)
// 	} else {
// 		ShowDeathIndicatderLastRui(text, localRuiCount, startTime, FADE_TIME, deathFontSize, minFontSize, maxFontSize)
// 	}

// }

// void function ShowDeathIndicatderLastRui(string text, int localRuiCount, float startTime, float FADE_TIME, float deathFontSize, float minFontSize, float maxFontSize){
// 	RuiSetFloat2( deathIndicatderLastRui, "msgPos", WorldToScreenPos( lastDeathPlayerPos ) )
// 	RuiSetString( deathIndicatderLastRui, "msgText", text )
// 	deathDistance = VectorDistance(GetLocalViewPlayer().GetOrigin(), lastDeathPlayerPos)
// 	deathFontSize = DistanceFontSize( deathDistance, maxFontSize )
// 	RuiSetFloat( deathIndicatderLastRui, "msgFontSize", clamp(deathFontSize, minFontSize, maxFontSize) )
// 	RuiSetFloat( deathIndicatderLastRui, "msgAlpha", 1.0 )
// 	isDeathIndicatderFade = false
// 	while ( Time() - startTime <= FADE_TIME )
// 	{
// 		if (localRuiCount != deathIndicatderCount){
// 			return	
// 		}
// 		if (deathIndicatderLastRui){
// 			float alpha = 1 - (Time() - startTime) * (1/FADE_TIME)
// 			RuiSetFloat( deathIndicatderLastRui, "msgAlpha", alpha )
// 			RuiSetFloat2( deathIndicatderLastRui, "msgPos", WorldToScreenPos( lastDeathPlayerPos ) )
// 			// print(VectorFontSize( VectorDistance(player.GetOrigin(), playerPos), minFontSize, maxFontSize ))
// 			deathDistance = VectorDistance(GetLocalViewPlayer().GetOrigin(), lastDeathPlayerPos)
// 			deathFontSize = DistanceFontSize( deathDistance, maxFontSize )
// 			RuiSetFloat( deathIndicatderLastRui, "msgFontSize", clamp(deathFontSize, minFontSize, maxFontSize) )		
// 		}
// 		WaitFrame()
// 	}
// 	if (localRuiCount == deathIndicatderCount){
// 		RuiSetFloat( deathIndicatderLastRui, "msgAlpha", 0 )
// 		isDeathIndicatderFade = true
// 	}
// 	// RuiDestroyIfAlive(deathIndicatderLastRui)
// }






