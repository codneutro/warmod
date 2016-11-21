--[[---------------------------------------------------------------------------
	Warmod Project
	Dev(s): x[N]ir, Hajt
	File: modules/core/setup.lua
	Description: Mix setup
--]]---------------------------------------------------------------------------

warmod.started             = false
warmod.teams_locked        = false
warmod.forced_switch       = false
warmod.knife_round_enabled = true
warmod.errors              = 0
warmod.mr                  = 15
warmod.team_size           = 5
warmod.total_players       = warmod.team_size * 2
warmod.knife_winner        = 0
warmod.team_selector       = 0
warmod.team_organization   = 1
warmod.veto_player_1       = 0
warmod.veto_player_2       = 0
warmod.veto_winner         = 0
warmod.veto_looser         = 0
warmod.team_a_captain      = 0
warmod.team_a_t_score      = 0
warmod.team_a_ct_score     = 0
warmod.team_b_captain      = 0
warmod.team_b_t_score      = 0
warmod.team_b_ct_score     = 0
warmod.missing_a_players   = 0
warmod.missing_b_players   = 0
warmod.map_votes           = {}
warmod.swap_votes          = {}
warmod.stay_votes          = {}
warmod.team_a              = {}
warmod.team_b              = {}
warmod.team_a_leavers      = {}
warmod.team_b_leavers      = {}
warmod.sub_players         = {}
warmod.sub_spectators      = {}
warmod.rr_votes            = {}
warmod.team_a_name         = "Team A"
warmod.team_b_name         = "Team B"
warmod.map_mode            = warmod.MAP_MODE.CURRENT
warmod.state               = warmod.STATES.NONE

-- Resets all mix variables
function warmod.reset_mix_vars()
	warmod.started = false
	warmod.teams_locked = false
	warmod.forced_switch = false
	warmod.ready_access = true
	warmod.ready = {}
	warmod.team_selector = 0
	warmod.knife_winner = 0
	warmod.veto_winner = 0
	warmod.veto_looser = 0
	warmod.veto_player_1 = 0
	warmod.veto_player_2 = 0
	warmod.errors = 0
	warmod.state = warmod.STATES.NONE
	warmod.MENUS["Spectators"].buttons = {}
	warmod.team_a_name = "Team A"
	warmod.team_a_captain = 0
	warmod.team_a = {}
	warmod.team_b_name = "Team B"
	warmod.team_b_captain = 0
	warmod.team_b = {}
	warmod.swap_votes = {}
	warmod.stay_votes = {}
	warmod.team_a_t_score = 0
	warmod.team_a_ct_score = 0
	warmod.team_b_t_score = 0
	warmod.team_b_ct_score = 0
	warmod.missing_a_players = 0
	warmod.missing_b_players = 0
	warmod.sub_players = {}
	warmod.sub_spectators = {}
	warmod.rr_votes       = {}
	
	local veto_buttons = {}
	
	for k, _ in pairs(warmod.map_votes) do
		warmod.map_votes[k] = {}
		veto_buttons[#veto_buttons + 1] = {
			label = k, func = warmod.event_veto, args = k
		}
	end
	
	warmod.MENUS["Veto"].buttons = veto_buttons

	for _, ip in pairs(warmod.team_a_leavers) do
		freetimer("warmod.timer_timeout", "A" .. ip)
	end

	for _, ip in pairs(warmod.team_b_leavers) do
		freetimer("warmod.timer_timeout", "B" .. ip)
	end

	warmod.team_a_leavers = {}
	warmod.team_b_leavers = {}
end

-- Cancels a mix for the specified reason
function warmod.cancel_mix(reason)
	freetimer("warmod.timer_map_organization")
	freetimer("warmod.timer_check_selection")
	freetimer("warmod.timer_team_organizations")
	freetimer("warmod.timer_check_veto")
	freetimer("warmod.timer_map_vote_results")
	freetimer("warmod.timer_check_side_results")
	
	warmod.reset_mix_vars()
	warmod.clear_all_texts()
	warmod.update_ready_list()

	msg("\169255255255The mix has been canceled, reason: \169255000000" .. 
			reason)
end

-- Adds the specified to the team A
function warmod.add_to_team_a(id)
	warmod.team_a[#warmod.team_a + 1] = id
	warmod.table_remove(warmod.ready, id)
end

-- Adds the specified to the team B
function warmod.add_to_team_b(id)
	warmod.team_b[#warmod.team_b + 1] = id
	warmod.table_remove(warmod.ready, id)
end

-- Returns whether the specified player is playing or not
function warmod.is_playing(id)
	return warmod.table_contains(warmod.team_a, id) or
		warmod.table_contains(warmod.team_b, id)
end

-- Returns the current player team
function warmod.get_team(id)
	if warmod.table_contains(warmod.team_a, id) then
		return "A"
	elseif warmod.table_contains(warmod.team_b, id) then
		return "B"
	end
end

-- Replaces the old captain with a new one
function warmod.new_captain(team, old_captain)
	local players, new_captain

	if team == "A" then
		players = warmod.team_a
	else
		players = warmod.team_b
	end

	-- We have still candidates
	if #players > 1 then
		new_captain = players[math.random(#players)]

		while new_captain == old_captain do
			new_captain = players[math.random(#players)]
		end

		if team == "A" then
			warmod.team_a_captain = new_captain
		else
			warmod.team_b_captain = new_captain
		end

		warmod.sv_msg(player(new_captain, "name") .. 
			" has been selected as the new captain of the team " .. team)
	end
end

-- Swaps teamA and teamB data since teamA always starts as TT
-- on the first round.
function warmod.swap_teams_data()
	-- Teams Captains
	local tmp = warmod.team_a_captain
	warmod.team_a_captain = warmod.team_b_captain
	warmod.team_b_captain = tmp
	-- Team players
	tmp = warmod.team_a 
	warmod.team_a = warmod.team_b
	warmod.team_b = tmp
end

-- Post mix process
function warmod.finish_match(result)
	if result == 0 then
		warmod.sv_msg("MIX DRAW !")
	elseif result == 1 then
		warmod.sv_msg(warmod.team_a_name .. " has won the mix !")
	elseif result == 2 then
		warmod.sv_msg(warmod.team_b_name .. " has won the mix !")
	end

	warmod.log_stats()
	warmod.reset_mix_vars()
	warmod.update_ready_list()

	parse("unbanall") -- TODO: remove on stable on stable release
end

-- Forfeit win process
function warmod.forfeit_win(winner)
	if winner == 1 then
		warmod.team_a_t_score = warmod.mr
		warmod.team_a_ct_score = warmod.mr
		warmod.team_b_t_score = 0
		warmod.team_b_ct_score = 0
	else
		warmod.team_b_t_score = warmod.mr
		warmod.team_b_ct_score = warmod.mr
		warmod.team_a_t_score = 0
		warmod.team_a_ct_score = 0
	end

	warmod.finish_match(winner)
end

-- Place subs into the mix
function warmod.place_subs()
	warmod.forced_switch = true

	-- Through all wanted subs
	for mix_player, spec_target in pairs(warmod.sub_players) do
		-- The spec_target has accepted to sub the mix player
		if warmod.sub_spectators[spec_target] then
			local team = warmod.get_team(mix_player)

			-- Swaps players
			if team == "A" then
				warmod.table_remove(warmod.team_a, mix_player)
				warmod.add_to_team_a(spec_target)

				if warmod.team_a_captain == mix_player then
					warmod.team_a_captain = spec_target
					warmod.sv_msg(player(spec_target, "name") .. 
						" is the new captain of " .. warmod.team_a_name)
				end
			else 
				warmod.table_remove(warmod.team_b, mix_player)
				warmod.add_to_team_b(spec_target)

				if warmod.team_b_captain == mix_player then
					warmod.team_b_captain = spec_target
					warmod.sv_msg(player(spec_target, "name") .. 
						" is the new captain of " .. warmod.team_b_name)
				end
			end

			-- Place player
			if warmod.state < warmod.STATES.SECOND_HALF then
				if team == "A" then
					parse("maket " .. spec_target)
				else
					parse("makect " .. spec_target)
				end
			else
				if team == "A" then
					parse("makect " .. spec_target)
				else
					parse("maket " .. spec_target)
				end
			end

			parse("makespec " .. mix_player)
			parse('setmoney ' .. spec_target .. ' ' .. player(mix_player, "money"))

			-- Swap done
			warmod.sub_players[mix_player] = nil
			warmod.sub_spectators[spec_target] = nil
		end
	end

	warmod.forced_switch = false
end