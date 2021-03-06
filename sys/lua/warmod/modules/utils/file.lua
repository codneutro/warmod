--[[---------------------------------------------------------------------------
	Warmod Project
	Dev(s): x[N]ir, Hajt
	File: modules/utils/file.lua
	Description: I/O Operations
--]]---------------------------------------------------------------------------

-- Stored lines
local buff     = {}

-- Position in the buffer		
local buff_pos = 0      

-- Loads a file into memory
-- @return true if the file was actually loaded false otherwise
function warmod.file_load(path)
	local f = io.open(path)

	if not f then
		print("\169255000000[ERROR]: Can't load this file <" .. path .. ">")
		return false
	end

	local newbuff = {}

	-- Cache each line
	for line in f:lines() do
		newbuff[#newbuff + 1] = line
	end

	-- Update and reset
	buff = newbuff
	buff_pos = 0

	f:close()
	return true
end

-- Returns the current line from the buffer or nil on EOF
function warmod.file_read()
	buff_pos = buff_pos + 1
	return buff[buff_pos]
end

-- Write the specified lines into a file
-- @string path a file path
-- @table lines the lines to be written
-- @strnig mode a file mode
function warmod.file_write(path, lines, mode)
	local f = io.open(path, mode)
	
	if not f then
		print("\169255000000[ERROR]: Can't write in this file <" .. path .. ">")
		return
	end

	local size = #lines

	-- Writes each line and starts a new line if there are/is still some line(s)
	-- to be written
	for i = 1, size do
		f:write(lines[i] .. (i ~= size and "\n" or "")) 
	end

	f:close()
end