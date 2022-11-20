local vector3 = {}

vector3.__index = function(self, key)
	if isstring(key) then
		if key == "x" then return rawget(self, 1) end
		if key == "y" then return rawget(self, 2) end
		if key == "z" then return rawget(self, 3) end
	end
	
	local func = vector3[key]
	if func ~= nil then return func end
end

vector3.__newindex = function()
	error "attempt to add values in static structure!"
end

vector3.__tostring = function(self)
	return string.format("Vector3(%d, %d, %d)", rawget(self, 1), rawget(self, 2), rawget(self, 3))
end

function Vector3(x, y, z)
	return setmetatable({x, y, z}, vector3)
end

function isvector(v) return getmetatable(v) == vector3 end