select(2, ...) 'rosterfilter'


_G.BINDING_HEADER_RF_HEADER = "RosterFilter";
_G.BINDING_NAME_TOGGLE_RF = "Toggle Window";

_G.RosterFilter_ToggleWindow = function()
	local visible = RosterFilterFrame:IsVisible()
	if visible then
		RosterFilterFrame:Hide()
	else
		GuildRoster();
		RosterFilterFrame:Show()
		set_tab(1)
	end
end


function M.print(...)
    DEFAULT_CHAT_FRAME:AddMessage(LIGHTYELLOW_FONT_COLOR_CODE .. '<rosterfilter> ' .. join(map({...}, tostring), ' '))
end


local event_frame = CreateFrame'Frame'
for _, event in pairs{'ADDON_LOADED', 'PLAYER_LOGIN'} do
	event_frame:RegisterEvent(event)
end

local set_handler = {}
M.handle = setmetatable({}, {__metatable=false, __newindex=function(_, k, v) set_handler[k](v) end})

do
	local handlers, handlers2 = {}, {}
	function set_handler.LOAD(f)
		tinsert(handlers, f)
	end
	function set_handler.LOAD2(f)
		tinsert(handlers2, f)
	end
	event_frame:SetScript('OnEvent', function(_, event, arg1, ...)
		if event == 'ADDON_LOADED' then
			if arg1 == 'RosterFilter' then
				for _, f in ipairs(handlers) do f(arg1, ...) end
			end
		elseif event == 'PLAYER_LOGIN' then
			for _, f in ipairs(handlers2) do f(arg1, ...) end
			print('loaded - /rf')
		else
			_M[event](arg1, ...)
		end
	end)
end

function handle.LOAD()
	_G.rosterfilter = rosterfilter or {}
end


function handle.LOAD2()

end


tab_info = {}
function M.tab(name)
	local tab = { name = name }
	local tab_event = {
	OPEN = function(f) tab.OPEN = f end,
	CLOSE = function(f) tab.CLOSE = f end,
	USE_ITEM = function(f) tab.USE_ITEM = f end,
	CLICK_LINK = function(f) tab.CLICK_LINK = f end,
	}
	tinsert(tab_info, tab)
	return setmetatable({}, {__metatable=false, __newindex=function(_, k, v) tab_event[k](v) end})
end

do
	local index
	function M.get_tab() return tab_info[index] end
	function on_tab_click(i)
		do (index and get_tab().CLOSE or pass)() end
		index = i
		do (index and get_tab().OPEN or pass)() end
	end
end

M.orig = setmetatable({[_G]={}}, {__index=function(self, key) return self[_G][key] end})
function M.hook(...)
	local name, object, handler
	if select('#', ...) == 3 then
		name, object, handler = ...
	else
		object, name, handler = _G, ...
	end
	handler = handler or getfenv(3)[name]
	orig[object] = orig[object] or {}
	orig[object][name], object[name] = object[name], handler
	return hook
end