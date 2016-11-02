# Contribution

In this file, you can find any informations about how to contribute effectively to our project.

- <a href="#contributor-request">Contributor request</a>
- <a href="#how-to-participate-in-development">How to participate in development</a>
- <a href="#project-structure">Project Structure</a>
- <a href="#code-guidelines">Code guidelines</a>
- <a href="#code-example">Code example</a>

## Contributor Request

In order to join the dev team, contact x[N]ir/Hajt which are mostly available on the official cs2d teamspeak channel.

IP Address: **ts3.cs2d.net**

## How to participate in development

1.  You must clearly inform the dev team about what you are going to do.
2.  If the dev team agrees then you are allowed to push your changes into the master branch.
3.  Testing/Debugging phase about your new functionnality.

## Project Structure

A short description about how the project is organized.

```
warmod/
  init.lua
  cfg/
    admins.cfg
    server.cfg
  data/
    mixes/
  modules/
    player/
    server/
    core/
    utils/
    menu/
    commands/
    constants.lua
```

In depth explainations:

* **init.lua**: This is the main entry point of the project. 
Actually it does basic stuff like loading modules, adding hooks, ... 

* **cfg folder**: The configuration folder.

* **data folder**: This folder contains data used by the script. For instance, player stats, usgns, etc.

* **modules folder**: All lua modules are located there within subfolders sorted by their functionnality.

* **constants.lua**: Constants declarations.

## Code guidelines

By contributing to this project, you **have to** use these coding guidelines.

http://dev.minetest.net/Lua_code_style_guidelines

## Code example 
**(modules/utils/file.lua)**

```lua
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
```



