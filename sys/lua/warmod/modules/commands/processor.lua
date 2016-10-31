--[[---------------------------------------------------------------------------
	Warmod Project
	Dev(s): x[N]ir, Hajt
	File: modules/commands/processor.lua
	Description: Command processor
--]]---------------------------------------------------------------------------

warmod.COMMANDS = {}

function warmod.command_check(id, txt)
	local cmd = string.match(string.lower(txt), "^([!][%w]+)[%s]?")

	if not cmd then 
		return 0 
	end

	if not warmod.COMMANDS[cmd] then
		msg2(id,"\169255150150[ERROR]:\169255255255 Undefined command")
		return 1
	end

	local aftercmd = string.match(txt, "[%s](.*)")
	warmod.command_process(id, cmd, aftercmd)
	return 1
end

function warmod.command_process(id, cmd, txt)
	local arg_count = warmod.COMMANDS[cmd].argv
	local argv      = {}

	if arg_count > 0 then
		if not txt then
			msg2(id, "\169255150150[ERROR]:\169255255255 Invalid syntax")
			msg2(id, "\169255150150[ERROR]:\169255255255 Syntax: " .. cmd .. " " .. 
					warmod.COMMANDS[cmd].syntax)
			return 1
		end

		local count = 0

		for word in string.gmatch(txt, "[^%s]+") do
			count = count + 1

			if count <= arg_count then
				table.insert(argv, word)
			else
				argv[#argv] = argv[#argv] .. " " .. word
			end
		end

		if count < arg_count then
			msg2(id, "\169255150150[ERROR]:\169255255255 Invalid syntax")
			msg2(id, "\169255150150[ERROR]:\169255255255 Syntax: " .. cmd .. " " .. 
					warmod.COMMANDS[cmd].syntax)
			return 1
		end

	elseif arg_count <= 0 and txt ~= nil and txt ~= " " then
		argv = {txt}
	end
	
	if warmod.COMMANDS[cmd].admin == true then
		if not warmod.is_admin(id) then
			msg2(id, "\169255150150[ERROR]:\169255255255 You do not have " .. 
					"permission to use this command")
			return 1
		end
	end

	local ret

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

function warmod.is_admin(id)
	return warmod.table_contains(warmod.ADMINS, player(id, "usgn"))
end