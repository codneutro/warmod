--[[---------------------------------------------------------------------------
	Warmod Project
	Dev(s): x[N]ir, Hajt
	File: modules/constants.lua
	Description: Constants declaration
--]]---------------------------------------------------------------------------

-- USGNs database export
warmod.USGNS_FILE           = "sys/lua/warmod/data/usgns.dat" 

-- Maximum number of errors during the mix preparation
warmod.MAX_ERRORS           = 3 

-- Forbidden characters in menu buttons 
warmod.FORBIDDEN_CHARACTERS = {"%|", "%(", "%)"} 

-- Current map name
warmod.CURRENT_MAP          = map("name") 

-- The current warmod version
warmod.VERSION				= "warmod-b1.0" 

-- Mix state
warmod.STATES = { 
	NONE               = 0,
	PRE_MAP_VETO       = 1,
	MAP_VETO           = 2,
	WINNER_VETO        = 3,
	LOOSER_VETO        = 4,
	PRE_CAPTAINS_KNIFE = 5,
	CAPTAINS_KNIFE     = 6,
	PRE_TEAM_SELECTION = 7,
	TEAM_A_SELECTION   = 8,
	TEAM_B_SELECTION   = 9,
	PRE_MAP_SELECTION  = 10,
	MAP_SELECTION      = 11,
	PRE_KNIFE_ROUND    = 12,
	KNIFE_ROUND        = 13,
	PRE_FIRST_HALF     = 14,
	FIRST_HALF         = 15,
	PRE_SECOND_HALF    = 16,
	SECOND_HALF        = 17,
}

-- Current map mode
warmod.MAP_MODE = {
	CURRENT = 0,
	VOTE    = 1,
	VETO    = 2,
}

-- Server settings
warmod.SETTINGS = {
	["STARTUP"] = {
		["mp_antispeeder"]     = 0,
		["mp_autoteambalance"] = 0,
		["mp_grenaderebuy"]    = 0,
		["mp_idlekick"]        = 0,
		["mp_infammo"]         = 0,
		["mp_kickpercent"]     = 0,
		["mp_mapvoteratio"]    = 0,
		["mp_maxclientsip"]    = 2,
		["mp_maxrconfails"]    = 5,
		["mp_pinglimit"]       = 0,
		["mp_postspawn"]       = 0,
		["mp_shotweakening"]   = 30,
		["mp_smokeblock"]      = 1,
		["mp_teamkillpenalty"] = 0,
		["mp_tkpunish"]        = 0,
		["mp_floodprot"]       = 1,
		["sv_friendlyfire"]    = 0,
		["sv_specmode"]        = 2,
		["sv_usgnonly"]        = 0,
		["sv_checkusgnlogin"]  = 0,
		["sv_maxplayers"]      = 12,
		["stats"]              = 0,
		["transfer_speed"]     = 250,
		["mp_unbuyable"]       = {
			"Tactical Shield", "Aug", "SG552", "SG550", "Scout", "AWP", "G3SG1"
		},
		["logaddress_add"]     = warmod.LOG_ADDRESS,
	},
	["KNIFE"] = {
		["mp_freezetime"] = 0,
		["mp_roundtime"]  = 5,
		["mp_startmoney"] = 0,
		["sv_fow"]        = 0,
		["sv_specmode"]   = 1,
	},
	["LIVE"] = {
		["mp_freezetime"] = 7,
		["mp_roundtime"]  = 2,
		["mp_startmoney"] = 800,
		["sv_fow"]        = 1,
		["sv_specmode"]   = 2,
	},
}