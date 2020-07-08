local addon, ns = ...
local C, F, G, L = unpack(ns)

local QWF, QTF = QuestWatchFrame, QuestTimerFrame

--================================================--
-----------------    [[ Core ]]    -----------------
--================================================--

local ObjectiveFrameHolder = CreateFrame("Frame", "QWFHoler", UIParent)
	ObjectiveFrameHolder:SetSize(160, G.QfontSize + 4)

local function updateQWFPos()
	ObjectiveFrameHolder:ClearAllPoints()
	ObjectiveFrameHolder:SetPoint(EKMinimapDB["QuestWatchAnchor"], UIParent, EKMinimapDB["QuestWatchAnchor"], EKMinimapDB["QuestWatchX"], EKMinimapDB["QuestWatchY"])
	ObjectiveFrameHolder:SetMovable(true)
	ObjectiveFrameHolder:SetClampedToScreen(true)
end

-- [[ Load Blizzard ]] --

local function setQWF()
	if not EKMinimapDB["QuestWatchStyle"] then return end
	updateQWFPos()
	-- create holder
	--[[local ObjectiveFrameHolder = CreateFrame("Frame", "QWFHoler", UIParent)
	ObjectiveFrameHolder:SetSize(160, G.QfontSize + 4)
	ObjectiveFrameHolder:ClearAllPoints()
	ObjectiveFrameHolder:SetPoint(EKMinimapDB["QuestWatchAnchor"], UIParent, EKMinimapDB["QuestWatchAnchor"], EKMinimapDB["QuestWatchX"], EKMinimapDB["QuestWatchY"])
	ObjectiveFrameHolder:SetMovable(true)]]--
	
	QWF:SetClampedToScreen(true)
	QWF:SetMovable(true)
	QWF:SetUserPlaced(true)
	QWF:SetParent(ObjectiveFrameHolder)
	QWF:ClearAllPoints()
	QWF:SetPoint("TOPLEFT", ObjectiveFrameHolder)
	
	hooksecurefunc(QWF, "SetPoint", function(self, _, parent)
		if parent == "MinimapCluster" or parent == _G.MinimapCluster then
			self:SetParent(ObjectiveFrameHolder)
			self:ClearAllPoints()
			self:SetPoint("TOPLEFT", ObjectiveFrameHolder)
		end
	end)
	
	hooksecurefunc(QTF, "SetPoint", function(self, _, parent)
		if parent ~= ObjectiveFrameHolder then
			self:SetParent(ObjectiveFrameHolder)
			self:ClearAllPoints()
			self:SetPoint("TOPRIGHT", ObjectiveFrameHolder , "TOPLEFT", -10 , 0)
		end
	end)

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
	if not EKMinimapDB["QuestWatchStyle"] then return end
	if not EKMinimapDB["QuestWatchStar"] then return end
	-- Change font of watched quests
	hooksecurefunc("QuestWatch_Update", function()
		for i = 1, 30 do
			local line = _G["QuestWatchLine"..i]
			
			line:SetFont(G.font, G.QfontSize-2, G.QfontFlag)
			line:SetHeight(G.QfontSize+2)
			line:SetShadowOffset(0, 0)
			local text = line:GetText()
			if text then
				line:SetText(gsub(text, "- ", "★ "))
			end
			--print(line:GetText())
		end
	end)
	--hooksecurefunc("QuestWatch_Update", function()
end

--============================================================--
-----------------    [[ ModernQuestWatch ]]    -----------------
--============================================================--

local function ModernQuestWatch()
	if not EKMinimapDB["QuestWatchStyle"] then return end
	if not EKMinimapDB["QuestWatchClick"] then return end
	
	-- ModernQuestWatch, Ketho
	local function onMouseUp(self)
		if IsShiftKeyDown() then -- untrack quest
			local questID = GetQuestIDFromLogIndex(self.questIndex)
			for index, value in ipairs(QUEST_WATCH_LIST) do
				if value.id == questID then
					tremove(QUEST_WATCH_LIST, index)
				end
			end
			RemoveQuestWatch(self.questIndex)
			QuestWatch_Update()
		else -- open to quest log
			if QuestLogEx then -- https://www.wowinterface.com/downloads/info24980-QuestLogEx.html
				ShowUIPanel(QuestLogExFrame)
				QuestLogEx:QuestLog_SetSelection(self.questIndex)
				QuestLogEx:Maximize()
			elseif ClassicQuestLog then -- https://www.wowinterface.com/downloads/info24937-ClassicQuestLogforClassic.html
				ShowUIPanel(ClassicQuestLog)
				QuestLog_SetSelection(self.questIndex)
			elseif QuestGuru then -- https://www.curseforge.com/wow/addons/questguru_classic
				ShowUIPanel(QuestGuru)
				QuestLog_SetSelection(self.questIndex)
			else
				ShowUIPanel(QuestLogFrame)
				QuestLog_SetSelection(self.questIndex)
				local valueStep = QuestLogListScrollFrame.ScrollBar:GetValueStep()
				QuestLogListScrollFrame.ScrollBar:SetValue(self.questIndex*valueStep/2)
			end
		end
		QuestLog_Update()
	end

	local function onEnter(self)
		if self.completed then
			-- use normal colors instead as highlight
			self.headerText:SetTextColor(.75, .61, 0)
			for _, text in ipairs(self.objectiveTexts) do
				text:SetTextColor(.8, .8, .8)
			end
		else
			self.headerText:SetTextColor(1, .8, 0)
			for _, text in ipairs(self.objectiveTexts) do
				text:SetTextColor(1, 1, 1)
			end
		end
	end

	local ClickFrames = {}
	local function SetClickFrame(watchIndex, questIndex, headerText, objectiveTexts, completed)
		if not ClickFrames[watchIndex] then
			ClickFrames[watchIndex] = CreateFrame("Frame")
			ClickFrames[watchIndex]:SetScript("OnMouseUp", onMouseUp)
			ClickFrames[watchIndex]:SetScript("OnEnter", onEnter)
			ClickFrames[watchIndex]:SetScript("OnLeave", QuestWatch_Update)
		end

		local f = ClickFrames[watchIndex]
		f:SetAllPoints(headerText)
		f.watchIndex = watchIndex
		f.questIndex = questIndex
		f.headerText = headerText
		f.objectiveTexts = objectiveTexts
		f.completed = completed
	end

	hooksecurefunc("QuestWatch_Update", function()
		local watchTextIndex = 1
		local numWatches = GetNumQuestWatches()
		for i = 1, numWatches do
			local questIndex = GetQuestIndexForWatch(i)
			if questIndex then
				local numObjectives = GetNumQuestLeaderBoards(questIndex)
				if numObjectives > 0 then
					local headerText = _G["QuestWatchLine"..watchTextIndex]
					if watchTextIndex > 1 then
						headerText:SetPoint("TOPLEFT", "QuestWatchLine"..(watchTextIndex - 1), "BOTTOMLEFT", 0, -10)
					end
					watchTextIndex = watchTextIndex + 1
					local objectivesGroup = {}
					local objectivesCompleted = 0
					for j = 1, numObjectives do
						local finished = select(3, GetQuestLogLeaderBoard(j, questIndex))
						if finished then
							objectivesCompleted = objectivesCompleted + 1
						end
						_G["QuestWatchLine"..watchTextIndex]:SetPoint("TOPLEFT", "QuestWatchLine"..(watchTextIndex - 1), "BOTTOMLEFT", 0, -5)
						tinsert(objectivesGroup, _G["QuestWatchLine"..watchTextIndex])
						watchTextIndex = watchTextIndex + 1
					end
					SetClickFrame(i, questIndex, headerText, objectivesGroup, objectivesCompleted == numObjectives)
				end
			end
		end
		-- hide/show frames so it doesnt eat clicks, since we cant parent to a FontString
		for _, frame in pairs(ClickFrames) do
			frame[GetQuestIndexForWatch(frame.watchIndex) and "Show" or "Hide"](frame)
		end

		--bu:SetShown(numWatches > 0)
		--if bu.collapse then QuestWatchFrame:Hide() end
	end)

	local function autoQuestWatch(_, questIndex)
		-- tracking otherwise untrackable quests (without any objectives) would still count against the watch limit
		-- calling AddQuestWatch() while on the max watch limit silently fails
		if GetCVarBool("autoQuestWatch") and GetNumQuestLeaderBoards(questIndex) ~= 0 and GetNumQuestWatches() < MAX_WATCHABLE_QUESTS then
			AutoQuestWatch_Insert(questIndex, QUEST_WATCH_NO_EXPIRE)
		end
	end
	
	local frame = CreateFrame("FRAME")
	frame:RegisterEvent("QUEST_ACCEPTED")
	frame:SetScript("OnEvent", autoQuestWatch)
end

-- Reset / 重置
F.ResetO = function()
	updateQWFPos()
	--setQWF()
end

local function OnEvent()
	--if not IsAddOnLoaded("Blizzard_QuestWatchTracker") then
	--	LoadAddOn("Blizzard_QuestWatchTracker")
	--end
	--setParent()
	setQWF()
	styleQuestBlock()
	ModernQuestWatch()
end

local frame = CreateFrame("FRAME")
	frame:RegisterEvent("PLAYER_LOGIN")
	frame:SetScript("OnEvent", OnEvent)