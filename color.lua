select(2, ...) 'rosterfilter'

local rosterfilter = require 'rosterfilter'

function C(r, g, b, a)
	local mt = { __metatable = false, __newindex = pass, color = {r, g, b, a} }
	function mt:__call(text)
		local r, g, b, a = unpack(mt.color)
		if text then
			return format('|c%02X%02X%02X%02X', a, r, g, b) .. text .. FONT_COLOR_CODE_CLOSE
		else
			return r/255, g/255, b/255, a
		end
	end
	function mt:__concat(text)
		local r, g, b, a = unpack(mt.color)
		return format('|c%02X%02X%02X%02X', a, r, g, b) .. text
	end
	return setmetatable({}, mt)
end

M.color = rosterfilter.immutable-{
	none = setmetatable({}, {__metatable=false, __newindex=nop, __call=function(_, v) return v end, __concat=function(_, v) return v end}),
	text = rosterfilter.immutable-{enabled = C(255, 254, 250, 1), disabled = C(147, 151, 139, 1)},
	label = rosterfilter.immutable-{enabled = C(216, 225, 211, 1), disabled = C(150, 148, 140, 1)},
	link = C(153, 255, 255, 1),
	window = rosterfilter.immutable-{background = C(24, 24, 24, .93), border = C(30, 30, 30, 1)},
	panel = rosterfilter.immutable-{background = C(24, 24, 24, 1), border = C(255, 255, 255, .03)},
	content = rosterfilter.immutable-{background = C(42, 42, 42, 1), border = C(0, 0, 0, 0)},
	state = rosterfilter.immutable-{enabled = C(70, 140, 70, 1), disabled = C(140, 70, 70, 1)},

	tooltip = rosterfilter.immutable-{
		value = C(255, 255, 154, 1),
		merchant = C(204, 127, 25, 1),
		disenchant = rosterfilter.immutable-{
			value = C(25, 153, 153, 1),
			distribution = C(204, 204, 51, 1),
			source = C(178, 178, 178, 1),
		}
	},

	blue = C(41, 146, 255, 1),
	green = C(22, 255, 22, 1),
	yellow = C(255, 255, 0, 1),
	orange = C(255, 146, 24, 1),
	red = C(255, 0, 0, 1),
	gray = C(187, 187, 187, 1),
	gold = C(255, 255, 154, 1),

	blizzard = C(0, 180, 255, 1),

	class = rosterfilter.immutable-{
		druid = C(255, 125, 10, 1),
		hunter = C(171, 212, 115, 1),
		mage = C(105, 204, 240, 1),
		paladin = C(245, 140, 186, 1),
		priest = C(255, 255, 255, 1),
		rogue = C(255, 245, 105, 1),
		shaman = C(0, 112, 222, 1),
		warlock = C(148, 130, 201, 1),
		warrior = C(199, 156, 110, 1)
	}
}
