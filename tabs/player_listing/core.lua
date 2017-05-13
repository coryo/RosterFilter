module 'rosterfilter.tabs.player_listing'

include 'T'
include 'rosterfilter'

TAB 'Guild'


do
	local c = 0
	function get_refresh() return c end
	function set_refresh(v) c = v end
end


function OPEN()
    frame:Show()
    refresh = true
end


function CLOSE()
    -- selected_item = nil
    frame:Hide()
end


function on_update()
    if refresh then
        refresh= false
    end
end