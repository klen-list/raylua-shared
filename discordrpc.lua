local ffi = require "ffi"
local discordrpc_dll = ffi.load "./bin/discord-rpc"

ffi.cdef [[
	typedef struct {
		const char* state;   		// max 128 bytes
		const char* details;		// max 128 bytes
		int64_t startTimestamp;
		int64_t endTimestamp;
		const char* largeImageKey;  // max 32 bytes
		const char* largeImageText; // max 128 bytes
		const char* smallImageKey;  // max 32 bytes
		const char* smallImageText; // max 128 bytes
		const char* partyId;        // max 128 bytes
		int partySize;
		int partyMax;
		const char* matchSecret;    // max 128 bytes
		const char* joinSecret;     // max 128 bytes
		const char* spectateSecret; // max 128 bytes
		int8_t instance;
	} DiscordRichPresence;
	
	typedef struct {
		const char* userId;
		const char* username;
		const char* discriminator;
		const char* avatar;
	} DiscordUser;
	
	typedef void (*readyCallback) (const DiscordUser* request);
	
	typedef struct {
		readyCallback ready;
		void (*disconnected) (int errorCode, const char* message);
		void (*errored) (int errorCode, const char* message);
		void (*joinGame) (const char* joinSecret);
		void (*spectateGame) (const char* spectateSecret);
		void (*joinRequest) (const DiscordUser* request);
	} DiscordEventHandlers;
]]

discordrpc = discordrpc or {}

local INIT_TIME = os.time()
local presence = ffi.new "DiscordRichPresence"
ffi.fill(presence, ffi.sizeof(presence))

ffi.cdef "void Discord_Initialize (const char*, DiscordEventHandlers*, int, const char*)"
function discordrpc.Init(appid, handlers, autoreg, steamid)
	discordrpc_dll.Discord_Initialize(appid, handlers, autoreg, steamid or '\x00')
end

function discordrpc.SetState(state)
	presence.state = state
end

function discordrpc.SetDetails(details)
	presence.details = details
end

function discordrpc.SyncStartTime()
	presence.startTimestamp = INIT_TIME
end

ffi.cdef "void Discord_RunCallbacks (void)"
function discordrpc.RunCallbacks()
	discordrpc_dll.Discord_RunCallbacks()
end

ffi.cdef "void Discord_UpdatePresence (const DiscordRichPresence*)"
function discordrpc.Update()
	log(LOG_INFO, "DISCORD: Presence updated")
	discordrpc.SyncStartTime()
	discordrpc_dll.Discord_UpdatePresence(presence)
end

ffi.cdef "void Discord_Shutdown (void)"
function discordrpc.Shutdown()
	discordrpc_dll.Discord_Shutdown()
end

--local callback = function()
	--log(LOG_INFO, "DISCORD: Presence inited at %s#%s",	tostring(user.username), tostring(user.discriminator))
--end

event.on("Initialize", "DISCORD_RPC_INIT", function()
	local handlers = ffi.new "DiscordEventHandlers"
	ffi.fill(handlers, ffi.sizeof(handlers))
	
	--handlers.ready = ffi.cast("readyCallback", callback)
	
	discordrpc.Init("", handlers, 1)
	discordrpc.SetState "Idle"
end)

do
	local next_presence_upd = 0
	event.on("Think", "DISCORD_RPC_REFRESH", function()
		discordrpc.RunCallbacks()
		if os.clock() - next_presence_upd > 0 then
			next_presence_upd = os.clock() + 30
			discordrpc.Update()
		end
	end)
end

event.on("ShutDown", "DISCORD_RPC_SHUTDOWN", discordrpc.Shutdown)