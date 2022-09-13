local addon, ns = ...
local C, F, G, L = unpack(ns)

local v = GetAddOnMetadata("EKMinimap", "Version")
local CreateFrame, tonumber, pairs, tinsert = CreateFrame, tonumber, pairs, table.insert
local MainFrame = MainFrame

------
	
	-- EKMinimap 現在有了遊戲內控制台，請輸入 /ekm 或 /ekminimap 或右鍵小地圖選單打開控制台更改設定
	-- EKMinimap have in-game config. type /ekm or /ekminimap or right-click minimap toggle config to toggle options

------

--===================================================--
-----------------    [[ Initial ]]    -----------------
--===================================================--

local default = CreateFrame("Frame")
	default:RegisterEvent("ADDON_LOADED")
	default:SetScript("OnEvent", function(self, _, addonName)
		if addonName == addon then
			if not EKMinimapDB then EKMinimapDB = {} end
			-- 載入存在於表中，但不存在於設定的数据
			for key, value in pairs(C.defaultSettings) do
				if EKMinimapDB[key] == nil then
					EKMinimapDB[key] = value
				end
			end
			-- 删除不存在於表中，但存在於設定的数据
			for key in pairs(EKMinimapDB) do
				if C.defaultSettings[key] == nil then
					EKMinimapDB[key] = nil
				end
			end
		end
	end)

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

-- variable check: check if value update, or simply get value for show
local function GLOBEVARIABLE(value, newValue)
	if newValue ~= nil then
		EKMinimapDB[value] = newValue
	else
		return EKMinimapDB[value]
	end
end

-- click buttons
local function CreateButton(self, width, height, text)
	local bu = CreateFrame("Button", nil, self)
	bu:SetSize(width, height)
	bu.bg = F.CreateBG(bu, 3, 3, .5)
	
	bu:SetNormalTexture("")
	bu:SetHighlightTexture("")
	bu:SetPushedTexture("")
	bu:SetDisabledTexture("")
	
	bu.Text = F.CreateFS(bu, text, "CENTER", "CENTER", 0, 0)
	
	if bu.Left then bu.Left:SetAlpha(0) end
	if bu.Middle then bu.Middle:SetAlpha(0) end
	if bu.Right then bu.Right:SetAlpha(0) end
	if bu.LeftSeparator then bu.LeftSeparator:Hide() end
	if bu.RightSeparator then bu.RightSeparator:Hide() end
	
	bu:SetScript("OnEnter", function() bu.bg:SetBackdropColor(0, 1, 1, .5) end)
	bu:SetScript("OnLeave", function() bu.bg:SetBackdropColor(0, 0, 0, .5) end)
	
	return bu
end

-- check box
local function CreateCheckBox(self, text, value)
	local cb = CreateFrame("CheckButton", nil, self, "InterfaceOptionsCheckButtonTemplate")
	cb:SetHighlightTexture("Interface\\ChatFrame\\ChatFrameBackground")
	cb:SetHitRectInsets(-5, -5, -5, -5)
	
	local hl = cb:GetHighlightTexture()
	hl:SetPoint("TOPLEFT", 5, -5)
	hl:SetPoint("BOTTOMRIGHT", -5, 5)
	hl:SetVertexColor(0, 1, 1, .25)

	local bd = F.CreateBG(cb, -4, 1, .5)

	local ch = cb:GetCheckedTexture()
	ch:SetDesaturated(true)
	ch:SetVertexColor(0, 1, 1)

	cb:SetChecked(GLOBEVARIABLE(value) == true)
	cb:SetScript("OnClick", function(self)
		GLOBEVARIABLE(value, self:GetChecked())
	end)
	
	cb.text = F.CreateFS(cb, text, "LEFT")
	cb.text:SetPoint("LEFT", cb, "RIGHT", 4, 0)
	
	return cb
end

-- edit box
local function CreateEditBox(self, width, height, value)
	local eb = CreateFrame("EditBox", nil, self)
	eb:SetSize(width, height)
	eb.bg = F.CreateBG(eb, 3, 3, .5)
	eb:SetAutoFocus(false)
	
	eb:SetTextInsets(5, 5, 0, 0)
	eb:SetMaxLetters(500)
	eb:SetFont(G.font, G.fontSize, G.fontFlag)
	eb:SetText(GLOBEVARIABLE(value))
	
	eb:HookScript("OnEnterPressed", function(self)
		local n = tonumber(self:GetText())
		if n then
			GLOBEVARIABLE(value, n)
		end
		self:ClearFocus()
	end)
	eb:HookScript("OnEscapePressed", function(self)
		self:SetText(GLOBEVARIABLE(value))
	end)
	eb:SetScript("OnEnter", function() eb.bg:SetBackdropColor(0, 1, 1, .5) end)
	eb:SetScript("OnLeave", function() eb.bg:SetBackdropColor(0, 0, 0, .5) end)
	
	return eb
end

-- drop down menu arrow icon
local function CreateGear(name)
	local bu = CreateFrame("Button", name, name)
	bu:SetSize(21, 21)
	bu.Icon = bu:CreateTexture(nil, "ARTWORK")
	bu.Icon:SetAllPoints()
	bu.Icon:SetTexture("Interface/minimap/minimap-deadarrow")
	bu.Icon:SetRotation(math.rad(180))

	return bu
end

-- custom drop down menu
local function CreateDropDown(self, width, height, data, value)
	local dd = CreateFrame("Frame", nil, self)
	dd:SetSize(width, height)
	dd.bg = F.CreateBG(dd, 3, 3, .5)
	dd.options = {}
	
	dd.Text = F.CreateFS(dd, "", "CENTER", 0, 0)
	dd.Text:SetText(GLOBEVARIABLE(value))
	
	local bu = CreateGear(dd)
	bu:SetPoint("LEFT", dd, "RIGHT", -2, 0)
	
	local list = CreateFrame("Frame", nil, dd)
	list:SetPoint("TOP", dd, "BOTTOM", 0, -2)
	list.bg = F.CreateBG(list, 0, 3, .2)
	list:Hide()
	
	bu:SetScript("OnShow", function() list:Hide() end)
	bu:SetScript("OnClick", function()
		ToggleFrame(list)
	end)
	dd.button = bu

	local opt, index = {}, 0
	for i, j in pairs(data) do
		opt[i] = CreateFrame("Button", nil, list)
		opt[i]:SetPoint("TOPLEFT", 3, -4 - (i-1)*(height+2))
		opt[i]:SetSize(width - 6, height)
		opt[i].bg = F.CreateBG(opt[i], 1, 1, .7)
		
		local text = F.CreateFS(opt[i], j, "CENTER", "LEFT", 5, 0)
		text:SetPoint("RIGHT", -5, 0)
		opt[i].text = j
		opt[i].__owner = dd
		opt[i]:SetScript("OnClick", function(self)
			self.__owner.Text:SetText(self.text)
			self:GetParent():Hide()
		end)
		opt[i]:HookScript("OnClick", function(self)
			GLOBEVARIABLE(value, self.__owner.Text:GetText())
		end)
		opt[i]:SetScript("OnEnter", function() opt[i].bg:SetBackdropColor(0, 1, 1, .7) end)
		opt[i]:SetScript("OnLeave", function() opt[i].bg:SetBackdropColor(0, 0, 0, .7) end)

		dd.options[i] = opt[i]
		index = index + 1
	end
	list:SetSize(width, index*(height+2) + 6)

	return dd
end

-- slider bar
local function CreateBar(self, name, width, height, min, max, step, value, text)
	local s = CreateFrame("Slider", name.."Bar", self, "OptionsSliderTemplate")
	s:SetSize(width, height)
	_G[s:GetName().."Low"]:SetText(min/10)
	_G[s:GetName().."High"]:SetText(max/10)
	
	s:SetMinMaxValues(min, max)
	s:SetObeyStepOnDrag(true)
	s:SetValueStep(step)
	s:SetOrientation("HORIZONTAL")
	
	s:SetValue(GLOBEVARIABLE(value)*10)
	
	s.text = F.CreateFS(s, text.." "..GLOBEVARIABLE(value), "LEFT")
	s.text:SetPoint("BOTTOM", s, "TOP", 0, 5)
	
	s:SetScript("OnValueChanged", function(self)
		local n = tonumber(self:GetValue())
		if n then
			GLOBEVARIABLE(value, n/10)
		end
		s.text:SetText(text.." "..GLOBEVARIABLE(value), "LEFT")
	end)
	
	return s
end

-- tooltip
local function CreateTooltip(self, tex, anchor, title, text)
	local i = CreateFrame("Button", nil, self)
	--local f = i:GetParent()
	i:SetSize(G.fontSize+2, G.fontSize+2)
	--i:SetFrameLevel(f:GetFrameLevel()+2)
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

F.CreateEKMOptions = function()
	if MainFrame ~= nil then
		MainFrame:Show()
		return
	end
	
	MainFrame = CreateFrame("Frame", "EKMinimapOptions", UIParent)
	tinsert(UISpecialFrames, "EKMinimapOptions")
	
	MainFrame:SetFrameStrata("DIALOG")
	MainFrame:SetWidth(500)
	MainFrame:SetHeight(420)
	MainFrame:SetPoint("CENTER", UIParent)
	MainFrame:SetMovable(true)
	MainFrame:EnableMouse(true)
	MainFrame:RegisterForDrag("LeftButton")
	MainFrame.bg = F.CreateBG(MainFrame, 5, 5, .4)
	MainFrame:SetClampedToScreen(true)
	MainFrame:SetScript("OnDragStart", function() MainFrame:StartMoving() end)
	MainFrame:SetScript("OnDragStop", function() MainFrame:StopMovingOrSizing() end)
	
	-- Main title
	local Title = F.CreateFS(MainFrame, "|cff00ffffEK|rMinimap "..v, "CENTER", "TOP", 0, 10)
	
	-- minimap / 小地圖
	
	local mapTitle = F.CreateFS(MainFrame, MINIMAP_LABEL, "LEFT", "TOPLEFT", 24, -20)

	local ClickMenuBox = CreateCheckBox(MainFrame, L.ClickMenuOpt, "ClickMenu")
	ClickMenuBox:SetPoint("TOPLEFT", MainFrame, 24, -44)
	
	local HoverClockBox = CreateCheckBox(MainFrame, L.HoverClockOpt, "HoverClock")
	HoverClockBox:SetPoint("BOTTOM", ClickMenuBox, 0, -30)
	
	local mapPosText = F.CreateFS(MainFrame, L.AnchorOpt, "LEFT")
	mapPosText:SetPoint("TOPLEFT", HoverClockBox, "BOTTOMLEFT", 10, -10)
	
	local mapAnchor = CreateDropDown(MainFrame, 120, 20, optList, "MinimapAnchor")
	mapAnchor:SetPoint("LEFT", mapPosText, "RIGHT", 4, 0)
	
	local mapXText = F.CreateFS(MainFrame, "X", "LEFT")
	mapXText:SetPoint("LEFT", mapPosText, 0, -30)
	
	local mapXBox = CreateEditBox(MainFrame, 68, 20, "MinimapX")
	mapXBox:SetPoint("LEFT", mapXText, "RIGHT", 4, 0)
	
	local mapYText = F.CreateFS(MainFrame, "Y", "LEFT")
	mapYText:SetPoint("LEFT", mapXBox, "RIGHT", 8, 0)
	
	local mapYBox = CreateEditBox(MainFrame, 68, 20, "MinimapY")
	mapYBox:SetPoint("LEFT", mapYText, "RIGHT", 4, 0)

	local mapSizeBar = CreateBar(MainFrame, "Size", 160, 20, 10, 20, 1, "MinimapScale", L.SizeOpt)
	mapSizeBar:SetPoint("TOPLEFT", mapXBox, "BOTTOMRIGHT", -70, -30)
	
	-- QuestWatch tracker
	
	local QWFTitle = F.CreateFS(MainFrame, L.QuestWatchOpt, "LEFT", "LEFT", 24, -30)
	
	local QWFBox = CreateCheckBox(MainFrame, L.QuestWatchStyleOpt, "QuestWatchStyle")
	QWFBox:SetPoint("LEFT", MainFrame, 24, -60)
	
	local StarBox = CreateCheckBox(MainFrame, L.QuestWatchStarOpt, "QuestWatchStar")
	StarBox:SetPoint("BOTTOM", QWFBox, 0, -30)
	
	local QWFPosText = F.CreateFS(MainFrame, L.AnchorOpt, "LEFT")
	QWFPosText:SetPoint("TOPLEFT", StarBox, "BOTTOMLEFT", 10, -10)
	
	local QWFAnchor = CreateDropDown(MainFrame, 120, 20, optList, "QuestWatchAnchor")
	QWFAnchor:SetPoint("LEFT", QWFPosText, "RIGHT", 4, 0)
	
	local QWFXText = F.CreateFS(MainFrame, "X", "LEFT")
	QWFXText:SetPoint("LEFT", QWFPosText, 0, -30)
	
	local QWFXBox = CreateEditBox(MainFrame, 68, 20, "QuestWatchX")
	QWFXBox:SetPoint("LEFT", QWFXText, "RIGHT", 4, 0)
	
	local QWFYText = F.CreateFS(MainFrame, "Y", "LEFT")
	QWFYText:SetPoint("LEFT", QWFXBox, "RIGHT", 8, 0)
	
	local QWFYBox = CreateEditBox(MainFrame, 68, 20, "QuestWatchY")
	QWFYBox:SetPoint("LEFT", QWFYText, "RIGHT", 4, 0)

	-- world map
	
	local WMFTitle = F.CreateFS(MainFrame, WORLDMAP_BUTTON, "LEFT", "TOPLEFT", 260, -20)
	
	local WMFBox = CreateCheckBox(MainFrame, L.WorldMapStyleOpt, "WorldMapStyle")
	WMFBox:SetPoint("TOP", MainFrame, 24, -44)
	
	local fadeBox = CreateCheckBox(MainFrame, L.fadeOpt, "WorldMapFade")
	fadeBox:SetPoint("BOTTOM", WMFBox, 0, -30)
	
	local WMFScaleBar = CreateBar(MainFrame, "WMFScale", 160, 20, 0, 10, 1, "WorldMapScale", L.SizeOpt)
	WMFScaleBar:SetPoint("TOPLEFT", fadeBox, "BOTTOMRIGHT", 0, -24)
	
	local WMFFadeBar = CreateBar(MainFrame, "WMFFade", 160, 20, 0, 10, 1, "WorldMapAlpha", L.AlphaOpt)
	WMFFadeBar:SetPoint("TOP", WMFScaleBar, "BOTTOM", 0, -30)
	
	local WMFi = CreateTooltip(MainFrame, G.Info, "ANCHOR_RIGHT", INFO, L.WMFTip)
	WMFi:SetPoint("RIGHT", WMFTitle, G.fontSize+2, 0)
	
	-- infos
	
	local info = F.CreateFS(MainFrame, INFO, "LEFT", "LEFT", 260, -30)
	
	local q = CreateTooltip(MainFrame, G.Question, "ANCHOR_RIGHT", INFO, L.tempTip1.."\n\n"..L.tempTip2)
	q:SetSize(G.fontSize*3, G.fontSize*3)
	q:SetPoint("LEFT", MainFrame, 250, -60)

	local infoDrag1 = F.CreateFS(MainFrame, L.dragInfo, "LEFT")
	infoDrag1:SetPoint("LEFT", q, "RIGHT", 0, 8)
	
	local infoScroll = F.CreateFS(MainFrame, L.scrollInfo, "LEFT")
	infoScroll:SetPoint("LEFT", q, "RIGHT", 0, -8)
	
	local infoApply = F.CreateFS(MainFrame, L.Apply, "RIGHT")
	infoApply:SetPoint("TOPLEFT", q, "BOTTOMLEFT", 4, -4)

	-- buttons
	
	local closeButton = CreateButton(MainFrame, 22, 22, "X")
	closeButton:SetPoint("TOPRIGHT", MainFrame, -8, -8)
	closeButton:SetScript("OnClick", function() MainFrame:Hide() end)
	
	local reloadButton = CreateButton(MainFrame, 80, 30, APPLY)
	reloadButton:SetPoint("BOTTOMRIGHT", MainFrame, -20, 20)
	reloadButton:SetScript("OnClick", function() ReloadUI() end)
	
	local reposButton = CreateButton(MainFrame, 170, 30, L.posApply)
	reposButton:SetPoint("BOTTOMRIGHT", MainFrame, -20, 60)
	reposButton:SetScript("OnClick", function() F.ResetM() F.ResetO() end)
	
	local i = CreateTooltip(reposButton, G.Info, "ANCHOR_RIGHT", INFO, L.tempTip3)
	i:SetPoint("TOPRIGHT", reposButton, 8, 8)
	
	local resetButton = CreateButton(MainFrame, 80, 30, RESET)
	resetButton:SetPoint("RIGHT", reloadButton, "LEFT", -10, 0)
	resetButton:SetScript("OnClick", function()
		EKMinimapDB = C.defaultSettings
		ReloadUI()
	end)
end

SlashCmdList["EKMINIMAP"] = function()
	F.CreateEKMOptions()
end
SLASH_EKMINIMAP1 = "/ekm"
SLASH_EKMINIMAP2 = "/ekminimap"