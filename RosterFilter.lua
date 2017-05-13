module 'rosterfilter'

include 'T'

_G.rf_scale = 1


function M.print(...)
    DEFAULT_CHAT_FRAME:AddMessage(LIGHTYELLOW_FONT_COLOR_CODE .. '<rosterfilter> ' .. join(map(arg, tostring), ' '))
end


local event_frame = CreateFrame'Frame'
for event in temp-S('ADDON_LOADED', 'VARIABLES_LOADED', 'PLAYER_LOGIN') do
	event_frame:RegisterEvent(event)
end


do
	local handlers, handlers2 = {}, {}
	function M.set_LOAD(f)
		tinsert(handlers, f)
	end
	function M.set_LOAD2(f)
		tinsert(handlers2, f)
	end
	event_frame:SetScript('OnEvent', function()
		if event == 'ADDON_LOADED' then
            --
		elseif event == 'VARIABLES_LOADED' then
			for _, f in handlers do f() end
		elseif event == 'PLAYER_LOGIN' then
			for _, f in handlers2 do f() end
			print('loaded - /rf')
		else
			_M[event]()
		end
	end)
end


function LOAD2()
	RosterFilterFrame:SetScale(rf_scale)
end


tab_info = {}
function M.TAB(name)
	local tab = O('name', name)
	local env = getfenv(2)
	function env.set_OPEN(f) tab.OPEN = f end
	function env.set_CLOSE(f) tab.CLOSE = f end
	function env.set_USE_ITEM(f) tab.USE_ITEM = f end
	function env.set_CLICK_LINK(f) tab.CLICK_LINK = f end
	tinsert(tab_info, tab)
end


do
	local index
	function get_active_tab() return tab_info[index] end
	function on_tab_click(i)
		CloseDropDownMenus()
		do (index and active_tab.CLOSE or nop)() end
		index = i
		do (index and active_tab.OPEN or nop)() end
	end
end
