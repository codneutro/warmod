--[[---------------------------------------------------------------------------
	Warmod Project
	Dev(s): x[N]ir, Hajt
	File: modules/menu/list.lua
	Description: static menu data
--]]---------------------------------------------------------------------------

warmod.MENU_ARGS = {
	{static = 1, menu = "Main Menu", display = 1},
	{static = 1, menu = "Team Organization", display = 1},
	{static = 1, menu = "Team Size", display = 1},
	{static = 1, menu = "Map", display = 1},
	{static = 1, menu = "Knife", display = 1},
	{static = 1, menu = "Spectators", display = 1},
	{static = 1, menu = "Maps", display = 1},
	{static = 1, menu = "Veto", display = 1},
	{static = 1, menu = "Side", display = 1},
	{static = 1, menu = "MR", display = 1},
}

warmod.MENUS["Main Menu"] = warmod.new_menu("Main Menu", {
	{label = "Team Organization", func = warmod.event_main_menu, args = 1},
	{label = "Team Size", func = warmod.event_main_menu, args = 2},
	{label = "MR", func = warmod.event_main_menu, args = 3},
	{label = "Map", func = warmod.event_main_menu, args = 4},
	{label = "Knife Round", func = warmod.event_main_menu, args = 5},
})

warmod.MENUS["Team Organization"] = warmod.new_menu("Team Organization", {
	{label = "Current Teams", func = warmod.event_change_settings, 
		args = {setting = "organization", value = 1}},
	{label = "Random Captains", func = warmod.event_change_settings, 
		args = {setting = "organization", value = 2}},
	{label = "Random Teams", func = warmod.event_change_settings, 
		args = {setting = "organization", value = 3}},
})

warmod.MENUS["Team Size"] = warmod.new_menu("Team Size", {
	{label = " ", func = warmod.event_change_settings, 
		args = {setting = "size", value = 1}},
	{label = " ", func = warmod.event_change_settings, 
		args = {setting = "size", value = 2}},
	{label = " ", func = warmod.event_change_settings, 
		args = {setting = "size", value = 3}},
	{label = " ", func = warmod.event_change_settings, 
		args = {setting = "size", value = 4}},
	{label = " ", func = warmod.event_change_settings, 
		args = {setting = "size", value = 5}},
})

warmod.MENUS["MR"] = warmod.new_menu("MR", {
	{label = "10", func = warmod.event_change_settings, 
		args = {setting = "mr", value = 10}},
	{label = "12", func = warmod.event_change_settings, 
		args = {setting = "mr", value = 12}},
	{label = "15", func = warmod.event_change_settings, 
		args = {setting = "mr", value = 15}},
	-- TODO: Remove this button later
	{label = "4", func = warmod.event_change_settings,  
		args = {setting = "mr", value = 4}},
})

warmod.MENUS["Map"] = warmod.new_menu("Map", {
	{label = " ", func = warmod.event_change_settings, 
		args = {setting = "map", value = warmod.MAP_MODE.CURRENT}},
	{label = " ", func = warmod.event_change_settings, 
		args = {setting = "map", value = warmod.MAP_MODE.VOTE}},
	{label = " ", func = warmod.event_change_settings, 
		args = {setting = "map", value = warmod.MAP_MODE.VETO}},
})

warmod.MENUS["Knife"] = warmod.new_menu("Knife", {
	{label = "Enabled", func = warmod.event_change_settings, 
		args = {setting = "knife", value = true}},
	{label = "Disabled", func = warmod.event_change_settings, 
		args = {setting = "knife", value = false}},
})

warmod.MENUS["Side"] = warmod.new_menu("Side", {
	{label = "Stay", func = warmod.event_side_vote, args = false},
	{label = "Swap", func = warmod.event_side_vote, args = true},
})

warmod.MENUS["Spectators"] = warmod.new_menu("Spectators")
warmod.MENUS["Maps"]       = warmod.new_menu("Maps")
warmod.MENUS["Veto"]       = warmod.new_menu("Veto")