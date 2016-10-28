--[[---------------------------------------------------------------------------
	Warmod Project
	Dev(s): x[N]ir, Hajt
	File: modules/core/setup.lua
	Description: mix setup
--]]---------------------------------------------------------------------------

warmod.started             = false
warmod.teams_locked        = false
warmod.forced_switch       = false
warmod.errors              = 0
warmod.mr                  = 15
warmod.team_size           = 5
warmod.total_players       = warmod.team_size * 2
warmod.knife_round_enabled = true
warmod.map_mode = warmod.MAP_MODE.CURRENT
warmod.state = warmod.STATES.NONE
warmod.knife_winner = 0
warmod.team_selector = 0
warmod.team_organization = 1
warmod.map_votes = {}
warmod.veto_player_1 = 0
warmod.veto_player_2 = 0
warmod.veto_winner = 0
warmod.veto_looser = 0
warmod.swap_votes = {}
warmod.stay_votes = {}
warmod.team_a_captain = 0
warmod.team_a_name = "Team A"
warmod.team_a = {}
warmod.team_a_t_score = 0
warmod.team_a_ct_score = 0
warmod.team_b_captain = 0
warmod.team_b_name = "Team B"
warmod.team_b = {}
warmod.team_b_t_score = 0
warmod.team_b_ct_score = 0
warmod.team_a_leavers = {}
warmod.team_b_leavers = {}
warmod.sub_players = {}
warmod.sub_spectators = {}

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
	warmod.team_a_leavers = {}
	warmod.team_b_leavers = {}
	warmod.team_a_t_score = 0
	warmod.team_a_ct_score = 0
	warmod.team_b_t_score = 0
	warmod.team_b_ct_score = 0
	warmod.sub_players = {}
	warmod.sub_spectators = {}
	
	local veto_buttons = {}
	
	for k, _ in pairs(warmod.map_votes) do
		warmod.map_votes[k] = {}
		veto_buttons[#veto_buttons + 1] = {
			label = k, func = warmod.event_veto, args = k
		}
	end
	
	warmod.MENUS["Veto"].buttons = veto_buttons
end

function warmod.cancel_mix(reason)
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

function warmod.add_to_team_a(id)
	warmod.team_a[#warmod.team_a + 1] = id
	warmod.table_remove(warmod.ready, id)
end

function warmod.add_to_team_b(id)
	warmod.team_b[#warmod.team_b + 1] = id
	warmod.table_remove(warmod.ready, id)
end

function warmod.is_playing(id)
	return warmod.table_contains(warmod.team_a, id) or
		warmod.table_contains(warmod.team_b, id)
end

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
	local tmp = warmod.team_a_name

	-- Teams names
	warmod.team_a_name = warmod.team_b_name
	warmod.team_b_name = tmp
	-- Teams Captains
	tmp = warmod.team_a_captain
	warmod.team_a_captain = warmod.team_b_captain
	warmod.team_b_captain = tmp
	-- Team players
	tmp = warmod.team_a 
	warmod.team_a = warmod.team_b
	warmod.team_b = tmp
end

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
end

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