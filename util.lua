---@author Klen_list <https://github.com/klen-list>

---@class ffilib
ffi = require("ffi")

Format = string.format
ColorWhite = rl.RAYWHITE

---Проверяет является ли переменная строкой.
---@param obj any
---@return boolean
---@nodiscard
function StringOk(obj)
	return type(obj) == "string"
end

---Проверяет является ли переменная числом.
---@param obj any
---@return boolean
---@nodiscard
function NumberOk(obj)
	return type(obj) == "number"
end

---Проверяет является ли переменная таблицей.
---@param obj any
---@return boolean
---@nodiscard
function TableOk(obj)
	return type(obj) == "table"
end

---Проверяет является ли переменная функцией.
---@param obj any
---@return boolean
---@nodiscard
function FunctionOk(obj)
	return type(obj) == "function"
end

---Загружает текстуру из файла изображения.
---@param path string
---@return unknown texture
---@nodiscard
function Texture(path)
	assert(StringOk(path))

	local bg = rl.LoadImage(path)
	local tex_bg = rl.LoadTextureFromImage(bg)
	rl.UnloadImage(bg)

	return tex_bg
end

---Проверяет ОС где запущена программа и создает ошибку, если это не `Windows`.
---@return nil
function DEFINE_WINDOWSONLY()
	assert(jit.os == "Windows", "This app support only Windows!")
end

---Блокирует выполнение программы на указанное время.
---@param time number
---@return nil
function DebugHang(time)
	time = time or 60

	local startTime = os.time()
	while true do
		if os.time() > startTime + time then break end
	end
end

---Переводит первый символ строки в верхний регистр.
---@param str string
---@return string
---@nodiscard
function string.upperfirst(str)
	assert(StringOk(str))

	local out = str:gsub("^%l", string.upper)
	return out
end

---Проверяет пустая ли таблица.
---@param tbl table
---@return boolean
---@nodiscard
function table.isempty(tbl)
	return next(tbl) == nil
end

---Дебаг функция для вывода таблицы в консоль.
---@param tbl table
---@param outString string?
---@return nil
function PrintTable(tbl, outString)
	assert(TableOk(tbl))

	for key, val in pairs(tbl) do
		if TableOk(val) then
			print(outString .. tostring(key))
			outString = outString .. ' '

			PrintTable(val, outString)
			outString = ''

			goto next
		end

		print(outString .. tostring(key) .. '\t' .. val)

		::next::
	end
end

---Создает в таблице `Get[name]`/`Set[name]` функции для указанного ключа.
---@param t table
---@param key string
---@param name string
---@return nil
function MakeAccessor(t, key, name)
	assert(TableOk(t))
	assert(StringOk(key))
	assert(StringOk(name))

	t["Get" .. name:upperfirst()] = function(tbl) return tbl[key] end
	t["Set" .. name:upperfirst()] = function(tbl, val) tbl[key] = val end
end