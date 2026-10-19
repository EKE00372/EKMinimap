local addon, ns = ...
local C, F, G, L = unpack(ns)

local WatchFrame = WatchFrame
local ObjectiveFrameHolder
local trackerEnabled = false

local function updateWatchFramePos()
	ObjectiveFrameHolder:ClearAllPoints()
	ObjectiveFrameHolder:SetPoint(F.GetEKMOption("QuestWatchAnchor"), UIParent, F.GetEKMOption("QuestWatchAnchor"), F.GetEKMOption("QuestWatchX"), F.GetEKMOption("QuestWatchY"))
	WatchFrame:ClearAllPoints()
	WatchFrame:SetPoint("TOPRIGHT", ObjectiveFrameHolder)
	-- 原生依父框體底邊計算可用高度；位置改變後重新排版現有追蹤項目。
	WatchFrame_Update(WatchFrame)
end

local function styleWatchLine(line)
	line.text:SetFont(G.font, G.fontSize, G.fontFlag)
	line.text:SetShadowOffset(0, 0)
	if F.GetEKMOption("QuestWatchStar") then
		line.dash:SetWordWrap(false)
		-- 原生 Reset 會回收文字與錨點；同時解除星號保留的前綴寬度。
		hooksecurefunc(line, "Reset", function(self)
			self.dash:SetWidth(0)
		end)
	end
end

local function styleQuestItem(button)
	button:SetSize(24, 24)
	button:GetNormalTexture():SetAlpha(0)
	button:GetPushedTexture():SetAlpha(0)
	button:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
	local icon = _G[button:GetName().."IconTexture"]
	icon:SetAllPoints(button)
	icon:SetTexCoord(.08, .92, .08, .92)
	F.CreateBG(icon, 3, 3, 0)
	_G[button:GetName().."Cooldown"]:SetAllPoints(button)
end

local function setWatchFrame()
	ObjectiveFrameHolder = CreateFrame("Frame", "EKMinimapWatchFrameHolder", UIParent)
	ObjectiveFrameHolder:SetSize(204, 30)
	ObjectiveFrameHolder:SetMovable(true)
	ObjectiveFrameHolder:SetClampedToScreen(true)
	-- 離開原生右側 layout，但保留全畫面父框體供 WatchFrame_Update 計算高度。
	WatchFrame:SetParent(UIParent)
	-- 只夾住標題範圍，避免舊的內容高度在向下拖曳時將整個追蹤框推回原處。
	WatchFrame:SetClampedToScreen(false)

	WatchFrameTitle:SetFont(G.font, G.fontSize + 2, G.fontFlag)
	WatchFrameTitle:SetShadowOffset(0, 0)
	WatchFrameTitle:SetTextColor(G.Ccolors.r, G.Ccolors.g, G.Ccolors.b)

	local HeaderBar = CreateFrame("StatusBar", nil, WatchFrameHeader)
	HeaderBar:SetSize(140, 3)
	HeaderBar:SetPoint("TOPLEFT", WatchFrameHeader, "BOTTOMLEFT", 0, -3)
	HeaderBar:SetStatusBarTexture(G.Tex)
	HeaderBar:SetStatusBarColor(G.Ccolors.r, G.Ccolors.g, G.Ccolors.b)
	F.CreateBG(HeaderBar, 3, 3, 1)

	local Button = WatchFrameCollapseExpandButton
	Button:GetNormalTexture():SetAlpha(0)
	Button:GetPushedTexture():SetAlpha(0)
	Button:GetHighlightTexture():SetAlpha(0)
	Button:GetDisabledTexture():SetAlpha(0)
	Button.bg = F.CreateBG(Button, 3, 3, .5)
	Button.text = F.CreateFS(Button, "-", "CENTER", "CENTER", 0, 0)
	Button.text:SetTextColor(G.Ccolors.r, G.Ccolors.g, G.Ccolors.b)
	local function updateCollapseState()
		Button.text:SetText(WatchFrame.collapsed and "+" or "-")
		HeaderBar:SetShown(not WatchFrame.collapsed)
	end
	hooksecurefunc("WatchFrame_Collapse", updateCollapseState)
	hooksecurefunc("WatchFrame_Expand", updateCollapseState)
	Button:HookScript("OnEnter", function(self)
		self.bg:SetBackdropBorderColor(G.Ccolors.r, G.Ccolors.g, G.Ccolors.b, 1)
	end)
	Button:HookScript("OnLeave", function(self)
		self.bg:SetBackdropBorderColor(0, 0, 0, 1)
	end)
	Button:HookScript("OnEnable", function(self) self.text:SetAlpha(1) end)
	Button:HookScript("OnDisable", function(self) self.text:SetAlpha(.35) end)
	Button.text:SetAlpha(Button:IsEnabled() and 1 or .35)
	updateCollapseState()

	-- 池內已建立及未來建立的行都只修改自己的字型，不改共用 FontObject。
	for _, line in ipairs({ WatchFrameLines:GetChildren() }) do
		if line.text and line.dash then styleWatchLine(line) end
	end
	hooksecurefunc("WatchFrameLineTemplate_OnLoad", styleWatchLine)
	if F.GetEKMOption("QuestWatchStar") then
		hooksecurefunc("WatchFrame_SetLine", function(line, anchor, verticalOffset, isHeader, text, dash)
			if dash == 1 or dash == 2 then
				-- DASH_WIDTH 是原生私有快取；只替換本行前綴並保持原生配置寬度。
				local width = line.dash:GetWidth()
				line.dash:SetText("★ ")
				line.dash:SetWidth(width)
			end
		end)
	end

	for i = 1, WATCHFRAME_NUM_ITEMS do styleQuestItem(_G["WatchFrameItem"..i]) end
	hooksecurefunc("WatchFrameItem_OnLoad", styleQuestItem)

	-- 直接沿用原生標題命中區；右鍵選單與一般點擊仍由原生負責。
	WatchFrameHeader:RegisterForDrag("RightButton")
	WatchFrameHeader:HookScript("OnDragStart", function()
		if IsAltKeyDown() and not F.CombatError() then ObjectiveFrameHolder:StartMoving() end
	end)
	WatchFrameHeader:HookScript("OnDragStop", function()
		ObjectiveFrameHolder:StopMovingOrSizing()
		WatchFrame_Update(WatchFrame)
	end)
	WatchFrameHeader:HookScript("OnHide", function() ObjectiveFrameHolder:StopMovingOrSizing() end)
	WatchFrameHeader:HookScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_TOP")
		GameTooltip:AddDoubleLine(DRAG_MODEL, "Alt + |TInterface\\TUTORIALFRAME\\UI-TUTORIAL-FRAME:13:11:0:-1:512:512:12:66:333:411|t", 0, 1, .5, 1, 1, 1)
		GameTooltip:Show()
	end)
	WatchFrameHeader:HookScript("OnLeave", function() GameTooltip:Hide() end)
	updateWatchFramePos()
end

F.ResetO = function()
	if not trackerEnabled then return end
	updateWatchFramePos()
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", function(self, event)
	self:UnregisterEvent(event)
	if not F.GetEKMOption("QuestWatchStyle") or C_AddOns.IsAddOnLoaded("Questie") then return end
	trackerEnabled = true
	setWatchFrame()
end)
