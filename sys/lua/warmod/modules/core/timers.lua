--[[---------------------------------------------------------------------------
	Warmod Project
	Dev(s): x[N]ir, Hajt
	File: modules/core/timers.lua
	Description: timers functions
--]]---------------------------------------------------------------------------

-- Flag used when a timer function tries to "freetimer" itself during 
-- it's lifespan
warmod.timer_reached = false

-- Called when all players are ready
function warmod.timer_map_organization()
	if #warmod.ready < warmod.total_players then
		warmod.errors = warmod.errors + 1
		
		if warmod.errors == warmod.MAX_ERRORS then
			warmod.cancel_mix("Not enough ready players during map organization !")
		else
			timer(5000, "warmod.timer_map_organization")
		end
	end
	
	if warmod.map_mode == warmod.MAP_MODE.CURRENT then
		warmod.timer_team_organization()
	elseif warmod.map_mode == warmod.MAP_MODE.VOTE then
		for k, id in pairs(warmod.ready) do 
			warmod.event_change_menu(id, warmod.MENU_ARGS[7])
		end
		
		timer(15000, "warmod.timer_map_vote_results")
	elseif warmod.map_mode == warmod.MAP_MODE.VETO then
		local r1 = warmod.get_random_ready_player()
		local r2 = warmod.get_random_ready_player()
		
		while r2 == r1 do
			r2 = warmod.get_random_ready_player()
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
		
		warmod.veto_player_1 = r1
		warmod.veto_player_2 = r2
		
		if warmod.knife_round_enabled then
			warmod.state = warmod.STATES.PRE_MAP_VETO
		else
			if math.random(2) == 1 then
				warmod.veto_winner = warmod.veto_player_1
				warmod.veto_looser = warmod.veto_player_2
			else
				warmod.veto_winner = warmod.veto_player_2
				warmod.veto_looser = warmod.veto_player_1
			end
			
			warmod.sv_msg(player(warmod.veto_winner, "name") .. 
				" will veto first !")
			warmod.event_change_menu(warmod.veto_winner, warmod.MENU_ARGS[8])
			warmod.state = warmod.STATES.WINNER_VETO
			timer(5000, "warmod.timer_check_veto")
		end
		
		warmod.teams_locked = true
	end
end

-- Change map based on map vote results
function warmod.timer_map_vote_results()
	local max, map
	
	for k, votes in pairs(warmod.map_votes) do
		if #votes > 0 and (not max or max > #votes) then
			map = k
			max = #votes
		end
	end
	
	if not map then
		warmod.cancel_mix("Nobody has voted for a map !")
	else
		warmod.sv_msg("Next map: " .. map)
		timer(3000, "parse", 'sv_map ' .. map)
	end
end

-- Deals with AFK(s) during map selection
function warmod.timer_check_veto()
	warmod.timer_reached = true

	local veto_maps = warmod.MENUS["Veto"].buttons
	local random_map = veto_maps[math.random(#veto_maps)].label

	if warmod.state == warmod.STATES.WINNER_VETO then
		warmod.event_veto(warmod.veto_winner, random_map)
	elseif warmod.state == warmod.STATES.LOOSER_VETO then
		warmod.event_veto(warmod.veto_looser, random_map)
	end

	warmod.timer_reached = false
end

-- Once the map has been chosen, it's time to setup teams
function warmod.timer_team_organization()
	-- Current teams
	if warmod.team_organization == 1 then
		local number_t  = #player(0, "team1")
		local number_ct = #player(0, "team2")

		if number_t ~= warmod.team_size or number_ct ~= warmod.team_size then
			warmod.cancel_mix("Is that difficult to gather " .. 
				warmod.team_size .. " on both sides !?")
		else
			while #warmod.team_a < warmod.team_size or 
					#warmod.team_b < warmod.team_size do
				local random_player = warmod.get_random_ready_player()

				if #warmod.team_a < warmod.team_size then
					warmod.add_to_team_a(random_player)
				else
					warmod.add_to_team_b(random_player)
				end
			end

			local players = player(0, "table")

			for k, v in pairs(players) do
				if warmod.table_contains(warmod.team_a, v) then
					parse("maket " .. v)
				elseif warmod.table_contains(warmod.team_b, v) then
					parse("makect " .. v)
				else
					parse("makespec " .. v)
				end
			end

			--warmod.team_a_captain = warmod.team_a[math.random(#warmod.team_a)]
			warmod.team_a_captain = 1
			warmod.team_b_captain = warmod.team_b[math.random(#warmod.team_b)]

			msg("\169255255255" .. player(warmod.team_a_captain, "name") .. 
				" has been chosen as Team A Captain !")
			msg("\169255255255" .. player(warmod.team_b_captain, "name") .. 
				" has been chosen as Team B Captain !")
			
			if warmod.knife_round_enabled then
				warmod.state = warmod.STATES.PRE_KNIFE_ROUND
			else
				warmod.state = warmod.STATES.PRE_FIRST_HALF
			end
			
			warmod.teams_locked = true
		end
	-- Random Captains
	elseif warmod.team_organization == 2 then
		--local a_captain = warmod.get_random_ready_player()
		a_captain = 1
		local b_captain = warmod.get_random_ready_player()

		while b_captain == a_captain do
			b_captain = warmod.get_random_ready_player()
		end

		warmod.team_a_captain = a_captain
		warmod.team_b_captain = b_captain
		
		warmod.add_to_team_a(warmod.team_a_captain)
		warmod.add_to_team_b(warmod.team_b_captain)

		msg("\169255255255" .. player(warmod.team_a_captain, "name") .. 
			" has been chosen as Team A Captain !")
		msg("\169255255255" .. player(warmod.team_b_captain, "name") .. 
			" has been chosen as Team B Captain !")

		local players = player(0, "table")

		for k, v in pairs(players) do
			if v == warmod.team_a_captain then
				parse("maket " .. v)
			elseif v == warmod.team_b_captain then
				parse("makect " .. v)
			else
				parse("makespec " .. v)
			end
		end

		if warmod.knife_round_enabled then
			warmod.state = warmod.STATES.PRE_CAPTAINS_KNIFE
		else
			warmod.state = warmod.STATES.PRE_TEAM_SELECTION
		end
		
		warmod.teams_locked = true
	-- Random Teams
	elseif warmod.team_organization == 3 then
		while #warmod.ready > 0 do
			if #warmod.team_a < warmod.team_size then
				warmod.add_to_team_a(warmod.get_random_ready_player())
			else
				warmod.add_to_team_b(warmod.get_random_ready_player())
			end
		end

		local a_captain = warmod.team_a[math.random(#warmod.team_a)]
		local b_captain = warmod.team_b[math.random(#warmod.team_b)]

		--warmod.team_a_captain = a_captain
		warmod.team_a_captain = 1
		warmod.team_b_captain = b_captain

		msg("\169255255255" .. player(warmod.team_a_captain, "name") .. 
			" has been chosen as Team A Captain !")
		msg("\169255255255" .. player(warmod.team_b_captain, "name") .. 
			" has been chosen as Team B Captain !")

		local players = player(0, "table")

		for k, v in pairs(players) do
			if warmod.table_contains(warmod.team_a, v) then
				parse("maket " .. v)
			elseif warmod.table_contains(warmod.team_b, v) then
				parse("makect " .. v)
			else
				parse("makespec " .. v)
			end
		end

		if warmod.knife_round_enabled then
			warmod.state = warmod.STATES.PRE_KNIFE_ROUND
		else
			warmod.state = warmod.STATES.PRE_FIRST_HALF
		end

		warmod.teams_locked = true
	end
end

-- Deals with AFK(s) during player selection (captains mode)
function warmod.timer_check_selection()
	warmod.timer_reached = true

	local buttons = warmod.MENUS["Spectators"].buttons
	local random_button = buttons[math.random(#buttons)]
	
	-- Get a player which hasn't already been selected
	while string.match(random_button.label, "%(") do
		random_button = buttons[math.random(#buttons)]
	end
		
	warmod.event_choose_spectator(warmod.team_selector, 
			random_button.args)
	
	warmod.timer_reached = false
end

-- Process side vote results
function warmod.timer_check_side_results()
	local stay = #warmod.stay_votes
	local swap = #warmod.swap_votes
	
	if swap > stay then
		warmod.swap_teams()
		warmod.swap_teams_data()

		if warmod.knife_winner == 1 then
			warmod.sv_msg("Terrorists decided to swap")
		else
			warmod.sv_msg("Counter-Terrorists decided to swap")
		end
	else
		if warmod.knife_winner == 1 then
			warmod.sv_msg("Terrorists decided to stay")
		else
			warmod.sv_msg("Counter-Terrorists decided to stay")
		end
	end
	
	warmod.state = warmod.STATES.PRE_FIRST_HALF
	warmod.safe_restart()
end