--[[---------------------------------------------------------------------------
	Warmod Project Created by x[N]ir (#4841)
	Latest version available here:
	https://raw.githubusercontent.com/codneutro/warmod/master/warmod.lua
--]]---------------------------------------------------------------------------

-- Libs
local time = os.time
local open = io.open
local enumdir = io.enumdir
local match = string.match
local gmatch = string.gmatch
local char = string.char
local sub = string.sub
local gsub = string.gsub
local lower = string.lower
local floor = math.floor
local ceil = math.ceil
local randomseed = math.randomseed
local random = math.random
local remove = table.remove
local sort = table.sort
local insert = table.insert

-- Constants
local ADMINS = {4841, 14545}
local WEBSITE = "www.cs2d.net"
local SETTINGS = {
	["STARTUP"] = {
		["mp_antispeeder"] = 0,
		["mp_autoteambalance"] = 0,
		["mp_grenaderebuy"] = 0,
		["mp_idlekick"] = 0,
		["mp_infammo"] = 0,
		["mp_kickpercent"] = 0,
		["mp_mapvoteratio"] = 0,
		["mp_maxclientsip"] = 2,
		["mp_maxrconfails"] = 5,
		["mp_pinglimit"] = 0,
		["mp_postspawn"] = 0,
		["mp_shotweakening"] = 30,
		["mp_smokeblock"] = 1,
		["mp_teamkillpenalty"] = 0,
		["mp_tkpunish"] = 0,
		["mp_unbuyable"] = {
			"Tactical Shield", "Aug", "SG552", "SG550", "Scout", "AWP", "G3SG1"
		},
		["mp_floodprot"] = 1,
		["sv_friendlyfire"] = 0,
		["sv_specmode"] = 2,
		["sv_usgnonly"] = 1,
		["sv_checkusgnlogin"] = 0,
		["sv_maxplayers"] = 12,
		["stats"] = 0,
		["transfer_speed"] = 250,
	},
	["KNIFE"] = {
		["mp_freezetime"] = 0,
		["mp_roundtime"] = 5,
		["mp_startmoney"] = 0,
		["sv_fow"] = 0,
	},
	["LIVE"] = {
		["mp_freezetime"] = 7,
		["mp_roundtime"] = 2,
		["mp_startmoney"] = 800,
		["sv_fow"] = 1,
	},
}
local COMMANDS = {}
local MENUS = {}
local MAPS = {}
local OS = sub(package.config, 1, 1) == "\\" and "Windows" or "Linux"
local DATA_FOLDER = "sys/lua/warmod/data/"
local USERS_FILE = DATA_FOLDER .. "users.dat"
local USGNS_FILE = DATA_FOLDER .. "usgns.dat"
local TEMP_DATA = DATA_FOLDER .. "temp.dat"
local MIXES_FOLDER = DATA_FOLDER .. "mixes/"
local MAX_ERRORS = 3
local MENU_ARGS = {
	{static = 1, menu = "Main Menu", display = 1},
	{static = 1, menu = "Team Organization", display = 1},
	{static = 1, menu = "Team Size", display = 1},
	{static = 1, menu = "Map", display = 1},
	{static = 1, menu = "Knife", display = 1},
	{static = 1, menu = "Spectators", display = 1},
	{static = 1, menu = "Maps", display = 1},
	{static = 1, menu = "Veto", display = 1},
	{static = 1, menu = "Side", display = 1},
}
local STATES = {
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
local MAP_MODE = {
	CURRENT = 0,
	VOTE    = 1,
	VETO    = 2,
}
local FORBIDDEN_CHARACTERS = {"%|", "%(", "%)"}
local CURRENT_MAP = map("name")

-- Variables
local connected = {}
local buff = {}
local buff_pos = 0
local ready = {}
local ready_access = true
local started = false
local teams_locked = false
local forced_switch = false
local player_menu = {}
local errors = 0
local team_size = 5
local total_players = team_size * 2
local knife_round_enabled = true
local map_mode = MAP_MODE.CURRENT
local state = STATES.NONE
local knife_winner = 0
local team_selector = 0
local team_organization = 1
local map_votes = {}
local veto_player_1 = 0
local veto_player_2 = 0
local veto_winner = 0
local veto_looser = 0
local swap_votes = {}
local stay_votes = {}
local team_a_captain = 0
local team_a_name = "Team A"
local team_a = {}
local team_a_t_score = 0
local team_a_ct_score = 0
local team_b_captain = 0
local team_b_name = "Team B"
local team_b = {}
local team_b_t_score = 0
local team_b_ct_score = 0
local mute = {}
local usgns = {}

--[[---------------------------------------------------------------------------
	UTILS
--]]---------------------------------------------------------------------------
local function log(tag, text)
	print("\169255255255[LOG]: \"" .. tag .. "\": " .. text)
end

local function error(tag, text)
	print("\169255000000[ERROR]: \"" .. tag .. "\": " .. text)
end

local function sv_msg(text)
	msg("\169000255000[WARMOD] " .. text)
end

--[[---------------------------------------------------------------------------
	TABLE
--]]---------------------------------------------------------------------------
local function table_contains(tab, value)
	for k, v in pairs(tab) do
		if v == value then
			return true
		end
	end
end

local function table_remove(tab, value)
	for k, v in pairs(tab) do
		if v == value then
			remove(tab, k)
			break
		end
	end
end

--[[---------------------------------------------------------------------------
	I/O
--]]---------------------------------------------------------------------------
local function file_load(path)
	local f = open(path)
	if not f then
		print("\169255000000[ERROR]: Can't load this file <" .. path .. ">")
		return false
	end

	local newbuff = {}

	for line in f:lines() do
		newbuff[#newbuff + 1] = line
	end

	buff = newbuff
	buff_pos = 0

	f:close()
	return true
end

local function file_read()
	buff_pos = buff_pos + 1
	return buff[buff_pos]
end

local function file_write(path, lines, mode)
	local f = open(path, mode)
	if not f then
		print("\169255000000[ERROR]: Can't write in this file <" .. path .. ">")
		return
	end

	local size = #lines

	for i = 1, size do
		f:write(lines[i] .. (i ~= size and "\n" or ""))
	end

	f:close()
end

--[[---------------------------------------------------------------------------
	COMMANDS
--]]---------------------------------------------------------------------------
local function is_admin(id)
	return table_contains(ADMINS, player(id, "usgn"))
end

local function apply_settings(key)
	local settings = SETTINGS[key]

	for cmd, value in pairs(settings) do
		if type(value) ~= "table" then
			parse(cmd .. ' ' .. value)
		else
			local args = ""

			for k, arg in pairs(value) do
				args = arg .. "," .. args
			end

			parse(cmd .. ' "' .. args .. '"')
		end
	end
end

function load_usgns()
	if file_load(USGNS_FILE) then
		local line = file_read()
		while line do
			local usgn, name = match(line, "([^,]+),([^,]+)")
			insert(usgns, tonumber(usgn), name)
			line = file_read()
		end
	end
end

--[[---------------------------------------------------------------------------
	TEXT
--]]---------------------------------------------------------------------------
local function hudtxt(id, text, x, y, color, align)
	parse('hudtxt ' .. id .. ' "\169' .. (color ~= nil and color or "255255255") .. text .. '" ' .. 
		x .. ' ' .. y .. ' ' .. (align ~= nil and align or 1))
end

local function cleartxt(...)
	for _, id in ipairs(arg) do
		parse('hudtxt ' .. id)
	end
end

local function clear_all_texts()
	for i = 0, 49 do
		parse('hudtxt ' .. i)
	end
end

local function allspec()
	local players = player(0, "table")

	for k, v in pairs(players) do
		parse("makespec " .. v)
	end
end

local function safe_restart()
	timer(5000, "parse", "sv_restart")
end

local function swap_teams()
	forced_switch = true
	
	local tt = player(0, "team1")
	local ct = player(0, "team2")
	
	for k, v in pairs(tt) do
		parse("makect " .. v)
	end
	
	for k, v in pairs(ct) do
		parse("maket " .. v)
	end
	
	forced_switch = false
end

--[[---------------------------------------------------------------------------
	MENU
--]]---------------------------------------------------------------------------
local function new_menu(title, buttons)
	return {
		title = title or "Menu",
		buttons = buttons or {},
		opened = false,
		page = 1,
		pages = 1,
	}
end

local function display_menu(id)
	local pmenu = player_menu[id]
	local buttons = pmenu.buttons

	pmenu.pages = ceil(#buttons / 7)

	if pmenu.pages < 1 then
		pmenu.opened = false
		return
	else
		pmenu.opened = true
	end

	if pmenu.page < 1 then pmenu.page = 1 end
	if pmenu.page > pmenu.pages then pmenu.page = pmenu.pages end

	local string = pmenu.title
	local start = pmenu.page * 7 - 6
	local stop = start + 6

	for i = start, stop do
		local button = buttons[i]

		if button then
			string = string .. "," .. button.label
		else
			string = string .. ","
		end
	end

	if pmenu.page > 1 then
		string = string .. ",Previous"
	else
		string = string .. ","
	end

	if pmenu.page < pmenu.pages then
		string = string .. ",Next"
	end

	menu(id, string)
end

local function register_menu(title, buttons)
	MENUS[title] = new_menu(title, buttons)
end

--[[---------------------------------------------------------------------------
	READY
--]]---------------------------------------------------------------------------
local function update_ready_list()
	if started then return end

	clear_all_texts()

	local k = 1

	hudtxt(0, "----- Ready -----", 550, 70)

	for k, v in pairs(ready) do
		hudtxt(k, player(v, "name"), 550, 70 + k * 15)
		k = k + 1
	end
end

local function check_ready_list()
	if #ready == total_players then
		started = true
		ready_access = false
		clear_all_texts()
		
		msg("\169255255255Starting Map Organization in \1692550000003 seconds !@C")
		if map_mode == MAP_MODE.VOTE then parse("sv_sound hajt/countdown.ogg") end
		timer(3000, "timer_map_organization")
	end 
end

local function set_player_ready(id)
	if not table_contains(ready, id) and #ready < total_players then
		ready[#ready + 1] = id
		update_ready_list()
		check_ready_list()
	end
end

local function set_player_notready(id)
	if table_contains(ready, id) then
		table_remove(ready, id)
		update_ready_list()
	end
end

local function get_random_ready_player()
	return ready[random(#ready)]
end

--[[---------------------------------------------------------------------------
	MENU EVENTS
--]]---------------------------------------------------------------------------
local function event_change_menu(id, args)
	local menu = args.static and MENUS[args.menu] or args.menu
	menu.page = 1
	menu.opened = false

	player_menu[id] = menu

	if args.display then
		display_menu(id)
	end
end

local function event_main_menu(id, args)
	if args == 1 then
		local buttons = MENUS["Team Organization"].buttons

		buttons[1].label = "Current Teams"
		buttons[2].label = "Random Captains"
		buttons[3].label = "Random Teams"

		if team_organization == 1 then
			buttons[1].label = "(" .. buttons[1].label .. ")"
		elseif team_organization == 2 then
			buttons[2].label = "(" .. buttons[2].label .. ")"
		else
			buttons[3].label = "(" .. buttons[3].label .. ")"
		end

		event_change_menu(id, MENU_ARGS[2])
	elseif args == 2 then
		local buttons = MENUS["Team Size"].buttons

		for i = 1, 5 do
			if team_size == i then
				buttons[i].label = "(" .. " " .. ")"
			else
				buttons[i].label = " "
			end
		end

		event_change_menu(id, MENU_ARGS[3])
	elseif args == 3 then
		local buttons = MENUS["Map"].buttons

		buttons[1].label = "Current"
		buttons[2].label = "Vote"
		buttons[3].label = "Veto"

		if map_mode == MAP_MODE.CURRENT then
			buttons[1].label = "(" .. buttons[1].label .. ")"
		elseif map_mode == MAP_MODE.VOTE then
			buttons[2].label = "(" .. buttons[2].label .. ")"
		else
			buttons[3].label = "(" .. buttons[3].label .. ")"
		end

		event_change_menu(id, MENU_ARGS[4])
	elseif args == 4 then
		local buttons = MENUS["Knife"].buttons

		buttons[1].label = "Enabled"
		buttons[2].label = "Disabled"

		if knife_round_enabled then
			buttons[1].label = "(" .. buttons[1].label .. ")"
		else
			buttons[2].label = "(" .. buttons[2].label .. ")"
		end

		event_change_menu(id, MENU_ARGS[5])
	end
end

local function open_main_menu(id)
	local buttons = MENUS["Main Menu"].buttons
	local organization, map

	if team_organization == 1 then organization = "Current Teams"
	elseif team_organization == 2 then organization = "Random Captains"
	elseif team_organization == 3 then organization = "Random Teams"
	end

	if map_mode == MAP_MODE.CURRENT then map = "Current"
	elseif map_mode == MAP_MODE.VETO then map = "Veto"
	elseif map_mode == MAP_MODE.VOTE then map = "Vote"
	end

	buttons[1].label = "Team Mode: " .. organization
	buttons[2].label = "Team Size: " .. team_size
	buttons[3].label = "Map: " .. map
	buttons[4].label = "Knife: " .. (knife_round_enabled and "Enabled" or "Disabled")

	event_change_menu(id, MENU_ARGS[1])
end

local function event_change_settings(id, args)
	if started or (not is_admin(id) and #player(0, "table") > 1) then 
		msg2(id, "\169255000000[ERROR]: You can't change settings now !")
		return
	end

	if args.setting == "size" then
		if (team_organization == 2 or team_organization == 3) and args.value == 1 then
			msg2(id, "\169255000000[ERROR]: You can't set 1 player per team " ..
				"for this team mode !")
			return
		end
		
		team_size = args.value
		total_players = team_size * 2
	elseif args.setting == "knife" then
		knife_round_enabled = args.value
	elseif args.setting == "map" then
		map_mode = args.value
	elseif args.setting == "organization" then
		if (args.value == 2 or args.value == 3) and team_size == 1 then 
			msg2(id, "\169255000000[ERROR]: You can't set this team mode " ..
				"for 2 players only !")
			return
		end
		
		team_organization = args.value
	end

	local players = player(0, "table")
	for k, v in pairs(players) do
		set_player_notready(v)
	end

	open_main_menu(id)
end

local function event_vote_map(id, map)
	local votes = map_votes[map]
	
	votes[#votes + 1] = id
	
	sv_msg(player(id, "name") .. " has voted for " .. map)
end

local function event_veto(id, map)
	if state == STATES.WINNER_VETO then
		if id ~= veto_winner then
			return
		end
	elseif state == STATES.LOOSER_VETO then
		if id ~= veto_looser then
			return
		end
	else
		return
	end
	
	freetimer("timer_check_veto")
	
	local buttons = MENUS["Veto"].buttons
	
	for i = 1, #buttons do
		if buttons[i].label == map then
			remove(buttons, i)
			break
		end
	end
	
	sv_msg(player(id, "name") .. " has vetoed " .. map)
	
	if #buttons == 1 then
		sv_msg(buttons[1].label .. " has won !")
		timer(3000, "parse", 'map "' .. buttons[1].label .. '"')
	else
		if id == veto_winner then
			event_change_menu(veto_looser, MENU_ARGS[8])
			state = STATES.LOOSER_VETO
		else
			event_change_menu(veto_winner, MENU_ARGS[8])
			state = STATES.WINNER_VETO
		end
		
		timer(5000, "timer_check_veto")
	end
end

local function load_maps()
	local prefixes = {"^de_", "^pcs_", "^up_", "^sf_", "^icc_"}
	local buttons = MENUS["Maps"].buttons
	local veto_buttons = MENUS["Veto"].buttons

	for file in enumdir("maps") do
		if match(file, "[^.]+$") == "map" then
			local text = match(file, "(.+)%..+")

			for k, prefix in pairs(prefixes) do
				if match(text, prefix) then
					MAPS[#MAPS + 1] = text
					map_votes[text] = {}
					veto_buttons[#veto_buttons + 1] = {label = text, 
						func = event_veto, args = text}

					if text ~= CURRENT_MAP then
						buttons[#buttons + 1] = {label = text, 
						func = event_vote_map, args = text}
					end
				end
			end
		end
	end
end

local function event_side_vote(id, swap)
	if swap then
		swap_votes[#swap_votes + 1] = id
	else
		stay_votes[#stay_votes + 1] = id
	end
end

--[[---------------------------------------------------------------------------
	MIX PREPARATION
--]]---------------------------------------------------------------------------
local function cancel_mix(reason)
	freetimer("timer_check_selection")
	freetimer("timer_team_organizations")
	freetimer("timer_check_veto")
	started = false
	teams_locked = false
	forced_switch = false
	ready_access = true
	ready = {}
	team_selector = 0
	knife_winner = 0
	veto_winner = 0
	veto_looser = 0
	veto_player_1 = 0
	veto_player_2 = 0
	errors = 0
	state = STATES.NONE
	MENUS["Spectators"].buttons = {}
	team_a_captain = 0
	team_a = {}
	team_b_captain = 0
	team_b = {}
	swap_votes = {}
	stay_votes = {}
	
	local veto_buttons = {}
	
	for k, _ in pairs(map_votes) do
		map_votes[k] = {}
		veto_buttons[#veto_buttons + 1] = {
			label = k, func = event_veto, args = k
		}
	end
	
	MENUS["Veto"].buttons = veto_buttons
	
	-- TODO: Add all variables
	update_ready_list()
	clear_all_texts()
	msg("\169255255255The mix has been canceled, reason: \169255000000" .. reason)
end

local function add_to_team_a(id)
	team_a[#team_a + 1] = id
	table_remove(ready, id)
end

local function add_to_team_b(id)
	team_b[#team_b + 1] = id
	table_remove(ready, id)
end

local function format_spectator_name(name)
	for i = 1, #FORBIDDEN_CHARACTERS do
		name = gsub(name, FORBIDDEN_CHARACTERS[i], "")
	end
	
	return name
end

local function event_choose_spectator(id, args)
	if not started or (state == STATES.TEAM_A_SELECTION and 
		team_selector ~= team_a_captain) or (state == STATES.TEAM_B_SELECTION and 
		team_selector ~= team_b_captain) then
		return
	end
	
	freetimer("timer_check_selection")
	forced_switch = true
	
	local buttons = MENUS["Spectators"].buttons
	buttons[args.index].label = "(" .. buttons[args.index].label .. ")"

	if state == STATES.TEAM_A_SELECTION then
		add_to_team_a(args.player)
		parse("maket " .. args.player)
	
		if #team_b < team_size then
			state = STATES.TEAM_B_SELECTION
			team_selector = team_b_captain
			event_change_menu(team_selector, MENU_ARGS[6])
			timer(5000, "timer_check_selection")
		else
			state = STATES.PRE_KNIFE_ROUND
		end
	elseif state == STATES.TEAM_B_SELECTION then
		add_to_team_b(args.player)
		parse("makect " .. args.player)
	
		if #team_a < team_size then
			state = STATES.TEAM_A_SELECTION
			team_selector = team_a_captain
			event_change_menu(team_selector, MENU_ARGS[6])
			timer(5000, "timer_check_selection")
		else
			state = STATES.PRE_KNIFE_ROUND
		end
	end
	
	forced_switch = false
end

local function init_spectators_menu()
	local button_index = 1
	local buttons = MENUS["Spectators"].buttons

	for k, v in pairs(ready) do
		buttons[button_index] = {
			label = format_spectator_name(player(v, "name")),
			func = event_choose_spectator,
			args = {player = v, index = button_index},
		}

		button_index = button_index + 1
	end
end

--[[---------------------------------------------------------------------------
	TIMERS
--]]---------------------------------------------------------------------------
function timer_map_organization()
	if #ready < total_players then
		errors = errors + 1
		
		if errors == MAX_ERRORS then
			cancel_mix("Not enough ready players during map organization !")
		else
			timer(5000, "timer_map_organization")
		end
	end
	
	if map_mode == MAP_MODE.CURRENT then
		timer_team_organization()
	elseif map_mode == MAP_MODE.VOTE then
		for k, id in pairs(ready) do 
			event_change_menu(id, MENU_ARGS[7])
		end
		
		timer(15000, "timer_map_vote_results")
	elseif map_mode == MAP_MODE.VETO then
		local r1 = get_random_ready_player()
		local r2 = get_random_ready_player()
		
		while r2 == r1 do
			r2 = get_random_ready_player()
		end
		
		local players = player(0, "table")
		
		for k, v in pairs(players) do
			if v == r1 then
				parse("maket " .. v)
			elseif v == r2 then
				parse("makect " .. v)
			else
				parse("makespec " .. v)
			end
		end
		
		veto_player_1 = r1
		veto_player_2 = r2
		
		if knife_round_enabled then
			state = STATES.PRE_MAP_VETO
		else
			if random(2) == 1 then
				veto_winner = veto_player_1
				veto_looser = veto_player_2
			else
				veto_winner = veto_player_2
				veto_looser = veto_player_1
			end
			
			sv_msg(player(veto_winner, "name") .. " will veto first !")
			event_change_menu(veto_winner, MENU_ARGS[8])
			state = STATES.WINNER_VETO
			timer(5000, "timer_check_veto")
		end
		
		teams_locked = true
	end
end

function timer_map_vote_results()
	local max, map
	
	for k, votes in pairs(map_votes) do
		if #votes > 0 and (not max or max > #votes) then
			map = k
			max = #votes
		end
	end
	
	if not map then
		cancel_mix("Nobody has voted for a map !")
	else
		sv_msg("Next map: " .. map)
		timer(3000, "parse", 'sv_map ' .. map)
	end
end

function timer_check_veto()
	local veto_maps = MENUS["Veto"].buttons
	local random_map = veto_maps[random(#veto_maps)].label

	if state == STATES.WINNER_VETO then
		event_veto(veto_winner, random_map)
	elseif state == STATES.LOOSER_VETO then
		event_veto(veto_looser, random_map)
	end
end

function timer_team_organization()
	if team_organization == 1 then
		local number_t  = #player(0, "team1")
		local number_ct = #player(0, "team2")

		if number_t ~= team_size or number_ct ~= team_size then
			cancel_mix("Is that difficult to gather " .. team_size .. " on both sides !?")
		else
			while #team_a < team_size or #team_b < team_size do
				local random_player = ready[random(#ready)]

				if #team_a < team_size then
					add_to_team_a(random_player)
				else
					add_to_team_b(random_player)
				end
			end

			local players = player(0, "table")

			for k, v in pairs(players) do
				if table_contains(team_a, v) then
					parse("maket " .. v)
				elseif table_contains(team_b, v) then
					parse("makect " .. v)
				else
					parse("makespec " .. v)
				end
			end

			team_a_captain = team_a[random(#team_a)]
			team_b_captain = team_b[random(#team_b)]

			msg("\169255255255" .. player(team_a_captain, "name") .. " has been chosen as Team A Captain !")
			msg("\169255255255" .. player(team_b_captain, "name") .. " has been chosen as Team B Captain !")
			
			if knife_round_enabled then
				state = STATES.PRE_KNIFE_ROUND
			else
				state = STATES.PRE_FIRST_HALF
			end
			
			teams_locked = true
		end
	elseif team_organization == 2 then
		--local a_captain = ready[random(#ready)]
		a_captain = 1
		local b_captain = ready[random(#ready)]

		while b_captain == a_captain do
			b_captain = ready[random(#ready)]
		end

		team_a_captain = a_captain
		team_b_captain = b_captain
		
		add_to_team_a(team_a_captain)
		add_to_team_b(team_b_captain)

		msg("\169255255255" .. player(team_a_captain, "name") .. " has been chosen as Team A Captain !")
		msg("\169255255255" .. player(team_b_captain, "name") .. " has been chosen as Team B Captain !")

		local players = player(0, "table")

		for k, v in pairs(players) do
			if v == team_a_captain then
				parse("maket " .. v)
			elseif v == team_b_captain then
				parse("makect " .. v)
			else
				parse("makespec " .. v)
			end
		end

		if knife_round_enabled then
			state = STATES.PRE_CAPTAINS_KNIFE
		else
			state = STATES.PRE_TEAM_SELECTION
		end
		
		teams_locked = true
	elseif team_organization == 3 then
		while #ready > 0 do
			if #team_a < team_size then
				add_to_team_a(get_random_ready_player())
			else
				add_to_team_b(get_random_ready_player())
			end
		end

		local a_captain = team_a[random(#team_a)]
		local b_captain = team_b[random(#team_b)]

		team_a_captain = a_captain
		team_b_captain = b_captain

		msg("\169255255255" .. player(team_a_captain, "name") .. " has been chosen as Team A Captain !")
		msg("\169255255255" .. player(team_b_captain, "name") .. " has been chosen as Team B Captain !")

		local players = player(0, "table")

		for k, v in pairs(players) do
			if table_contains(team_a, v) then
				parse("maket " .. v)
			elseif table_contains(team_b, v) then
				parse("makect " .. v)
			else
				parse("makespec " .. v)
			end
		end

		if knife_round_enabled then
			state = STATES.PRE_KNIFE_ROUND
		else
			state = STATES.PRE_FIRST_HALF
		end

		teams_locked = true
	end
end

function timer_check_selection()
	local buttons = MENUS["Spectators"].buttons
	local random_button = buttons[random(#buttons)]
		
	event_choose_spectator(team_selector, random_button.args)
end

function timer_check_side_results()
	local stay = #stay_votes
	local swap = #swap_votes
	
	if swap > stay then
		swap_teams()
	end
	
	state = STATES.PRE_FIRST_HALF
	safe_restart()
end

--[[---------------------------------------------------------------------------
	COMMANDS FUNCTIONS
--]]---------------------------------------------------------------------------
COMMANDS["!ready"] = {
	argv = 0,
	syntax = "",
	func = function(id, argv)
		if not ready_access then return "This feature is disabled during the match" end
		set_player_ready(id)
	end
}

COMMANDS["!notready"] = {
	argv = 0,
	syntax = "",
	func = function(id, argv)
		if not ready_access then return "This feature is disabled during the match" end
		set_player_notready(id)
	end
}

COMMANDS["!bc"] = {
	argv = 1,
	syntax = "<message>",
	func = function(id, argv)
		if not is_admin(id) then return "You do not have permission to use this command" end
		msg("\169255255255"..player(id,"name")..": "..argv[1])
	end
}

COMMANDS["!readyall"] = {
	argv = 0,
	syntax = "",
	func = function(id, argv)
		if not is_admin(id) then return "You do not have permission to use this command" end
		if started then return "This feature is disabled during the match" end
		local players = player(0, "table")
		for k, v in pairs(players) do
			set_player_ready(v)
		end
	end
}

COMMANDS["!cancel"] = {
	argv = 0,
	syntax = "",
	func = function(id, argv)
		if not is_admin(id) then return "You do not have permission to use this command" end
		if not started then return "This feature is currently disabled" end
		cancel_mix("Canceled by " .. player(id, "name"))
	end
}

COMMANDS["!whois"] = {
	argv = 1,
	syntax = "<id>",
	func = function(id, argv)
		local a1 = tonumber(argv[1])
		if not a1 then return "First argument must be a number" end
		if not player(a1, "exists") then return "Player does not exist" end
		if not player(a1, "usgn") then return player(a1, "name") .. " is not logged in" end

		local name = usgns[player(a1, "usgn")] or false
		if name == false then return "Unknown username" end

		msg2(id, "\169175255100[SERVER]:\169255255255 " .. player(a1, "name") ..
			" is logged in as " .. name .. " (ID " .. player(a1, "usgn") .. ")")
	end
}

function command_check(id, txt)
	local cmd = match(lower(txt), "^([!][%w]+)[%s]?")
	if not cmd then return 0 end

	if not COMMANDS[cmd] then
		msg2(id,"\169255150150[ERROR]:\169255255255 Undefined command")
		return 1
	end

	local aftercmd = match(txt, "[%s](.*)")
	command_process(id, cmd, aftercmd)
	return 1
end

function command_process(id, cmd, txt)
	local arg_count = COMMANDS[cmd].argv
	local argv = {}
	if arg_count > 0 then
		if not txt then
			msg2(id, "\169255150150[ERROR]:\169255255255 Invalid syntax")
			msg2(id, "\169255150150[ERROR]:\169255255255 Syntax: " .. cmd .. " " .. COMMANDS[cmd].syntax)
			return 1
		end

		local count = 0
		for word in gmatch(txt, "[^%s]+") do
			count = count + 1
			if count <= arg_count then
				insert(argv, word)
			else
				argv[#argv] = argv[#argv] .. " " .. word
			end
		end

		if count < arg_count then
			msg2(id, "\169255150150[ERROR]:\169255255255 Invalid syntax")
			msg2(id, "\169255150150[ERROR]:\169255255255 Syntax: " .. cmd .. " " .. COMMANDS[cmd].syntax)
			return 1
		end

	elseif arg_count <= 0 and txt ~= nil and txt ~= " " then
		argv = {txt}
	end

	local ret
	if #argv > 0 then
		ret = COMMANDS[cmd].func(id, argv)
	else
		ret = COMMANDS[cmd].func(id)
	end

	if ret ~= nil then
		if ret == false then
			msg2(id, "\169255150150[ERROR]:\169255255255 Something went wrong")
		else
			msg2(id, "\169255150150[ERROR]:\169255255255 " .. ret)
		end
		return 1
	end
end

--[[---------------------------------------------------------------------------
	HOOKS
--]]---------------------------------------------------------------------------
function warmod_join(id)
	update_ready_list()
	msg2(id, "\169255000000Connected to \169255255255" .. game("sv_name"))
	msg2(id, "\169255000000Warmod Settings \169000255000[F2]")
	msg2(id, "\169255000000Website: \169255255000" .. WEBSITE)
	connected[id] = true
	mute[id] = false
end

function warmod_leave(id)
	if started then
		if state == STATES.PRE_CAPTAINS_KNIFE or state == STATES.CAPTAINS_KNIFE then
			if team_a_captain == id or team_b_captain == id then
				cancel_mix("A captain left during knife")
			end
		elseif state == STATES.PRE_TEAM_SELECTION or state == STATES.TEAM_A_SELECTION or 
			state == STATES.TEAM_B_SELECTION then
			if team_a_captain == id or team_b_captain == id then
				cancel_mix("A captain left during team selection")
			end
		elseif state == STATES.PRE_MAP_VETO or state == STATES.MAP_VETO or 
			state == STATES.WINNER_VETO or state == STATES.LOOSER_VETO then
			if id == veto_winner or id == veto_looser then
				cancel_mix("A veto chooser left !")
			end
		end
	end

	set_player_notready(id)
	connected[id] = false
	--mute[id]=nil
end

function warmod_die(victim)
end

function warmod_name(id, oldname, newname)
end

function warmod_say(id,txt)
	local ret = command_check(id,txt)
	if ret == 1 then
		return 1
	elseif mute[id] == true then
		msg2(id,"\169255150150[ERROR]:\169255255255 You are muted")
		return 1
	end
end

function warmod_startround(mode)
	log("Startround", "Mode: " .. mode .. ", State: " .. state)

	if started then
		if state == STATES.PRE_MAP_VETO then
			sv_msg("Preparing Map Veto")
			apply_settings("KNIFE")
			state = STATES.MAP_VETO
			safe_restart()
		elseif state == STATES.MAP_VETO then
			if mode == 1 then
				veto_winner = veto_player_1
				veto_looser = veto_player_2
			elseif mode == 2 then
				veto_winner = veto_player_2
				veto_looser = veto_player_1
			elseif mode == 5 then
				sv_msg("Map Veto !")
			elseif mode == 22 then
				if random(2) == 1 then
					veto_winner = veto_player_1
					veto_looser = veto_player_2
				else
					veto_winner = veto_player_2
					veto_looser = veto_player_1
				end
			end
			
			if mode == 1 or mode == 2 or mode == 22 then
				sv_msg(player(veto_winner, "name") .. " will veto first !")
				event_change_menu(veto_winner, MENU_ARGS[8])
				state = STATES.WINNER_VETO
				timer(5000, "timer_check_veto")
			end
		elseif state == STATES.PRE_CAPTAINS_KNIFE then
			sv_msg("Preparing Captains Knife")
			apply_settings("KNIFE")
			state = STATES.CAPTAINS_KNIFE
			safe_restart()
		elseif state == STATES.CAPTAINS_KNIFE then		
			if mode == 1 then
				knife_winner = team_a_captain
				state = STATES.TEAM_A_SELECTION
			elseif mode == 2 then
				knife_winner = team_b_captain
				state = STATES.TEAM_B_SELECTION
			elseif mode == 22 then
				if random(2) == 1 then
					knife_winner = team_a_captain
					state = STATES.TEAM_A_SELECTION
				else
					knife_winner = team_b_captain
					state = STATES.TEAM_B_SELECTION
				end
			elseif mode == 5 then
				sv_msg("Captains Knife !")
			end
			
			if mode == 1 or mode == 2 or mode == 22 then
				sv_msg(player(knife_winner, "name") .. " has won the knife round !")
				team_selector = knife_winner
				
				if #ready < total_players - 2 then
					cancel_mix("Player(s) left during team selection")
				else
					init_spectators_menu()
					event_change_menu(team_selector, MENU_ARGS[6])
					timer(5000, "timer_check_selection")
				end
			end
		elseif state == STATES.PRE_TEAM_SELECTION then
			team_selector = team_b_captain
			state = STATES.TEAM_B_SELECTION
			init_spectators_menu()
			event_change_menu(team_selector, MENU_ARGS[6])
			timer(5000, "timer_check_selection")
		elseif state == STATES.PRE_KNIFE_ROUND then
			sv_msg("Preparing Knife Round")
			apply_settings("KNIFE")
			state = STATES.KNIFE_ROUND
			safe_restart()
		elseif state == STATES.KNIFE_ROUND then
			if mode == 5 then
				sv_msg("Knife Round !")
			elseif mode == 1 then
				knife_winner = 1
			elseif mode == 2 then
				knife_winner = 2
			elseif mode == 22 then
				if random(2) == 1 then
					knife_winner = 1
				else
					knife_winner = 2
				end
			end
			
			if mode == 1 or mode == 2 or mode == 22 then
				if knife_winner == 1 then
					local tt = player(0, "team1")
					
					for k, v in pairs(tt) do
						event_change_menu(v, MENU_ARGS[9])
					end
				else
					local ct = player(0, "team2")
					
					for k, v in pairs(ct) do
						event_change_menu(v, MENU_ARGS[9])
					end
				end
				
				timer(7000, "timer_check_side_results")
			end
		elseif state == STATES.PRE_FIRST_HALF then
			state = STATES.FIRST_HALF
			safe_restart()
		elseif state == STATES.FIRST_HALF then
			if mode == 5 then
				sv_msg("LIVE")
			end
		end
	end
end

function warmod_endround(mode)
	log("Endround", "Mode: " .. mode .. ", State: " .. state)
end

function warmod_hit(victim, source)
end

function warmod_team(id, team, skin)
	if teams_locked and not forced_switch then
		msg("\169255000000You can't join now !")
		return 1
	end
end

function warmod_menu(id, title, button)
	local menu = player_menu[id]

	if button == 0 then
		player_menu[id] = nil
	elseif button == 8 then
		menu.page = menu.page - 1
		display_menu(id)
	elseif button == 9 then
		menu.page = menu.page + 1
		display_menu(id)
	else
		local index = (menu.page - 1) * 7 + button
		local b = menu.buttons[index]
		local func = b.func

		func(id, b.args)
	end
end

function warmod_bombplant(id, x, y)
	if started then
		if state == STATES.CAPTAINS_KNIFE or 
			state == STATES.KNIFE_ROUND or 
			state == STATES.MAP_VETO then
			msg2(id, "\169255000000[ERROR]: You can't plant the bomb now !")
			return 1
		end
	end
end

function warmod_bombdefuse(id) end

function warmod_spawn(id)
	if started then
		if state == STATES.CAPTAINS_KNIFE or
			state == STATES.MAP_VETO or
			state == STATES.KNIFE_ROUND  then
			parse("setmoney " .. id .. " 0")
			return "x"
		end
	end
end

function warmod_serveraction(id, action)
	if action == 1 then
		open_main_menu(id)
	end
end

addhook("join",         "warmod_join")
addhook("leave",        "warmod_leave")
addhook("die",          "warmod_die")
addhook("name",         "warmod_name")
addhook("say",          "warmod_say")
addhook("sayteam",      "warmod_say")
addhook("startround",   "warmod_startround")
addhook("endround",     "warmod_endround")
addhook("hit",          "warmod_hit")
addhook("menu",         "warmod_menu")
addhook("team",         "warmod_team")
addhook("bombplant",    "warmod_bombplant")
addhook("bombdefuse",   "warmod_bombdefuse")
addhook("spawn",        "warmod_spawn")
addhook("serveraction", "warmod_serveraction")

register_menu("Main Menu", {
	{label = "Team Organization", func = event_main_menu, args = 1},
	{label = "Team Size", func = event_main_menu, args = 2},
	{label = "Map", func = event_main_menu, args = 3},
	{label = "Knife Round", func = event_main_menu, args = 4},
})

register_menu("Team Organization", {
	{label = "Current Teams", func = event_change_settings, args = {setting = "organization", value = 1}},
	{label = "Random Captains", func = event_change_settings, args = {setting = "organization", value = 2}},
	{label = "Random Teams", func = event_change_settings, args = {setting = "organization", value = 3}},
})

register_menu("Team Size", {
	{label = " ", func = event_change_settings, args = {setting = "size", value = 1}},
	{label = " ", func = event_change_settings, args = {setting = "size", value = 2}},
	{label = " ", func = event_change_settings, args = {setting = "size", value = 3}},
	{label = " ", func = event_change_settings, args = {setting = "size", value = 4}},
	{label = " ", func = event_change_settings, args = {setting = "size", value = 5}},
})

register_menu("Map", {
	{label = " ", func = event_change_settings, args = {setting = "map", value = MAP_MODE.CURRENT}},
	{label = " ", func = event_change_settings, args = {setting = "map", value = MAP_MODE.VOTE}},
	{label = " ", func = event_change_settings, args = {setting = "map", value = MAP_MODE.VETO}},
})

register_menu("Knife", {
	{label = "Enabled", func = event_change_settings, args = {setting = "knife", value = true}},
	{label = "Disabled", func = event_change_settings, args = {setting = "knife", value = false}},
})

register_menu("Side", {
	{label = "Stay", func = event_side_vote, args = false},
	{label = "Swap", func = event_side_vote, args = true},
})

register_menu("Spectators")
register_menu("Maps")
register_menu("Veto")

apply_settings("STARTUP")
load_maps()
load_usgns()
randomseed(time())

load_maps        = nil
load_usgns       = nil
register_menu    = nil
