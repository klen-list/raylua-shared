local ffi = require "ffi"

ffi_t = ffi_t or {}

if WINDOWS then

	ffi.cdef "bool __stdcall FreeConsole (void)"
	function ffi_t.confree()
		return ffi.C.FreeConsole()
	end
	
	ffi.cdef "bool __stdcall SetConsoleOutputCP (int)"
	function ffi_t.consetcp(codepage)
		return ffi.C.SetConsoleOutputCP(codepage)
	end

else

	function ffi_t.confree() end
	function ffi_t.consetcp() end

end

function ffi_t.intp(size, values)
	return ffi.new("int[?]", size, values)
end

function ffi_t.stridxp(ptr, pos)
	return ffi.string(ptr[pos])
end

function ffi_t.from_charptr(str)
	return ffi.string(ffi.new("char[?]", #str, str))
end

local floatp_type = ffi.typeof "float*"
function ffi_t.tofloat(bytes)
	return ffi.cast(floatp_type, bytes)[0]
end