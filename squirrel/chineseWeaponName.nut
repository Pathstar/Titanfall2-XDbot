untyped
globalize_all_functions

// global table setTable = {}


//  chinese weapon name
global table weaponChineseToClassNameTable = {}
global table weaponClassToChineseNameTable = {}
global table weaponClassToProfessionalChineseNameTable = {}
global const string weaponChineseToClassNameTable_InitSignal = "WPN_CN_TO_CLASS"
global const string weaponClassToChineseNameTable_InitSignal = "WPN_CLASS_TO_CN"
global const string weaponClassToProfessionalChineseNameTable_InitSignal = "WPN_CLASS_TO_PCN"


// tool

function GetChineseNameOrShortPrintNameByClass(weaponClassName){
	local weaponName = GetChineseNameByClass(weaponClassName)
	if ( weaponName == null ){
		weaponName = GetWeaponInfoFileKeyField_Global( weaponClassName, "shortprintname" )
	}
	return weaponName
}


function GetChineseNameByClass(weaponClassName, fail=null){
	if ( isProfessionalChineseWeaponName ){
		if ( weaponClassToProfessionalChineseNameTable.rawin( weaponClassName ) ){
			return weaponClassToProfessionalChineseNameTable[weaponClassName]
		} else {
			return fail
		}
	} else {
		if ( weaponClassToChineseNameTable.rawin( weaponClassName ) ){
			return weaponClassToChineseNameTable[weaponClassName]
		} else {
			return fail
		}
	}
	// unreachable
	return fail
}

table function FindWeaponClassNameByChinese(blurChineseName){
	blurChineseName = cleanDotAndDash(blurChineseName)
	foreach ( ChineseWeaponName, weaponClassName in weaponChineseToClassNameTable ) {
		if ( ChineseWeaponName.tolower().find(cleanDotAndDash(blurChineseName).tolower()) != null ){
			return { ["chineseWeaponName"]=ChineseWeaponName, ["weaponClassName"]=weaponClassName }
		}
	}
	return {}
}


// return is set success
bool function Cmd_Set_isProfessionalChineseWeaponName(value){
	bool v = strToBool(value)
	if ( isProfessionalChineseWeaponName == v ) return false
	isProfessionalChineseWeaponName = v
	if ( v ){
		weaponClassToProfessionalChineseNameTable_LazyInit()
	} else {
		weaponClassToChineseNameTable_LazyInit()
	}
	return true
}

// ---------------- LAZY_INIT ----------------

// void function weaponDictLazyInit() {
// 	weaponChineseToClassNameTable_LazyInit()
// 	weaponClassToChineseNameTable_LazyInit()
// }

void function weaponClassToChineseNameTable_LazyInit(){
	if ( isProfessionalChineseWeaponName ){
		weaponClassToProfessionalChineseNameTable_LazyInit()
	} else {
		weaponClassToSimpleChineseNameTable_LazyInit()
	}
}


void function weaponChineseToClassNameTable_LazyInit(){
	if (hasLazyInit(weaponChineseToClassNameTable_InitSignal)) return
	lazyInitTable[weaponChineseToClassNameTable_InitSignal] <- true
	weaponChineseToClassNameTable_Init()
	print("[Lazy Init] weaponChineseToClassNameTable_Init")
}

void function weaponClassToSimpleChineseNameTable_LazyInit(){
	if (hasLazyInit(weaponClassToChineseNameTable_InitSignal)) return
	lazyInitTable[weaponClassToChineseNameTable_InitSignal] <- true
	weaponClassToChineseNameTable_Init()
	print("[Lazy Init] weaponClassToChineseNameTable_Init")
}

void function weaponClassToProfessionalChineseNameTable_LazyInit(){
	if (hasLazyInit(weaponClassToProfessionalChineseNameTable_InitSignal)) return
	lazyInitTable[weaponClassToProfessionalChineseNameTable_InitSignal] <- true
	weaponClassToProfessionalChineseNameTable_Init()
	print("[Lazy Init] weaponClassToProfessionalChineseNameTable_Init")
}


void function weaponChineseToClassNameTable_Init(){
	weaponChineseToClassNameTable = {
		["R201"] = "mp_weapon_rspn101",
		["R101"] = "mp_weapon_rspn101_og",
		["汗洛"] = "mp_weapon_hemlok",
		["赫姆洛克"] = "mp_weapon_hemlok",
		["平行步枪"] = "mp_weapon_vinson",
		["VK47"] = "mp_weapon_vinson",
		["G2A5"] = "mp_weapon_g2",
		["CAR"] = "mp_weapon_car",
		["转换者冲锋枪"] = "mp_weapon_alternator_smg",
		["电能冲锋枪"] = "mp_weapon_hemlok_smg",
		["R97"] = "mp_weapon_r97",
		["喷火枪"] = "mp_weapon_lmg",
		["LSTAR"] = "mp_weapon_lstar",
		["专注冲锋枪"] = "mp_weapon_esaw",
		["克莱伯"] = "mp_weapon_sniper",
		["克莱博"] = "mp_weapon_sniper",
		["克雷贝尔"] = "mp_weapon_sniper",
		["科莱博"] = "mp_weapon_sniper",
		["双重狙击枪"] = "mp_weapon_doubletake",
		["长弓DMR"] = "mp_weapon_dmr",
		["EVA8"] = "mp_weapon_shotgun",
		["敖犬霰弹枪"] = "mp_weapon_mastiff",
		["獒犬霰弹枪"] = "mp_weapon_mastiff",
		["响尾蛇飞弹"] = "mp_weapon_smr",
		["能源炮"] = "mp_weapon_epg",
		["垒球榴弹枪"] = "mp_weapon_softball",
		["冷战榴弹枪"] = "mp_weapon_pulse_lmg",
		["P2016"] = "mp_weapon_semipistol",
		["RE45"] = "mp_weapon_autopistol",
		["B3小帮手"] = "mp_weapon_wingman",
		["小帮手精英"] = "mp_weapon_wingman_n",
		["莫桑比克"] = "mp_weapon_shotgun_pistol",
		["莫三比克"] = "mp_weapon_shotgun_pistol",
		["智慧手枪"] = "mp_weapon_smart_pistol",
		["电能步枪"] = "mp_weapon_defender",
		["滋嘣"] = "mp_weapon_defender",
		["磁能榴弹发射器"] = "mp_weapon_mgl",
		["雷电炮"] = "mp_weapon_arc_launcher",
		["射手飞弹"] = "mp_weapon_rocket_launcher",
		["破片手榴弹"] = "mp_weapon_frag_grenade",
		["破片手雷"] = "mp_weapon_frag_grenade",
		["捏雷"] = "mp_weapon_frag_grenade",
		["电弧手榴弹"] = "mp_weapon_grenade_emp",
		["飞火星"] = "mp_weapon_thermite_grenade",
		["重力星"] = "mp_weapon_grenade_gravity",
		["电子烟雾手榴弹"] = "mp_weapon_grenade_electric_smoke",
		["炸药包"] = "mp_weapon_satchel",
		["隐身"] = "mp_ability_cloak",
		["脉冲刀"] = "mp_weapon_grenade_sonar",
		["钩爪"] = "mp_ability_grapple",
		["激素"] = "mp_ability_heal",
		["兴奋剂"] = "mp_ability_heal",
		["A盾"] = "mp_weapon_deployable_cover",
		["相位"] = "mp_ability_shifter",
		["幻影"] = "mp_ability_holopilot",
		["C盾卡"] = "mp_weapon_hard_cover",
		["炮塔卡"] = "mp_ability_turretweapon",
		["炸猪卡"] = "mp_weapon_frag_drone",
		["分身卡"] = "mp_ability_holopilot_nova"
	}
}

void function weaponClassToChineseNameTable_Init(){
	weaponClassToChineseNameTable = {
		["mp_weapon_rspn101"] = "R-201",
		["mp_weapon_rspn101_og"] = "R-101",
		["mp_weapon_hemlok"] = "汗洛",
		["mp_weapon_vinson"] = "平行步枪",
		["mp_weapon_g2"] = "G2",
		["mp_weapon_car"] = "CAR",
		["mp_weapon_alternator_smg"] = "转换者冲锋枪",
		["mp_weapon_hemlok_smg"] = "电能冲锋枪",
		["mp_weapon_r97"] = "R-97",
		["mp_weapon_lmg"] = "喷火枪",
		["mp_weapon_lstar"] = "L-STAR",
		["mp_weapon_esaw"] = "专注冲锋枪",
		["mp_weapon_sniper"] = "克莱博",
		["mp_weapon_doubletake"] = "双重狙击枪",
		["mp_weapon_dmr"] = "长弓DMR",
		["mp_weapon_shotgun"] = "EVA-8",
		["mp_weapon_mastiff"] = "敖犬霰弹枪",
		["mp_weapon_shotgun_doublebarrel_tfo"] = "双管霰弹枪",
		["mp_weapon_smr"] = "SMR",
		["mp_weapon_epg"] = "EPG",
		["mp_weapon_softball"] = "垒球榴弹枪",
		["mp_weapon_pulse_lmg"] = "冷战榴弹枪",
		["mp_weapon_semipistol"] = "P2016",
		["mp_weapon_autopistol"] = "RE-45",
		["mp_weapon_wingman"] = "B3小帮手",
		["mp_weapon_wingman_n"] = "小帮手精英",
		["mp_weapon_shotgun_pistol"] = "莫桑比克",
		["mp_weapon_smart_pistol"] = "智慧手枪",
		["mp_weapon_defender"] = "电能步枪",
		["mp_weapon_mgl"] = "磁能榴弹枪",
		["mp_weapon_arc_launcher"] = "雷电炮",
		["mp_weapon_rocket_launcher"] = "射手飞弹",
		["mp_weapon_frag_grenade"] = "破片手榴弹",
		["mp_weapon_grenade_emp"] = "电弧手榴弹",
		["mp_weapon_thermite_grenade"] = "飞火星",
		["mp_weapon_grenade_gravity"] = "重力星",
		["mp_weapon_grenade_electric_smoke"] = "电子烟雾手榴弹",
		["mp_weapon_satchel"] = "炸药包",
		["mp_ability_cloak"] = "隐身",
		["mp_weapon_grenade_sonar"] = "脉冲刀",
		["mp_ability_grapple"] = "钩爪",
		["mp_ability_heal"] = "激素",
		["mp_weapon_deployable_cover"] = "A盾",
		["mp_ability_shifter"] = "相位",
		["mp_ability_holopilot"] = "幻影",
		["mp_weapon_hard_cover"] = "C盾卡",
		["mp_ability_turretweapon"] = "炮塔卡",
		["mp_weapon_frag_drone"] = "炸猪卡",
		["mp_ability_holopilot_nova"] = "分身卡"
	}
}

void function weaponClassToProfessionalChineseNameTable_Init(){
	weaponClassToProfessionalChineseNameTable = {
		["mp_weapon_rspn101"] = "R-201卡宾枪",
		["mp_weapon_rspn101_og"] = "R-101卡宾枪",
		["mp_weapon_hemlok"] = "M1A3汗洛BF-R",
		["mp_weapon_vinson"] = "V-47平行步枪",
		["mp_weapon_g2"] = "G2A5步枪",
		["mp_weapon_car"] = "CAR冲锋枪",
		["mp_weapon_alternator_smg"] = "SP-14转换者冲锋枪",
		["mp_weapon_hemlok_smg"] = "M-18电能冲锋枪",
		["mp_weapon_r97"] = "R-97冲锋枪",
		["mp_weapon_lmg"] = "MK2喷火枪",
		["mp_weapon_lstar"] = "L-STAR轻机枪",
		["mp_weapon_esaw"] = "X-55专注冲锋枪",
		["mp_weapon_sniper"] = "克莱伯-AP .57狙击枪",
		["mp_weapon_doubletake"] = "D-2双重狙击枪",
		["mp_weapon_dmr"] = "D-101长弓DMR",
		["mp_weapon_shotgun"] = "EVA-8自动霰弹枪",
		["mp_weapon_mastiff"] = "M1901敖犬霰弹枪",
		["mp_weapon_shotgun_doublebarrel_tfo"] = "双管霰弹枪",
		["mp_weapon_smr"] = "AT-SMR响尾蛇飞弹",
		["mp_weapon_epg"] = "EPG-1能源炮",
		["mp_weapon_softball"] = "R-6P垒球榴弹枪",
		["mp_weapon_pulse_lmg"] = "EM-4冷战榴弹枪",
		["mp_weapon_semipistol"] = "汉蒙P2016手枪",
		["mp_weapon_autopistol"] = "RE-45自动手枪",
		["mp_weapon_wingman"] = "B3小帮手",
		["mp_weapon_wingman_n"] = "小帮手精英",
		["mp_weapon_shotgun_pistol"] = "SA-3莫桑比克",
		["mp_weapon_smart_pistol"] = "智慧手枪MK6",
		["mp_weapon_defender"] = "电能步枪",
		["mp_weapon_mgl"] = "MGL磁能榴弹发射器",
		["mp_weapon_arc_launcher"] = "LG-97雷电炮",
		["mp_weapon_rocket_launcher"] = "射手飞弹",
		["mp_weapon_frag_grenade"] = "破片手榴弹",
		["mp_weapon_grenade_emp"] = "电弧手榴弹",
		["mp_weapon_thermite_grenade"] = "飞火星",
		["mp_weapon_grenade_gravity"] = "重力星",
		["mp_weapon_grenade_electric_smoke"] = "电子烟雾手榴弹",
		["mp_weapon_satchel"] = "炸药包",
		["mp_ability_cloak"] = "隐身",
		["mp_weapon_grenade_sonar"] = "脉冲刀",
		["mp_ability_grapple"] = "钩爪",
		["mp_ability_heal"] = "激素",
		["mp_weapon_deployable_cover"] = "A盾",
		["mp_ability_shifter"] = "相位",
		["mp_ability_holopilot"] = "幻影",
		["mp_weapon_hard_cover"] = "C盾卡",
		["mp_ability_turretweapon"] = "炮塔卡",
		["mp_weapon_frag_drone"] = "炸猪卡",
		["mp_ability_holopilot_nova"] = "分身卡"
	}
}



// Not Professional Chinese
// table weaponClassToChineseNameTable = {
//     ["mp_weapon_rspn101"] = "R-201",
//     ["mp_weapon_rspn101_og"] = "R-101",
//     ["mp_weapon_hemlok"] = "汗洛",
//     ["mp_weapon_vinson"] = "平行步枪",
//     ["mp_weapon_g2"] = "G2",
//     ["mp_weapon_car"] = "CAR",
//     ["mp_weapon_alternator_smg"] = "转换者冲锋枪",
//     ["mp_weapon_hemlok_smg"] = "电能冲锋枪",
//     ["mp_weapon_r97"] = "R-97",
//     ["mp_weapon_lmg"] = "喷火枪",
//     ["mp_weapon_lstar"] = "L-STAR",
//     ["mp_weapon_esaw"] = "专注冲锋枪",
//     ["mp_weapon_sniper"] = "克莱博",
//     ["mp_weapon_doubletake"] = "双重狙击枪",
//     ["mp_weapon_dmr"] = "长弓DMR",
//     ["mp_weapon_shotgun"] = "EVA-8",
//     ["mp_weapon_mastiff"] = "敖犬霰弹枪",
//     ["mp_weapon_shotgun_doublebarrel_tfo"] = "双管霰弹枪",
//     ["mp_weapon_smr"] = "SMR",
//     ["mp_weapon_epg"] = "EPG",
//     ["mp_weapon_softball"] = "垒球榴弹枪",
//     ["mp_weapon_pulse_lmg"] = "冷战榴弹枪",
//     ["mp_weapon_semipistol"] = "P2016",
//     ["mp_weapon_autopistol"] = "RE-45",
//     ["mp_weapon_wingman"] = "B3小帮手",
//     ["mp_weapon_wingman_n"] = "小帮手精英",
//     ["mp_weapon_shotgun_pistol"] = "莫桑比克",
//     ["mp_weapon_smart_pistol"] = "智慧手枪",
//     ["mp_weapon_defender"] = "电能步枪",
//     ["mp_weapon_mgl"] = "磁能榴弹枪",
//     ["mp_weapon_arc_launcher"] = "雷电炮",
//     ["mp_weapon_rocket_launcher"] = "射手飞弹",
//     ["mp_weapon_frag_grenade"] = "破片手榴弹",
//     ["mp_weapon_grenade_emp"] = "电弧手榴弹",
//     ["mp_weapon_thermite_grenade"] = "飞火星",
//     ["mp_weapon_grenade_gravity"] = "重力星",
//     ["mp_weapon_grenade_electric_smoke"] = "电子烟雾手榴弹",
//     ["mp_weapon_satchel"] = "炸药包",
//     ["mp_ability_cloak"] = "隐身",
//     ["mp_weapon_grenade_sonar"] = "脉冲刀",
//     ["mp_ability_grapple"] = "钩爪",
//     ["mp_ability_heal"] = "激素",
//     ["mp_weapon_deployable_cover"] = "A盾",
//     ["mp_ability_shifter"] = "相位",
//     ["mp_ability_holopilot"] = "幻影",
// 	["mp_weapon_hard_cover"] = "C盾卡",
// 	["mp_ability_turretweapon"] = "炮塔卡",
// 	["mp_weapon_frag_drone"] = "炸猪卡",
// 	["mp_ability_holopilot_nova"] = "分身卡"
// }

// all
// table<string, string> weaponChineseToClassTable = {
//     ["R-201"] = "mp_weapon_rspn101",
//     ["R-101"] = "mp_weapon_rspn101_og",
//     ["汗洛"] = "mp_weapon_hemlok",
// 	["赫姆洛克"] = "mp_weapon_hemlok",
// 	["平行步枪"] = "mp_weapon_vinson",
//     ["VK47"] = "mp_weapon_vinson",
//     ["G2"] = "mp_weapon_g2",
//     ["CAR"] = "mp_weapon_car",
//     ["转换者冲锋枪"] = "mp_weapon_alternator_smg",
//     ["电能冲锋枪"] = "mp_weapon_hemlok_smg",
//     ["R-97"] = "mp_weapon_r97",
//     ["喷火枪"] = "mp_weapon_lmg",
//     ["L-STAR"] = "mp_weapon_lstar",
//     ["专注冲锋枪"] = "mp_weapon_esaw",
//     ["克莱博"] = "mp_weapon_sniper",
//     ["双重狙击枪"] = "mp_weapon_doubletake",
//     ["长弓DMR"] = "mp_weapon_dmr",
//     ["EVA-8"] = "mp_weapon_shotgun",
//     ["獒犬散弹枪"] = "mp_weapon_mastiff",
//     ["响尾蛇飞弹"] = "mp_weapon_smr",
//     ["能源炮"] = "mp_weapon_epg",
//     ["垒球榴弹枪"] = "mp_weapon_softball",
//     ["冷战榴弹枪"] = "mp_weapon_pulse_lmg",
//     ["P2016"] = "mp_weapon_semipistol",
//     ["RE-45"] = "mp_weapon_autopistol",
//     ["B3小帮手"] = "mp_weapon_wingman",
//     ["小帮手精英"] = "mp_weapon_wingman_n",
//     ["莫桑比克"] = "mp_weapon_shotgun_pistol",
// 	["莫三比克"] = "mp_weapon_shotgun_pistol",
//     ["智慧手枪"] = "mp_weapon_smart_pistol",
//     ["电能步枪"] = "mp_weapon_defender",
//     ["磁能榴弹发射器"] = "mp_weapon_mgl",
//     ["雷电炮"] = "mp_weapon_arc_launcher",
//     ["射手飞弹"] = "mp_weapon_rocket_launcher",
//     ["破片手榴弹"] = "mp_weapon_frag_grenade",
//     ["电弧手榴弹"] = "mp_weapon_grenade_emp",
//     ["飞火星"] = "mp_weapon_thermite_grenade",
//     ["重力星"] = "mp_weapon_grenade_gravity",
//     ["电子烟雾手榴弹"] = "mp_weapon_grenade_electric_smoke",
//     ["炸药包"] = "mp_weapon_satchel",
//     ["隐身"] = "mp_ability_cloak",
//     ["脉冲刀"] = "mp_weapon_grenade_sonar",
//     ["钩爪"] = "mp_ability_grapple",
//     ["兴奋剂"] = "mp_ability_heal",
// 	["激素"] = "mp_ability_heal",
//     ["A盾"] = "mp_weapon_deployable_cover",
//     ["相位"] = "mp_ability_shifter",
//     ["幻影"] = "mp_ability_holopilot",
// }
// titan:
// ["Ability Electric Smoke"] = "mp_titanability_smoke",
// ["Global Electric Smoke"] = "mp_titanability_electric_smoke",
// ["核能弹射"] = "mp_titanability_nuke_eject",
// ["四段火箭"] = "mp_titanweapon_rocketeer_rocketstream",
// ["分裂枪"] = "mp_titanweapon_particle_accelerator",
// ["镭射炮"] = "mp_titanweapon_laser_lite",
// ["拌线"] = "mp_titanability_laser_trip",
// ["涡流防护罩"] = "mp_titanweapon_vortex_shield_ion",
// ["镭射核心"] = "mp_titancore_laser_cannon",
// ["T-203铝热剂发射器"] = "mp_titanweapon_meteor",
// ["火墙"] = "mp_titanweapon_flame_wall",
// ["燃烧陷阱"] = "mp_titanability_slow_trap",
// ["热能护罩"] = "mp_titanweapon_heat_shield",
// ["火焰核心"] = "mp_titancore_flame_wave",
// ["电浆磁轨炮"] = "mp_titanweapon_sniper",
// ["集束飞弹"] = "mp_titanweapon_dumbfire_rockets",
// ["悬浮"] = "mp_titanability_hover",
// ["绊索陷阱"] = "mp_titanability_tether_trap",
// ["飞行核心"] = "mp_titancore_flight_core",
// ["天女散花"] = "mp_titanweapon_leadwall",
// ["电弧波"] = "mp_titanweapon_arc_wave",
// ["相位冲刺"] = "mp_titanability_phase_dash",
// ["剑封锁"] = "mp_titanability_basic_block",
// ["剑核心"] = "mp_titancore_shift_core",
// ["40MM追踪机炮"] = "mp_titanweapon_sticky_40mm",
// ["追踪火箭"] = "mp_titanweapon_tracker_rockets",
// ["声呐锁定"] = "mp_titanability_sonar_pulse",
// ["粒子屏障"] = "mp_titanability_particle_wall",
// ["火箭核心"] = "mp_titancore_salvo_core",
// ["猎杀者机炮"] = "mp_titanweapon_predator_cannon",
// ["强大火力"] = "mp_titanability_power_shot",
// ["近/远程模式切换"] = "mp_titanability_ammo_swap",
// ["枪盾"] = "mp_titanability_gun_shield",
// ["智慧核心"] = "mp_titancore_siege_mode",
// ["XO-16"] = "mp_titanweapon_xo16_vanguard",
// ["火箭弹群"] = "mp_titanweapon_salvo_rockets",
// ["多目标飞弹"] = "mp_titanweapon_shoulder_rockets",
// ["武装"] = "mp_titanability_rearm",
// ["能量吸收"] = "mp_titanweapon_stun_laser",
// ["升级核心"] = "mp_titancore_upgrade",
// ["轨道打击"] = "mp_titanweapon_orbital_stike"
