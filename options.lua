select(2, ...) 'rosterfilter'

function handle.LOAD()
    if not _G.RosterFilterOptions then
        _G.RosterFilterOptions = {}
    end
end

local defs = {}
local function GetConfigOrDefault(key, def)
    defs[key] = def

    if _G.RosterFilterOptions[key] == nil then
        _G.RosterFilterOptions[key] = def
    end

    return _G.RosterFilterOptions[key]
end

local changedcb = {}
local function RegisterKeyChangedCallback(key, cb)
    if not changedcb[key] then
        changedcb[key] = {}
    end

    table.insert(changedcb[key] , cb)
end
M.RegisterKeyChangedCallback = RegisterKeyChangedCallback

local function triggerCallback(key, value)
    for _, cb in pairs(changedcb[key] or {}) do
        cb(value)
    end
end

local function SetConfig(key, value)
    _G.RosterFilterOptions[key] = value

    triggerCallback(key, value)
end
M.SetConfig = SetConfig


local f = CreateFrame("Frame", nil, UIParent)
f.name = "RosterFilter"
local category = Settings.RegisterCanvasLayoutCategory(f, f.name)
Settings.RegisterAddOnCategory(category)
-- InterfaceOptions_AddCategory(f)

do
    local t = f:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    t:SetText("RosterFilter")
    t:SetPoint("TOPLEFT", f, 15, -15)
end

local function createCheckbox(title, key, def)
    local b = CreateFrame("CheckButton", nil, f, "UICheckButtonTemplate")
    b.text = b:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    b.text:SetPoint("LEFT", b, "RIGHT", 0, 1)
    b.text:SetText(title)
    b.text:SetTextColor(1, 1, 1)
    b:SetScript("OnClick", function()
        SetConfig(key, b:GetChecked())
    end)

    RegisterKeyChangedCallback(key, function(v)
        b:SetChecked(v)
    end)

    triggerCallback(key, GetConfigOrDefault(key, def))
    return b
end

function handle.LOAD2()
    f.default = function()
        for k, v in pairs(defs) do
            SetConfig(k, v)
        end
    end

    f.refresh = function()
    end

    local base = -15
    local nextpos = function(offset)
        if not offset then
            offset = 30
        end
        base = base - offset
        return base
    end

    do
        local b = createCheckbox("Show guild name", "showguildname", true)
        b:SetPoint("TOPLEFT", f, 15, nextpos())
    end

    do
        local b = createCheckbox("Show numbers", "shownumbers", true)
        b:SetPoint("TOPLEFT", f, 15, nextpos())
    end

    do
        local b = createCheckbox("Show guild notes", "notes", true)
        b:SetPoint("TOPLEFT", f, 15, nextpos())
    end

    do
        local key = "scale"
        local s = CreateFrame("Slider", f, f, "OptionsSliderTemplate")
        s:SetOrientation('HORIZONTAL')
        s:SetHeight(14)
        s:SetWidth(160)
        s:SetMinMaxValues(0.1, 2.0)
        s:SetValueStep(0.05)
        s.Low:SetText("10%")
        s.High:SetText("200%")

        local l = s:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        l:SetPoint("RIGHT", s, "LEFT", -20, 1)
        l:SetText("Frame scale")
        l:SetTextColor(1, 1, 1)

        s:SetPoint("TOPLEFT", f, 40 + l:GetStringWidth(), nextpos(45))

        s:SetScript("OnValueChanged", function(self, value)
            s.Text:SetText(tostring(math.floor(value*100)).."%")
            SetConfig(key, value)
        end)

        RegisterKeyChangedCallback(key, function(v)
            s:SetValue(v)
        end)

        triggerCallback(key, GetConfigOrDefault(key, 1.0))
    end
end
