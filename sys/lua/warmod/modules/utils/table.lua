--[[---------------------------------------------------------------------------
	Warmod Project
	Dev(s): x[N]ir, Hajt
	File: modules/utils/table.lua
	Description: Additional table behavior
--]]---------------------------------------------------------------------------

-- Returns true if the specified value is contained in the table
function warmod.table_contains(tab, value)
	for k, v in pairs(tab) do
		if v == value then
			return true
		end
	end
end

-- Removes a value from a table
function warmod.table_remove(tab, value)
	for k, v in pairs(tab) do
		if v == value then
			table.remove(tab, k)
			break
		end
	end
end