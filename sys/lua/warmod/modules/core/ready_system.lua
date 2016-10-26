--[[---------------------------------------------------------------------------
	Warmod Project
	Dev(s): x[N]ir, Hajt
	File: modules/core/ready_system.lua
	Description: mix preparation functions
--]]---------------------------------------------------------------------------

warmod.ready = {}		   -- Contains players IDs who are ready
warmod.ready_access = true -- Whether the ready commands are allowed

-- Graphic refresh
function warmod.update_ready_list()
	if warmod.started then 
		return 
	end

	warmod.clear_all_texts()

	local k = 1

	warmod.hudtxt(0, "----- Ready -----", 550, 70)

	for k, v in pairs(warmod.ready) do
		warmod.hudtxt(k, player(v, "name"), 550, 70 + k * 15)
		k = k + 1
	end
end

-- Can we start a mix ?
function warmod.check_ready_list()
	if #warmod.ready == warmod.total_players then
		warmod.started = true
		warmod.ready_access = false
		warmod.clear_all_texts()
		
		msg("\169255255255Starting Map Organization in \1692550000003 seconds !@C")

		if warmod.map_mode == warmod.MAP_MODE.VOTE then 
			parse("sv_sound hajt/countdown.ogg") 
		end

		timer(3000, "warmod.timer_map_organization")
	end 
end

function warmod.set_player_ready(id)
	if not warmod.table_contains(warmod.ready, id) and 
			#warmod.ready < warmod.total_players then
		warmod.ready[#warmod.ready + 1] = id
		warmod.update_ready_list()
		warmod.check_ready_list()
	end
end

function warmod.set_player_notready(id)
	if warmod.table_contains(warmod.ready, id) then
		warmod.table_remove(warmod.ready, id)
		warmod.update_ready_list()
	end
end

function warmod.get_random_ready_player()
	return warmod.ready[math.random(#warmod.ready)]
end

-- Removes some characters which could make the buttons disabled/bugged
function warmod.format_spectator_name(name)
	for i = 1, #warmod.FORBIDDEN_CHARACTERS do
		name = string.gsub(name, warmod.FORBIDDEN_CHARACTERS[i], "")
	end
	
	return name
end

-- Dynamically update the spec menu from the ready list
function warmod.init_spectators_menu()
	local button_index = 1
	local buttons = warmod.MENUS["Spectators"].buttons

	for k, v in pairs(warmod.ready) do
		buttons[button_index] = {
			label = warmod.format_spectator_name(player(v, "name")),
			func = warmod.event_choose_spectator,
			args = {player = v, index = button_index},
		}

		button_index = button_index + 1
	end
end

-- Displays all users one by one during the team selection
function warmod.update_team_selection_board()
	if not warmod.started then
		return
	end

	local txt_id = 1

	warmod.clear_all_texts()

	warmod.hudtxt(0, "Team A", 200, 100)
	warmod.hudtxt(1, "Team B", 400, 100)

	for i = 1, #warmod.team_a do
		txt_id = txt_id + 1

		if i == 1 then
			warmod.hudtxt(txt_id, player(warmod.team_a[i], "name"), 
					200, 115 + i * 15, "255000000")
		else
			warmod.hudtxt(txt_id, player(warmod.team_a[i], "name"), 
					200, 115 + i * 15)
		end
	end

	for i = 1, #warmod.team_b do
		txt_id = txt_id + 1

		if i == 1 then
			warmod.hudtxt(txt_id, player(warmod.team_b[i], "name"), 
					400, 115 + i * 15, "000000255")
		else
			warmod.hudtxt(txt_id, player(warmod.team_b[i], "name"), 
					400, 115 + i * 15)
		end
	end
end