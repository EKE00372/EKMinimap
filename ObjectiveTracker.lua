local addon, ns = ...
local C, F, G, L = unpack(ns)

--===================================================--
-----------------    [[ Function ]]    ----------------
--===================================================--

local function addOutlineFlag(flags)
	if flags and flags:find("OUTLINE", 1, true) then
		return flags
	end
	return flags and flags ~= "" and flags..",OUTLINE" or "OUTLINE"
end

local function styleObjectiveTrackerFontObject(fontObject)
	local font, size, flags = fontObject:GetFont()
	fontObject:SetFont(font, size, addOutlineFlag(flags))
	fontObject:SetShadowOffset(0, 0)
end

local function styleObjectiveTrackerFonts()
	-- Only touch ObjectiveTracker font objects.
	styleObjectiveTrackerFontObject(ObjectiveTrackerLineFont)
	styleObjectiveTrackerFontObject(ObjectiveTrackerHeaderFont)
end

--================================================--
-----------------    [[ Style ]]    ----------------
--================================================--

local function trackerStyle()
	if not F.GetEKMOption("TrackerStyle") then return end

	local OTF = ObjectiveTrackerFrame
	local textButtonGap = -8
	local headerTextYOffset = 2		-- Header text and line texture offset
	local lineYOffset = 3
	local headers = {
		ObjectiveTrackerFrame.Header,
		ScenarioObjectiveTracker.Header,
		CampaignQuestObjectiveTracker.Header,
		UIWidgetObjectiveTracker.Header,
		QuestObjectiveTracker.Header,
		AchievementObjectiveTracker.Header,
		BonusObjectiveTracker.Header,
		MonthlyActivitiesObjectiveTracker.Header,
		ProfessionsRecipeTracker.Header,
		WorldQuestObjectiveTracker.Header,
		AdventureObjectiveTracker.Header,
		InitiativeTasksObjectiveTracker.Header,
	}

	local function reskinHeader(header)
		if header.Background then
			header.Background:SetAtlas(nil)
			header.Background:Hide()
		end

		if header.Text then
			header.Text:SetFont(G.font, G.obfontSize, addOutlineFlag(G.obfontFlag))
			header.Text:SetTextColor(1, .75, 0)
			header.Text:SetWordWrap(false)
			header.Text:SetShadowOffset(0, 0)
			header.Text:ClearAllPoints()

			if header.MinimizeButton then
				header.Text:SetPoint("RIGHT", header.MinimizeButton, "LEFT", textButtonGap, headerTextYOffset)
			else
				header.Text:SetPoint("RIGHT", header, "RIGHT", -40, headerTextYOffset)
			end

			header.Text:SetJustifyH("RIGHT")
		end

		if not C_AddOns.IsAddOnLoaded("AuroraClassic") then
			local headerTex = header:CreateTexture(nil, "BACKGROUND")
			headerTex:SetTexture(G.Tex)
			headerTex:SetVertexColor(G.Ccolors.r, G.Ccolors.g, G.Ccolors.b, .8)
			F.CreateBG(headerTex, 2, 2, .5)

			headerTex:SetSize(OTF:GetWidth() / 2, 5)
			headerTex:ClearAllPoints()
			if header.Text then
				headerTex:SetPoint("TOPRIGHT", header.Text, "BOTTOMRIGHT", 0, lineYOffset)
			else
				headerTex:SetPoint("TOPRIGHT", header, "BOTTOMRIGHT", -24, lineYOffset)
			end
		end
	end

	for _, header in pairs(headers) do
		reskinHeader(header)
	end

	local function reskinMinimizeButton(header)
		local minimize = header.MinimizeButton
		if not minimize then return end
		local bg = F.CreateBG(minimize, 2, 2, .5)
		if header ~= OTF.Header then return end
		-- Match main and child header button size.
		minimize:SetSize(16, 16)

		local function updateMainMinimizeButton()
			local collapsed = OTF:IsCollapsed()
			local normalTexture = minimize:GetNormalTexture()
			local pushedTexture = minimize:GetPushedTexture()
			local highlightTexture = minimize:GetHighlightTexture()
			local visualOffsetX = 2 -- Align main and child +/- visuals.

			if normalTexture then
				normalTexture:SetAtlas(collapsed and "ui-questtrackerbutton-secondary-expand" or "ui-questtrackerbutton-secondary-collapse", true)
				normalTexture:ClearAllPoints()
				normalTexture:SetPoint("RIGHT", minimize, "RIGHT", visualOffsetX, 0)
			end
			if pushedTexture then
				pushedTexture:SetAtlas(collapsed and "ui-questtrackerbutton-secondary-expand-pressed" or "ui-questtrackerbutton-secondary-collapse-pressed", true)
				pushedTexture:ClearAllPoints()
				pushedTexture:SetPoint("RIGHT", minimize, "RIGHT", visualOffsetX, 0)
			end
			if highlightTexture then
				highlightTexture:SetAlpha(0)
			end
			bg:ClearAllPoints()
			bg:SetPoint("TOPLEFT", minimize, -2 + visualOffsetX, 2)
			bg:SetPoint("BOTTOMRIGHT", minimize, 2 + visualOffsetX, -2)
		end

		updateMainMinimizeButton()
		hooksecurefunc(header, "SetCollapsed", updateMainMinimizeButton)
	end

	for _, header in pairs(headers) do
		reskinMinimizeButton(header)
	end

	styleObjectiveTrackerFonts()
	hooksecurefunc(ObjectiveTrackerManager, "SetTextSize", styleObjectiveTrackerFonts)
end

--===================================================--
-----------------    [[ Collapse ]]    ----------------
--===================================================--

-- 初始化與狀態暫存
local isAutoCollapsed = false
local mouseDisabledFrames = {}
local trackerAlphas = {}
local trackers

-- 滑鼠互動狀態的紀錄與開關
local function setFrameMouseDisabledRecursive(frame)
	if not mouseDisabledFrames[frame] then
		mouseDisabledFrames[frame] = { frame:IsMouseClickEnabled(), frame:IsMouseMotionEnabled() }
	end
	frame:EnableMouse(false)

	local children = { frame:GetChildren() }	-- 遞迴處理
	for _, child in ipairs(children) do
		setFrameMouseDisabledRecursive(child)
	end
end

-- 套用到各個子追蹤分類並執行：進入 mythic+ 隱藏框架並關閉互動，離開後還原
local function updateCollapse()
	local _, _, difficulty = GetInstanceInfo()
	if difficulty ~= 8 then
		if not isAutoCollapsed then return end
		for tracker, alpha in pairs(trackerAlphas) do
			tracker:SetAlpha(alpha)
			trackerAlphas[tracker] = nil
		end
		-- 還原滑鼠互動狀態：直接處理已記錄的 frame
		for frame, state in pairs(mouseDisabledFrames) do
			frame:SetMouseClickEnabled(state[1])
			frame:SetMouseMotionEnabled(state[2])
			mouseDisabledFrames[frame] = nil
		end
		isAutoCollapsed = false
		return
	end

	for _, tracker in ipairs(trackers) do
		if trackerAlphas[tracker] == nil then
			trackerAlphas[tracker] = tracker:GetAlpha()
		end
		tracker:SetAlpha(0)	-- 調整透明度而非直接隱藏
		setFrameMouseDisabledRecursive(tracker)
	end
	isAutoCollapsed = true
end

--================================================--
-----------------    [[ Load ]]    -----------------
--================================================--

local frame = CreateFrame("FRAME")
local collapseTimer

local function applyPendingCollapse()
	collapseTimer = nil
	if InCombatLockdown() then
		-- 戰鬥中延遲載入
		frame:RegisterEvent("PLAYER_REGEN_ENABLED")
		return
	end
	frame:UnregisterEvent("PLAYER_REGEN_ENABLED")
	updateCollapse()
end

local function OnEvent(self, event)
	if event == "PLAYER_LOGIN" then
		trackerStyle()
		self:UnregisterEvent("PLAYER_LOGIN")

		-- 功能開關只在重載時變更，停用時不建立隱藏流程。
		if not F.GetEKMOption("AutoCollapse") then
			self:SetScript("OnEvent", nil)
			return
		end

		-- 避免新追蹤的項目隱藏時可被點擊
		trackers = {
			CampaignQuestObjectiveTracker,
			QuestObjectiveTracker,
			AchievementObjectiveTracker,
			BonusObjectiveTracker,
			MonthlyActivitiesObjectiveTracker,
			ProfessionsRecipeTracker,
			WorldQuestObjectiveTracker,
			AdventureObjectiveTracker,
			InitiativeTasksObjectiveTracker,
		}
		for _, tracker in ipairs(trackers) do
			hooksecurefunc(tracker, "EndLayout", function(self)
				if isAutoCollapsed then
					setFrameMouseDisabledRecursive(self)
				end
			end)
		end

		self:RegisterEvent("PLAYER_ENTERING_WORLD")
		self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
		self:RegisterEvent("CHALLENGE_MODE_START")
		return
	end

	-- 合併推遲更新
	if collapseTimer then collapseTimer:Cancel() end
	collapseTimer = C_Timer.NewTimer(2, applyPendingCollapse)
end

frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", OnEvent)
