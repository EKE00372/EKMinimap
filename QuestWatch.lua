local addon, ns = ...
local C, F, G = unpack(ns)
if not C.QuestWatchStyle then return end

local QWF, QTF, gsub, unpack = QuestWatchFrame, QuestTimerFrame, string.gsub, unpack
local GetNumQuestWatches = GetNumQuestWatches
local ClickFrames = {}
local frame

--====================================================--
-----------------    [[ Position ]]    -----------------
--====================================================--

local QWFHolder = CreateFrame("Frame", "QWFHoler", UIParent)
	QWFHolder:SetSize(160, G.fontSize + 4)
	QWFHolder:ClearAllPoints()
	QWFHolder:SetPoint(unpack(C.QuestWatchPoint))
	QWFHolder:SetMovable(true)
	QWFHolder:SetUserPlaced(true)
	QWFHolder:SetClampedToScreen(true)
	
	QWF:SetParent(QWFHolder)
	QWF:ClearAllPoints()
	QWF:SetPoint("TOPLEFT", QWFHolder)
	QWF:SetMovable(true)
	QWF:SetUserPlaced(true)
	QWF:SetClampedToScreen(true)

hooksecurefunc(QWF, "SetPoint", function(self, _, parent)
	if parent == "MinimapCluster" or parent == _G.MinimapCluster then
		self:SetParent(QWFHolder)
		self:ClearAllPoints()
		self:SetPoint("TOPLEFT", QWFHolder)
	end
end)

hooksecurefunc(QTF, "SetPoint", function(self, _, parent)
	if parent ~= QWFHolder then
		self:SetParent(QWFHolder)
		self:ClearAllPoints()
		self:SetPoint("TOPRIGHT", QWFHolder , "TOPLEFT", -10 , 0)
	end
end)

--=================================================--
-----------------    [[ Style ]]    -----------------
--=================================================--

-- add title line
local HeaderBar = CreateFrame("StatusBar", nil, QWFHolder)
	HeaderBar:SetSize(140, 3)
	HeaderBar:SetPoint("TOPRIGHT", QWFHolder, 0, -2)
	HeaderBar:SetStatusBarTexture(G.Tex)
	HeaderBar:SetStatusBarColor(G.Ccolors.r, G.Ccolors.g, G.Ccolors.b)
	HeaderBar.bg = F.CreateBG(HeaderBar, 3, 3, 1)
	HeaderBar:SetShown(GetNumQuestWatches() > 0)

	-- add title text
	HeaderBar.Text = F.CreateFS(HeaderBar, CURRENT_QUESTS, "RIGHT", "RIGHT", 2, G.fontSize+2)
	HeaderBar.Text:SetFont(G.font, G.fontSize, G.fontFlag)
	HeaderBar.Text:SetTextColor(G.Ccolors.r, G.Ccolors.g, G.Ccolors.b)

local HeaderButton = CreateFrame("Button", nil, HeaderBar)
	HeaderButton:SetSize(20, 20)
	HeaderButton:SetPoint("LEFT", HeaderBar, "RIGHT", 8, 8)
	HeaderButton.bg = F.CreateBG(HeaderButton, 3, 3, .5)
	HeaderButton.collapse = false
	HeaderButton.text = F.CreateFS(HeaderButton, "-", "CENTER", "CENTER", 0, 0)
	HeaderButton:SetNormalTexture("")
	HeaderButton:SetHighlightTexture("")
	HeaderButton:SetShown(GetNumQuestWatches() > 0)

	HeaderButton:SetScript("OnEnter", function(self)
		HeaderButton.bg:SetBackdropBorderColor(G.Ccolors.r, G.Ccolors.g, G.Ccolors.b, 1)
	end)

	HeaderButton:SetScript("OnLeave", function(self)
		HeaderButton.bg:SetBackdropBorderColor(0, 0, 0, 1)
	end)

	HeaderButton:SetScript("OnClick", function(self)
		self.collapse = not self.collapse
		if self.collapse then
			self.text:SetText("+")
			QWF:Hide()
		else
			self.text:SetText("-")
			if GetNumQuestWatches() > 0 then
				QWF:Show()
			end
		end
	end)
	
	-- block text outline
	for i = 1, 30 do
		local line = _G["QuestWatchLine"..i]
		
		line:SetFont(G.font, G.fontSize, G.fontFlag)
		line:SetHeight(G.fontSize)
		line:SetShadowOffset(0, 0)
	end
	
	hooksecurefunc("QuestWatch_Update", function()
		-- make sure header and collapse button show only when tracking quest
		HeaderBar:SetShown(GetNumQuestWatches() > 0)
		HeaderButton:SetShown(GetNumQuestWatches() > 0)
		-- if quest update when collapse then keep collapse it
		if HeaderButton.collapse then QuestWatchFrame:Hide() end
		
		if C.QuestWatchStar then
			for i = 1, 30 do
				local line = _G["QuestWatchLine"..i]
				local text = line:GetText()
				if text then
					line:SetText(gsub(text, "- ", "★ "))
				end
			end
		end
	end)

--================================================--
-----------------    [[ Drag ]]    -----------------
--================================================--

local function QWF_Tooltip(self)
	GameTooltip:SetOwner(self, "ANCHOR_TOP")
	GameTooltip:AddDoubleLine(DRAG_MODEL, "Alt + |TInterface\\TUTORIALFRAME\\UI-TUTORIAL-FRAME:13:11:0:-1:512:512:12:66:333:411|t", 0, 1, 0.5, 1, 1, 1)
	GameTooltip:Show()
end

local QWFMove = CreateFrame("FRAME", "QWFdrag", QWFHolder)
	-- Create frame for click
	QWFMove:SetSize(160, G.fontSize + 2)
	QWFMove:SetPoint("TOP", QWFHolder, 0, G.fontSize)
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

--============================================================--
-----------------    [[ ModernQuestWatch ]]    -----------------
--============================================================--
	
local function onMouseUp(self)
	if not C.QuestWatchClick then return end
	
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

	for i = 1, GetNumQuestWatches() do
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
end)

local function autoQuestWatch(self, _, questIndex)
	-- tracking otherwise untrackable quests (without any objectives) would still count against the watch limit
	-- calling AddQuestWatch() while on the max watch limit silently fails
	if GetCVarBool("autoQuestWatch") and GetNumQuestLeaderBoards(questIndex) ~= 0 and GetNumQuestWatches() < MAX_WATCHABLE_QUESTS then
		AutoQuestWatch_Insert(questIndex, QUEST_WATCH_NO_EXPIRE)
	end
end

local frame = CreateFrame("FRAME")
frame:RegisterEvent("QUEST_ACCEPTED")
frame:SetScript("OnEvent", autoQuestWatch)

--=================================================--
-----------------    [[ Reset ]]    -----------------
--=================================================--

-- Reset / 重置
local function ResetQWF()
	QWFHolder:ClearAllPoints()
	QWFHolder:SetPoint(unpack(C.QuestWatchPoint))
	QWF:SetParent(QWFHolder)
	QWF:ClearAllPoints()
	QWF:SetPoint("TOPLEFT", QWFHolder)
end

SlashCmdList["RESETQWF"] = function()
	ResetQWF()
end
SLASH_RESETQWF1 = "/rq"
SLASH_RESETQWF2 = "/resetqwf"