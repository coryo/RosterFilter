select(2, ...) 'rosterfilter.tabs.guild'

local rosterfilter = require 'rosterfilter'

local tab = rosterfilter.tab 'Guild'


local roster_update_listener, player_guild_update_listener, motd_listener;
map_cache = {}


function rosterfilter.handle.LOAD()
    for i = 1, 3000 do
        local info = C_Map.GetMapInfo(i)
        if info and info.mapID then
            map_cache[info.name] = info.mapID
        end
    end

    rosterfilter.RegisterKeyChangedCallback("notes", function(value)
        if value then
            player_listing:SetColInfo{
                {name='C', width=10, align='LEFT', fixed=true},
                {name='Name', width=80, align='LEFT', fixed=true},
                {name='L', width=15, align='CENTER', fixed=true},
                {name='Rank', width=90, align='RIGHT', fixed=true},
                {name='Zone', width=120, align='CENTER', fixed=true},
                {name='Note', width=1, align='RIGHT'},
            }
        else
            player_listing:SetColInfo{
                {name='C', width=10, align='LEFT', fixed=true},
                {name='Name', width=80, align='LEFT', fixed=true},
                {name='L', width=15, align='CENTER', fixed=true},
                {name='Rank', width=90, align='RIGHT', fixed=true},
                {name='Zone', width=1, align='CENTER'},
            }
        end
    end)

    rosterfilter.RegisterKeyChangedCallback("showguildname", function(value)
        if value then name_label:Show() else name_label:Hide() end
    end)

    rosterfilter.RegisterKeyChangedCallback("shownumbers", function(value)
        if value then status_label:Show() else status_label:Hide() end
    end)

    _G.StaticPopupDialogs["GENERIC_INPUT_BOX"] = {
		text = "",		-- supplied dynamically.
		button1 = "",	-- supplied dynamically.
		button2 = "",	-- supplied dynamically.
		hasEditBox = 1,
		OnShow = function(self, data)
			self.text:SetFormattedText(data.text, data.text_arg1, data.text_arg2);
			self.button1:SetText(data.acceptText or DONE);
			self.button2:SetText(data.cancelText or CANCEL);

			self.editBox:SetMaxLetters(data.maxLetters or 24);
			self.editBox:SetCountInvisibleLetters(not not data.countInvisibleLetters);
			self.editBox:SetText(data.text2)
			self.editBox:HighlightText()
		end,
		OnAccept = function(self, data)
			local text = self.editBox:GetText();
			data.callback(text);
		end,
		OnCancel = function(self, data)
			local cancelCallback = data.cancelCallback;
			if cancelCallback ~= nil then
				cancelCallback();
			end
		end,
		EditBoxOnEnterPressed = function(self, data)
			local parent = self:GetParent();
			if parent.button1:IsEnabled() then
				local text = parent.editBox:GetText();
				data.callback(text);
				parent:Hide();
			end
		end,
		EditBoxOnEscapePressed = function(self, data)
			local parent = self:GetParent();
			if parent.button1:IsEnabled() then
				local text = parent.editBox:GetText();
				data.callback(text);
				parent:Hide();
			end
		end,
		hideOnEscape = 1,
		timeout = 0,
		exclusive = 1,
		whileDead = 1,
	};
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
    else
        motd_edit_button:Enable()
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
