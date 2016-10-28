--[[---------------------------------------------------------------------------
	Warmod Project
	Dev(s): x[N]ir, Hajt
	File: init.lua
	Description: main entry point of the project
--]]---------------------------------------------------------------------------

math.randomseed(os.time())

-- The main table
warmod = {}

-- Modules
dofile("sys/lua/warmod/modules/constants.lua")
dofile("sys/lua/warmod/modules/utils/file.lua")
dofile("sys/lua/warmod/modules/utils/table.lua")
dofile("sys/lua/warmod/modules/utils/misc.lua")
dofile("sys/lua/warmod/modules/menu/engine.lua")
dofile("sys/lua/warmod/modules/menu/events.lua")
dofile("sys/lua/warmod/modules/menu/list.lua")
dofile("sys/lua/warmod/modules/commands/processor.lua")
dofile("sys/lua/warmod/modules/commands/list.lua")
dofile("sys/lua/warmod/modules/core/setup.lua")
dofile("sys/lua/warmod/modules/core/ready_system.lua")
dofile("sys/lua/warmod/modules/core/timers.lua")
dofile("sys/lua/warmod/modules/core/stats.lua")
dofile("sys/lua/warmod/modules/player/hooks.lua")
dofile("sys/lua/warmod/modules/server/hooks.lua")

-- Hooks
addhook("join",         "warmod.join")
addhook("leave",        "warmod.leave")
addhook("kill",         "warmod.kill")
addhook("name",         "warmod.name")
addhook("say",          "warmod.say")
addhook("sayteam",      "warmod.say")
addhook("startround",   "warmod.startround")
addhook("endround",     "warmod.endround")
addhook("hit",          "warmod.hit")
addhook("menu",         "warmod.menu")
addhook("team",         "warmod.team")
addhook("bombplant",    "warmod.bombplant")
addhook("bombdefuse",   "warmod.bombdefuse")
addhook("spawn",        "warmod.spawn")
addhook("serveraction", "warmod.serveraction")
addhook("suicide",      "warmod.suicide")

warmod.apply_settings("STARTUP")
warmod.load_maps()
warmod.load_usgns()

warmod.load_maps        = nil
warmod.load_usgns       = nil