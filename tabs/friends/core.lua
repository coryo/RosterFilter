module 'rosterfilter.tabs.friends'

include 'T'
include 'rosterfilter'

TAB 'Friends'

local locale = require 'rosterfilter.locale'
local zones = require 'rosterfilter.locale.zone'
local L = locale.L

local friends_cache = T;
local friendlist_update_listener;

do
	local c = 0
	function get_refresh() return c end
	function set_refresh(v) c = v end
end


function LOAD()
    
end


function OPEN()
    friendlist_update_listener = event_listener("FRIENDLIST_UPDATE", function() refresh = true; end)
    local friends = GetNumFriends();
    if friends >= 50 then
        add_button:Disable()
    end
    frame:Show()
    refresh = true
end


function CLOSE()
    frame:Hide()
end


function update_listing()
    wipe(friends_cache)

    local friends = GetNumFriends();
    
    local rows = T;

    for i = 1, friends do
        local name, level, class, area, connected, status = GetFriendInfo(i);
        
        local friend = O(
            'name', name,
            'level', level,
            'class', class,
            'zone', area,
            'online', connected == 1,
            'status', status
        )
        tinsert(friends_cache, friend)

        local alpha = 1.0;
        if not friend.online then
            alpha = 0.4;
        end

        local zone_color;
        if zones.IsBattleground(friend.zone) then
            zone_color = color.red
        elseif zones.IsDungeon(friend.zone) then
            zone_color = color.blue
        elseif zones.IsCity(friend.zone) then
            zone_color = color.green
        else
            zone_color = color.text.enabled
        end        
        
        local class_color = color.class[strlower(friend.class)] or color.text.enabled
        
        tinsert(rows, O(
            'cols', A(
                O('name', 'class', 'value', '', 'sort', friend.class),
                O('name', 'name', 'value', class_color(friend.name) .. ' ' .. friend.status, 'sort', friend.name),
                O('name', 'level', 'value', friend.level, 'sort', tonumber(friend.level)),
                O('name', 'zone', 'value', zone_color(friend.zone), 'sort', friend.zone),
                O('name', 'online', 'value', friend.online, 'sort', friend.online)
            ),
            'record', friend,
            'alpha', alpha
        ))

    end

    player_listing.sortColumn = 5
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
    kill_listener(friendlist_update_listener)
end
