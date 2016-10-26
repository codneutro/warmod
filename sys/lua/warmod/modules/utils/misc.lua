--[[---------------------------------------------------------------------------
	Warmod Project
	Dev(s): x[N]ir, Hajt
	File: modules/utils/misc.lua
	Description: misc functions
--]]---------------------------------------------------------------------------

warmod.usgns = {}	-- whois command
warmod.MAPS  = {}	

function warmod.log(tag, text)
	print("\169255255255[LOG]: \"" .. tag .. "\": " .. text)
end

function warmod.error(tag, text)
	print("\169255000000[ERROR]: \"" .. tag .. "\": " .. text)
end

function warmod.sv_msg(text)
	msg("\169000255000[WARMOD] " .. text)
end

-- Execute server settings depending of a key
-- @see constants.lua for more info
function warmod.apply_settings(key)
	local settings = warmod.SETTINGS[key]

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

function warmod.load_usgns()
	if warmod.file_load(warmod.USGNS_FILE) then
		local line = warmod.file_read()

		while line do
			local usgn, name = string.match(line, "([^,]+),([^,]+)")
			table.insert(warmod.usgns, tonumber(usgn), name)
			line = warmod.file_read()
		end
	end
end

function warmod.hudtxt(id, text, x, y, color, align)
	parse('hudtxt ' .. id .. ' "\169' .. 
			(color ~= nil and color or "255255255") .. text .. '" ' .. 
			x .. ' ' .. y .. ' ' .. (align ~= nil and align or 1))
end

function warmod.cleartxt(...)
	for _, id in ipairs(arg) do
		parse('hudtxt ' .. id)
	end
end

function warmod.clear_all_texts()
	for i = 0, 49 do
		parse('hudtxt ' .. i)
	end
end

function warmod.allspec()
	local players = player(0, "table")

	for k, v in pairs(players) do
		parse("makespec " .. v)
	end
end

function warmod.safe_restart()
	timer(5000, "parse", 'sv_restart')
end

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
	local prefixes     = {"^de_", "^pcs_", "^up_", "^sf_", "^icc_"}
	local buttons      = warmod.MENUS["Maps"].buttons
	local veto_buttons = warmod.MENUS["Veto"].buttons

	for file in io.enumdir("maps") do
		if string.match(file, "[^.]+$") == "map" then
			local text = string.match(file, "(.+)%..+")

			for k, prefix in pairs(prefixes) do
				if string.match(text, prefix) then
					warmod.MAPS[#warmod.MAPS + 1] = text
					warmod.map_votes[text] = {}
					veto_buttons[#veto_buttons + 1] = {label = text, 
						func = warmod.event_veto, args = text}

					if text ~= warmod.CURRENT_MAP then
						buttons[#buttons + 1] = {label = text, 
						func = warmod.event_vote_map, args = text}
					end
				end
			end
		end
	end
end

function warmod.escape_string(text)
	if string.sub(text, -2) == "@C" then
		text = string.sub(text, 1, string.len(text) - 2)
	end

	text = string.gsub(text, "[\166]", " ")

	return text
end