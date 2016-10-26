--[[---------------------------------------------------------------------------
	Warmod Project
	Dev(s): x[N]ir, Hajt, BCG2000
	File: modules/core/stats.lua
	Description: player stats tracker
--]]---------------------------------------------------------------------------

-- MVP Variables
warmod.dmg           = {}
warmod.total_dmg     = {}
-- Mix Stats
warmod.kills         = {}
warmod.bomb_plants   = {}
warmod.bomb_defusals = {}
warmod.double_kills  = {}
warmod.triple_kills  = {}
warmod.quadra_kills  = {}
warmod.penta_kills   = {}

function warmod.reset_mvp(all)
	local players = player(0, "table")

	-- This way I'm checking the boolean only once
	-- Not on every player since this value can't change
	if all then 
		for k, v in pairs(players) do
			warmod.dmg[id] = 0
			warmod.total_dmg[id] = 0
		end
	else
		for k, v in pairs(players) do
			warmod.dmg[id] = 0
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

	msg("\169255255255[DMG] MVP " .. player(mvp, "name") .. 
		" with " .. max_dmg .. " HP")

	local players = player(0, "table")

	for k, id in pairs(players) do
		if player(id, "team") > 0 then
			warmod.total_dmg[id] = warmod.total_dmg[id] + warmod.dmg[id]
			msg2(id, "\169255255255[DMG] This round: " .. warmod.dmg[id] .. " HP")
			msg2(id, "\169255255255[DMG] Total: " .. warmod.total_dmg[id] .. " HP")
		end
	end
end