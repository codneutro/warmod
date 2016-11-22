--[[---------------------------------------------------------------------------
	Warmod Project
	Dev(s): x[N]ir, Hajt
	File: modules/menu/events.lua
	Description: Buttons functions
--]]---------------------------------------------------------------------------

function warmod.event_change_menu(id, args)
	-- either already defined or dynamically passed from args table
	local menu = args.static and warmod.MENUS[args.menu] or args.menu
	menu.page = 1
	menu.opened = false

	warmod.player_menu[id] = menu

	if args.display then
		warmod.display_menu(id)
	end
end

function warmod.event_main_menu(id, args)
	if args == 1 then
		local buttons = warmod.MENUS["Team Organization"].buttons

		buttons[1].label = "Current Teams"
		buttons[2].label = "Random Captains"
		buttons[3].label = "Random Teams"

		if warmod.team_organization == 1 then
			buttons[1].label = "(" .. buttons[1].label .. ")"
		elseif warmod.team_organization == 2 then
			buttons[2].label = "(" .. buttons[2].label .. ")"
		else
			buttons[3].label = "(" .. buttons[3].label .. ")"
		end

		warmod.event_change_menu(id, warmod.MENU_ARGS[2])
	elseif args == 2 then
		local buttons = warmod.MENUS["Team Size"].buttons

		for i = 1, 5 do
			if warmod.team_size == i then
				buttons[i].label = "(" .. " " .. ")"
			else
				buttons[i].label = " "
			end
		end

		warmod.event_change_menu(id, warmod.MENU_ARGS[3])
	elseif args == 3 then
		local buttons = warmod.MENUS["MR"].buttons

		buttons[1].label = "10"
		buttons[2].label = "12"
		buttons[3].label = "15"
		buttons[4].label = "2" -- TODO: remove this later

		if warmod.mr == 10 then
			buttons[1].label = "(" .. buttons[1].label .. ")"
		elseif warmod.mr == 12 then
			buttons[2].label = "(" .. buttons[2].label .. ")"
		elseif warmod.mr == 15 then
			buttons[3].label = "(" .. buttons[3].label .. ")"
		else -- TODO: remove this later
			buttons[4].label = "(" .. buttons[4].label .. ")"
		end

		warmod.event_change_menu(id, warmod.MENU_ARGS[10])
	elseif args == 4 then
		local buttons = warmod.MENUS["Map"].buttons

		buttons[1].label = "Current"
		buttons[2].label = "Vote"
		buttons[3].label = "Veto"

		if warmod.map_mode == warmod.MAP_MODE.CURRENT then
			buttons[1].label = "(" .. buttons[1].label .. ")"
		elseif warmod.map_mode == warmod.MAP_MODE.VOTE then
			buttons[2].label = "(" .. buttons[2].label .. ")"
		else
			buttons[3].label = "(" .. buttons[3].label .. ")"
		end

		warmod.event_change_menu(id, warmod.MENU_ARGS[4])
	elseif args == 5 then
		local buttons = warmod.MENUS["Knife"].buttons

		buttons[1].label = "Enabled"
		buttons[2].label = "Disabled"

		if warmod.knife_round_enabled then
			buttons[1].label = "(" .. buttons[1].label .. ")"
		else
			buttons[2].label = "(" .. buttons[2].label .. ")"
		end

		warmod.event_change_menu(id, warmod.MENU_ARGS[5])
	end
end

function warmod.event_change_settings(id, args)
	if not warmod.is_admin(id) then 
		msg2(id, "\169255000000[ERROR]: You do not have permission to modify the settings")
		return
	end

	if warmod.started then 
		msg2(id, "\169255000000[ERROR]: You can't change settings now !")
		return
	end

	if args.setting == "size" then
		-- Random Captains are useless for 1v1
		if warmod.team_organization == 2 and args.value == 1 then
			msg2(id, "\169255000000[ERROR]: You can't set 1 player per team " ..
				"for this team mode !")
			return
		end
		
		warmod.team_size = args.value
		warmod.total_players = warmod.team_size * 2
	elseif args.setting == "knife" then
		warmod.knife_round_enabled = args.value
	elseif args.setting == "map" then
		warmod.map_mode = args.value
	elseif args.setting == "organization" then
		-- Random Captains are useless for 1v1
		if args.value == 2 and warmod.team_size == 1 then 
			msg2(id, "\169255000000[ERROR]: You can't set this team mode " ..
				"for 2 players only !")
			return
		end
		
		warmod.team_organization = args.value
	elseif args.setting == "mr" then
		warmod.mr = args.value
	end

	local players = player(0, "table")

	warmod.hudtxt(0, "----- READY " .. #warmod.ready .. "/" ..
				warmod.total_players .." -----", 550, 70)
	warmod.check_ready_list()
	warmod.open_main_menu(id)
end

function warmod.event_vote_map(id, map)
	if not warmod.started then
		return
	end
	
	local votes = warmod.map_votes[map]
	
	votes[#votes + 1] = id
	
	warmod.sv_msg(player(id, "name") .. " has voted for " .. map)
end

function warmod.event_veto(id, map)
	-- Avoid late/undesired clicks
	if warmod.state == warmod.STATES.WINNER_VETO then
		if id ~= warmod.veto_winner then
			return
		end
	elseif warmod.state == warmod.STATES.LOOSER_VETO then
		if id ~= warmod.veto_looser then
			return
		end
	else
		return
	end
	
	if not warmod.timer_reached then
		freetimer("warmod.timer_check_veto")
	end
	
	local buttons = warmod.MENUS["Veto"].buttons
	
	for i = 1, #buttons do
		if buttons[i].label == map then
			table.remove(buttons, i)
			break
		end
	end
	
	if player(id, "exists") then
		warmod.sv_msg(player(id, "name") .. " has vetoed " .. map)
	end
	
	if #buttons == 1 then
		warmod.sv_msg(buttons[1].label .. " has won !")
		timer(3000, "parse", 'map "' .. buttons[1].label .. '"')
	else
		-- Still some maps to veto 
		if id == warmod.veto_winner then
			warmod.event_change_menu(warmod.veto_looser, warmod.MENU_ARGS[8])
			warmod.state = warmod.STATES.LOOSER_VETO
		else
			warmod.event_change_menu(warmod.veto_winner, warmod.MENU_ARGS[8])
			warmod.state = warmod.STATES.WINNER_VETO
		end
		
		timer(5000, "warmod.timer_check_veto")
	end
end

function warmod.event_side_vote(id, swap)
	if not warmod.started or warmod.state ~= warmod.STATES.KNIFE_ROUND then
		return
	end

	if swap then
		warmod.swap_votes[#warmod.swap_votes + 1] = id
	else
		warmod.stay_votes[#warmod.stay_votes + 1] = id
	end
end

function warmod.event_choose_spectator(id, args)
	if not warmod.started or id ~= warmod.team_selector or 
			(warmod.state ~= warmod.STATES.TEAM_A_SELECTION and
			warmod.state ~= warmod.STATES.TEAM_B_SELECTION) then
		return
	end

	if not warmod.timer_reached then
		freetimer("warmod.timer_check_selection")
	end
	
	warmod.forced_switch = true
	
	local buttons = warmod.MENUS["Spectators"].buttons
	buttons[args.index].label = "(" .. buttons[args.index].label .. ")"

	if warmod.state == warmod.STATES.TEAM_A_SELECTION then
		warmod.add_to_team_a(args.player)
		parse("maket " .. args.player)
		warmod.update_team_selection_board()
	
		if #warmod.team_b < warmod.team_size then
			warmod.state = warmod.STATES.TEAM_B_SELECTION
			warmod.team_selector = warmod.team_b_captain
			warmod.event_change_menu(warmod.team_selector, warmod.MENU_ARGS[6])
			timer(5000, "warmod.timer_check_selection")
		else
			if warmod.knife_round_enabled then
				warmod.state = warmod.STATES.PRE_KNIFE_ROUND
			else
				warmod.state = warmod.STATES.PRE_FIRST_HALF
			end

			warmod.sv_msg("Team Selection is now finished")
			warmod.safe_restart()
		end
	elseif warmod.state == warmod.STATES.TEAM_B_SELECTION then
		warmod.add_to_team_b(args.player)
		parse("makect " .. args.player)
		warmod.update_team_selection_board()
	
		if #warmod.team_a < warmod.team_size then
			warmod.state = warmod.STATES.TEAM_A_SELECTION
			warmod.team_selector = warmod.team_a_captain
			warmod.event_change_menu(warmod.team_selector, warmod.MENU_ARGS[6])
			timer(5000, "warmod.timer_check_selection")
		else
			if warmod.knife_round_enabled then
				warmod.state = warmod.STATES.PRE_KNIFE_ROUND
			else
				warmod.state = warmod.STATES.PRE_FIRST_HALF
			end
			
			warmod.sv_msg("Team Selection is now finished")
			warmod.safe_restart()
		end
	end
	
	warmod.forced_switch = false
end