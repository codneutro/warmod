--[[---------------------------------------------------------------------------
	Warmod Project
	Dev(s): x[N]ir, Hajt
	File: modules/commands/list.lua
	Description: commands functions
--]]---------------------------------------------------------------------------

warmod.COMMANDS["!ready"] = {
	argv = 0,
	syntax = "",
	admin = false,
	func = function(id, argv)
		if not warmod.ready_access then 
			return "This feature is currently not available" 
		end

		if player(id, "team") == 0 then
			return "You can use this command while being spectator !"
		end

		warmod.set_player_ready(id)
	end
}

warmod.COMMANDS["!notready"] = {
	argv = 0,
	syntax = "",
	admin = false,
	func = function(id, argv)
		if not warmod.ready_access then 
			return "This feature is currently not available" 
		end

		if player(id, "team") == 0 then
			return "You can use this command while being spectator !"
		end

		warmod.set_player_notready(id)
	end
}

warmod.COMMANDS["!bc"] = {
	argv = 1,
	syntax = "<message>",
	admin = true,
	func = function(id, argv)
		local a1 = warmod.escape_string(argv[1])

		msg("\169255255255"..player(id,"name")..": "..a1)
	end
}

warmod.COMMANDS["!readyall"] = {
	argv = 0,
	syntax = "",
	admin = true,
	func = function(id, argv)
		if warmod.started then 
			return "This feature is currently not available" 
		end

		local players = player(0, "table")

		for k, v in pairs(players) do
			if player(v, "team") ~= 0 then
				warmod.set_player_ready(v)
			end
		end
	end
}

warmod.COMMANDS["!cancel"] = {
	argv = 0,
	syntax = "",
	admin = true,
	func = function(id, argv)
		if not warmod.started then 
			return "This feature is currently not available" 
		end

		warmod.cancel_mix("Canceled by " .. player(id, "name"))
	end
}

warmod.COMMANDS["!whois"] = {
	argv = 1,
	admin = false,
	syntax = "<id>",
	func = function(id, argv)
		local a1 = tonumber(argv[1])

		if not a1 then 
			return "First argument must be a number" 
		end

		if not player(a1, "exists") then 
			return "Player does not exist" 
		end

		if player(a1, "usgn") == 0 then 
			return player(a1, "name") .. " is not logged in" 
		end

		local name = warmod.usgns[player(a1, "usgn")] or false

		if name == false then 
			return "Unknown username" 
		end

		msg2(id, "\169175255100[SERVER]:\169255255255 " .. player(a1, "name") ..
			" is logged in as " .. name .. " (ID " .. player(a1, "usgn") .. ")")
	end
}

warmod.COMMANDS["!mute"] = {
	argv = 1,
	syntax = "<id>",
	admin = true,
	func = function(id, argv)
		local a1 = tonumber(argv[1])

		if not a1 then 
			return "First argument must be a number" 
		end

		if not player(a1, "exists") then 
			return "Player does not exist" 
		end

		if warmod.mute[a1] == true then 
			return player(a1, "name") .. " is already muted" 
		end

		warmod.mute[a1] = true
		msg("\169175255100[SERVER]:\169255255255 " .. player(id, "name") ..
			" muted " .. player(a1, "name"))
	end
}

warmod.COMMANDS["!unmute"] = {
	argv = 1,
	syntax = "<id>",
	admin = true,
	func = function(id, argv)
		local a1 = tonumber(argv[1])

		if not a1 then 
			return "First argument must be a number" 
		end

		if not player(a1, "exists") then 
			return "Player does not exist" 
		end

		if warmod.mute[a1] == false then 
			return player(a1, "name") .. " is not muted" 
		end

		warmod.mute[a1] = false
		msg("\169175255100[SERVER]:\169255255255 " .. player(id, "name") ..
			" unmuted " .. player(a1, "name"))
	end
}

warmod.COMMANDS["!teamname"] = {
	argv = 1,
	syntax = "<name>",
	admin = false,
	func = function(id, argv)
		local a1 = warmod.escape_string(argv[1])

		if not warmod.started then 
			return "This feature is currently not available" 
		end

		if warmod.team_a_captain == id then
			if warmod.team_a_name == "Team A" then
				warmod.team_a_name = a1
				msg("\169175255100[SERVER]:\169255255255 " .. player(id, "name") ..
				" changed the team name to " .. a1)
				return
			else
				return "Your team name has already been set !"
			end
		end

		if warmod.team_b_captain == id then
			if warmod.team_b_name == "Team B" then
				warmod.team_b_name = a1
				msg("\169175255100[SERVER]:\169255255255 " .. player(id, "name") ..
				" changed the team name to " .. a1)
				return
			else
				return "Your team name has already been set !"
			end
		end

		return "This feature is available only for team captains"
	end
}

warmod.COMMANDS["!sub"] = {
	argv = 1,
	syntax = "<id>",
	admin = false,
	func = function(id, argv)
		if not warmod.started then
			return "This feature is currently not available" 
		end

		local target = tonumber(argv[1])

		if not target then 
			return "First argument must be a number" 
		end

		if not player(target, "exists") then 
			return "Player does not exist" 
		end

		local subber_team = player(id, "team")
		local target_team = player(target, "team")

		if subber_team == 0 then
			if target_team == 0 then
				return "You can't sub a spectator !"
			else

			end
		else
			if target_team ~= 0 then
				return "You must select a spectator !"
			else

			end
		end
	end
}

warmod.COMMANDS["!nosub"] = {
	argv = 1,
	syntax = "",
	admin = false,
	func = function(id, argv)
		if not warmod.started then
			return "This feature is currently not available" 
		end

		if not warmod.is_playing(id) then
			return "This feature is currently not available"
		end


	end
}

warmod.COMMANDS["!map"] = {
	argv = 1,
	syntax = "<name>",
	admin = true,
	func = function(id, argv)
		if warmod.started then
			return "This feature is currently not available" 
		end

		local map = argv[1]

		if not warmod.table_contains(warmod.MAPS, map) then
			return "This map isn't in the map list !"
		end

		parse('sv_map ' .. map)
	end
}