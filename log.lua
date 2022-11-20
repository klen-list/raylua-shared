local ffi = require "ffi"

if WINDOWS or LINUX then
	os.execute "mkdir logs"
	
	ffi.cdef "void* freopen(const char*, const char*, void*)"
	
	local filepath = "./logs/" .. os.date('log-%Y-%m-%d_%H-%M-%S.txt')
	
	ffi.C.freopen(filepath, "w", io.stdout)
	ffi.C.freopen(filepath, "a", io.stderr)
end

LOG_DEBUG = rl.LOG_DEBUG
LOG_INFO = rl.LOG_INFO
LOG_WARNING = rl.LOG_WARNING
LOG_ERROR = rl.LOG_ERROR

function log(level, text, ...)
	rl.TraceLog(level, text, ...);  
end