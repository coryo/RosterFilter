module 'rosterfilter.tabs.guild'

include 'T'
include 'rosterfilter'

-- local filters = require 'rosterfilter.filter'


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

local roster_update_listener, player_guild_update_listener, motd_listener;


function LOAD()
    
end


function OPEN()
    local guildName,_,_ = GetGuildInfo('player');
    name_label:SetText(format('<%s>', guildName))
    roster_update_listener = event_listener("GUILD_ROSTER_UPDATE", function() refresh = true; end)
    player_guild_update_listener = event_listener("PLAYER_GUILD_UPDATE", function() refresh = true; end)
    motd_listener = event_listener("GUILD_MOTD", function(self, message) motd_label:SetText(message); end)

    if not CanEditMOTD() then
        motd_edit_button:Disable()
    end

    motd_label:SetText(GetGuildRosterMOTD())

    frame:Show()
    refresh = true
end


function CLOSE()
    frame:Hide()   
end


function update_listing()
    local data = Query(query)
    player_listing:SetData(data)
    local online, total = PlayerCount();
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
    kill_listener(player_guild_update_listener)
    kill_listener(motd_listener)
end
