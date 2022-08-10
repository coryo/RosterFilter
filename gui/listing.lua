select(2, ...) 'rosterfilter.gui.listing'

local rosterfilter = require 'rosterfilter'
local gui = require 'rosterfilter.gui'

local ROW_TEXT_SIZE = gui.font_size.small
local ROW_HEIGHT = ROW_TEXT_SIZE + 1
local HEAD_HEIGHT = 27
local HEAD_SPACE = 2
local DEFAULT_COL_INFO = {{width=1}}


local handlers = {
    OnEnter = function(self)
        self.mouseover = true
        if not self.data then return end
        if not self.st.highlightDisabled then
            self.highlight:Show()
        end

        local handler = self.st.handlers.OnEnter
        if handler then
            handler(self.st, self.data, self)
        end

        local x,y = RosterFilterFrame:GetCenter();
        local anchor;
        if x < GetScreenWidth() / 2 then
            anchor = 'ANCHOR_RIGHT'
        else
            anchor = 'ANCHOR_LEFT'
        end

        GameTooltip:SetOwner(self, anchor)
        for _,col in pairs(self.st.tooltipCols) do
            local data = self.data.cols[col]
            if data.value and data.value ~= '' then
                GameTooltip:AddLine(data.name .. ": " .. data.value)
            end
        end
        GameTooltip:Show()
    end,

    OnLeave = function(self)
        self.mouseover = false
        if not self.data then return end
        if not (self.st.selected and self.st.selected(self.data)) then
            self.highlight:Hide()
        end

        local handler = self.st.handlers.OnLeave
        if handler then
            handler(self.st, self.data, self)
        end

        GameTooltip:Hide()
    end,

    OnClick = function(self, button)
        if not self.data then return end
        local handler = self.st.handlers.OnClick
        if handler then
            handler(self.st, self.data, self, button)
        end
    end,

	OnDoubleClick = function(self, button)
		if not self.data then return end

		local handler = self.st.handlers.OnDoubleClick
		if handler then
			handler(self.st, self.data, self, button)
		end
    end


}

local methods = {

    OnHeadColumnClick = function(self, button)
        local st = self.st

        if st.sortColumn == self.colNum then
            st.sortInvert = not st.sortInvert
        else
            st.sortInvert = false
        end

        st.sortColumn = self.colNum
        st:SetSort(self.colNum)
        st:Update()
    end,

    SetSort = function(self, column)
        local invert = self.sortInvert

        local function sortFunc(a, b)
            local a_val = a['cols'][column]['sort']
            local b_val = b['cols'][column]['sort']
            local cmp_a = tonumber(a_val)
            local cmp_b = tonumber(b_val)
            local str_a, str_b;
            if cmp_a == nil or cmp_b == nil then
                cmp_a = tostring(a_val)
                cmp_b = tostring(b_val)
            end

            if invert then
                return cmp_a > cmp_b
            else
                return cmp_a < cmp_b
            end
        end
        sort(self.rowData, sortFunc)
        self.isSorted = true
    end,
    -- {name='C', width=10, align='LEFT', fixed=true},
    -- {name='Name', width=.20, align='LEFT'},
    -- {name='L', width=15, align='CENTER', fixed=true},
    -- {name='Rank', width=.20, align='RIGHT'},
    -- {name='Zone', width=.20, align='CENTER'},
    -- {name='Note', width=.35, align='RIGHT'},
    GetWidthFromColInfo = function(self, colInfo)
        local width = self.contentFrame:GetRight() - self.contentFrame:GetLeft()
        local total_fixed_width = 0;
        for _,col in pairs(colInfo) do
            if col.fixed == true then total_fixed_width = total_fixed_width + col.width end
        end
        return width - total_fixed_width;
    end,

    Update = function(self)
	    if #self.colInfo > 1 or self.colInfo[1].name then
		    self.headHeight = HEAD_HEIGHT
	    else
		    self.headHeight = 0
	    end

	    if #(self.rowData or empty) > self:GetNumRows() then
		    self.contentFrame:SetPoint('BOTTOMRIGHT', -15, 0)
	    else
		    self.contentFrame:SetPoint('BOTTOMRIGHT', 0, 0)
	    end

        local width = self.contentFrame:GetRight() - self.contentFrame:GetLeft()
        local dynamic_width = self:GetWidthFromColInfo(self.colInfo)

	    while #self.headCols < #self.colInfo do
		    self:AddColumn()
	    end

	    for i, col in ipairs(self.headCols) do
		    if self.colInfo[i] then
			    col:Show()
                if self.colInfo[i].fixed then
                    col:SetWidth(self.colInfo[i].width)
                else
			        col:SetWidth(self.colInfo[i].width * dynamic_width)
                end
			    col:SetHeight(self.headHeight)
			    col.text:SetText(self.colInfo[i].name or '')
			    col.text:SetJustifyH(self.colInfo[i].headAlign or 'CENTER')
                col:RegisterForClicks('LeftButtonUp')
                col:SetScript('OnClick', self.OnHeadColumnClick)

                local tex = col:GetNormalTexture()
                tex:SetTexture[[Interface\AddOns\RosterFilter\WorldStateFinalScore-Highlight]]
                tex:SetTexCoord(.017, 1, .083, .909)
                tex:SetAlpha(.5)
		    else
			    col:Hide()
		    end
        end

        if self.isSorted and self.sortColumn < getn(self.headCols) then
            if self.sortInvert then
                self.headCols[self.sortColumn]:GetNormalTexture():SetColorTexture(.8, .6, 1, .8)
            else
                self.headCols[self.sortColumn]:GetNormalTexture():SetColorTexture(.6, .8, 1, .8)
            end
        end

	    while getn(self.rows) < self:GetNumRows() do
		    self:AddRow()
	    end

	    for i, row in ipairs(self.rows) do
		    if i > self:GetNumRows() then
			    row.data = nil
			    row:Hide()
		    else
			    row:Show()
			    while getn(row.cols) < getn(self.colInfo) do
				    self:AddCell(i)
			    end
			    for j, col in ipairs(row.cols) do
				    if self.headCols[j] and self.colInfo[j] then
					    col:Show()
                        if self.colInfo[j].fixed then
                            col:SetWidth(self.colInfo[j].width)
                        else
					        col:SetWidth(self.colInfo[j].width * dynamic_width)
                        end
					    col.text:SetJustifyH(self.colInfo[j].align or 'LEFT')
				    else
					    col:Hide()
				    end
			    end
		    end
	    end

        if not self.rowData then return end
        FauxScrollFrame_Update(self.scrollFrame, getn(self.rowData), self:GetNumRows(), ROW_HEIGHT)
        local offset = FauxScrollFrame_GetOffset(self.scrollFrame)
        self.offset = offset

        for i = 1, self:GetNumRows() do
            self.rows[i].data = nil
            if i > getn(self.rowData) then
                self.rows[i]:Hide()
            else
                self.rows[i]:Show()
                local data = self.rowData[i + offset]
                if not data then break end
                self.rows[i].data = data

                if self.rows[i].mouseover or self.selected and self.selected(data) then
                    self.rows[i].highlight:Show()
                else
                    self.rows[i].highlight:Hide()
                end

                for j, col in ipairs(self.rows[i].cols) do
                    if self.colInfo[j] then
                        local colData = data.cols[j]
                        if type(colData.value) == 'function' then
	                        col.text:SetText(colData.value(unpack(colData.args)))
                        else
                            col.text:SetText(colData.value)
                        end
                        col.text:SetAlpha(data.alpha or 1.0)
                    end
                end
            end
        end
    end,

    SetData = function(self, rowData)
        self.rowData = rowData
        self:SetSort(self.sortColumn)
        self:Update()
    end,

    AddColumn = function(self)
        local colNum = getn(self.headCols) + 1
        local col = CreateFrame('Button', nil, self.contentFrame)
        if colNum == 1 then
            col:SetPoint('TOPLEFT', 0, 0)
        else
            col:SetPoint('TOPLEFT', self.headCols[colNum - 1], 'TOPRIGHT')
        end
        col.st = self
        col.colNum = colNum

	    local text = col:CreateFontString()
	    text:SetAllPoints()
	    text:SetFont(gui.font, 12)
	    text:SetTextColor(rosterfilter.color.label.enabled())
        col.text = text

        local tex = col:CreateTexture()
        tex:SetAllPoints()
        tex:SetTexture([[Interface\AddOns\RosterFilter\WorldStateFinalScore-Highlight]])
        tex:SetTexCoord(.017, 1, .083, .909)
        tex:SetAlpha(.5)
        col:SetNormalTexture(tex)

        local tex = col:CreateTexture()
        tex:SetAllPoints()
        tex:SetTexture([[Interface\Buttons\UI-Listbox-Highlight]])
        tex:SetTexCoord(.025, .957, .087, .931)
        tex:SetAlpha(.2)
        col:SetHighlightTexture(tex)

        tinsert(self.headCols, col)

        for i, row in ipairs(self.rows) do
            while getn(row.cols) < getn(self.headCols) do
                self:AddCell(i)
            end
        end
    end,

    AddCell = function(self, rowNum)
        local row = self.rows[rowNum]
        local colNum = getn(row.cols) + 1
        local cell = CreateFrame('Frame', nil, row)
        local text = cell:CreateFontString()
        cell.text = text
        text:SetFont(gui.font, ROW_TEXT_SIZE)
        text:SetJustifyV('CENTER')
        text:SetPoint('TOPLEFT', 1, -1)
        text:SetPoint('BOTTOMRIGHT', -1, 1)
        cell:SetHeight(ROW_HEIGHT)
        cell.st = self

        if colNum == 1 then
	        cell:SetPoint('TOPLEFT', 0, 0)
        else
	        cell:SetPoint('TOPLEFT', row.cols[colNum - 1], 'TOPRIGHT')
        end
        tinsert(row.cols, cell)
    end,

    AddRow = function(self)
        local row = CreateFrame('Button', nil, self.contentFrame)
        row:SetHeight(ROW_HEIGHT)
        row:RegisterForClicks('LeftButtonUp', 'RightButtonUp')
        for name, func in pairs(handlers) do
	        row:SetScript(name, func)
        end
        local rowNum = getn(self.rows) + 1
        if rowNum == 1 then
            row:SetPoint('TOPLEFT', 0, -(self.headHeight + HEAD_SPACE))
            row:SetPoint('TOPRIGHT', 0, -(self.headHeight + HEAD_SPACE))
        else
            row:SetPoint('TOPLEFT', 0, -(self.headHeight + HEAD_SPACE + (rowNum - 1) * ROW_HEIGHT))
            row:SetPoint('TOPRIGHT', 0, -(self.headHeight + HEAD_SPACE + (rowNum - 1) * ROW_HEIGHT))
        end
        local highlight = row:CreateTexture()
        highlight:SetAllPoints()
        highlight:SetColorTexture(1, .9, 0, .4)
        highlight:Hide()
        row.highlight = highlight
        row.st = self

        row.cols = {}
        self.rows[rowNum] = row
        for _ = 1, getn(self.colInfo) do
            self:AddCell(rowNum)
        end
    end,

	SetSelection = function(self, f)
		self.selected = f
	end,

    SetHandler = function(self, event, handler)
	    self.handlers[event] = handler
    end,

    SetColInfo = function(self, colInfo)
        colInfo = colInfo or DEFAULT_COL_INFO
        self.colInfo = colInfo
        self:Update()
    end,

    GetNumRows = function(self)
        return max(floor((self:GetHeight() - (HEAD_SPACE + HEAD_HEIGHT)) / ROW_HEIGHT), 0)
    end
}

function M.new(parent)
    local st = CreateFrame('Frame', gui.unique_name(), parent)
    st:SetAllPoints()

    st.numRows = max(floor((parent:GetHeight() - HEAD_HEIGHT - HEAD_SPACE) / ROW_HEIGHT), 0)

    local contentFrame = CreateFrame('Frame', nil, st)
    contentFrame:SetAllPoints()
    st.contentFrame = contentFrame

    local scrollFrame = CreateFrame('ScrollFrame', st:GetName() .. 'ScrollFrame', st, 'FauxScrollFrameTemplate')
    scrollFrame:SetScript('OnVerticalScroll', function(self, offset)
        FauxScrollFrame_OnVerticalScroll(self, offset, ROW_HEIGHT, function() st:Update() end)
    end)
    scrollFrame:SetAllPoints(contentFrame)
    st.scrollFrame = scrollFrame

    local scroll_bar = _G[scrollFrame:GetName() .. 'ScrollBar']
    scroll_bar:ClearAllPoints()
    scroll_bar:SetPoint('TOPRIGHT', st, -4, -HEAD_HEIGHT)
    scroll_bar:SetPoint('BOTTOMRIGHT', st, -4, 4)
    scroll_bar:SetWidth(10)
    local thumbTex = scroll_bar:GetThumbTexture()
    thumbTex:SetPoint('CENTER', 0, 0)
    thumbTex:SetColorTexture(rosterfilter.color.content.background())
    thumbTex:SetHeight(150)
    thumbTex:SetWidth(scroll_bar:GetWidth())
    _G[scroll_bar:GetName() .. 'ScrollUpButton']:Hide()
    _G[scroll_bar:GetName() .. 'ScrollDownButton']:Hide()

    for name, func in pairs(methods) do
        st[name] = func
    end

    st.headCols = {}
    st.rows = {}
    st.handlers = {}
    st.colInfo = DEFAULT_COL_INFO
    st.sorts = {}

    st.isSorted = false
    st.sortColumn = 1
    st.sortInvert = false
    st.tooltipCols = {}

    return st
end
