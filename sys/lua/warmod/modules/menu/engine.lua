--[[---------------------------------------------------------------------------
	Warmod Project
	Dev(s): x[N]ir, Hajt
	File: modules/menu/engine.lua
	Description: menu engine
--]]---------------------------------------------------------------------------

warmod.MENUS = {}

function warmod.new_menu(title, buttons)
	return {
		title = title or "Menu",
		buttons = buttons or {},
		opened = false,
		page = 1,
		pages = 1,
	}
end

function warmod.display_menu(id)
	local pmenu = warmod.player_menu[id]
	local buttons = pmenu.buttons

	-- 7 buttons per page
	pmenu.pages = math.ceil(#buttons / 7) 

	if pmenu.pages < 1 then
		pmenu.opened = false
		return
	else
		pmenu.opened = true
	end

	if pmenu.page < 1 then 
		pmenu.page = 1 
	end

	if pmenu.page > pmenu.pages then 
		pmenu.page = pmenu.pages 
	end

	-- Build the menu string from the current page
	local string = pmenu.title
	local start = pmenu.page * 7 - 6 -- 7 buttons per page
	local stop = start + 6

	for i = start, stop do
		local button = buttons[i]

		if button then
			string = string .. "," .. button.label
		else
			string = string .. ","
		end
	end

	if pmenu.page > 1 then
		string = string .. ",Previous"
	else
		string = string .. ","
	end

	if pmenu.page < pmenu.pages then
		string = string .. ",Next"
	end

	menu(id, string)
end

-- Opens the dynamic main menu by refreshing its buttons
function warmod.open_main_menu(id)
	local buttons = warmod.MENUS["Main Menu"].buttons
	local organization, map

	if warmod.team_organization == 1 then 
		organization = "Current Teams"
	elseif warmod.team_organization == 2 then 
		organization = "Random Captains"
	elseif warmod.team_organization == 3 then 
		organization = "Random Teams"
	end

	if warmod.map_mode == warmod.MAP_MODE.CURRENT then 
		map = "Current"
	elseif warmod.map_mode == warmod.MAP_MODE.VETO then 
		map = "Veto"
	elseif warmod.map_mode == warmod.MAP_MODE.VOTE then 
		map = "Vote"
	end

	buttons[1].label = "Team Mode: " .. organization
	buttons[2].label = "Team Size: " .. warmod.team_size
	buttons[3].label = "MR: " .. warmod.mr
	buttons[4].label = "Map: " .. map
	buttons[5].label = "Knife: " .. 
		(warmod.knife_round_enabled and "Enabled" or "Disabled")

	warmod.event_change_menu(id, warmod.MENU_ARGS[1])
end