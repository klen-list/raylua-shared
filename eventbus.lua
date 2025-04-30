---@author Klen_list <https://github.com/klen-list>

---@class eventbus
---@field listeners table<string, table<string, fun(...): nil>>
eventbus = eventbus or {}
eventbus.listeners = eventbus.listeners or {}

---Присоеденяет функцию обратного вызова к указанному событию
---@param eventName string Имя события для присоединения
---@param callbackName string Уникальное название обратного вызова
---@param callback fun(...): nil Функция обратного вызова
function eventbus.attach(eventName, callbackName, callback)
	assert(StringOk(eventName))
	assert(StringOk(callbackName))
	assert(FunctionOk(callback))

	eventbus.listeners[eventName] = eventbus.listeners[eventName] or {}
	eventbus.listeners[eventName][callbackName] = callback
end

---Запускает все обратные вызовы по указанному имени события
---@param eventName string Имя события для которого нужно вызвать все обратные вызовы
---@param ... any Аргументы что будут переданны во все функции обратных вызовов
function eventbus.run(eventName, ...)
	assert(StringOk(eventName))

	local eventsTbl = eventbus.listeners[eventName]
	if not eventsTbl then return end

	for _, callback in pairs(eventsTbl) do
		callback(...)
	end
end

---Отключает функцию обратного вызова от указанного события
---@param eventName string Имя события для отключения
---@param callbackName string Уникальное название обратного вызова что будет отключен
function eventbus.detach(eventName, callbackName)
	assert(StringOk(eventName))
	assert(StringOk(callbackName))

	local eventsTbl = eventbus.listeners[eventName]
	if not eventsTbl then
		Log(LOG_ERROR, "eventbus.detach: event table %s does not exist", eventName)
		return
	end

	eventsTbl[callbackName] = nil
	if table.isempty(eventsTbl) then
		eventbus.listeners[eventName] = nil
	end
end