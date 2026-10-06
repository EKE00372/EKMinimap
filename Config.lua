local addon, ns = ...
local _, F, G, L = unpack(ns)

local v = C_AddOns.GetAddOnMetadata(addon, "Version")
local CreateFrame, tonumber, pairs, tinsert = CreateFrame, tonumber, pairs, table.insert
local MainFrame
-- GUI 字級以共用字級加 2 為基準。
local configFontSize = G.fontSize + 2
-- 兩欄共用內距與列距；欄位錨點獨立於標籤文字寬度。
local panelInset, columnWidth, columnGap, rowHeight, rowGap = 24, 226, 20, 26, 2
-- 按鈕外側留白獨立於選項欄的內距。
local buttonInset = 20

------
	
	-- EKMinimap 現在有了遊戲內控制台，請輸入 /ekm 或 /ekminimap 打開控制台更改設定
	-- EKMinimap have in-game config. type /ekm or /ekminimap to toggle options

------

--=====================================================--
-----------------    [[ Functions ]]    -----------------
--=====================================================--

local optList = {
	[1] = "TOP",
	[2] = "TOPLEFT",
	[3] = "TOPRIGHT",
	[4] = "CENTER",
	[5] = "LEFT",
	[6] = "BOTTOM",
	[7] = "BOTTOMLEFT",
	[8] = "BOTTOMRIGHT",
	[9] = "RIGHT",
	}

-- 提示反映存檔與已生效設定的差異；改回原值後清除提示。
local function UpdateStatus()
	MainFrame.StatusText:SetText(F.HasPendingEKMChanges() and "|cff00ffff"..L.StatusChanged.."|r" or "")
end

local function SaveOption(key, value)
	F.SetEKMOption(key, value)
	UpdateStatus()
end

local function RefreshOptionControls()
	for _, control in ipairs(MainFrame.OptionControls) do
		control:RefreshState()
	end
	UpdateStatus()
end

-- click buttons
local function CreateButton(self, width, height, text)
	local bu = CreateFrame("Button", nil, self)
	bu:SetSize(width, height)
	bu.bg = F.CreateBG(bu, 3, 3, .5)
	
	bu:SetNormalTexture(0)
	bu:SetHighlightTexture(0)
	bu:SetPushedTexture(0)
	bu:SetDisabledTexture(0)
	
	bu.Text = F.CreateFS(bu, text, configFontSize, "CENTER", "CENTER", 0, 0)
	
	bu:SetScript("OnEnter", function() bu.bg:SetBackdropColor(0, 1, 1, .5) end)
	bu:SetScript("OnLeave", function() bu.bg:SetBackdropColor(0, 0, 0, .5) end)
	
	return bu
end

-- check box
local function CreateCheckBox(self, text, value)
	local row = CreateFrame("Button", nil, self)
	row:SetSize(columnWidth, rowHeight)
	local cb = CreateFrame("CheckButton", nil, row, "UICheckButtonTemplate")
	cb:SetPoint("LEFT", row, "LEFT", -4, 0)
	cb:SetHighlightTexture("Interface\\ChatFrame\\ChatFrameBackground")
	-- 原生 32px 按鈕的點擊範圍收在 26px 列內，不伸入鄰列。
	cb:SetHitRectInsets(4, 0, 3, 3)
	
	local hl = cb:GetHighlightTexture()
	hl:SetPoint("TOPLEFT", 5, -5)
	hl:SetPoint("BOTTOMRIGHT", -5, 5)
	hl:SetVertexColor(1, 1, 1, .25)

	F.CreateBG(cb, -4, 1, .5)

	local ch = cb:GetCheckedTexture()
	ch:SetDesaturated(true)
	ch:SetVertexColor(0, 1, 1)

	local function ToggleValue()
		SaveOption(value, (cb:GetChecked() == true))
	end
	cb:SetScript("OnClick", ToggleValue)
	-- 與 Ruri 一樣，點擊文字所在的列也可切換勾選。
	row:SetScript("OnClick", function()
		cb:SetChecked(not cb:GetChecked())
		ToggleValue()
	end)
	
	row.text = F.CreateFS(row, text, configFontSize, "LEFT")
	row.text:ClearAllPoints()
	row.text:SetPoint("LEFT", cb, "RIGHT", 2, 0)
	row.RefreshState = function()
		cb:SetChecked(F.GetSavedEKMOption(value) == true)
	end
	
	return row
end

-- edit box
local function CreateEditBox(self, text, width, height, value)
	-- 建立容器，打包選項名字和輸入框
	local container = CreateFrame("Frame", nil, self)
	container:SetSize(columnWidth, rowHeight)
	-- 選項名字
	container.text = F.CreateFS(container, text, configFontSize, "LEFT")
	container.text:ClearAllPoints()
	container.text:SetPoint("LEFT", container, "LEFT", 0, 0)
	-- 輸入框
	local eb = CreateFrame("EditBox", nil, container)
	eb:SetSize(width, height)
	eb:SetPoint("LEFT", container, "LEFT", 72, 0)
	eb.bg = F.CreateBG(eb, 3, 3, .5)
	eb:SetAutoFocus(false)
	
	eb:SetTextInsets(5, 5, 0, 0)
	eb:SetMaxLetters(10)
	eb:SetFont(G.font, configFontSize, G.fontFlag)
	eb:SetText(F.GetSavedEKMOption(value))
	
	eb:HookScript("OnEnterPressed", function(self)
		local n = tonumber(self:GetText())
		if n then
			SaveOption(value, n)
		end
		self:ClearFocus()
	end)
	eb:HookScript("OnEscapePressed", function(self)
		self:SetText(F.GetSavedEKMOption(value))
	end)
	eb:SetScript("OnEnter", function() eb.bg:SetBackdropColor(0, 1, 1, .5) end)
	eb:SetScript("OnLeave", function() eb.bg:SetBackdropColor(0, 0, 0, .5) end)
	
	container.RefreshState = function()
		eb:SetText(F.GetSavedEKMOption(value))
	end
	return container
end

-- drop down menu arrow icon
local function CreateGear(parent)
	local bu = CreateFrame("Button", nil, parent)
	bu:SetSize(21, 21)
	bu.Icon = bu:CreateTexture(nil, "ARTWORK")
	bu.Icon:SetAllPoints()
	bu.Icon:SetTexture("Interface/minimap/minimap-deadarrow")
	bu.Icon:SetRotation(math.rad(180))

	return bu
end

-- custom drop down menu
local function CreateDropDown(self, text, width, height, data, value)
	-- 建立容器，打包選項名字和選單
	local container = CreateFrame("Frame", nil, self)
	container:SetSize(columnWidth, rowHeight)
	-- 選項名字
	container.text = F.CreateFS(container, text, configFontSize, "LEFT")
	container.text:ClearAllPoints()
	container.text:SetPoint("LEFT", container, "LEFT", 0, 0)
	-- 選單
	local dd = CreateFrame("Frame", nil, container)
	dd:SetSize(width, height)
	dd:SetPoint("LEFT", container, "LEFT", 72, 0)
	dd.bg = F.CreateBG(dd, 3, 3, .5)
	
	dd.Text = F.CreateFS(dd, "", configFontSize, "CENTER", "CENTER", 0, 0)
	dd.Text:SetText(F.GetSavedEKMOption(value))
	
	local bu = CreateGear(dd)
	bu:SetPoint("LEFT", dd, "RIGHT", -2, 0)
	
	local list = CreateFrame("Frame", nil, dd)
	list:SetPoint("TOP", dd, "BOTTOM", 0, -2)
	list:SetFrameLevel(dd:GetFrameLevel() + 10)
	list:SetClampedToScreen(true)
	list.bg = F.CreateBG(list, 0, 3, .2)
	list:Hide()
	
	bu:SetScript("OnShow", function() list:Hide() end)
	bu:SetScript("OnClick", function()
		ToggleFrame(list)
	end)

	local opt, index = {}, 0
	for i, j in pairs(data) do
		opt[i] = CreateFrame("Button", nil, list)
		opt[i]:SetPoint("TOPLEFT", 3, -4 - (i-1)*(height+2))
		opt[i]:SetSize(width - 6, height)
		opt[i].bg = F.CreateBG(opt[i], 1, 1, .7)
		
		local text = F.CreateFS(opt[i], j, configFontSize, "CENTER", "LEFT", 5, 0)
		text:SetPoint("RIGHT", -5, 0)
		opt[i].text = j
		opt[i].__owner = dd
		opt[i]:SetScript("OnClick", function(self)
			self.__owner.Text:SetText(self.text)
			self:GetParent():Hide()
		end)
		opt[i]:HookScript("OnClick", function(self)
			SaveOption(value, self.__owner.Text:GetText())
		end)
		opt[i]:SetScript("OnEnter", function() opt[i].bg:SetBackdropColor(0, 1, 1, .7) end)
		opt[i]:SetScript("OnLeave", function() opt[i].bg:SetBackdropColor(0, 0, 0, .7) end)

		index = index + 1
	end
	list:SetSize(width, index*(height+2) + 6)

	container.RefreshState = function()
		dd.Text:SetText(F.GetSavedEKMOption(value))
		list:Hide()
	end
	return container
end

-- slider bar
local function CreateBar(self, name, width, height, min, max, step, value, text, coeff)
	local s = CreateFrame("Slider", name.."Bar", self, "OptionsSliderTemplate")
	s:SetSize(width, height)
	_G[s:GetName().."Low"]:SetText(min * coeff)
	_G[s:GetName().."High"]:SetText(max * coeff)
	for _, label in ipairs({ _G[s:GetName().."Low"], _G[s:GetName().."High"] }) do
		label:SetFont(G.font, configFontSize, G.fontFlag)
		label:SetShadowOffset(0, 0)
	end
	
	s:SetMinMaxValues(min, max)
	s:SetObeyStepOnDrag(true)
	s:SetValueStep(step)
	s:SetOrientation("HORIZONTAL")
	
	s:SetValue(F.GetSavedEKMOption(value)/coeff)
	
	s.text = F.CreateFS(s, text.." "..F.GetSavedEKMOption(value), configFontSize, "LEFT")
	s.text:ClearAllPoints()
	s.text:SetPoint("BOTTOM", s, "TOP", 0, 5)
	
	s:SetScript("OnValueChanged", function(self)
		SaveOption(value, self:GetValue() * coeff)
		s.text:SetText(text.." "..F.GetSavedEKMOption(value))
	end)
	s.RefreshState = function()
		local saved = F.GetSavedEKMOption(value)
		-- 只有數值不同才呼叫 SetValue，避免重新開啟時觸發多餘寫入。
		if s:GetValue() ~= saved/coeff then s:SetValue(saved/coeff) end
		s.text:SetText(text.." "..saved)
	end
	
	return s
end

-- tooltip
local function CreateTooltip(self, tex, anchor, text)
	local i = CreateFrame("Button", nil, self)
	i:SetSize(configFontSize + 2, configFontSize + 2)
	i.Icon = i:CreateTexture(nil, "ARTWORK")
	i.Icon:SetAllPoints()
	i.Icon:SetTexture(tex)
	i:SetHighlightTexture(tex)
	
	i:SetScript("OnEnter", function(self)
		GameTooltip:ClearLines()
		GameTooltip:SetOwner(self, anchor, 0, 0)
		GameTooltip:AddLine(text, 1, 1, 1, true)
		GameTooltip:Show()
	end)
	i:SetScript("OnLeave", function() GameTooltip:Hide() end)
	
	return i
end

--===============================================--
-----------------    [[ GUI ]]    -----------------
--===============================================--

local function BuildGUI()
	MainFrame = CreateFrame("Frame", "EKMinimapOptions", UIParent)
	tinsert(UISpecialFrames, "EKMinimapOptions")
	
	MainFrame:SetFrameStrata("DIALOG")
	MainFrame:SetSize(panelInset * 2 + columnWidth * 2 + columnGap, 370)
	MainFrame:SetPoint("CENTER", UIParent)
	MainFrame:SetMovable(true)
	MainFrame:EnableMouse(true)
	MainFrame:RegisterForDrag("LeftButton")
	MainFrame.bg = F.CreateBG(MainFrame, 5, 5, .4)
	MainFrame:SetClampedToScreen(true)
	MainFrame:SetScript("OnDragStart", function() MainFrame:StartMoving() end)
	MainFrame:SetScript("OnDragStop", function() MainFrame:StopMovingOrSizing() end)
	MainFrame.OptionControls = {}
	MainFrame.StatusText = F.CreateFS(MainFrame, "", configFontSize, "LEFT", "TOPLEFT", panelInset + columnWidth + columnGap, -258)
	MainFrame.StatusText:SetWidth(columnWidth)
	MainFrame.StatusText:SetWordWrap(true)
	
	-- Main title
	F.CreateFS(MainFrame, "|cff00ffffEK|rMinimap "..v, configFontSize + 4, "CENTER", "TOP", 0, 14)

	-- 選項順序由 Init 定義，左右欄共用同一列距。
	for column, group in ipairs(F.GUIOptionGroups) do
		local x = panelInset + (column - 1) * (columnWidth + columnGap)
		F.CreateFS(MainFrame, "|cff00ffff"..group.name.."|r", configFontSize + 2, "LEFT", "TOPLEFT", x, -panelInset)
		for index, option in ipairs(group.options) do
			local control
			local text = L[option.label]
			if option.type == "toggle" then
				control = CreateCheckBox(MainFrame, text, option.key)
			elseif option.type == "dropdown" then
				control = CreateDropDown(MainFrame, text, option.width, option.height, optList, option.key)
			elseif option.type == "edit" then
				control = CreateEditBox(MainFrame, text, option.width, option.height, option.key)
			elseif option.type == "slider" then
				control = CreateBar(MainFrame, "Size", 160, 20, option.min, option.max, option.step, option.key, text, option.coeff)
			end
			local y = -panelInset - 24 - (index - 1) * (rowHeight + rowGap)
			-- 位置與縮放區多留 4px，和上方勾選項分開。
			if option.type ~= "toggle" then y = y - 4 end
			if option.type == "slider" then
				control:SetPoint("TOPLEFT", MainFrame, x + (columnWidth - control:GetWidth()) / 2, y - 24)
			else
				control:SetPoint("TOPLEFT", MainFrame, x, y)
			end
			if option.tooltip then
				local tip = CreateTooltip(control, G.Info, "ANCHOR_RIGHT", L[option.tooltip])
				tip:SetPoint("LEFT", control.text, "RIGHT", 4, 2)
			end
			tinsert(MainFrame.OptionControls, control)
		end
	end

	-- infos
	local rightX = panelInset + columnWidth + columnGap
	F.CreateFS(MainFrame, "|cff00ffff"..INFO.."|r", configFontSize + 2, "LEFT", "TOPLEFT", rightX, -192)
	local q = CreateTooltip(MainFrame, G.Question, "ANCHOR_LEFT", L.tempTip1.."\n\n"..L.tempTip2)
	q:SetPoint("TOPLEFT", MainFrame, rightX, -216)
	q:SetSize(28, 28)
	-- 說明沿用原字級，放在右欄選項下方。
	local infoDrag = F.CreateFS(MainFrame, L.dragInfo, G.fontSize, "LEFT")
	infoDrag:ClearAllPoints()
	infoDrag:SetPoint("TOPLEFT", q, "TOPRIGHT", 8, 0)
	local infoScroll = F.CreateFS(MainFrame, L.scrollInfo, G.fontSize, "LEFT")
	infoScroll:ClearAllPoints()
	infoScroll:SetPoint("TOPLEFT", infoDrag, "BOTTOMLEFT", 0, -8)

	-- buttons
	local closeButton = CreateButton(MainFrame, 22, 22, "X")
	closeButton:SetPoint("TOPRIGHT", MainFrame, -buttonInset, -buttonInset)
	closeButton:SetScript("OnClick", function() MainFrame:Hide() end)

	local reloadButton = CreateButton(MainFrame, (columnWidth - 10) / 2, 28, L.ReloadUI)
	reloadButton:SetPoint("BOTTOMRIGHT", MainFrame, -buttonInset, buttonInset)
	reloadButton:SetScript("OnClick", function() ReloadUI() end)

	local reposButton = CreateButton(MainFrame, columnWidth, 28, L.posApply)
	reposButton:SetPoint("BOTTOMRIGHT", MainFrame, -buttonInset, buttonInset + 38)
	reposButton:SetScript("OnClick", function()
		F.ResetM()
		UpdateStatus()
	end)
	
	local i = CreateTooltip(reposButton, G.Info, "ANCHOR_RIGHT", L.tempTip3)
	i:SetPoint("TOPRIGHT", reposButton, "TOPRIGHT", 8, 8)

	local resetButton = CreateButton(MainFrame, (columnWidth - 10) / 2, 28, RESET)
	resetButton:SetPoint("RIGHT", reloadButton, "LEFT", -10, 0)
	resetButton:SetScript("OnClick", function()
		wipe(EKMinimapDB)
		ReloadUI()
	end)
	MainFrame:Hide()
end

-- 與 Ruri 一樣切換視窗；重開時同步存檔值，不保存尚未按 Enter 的草稿。
F.CreateEKMOptions = function()
	if not MainFrame then BuildGUI() end
	if MainFrame:IsShown() then
		MainFrame:Hide()
	else
		RefreshOptionControls()
		MainFrame:Show()
	end
end

SlashCmdList["EKMINIMAP"] = function()
	F.CreateEKMOptions()
end
SLASH_EKMINIMAP1 = "/ekm"
SLASH_EKMINIMAP2 = "/ekminimap"

-------------
-- Credits --
-------------

	-- HopeASD, Felix S., sakaras, ape47, 
	-- iMinimap by Chiril, ooMinimap by Ooglogput, intMinimap by Int0xMonkey
	-- DifficultyID list
	-- https://wow.gamepedia.com/DifficultyID
	-- rStatusButton by zork
	-- https://www.wowinterface.com/downloads/info24772-rStatusButton.html
	-- Hide order hall bar
	-- https://github.com/destroyerdust/Class-Hall
	-- NeavUI by Neal: https://www.wowinterface.com/downloads/info13981-NeavUI.html#info
	-- ClickMenu by 10leej: https://www.wowinterface.com/downloads/info22660-ClickMenu.html