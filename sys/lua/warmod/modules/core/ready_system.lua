--[[---------------------------------------------------------------------------
	Warmod Project
	Dev(s): x[N]ir, Hajt
	File: modules/core/ready_system.lua
	Description: mix preparation functions
--]]---------------------------------------------------------------------------

warmod.ready = {}
warmod.ready_access = true

function warmod.update_ready_list()
	if warmod.started then return end

	warmod.clear_all_texts()

	local k = 1

	warmod.hudtxt(0, "----- Ready -----", 550, 70)

	for k, v in pairs(warmod.ready) do
		warmod.hudtxt(k, player(v, "name"), 550, 70 + k * 15)
		k = k + 1
	end
end

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

function warmod.format_spectator_name(name)
	for i = 1, #warmod.FORBIDDEN_CHARACTERS do
		name = string.gsub(name, warmod.FORBIDDEN_CHARACTERS[i], "")
	end
	
	return name
end

function warmod.init_spectators_menu()
	local button_index = 1
	local buttons = warmod.MENUS["Spectators"].buttons

	for k, v in pairs(ready) do
		buttons[button_index] = {
			label = warmod.format_spectator_name(player(v, "name")),
			func = warmod.event_choose_spectator,
			args = {player = v, index = button_index},
		}

		button_index = button_index + 1
	end
end