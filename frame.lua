module 'rosterfilter'

local gui = require 'rosterfilter.gui'

function LOAD()
	for i = 1, getn(tab_info) do
		tabs:create_tab(tab_info[i].name)
	end
end

do
    local frame = CreateFrame('Frame', 'RosterFilterFrame', UIParent)
    gui.set_window_style(frame)
    gui.set_size(frame, 750, 500)
    frame:SetPoint('LEFT', 750, 0)
    frame:SetToplevel(true)
	frame:SetMovable(true)
	frame:EnableMouse(true)
	frame:SetClampedToScreen(true)
	frame:RegisterForDrag('LeftButton')
	frame:SetScript('OnDragStart', function() this:StartMoving() end)
	frame:SetScript('OnDragStop', function() this:StopMovingOrSizing() end)
	frame:SetScript('OnShow', function() PlaySound('AuctionWindowOpen') end)
	frame:SetScript('OnHide', function() PlaySound('AuctionWindowClose'); end)
	frame.content = CreateFrame('Frame', nil, frame)
	frame.content:SetPoint('TOPLEFT', 4, -80)
	frame.content:SetPoint('BOTTOMRIGHT', -4, 35)
	frame:Hide()
	M.RosterFilterFrame = frame
end

do
	tabs = gui.tabs(RosterFilterFrame, 'DOWN')
	tabs._on_select = on_tab_click
	function M.set_tab(id) tabs:select(id) end
end

do
	local btn = gui.button(RosterFilterFrame)
	btn:SetPoint('BOTTOMRIGHT', -5, 5)
	gui.set_size(btn, 60, 24)
	btn:SetText('Close')
	btn:SetScript('OnClick', function() RosterFilterFrame:Hide() end)
	close_button = btn
end
