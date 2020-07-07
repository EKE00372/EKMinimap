local addon, ns = ...
local C, F, G, L = unpack(ns)

local QWF = QuestWatchFrame

--================================================--
-----------------    [[ Core ]]    -----------------
--================================================--

-- [[ Load Blizzard ]] --
--[[
local function setParent()
	local ObjectiveFrameHolder = CreateFrame("Frame", "QWFHoler", UIParent)
	ObjectiveFrameHolder:SetSize(140, G.QfontSize + 4)
	ObjectiveFrameHolder:ClearAllPoints()
	--ObjectiveFrameHolder:SetPoint(EKMinimapDB["QuestWatchAnchor"], UIParent, EKMinimapDB["QuestWatchX"], EKMinimapDB["QuestWatchY"])
	ObjectiveFrameHolder:SetPoint("TOPLEFT", UIParent, "TOPRIGHT", -200, -200)
	--ObjectiveFrameHolder:Hide()
end

local function updateQWFPos()
	if not EKMinimapDB["QuestWatchStyle"] then return end
	
	--QWF:SetPoint(EKMinimapDB["QuestWatchAnchor"], UIParent, EKMinimapDB["QuestWatchX"], EKMinimapDB["QuestWatchY"])
	QWF:SetParent(ObjectiveFrameHolder)
	QWF:ClearAllPoints()
	QWF:SetPoint("TOPLEFT", ObjectiveFrameHolder)
end]]--

local function setQWF()
	if not EKMinimapDB["QuestWatchStyle"] then return end
	
	QWF:SetMovable(true)
	--QWF:SetUserPlaced(true)
	QWF:SetClampedToScreen(true)
	--QWF:SetHeight(EKMinimapDB["QuestWatchHeight"])
	--setParent()
	--updateQWFPos()
	--QWF:EnableMouse(true)
	
	local ObjectiveFrameHolder = CreateFrame("Frame", "QWFHoler", UIParent)
	ObjectiveFrameHolder:SetSize(200, G.QfontSize + 4)
	ObjectiveFrameHolder:ClearAllPoints()
	--ObjectiveFrameHolder:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 200, -270)
	ObjectiveFrameHolder:SetPoint(EKMinimapDB["QuestWatchAnchor"], UIParent, EKMinimapDB["QuestWatchAnchor"], EKMinimapDB["QuestWatchX"], EKMinimapDB["QuestWatchY"])

	--QWF:SetParent(ObjectiveFrameHolder)
	QWF:ClearAllPoints()
	QWF:SetPoint("TOPLEFT", ObjectiveFrameHolder)
end

--=================================================--
-----------------    [[ Block ]]    -----------------
--=================================================--

local function styleQuestBlock()
	local HeaderBar = CreateFrame("StatusBar", nil, QWF)
	local HeaderText = HeaderBar:CreateFontString(nil, "OVERLAY")

	-- title line
	HeaderBar:SetSize(140, 3)
	HeaderBar:SetPoint("RIGHT", QWF, "LEFT", 0, -2)
	HeaderBar:SetStatusBarTexture(G.Tex)
	HeaderBar:SetStatusBarColor(G.Ccolors.r, G.Ccolors.g, G.Ccolors.b)
	-- title line shadow
	sd = CreateFrame("Frame", nil, HeaderBar)
	sd:SetPoint("TOPLEFT", -3, 3)
	sd:SetPoint("BOTTOMRIGHT", 3, -3)
	sd:SetFrameStrata(HeaderBar:GetFrameStrata())
	sd:SetFrameLevel(0)
	sd:SetBackdrop({edgeFile = G.Glow, edgeSize = 3,})
	sd:SetBackdropBorderColor(0, 0, 0)

	-- title
	HeaderText:SetFont(G.font, G.QfontSize, G.QfontFlag)
	HeaderText:SetTextColor(G.Ccolors.r, G.Ccolors.g, G.Ccolors.b)
	HeaderText:SetShadowOffset(0, 0)
	HeaderText:SetPoint("RIGHT", HeaderBar, "RIGHT", -2, G.QfontSize)
	HeaderText:SetText(CURRENT_QUESTS)
	
	-- Change font of watched quests
	for i = 1, 30 do
		local Line = _G["QuestWatchLine"..i]

		Line:SetFont(G.font, G.QfontSize-2, G.QfontFlag)
		Line:SetHeight(G.QfontSize+2)
		Line:SetShadowOffset(0, 0)
	end
	
	--hooksecurefunc("QuestWatch_Update", function()
end


--===================================================--
-----------------    [[ Movable ]]    -----------------
--===================================================--

--tooltip for drag
local function moveQWF()
	if not EKMinimapDB["QuestWatchStyle"] then return end

	local function QWF_Tooltip(self)
		GameTooltip:SetOwner(self, "ANCHOR_TOP")
		GameTooltip:AddDoubleLine(DRAG_MODEL, "Alt + |TInterface\\TUTORIALFRAME\\UI-TUTORIAL-FRAME:13:11:0:-1:512:512:12:66:333:411|t", 0, 1, 0.5, 1, 1, 1)
		GameTooltip:Show()
	end

	-- Make a Frame for Drag / 創建一個供移動的框架
	local QWFMove = CreateFrame("FRAME", "QWFdrag", QWF)
		-- Create frame for click
		QWFMove:SetSize(140, G.QfontSize + 2)
		QWFMove:SetPoint("TOPLEFT", QWF, 0, G.QfontSize)
		QWFMove:SetFrameStrata("BACKGROUND")
		QWFMove:EnableMouse(true)
		-- Make it drag-able
		QWFMove:RegisterForDrag("RightButton")
		QWFMove:SetHitRectInsets(-5, -5, -5, -5)
		-- Alt+right click to drag frame
		QWFMove:SetScript("OnDragStart", function(self, button)
			if IsAltKeyDown() then
				local frame = self:GetParent()
				frame:StartMoving()
			end
		end)
		QWFMove:SetScript("OnDragStop", function(self, button)
			local frame = self:GetParent()
			frame:StopMovingOrSizing()
		end)
		-- Show tooltip for drag
		QWFMove:SetScript("OnEnter", function(self)
			QWF_Tooltip(self)
		end)
		QWFMove:SetScript("OnLeave", function(self)
			GameTooltip:Hide()
		end)
end

-- Reset / 重置
F.ResetO = function()
	--updateQWFPos()
	setQWF()
end

local function OnEvent()
	--if not IsAddOnLoaded("Blizzard_QuestWatchTracker") then
	--	LoadAddOn("Blizzard_QuestWatchTracker")
	--end
	--setParent()
	setQWF()
	styleQuestBlock()
	moveQWF()
end

local frame = CreateFrame("FRAME")
	frame:RegisterEvent("PLAYER_LOGIN")
	frame:SetScript("OnEvent", OnEvent)