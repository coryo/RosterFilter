select(2, ...) 'rosterfilter.tabs.guild'

local rosterfilter = require 'rosterfilter'
local zones = require 'rosterfilter.zones'


local member_cache = {}
local rank_cache = {}
local total_count = 0
local online_count = 0

function M.index_to_rank(index)
    return rank_cache[index]
end


function M.rank_to_index(rank)
    for i, name in pairs(rank_cache) do
        if strlower(name) == strlower(rank) then return i; end;
    end
end


M.filters = {
    ['default-filter'] = {
        input_type = 'string',
        validator = function(str)
            return function(member)
                local qry = strlower(str)
                local search = strlower(member.name..member.level..member.class..member.rank..member.zone..member.note..member.officer_note)
                return string.find(search, qry)
            end
        end
    },
    ['class'] = {
        input_type = 'string',
        validator = function(class_name)
            return function(member)
                return strlower(member.class) == strlower(class_name)
            end
        end
    },
    ['rank'] = {
        input_type = 'string',
        validator = function(rank)
            return function(member)
                local modifier_index = strfind(rank, "[+-]", -1)
                if modifier_index ~= nil then
                    local rank_name = strsub(rank, 1, modifier_index - 1)
                    local modifier = strsub(rank, modifier_index)
                    local rank_index = rank_to_index(rank_name);
                    if modifier == "+" then
                        return member.rank_index <= rank_index
                    else
                        return member.rank_index >= rank_index
                    end
                end
                return strlower(member.rank) == strlower(rank)
            end
        end
    },
    ['online'] = {
        input_type = '',
        validator = function()
            return function(member)
                return member.online
            end
        end
    },
    ['raid'] = {
        input_type = '',
        validator = function()
            return function(member)
                if GetNumGroupMembers() == 0 then return false; end;
                for i = 1, 40 do
                    local name,_,_,_,_,_,_,_,_,_,_ = GetRaidRosterInfo(i)
                    if name and strlower(name) == strlower(member.name) then return true; end;
                end
                return false
            end
        end
    },
    ['raid-'] = {
        input_type = '',
        validator = function()
            return function(member)
                if GetNumGroupMembers() == 0 then return true; end;
                for i = 1, 40 do
                    local name,_,_,_,_,_,_,_,_,_,_ = GetRaidRosterInfo(i)
                    if name and strlower(name) == strlower(member.name) then return false; end;
                end
                return true
            end
        end
    },
    ['zone'] = {
        input_type = 'string',
        validator = function(zone)
            return function(member)
                return strfind(strlower(member.zone), strlower(zone))
            end
        end
    },
    ['offline'] = {
        input_type = 'string',
        validator = function(days)
            return function(member)
                return member.offline and (member.offline / 24) >= (tonumber(days) or 0)
            end
        end
    },
    ['role'] = {
        input_type = 'string',
        validator = function(role)
            return function(member)
                local cls = member.classFile;
                local role = strlower(role);
                if role == 'heal' or role == 'healer' then
                    return cls == 'PRIEST' or cls == 'PALADIN' or cls == 'DRUID' or cls == 'SHAMAN';
                elseif role == 'dps' then
                    return cls == 'ROGUE' or cls == 'WARRIOR' or cls == 'MAGE' or cls == 'WARLOCK' or cls=='HUNTER' or cls == 'DEATHKNIGHT';
                elseif role == 'caster' then
                    return cls == 'MAGE' or cls == 'WARLOCK' or cls == 'SHAMAN' or cls == 'DRUID';
                elseif role == 'tank' then
                    return cls == 'WARRIOR' or cls == 'DRUID' or cls == 'PALADIN' or cls == 'DEATHKNIGHT';
                elseif role == 'melee' then
                    return cls == 'WARRIOR' or cls == 'ROGUE' or cls == 'PALADIN' or cls == 'DRUID' or cls == 'DEATHKNIGHT';
                elseif role == 'ranged' then
                    return cls =='MAGE' or cls == 'HUNTER' or cls=='WARLOCK';
                end
                return false
            end
        end
    },
    ['lvl'] = {
        input_type == 'string',
        validator = function(str)
            return function(member)
                local min = 1;
                local max = 60;

                local parts = str and rosterfilter.map(rosterfilter.split(str, '-'), function(part) return rosterfilter.trim(part) end) or {}

                if parts[1] ~= '' and parts[1] ~= nil then
                    min = tonumber(parts[1]) or 1
                    max = tonumber(parts[2]) or min
                end

                return (member.level >= min) and (member.level <= max);
            end
        end
    }
}


function M.parse_filter_string(str)
    local used_filters = {}

    local parts = str and rosterfilter.map(rosterfilter.split(str, '/'), function(part) return strlower(rosterfilter.trim(part)) end) or ''

    local i = 1;
    while parts[i] do
        if filters[parts[i]] then
            local input_type = filters[parts[i]].input_type
            if input_type ~= '' then
                tinsert(used_filters, {filter=parts[i], args=(parts[i + 1] or '')})
                i = i + 1
            else
                tinsert(used_filters, {filter=parts[i], args=''})
            end
        else
            tinsert(used_filters, {filter='default-filter', args=parts[i]})
        end
        i = i + 1
    end

    return used_filters
end

function M.Query(str)
    local used_filters = parse_filter_string(str)

    UpdateRoster()

    local working_set = {}

    for i = 1, table.getn(member_cache) do
        tinsert(working_set, i)
    end

    for i, filter in pairs(used_filters) do
        if filters[filter.filter] then
            local validator = filters[filter.filter].validator(filter.args)
            local subset = {}

            for _,index in pairs(working_set) do
                local member = member_cache[index]
                if validator(member) then
                    tinsert(subset, index)
                end
            end
            working_set = subset
        end
    end

    local rows = {}
    for _,index in pairs(working_set) do
        local member = member_cache[index]

        local info_text;
        local alpha = 1.0;
        if not member.online then
            alpha = 0.4;

            local days = member.offline / 24;
            if days < 2 then
                info_text = format('%d hours', member.offline)
            else
                info_text = format('%d days', days)
            end
        end

        local zone_color;
        if zones.IsBattleground(member.mapID) then
            zone_color = rosterfilter.color.red
        elseif member.zone == "Naxxramas" or zones.IsRaid(member.mapID) then
            zone_color = rosterfilter.color.blue
        elseif member.zone == "Magisters' Terrace" or zones.IsDungeon(member.mapID) then
            zone_color = rosterfilter.color.lightblue
        elseif zones.IsCity(member.mapID) then
            zone_color = rosterfilter.color.green
        else
            zone_color = rosterfilter.color.text.enabled
        end
        -- local num_ranks = table.getn(rank_cache)
        tinsert(rows, {
            ['cols'] = {
                {['name'] = 'class', ['value'] = '', ['sort'] = member.class},
                {['name'] = 'name', ['value'] = RAID_CLASS_COLORS[member.classFile]:WrapTextInColorCode(member.name), ['sort'] = member.name},
                {['name'] = 'level', ['value'] = member.level, ['sort'] = tonumber(member.level)},
                {['name'] = 'rank', ['value'] = member.rank, ['sort'] = member.rank_index},
                -- {['name'] = '', ['value'] = format('%s (%d)', member.rank, num_ranks - member.rank_index + 1), ['sort'] = member.rank_index},
                {['name'] = 'zone', ['value'] = zone_color(member.zone), ['sort'] = member.zone},
                {['name'] = 'note', ['value'] = member.note, ['sort'] = member.note},
                {['name'] = 'info', ['value'] = info_text, ['sort'] = member.offline},
                {['name'] = 'officer note', ['value'] = member.officer_note, ['sort'] = member.officer_note}
            },
            ['record'] = member,
            ['alpha'] = alpha
        })
    end

    return rows or nil
end


function M.UpdateRoster()
    rosterfilter.wipe(member_cache)
    rank_cache = {}
    total_count = 0
    online_count = 0

    local guild_members, num_online_max, num_online = GetNumGuildMembers();

    for i = 1, guild_members do
        local name, rank, rank_index, level, class, zone, note, officer_note, online, status, classFileName = GetGuildRosterInfo(i);

        if name then
            local member = {
                ['name'] = Ambiguate(name, "none"),
                ['rank'] = rank,
                ['rank_index'] = rank_index,
                ['level'] = level,
                ['class'] = class,
                ['classFile'] = classFileName,
                ['zone'] = zone or 'unknown',
                ['mapID'] = map_cache[zone] or 0,
                ['note'] = note,
                ['officer_note'] = officer_note,
                ['online'] = online,
                ['offline'] = 0,
                ['index'] = i
            }
            if not online then
                local years, months, days, hours = GetGuildRosterLastOnline(i);
                local toff = (((years*12)+months)*30.5+days)*24+hours;
                member.offline = toff
            else
                online_count = online_count + 1
            end
            tinsert(member_cache, member)

            total_count = total_count + 1
        end
    end

    for i = 1, GuildControlGetNumRanks() do
        rank_cache[i - 1] = GuildControlGetRankName(i);
    end
end


function M.PlayerCount()
    return online_count, total_count
end
