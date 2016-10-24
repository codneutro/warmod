--[[---------------------------------------------------------------------------
	Warmod Project
	Dev(s): x[N]ir, Hajt
	File: modules/utils/file.lua
	Description: I/O Operations
--]]---------------------------------------------------------------------------

local buff = {}
local buff_pos = 0

function warmod.file_load(path)
	local f = io.open(path)

	if not f then
		print("\169255000000[ERROR]: Can't load this file <" .. path .. ">")
		return false
	end

	local newbuff = {}

	for line in f:lines() do
		newbuff[#newbuff + 1] = line
	end

	buff = newbuff
	buff_pos = 0

	f:close()
	return true
end

function warmod.file_read()
	buff_pos = buff_pos + 1
	return buff[buff_pos]
end

function warmod.file_write(path, lines, mode)
	local f = io.open(path, mode)
	
	if not f then
		print("\169255000000[ERROR]: Can't write in this file <" .. path .. ">")
		return
	end

	local size = #lines

	for i = 1, size do
		f:write(lines[i] .. (i ~= size and "\n" or ""))
	end

	f:close()
end