module 'rosterfilter.tabs.player_listing'

local gui = require 'rosterfilter.gui'
local listing = require 'rosterfilter.gui.listing'
local filter = require 'rosterfilter.filter'


frame = CreateFrame('Frame', nil, RosterFilterFrame)
frame:SetAllPoints()
frame:SetScript('OnUpdate', on_update)
frame:Hide()

frame.content = CreateFrame('Frame', nil, frame)
frame.content:SetWidth(750)
frame.content:SetPoint('TOP', frame, 'TOP', 0, -8)
frame.content:SetPoint('BOTTOMLEFT', RosterFilterFrame.content, 'BOTTOMLEFT', 0, 0)
frame.content:SetPoint('BOTTOMRIGHT', RosterFilterFrame.content, 'BOTTOMRIGHT', 0, 0)



do
    local function execute()
        local query = this:GetText()
        this:SetText(query)
        local data = filter.Query(query)
        player_listing:SetData(data)
    end

    do
        local editbox = gui.editbox(frame.content)
        editbox:SetPoint('TOPLEFT', 5, 0)
        editbox:SetWidth(300)
        editbox:SetHeight(25)
        editbox:SetAlignment('CENTER')
        editbox:SetScript('OnTabPressed', function()
            if not IsShiftKeyDown() then
                -- last_page_input:SetFocus()
            end
        end)
        editbox.enter = function() editbox:ClearFocus() execute() end
        editbox.change = execute
    end
end


DEFAULT_CHAT_FRAME:AddMessage("player_listing LOAD")
frame.player_listing = gui.panel(frame.content)

frame.player_listing:SetHeight(500-80)
frame.player_listing:SetWidth(750 - 16)
frame.player_listing:SetPoint('TOPLEFT', 0, -25)


player_listing = listing.new(frame.player_listing)
player_listing:SetColInfo{
    {name='O', width=.02, align='RIGHT'},
    {name='Name', width=.23, align='LEFT'},
    {name='Lvl', width=.06, align='CENTER'},
    -- {name='Class', width=.125, align='LEFT'},
    {name='Rank', width=.125, align='RIGHT'},
    {name='Zone', width=.20, align='CENTER'},
    {name='Note', width=.365, align='RIGHT'},
} 

player_listing:SetSelection(function(data)
    return;
end)

player_listing:SetHandler('OnClick', function(table, row_data, column, button)
    print(row_data.record.name)
end)

player_listing:SetHandler('OnDoubleClick', function(table, row_data, column, button)
    return;
end)
