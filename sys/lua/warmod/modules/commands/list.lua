--[[---------------------------------------------------------------------------
	Warmod Project
	Dev(s): x[N]ir, Hajt
	File: modules/commands/list.lua
	Description: Commands functions
--]]---------------------------------------------------------------------------

warmod.COMMANDS["!ready"] = {
	argv = 0,
	syntax = "",
	admin = false,
	func = function(id, argv)
		if not warmod.ready_access then 
			return "This feature is currently not available" 
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

		msg("\169175255100[SERVER]:\169255255255 " .. player(id, "name") ..
			" used readyall")

		local players = player(0, "table")

		for k, v in pairs(players) do
			warmod.set_player_ready(v)
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

		msg("\169175255100[SERVER]:\169255255255 " .. player(id, "name") ..
			" used mute " .. a1)
		warmod.mute[a1] = true
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

		msg("\169175255100[SERVER]:\169255255255 " .. player(id, "name") ..
			" used unmute " .. a1)
		warmod.mute[a1] = false
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
		if not warmod.started or warmod.state < warmod.STATES.FIRST_HALF then
			return "This feature is currently not available" 
		end

		local target = tonumber(argv[1])

		if not target then 
			return "First argument must be a number" 
		end

		if not player(target, "exists") then 
			return "Player does not exist" 
		end

		if player(id, "team") == 0 then
			return "This feature is disabled for spectators"
		end

		local target_team = player(target, "team")

		if target_team ~= 0 then
			return "You must select a spectator !"
		else
			local spec_target = warmod.sub_players[id]

			-- Already requested someone else
			if spec_target then
				if spec_target == target then
					return "You have already sent a sub request to this player !"
				end

				local spec = warmod.sub_players[id]
				warmod.sub_spectators[spec] = nil
				warmod.sub_players[id] = nil

				msg2(spec, "\169255255255[SUB]: " .. 
					player(id, "name") .. " has decided to cancel his sub")
			end

			-- Will the target replace someone else
			for mix_player, spec_target in pairs(warmod.sub_players) do
				if target == spec_target and warmod.sub_spectators[spec_target] then
					return player(spec_target, "name") .. " will sub someone else !"
				end
			end

			warmod.sub_players[id] = target
			msg2(target, "\169255255255[SUB]: " .. 
					player(id, "name") .. " has chosen you as his sub, write !accept")
		end
	end
}

warmod.COMMANDS["!accept"] = {
	argv = 0,
	syntax = "",
	admin = false,
	func = function(id, argv)
		if not warmod.started or warmod.state < warmod.STATES.FIRST_HALF then
			return "This feature is currently not available" 
		end

		if player(id, "team") ~= 0 then
			return "This feature is only available for spectators"
		end

		for mix_player, spec_target in pairs(warmod.sub_players) do
			if spec_target == id then
				msg2(mix_player, "\169255255255[SUB]: " .. player(id, "name") .. 
					" has accepted to sub you !")
				msg2(id, "\169255255255[SUB]: You'll sub " .. 
					player(mix_player, "name") .. " in the following round !")
				warmod.sub_spectators[id] = true
				return
			end
		end

		return "Nobody asked you for a sub !"
	end
}

warmod.COMMANDS["!nosub"] = {
	argv = 0,
	syntax = "",
	admin = false,
	func = function(id, argv)
		if not warmod.started then
			return "This feature is currently not available" 
		end

		if not warmod.is_playing(id) then
			return "This feature is currently not available"
		end

		local spec = warmod.sub_players[id]

		if not spec then
			return "You didnt ask for a sub !"
		end

		warmod.sub_spectators[spec] = nil
		warmod.sub_players[id]      = nil

		msg2(spec, "\169255255255[SUB]: " .. 
			player(id, "name") .. " has decided to cancel his sub")
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

		local a1 = warmod.escape_string(argv[1])

		if not warmod.table_contains(warmod.MAPS, a1) then
			return "This map isn't in the map list !"
		end

		msg("\169175255100[SERVER]:\169255255255 " .. player(id, "name") ..
			" used map " .. a1)
		parse("map " .. a1)
	end
}

warmod.COMMANDS["!kick"] = {
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

		msg("\169175255100[SERVER]:\169255255255 " .. player(id, "name") ..
			" used kick " .. a1)
		parse("kick " .. a1)
	end
}

warmod.COMMANDS["!ban"] = {
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

		msg("\169175255100[SERVER]:\169255255255 " .. player(id, "name") ..
			" used ban " .. a1)

		local usgn = player(a1, "usgn")
		local ip   = player(a1, "ip")

		if usgn > 0 then
			parse("banusgn " .. usgn)
		end

		parse("banip " .. ip)
	end
}

warmod.COMMANDS["!tempban"] = {
	argv = 2,
	syntax = "<id> <duration in hours>",
	admin = true,
	func = function(id, argv)
		local a1 = tonumber(argv[1])
		local a2 = tonumber(argv[2])

		if not a1 or not a2 then 
			return "Both arguments must be a number" 
		end

		if a2 < 1 or a2 > 24 then
			return "Duration must be in the range from 1 to 24 hours"
		end

		if not player(a1, "exists") then 
			return "Player does not exist" 
		end

		msg("\169175255100[SERVER]:\169255255255 " .. player(id, "name") ..
			" used tempban " .. a1 .. " " .. a2)

		local usgn = player(a1, "usgn")
		local ip   = player(a1, "ip")

		if usgn > 0 then
			parse("banusgn " .. usgn .. " " .. a2 * 60)
		end

		parse("banip " .. ip .. " " .. a2 * 60)
	end
}

warmod.COMMANDS["!version"] = {
	argv = 0,
	syntax = "",
	admin = false,
	func = function(id, argv)
		msg2(id, "\169255000000Version: \169255165000" .. warmod.VERSION)
	end
}

warmod.COMMANDS["!help"] = {
	argv = 0,
	syntax = "",
	admin = false,
	func = function(id, argv)
		for k, v in pairs(warmod.COMMANDS) do
			msg2(id, "\169255255255" .. k .. " " .. v.syntax)
		end
	end
}

warmod.COMMANDS["!rr"] = {
	argv = 0,
	syntax = "",
	admin = false,
	func = function(id, argv)
		if not warmod.started or warmod.state < warmod.STATES.FIRST_HALF then
			return "This feature is currently not available"
		end

		if not warmod.is_playing(id) then
			return "You aren't allowed to vote !"
		end

		if warmod.table_contains(warmod.rr_votes, id) then
			return "You have already voted !!"
		end

		warmod.rr_votes[#warmod.rr_votes + 1] = id
		warmod.sv_msg(player(id, "name") .. " has voted for a restart !")

		local total_vote = #warmod.rr_votes
		local total_players = #warmod.team_a + #warmod.team_b

		if (total_vote / total_players) >= 0.6 then
			warmod.sv_msg("Players decided to restart the half !")
			warmod.safe_restart()
		end
	end
}

warmod.COMMANDS["!maket"] = {
	argv = 1,
	syntax = "<id>",
	admin = true,
	func = function(id, argv)
		if warmod.started then
			return "This feature is currently not available" 
		end

		local a1 = tonumber(argv[1])

		if not a1 then 
			return "First argument must be a number" 
		end

		if not player(a1, "exists") then 
			return "Player does not exist" 
		end

		msg("\169175255100[SERVER]:\169255255255 " .. player(id, "name") ..
			" used maket " .. a1)
		parse("maket " .. a1)
	end
}

warmod.COMMANDS["!makect"] = {
	argv = 1,
	syntax = "<id>",
	admin = true,
	func = function(id, argv)
		if warmod.started then
			return "This feature is currently not available" 
		end

		local a1 = tonumber(argv[1])

		if not a1 then 
			return "First argument must be a number" 
		end

		if not player(a1, "exists") then 
			return "Player does not exist" 
		end

		msg("\169175255100[SERVER]:\169255255255 " .. player(id, "name") ..
			" used makect " .. a1)
		parse("makect " .. a1)
	end
}

warmod.COMMANDS["!makespec"] = {
	argv = 1,
	syntax = "<id>",
	admin = true,
	func = function(id, argv)
		if warmod.started then
			return "This feature is currently not available" 
		end

		local a1 = tonumber(argv[1])

		if not a1 then 
			return "First argument must be a number" 
		end

		if not player(a1, "exists") then 
			return "Player does not exist" 
		end

		msg("\169175255100[SERVER]:\169255255255 " .. player(id, "name") ..
			" used makespec " .. a1)
		parse("makespec " .. a1)
	end
}