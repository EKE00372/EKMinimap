local addon, ns = ...
local C, F, G, L = unpack(ns)

--===================================================--
-----------------    [[ Function ]]    ----------------
--===================================================--

local function getHeader(frame)
	return frame and frame.Header
end

local function addOutlineFlag(flags)
	if flags and (flags:find("OUTLINE") or flags:find("THICKOUTLINE")) then
		return flags
	end
	return flags and flags ~= "" and flags..",OUTLINE" or "OUTLINE"
end

local function styleObjectiveTrackerFontObject(fontObject)
	if not fontObject then return end

	local font, size, flags = fontObject:GetFont()
	if font and size then
		fontObject:SetFont(font, size, addOutlineFlag(flags))
	end
	fontObject:SetShadowOffset(0, 0)
end

local function styleObjectiveTrackerFonts()
	-- Only touch ObjectiveTracker font objects.
	styleObjectiveTrackerFontObject(ObjectiveTrackerLineFont)
	styleObjectiveTrackerFontObject(ObjectiveTrackerHeaderFont)

	if ObjectiveTrackerManager and not ObjectiveTrackerManager.__EKMinimapFontHooked then
		hooksecurefunc(ObjectiveTrackerManager, "SetTextSize", styleObjectiveTrackerFonts)
		ObjectiveTrackerManager.__EKMinimapFontHooked = true
	end
end

--================================================--
-----------------    [[ Style ]]    ----------------
--================================================--

local function trackerStyle()
	if not EKMinimapDB["TrackerStyle"] then return end

	local OTF = ObjectiveTrackerFrame
	local textButtonGap = -8
	local headerTextYOffset = 2		-- Header text and line texture offset
	local lineYOffset = 3
	local headers = {
		getHeader(ObjectiveTrackerFrame),
		getHeader(ScenarioObjectiveTracker),
		getHeader(CampaignQuestObjectiveTracker),
		getHeader(UIWidgetObjectiveTracker),
		getHeader(QuestObjectiveTracker),
		getHeader(AchievementObjectiveTracker),
		getHeader(BonusObjectiveTracker),
		getHeader(MonthlyActivitiesObjectiveTracker),
		getHeader(ProfessionsRecipeTracker),
		getHeader(WorldQuestObjectiveTracker),
		getHeader(AdventureObjectiveTracker),
		getHeader(InitiativeTasksObjectiveTracker),
	}

	local function reskinHeader(header)
		if not header then return end

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
			local headerTex = header.__EKMinimapHeaderTex
			if not headerTex then
				headerTex = header:CreateTexture(nil, "BACKGROUND")
				headerTex:SetTexture(G.Tex)
				headerTex:SetVertexColor(G.Ccolors.r, G.Ccolors.g, G.Ccolors.b, .8)
				headerTex.bg = F.CreateBG(headerTex, 2, 2, .5)
				header.__EKMinimapHeaderTex = headerTex
			end

			headerTex:SetSize((OTF and OTF:GetWidth() or 250) / 2, 5)
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
		local minimize = header and header.MinimizeButton
		if not minimize then return end

		if not minimize.__EKMinimapBG then
			minimize.__EKMinimapBG = F.CreateBG(minimize, 2, 2, .5)
		end

		if header ~= getHeader(ObjectiveTrackerFrame) then return end

		if not minimize.__EKMinimapResized then
			-- Match main and child header button size.
			minimize:SetSize(16, 16)
			minimize.__EKMinimapResized = true
		end

		if header.Text then
			local textOffset = textButtonGap
			header.Text:ClearAllPoints()
			header.Text:SetPoint("RIGHT", minimize, "LEFT", textOffset, headerTextYOffset)
			header.Text:SetJustifyH("RIGHT")
		end

		local function updateMainMinimizeButton()
			local parent = header:GetParent()
			local collapsed = parent and type(parent.IsCollapsed) == "function" and parent:IsCollapsed()
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
			if minimize.__EKMinimapBG then
				minimize.__EKMinimapBG:ClearAllPoints()
				minimize.__EKMinimapBG:SetPoint("TOPLEFT", minimize, -2 + visualOffsetX, 2)
				minimize.__EKMinimapBG:SetPoint("BOTTOMRIGHT", minimize, 2 + visualOffsetX, -2)
			end
		end

		updateMainMinimizeButton()

		if not header.__EKMinimapMinimizeHooked and type(header.SetCollapsed) == "function" then
			hooksecurefunc(header, "SetCollapsed", updateMainMinimizeButton)
			header.__EKMinimapMinimizeHooked = true
		end
	end

	for _, header in pairs(headers) do
		reskinMinimizeButton(header)
	end

	styleObjectiveTrackerFonts()
end

--===================================================--
-----------------    [[ Collapse ]]    ----------------
--===================================================--

local isAutoCollapsed = false
local function updateCollapse()
	if not EKMinimapDB["AutoCollapse"] then return end

	local _, _, difficulty = GetInstanceInfo()
	-- Collapse child tracker modules only
	local trackers = {
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

	if difficulty == 8 then
		for _, tracker in pairs(trackers) do
			if tracker and type(tracker.SetCollapsed) == "function" then
				tracker:SetCollapsed(true)
			end
		end
		isAutoCollapsed = true
	else
		for _, tracker in pairs(trackers) do
			if tracker and type(tracker.SetCollapsed) == "function" then
				tracker:SetCollapsed(false)
			end
		end
		isAutoCollapsed = false
	end
end

--================================================--
-----------------    [[ Load ]]    -----------------
--================================================--

local function OnEvent(self, event)
	if not C_AddOns.IsAddOnLoaded("Blizzard_ObjectiveTracker") then
		C_AddOns.LoadAddOn("Blizzard_ObjectiveTracker")
	end

	if event == "PLAYER_LOGIN" then
		trackerStyle()
	else
		C_Timer.After(2, function()
			if not InCombatLockdown() then
				updateCollapse()
			end
		end)
	end
end

local frame = CreateFrame("FRAME")
	frame:RegisterEvent("PLAYER_LOGIN")
	frame:RegisterEvent("PLAYER_ENTERING_WORLD")
	frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	frame:RegisterEvent("CHALLENGE_MODE_START")
	frame:SetScript("OnEvent", OnEvent)