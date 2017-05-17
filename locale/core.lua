module 'rosterfilter.locale'

require 'T'

local default = 'enUS'
local active_locale = GetLocale()

local database = T

local translations = {}
translations.mt = {}
function translations.new(o)
    setmetatable(o, translations.mt)
    return o
end
translations.mt.__index = function(self, key)
    if active_locale == default then
        return key
    else
        return database[key]
    end
end


M.L = translations.new{}


function M.RegisterTranslations(locale, func)
    if active_locale == default then return; end

    if locale == active_locale then
        local t = func()
        func = nil
        for k, v in pairs(t) do
            database[k] = v
        end
    end
end
