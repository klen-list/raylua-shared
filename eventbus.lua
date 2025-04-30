---@author Klen_list <https://github.com/klen-list>

---@class eventbus
---@field listeners table<string, table<string, fun(...): nil>>
eventbus = eventbus or {}
eventbus.listeners = eventbus.listeners or {}

---@param eventName string
---@param callbackName string
---@param callback fun(...): nil
---@return nil
function eventbus.attach(eventName, callbackName, callback)
	assert(StringOk(eventName))
	assert(StringOk(callbackName))
	assert(FunctionOk(callback))

	eventbus.listeners[eventName] = eventbus.listeners[eventName] or {}
	eventbus.listeners[eventName][callbackName] = callback
end

---@param eventName string
---@param ... any
---@return nil
function eventbus.run(eventName, ...)
	assert(StringOk(eventName))

	local eventsTbl = eventbus.listeners[eventName]
	if not eventsTbl then return end

	for _, callback in pairs(eventsTbl) do
		callback(...)
	end
end

---@param eventName string
---@param callbackName string
---@return nil
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