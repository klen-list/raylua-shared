---@author Klen_list <https://github.com/klen-list>

local lfs = require("core.third-party.lfs_ffi")
require('core.third-party.utf8_filenames')

FSMODE_READ = 0x1
FSMODE_WRITE = 0x2
---skip 0x4 append mode
FSMODE_BINARY = 0x8

---@class File
---@field private _fpath string
---@field GetPath fun(self: File): string
---@field SetPath fun(self: File, path: string): nil
---@field private _iomode integer
---@field GetMode fun(self: File): integer
---@field SetMode fun(self: File, mode: integer): nil
---@field private _iostream file*
---@field GetStream fun(self: File): file*
---@field SetStream fun(self: File, stream: file*): nil
local file_class = {}
file_class.__index = file_class

debug.getregistry()["FileClass"] = file_class

MakeAccessor(file_class, "_fpath", "Path")
MakeAccessor(file_class, "_iomode", "Mode")
MakeAccessor(file_class, "_iostream", "Stream")

---Возвращает строковый код режима открытия файла.
---@return 'r' | 'rb' | 'w' | 'wb'
---@nodiscard
function file_class:GetModeStr()
	local strmode = 'wb'

	if self:CanRead() then strmode = 'r' end
	if self:CanWrite() then strmode = 'w' end
	if self:IsBinary() then strmode = strmode .. 'b' end

	return strmode
end

---Проверяет наличие флага режима чтения.
---@return boolean
---@nodiscard
function file_class:CanRead()
	return bit.band(self:GetMode(), FSMODE_READ) == FSMODE_READ
end

---Проверяет наличие флага режима записи.
---@return boolean
---@nodiscard
function file_class:CanWrite()
	return bit.band(self:GetMode(), FSMODE_WRITE) == FSMODE_WRITE
end

---Проверяет наличие флага бинарного режима.
---@return boolean
---@nodiscard
function file_class:IsBinary()
	return bit.band(self:GetMode(), FSMODE_BINARY) == FSMODE_BINARY
end

---Открывает файл по заданным заранее пути и режиму.
---@return File
---@nodiscard
function file_class:Open()
	local iobase = io.open(self:GetPath(), self:GetModeStr())
	assert(iobase, "Failed open file!") -- todo: not crash there, just warning?

	self:SetStream(iobase)

	return self
end

---Читает указанное кол-во байтов из файла.<br>
---Без аргументов читает один байт.
---@param bytesToRead integer?
---@return string
---@nodiscard
function file_class:Read(bytesToRead)
	bytesToRead = bytesToRead or 1
	assert(NumberOk(bytesToRead))

	return self:GetStream():read(bytesToRead)
end

---Читает байты из файла до первого встречного символа переноса строки.
---@return string
---@nodiscard
function file_class:ReadLine()
	return self:GetStream():read "*l"
end

---Читает один байт из файла в виде числа.
---@return integer
---@nodiscard
function file_class:ReadByte()
	return self:Read():byte()
end

---Читает 4 байта из файла в виде числа.
---@return integer
---@nodiscard
function file_class:ReadLong()
	local bytes = self:Read(4)

	local out = bit.lshift(bytes:byte(4), 24)
	out = out + bit.lshift(bytes:byte(3), 16)
	out = out + bit.lshift(bytes:byte(2), 8)
	out = out + bytes:byte(1)

	return out
end

do
	local floatType = ffi.typeof("float*")

	---Читает 4 байта из файла в виде числа с плавающей точкой.
	---@return number
	---@nodiscard
	function file_class:ReadFloat()
		return ffi.cast(floatType, self:Read(4))[0]
	end
end

---Записывает данные в файл.
---@param ... string
---@return nil
function file_class:Write(...)
	self:GetStream():write(...)
end

---Записывает число в файл в виде 4 байтов.
---@param num integer
---@return nil
function file_class:WriteLong(num)
	assert(NumberOk(num))

	local bytes = {}

	bytes[1] = bit.rshift(num, 24)
	bytes[2] = bit.rshift(num, 16)
	bytes[3] = bit.rshift(num, 8)
	bytes[4] = num

	self:Write(table.concat(bytes))
end

---Установка и получение позиции в файле.
---@param whence ("cur"|"end"|"set")?
---@param offset integer?
---@return integer: offset
---@return string?: errMessage
function file_class:Seek(whence, offset)
	return self:GetStream():seek(whence, offset)
end

---Перемещает указатель в файле относительно позиции.
---@param offset integer
---@param startPos integer?
---@return integer: offset
---@return string?: errMessage
function file_class:Move(offset, startPos)
	startPos = startPos or self:Tell()
	return self:Seek("cur", offset - startPos)
end

---Перемещает указатель в начало файла.
---@return nil
function file_class:Start()
	self:Seek("set")
end

---Перемещает указатель в конец файла.
---@return integer: offset
---@return string?: errMessage
function file_class:End()
	return self:Seek("end")
end

---Возвращает размер файла в байтах.
---@return integer
---@nodiscard
function file_class:Size()
	local curpos = self:Tell()
	local endpos = self:End()

	self:Move(curpos)
	return endpos
end

-- Алиасы для ленивых

---Возвращает текущую позицию в файле.
---@return integer: offset
---@return string?: errMessage
---@nodiscard
function file_class:Tell()
	return file_class:Seek()
end

---Пропускает указанное кол-во байтов в файле от текущей позиции.
---@param numToSkip integer
---@return integer: offset
---@return string?: errMessage
function file_class:Skip(numToSkip)
	assert(NumberOk(numToSkip) and numToSkip > 0)

	return self:Move(numToSkip)
end

-- Конец алиасов

---Закрывает файл.
---@return nil
function file_class:Close()
	self:GetStream():close()
end

---@class fs
fs = fs or {}

function fs.Open(path, mode)
	assert(StringOk(path))
	assert(NumberOk(mode) or TableOk(mode))

	local fsclass = setmetatable({}, file_class)

	if TableOk(mode) then
		mode = bit.bor(unpack(mode))
	end

	fsclass:SetPath(path)
	fsclass:SetMode(mode)

	return fsclass:Open()
end

function fs.Write(path, data)
	local f = fs.Open(path, FSMODE_WRITE + FSMODE_BINARY)
	f:Write(data)
	f:Close()
end

function fs.Type(obj)
	if getmetatable(obj) == file_class then return io.type(obj:GetStream()) end
	return io.type(obj)
end

function fs.IsValid(obj)
	return fs.Type(obj) == "file"
end

function fs.ReadFile(path)
	local f = fs.Open(path, FSMODE_READ + FSMODE_BINARY)
	local data = f:Read(f:Size())
	f:Close()
	return data
end

function fs.MakeDir(path)
	local succ, errcode = lfs.mkdir(path)
	if not succ and errcode ~= "File exists" then
		error("FS: Can't create folder: " .. path .. "; ErrorCode: " .. errcode)
	end
end

function fs.GetExtension(filename)
    return filename:match("%.(%w+)$") or ""
end