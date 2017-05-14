module 'rosterfilter.tabs.player_listing'

local gui = require 'rosterfilter.gui'
local listing = require 'rosterfilter.gui.listing'


frame = CreateFrame('Frame', nil, RosterFilterFrame)
frame:SetAllPoints()
frame:SetScript('OnUpdate', on_update)
frame:Hide()
frame:SetScript('OnHide', on_hide)

frame.content = CreateFrame('Frame', nil, frame)
frame.content:SetWidth(750)
frame.content:SetPoint('TOP', frame, 'TOP', 0, -8)
frame.content:SetPoint('BOTTOMLEFT', RosterFilterFrame.content, 'BOTTOMLEFT', 0, 0)
frame.content:SetPoint('BOTTOMRIGHT', RosterFilterFrame.content, 'BOTTOMRIGHT', 0, 0)


do
    local function execute()
        query = this:GetText()
        this:SetText(query)
        refresh = true
    end

    do
        local editbox = gui.editbox(frame.content)
        editbox:SetPoint('TOPLEFT', 5, 0)
        editbox:SetWidth(300)
        editbox:SetHeight(25)
        editbox:SetAlignment('CENTER')
        editbox:SetText('online')
        editbox:SetScript('OnTabPressed', function()
            if not IsShiftKeyDown() then
                -- last_page_input:SetFocus()
            end
        end)
        editbox.enter = function() editbox:ClearFocus() end
        editbox.change = execute
    end
end

status_label = gui.label(frame.content, gui.font_size.large)
status_label:SetText('0 / 0 / 0')
status_label:SetPoint('TOPRIGHT', frame.content, 'TOPRIGHT', 0, 0)


frame.player_listing = gui.panel(frame.content)

frame.player_listing:SetHeight(500 - 80)
frame.player_listing:SetWidth(750 - 16)
frame.player_listing:SetPoint('TOPLEFT', 0, -35)


player_listing = listing.new(frame.player_listing)
if not CanViewOfficerNote() then
    player_listing:SetColInfo{
        {name='O', width=.02, align='RIGHT'},
        {name='Name', width=.10, align='LEFT'},
        {name='Lvl', width=.06, align='CENTER'},
        {name='Rank', width=.125, align='RIGHT'},
        {name='Zone', width=.20, align='CENTER'},
        {name='Info', width=.10, align='RIGHT'},
        {name='Note', width=.395, align='RIGHT'},
    }
else
    player_listing:SetColInfo{
        {name='O', width=.02, align='RIGHT'},
        {name='Name', width=.10, align='LEFT'},
        {name='Lvl', width=.06, align='CENTER'},
        {name='Rank', width=.125, align='RIGHT'},
        {name='Zone', width=.20, align='CENTER'},
        {name='Info', width=.10, align='RIGHT'},
        {name='Note', width=.1975, align='RIGHT'},
        {name='Officer Note', width=.1975, align='RIGHT'},
    }
end

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
end)

player_listing:SetHandler('OnDoubleClick', function(table, row_data, column, button)
    return;
end)
