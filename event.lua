event = event or {}
event.listeners = event.listeners or {}

function event.on(event_name, callback_name, callback)
	assert(isstring(event_name))
	assert(isstring(callback_name))
	assert(isfunction(callback))
	
	event.listeners[event_name] = event.listeners[event_name] or {}
	event.listeners[event_name][callback_name] = callback
end

function event.run(event_name, ...)
	assert(isstring(event_name))
	
	local events_t = event.listeners[event_name]
	
	if not events_t then return end
	
	for callback_name, callback in pairs(events_t) do
		callback(...)
	end
end

function event.rm(event_name, callback_name)
	assert(isstring(event_name))
	assert(isstring(callback_name))

	event.listeners[event_name][callback_name] = nil
	if table.IsEmpty(event.listeners[event_name]) then
		event.listeners[event_name] = nil
	end
end