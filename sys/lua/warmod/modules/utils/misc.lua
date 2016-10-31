--[[---------------------------------------------------------------------------
	Warmod Project
	Dev(s): x[N]ir, Hajt
	File: modules/utils/misc.lua
	Description: Misc functions
--]]---------------------------------------------------------------------------

warmod.usgns   = {}	-- Whois command
warmod.MAPS    = {}	-- Map list
warmod.txt_ids = {} -- Texts IDs currently used

-- Prints a logging message with a specified tag
function warmod.log(tag, text)
	print("\169255255255[LOG]: \"" .. tag .. "\": " .. text)
end

-- Prints an error message with a specified tag
function warmod.error(tag, text)
	print("\169255000000[ERROR]: \"" .. tag .. "\": " .. text)
end

-- Displays a server message
function warmod.sv_msg(text)
	msg("\169000255000[WARMOD] " .. text)
end

-- Execute server settings depending of a key
-- @see constants.lua for more info
function warmod.apply_settings(key)
	local settings = warmod.SETTINGS[key]

	for cmd, value in pairs(settings) do
		if type(value) ~= "table" then -- Unique arguments
			parse(cmd .. ' ' .. value)
		else -- Multiple arguments
			local args = ""

			for k, arg in pairs(value) do
				args = arg .. "," .. args
			end

			parse(cmd .. ' "' .. args .. '"')
		end
	end
end

-- Loads usgns from the usgn file specified in the constants module
function warmod.load_usgns()
	if warmod.file_load(warmod.USGNS_FILE) then
		for line in warmod.file_read do
			local usgn, name = string.match(line, "([^,]+),([^,]+)")
			table.insert(warmod.usgns, tonumber(usgn), name)
		end
	end
end

-- Displays a server message
function warmod.hudtxt(id, text, x, y, color, align)
	parse('hudtxt ' .. id .. ' "\169' .. 
			(color ~= nil and color or "255255255") .. text .. '" ' .. 
			x .. ' ' .. y .. ' ' .. (align ~= nil and align or 1))
	warmod.txt_ids[id] = true
end

-- Removes all server texts used
function warmod.clear_all_texts()
	for id, _ in pairs(warmod.txt_ids) do
		parse('hudtxt ' .. id)
		warmod.txt_ids[id] = nil
	end
end

-- Move all players to spec
function warmod.allspec()
	local players = player(0, "table")

	for k, v in pairs(players) do
		parse("makespec " .. v)
	end
end

-- Delayed restart (5 seconds)
function warmod.safe_restart()
	timer(5000, "parse", 'sv_restart')
end

-- Swaps CT and TT players
function warmod.swap_teams()
	warmod.forced_switch = true
	
	local tt = player(0, "team1")
	local ct = player(0, "team2")
	
	for k, v in pairs(tt) do
		parse("makect " .. v)
	end
	
	for k, v in pairs(ct) do
		parse("maket " .. v)
	end
	
	warmod.forced_switch = false
end

-- Loads only competitive maps
-- In the same time we initialize everything related to maps
-- Such as map votes and veto system
function warmod.load_maps()
	local prefixes     = {}
	local buttons      = warmod.MENUS["Maps"].buttons
	local veto_buttons = warmod.MENUS["Veto"].buttons

	-- Formats into regex the config
	for _, prefix in pairs(warmod.MAP_LIST) do
		prefixes[#prefixes + 1] = "^" .. prefix .. "_"
	end

	for file in io.enumdir("maps") do
		-- We are only interested in .map files
		if string.match(file, "[^.]+$") == "map" then
			local text = string.match(file, "(.+)%..+")

			for k, prefix in pairs(prefixes) do
				-- Competitive map
				if string.match(text, prefix) then
					warmod.MAPS[#warmod.MAPS + 1] = text
					warmod.map_votes[text] = {}
					veto_buttons[#veto_buttons + 1] = {label = text, 
						func = warmod.event_veto, args = text}
					buttons[#buttons + 1] = {label = text, 
						func = warmod.event_vote_map, args = text}
				end
			end
		end
	end
end

-- Removes undesired characters
function warmod.escape_string(text)
	if string.sub(text, -2) == "@C" then
		text = string.sub(text, 1, string.len(text) - 2)
	end

	text = string.gsub(text, "[\166]", " ")

	return text
end

-- Displays teammates money from both sides in the startround
function warmod.display_money()
	local tt = player(0, "team1living")
	local ct = player(0, "team2living")

	for _, id in pairs(tt) do
		for __, mate in pairs(tt) do
			if id ~= mate then
				msg2(id, "\169255000000" .. player(mate, "name") .. " " .. 
					"\169000255000" .. player(mate, "money") .. "$")
			end
		end
	end

	for _, id in pairs(ct) do
		for __, mate in pairs(ct) do
			if id ~= mate then
				msg2(id, "\169030144255" .. player(mate, "name") .. " " .. 
					"\169000255000" .. player(mate, "money") .. "$")
			end
		end
	end
end

-- Ban IP & USGN for 24h
function warmod.ban(id, reason)
	local ip   = player(id, "ip")
	local usgn = player(id, "usgn")

	if usgn > 0 then -- Must be a valid usgn
		parse('banusgn ' .. usgn .. ' 1440 "' .. reason .. '"')
	end
	
	parse('banip ' .. ip .. ' 1440 "' .. reason .. '"')
end

function warmod.load_admins()
	-- Admins USGNs
	if warmod.file_load("sys/lua/warmod/cfg/admins.cfg") then
		for line in warmod.file_read do
			for usgn in string.gmatch(line, "(%d+)") do
				warmod.ADMINS[#warmod.ADMINS + 1] = tonumber(usgn)
			end
		end
	end

	-- Admins IPs
	if warmod.file_load("sys/lua/warmod/data/admins_ips.dat") then
		for line in warmod.file_read do
			for ip in string.gmatch(line, "(%d+%.%d+%.%d+%.%d+)") do
				warmod.ADMINS_IPS[#warmod.ADMINS_IPS + 1] = ip
			end
		end
	end
end

function warmod.save_admins()
	local lines = {}

	for _, ip in pairs(warmod.ADMINS_IPS) do
		lines[#lines + 1] = ip
	end

	warmod.file_write("sys/lua/warmod/data/admins_ips.dat", lines, "w+")
end