--[[---------------------------------------------------------------------------
	Warmod Project
	Dev(s): x[N]ir, Hajt
	File: modules/player/hooks.lua
	Description: client sided hooks
--]]---------------------------------------------------------------------------

warmod.connected   = {}
warmod.mute        = {}
warmod.dmg         = {}
warmod.total_dmg   = {}
warmod.player_menu = {}

function warmod.join(id)
	warmod.update_ready_list()

	msg2(id, "\169255000000Connected to \169255255255" .. game("sv_name"))
	msg2(id, "\169255000000Warmod Settings \169000255000[F2]")
	msg2(id, "\169255000000Website: \169255255000" .. warmod.WEBSITE)

	warmod.connected[id] = true
	warmod.mute[id]      = false
	warmod.dmg[id]       = {}
	warmod.total_dmg[id] = {}
end

function warmod.leave(id, reason)
	if warmod.started then
		if warmod.state == warmod.STATES.PRE_CAPTAINS_KNIFE or 
			warmod.state == warmod.STATES.CAPTAINS_KNIFE then
			if warmod.team_a_captain == id or warmod.team_b_captain == id then
				warmod.cancel_mix("A captain left during knife")
			end
		elseif warmod.state == warmod.STATES.PRE_TEAM_SELECTION or 
			warmod.state == warmod.STATES.TEAM_A_SELECTION or 
			warmod.state == warmod.STATES.TEAM_B_SELECTION then
			if warmod.team_a_captain == id or warmod.team_b_captain == id then
				warmod.cancel_mix("A captain left during team selection")
			end
		elseif warmod.state == warmod.STATES.PRE_MAP_VETO or warmod.state == warmod.STATES.MAP_VETO or 
			warmod.state == warmod.STATES.WINNER_VETO or warmod.state == warmod.STATES.LOOSER_VETO then
			if id == warmod.veto_winner or id == warmod.veto_looser then
				cancel_mix("A veto chooser left !")
			end
		end
	end

	warmod.set_player_notready(id)
	warmod.connected[id] = false
	warmod.dmg[id]       = nil
	warmod.total_dmg[id] = nil
	--warmod.mute[id]=nil
end

function warmod.die(victim)
end

function warmod.name(id, oldname, newname)
end

function warmod.say(id,txt)
	local ret = warmod.command_check(id,txt)

	if ret == 1 then
		return 1
	elseif warmod.mute[id] == true then
		msg2(id,"\169255150150[ERROR]:\169255255255 You are muted")
		return 1
	end
end



function warmod.hit(victim, source)
end

function warmod.team(id, team, skin)
	if warmod.teams_locked and not warmod.forced_switch then
		msg("\169255000000You can't join now !")
		return 1
	end
end

function warmod.menu(id, title, button)
	local menu = warmod.player_menu[id]

	if button == 0 then
		warmod.player_menu[id] = nil
	elseif button == 8 then
		menu.page = menu.page - 1
		warmod.display_menu(id)
	elseif button == 9 then
		menu.page = menu.page + 1
		warmod.display_menu(id)
	else
		local index = (menu.page - 1) * 7 + button
		local b     = menu.buttons[index]
		local func  = b.func

		func(id, b.args)
	end
end

function warmod.bombplant(id, x, y)
	if warmod.started then
		if warmod.state == warmod.STATES.CAPTAINS_KNIFE or 
			warmod.state == warmod.STATES.KNIFE_ROUND or 
			warmod.state == warmod.STATES.MAP_VETO then
			msg2(id, "\169255000000[ERROR]: You can't plant the bomb now !")
			return 1
		end
	end
end

function warmod.bombdefuse(id) end

function warmod.spawn(id)
	if warmod.started then
		if warmod.state == warmod.STATES.CAPTAINS_KNIFE or
			warmod.state == warmod.STATES.MAP_VETO or
			warmod.state == warmod.STATES.KNIFE_ROUND  then
			parse("setmoney " .. id .. " 0")
			return "x"
		end
	end
end

function warmod.serveraction(id, action)
	if action == 1 then
		warmod.open_main_menu(id)
	end
end