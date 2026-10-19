local addon, ns = ...
local _, F, G, L = unpack(ns)

local v = C_AddOns.GetAddOnMetadata(addon, "Version")
local CreateFrame, tonumber, pairs, tinsert = CreateFrame, tonumber, pairs, table.insert
local MainFrame
-- GUI 字級以共用字級加 2 為基準。
local configFontSize = G.fontSize + 2
-- 兩欄共用內距與列距；標籤靠左，欄位緊接文字。
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

	F.CreateFS(bu, text, "CENTER", "CENTER", 0, 0, configFontSize)

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
	-- 點擊文字所在的列也可切換勾選。
	row:SetScript("OnClick", function()
		cb:SetChecked(not cb:GetChecked())
		ToggleValue()
	end)

	row.text = F.CreateFS(row, text, "LEFT", nil, nil, nil, configFontSize)
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
	container:SetSize((columnWidth - 10) / 2, rowHeight)
	-- 選項名字
	container.text = F.CreateFS(container, text, "LEFT", nil, nil, nil, configFontSize)
	container.text:ClearAllPoints()
	container.text:SetPoint("LEFT", container, "LEFT", 0, 0)
	-- 輸入框
	local eb = CreateFrame("EditBox", nil, container)
	eb:SetSize(width, height)
	eb:SetPoint("LEFT", container.text, "RIGHT", 6, 0)
	eb.bg = F.CreateBG(eb, 3, 3, .5)
	eb:SetAutoFocus(false)

	eb:SetTextInsets(5, 5, 0, 0)
	eb:SetMaxLetters(10)
	eb:SetFont(G.font, configFontSize, G.fontFlag)
	eb:SetText(F.GetSavedEKMOption(value))

	eb:HookScript("OnEnterPressed", function(self)
		local n = tonumber(self:GetText())
		if n and n == n and n > -math.huge and n < math.huge then
			SaveOption(value, n)
		else
			self:SetText(F.GetSavedEKMOption(value))
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
	container.text = F.CreateFS(container, text, "LEFT", nil, nil, nil, configFontSize)
	container.text:ClearAllPoints()
	container.text:SetPoint("LEFT", container, "LEFT", 0, 0)
	-- 選單
	local dd = CreateFrame("Frame", nil, container)
	dd:SetSize(width, height)
	dd:SetPoint("LEFT", container.text, "RIGHT", 6, 0)
	F.CreateBG(dd, 3, 3, .5)

	dd.Text = F.CreateFS(dd, "", "CENTER", "CENTER", 0, 0, configFontSize)
	dd.Text:SetText(F.GetSavedEKMOption(value))

	local bu = CreateGear(dd)
	bu:SetPoint("LEFT", dd, "RIGHT", -2, 0)

	local list = CreateFrame("Frame", nil, dd)
	list:SetPoint("TOP", dd, "BOTTOM", 0, -2)
	list:SetFrameLevel(dd:GetFrameLevel() + 10)
	list:SetClampedToScreen(true)
	F.CreateBG(list, 0, 3, .2)
	list:Hide()

	bu:SetScript("OnShow", function() list:Hide() end)
	bu:SetScript("OnClick", function()
		list:SetShown(not list:IsShown())
	end)

	local opt, index = {}, 0
	for i, j in pairs(data) do
		opt[i] = CreateFrame("Button", nil, list)
		opt[i]:SetPoint("TOPLEFT", 3, -4 - (i-1)*(height+2))
		opt[i]:SetSize(width - 6, height)
		opt[i].bg = F.CreateBG(opt[i], 1, 1, .7)

		local text = F.CreateFS(opt[i], j, "CENTER", "LEFT", 5, 0, configFontSize)
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
local function CreateBar(self, key, min, max, step, text, coeff)
	local row = CreateFrame("Frame", nil, self)
	row:SetSize(columnWidth, rowHeight)
	row.text = F.CreateFS(row, text, "LEFT", "LEFT", 0, 0, configFontSize)
	-- 精簡原生滑桿與標籤、數值共用一列。
	local s = CreateFrame("Slider", key.."Bar", row, "MinimalSliderTemplate")
	local valueScale = 1 / coeff
	s:SetSize(columnWidth - row.text:GetStringWidth() - 6 - 4 - 28, 19)
	s:SetPoint("LEFT", row.text, "RIGHT", 6, 0)
	local current = F.CreateFS(row, F.GetSavedEKMOption(key), "LEFT", nil, nil, nil, configFontSize)
	current:ClearAllPoints()
	current:SetPoint("LEFT", s, "RIGHT", 4, 0)
	current:SetWidth(28)

	s:SetMinMaxValues(min, max)
	s:SetValueStep(step)
	s:SetOrientation("HORIZONTAL")

	s:SetValue(F.GetSavedEKMOption(key) * valueScale)

	s:SetScript("OnValueChanged", function(self)
		-- 以整數步進除回設定單位，避免 12 * .1 與預設 1.2 產生假差異。
		local value = self:GetValue() / valueScale
		SaveOption(key, value)
		current:SetText(value)
	end)
	row.RefreshState = function()
		local saved = F.GetSavedEKMOption(key)
		-- 只有數值不同才呼叫 SetValue，避免重新開啟時觸發多餘寫入。
		if s:GetValue() ~= saved * valueScale then s:SetValue(saved * valueScale) end
		current:SetText(saved)
	end

	return row
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
	MainFrame:SetSize(panelInset * 2 + columnWidth * 2 + columnGap, 408)
	MainFrame:SetPoint("CENTER", UIParent)
	MainFrame:SetMovable(true)
	MainFrame:EnableMouse(true)
	MainFrame:RegisterForDrag("LeftButton")
	F.CreateBG(MainFrame, 5, 5, .4)
	MainFrame:SetClampedToScreen(true)
	MainFrame:SetScript("OnDragStart", function() MainFrame:StartMoving() end)
	MainFrame:SetScript("OnDragStop", function() MainFrame:StopMovingOrSizing() end)
	-- 設定只在非戰鬥時開啟；進入戰鬥便關閉已開啟的視窗。
	MainFrame:SetScript("OnShow", function(self)
		self:RegisterEvent("PLAYER_REGEN_DISABLED")
	end)
	MainFrame:SetScript("OnHide", function(self)
		self:UnregisterEvent("PLAYER_REGEN_DISABLED")
		self:StopMovingOrSizing()
	end)
	MainFrame:SetScript("OnEvent", function(self) self:Hide() end)
	MainFrame.OptionControls = {}
	local rightX = panelInset + columnWidth + columnGap
	MainFrame.StatusText = F.CreateFS(MainFrame, "", "LEFT", nil, nil, nil, configFontSize)
	MainFrame.StatusText:SetWidth(columnWidth)
	MainFrame.StatusText:SetWordWrap(true)

	-- Main title
	F.CreateFS(MainFrame, "|cff00ffffEK|rMinimap "..v, "CENTER", "TOP", 0, 14, configFontSize + 4)

	-- 小地圖／世界地圖沿左欄排列，追蹤框與資訊沿右欄排列。
	for _, group in ipairs(F.GUIOptionGroups) do
		local x = panelInset + (group.column - 1) * (columnWidth + columnGap)
		F.CreateFS(MainFrame, "|cff00ffff"..(group.name or L[group.label]).."|r", "LEFT", "TOPLEFT", x, -group.y, configFontSize + 2)
		local y = -group.y - 24
		local inPositionSection = false
		for _, option in ipairs(group.options) do
			local text = L[option.label]
			local control
			if option.type == "toggle" then
				control = CreateCheckBox(MainFrame, text, option.key)
			elseif option.type == "dropdown" then
				control = CreateDropDown(MainFrame, text, option.width, option.height, F.AnchorOptions, option.key)
			elseif option.type == "edit" then
				control = CreateEditBox(MainFrame, text, option.width, option.height, option.key)
			elseif option.type == "slider" then
				control = CreateBar(MainFrame, option.key, option.min, option.max, option.step, text, option.coeff)
			end
			if option.type ~= "toggle" and not inPositionSection then
				y = y - 4
				inPositionSection = true
			end
			if option.type == "edit" then
				-- 同組 X／Y 共用一列，兩個控制項仍各自儲存與刷新。
				control:SetPoint("TOPLEFT", MainFrame, x + (option.rowColumn - 1) * (control:GetWidth() + 10), y)
				if option.rowColumn == 2 then y = y - rowHeight - rowGap end
			else
				control:SetPoint("TOPLEFT", MainFrame, x, y)
				y = y - rowHeight - rowGap
			end
			if option.tooltip then
				local tip = CreateTooltip(control, G.Info, "ANCHOR_RIGHT", L[option.tooltip])
				tip:SetPoint("LEFT", control.text, "RIGHT", 4, 2)
			end
			tinsert(MainFrame.OptionControls, control)
		end
	end

	-- infos
	F.CreateFS(MainFrame, "|cff00ffff"..INFO.."|r", "LEFT", "TOPLEFT", rightX, -232, configFontSize + 2)
	local q = CreateTooltip(MainFrame, G.Question, "ANCHOR_LEFT", L.tempTip1.."\n\n"..L.tempTip2)
	q:SetPoint("TOPLEFT", MainFrame, rightX, -252)
	q:SetSize(28, 28)
	-- 說明沿用原字級，放在右欄選項下方。
	local infoDrag = F.CreateFS(MainFrame, L.dragInfo, "LEFT", nil, nil, nil, G.fontSize)
	infoDrag:ClearAllPoints()
	infoDrag:SetPoint("TOPLEFT", q, "TOPRIGHT", 8, 0)
	local infoScroll = F.CreateFS(MainFrame, L.scrollInfo, "LEFT", nil, nil, nil, G.fontSize)
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
	-- 重載提示隨套用按鈕定位，換行時向上延伸。
	reposButton:SetPoint("BOTTOMRIGHT", MainFrame, -buttonInset, buttonInset + 38)
	MainFrame.StatusText:ClearAllPoints()
	MainFrame.StatusText:SetPoint("BOTTOMLEFT", reposButton, "TOPLEFT", 0, 8)
	reposButton:SetScript("OnClick", function()
		F.ApplyEKMPositionSettings()
		F.ResetM()
		F.ResetO()
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

-- 重開時同步存檔值，不保存尚未按 Enter 的草稿。
F.CreateEKMOptions = function()
	if F.CombatError() then return end
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
