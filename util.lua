---@author Klen_list <https://github.com/klen-list>

---@class ffilib
ffi = require("ffi")

Format = string.format
ColorWhite = rl.RAYWHITE

---Проверяет является ли переменная строкой
---@param obj any Любой объект
---@return boolean ok Это строка
---@nodiscard
function StringOk(obj)
	return type(obj) == "string"
end

---Проверяет является ли переменная числом
---@param obj any Любой объект
---@return boolean ok Это число
---@nodiscard
function NumberOk(obj)
	return type(obj) == "number"
end

---Проверяет является ли переменная таблицей
---@param obj any Любой объект
---@return boolean ok Это таблица
---@nodiscard
function TableOk(obj)
	return type(obj) == "table"
end

---Проверяет является ли переменная функцией
---@param obj any Любой объект
---@return boolean ok Это функция
---@nodiscard
function FunctionOk(obj)
	return type(obj) == "function"
end

---Загружает текстуру из файла изображения
---@param path string Путь к файлу изображения
---@return Texture texture Загруженная текстура
---@nodiscard
function Texture(path)
	assert(StringOk(path))

	local bg = rl.LoadImage(path)
	local tex_bg = rl.LoadTextureFromImage(bg)
	rl.UnloadImage(bg)

	return tex_bg
end

---Проверяет ОС где запущена программа и создает ошибку, если это не `Windows`
function DEFINE_WINDOWSONLY()
	assert(jit.os == "Windows", "This app support only Windows!")
end

---Блокирует выполнение программы на указанное время
---@param time number Время в секундах
function DebugHang(time)
	time = time or 60

	local startTime = os.time()
	while true do
		if os.time() > startTime + time then break end
	end
end

---Переводит первый символ строки в верхний регистр
---@param str string Целевая строка
---@return string outString Результат перевода
---@nodiscard
function string.upperfirst(str)
	assert(StringOk(str))

	local out = str:gsub("^%l", string.upper)
	return out
end

---Проверяет пустая ли таблица
---@param tbl table Таблица для проверки
---@return boolean ok Таблица пустая
---@nodiscard
function table.isempty(tbl)
	return next(tbl) == nil
end

---Дебаг функция для вывода таблицы в консоль
---@param tbl table Таблица для вывода
---@param outString string? Внутренний буффер для рекурсивного вызова
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

---Создает в указанной таблице `Get[name]`/`Set[name]` функции хранения<br>
---Значения храняться по указанному ключу в этой же таблице
---@param t table Таблица для которой нужно создать Get/Set
---@param key string Уникальный ключ для хранения значения в указанной таблице
---@param name string Уникальное имя функции (оно будет соеденено с `Get`/`Set`)
function MakeAccessor(t, key, name)
	assert(TableOk(t))
	assert(StringOk(key))
	assert(StringOk(name))

	t["Get" .. name:upperfirst()] = function(tbl) return tbl[key] end
	t["Set" .. name:upperfirst()] = function(tbl, val) tbl[key] = val end
end