local addon, ns = ...
local C, F, G, L = unpack(ns)

local OTF = ObjectiveTrackerFrame

--================================================--
-----------------    [[ Core ]]    -----------------
--================================================--

-- [[ Load Blizzard ]] --

local function updateOTFPos()
	if not EKMinimapDB["ObjectiveStyle"] then return end
	
	OTF:ClearAllPoints()
	--OTF:SetPoint(unpack(C.OTF))
	OTF:SetPoint(EKMinimapDB["ObjectiveAnchor"], UIParent, EKMinimapDB["ObjectiveX"], EKMinimapDB["ObjectiveY"])
end

local function setOTF()
	if not EKMinimapDB["ObjectiveStyle"] then return end
	
	OTF:SetMovable(true)
	OTF:SetUserPlaced(true)
	OTF:SetClampedToScreen(true)
	OTF:SetHeight(EKMinimapDB["ObjectiveHeight"])
	updateOTFPos()
	--OTF:EnableMouse(true)
end

--=================================================--
-----------------    [[ Block ]]    -----------------
--=================================================--

local function styleQuestBlock()
	if not EKMinimapDB["ObjectiveStyle"] then return end
	
	-- [[ main title / 大標題 ]] --

	local function reskinHeader(header)
		header.Background:SetAtlas(nil)
		header.Background:Hide()
		
		header.Text:SetFont(G.font, G.obfontSize, G.obfontFlag)
		header.Text:SetTextColor(1, .75, 0)
		header.Text:SetShadowColor(0, 0, 0, 1)
		header.Text:SetShadowOffset(0, 0)
		header.Text:SetWordWrap(false)
		
		header.Text:ClearAllPoints()
		header.Text:SetPoint("RIGHT", header, -5, 0)
		header.Text:SetJustifyH("RIGHT")
	end

	local headers = {
		ObjectiveTrackerBlocksFrame.QuestHeader,
		ObjectiveTrackerBlocksFrame.AchievementHeader,
		ObjectiveTrackerBlocksFrame.ScenarioHeader,
		BONUS_OBJECTIVE_TRACKER_MODULE.Header,
		WORLD_QUEST_TRACKER_MODULE.Header,
	}
	for _, header in pairs(headers) do
		reskinHeader(header)
	end

	-- [[ quest title / 任務標題 ]] --

	hooksecurefunc(QUEST_TRACKER_MODULE, "SetBlockHeader", function(_, block)
		block.HeaderText:SetFont(G.font, G.obfontSize - 2, G.obfontFlag)
		block.HeaderText:SetShadowColor(0, 0, 0, 1)
		block.HeaderText:SetShadowOffset(0, 0)
		block.HeaderText:SetWordWrap(false)
		block.HeaderText:SetTextColor(G.Ccolors.r, G.Ccolors.g, G.Ccolors.b)
		block.HeaderText:SetJustifyH("LEFT")
	end)

	local function hoverquest(_, block)
		block.HeaderText:SetTextColor(G.Ccolors.r, G.Ccolors.g, G.Ccolors.b)
	end

	hooksecurefunc(QUEST_TRACKER_MODULE, "OnBlockHeaderLeave", hoverquest)

	-- [[ achievement title / 成就標題 ]] --

	hooksecurefunc(ACHIEVEMENT_TRACKER_MODULE, "SetBlockHeader", function(_, block)
		local trackedAchievements = {GetTrackedAchievements()}

		for i = 1, #trackedAchievements do
			local achieveID = trackedAchievements[i]
			local _, achievementName, _, completed, _, _, _, description, _, icon, _, _, wasEarnedByMe = GetAchievementInfo(achieveID)

			if not wasEarnedByMe then
				block.HeaderText:SetFont(G.font, G.obfontSize - 2, G.obfontFlag)
				block.HeaderText:SetShadowColor(0, 0, 0, 1)
				block.HeaderText:SetShadowOffset(0, 0)
				block.HeaderText:SetWordWrap(false)
				block.HeaderText:SetTextColor(G.Ccolors.r, G.Ccolors.g, G.Ccolors.b)
				block.HeaderText:SetJustifyH("LEFT")
			end
		end
	end)

	local function hoverachieve(_, block)
		block.HeaderText:SetTextColor(G.Ccolors.r, G.Ccolors.g, G.Ccolors.b)
	end

	hooksecurefunc(ACHIEVEMENT_TRACKER_MODULE, "OnBlockHeaderLeave", hoverachieve)

	-- [[ 細項與內文 ]] --

	hooksecurefunc(DEFAULT_OBJECTIVE_TRACKER_MODULE, "AddObjective", function(self, block, objectiveKey, _, lineType)
		local line = self:GetLine(block, objectiveKey, lineType)
		
		line.Text:SetFont(G.font, G.obfontSize - 4, G.obfontFlag)
		line.Text:SetShadowColor(0, 0, 0, 1)
		line.Text:SetShadowOffset(0, 0)
		line.Text:SetWidth(OTF:GetWidth() - 25)
			
		if line.Dash and line.Dash:IsShown() then
			line.Dash:SetFont(G.font, G.obfontSize - 2, G.obfontFlag)
			
			if EKMinimapDB["ObjectiveStar"] then
				line.Dash:SetText("★ ")
			else
				line.Dash:SetText("-")
			end
			
			line.Dash:SetShadowColor(0, 0, 0, 1)
			line.Dash:SetShadowOffset(0, 0)
		end
	end)
	
	-- [[ Quick Click: Alt to Share, Ctrl to Abandon / 快速按鍵：alt分享ctrl放棄 ]]--

	local function QuestHook(id)
		local questLogIndex = GetQuestLogIndexByID(id)
		
		if IsControlKeyDown() and CanAbandonQuest(id) then
			QuestMapQuestOptions_AbandonQuest(id)
		elseif IsAltKeyDown() and GetQuestLogPushable(questLogIndex) then
			QuestMapQuestOptions_ShareQuest(id)
		end
	end

	hooksecurefunc(QUEST_TRACKER_MODULE, "OnBlockHeaderClick", function(self, block)
		QuestHook(block.id)
	end)
	hooksecurefunc("QuestMapLogTitleButton_OnClick", function(self)
		QuestHook(self.questID)
	end)
end

--===================================================--
-----------------    [[ Movable ]]    -----------------
--===================================================--

local function moveOTF()
	if not EKMinimapDB["ObjectiveStyle"] then return end
	
	local function createOTFTooltip(self)
		GameTooltip:SetOwner(self, "ANCHOR_TOP")
		GameTooltip:AddDoubleLine(DRAG_MODEL, "Alt + |TInterface\\TUTORIALFRAME\\UI-TUTORIAL-FRAME:13:11:0:-1:512:512:12:66:333:411|t", 0, 1, 0.5, 1, 1, 1)
		GameTooltip:Show()
	end

	-- Make a Frame for Drag / 創建一個供移動的框架
	local OTFMove = CreateFrame("FRAME", "OTFdrag", OTF)
		OTFMove:SetHeight(G.obfontSize + 2)
		OTFMove:SetPoint("TOPLEFT", OTF)
		OTFMove:SetPoint("TOPRIGHT", OTF)
		OTFMove:SetFrameLevel(OTF:GetFrameLevel()+2)
		OTFMove:EnableMouse(true)
		OTFMove:RegisterForDrag("RightButton")
		OTFMove:SetHitRectInsets(-5, -5, -5, -5)
		
	-- Alt+right click to drag frame
	OTFMove:SetScript("OnDragStart", function(self, button)
		if IsAltKeyDown() then
			local frame = self:GetParent()
			frame:StartMoving()
		end
	end)
	OTFMove:SetScript("OnDragStop", function(self, button)
		local frame = self:GetParent()
		frame:StopMovingOrSizing()
	end)
	-- Show tooltip for drag
	OTFMove:SetScript("OnEnter", function(self)
		createOTFTooltip(self)
	end)
	OTFMove:SetScript("OnLeave", function(self)
		GameTooltip:Hide()
	end)
end

--====================================================--
-----------------    [[ Collapse ]]    -----------------
--====================================================--

local function miniIcon()
	if not EKMinimapDB["ObjectiveStyle"] then return end
	
	-- creat icon  / 創建按鈕
	local Minimize = OTF.HeaderMenu.MinimizeButton
		Minimize:SetSize(16, 20)
		Minimize:SetNormalTexture("")
		Minimize:SetPushedTexture("")
		-- Close  / 關閉按鈕
		Minimize.minus = Minimize:CreateFontString(nil, "OVERLAY")
		Minimize.minus:SetFont(G.font, G.obfontSize, G.obfontFlag)
		Minimize.minus:SetText(">")
		Minimize.minus:SetPoint("CENTER")
		Minimize.minus:SetTextColor(1, 1, 1)
		Minimize.minus:SetShadowOffset(0, 0)
		Minimize.minus:SetShadowColor(0, 0, 0, 1)
		-- Open / 開啟按鈕
		Minimize.plus = Minimize:CreateFontString(nil, "OVERLAY")
		Minimize.plus:SetFont(G.font, G.obfontSize, G.obfontFlag)
		Minimize.plus:SetText("<")
		Minimize.plus:SetPoint("CENTER")
		Minimize.plus:SetTextColor(1, 1, 1)
		Minimize.plus:SetShadowOffset(0, 0)
		Minimize.plus:SetShadowColor(0, 0, 0, 1)
		Minimize.plus:Hide()

	-- Close Title / 收起後的標題
	local Title = OTF.HeaderMenu.Title
		Title:SetFont(G.font, G.obfontSize, G.obfontFlag)
		Title:SetTextColor(1, .75, 0)
		Title:SetShadowOffset(0, 0)
		Title:SetShadowColor(0, 0, 0, 1)
		Title:ClearAllPoints()
		Title:SetPoint("RIGHT", Minimize, "LEFT", 0, 0)	

		-- Let It Work / 使其工作
		Minimize:HookScript("OnEnter", function()
			Minimize.minus:SetTextColor(.7, .5, 0)
			Minimize.plus:SetTextColor(.7, .5, 0)
		end)
		Minimize:HookScript("OnLeave", function()
			Minimize.minus:SetTextColor(1, 1, 1)
			Minimize.plus:SetTextColor(1, 1, 1)
		end)
		hooksecurefunc("ObjectiveTracker_Collapse", function()
			Minimize.plus:Show()
			Minimize.minus:Hide()
		end)
		hooksecurefunc("ObjectiveTracker_Expand",  function()
			Minimize.plus:Hide()
			Minimize.minus:Show()
		end)
end

--================================================--
-----------------    [[ Load ]]    -----------------
--================================================--

-- Reset / 重置
F.ResetO = function()
	updateOTFPos()
end

local function OnEvent()
	if not IsAddOnLoaded("Blizzard_ObjectiveTracker") then
		LoadAddOn("Blizzard_ObjectiveTracker")
	end
	
	setOTF()
	styleQuestBlock()
	moveOTF()
	miniIcon()
end

local frame = CreateFrame("FRAME")
	frame:RegisterEvent("PLAYER_LOGIN")
	frame:SetScript("OnEvent", OnEvent)