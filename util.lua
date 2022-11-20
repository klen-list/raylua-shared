function isstring(s) return type(s) == "string" end
function isnumber(n) return type(n) == "number" end
function istable(t) return type(t) == "table" end
function isfunction(f) return type(f) == "function" end

Format = string.format

function string.upperfirst(str)
	assert(isstring(str))
	return str:gsub("^%l", string.upper)
end

function table.isempty(t)
	return next(t) == nil
end

-- for debug
function tprint(t, out)
	assert(istable(t))
	
	local out = out or ""
	for key, val in pairs(t) do
		if istable(val) then
			print(out .. tostring(key))
			out = out .. " "
			tprint(val, out)
			out = ""
			goto next
		end
		print(out .. tostring(key) .. '\t' .. val)
		::next::
	end
end

function table.prettystr(t, print_tables)
	local out = "{\n"
	for key, val in pairs(t) do
		local fout = "\t%s = %s %s,\n"
		local hex = ""
		if isnumber(val) then
			hex = "(0x" .. bit.tohex(val) .. ')'
		elseif istable(val) and print_tables then
			val = table.prettystr(val, print_tables)
		end
		out = out .. fout:format(tostring(key):upperfirst(), tostring(val), hex)
	end
	out = out .. '}'
	return out
end

function MakeAccessor(t, key, name)
	assert(istable(t))
	assert(isstring(key))
	assert(isstring(name))
	
	t["Get" .. name:upperfirst()] = function() return t[key] end
	t["Set" .. name:upperfirst()] = function(self, val) t[key] = val end
end