module 'rosterfilter.tabs.friends'

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


-- CONTENT --------------------------------------------------------------------
frame.player_listing = gui.panel(frame.content)
frame.player_listing:SetAllPoints()

player_listing = listing.new(frame.player_listing)

player_listing:SetColInfo{
    {name='C', width=.1, align='LEFT'},
    {name='Name', width=.3, align='LEFT'},
    {name='Lvl', width=.3, align='CENTER'},
    {name='Zone', width=.3, align='CENTER'}
}


player_listing:SetSelection(function(data)
    return;
end)


player_listing:SetHandler('OnClick', function(table, row_data, column, button)
    local friend = row_data.record
    print(friend.name, 'Level', friend.level, friend.class, '-', friend.zone)

    if button == 'RightButton' then
        gui.menu(
            'Whisper', function()
                if (ChatFrameEditBox:IsVisible()) then
                    ChatEdit_OnEscapePressed(ChatFrameEditBox);
                end
                ChatFrameEditBox:SetText('/w '..friend.name);
            end,
            'Invite', function () InviteByName(friend.name) end,
            'Target', function () 
                if (ChatFrameEditBox:IsVisible()) then
                    ChatEdit_OnEscapePressed(ChatFrameEditBox);
                end
                ChatFrameEditBox:SetText('/tar '..friend.name);
                ChatEdit_SendText(ChatFrameEditBox);
            end,
            'Remove Friend', function () RemoveFriend(friend.name) end,
            'Cancel', function () return; end
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

add_button = gui.button(frame.footer)
add_button:SetPoint('TOPRIGHT', close_button, 'TOPLEFT', -padding, 0)
gui.set_size(add_button, 80, frame.footer:GetHeight())
add_button:SetText('Add Friend')
add_button:SetScript('OnClick', function() StaticPopup_Show("ADD_FRIEND") end)

-- motd_label = gui.label(frame.footer, gui.font_size.small)
-- motd_label:SetPoint('TOPLEFT', frame.footer, 'TOPLEFT')
-- motd_label:SetPoint('RIGHT', motd_edit_button, 'LEFT', -padding, 0)
-- motd_label:SetJustifyH('LEFT')
-- motd_label:SetJustifyV('CENTER')
