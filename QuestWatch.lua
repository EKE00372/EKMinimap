local addon, ns = ...
local C, F, G, L = unpack(ns)

local QWF, QTF = QuestWatchFrame, QuestTimerFrame

--================================================--
-----------------    [[ Core ]]    -----------------
--================================================--

-- [[ Load Blizzard ]] --

local function setQWF()
	if not EKMinimapDB["QuestWatchStyle"] then return end

	-- create holder
	local ObjectiveFrameHolder = CreateFrame("Frame", "QWFHoler", UIParent)
	ObjectiveFrameHolder:SetSize(160, G.QfontSize + 4)
	ObjectiveFrameHolder:ClearAllPoints()
	ObjectiveFrameHolder:SetPoint(EKMinimapDB["QuestWatchAnchor"], UIParent, EKMinimapDB["QuestWatchAnchor"], EKMinimapDB["QuestWatchX"], EKMinimapDB["QuestWatchY"])
	ObjectiveFrameHolder:SetMovable(true)
	
	QWF:SetClampedToScreen(true)
	QWF:SetMovable(true)
	QWF:SetUserPlaced(true)
	
	hooksecurefunc(QWF, "SetPoint", function(self, _, parent)
		if parent == "MinimapCluster" or parent == _G.MinimapCluster then
			self:ClearAllPoints()
			self:SetPoint("TOPLEFT", ObjectiveFrameHolder)
		end
	end)
	
	hooksecurefunc(QTF, "SetPoint", function(self, _, parent)
		if parent ~= ObjectiveFrameHolder then
			self:ClearAllPoints()
			self:SetPoint("TOPRIGHT", ObjectiveFrameHolder , "TOPLEFT", -10 , 0)
		end
	end)
	--[[
	-- set position
	QWF:SetParent(ObjectiveFrameHolder)
	QWF:ClearAllPoints()
	QWF:SetPoint("TOPLEFT", ObjectiveFrameHolder)
	QWF:SetMovable(true)
	QWF:SetClampedToScreen(true)
	]]--
	-- add title line
	local HeaderBar = CreateFrame("StatusBar", nil, ObjectiveFrameHolder)
	HeaderBar:SetSize(140, 3)
	HeaderBar:SetPoint("TOPRIGHT", ObjectiveFrameHolder, 0, -2)
	HeaderBar:SetStatusBarTexture(G.Tex)
	HeaderBar:SetStatusBarColor(G.Ccolors.r, G.Ccolors.g, G.Ccolors.b)
	HeaderBar.bg = F.CreateBG(HeaderBar, 3, 3, 1)

	-- add title text
	HeaderBar.Text = F.CreateFS(HeaderBar, CURRENT_QUESTS, "RIGHT", "RIGHT", 2, G.QfontSize)
	HeaderBar.Text:SetFont(G.font, G.QfontSize, G.QfontFlag)
	HeaderBar.Text:SetTextColor(G.Ccolors.r, G.Ccolors.g, G.Ccolors.b)
	
	local function QWF_Tooltip(self)
		GameTooltip:SetOwner(self, "ANCHOR_TOP")
		GameTooltip:AddDoubleLine(DRAG_MODEL, "Alt + |TInterface\\TUTORIALFRAME\\UI-TUTORIAL-FRAME:13:11:0:-1:512:512:12:66:333:411|t", 0, 1, 0.5, 1, 1, 1)
		GameTooltip:Show()
	end
	
	local QWFMove = CreateFrame("FRAME", "QWFdrag", ObjectiveFrameHolder)
		-- Create frame for click
		QWFMove:SetSize(160, G.QfontSize + 6)
		QWFMove:SetPoint("TOP", ObjectiveFrameHolder, 0, G.QfontSize)
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

--=================================================--
-----------------    [[ Block ]]    -----------------
--=================================================--

local function styleQuestBlock()
	
	-- Change font of watched quests
	for i = 1, 30 do
		local Line = _G["QuestWatchLine"..i]

		Line:SetFont(G.font, G.QfontSize-2, G.QfontFlag)
		Line:SetHeight(G.QfontSize+2)
		Line:SetShadowOffset(0, 0)
	end
	
	--hooksecurefunc("QuestWatch_Update", function()
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
end

local frame = CreateFrame("FRAME")
	frame:RegisterEvent("PLAYER_LOGIN")
	frame:SetScript("OnEvent", OnEvent)