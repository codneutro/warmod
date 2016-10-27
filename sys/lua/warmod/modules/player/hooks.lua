--[[---------------------------------------------------------------------------
	Warmod Project
	Dev(s): x[N]ir, Hajt
	File: modules/player/hooks.lua
	Description: client sided hooks
--]]---------------------------------------------------------------------------

warmod.connected   = {}
warmod.mute        = {}
warmod.player_menu = {}

function warmod.join(id)
	warmod.update_ready_list()

	msg2(id, "\169255000000Connected to \169255255255" .. game("sv_name"))
	msg2(id, "\169255000000Warmod Settings \169000255000[F2]")
	msg2(id, "\169255000000Website: \169255255000" .. warmod.WEBSITE)

	warmod.connected[id] = true
	warmod.mute[id]      = false
	warmod.init_stats(id, true)
end

-- Reasons: 2 Kick / Banned 6 / Normal 0 / Timeout 1
function warmod.leave(id, reason)
	-- Canceling the join process (stop download files) will trigger this hook
	-- even if the player isn't fully connected :/
	if not warmod.connected[id] then
		return
	end

	if warmod.started and warmod.is_playing(id) then
		if warmod.state == warmod.STATES.PRE_CAPTAINS_KNIFE or 
				warmod.state == warmod.STATES.CAPTAINS_KNIFE then

			if warmod.team_a_captain == id or warmod.team_b_captain == id then
				warmod.cancel_mix("A captain left during knife")
			elseif warmod.table_contains(warmod.ready, id) then
				warmod.cancel_mix("A player left during knife")
			end
		elseif warmod.state == warmod.STATES.PRE_TEAM_SELECTION or 
				warmod.state == warmod.STATES.TEAM_A_SELECTION or 
				warmod.state == warmod.STATES.TEAM_B_SELECTION then

			if warmod.team_a_captain == id or 
				warmod.team_b_captain == id then
				warmod.cancel_mix("A captain left during team selection")
			elseif warmod.table_contains(warmod.ready, id) then
				warmod.cancel_mix("A player left during team selection")
			end
		elseif warmod.state == warmod.STATES.PRE_MAP_VETO or 
				warmod.state == warmod.STATES.MAP_VETO or 
				warmod.state == warmod.STATES.WINNER_VETO or 
				warmod.state == warmod.STATES.LOOSER_VETO then

			if id == warmod.veto_winner or id == warmod.veto_looser then
				warmod.cancel_mix("A veto chooser left !")
			end
		elseif warmod.state >= warmod.STATES.PRE_KNIFE_ROUND and 
				warmod.state <= warmod.STATES.SECOND_HALF then

			if id == warmod.team_a_captain then
				warmod.new_captain("A", id)
			elseif id == warmod.team_b_captain then
				warmod.new_captain("B", id)
			end

			local team = warmod.get_team(id)

			if team == "A" then
				warmod.table_remove(warmod.team_a, id)
			else
				warmod.table_remove(warmod.team_b, id)
			end

			-- Intentional leave
			if reason == 1 then
				warmod.ban(id, "Leaving during a match = 1 Day Ban")
			-- Timed out
			elseif reason == 2 then
				local ip = player(id, "ip")

				if team == "A" then
					warmod.team_a_leavers[#warmod.team_a_leavers + 1] = ip
				else
					warmod.team_b_leavers[#warmod.team_b_leavers + 1] = ip
				end

				warmod.sv_msg(player(id, "name") .. 
					" has 3 minutes to reconnect !")
				timer(180000, "warmod.timer_timeout", team .. ip)
			end

			if team == "A" then
				if #warmod.team_a == 0 then
					if warmod.state > warmod.STATES.FIRST_HALF then
						warmod.forfeit_win(2)
					else
						warmod.cancel_mix("Rage quit")
					end
				end
			else
				if #warmod.team_b == 0 then
					if warmod.state > warmod.STATES.FIRST_HALF then
						warmod.forfeit_win(1)
					else
						warmod.cancel_mix("Rage quit")
					end
				end
			end
		end
	end

	warmod.set_player_notready(id)
	warmod.connected[id]     = false
	warmod.dmg[id]           = nil
	warmod.total_dmg[id]     = nil
	warmod.bomb_plants[id]   = nil
	warmod.bomb_defusals[id] = nil
	warmod.total_kills[id]   = nil
	warmod.total_deaths[id]  = nil
	warmod.double[id]        = nil  
	warmod.triple[id]        = nil
	warmod.quadra[id]        = nil
	warmod.aces[id]          = nil
	warmod.total_mvp[id]     = nil
	warmod.mix_dmg[id]       = nil
	warmod.tmp_bp[id]        = nil
	warmod.tmp_bd[id]        = nil
	warmod.tmp_k[id]         = nil
	warmod.tmp_d[id]         = nil
	warmod.tmp_dk[id]        = nil
	warmod.tmp_tk[id]        = nil
	warmod.tmp_qk[id]        = nil
	warmod.tmp_aces[id]      = nil
	warmod.tmp_mvp[id]       = nil
	warmod.tmp_mix_dmg[id]   = nil
end

function warmod.kill(killer, victim)
	if not warmod.started or (warmod.state ~= warmod.STATES.FIRST_HALF and 
			warmod.state ~= warmod.STATES.SECOND_HALF) then
		return
	end

	warmod.tmp_k[killer] = warmod.tmp_k[killer] + 1
	warmod.tmp_d[victim] = warmod.tmp_d[victim] + 1
end

function warmod.name(id, oldname, newname)
	if warmod.mute[id] == true then
		msg2(id,"\169255150150[ERROR]:\169255255255 You are muted")
		return 1
	end
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

function warmod.hit(id, source, weapon, hpdmg)
	if not warmod.started or (warmod.state ~= warmod.STATES.FIRST_HALF and 
			warmod.state ~= warmod.STATES.SECOND_HALF) then
		return
	end

	if source ~= 0 and player(source, "team") ~= player(id, "team") then
		warmod.dmg[source] = warmod.dmg[source] + hpdmg
	end
end

function warmod.team(id, team, skin)
	if warmod.started then
		if #warmod.team_a_leavers > 0 or #warmod.team_b_leavers > 0 then
			local ip = player(id, "ip")

			if warmod.state > warmod.STATES.KNIFE_ROUND and 
					warmod.state < warmod.STATES.PRE_FIRST_HALF then
				if warmod.table_contains(warmod.team_a_leavers, ip) and team == 1 then
					warmod.add_to_team_a(id)
					warmod.table_remove(warmod.team_a_leavers, ip)
					freetimer("warmod.timer_timeout", "A" .. ip)
					warmod.sv_msg(player(id, "name") .. " has joined back " .. 
						warmod.team_a_name)
					return 0
				elseif warmod.table_contains(warmod.team_b_leavers, ip) and team == 2 then
					warmod.add_to_team_b(id)
					warmod.table_remove(warmod.team_b_leavers, ip)
					freetimer("warmod.timer_timeout", "B" .. ip)
					warmod.sv_msg(player(id, "name") .. " has joined back " .. 
						warmod.team_b_name)
					return 0
				else
					return 1
				end
			elseif warmod.state == warmod.STATES.PRE_SECOND_HALF or 
					warmod.state == warmod.STATES.SECOND_HALF then
				if warmod.table_contains(warmod.team_a_leavers, ip) and team == 2 then
					warmod.add_to_team_a(id)
					warmod.table_remove(warmod.team_a_leavers, ip)
					freetimer("warmod.timer_timeout", "A" .. ip)
					warmod.sv_msg(player(id, "name") .. " has joined back " .. 
						warmod.team_a_name)
					return 0
				elseif warmod.table_contains(warmod.team_b_leavers, ip) and team == 1 then
					warmod.add_to_team_b(id)
					warmod.table_remove(warmod.team_b_leavers, ip)
					freetimer("warmod.timer_timeout", "B" .. ip)
					warmod.sv_msg(player(id, "name") .. " has joined back " .. 
						warmod.team_b_name)
					return 0
				else
					return 1
				end
			end
		end

		if warmod.teams_locked and not warmod.forced_switch then
			msg2(id, "\169255000000Team change is disabled !")
			return 1
		end
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
		elseif warmod.state == warmod.STATES.FIRST_HALF or 
			warmod.state == warmod.STATES.SECOND_HALF then
			warmod.tmp_bp[id] = warmod.tmp_bp[id] + 1
		end
	end
end

function warmod.bombdefuse(id) 
	if warmod.started then
		if warmod.state == warmod.STATES.FIRST_HALF or 
			warmod.state == warmod.STATES.SECOND_HALF then
			warmod.tmp_bd[id] = warmod.tmp_bd[id] + 1
		end
	end
end

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