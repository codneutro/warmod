--[[---------------------------------------------------------------------------
	Warmod Project
	Dev(s): x[N]ir, Hajt
	File: modules/core/stats.lua
	Description: Player stats tracker
--]]---------------------------------------------------------------------------

-- Round variables
warmod.dmg           = {}
warmod.total_dmg     = {}
warmod.round_kills   = {}
-- Mix Stats
-- These variables keeps the real values
warmod.bomb_plants   = {}
warmod.bomb_defusals = {}
warmod.total_kills   = {}
warmod.total_deaths  = {}
warmod.double        = {}
warmod.triple        = {}
warmod.quadra        = {}
warmod.aces          = {}
warmod.total_mvp     = {}
warmod.mix_dmg       = {}
-- We have to use temp variables
-- In case of a half restart
warmod.tmp_bp        = {}
warmod.tmp_bd        = {}
warmod.tmp_k         = {}
warmod.tmp_d         = {}
warmod.tmp_dk        = {}
warmod.tmp_tk        = {}
warmod.tmp_qk        = {}
warmod.tmp_aces      = {}
warmod.tmp_mvp       = {}
warmod.tmp_mix_dmg   = {}

-- Initialize all / temporary player stats
function warmod.init_stats(id, all)
	-- Must we initialize real stats ?
	if all then
		warmod.total_dmg[id]           = 0
		warmod.bomb_plants[id]         = 0
		warmod.bomb_defusals[id]       = 0
		warmod.total_kills[id]         = 0
		warmod.total_deaths[id]        = 0
		warmod.double[id]              = 0
		warmod.triple[id]              = 0
		warmod.quadra[id]              = 0
		warmod.aces[id]                = 0
		warmod.total_mvp[id]           = 0
		warmod.mix_dmg[id]             = 0
	end

	-- Temporary variables
	warmod.dmg[id]			 = 0
	warmod.round_kills[id]   = 0
 	warmod.tmp_bp[id]        = 0
	warmod.tmp_bd[id]        = 0
	warmod.tmp_k[id]         = 0
	warmod.tmp_d[id]         = 0
	warmod.tmp_dk[id]        = 0
	warmod.tmp_tk[id]        = 0
	warmod.tmp_qk[id]        = 0
	warmod.tmp_aces[id]      = 0
	warmod.tmp_mvp[id]       = 0
	warmod.tmp_mix_dmg[id]   = 0
end

-- Resets players stats on each round
function warmod.reset_stats(all)
	local players = player(0, "table")

	
	if all then -- First round of a half
		for k, id in pairs(players) do
			warmod.total_dmg[id] = 0
			warmod.init_stats(id)
		end
	else -- Classic rounds except the first round
		for k, id in pairs(players) do
			warmod.dmg[id] = 0
			warmod.round_kills[id] = 0
		end
	end
end

-- Displays and updates mvp stats
function warmod.display_mvp()
	local max_dmg, mvp

	for id, dmg in pairs(warmod.dmg) do
		if dmg > 0 and (not max_dmg or dmg > max_dmg) then
			mvp = id
			max_dmg = dmg
		end
	end

	if not mvp then
		return
	end

	warmod.tmp_mvp[mvp] = warmod.tmp_mvp[mvp] + 1

	msg("\169255255255[DMG] MVP " .. player(mvp, "name") .. 
		" with " .. max_dmg .. " HP")

	local players = player(0, "table")

	for k, id in pairs(players) do
		if player(id, "team") > 0 then
			warmod.total_dmg[id] = warmod.total_dmg[id] + warmod.dmg[id]
			warmod.tmp_mix_dmg[id] = warmod.total_dmg[id]
			msg2(id, "\169255255255[DMG] This round: " .. warmod.dmg[id] .. " HP")
			msg2(id, "\169255255255[DMG] Total: " .. warmod.total_dmg[id] .. " HP")
		end
	end
end

-- Save temporary stats of the first half only !!
function warmod.update_stats_on_half()
	local players = player(0, "table")

	for k, id in pairs(players) do
		warmod.bomb_plants[id]         = warmod.tmp_bp[id]
		warmod.bomb_defusals[id]       = warmod.tmp_bd[id]
		warmod.total_kills[id]         = warmod.tmp_k[id]
		warmod.total_deaths[id]        = warmod.tmp_d[id]
		warmod.double[id]        	   = warmod.tmp_dk[id]
		warmod.triple[id]              = warmod.tmp_tk[id]
		warmod.quadra[id]              = warmod.tmp_qk[id]
		warmod.aces[id]                = warmod.tmp_aces[id]
		warmod.total_mvp[id]           = warmod.tmp_mvp[id]
		warmod.mix_dmg[id]             = warmod.tmp_mix_dmg[id]
	end
end

-- Updates multiple kills
function warmod.update_kills()
	local players = player(0, "table")

	for k, id in pairs(players) do
		local kills = warmod.round_kills[id]

		if kills > 4 then
			warmod.tmp_aces[id] = warmod.tmp_aces[id] + 1
		elseif kills > 3 then
			warmod.tmp_qk[id] = warmod.tmp_qk[id] + 1
		elseif kills > 2 then
			warmod.tmp_tk[id] = warmod.tmp_tk[id] + 1
		elseif kills > 1 then
			warmod.tmp_dk[id] = warmod.tmp_dk[id] + 1
		end

		warmod.tmp_k[id] = warmod.tmp_k[id] + kills
	end
end

-- Prints the player's mix stats
function warmod.print_stats(id, team_a)
	local usgn                = player(id, "usgn")
	local ip                  = player(id, "ip")
	local name                = player(id, "name")
	local mix_dmg             = warmod.mix_dmg[id] + warmod.tmp_mix_dmg[id]
	local total_kills         = warmod.total_kills[id] + warmod.tmp_k[id]
	local total_deaths        = warmod.total_deaths[id] + warmod.tmp_d[id]
	local bomb_plants         = warmod.bomb_plants[id] + warmod.tmp_bp[id]
	local bomb_defusals       = warmod.bomb_defusals[id] + warmod.tmp_bd[id]
	local double              = warmod.double[id] + warmod.tmp_dk[id]
	local triple              = warmod.triple[id] + warmod.tmp_tk[id]
	local quadra              = warmod.quadra[id] + warmod.tmp_qk[id]
	local aces                = warmod.aces[id] + warmod.tmp_aces[id]
	local total_mvp           = warmod.total_mvp[id] + warmod.tmp_mvp[id]

	print(usgn, ip, name, team_a, mix_dmg, total_kills, total_deaths,
		bomb_plants, bomb_defusals, double, triple, quadra, aces, total_mvp)
end

-- Prints all mix stats
function warmod.log_stats()
	print(warmod.team_a_name, warmod.team_b_name, warmod.CURRENT_MAP, warmod.team_size,
		warmod.team_a_t_score, warmod.team_b_ct_score, warmod.team_a_ct_score, warmod.team_b_t_score)

	for _, id in pairs(warmod.team_a) do
		warmod.print_stats(id, 1)
	end

	for _, id in pairs(warmod.team_b) do
		warmod.print_stats(id, 0)
	end
end

-- Set all stats to nil
function warmod.set_stats_nil(id)
	warmod.connected[id]      = false
	warmod.dmg[id]            = nil
	warmod.round_kills[id]    = nil
	warmod.total_dmg[id]      = nil
	warmod.bomb_plants[id]    = nil
	warmod.bomb_defusals[id]  = nil
	warmod.total_kills[id]    = nil
	warmod.total_deaths[id]   = nil
	warmod.double[id]         = nil  
	warmod.triple[id]         = nil
	warmod.quadra[id]         = nil
	warmod.aces[id]           = nil
	warmod.total_mvp[id]      = nil
	warmod.mix_dmg[id]        = nil
	warmod.tmp_bp[id]         = nil
	warmod.tmp_bd[id]         = nil
	warmod.tmp_k[id]          = nil
	warmod.tmp_d[id]          = nil
	warmod.tmp_dk[id]         = nil
	warmod.tmp_tk[id]         = nil
	warmod.tmp_qk[id]         = nil
	warmod.tmp_aces[id]       = nil
	warmod.tmp_mvp[id]        = nil
	warmod.tmp_mix_dmg[id]    = nil
	warmod.sub_spectators[id] = nil
	warmod.sub_players[id]    = nil
end