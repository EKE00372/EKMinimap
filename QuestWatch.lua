local addon, ns = ...
local C, F, G, L = unpack(ns)

local QWF, QTF, gsub = QuestWatchFrame, QuestTimerFrame, string.gsub
local GetNumQuestWatches = GetNumQuestWatches
local ClickFrames = {}
local ObjectiveFrameHolder
local trackerEnabled = false

--================================================--
-----------------    [[ Core ]]    -----------------
--================================================--

local function updateQWFPos()
	ObjectiveFrameHolder:ClearAllPoints()
	ObjectiveFrameHolder:SetPoint(F.GetEKMOption("QuestWatchAnchor"), UIParent, F.GetEKMOption("QuestWatchAnchor"), F.GetEKMOption("QuestWatchX"), F.GetEKMOption("QuestWatchY"))
	ObjectiveFrameHolder:SetMovable(true)
	ObjectiveFrameHolder:SetClampedToScreen(true)

	QWF:SetParent(ObjectiveFrameHolder)
	QWF:ClearAllPoints()
	QWF:SetPoint("TOPLEFT", ObjectiveFrameHolder)
end

local function setQWF()
	ObjectiveFrameHolder = CreateFrame("Frame", "QWFHoler", UIParent)
	ObjectiveFrameHolder:SetSize(160, G.fontSize + 4)
	-- 原生 OnShow 會重新加入 managed container，先解除管理再接管定位。
	for _, target in ipairs({ QWF, QTF }) do
		target.ignoreFramePositionManager = true
		target.layoutParent:RemoveManagedFrame(target)
	end

	local numWatches = GetNumQuestWatches()

	updateQWFPos()
	QWF:SetClampedToScreen(true)
	QWF:SetMovable(true)
	QWF:SetUserPlaced(true)

	QTF:SetParent(ObjectiveFrameHolder)
	QTF:ClearAllPoints()
	QTF:SetPoint("TOPRIGHT", ObjectiveFrameHolder, "TOPLEFT", -10, 0)

	-- add title line
	local HeaderBar = CreateFrame("StatusBar", nil, ObjectiveFrameHolder)
	HeaderBar:SetSize(140, 3)
	HeaderBar:SetPoint("TOPRIGHT", ObjectiveFrameHolder, 0, -2)
	HeaderBar:SetStatusBarTexture(G.Tex)
	HeaderBar:SetStatusBarColor(G.Ccolors.r, G.Ccolors.g, G.Ccolors.b)
	HeaderBar.bg = F.CreateBG(HeaderBar, 3, 3, 1)
	HeaderBar:SetShown(numWatches > 0)

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
	HeaderButton:SetShown(numWatches > 0)

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

		if F.GetEKMOption("QuestWatchStar") then
			for i = 1, 30 do
				local line = _G["QuestWatchLine"..i]
				local text = line:GetText()
				if text then
					line:SetText(gsub(text, "- ", "★ "))
				end
			end
		end
	end)

	local function QWF_Tooltip(self)
		GameTooltip:SetOwner(self, "ANCHOR_TOP")
		GameTooltip:AddDoubleLine(DRAG_MODEL, "Alt + |TInterface\\TUTORIALFRAME\\UI-TUTORIAL-FRAME:13:11:0:-1:512:512:12:66:333:411|t", 0, 1, 0.5, 1, 1, 1)
		GameTooltip:Show()
	end

	local QWFMove = CreateFrame("FRAME", "QWFdrag", ObjectiveFrameHolder)
		-- Create frame for click
		QWFMove:SetSize(160, G.fontSize + 2)
		QWFMove:SetPoint("TOP", ObjectiveFrameHolder, 0, G.fontSize)
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

--============================================================--
-----------------    [[ ModernQuestWatch ]]    -----------------
--============================================================--

local function ModernQuestWatch()
	-- ModernQuestWatch, Ketho
	local function onMouseUp(self)
		if not F.GetEKMOption("QuestWatchClick") then return end

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
			if F.CombatError() then return end
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
			ClickFrames[watchIndex] = CreateFrame("Frame", nil, QWF)
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
		-- 以任務索引回收點擊區；父框體同時負責收合時的顯隱。
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
end

-- Reset / 重置
F.ResetO = function()
	if not trackerEnabled then return end
	updateQWFPos()
end

local function OnEvent(self)
	self:UnregisterEvent("PLAYER_LOGIN")
	-- 所有一般插件載入後才判斷 Questie，停用時仍保留設定呼叫契約。
	if not F.GetEKMOption("QuestWatchStyle") or C_AddOns.IsAddOnLoaded("Questie") then return end
	trackerEnabled = true
	setQWF()
	ModernQuestWatch()
	QuestWatch_Update()
end

local frame = CreateFrame("FRAME")
	frame:RegisterEvent("PLAYER_LOGIN")
	frame:SetScript("OnEvent", OnEvent)
