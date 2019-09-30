select(2, ...) 'rosterfilter.core.slash'

local rosterfilter = require 'rosterfilter'


function status(enabled)
	return (enabled and rosterfilter.color.green'on' or rosterfilter.color.red'off')
end


_G.SLASH_ROSTERFILTER1 = '/rf'
function SlashCmdList.ROSTERFILTER(command)
	if not command then return end
	local arguments = rosterfilter.tokenize(command)
    if arguments[1] == 'scale' and tonumber(arguments[2]) then
    	local scale = tonumber(arguments[2])
	    RosterFilterFrame:SetScale(scale)
	    _G.rf_scale = scale
    else
        GuildRoster();
        RosterFilterFrame:Show()
        rosterfilter.set_tab(1)
    end
end