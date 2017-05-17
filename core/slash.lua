module 'rosterfilter.core.slash'

include 'rosterfilter'


function status(enabled)
	return (enabled and color.green'on' or color.red'off')
end


_G.SLASH_ROSTERFILTER1 = '/rf'
function SlashCmdList.ROSTERFILTER(command)
	if not command then return end
	local arguments = tokenize(command)
    if arguments[1] == 'scale' and tonumber(arguments[2]) then
    	local scale = tonumber(arguments[2])
	    RosterFilterFrame:SetScale(scale)
	    _G.aux_scale = scale
    else
        GuildRoster();
        RosterFilterFrame:Show()
        tab = 1
    end
end