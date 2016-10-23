--[[---------------------------------------------------------------------------
	Warmod Project Created by x[N]ir (#4841)
	Latest version available here:
	https://raw.githubusercontent.com/codneutro/warmod/master/warmod.lua
--]]---------------------------------------------------------------------------

-- Libs
local time = os.time
local isdir = io.isdir
local open = io.open
local popen = io.popen
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

-- Constants
local ADMINS = {4841, 0}
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
local ROOT = match(sub(debug.getinfo(1).source, 2), "(.+/)")
local DATA_FOLDER = ROOT .. "warmod_data/"
local USERS_FILE = DATA_FOLDER .. "users.dat"
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
}
local STATES = {
	NONE = 0,
	PRE_CAPTAINS_KNIFE = 1,
	CAPTAINS_KNIFE = 2,
	PRE_TEAM_SELECTION = 3,
	TEAM_A_SELECTION = 4,
	TEAM_B_SELECTION = 5,
	PRE_MAP_SELECTION = 6,
	MAP_SELECTION = 7,
	PRE_KNIFE_ROUND = 8,
	KNIFE_ROUND = 9,
}
local MAP_MODE = {
	CURRENT = 0,
	VOTE = 1,
	--VETO = 2,
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
local team_organization = 2
local map_votes = {}
local won_map = ""
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
local function file_exists(path)
	local f = open(path)
	if not f then
		return false
	end
	f:close()
	return true
end

local function file_load(path)
	local f = open(path)
	if not f then
		print("\169255000000[ERROR]: Can't load this file <" .. path .. ">")
		return
	end

	local newbuff = {}

	for line in f:lines() do
		newbuff[#newbuff + 1] = line
	end

	buff = newbuff
	buff_pos = 0

	f:close()
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

local function create_folder(folder_name)
	if OS == "Windows" then
		folder_name = gsub(folder_name, "/", "\\")
	end

	popen("mkdir " .. folder_name)
end

local function check_folders()
	local folders = {sub(DATA_FOLDER, 1, #DATA_FOLDER - 1), 
		sub(MIXES_FOLDER, 1, #MIXES_FOLDER - 1)}

	for k, folder in ipairs(folders) do
		if not isdir(folder) then
			create_folder(folder)
		end
	end

	create_folder = nil
end

--[[---------------------------------------------------------------------------
	COMMANDS
--]]---------------------------------------------------------------------------
local function is_command(text)
	local cmd = match(text, "^!(%a+)")
	if not cmd then return false end

	return COMMANDS[lower(cmd)]
end

local function is_admin(id)
	return table_contains(ADMINS, player(id, "usgn"))
end

local function execute_command(id, cmd, arg)
	if cmd.admin and not is_admin(id) then
		msg2(id, "\169255000000[ERROR]: Insufficients Permissions !")
		return
	end

	local func = cmd.func

	if func(id, arg) then
		msg2(id, "\169255000000[ERROR]: Something went wrong !")
		return
	end

	if cmd.admin then
		if cmd.silent then
			return
		end

		msg("\169255255255" .. player(id, "name") .. " used " .. cmd.syntax .. " " ..
			(cmd.syntax ~= arg and arg or ""))
	end
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

local function load_maps()
	local prefixes = {"^de_", "^pcs_", "^up_", "^sf_", "^icc_"}
	local buttons = MENUS["Maps"].buttons

	for file in io.enumdir("maps") do
		if match(file, "[^.]+$") == "map" then
			local text = match(file, "(.+)%..+")
			for k, prefix in pairs(prefixes) do
				if match(text, prefix) then
					MAPS[#MAPS + 1] = text
					map_votes[text] = {}

					if text ~= CURRENT_MAP then
						buttons[#buttons + 1] = {label = text, func = event_vote_map, args = text}
					end
				end
			end
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
		--buttons[3].label = "Veto"

		if map_mode == MAP_MODE.CURRENT then
			buttons[1].label = "(" .. buttons[1].label .. ")"
		elseif map_mode == MAP_MODE.VOTE then
			buttons[2].label = "(" .. buttons[2].label .. ")"
		else
			--buttons[3].label = "(" .. buttons[3].label .. ")"
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
	--elseif map_mode == MAP_MODE.VETO then map = "Veto"
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

	open_main_menu(id)
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
		
		msg("\169255255255Starting team organization in \1692550000005 seconds !@C")
		timer(5000, "timer_team_organization")		
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
	MIX PREPARATION
--]]---------------------------------------------------------------------------
local function cancel_mix(reason)
	freetimer("timer_check_selection")
	freetimer("timer_team_organizations")
	started = false
	teams_locked = false
	forced_switch = false
	ready_access = true
	ready = {}
	team_selector = 0
	knife_winner = 0
	errors = 0
	state = STATES.NONE
	MENUS["Spectators"].buttons = {}
	team_a_captain = 0
	team_a = {}
	team_b_captain = 0
	team_b = {}
	for k, _ in pairs(map_votes) do
		map_votes[k] = {}
	end
	won_map = ""
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
	if not started or state > STATES.TEAM_B_SELECTION then
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
			msg("FINISHED")
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
			msg("FINISHED")
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

local function save_mix_state()
	local lines = {}

	lines[#lines + 1] = won_map .. " " .. team_size .. " " .. knife_round_enabled
	lines[#lines + 1] = team_a_name
	lines[#lines + 1] = team_b_name

	local a_team = ""
	local b_team = ""

	for i = 1, team_size do
		if not player(team_a[i], "exists") then
			error("Saving Mix State", "Missing Team A players")
			return
		end

		if not player(team_b[i], "exists") then
			error("Saving Mix State", "Missing Team B players")
			return
		end

		a_team = player(team_a[i], "name") .. " " .. a_team
		b_team = player(team_b[i], "name") .. " " .. b_team
	end

	lines[#lines + 1] = a_team
	lines[#lines + 1] = b_team

	file_write(TEMP_DATA, lines, "w+")
end

local function load_mix_state()
	if not file_exists(TEMP_DATA) then
		return
	end

	file_load(TEMP_DATA)

	local line = file_read()
	
end

--[[---------------------------------------------------------------------------
	TIMERS
--]]---------------------------------------------------------------------------
function timer_team_organization()
	if #ready < total_players then
		errors = errors + 1
	
		-- This is the only preparation issue where I deal with leaving cases
		-- It's all to up to players to behave correctly...
		if errors == MAX_ERRORS then
			cancel_mix("Not enough ready players during team organization")
		else
			timer(5000, "timer_team_organization")
		end

		return
	end

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
			
			if map_mode == MAP_MODE.CURRENT then
				state = STATES.PRE_KNIFE_ROUND
			elseif map_mode == MAP_MODE.VOTE then
				
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

		if map_mode == MAP_MODE.CURRENT then
			if knife_round_enabled then
				state = STATES.PRE_KNIFE_ROUND
			else

			end
		elseif map_mode == MAP_MODE.VOTE then
		end

		teams_locked = true
	end
end

function timer_check_selection()
	local random_player = get_random_ready_player()
	local formatted_name = format_spectator_name(player(random_player, "name"))
	local buttons = MENUS["Spectators"].buttons
	
	for i = 1, #buttons do
		if buttons[i].label == formatted_name then
			buttons[i].label = "(" .. buttons[i].label .. ")"
			break
		end
	end
	
	forced_switch = true
	
	if state == STATES.TEAM_A_SELECTION and team_selector == team_a_captain then
		add_to_team_a(random_player)
		parse("maket " .. random_player)
		
		if #team_b < team_size then
			state = STATES.TEAM_B_SELECTION
			team_selector = team_b_captain
			event_change_menu(team_selector, MENU_ARGS[6])
			timer(5000, "timer_check_selection")
		else
			msg("FINISHED")
		end
		
		menu(team_a_captain, " ,")
	elseif state == STATES.TEAM_B_SELECTION and team_selector == team_b_captain then
		add_to_team_b(random_player)
		parse("makect " .. random_player)
		
		if #team_a < team_size then
			state = STATES.TEAM_A_SELECTION
			team_selector = team_a_captain
			event_change_menu(team_selector, MENU_ARGS[6])
			timer(5000, "timer_check_selection")
		else
			msg("FINISHED")
		end
		
		menu(team_b_captain, " ,")
	end
	
	forced_switch = false
end

--[[---------------------------------------------------------------------------
	COMMANDS FUNCTIONS
--]]---------------------------------------------------------------------------
local function register_command(syntax, func, arg, admin, silent)
	local regex

	if type(arg) == "string" then
		regex = arg
	else
		if not arg then
			regex = "^(" .. syntax .. ")$"
		else
			regex = "^" .. syntax .. "%s([^%s]+)$"
		end
	end
	
	COMMANDS[sub(syntax, 2)] = {
		syntax = syntax,
		regex = regex,
		admin = admin,
		silent = silent,
		func = func,
	}
end

local function command_ready(id, _)
	if not ready_access then return -1 end
	set_player_ready(id)
end

local function command_notready(id, _)
	if not ready_access then return -1 end
	set_player_notready(id)
end

local function command_bc(id, arg)
	msg("\169255255255" .. player(id, "name") .. ": " .. arg)
end

local function command_readyall(id, _)
	if started then return -1 end
	local players = player(0, "table")

	for k, v in pairs(players) do
		set_player_ready(v)
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
		end
	end

	set_player_notready(id)
	connected[id] = false
end

function warmod_die(victim)
end

function warmod_name(id, oldname, newname)
end

function warmod_say(id, text)
	local cmd = is_command(text)

	if cmd == nil then
		msg2(id, "\169255000000[ERROR]: Undefined command !")
		return 1
	elseif cmd then
		local arg = match(lower(text), cmd.regex)

		if not arg then
			msg2(id, "\169255000000[ERROR]: Invalid syntax !")
			return 1
		end

		execute_command(id, cmd, arg)
		return 1
	else

	end
end

function warmod_startround(mode)
	log("Startround", "Mode: " .. mode .. ", State: " .. state)

	if started then
		if state == STATES.PRE_CAPTAINS_KNIFE then
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
			
			elseif mode == 2 then
			
			elseif mode == 22 then
				
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
			state == STATES.KNIFE_ROUND then
			msg2(id, "\169255000000[ERROR]: You can't plant the bomb now !")
			return 1
		end
	end
end

function warmod_bombdefuse(id) end

function warmod_spawn(id)
	if started then
		if state == STATES.CAPTAINS_KNIFE or 
			state == STATES.KNIFE_ROUND then
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

register_command("!ready",    command_ready, nil, nil, true)
register_command("!notready", command_notready, nil, nil, true)
register_command("!readyall", command_readyall, nil, true)
register_command("!bc",       command_bc, "!bc%s(.+)$", true, true)

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
	--{label = " ", func = event_change_settings, args = {setting = "map", value = MAP_MODE.VETO}},
})

register_menu("Knife", {
	{label = "Enabled", func = event_change_settings, args = {setting = "knife", value = true}},
	{label = "Disabled", func = event_change_settings, args = {setting = "knife", value = false}},
})

register_menu("Spectators")
register_menu("Maps")

apply_settings("STARTUP")
load_maps()
check_folders()
load_mix_state()
randomseed(time())

load_maps        = nil
register_command = nil
register_menu    = nil
check_folders    = nil
load_mix_state   = nil
