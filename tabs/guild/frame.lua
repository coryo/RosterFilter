select(2, ...) 'rosterfilter.tabs.guild'

local rosterfilter = require 'rosterfilter'
local gui = require 'rosterfilter.gui'
local listing = require 'rosterfilter.gui.listing'

local padding = 5

frame = CreateFrame('Frame', nil, RosterFilterFrame.content)
frame:SetAllPoints()
frame:SetScript('OnUpdate', on_update)
frame:Hide()
frame:SetResizable(true)
frame:SetScript('OnHide', on_hide)

frame.header = CreateFrame('Frame', nil, frame)
frame.header:SetHeight(25)
frame.header:SetPoint('TOP', frame, 'TOP', 0, -padding)
frame.header:SetPoint('LEFT', frame, 'LEFT', padding, 0)
frame.header:SetPoint('RIGHT', frame, 'RIGHT', -padding, 0)

frame.footer = CreateFrame('Frame', nil, frame)
frame.footer:SetHeight(25)
frame.footer:SetPoint('BOTTOM', frame, 'BOTTOM', 0, padding)
frame.footer:SetPoint('LEFT', frame, 'LEFT', padding, 0)
frame.footer:SetPoint('RIGHT', frame, 'RIGHT', -padding, 0)

frame.content = CreateFrame('Frame', nil, frame)
frame.content:SetWidth(frame:GetWidth() - 2*padding)
frame.content:SetPoint('TOP', frame.header, 'BOTTOM', 0, -padding)
frame.content:SetPoint('BOTTOMLEFT', frame.footer, 'TOPLEFT', 0, padding)
frame.content:SetPoint('BOTTOMRIGHT', frame.footer, 'TOPRIGHT', 0, padding)

frame.content:SetScript('OnSizeChanged', function(width, height)
    refresh = true
end)

-- HEADER ---------------------------------------------------------------------
do
    local function execute(self)
        query = self:GetText()
        self:SetText(query)
        refresh = true
    end

    do
        local editbox = gui.editbox(frame.header)
        editbox:SetPoint('TOPLEFT', 0, 0)
        editbox:SetWidth(250)
        editbox:SetHeight(frame.header:GetHeight())
        editbox:SetAlignment('CENTER')
        -- default filter
        editbox:SetText('online')
        -- focus the editbox when its shown
        -- editbox:SetScript('OnShow', function()
        --     editbox:SetFocus()
        -- end)

        editbox.enter = function(self) execute(self) end
        editbox.change = execute

        -- shortcut buttons
        local button1 = gui.button(editbox)
        button1:SetPoint('TOPLEFT', editbox, 'TOPRIGHT', 5, 0)
        button1:SetText('Clear')
        gui.set_size(button1, 50, 25)
        button1:SetScript('OnClick', function()
            editbox:SetText('');
            editbox:SetFocus();
            refresh=true;
        end)

        local button2 = gui.button(editbox)
        button2:SetPoint('TOPLEFT', button1, 'TOPRIGHT', 5, 0)
        button2:SetText('Online')
        gui.set_size(button2, 50, 25)
        button2:SetScript('OnClick', function()
            editbox:SetText('online');
            editbox:SetFocus();
            refresh=true;
        end)
    end
end

name_label = gui.label(frame.header, gui.font_size.medium)
name_label:SetPoint('TOPRIGHT', frame.header, 'TOPRIGHT', 0, 0)

status_label = gui.label(frame.header, gui.font_size.small)
status_label:SetText('0 / 0 / 0')
status_label:SetPoint('TOPRIGHT', name_label, 'BOTTOMRIGHT', -padding, 0)


-- CONTENT --------------------------------------------------------------------
frame.player_listing = gui.panel(frame.content)
frame.player_listing:SetAllPoints()

player_listing = listing.new(frame.player_listing)

player_listing:SetColInfo{
    {name='C', width=.02, align='LEFT'},
    {name='Name', width=.20, align='LEFT'},
    {name='L', width=.03, align='CENTER'},
    {name='Rank', width=.20, align='RIGHT'},
    {name='Zone', width=.20, align='CENTER'},
    -- {name='Info', width=.10, align='RIGHT'},
    {name='Note', width=.35, align='RIGHT'},
}

player_listing.tooltipCols = {2, 6, 7, 8}


player_listing:SetSelection(function(data)
    return;
end)


player_listing:SetHandler('OnClick', function(table, row_data, column, button)
    local member = row_data.record
    print(member.name, 'Level', member.level, member.class, '-', member.zone)

    if member.note ~= '' then
        print('Note:', member.note)
    end

    if CanViewOfficerNote() and member.officer_note ~= '' then
        print('ONote:', member.officer_note)
    end

    local edit_note = nil
    local edit_note_func = nil;
    if CanEditPublicNote() then
        edit_note = 'Edit Note';
        edit_note_func = function()
            SetGuildRosterSelection(member.index)
            StaticPopup_Show("SET_GUILDPLAYERNOTE")
        end
    end

    local edit_onote = nil
    local edit_onote_func = nil;
    if CanEditOfficerNote() then
        edit_onote = 'Edit Officer Note';
        edit_onote_func = function()
            SetGuildRosterSelection(member.index)
            StaticPopup_Show("SET_GUILDOFFICERNOTE")
        end
    end

    local ranks = {}
    local _,_,player_rank = GetGuildInfo("player")
    if CanGuildPromote() and member.rank_index > player_rank then
        for i = player_rank + 1, member.rank_index do
            ranks[i] = true
        end
    end
    if CanGuildDemote() and member.rank_index > player_rank then
        for i = member.rank_index + 1, 9 do
            ranks[i] = true
        end
    end

    local options = {}
    for rank in pairs(ranks) do
        if rank ~=  member.rank_index then
            tinsert(options, "- set " .. index_to_rank(rank))
            tinsert(options, {
                function(arg1)
                    local cur_rank = member.rank_index;
                    local target_rank = arg1;
                    local diff = math.abs(target_rank-cur_rank)
                    print(member.name, index_to_rank(cur_rank), ">", index_to_rank(target_rank));
                    if cur_rank == target_rank then
                        return
                    elseif target_rank < cur_rank then
                        for i = 1, diff do GuildPromoteByName(member.name); end;
                    else
                        for i = 1, diff do GuildDemoteByName(member.name); end;
                    end
                end,
                rank
            })
        end
    end


    if button == 'RightButton' then
        gui.menu(
            'Whisper', function()
                if (DEFAULT_CHAT_FRAME.editBox:IsVisible()) then
                    ChatEdit_OnEscapePressed(DEFAULT_CHAT_FRAME.editBox);
                end
                DEFAULT_CHAT_FRAME.editBox:Show()
                DEFAULT_CHAT_FRAME.editBox:SetText('/w '..member.name .. ' ');
            end,
            'Invite', function () InviteUnit(member.name) end,
            edit_note, edit_note_func,
            edit_onote, edit_onote_func,
            'Cancel', function () return; end,
            unpack(options)
        )
    end
end)


player_listing:SetHandler('OnDoubleClick', function(table, row_data, column, button)
    return;
end)


-- FOOTER ---------------------------------------------------------------------
local btn = gui.button(frame.footer)
btn:SetPoint('BOTTOMRIGHT', frame.footer, 'BOTTOMRIGHT')
gui.set_size(btn, 60, frame.footer:GetHeight())
btn:SetText('Close')
btn:SetScript('OnClick', function() RosterFilterFrame:Hide() end)
close_button = btn

motd_edit_button = gui.button(frame.footer)
motd_edit_button:SetPoint('TOPRIGHT', close_button, 'TOPLEFT', -padding, 0)
gui.set_size(motd_edit_button, 60, frame.footer:GetHeight())
motd_edit_button:SetText('MOTD')
motd_edit_button:SetScript('OnClick', function() StaticPopup_Show("SET_GUILDMOTD") end)

motd_label = gui.label(frame.footer, gui.font_size.small)
motd_label:SetPoint('TOPLEFT', frame.footer, 'TOPLEFT')
motd_label:SetPoint('BOTTOMRIGHT', motd_edit_button, 'BOTTOMLEFT', -padding, 0)
motd_label:SetJustifyH('LEFT')
motd_label:SetJustifyV('CENTER')
