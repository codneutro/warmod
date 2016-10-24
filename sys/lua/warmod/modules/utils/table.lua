--[[---------------------------------------------------------------------------
	Warmod Project
	Dev(s): x[N]ir, Hajt
	File: modules/utils/table.lua
	Description: additional table behavior
--]]---------------------------------------------------------------------------

function warmod.table_contains(tab, value)
	for k, v in pairs(tab) do
		if v == value then
			return true
		end
	end
end

function warmod.table_remove(tab, value)
	for k, v in pairs(tab) do
		if v == value then
			table.remove(tab, k)
			break
		end
	end
end