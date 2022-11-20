FSMODE_READ = 0x1
FSMODE_WRITE = 0x2
-- skip 0x4 append mode
FSMODE_BINARY = 0x8

local file_class = {}
file_class.__index = file_class

debug.getregistry()["FileClass"] = file_class

MakeAccessor(file_class, "_fpath", "Path")
MakeAccessor(file_class, "_iomode", "Mode")
MakeAccessor(file_class, "_iostream", "Stream")

function file_class:GetModeStr()
	local strmode = ""
	if self:CanRead() then strmode = strmode .. "r" end
	if self:CanWrite() then strmode = strmode .. "w" end
	if self:IsBinary() then strmode = strmode .. "b" end
	return strmode
end

function file_class:CanRead()
	return bit.band(self:GetMode(), FSMODE_READ) == FSMODE_READ
end

function file_class:CanWrite()
	return bit.band(self:GetMode(), FSMODE_WRITE) == FSMODE_WRITE
end

function file_class:IsBinary()
	return bit.band(self:GetMode(), FSMODE_BINARY) == FSMODE_BINARY
end

function file_class:Open()
	local iobase = io.open(self:GetPath(), self:GetModeStr())
	assert(iobase, "Failed open file!") -- todo: not crash there, just warning?
	self:SetStream(iobase)
	return self
end

function file_class:Read(n)
	n = n or 1
	assert(isnumber(n))
	return self:GetStream():read(n)
end

function file_class:ReadLine()
	return self:GetStream():read "*l"
end

function file_class:ReadByte()
	return self:Read():byte()
end

function file_class:ReadLong()
	local bytes = self:Read(4)
	local out = bit.lshift(bytes:byte(4), 24)
	out = out + bit.lshift(bytes:byte(3), 16)
	out = out + bit.lshift(bytes:byte(2), 8)
	out = out + bytes:byte(1)
	return out
end

function file_class:ReadFloat()
	return ffi_t.tofloat(self:Read(4))
end

function file_class:ReadVector()
	return Vector3(self:ReadFloat(), self:ReadFloat(), self:ReadFloat())
end

function file_class:Write(...)
	self:GetStream():write(...)
end

function file_class:WriteLong(n)
	local bytes = {}
	assert(isnumber(n))
	bytes[1] = bit.rshift(n, 24)
	bytes[2] = bit.rshift(n, 16)
	bytes[3] = bit.rshift(n, 8)
	bytes[4] = n
	self:Write(table.concat(bytes))
end

function file_class:Seek(...)
	return self:GetStream():seek(...)
end

function file_class:Move(n)
	return self:Seek("cur", n)
end

function file_class:Start()
	self:Seek "set"
end

function file_class:End()
	return self:Seek "end"
end

-- start lazy alias

function file_class:Tell()
	return file_class:Seek()
end

function file_class:Skip(n)
	assert(isnumber(n) and n > 0)
	return self:Move(n)
end

-- end lazy alias

function file_class:Close()
	self:GetStream():close()
end

fs = fs or {}

function fs.Open(path, mode)
	assert(isstring(path))
	assert(isnumber(mode) or istable(mode))
	
	local fsclass = setmetatable({}, file_class)
	
	if istable(mode) then
		mode = bit.bor(unpack(mode))
	end
	
	fsclass:SetPath(path)
	fsclass:SetMode(mode)
	
	return fsclass:Open()
end

function fs.Type(obj)
	if getmetatable(obj) == file_class then return io.type(obj:GetStream()) end
	return io.type(obj)
end

function fs.ValidType(obj)
	return fs.Type(obj) == "file"
end