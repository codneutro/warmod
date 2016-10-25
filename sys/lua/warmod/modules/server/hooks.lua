--[[---------------------------------------------------------------------------
	Warmod Project
	Dev(s): x[N]ir, Hajt
	File: modules/server/hooks.lua
	Description: server sided hooks
--]]---------------------------------------------------------------------------

function warmod.startround(mode)
	warmod.log("Startround", "Mode: " .. mode .. ", State: " .. warmod.state)

	if warmod.started then
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
				warmod.sv_msg("Map Veto !")
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
			warmod.apply_settings("KNIFE")
			warmod.clear_all_texts()
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
			warmod.clear_all_texts()
			warmod.safe_restart()
			warmod.sv_msg("Preparing LIVE")
		elseif warmod.state == warmod.STATES.FIRST_HALF then
			if mode == 5 then
				warmod.sv_msg("LIVE")
			elseif mode == 1 or mode == 20  then
			elseif mode == 2 or mode == 21 or mode == 22 then

			end
		end
	end
end

function warmod.endround(mode)
	warmod.log("Endround", "Mode: " .. mode .. ", State: " .. warmod.state)
end