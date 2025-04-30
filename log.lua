---@author Klen_list <https://github.com/klen-list>

LOG_DEBUG = rl.LOG_DEBUG
LOG_INFO = rl.LOG_INFO
LOG_WARNING = rl.LOG_WARNING
LOG_ERROR = rl.LOG_ERROR

---Основная функция логгирования.
---@param level integer
---@param text string
---@param ... string
---@return nil
function Log(level, text, ...)
	return rl.TraceLog(level, text, ...)
end