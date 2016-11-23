--[[---------------------------------------------------------------------------
	Warmod Project
	Dev(s): x[N]ir, Hajt
	File: modules/utils/table.lua
	Description: Additional table behavior
--]]---------------------------------------------------------------------------

-- Returns whether the specified value is contained in the table
-- @param table tab a table
-- @param object value a value
-- @return true if the value is within the table otherwise nil
function warmod.table_contains(tab, value)
	for k, v in pairs(tab) do
		if v == value then
			return true
		end
	end
end

-- Removes a value from the table
-- @param table tab a table
-- @param object value
function warmod.table_remove(tab, value)
	for k, v in pairs(tab) do
		if v == value then
			table.remove(tab, k)
			break
		end
	end
end