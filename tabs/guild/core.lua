select(2, ...) 'rosterfilter.tabs.guild'

local rosterfilter = require 'rosterfilter'

local tab = rosterfilter.tab 'Guild'


local roster_update_listener, player_guild_update_listener, motd_listener;


function rosterfilter.handle.LOAD()

end


function tab.OPEN()
    -- leave tab if not in a guild
    if not IsInGuild() then rosterfilter.set_tab(2); return; end

    local guildName,_,_ = GetGuildInfo('player');
    name_label:SetText(format('<%s>', guildName))
    roster_update_listener = rosterfilter.event_listener("GUILD_ROSTER_UPDATE", function() refresh = true; end)
    player_guild_update_listener = rosterfilter.event_listener("PLAYER_GUILD_UPDATE", function() refresh = true; end)
    motd_listener = rosterfilter.event_listener("GUILD_MOTD", function(self, message) motd_label:SetText(message); end)

    if not CanEditMOTD() then
        motd_edit_button:Disable()
    end

    motd_label:SetText(GetGuildRosterMOTD())

    frame:Show()
    refresh = true
end


function tab.CLOSE()
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
    rosterfilter.kill_listener(roster_update_listener)
    rosterfilter.kill_listener(player_guild_update_listener)
    rosterfilter.kill_listener(motd_listener)
end
