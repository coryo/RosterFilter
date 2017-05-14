module 'rosterfilter.tabs.player_listing'

include 'T'
include 'rosterfilter'

local filters = require 'rosterfilter.filter'


TAB 'Guild'


do
	local c = 0
	function get_refresh() return c end
	function set_refresh(v) c = v end
end

do
    local q = ''
    function get_query() return q end
    function set_query(v) q = v end
end

local roster_update_listener;


function LOAD()

end


function OPEN()
    frame:Show()
    -- "GUILD_MOTD"
    -- "PLAYER_GUILD_UPDATE"
    roster_update_listener = event_listener("GUILD_ROSTER_UPDATE", on_guild_roster_update)
    refresh = true
end


function CLOSE()
    frame:Hide()   
end

function update_listing()
    local data = filters.Query(query)
    player_listing:SetData(data)
    local online, total = filters.PlayerCount();
    status_label:SetText(format('%d / %d / %d', table.getn(data), online, total))
end


function on_update()
    if refresh then
        update_listing()
        refresh = false
    end
end

function on_hide()
    kill_listener(roster_update_listener)
end

do
    function on_guild_roster_update()
        refresh = true
    end
end