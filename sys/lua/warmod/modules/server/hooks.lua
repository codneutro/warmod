--[[---------------------------------------------------------------------------
	Warmod Project
	Dev(s): x[N]ir, Hajt
	File: modules/server/hooks.lua
	Description: Server sided hooks
--]]---------------------------------------------------------------------------

-- Called on startround
function warmod.startround(mode)
	warmod.log("Startround", "Mode: " .. warmod.get_mode_s(mode) .. 
		", State: " .. warmod.get_mix_state())

	-- This hook is used only during mixes
	if not warmod.started then
		return
	end

	if warmod.state == warmod.STATES.PRE_MAP_VETO then
		warmod.sv_msg("Preparing Map Veto")
		warmod.apply_settings("KNIFE")
		warmod.state = warmod.STATES.MAP_VETO
		warmod.safe_restart()
	elseif warmod.state == warmod.STATES.MAP_VETO then
		if mode == 1 then
			warmod.veto_winner = warmod.veto_player_1
			warmod.veto_looser = warmod.veto_player_2
		elseif mode == 2 then
			warmod.veto_winner = warmod.veto_player_2
			warmod.veto_looser = warmod.veto_player_1
		elseif mode == 5 then
			warmod.sv_msg("Knife for Map Veto !")
		elseif mode == 22 then
			if math.random(2) == 1 then
				warmod.veto_winner = warmod.veto_player_1
				warmod.veto_looser = warmod.veto_player_2
			else
				warmod.veto_winner = warmod.veto_player_2
				warmod.veto_looser = warmod.veto_player_1
			end
		end
		
		if mode == 1 or mode == 2 or mode == 22 then
			warmod.sv_msg(player(warmod.veto_winner, "name") .. 
					" will veto first !")
			warmod.event_change_menu(warmod.veto_winner, 
					warmod.MENU_ARGS[8])
			warmod.state = warmod.STATES.WINNER_VETO
			timer(5000, "warmod.timer_check_veto")
		end
	elseif warmod.state == warmod.STATES.PRE_CAPTAINS_KNIFE then
		warmod.sv_msg("Preparing Captains Knife")
		warmod.apply_settings("KNIFE")
		warmod.state = warmod.STATES.CAPTAINS_KNIFE
		warmod.safe_restart()
	elseif warmod.state == warmod.STATES.CAPTAINS_KNIFE then		
		if mode == 1 then
			warmod.knife_winner = warmod.team_a_captain
			warmod.state = warmod.STATES.TEAM_A_SELECTION
		elseif mode == 2 then
			warmod.knife_winner = warmod.team_b_captain
			warmod.state = warmod.STATES.TEAM_B_SELECTION
		elseif mode == 22 then
			if math.random(2) == 1 then
				warmod.knife_winner = warmod.team_a_captain
				warmod.state = warmod.STATES.TEAM_A_SELECTION
			else
				warmod.knife_winner = warmod.team_b_captain
				warmod.state = warmod.STATES.TEAM_B_SELECTION
			end
		elseif mode == 5 then
			warmod.sv_msg("Captains Knife !")
		end
		
		if mode == 1 or mode == 2 or mode == 22 then
			warmod.sv_msg(player(warmod.knife_winner, "name") .. 
					" has won the knife round !")
			warmod.team_selector = warmod.knife_winner
			
			if #warmod.ready < warmod.total_players - 2 then
				warmod.cancel_mix("Player(s) left during team selection")
			else
				warmod.init_spectators_menu()
				warmod.event_change_menu(warmod.team_selector, 
						warmod.MENU_ARGS[6])
				warmod.update_team_selection_board()
				timer(5000, "warmod.timer_check_selection")
			end
		end
	elseif warmod.state == warmod.STATES.PRE_TEAM_SELECTION then
		warmod.team_selector = warmod.team_b_captain
		warmod.state = warmod.STATES.TEAM_B_SELECTION
		warmod.init_spectators_menu()
		warmod.event_change_menu(warmod.team_selector, 
				warmod.MENU_ARGS[6])
		warmod.update_team_selection_board()
		timer(5000, "warmod.timer_check_selection")
	elseif warmod.state == warmod.STATES.PRE_KNIFE_ROUND then
		warmod.sv_msg("Preparing Knife Round")
		warmod.clear_all_texts()
		warmod.apply_settings("KNIFE")
		warmod.state = warmod.STATES.KNIFE_ROUND
		warmod.safe_restart()
	elseif warmod.state == warmod.STATES.KNIFE_ROUND then
		if mode == 5 then
			warmod.sv_msg("Knife Round !")
		elseif mode == 1 then
			warmod.knife_winner = 1
		elseif mode == 2 then
			warmod.knife_winner = 2
		elseif mode == 22 then
			if math.random(2) == 1 then
				warmod.knife_winner = 1
			else
				warmod.knife_winner = 2
			end
		end
		
		if mode == 1 or mode == 2 or mode == 22 then
			if warmod.knife_winner == 1 then
				local tt = player(0, "team1")
				
				for k, v in pairs(tt) do
					warmod.event_change_menu(v, warmod.MENU_ARGS[9])
				end
			else
				local ct = player(0, "team2")
				
				for k, v in pairs(ct) do
					warmod.event_change_menu(v, warmod.MENU_ARGS[9])
				end
			end
			
			timer(7000, "warmod.timer_check_side_results")
		end
	elseif warmod.state == warmod.STATES.PRE_FIRST_HALF then
		warmod.state = warmod.STATES.FIRST_HALF
		warmod.apply_settings("LIVE")
		warmod.safe_restart()
		warmod.clear_all_texts()
		warmod.sv_msg("Preparing LIVE")
	elseif warmod.state == warmod.STATES.FIRST_HALF then
		if mode == 5 then
			warmod.team_a_t_score  = 0
			warmod.team_b_ct_score = 0
			warmod.rr_votes        = {}
			warmod.reset_stats(true)
			warmod.sv_msg("LIVE \169255255255MR" .. warmod.mr)
		else
			warmod.reset_stats()
		end

		warmod.display_money()
	elseif warmod.state == warmod.STATES.PRE_SECOND_HALF then
		warmod.state = warmod.STATES.SECOND_HALF
		warmod.safe_restart()
		warmod.sv_msg("Preparing LIVE")
	elseif warmod.state == warmod.STATES.SECOND_HALF then
		if mode == 5 then
			warmod.team_a_ct_score = 0
			warmod.team_b_t_score  = 0
			warmod.rr_votes        = {}
			warmod.sv_msg("LIVE")
			warmod.reset_stats(true)
			parse("setteamscores " .. warmod.team_b_ct_score .. " " .. 
				warmod.team_a_t_score)
		else
			warmod.reset_stats()
		end

		warmod.display_money()
	end
end

-- Called on endround
function warmod.endround(mode)
	warmod.log("Endround", "Mode: " .. warmod.get_mode_s(mode) .. 
		", State: " .. warmod.get_mix_state())

	-- This hook is used only during mixes
	if not warmod.started then
		return
	end

	if warmod.state == warmod.STATES.FIRST_HALF then
		-- Score update
		if mode == 1 or mode == 20 or mode == 30 then
			warmod.team_a_t_score = warmod.team_a_t_score + 1
		elseif mode == 2 or mode == 21 or mode == 22 or mode == 31 then
			warmod.team_b_ct_score = warmod.team_b_ct_score + 1
		end

		-- Score display
		warmod.sv_msg(warmod.team_a_name .. " " .. 
				warmod.team_a_t_score .. " - " .. warmod.team_b_ct_score ..
				" " .. warmod.team_b_name)

		if mode == 1 or mode == 2 or mode == 20 or mode == 21 or 
				mode == 22 or mode == 30 or mode == 31 then
			-- Stats update
			warmod.display_mvp()
			warmod.update_kills()

			-- Checking whether the current half is finished
			if (warmod.team_a_t_score + warmod.team_b_ct_score) == warmod.mr then
				warmod.sv_msg("First Half finished !")
				warmod.update_stats_on_half()
				warmod.state = warmod.STATES.PRE_SECOND_HALF
				timer(1000, "warmod.swap_teams")
			end
		end

		warmod.place_subs()
	elseif warmod.state == warmod.STATES.SECOND_HALF then
		-- Score update
		if mode == 1 or mode == 20 or mode == 30 then
			warmod.team_b_t_score = warmod.team_b_t_score + 1
		elseif mode == 2 or mode == 21 or mode == 22 or mode == 31 then
			warmod.team_a_ct_score = warmod.team_a_ct_score + 1
		end

		-- Score display
		warmod.sv_msg(warmod.team_a_name .. " " .. 
				(warmod.team_a_t_score + warmod.team_a_ct_score) .. 
				" - " .. (warmod.team_b_ct_score + warmod.team_b_t_score) 
				.. " " .. warmod.team_b_name)

		-- Stats update
		if mode == 1 or mode == 2 or mode == 20 or mode == 21 or 
				mode == 22 or mode == 30 or mode == 31 then
			warmod.display_mvp()
			warmod.update_kills()
			
			-- Is the mix finished ?
			if warmod.team_a_ct_score > warmod.team_b_ct_score then
				warmod.finish_match(1)
			elseif warmod.team_b_t_score > warmod.team_a_t_score then
				warmod.finish_match(2)
			elseif warmod.team_a_t_score == warmod.team_b_t_score and
					warmod.team_a_ct_score == warmod.team_b_ct_score then
				warmod.finish_match(0)
			end
		end

		warmod.place_subs()
	end
end