select(2, ...) 'rosterfilter.tabs.friends'

local rosterfilter = require 'rosterfilter'

local tab = rosterfilter.tab 'Friends'

local locale = require 'rosterfilter.locale'
local zones = require 'rosterfilter.locale.zone'
local L = locale.L

local friends_cache = {};
local friendlist_update_listener;


function rosterfilter.handle.LOAD()

end


function tab.OPEN()
    friendlist_update_listener = rosterfilter.event_listener("FRIENDLIST_UPDATE", function() refresh = true; end)
    local friends = C_FriendList.GetNumFriends();
    if friends >= 50 then
        add_button:Disable()
    end
    frame:Show()
    refresh = true
end


function tab.CLOSE()
    frame:Hide()
end


function update_listing()
    rosterfilter.wipe(friends_cache)

    local friends = C_FriendList.GetNumFriends();

    local rows = {};

    for i = 1, friends do
        local info = C_FriendList.GetFriendInfoByIndex(i);
        local status = "";
        if info.dnd then status = "DND" elseif info.afk then status = "AFK" end

        local friend = {
            ['name'] = info.name,
            ['level'] = info.level,
            ['class'] = info.className,
            ['zone'] = info.area,
            ['online'] = info.connected,
            ['status'] = status,
            ['notes'] = info.notes
        }
        tinsert(friends_cache, friend)

        local alpha = 1.0;
        if not friend.online then
            alpha = 0.4;
        end

        local zone_color;
        if zones.IsBattleground(friend.zone) then
            zone_color = rosterfilter.color.red
        elseif zones.IsDungeon(friend.zone) then
            zone_color = rosterfilter.color.blue
        elseif zones.IsCity(friend.zone) then
            zone_color = rosterfilter.color.green
        else
            zone_color = rosterfilter.color.text.enabled
        end

        local class_color = rosterfilter.color.class[strlower(friend.class)] or rosterfilter.color.text.enabled

        tinsert(rows, {
            ['cols'] = {
                {['name'] = 'class', ['value'] = '', ['sort'] = friend.class},
                {['name'] = 'name', ['value'] = class_color(friend.name) .. ' ' .. friend.status, ['sort'] = friend.name},
                {['name'] = 'level', ['value'] = friend.level, ['sort'] = tonumber(friend.level)},
                {['name'] = 'zone', ['value'] = zone_color(friend.zone), ['sort'] = friend.zone},
                {['name'] = 'notes', ['value'] = friend.notes, ['sort'] = friend.notes},
                {['name'] = 'online', ['value'] = friend.online, ['sort'] = friend.online}
            },
            ['record'] = friend,
            ['alpha'] = alpha
        })

    end

    player_listing.sortColumn = 6
    player_listing.sortInvert = true
    player_listing:SetData(rows)
end


function on_update()
    if refresh then
        update_listing()
        refresh = false
    end
end


function on_hide()
    rosterfilter.kill_listener(friendlist_update_listener)
end
