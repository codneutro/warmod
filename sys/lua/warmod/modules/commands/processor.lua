--[[---------------------------------------------------------------------------
	Warmod Project
	Dev(s): x[N]ir, Hajt
	File: modules/commands/processor.lua
	Description: Command processor
--]]---------------------------------------------------------------------------

warmod.COMMANDS   = {} -- Command List
warmod.ADMINS     = {} -- Admins USGNs
warmod.ADMINS_IPS = {} -- Admins IPs

-- Checks whether the specified text contains a command
-- @param number id playerID
-- @param string text a text
function warmod.command_check(id, txt)
	local cmd = string.match(string.lower(txt), "^([!][%w]+)[%s]?")

	if not cmd then -- Doesn't match a command at all 
		return 0 
	end

	if not warmod.COMMANDS[cmd] then -- Not defined
		msg2(id,"\169255150150[ERROR]:\169255255255 Undefined command")
		return 1
	end

	local aftercmd = string.match(txt, "[%s](.*)")

	warmod.command_process(id, cmd, aftercmd)

	return 1
end

-- Parses command arguments within a text
-- @param number id caller
-- @param string cmd a command key
-- @param string text a text
function warmod.command_process(id, cmd, txt)
	local arg_count = warmod.COMMANDS[cmd].argv -- Command's arguments number
	local argv      = {} -- Argument(s) value(s)

	if arg_count > 0 then -- Require at least one argument
		if not txt then
			msg2(id, "\169255150150[ERROR]:\169255255255 Invalid syntax")
			msg2(id, "\169255150150[ERROR]:\169255255255 Syntax: " .. cmd .. " " .. 
					warmod.COMMANDS[cmd].syntax)
			return 1
		end

		local count = 0

		-- Adds each word separated by spaces
		for word in string.gmatch(txt, "[^%s]+") do
			count = count + 1

			if count <= arg_count then
				table.insert(argv, word)
			else
				argv[#argv] = argv[#argv] .. " " .. word
			end
		end

		if count < arg_count then -- Missing arguments
			msg2(id, "\169255150150[ERROR]:\169255255255 Invalid syntax")
			msg2(id, "\169255150150[ERROR]:\169255255255 Syntax: " .. cmd .. " " .. 
					warmod.COMMANDS[cmd].syntax)
			return 1
		end

	elseif arg_count <= 0 and txt ~= nil and txt ~= " " then
		argv = {txt}
	end
	
	-- This command requires admin access
	if warmod.COMMANDS[cmd].admin then 
		if not warmod.is_admin(id) then
			msg2(id, "\169255150150[ERROR]:\169255255255 You do not have " .. 
					"permission to use this command")
			return 1
		end
	end

	local ret -- Command return value

	-- Call the command function with arguments if necessary
	if #argv > 0 then
		ret = warmod.COMMANDS[cmd].func(id, argv)
	else
		ret = warmod.COMMANDS[cmd].func(id)
	end

	if ret ~= nil then
		if ret == false then
			msg2(id, "\169255150150[ERROR]:\169255255255 Something went wrong")
		else
			msg2(id, "\169255150150[ERROR]:\169255255255 " .. ret)
		end
		
		return 1
	end
end

-- Returns whether the specified player is an admin
function warmod.is_admin(id)
	return warmod.table_contains(warmod.ADMINS, player(id, "usgn")) or 
		warmod.table_contains(warmod.ADMINS_IPS, player(id, "ip"))
end