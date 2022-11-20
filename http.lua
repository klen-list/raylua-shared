local ffi = require "ffi"
local curl_dll = ffi.load "./bin/libcurl"

ffi.cdef [[
	typedef int CURL;
	
	typedef struct {
	  char *data;
	  struct curl_slist *next;
	} curl_slist;
	
	typedef size_t (*WriteFuncCallback) (char*, size_t, size_t, void*);
]]

local CURLE_OK = 0
local CURLOPT_SSL_VERIFYPEER = 64
local CURLOPT_SSL_VERIFYHOST = 81
local CURLOPT_URL = 10002
local CURLOPT_WRITEFUNCTION = 20011
local CURLOPT_HTTPHEADER = 10023

ffi.cdef "CURL* curl_easy_init (void)"
local function curl_init_session()
	return curl_dll.curl_easy_init()
end

ffi.cdef "uint8_t curl_easy_setopt (CURL*, int, ...)"
function curl_setopt(handle, option, ...)
	return curl_dll.curl_easy_setopt(handle, option, ...)
end

ffi.cdef "curl_slist* curl_slist_append (struct curl_slist*, const char*)"
function curl_slist_append(slist, data)
	return curl_dll.curl_slist_append(slist, data)
end

ffi.cdef "uint8_t curl_easy_perform (CURL*)"
function curl_perform(handle)
	return curl_dll.curl_easy_perform(handle)
end

ffi.cdef "void curl_easy_cleanup (CURL*)"
local function curl_shutdown_session(handler)
	curl_dll.curl_easy_cleanup(handler)
end

http = http or {}

function http.FetchText(url)
	assert(isstring(url))

	local session = curl_init_session()
	if not session or session == 0 then return false, "session init failed", -1 end
	
	local code = curl_setopt(session, CURLOPT_URL, url)
	if code ~= CURLE_OK then return false, "url option setup failed", code end
	
	local out = ""
	
	local callback = ffi.cast("WriteFuncCallback", function(ptr, size, nmemb, data)
		if ffi.cast("int", data) == 0 then return 0 end
		out = out .. ffi.string(ptr)
		return size * nmemb
	end)
	
	code = curl_setopt(session, CURLOPT_WRITEFUNCTION, callback)
	if code ~= CURLE_OK then return false, "wfunction option setup failed", code end
	
	local headers = ffi.new "struct curl_slist*"
	headers = curl_slist_append(headers, "Content-Type: text/plain; charset=utf-8;")
	code = curl_setopt(session, CURLOPT_HTTPHEADER, headers)
	if code ~= CURLE_OK then return false, "headers option setup failed", code end
	
	if url:sub(1, 5) == "https" then
		code = curl_setopt(session, CURLOPT_SSL_VERIFYPEER, 0)
		if code ~= CURLE_OK then return false, "sslpeer option setup failed", code end
		code = curl_setopt(session, CURLOPT_SSL_VERIFYHOST, 0)
		if code ~= CURLE_OK then return false, "sslhost option setup failed", code end
	end
	
	code = curl_perform(session)
	if code ~= CURLE_OK then return false, "run session failed", code end
	
	curl_shutdown_session(session)
	
	callback:free()
	
	return true, out, 0
end
