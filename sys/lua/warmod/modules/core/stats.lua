--[[---------------------------------------------------------------------------
	Warmod Project
	Dev(s): x[N]ir, Hajt, BCG2000
	File: modules/core/stats.lua
	Description: player stats tracker
--]]---------------------------------------------------------------------------

-- Round variables
warmod.dmg           = {}
warmod.total_dmg     = {}
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

function warmod.init_stats(id, all)
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

function warmod.reset_stats(all)
	local players = player(0, "table")

	-- This way I'm checking the boolean only once
	-- Not on every player since this value can't change
	if all then 
		for k, id in pairs(players) do
			warmod.dmg[id] = 0
			warmod.total_dmg[id] = 0
			warmod.init_stats(id)
		end
	else
		for k, id in pairs(players) do
			warmod.dmg[id] = 0
			warmod.tmp_k[id] = 0
		end
	end
end

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

function warmod.update_kills()
	local players = player(0, "table")

	for k, id in pairs(players) do
		local kills = warmod.tmp_k[id]

		if kills > 4 then
			warmod.tmp_aces[id] = warmod.tmp_aces[id] + 1
		elseif kills > 3 then
			warmod.tmp_qk[id] = warmod.tmp_qk[id] + 1
		elseif kills > 2 then
			warmod.tmp_tk[id] = warmod.tmp_tk[id] + 1
		elseif kills > 1 then
			warmod.tmp_dk[id] = warmod.tmp_dk[id] + 1
		end
	end
end

function warmod.print_stats(id)
	local usgn = player(id, "usgn")
	local identifier = usgn ~= 0 and usgn or player(id, "ip")

	print("*****")

	print(identifier .. " " .. warmod.total_kills[id] .. " " .. 
		warmod.total_deaths[id] .. " " .. warmod.bomb_plants[id] .. " " .. 
		warmod.bomb_defusals[id] .. " " .. warmod.double[id] .. " " .. 
		warmod.triple[id] .. " " .. warmod.quadra[id] .. " " ..
		warmod.aces[id] .. " " .. warmod.total_mvp[id] .. warmod.mix_dmg[id])
	print(identifier .. " " .. (warmod.total_kills[id] + warmod.tmp_k[id]) .. 
		" " .. (warmod.total_deaths[id] + warmod.tmp_d[id]) .. " " .. 
		warmod.bomb_plants[id] .. " " .. warmod.bomb_defusals[id] .. " " .. 
		(warmod.double[id] + warmod.tmp_dk[id]) .. " " .. 
		(warmod.triple[id] + warmod.tmp_tk[id])  .. " " ..
		(warmod.quadra[id] + warmod.tmp_qk[id]) .. " " .. 
		(warmod.aces[id] + warmod.tmp_aces[id])  .. " " ..
		(warmod.total_mvp[id] + warmod.tmp_mvp[id]) .. " " ..
		(warmod.mix_dmg[id] + warmod.tmp_mix_dmg[id])) 
end

function warmod.log_stats()
	print("^Mix")
	print("Date: " .. os.date("%x"))
	print("Teams:" .. warmod.team_a_name .. " vs " .. warmod.team_b_name)
	print("Map: " .. warmod.CURRENT_MAP)
	print("Size: " .. warmod.team_size)
	print("MR: " .. warmod.mr)
	print("First Half: "  .. warmod.team_a_t_score .. " " .. warmod.team_b_ct_score)
	print("Second Half: " .. warmod.team_a_ct_score .. " " .. warmod.team_b_t_score)

	for _, id in pairs(warmod.team_a) do
		warmod.print_stats(id)
	end

	for _, id in pairs(warmod.team_b) do
		warmod.print_stats(id)
	end

	print("-----")

	print("Mix$")
end
