local addon, ns = ...
local C, F, G, L = unpack(ns)

local OTF = ObjectiveTrackerFrame

--=================================================--
-----------------    [[ Header ]]    ----------------
--=================================================--

local function headerStyle()
    if not EKMinimapDB["TrackerStyle"] then return end

    local headers = {
		ObjectiveTrackerFrame.Header,       -- 大標題
		ScenarioObjectiveTracker.Header,	-- 場景
        CampaignQuestObjectiveTracker.Header,-- 戰役
		UIWidgetObjectiveTracker.Header,
		QuestObjectiveTracker.Header,		-- 任務
		AchievementObjectiveTracker.Header,	-- 成就
		BonusObjectiveTracker.Header,		-- 區域獎勵任務
        MonthlyActivitiesObjectiveTracker.Header,-- 旅行者日誌
		ProfessionsRecipeTracker.Header,	-- 專業
		WorldQuestObjectiveTracker.Header,	-- 世界任務
        AdventureObjectiveTracker.Header,
	}
	
	local function reskinHeader(header)
        if not header then return end

        header.Background:SetAtlas(nil)
        header.Background:Hide()

        -- Header text
        header.Text:SetFont(G.font, G.obfontSize, G.obfontFlag)
		header.Text:SetTextColor(1, .75, 0)
		--header.Text:SetShadowColor(0, 0, 0, 1)
		--header.Text:SetShadowOffset(0, 0)
		header.Text:SetWordWrap(false)
		header.Text:ClearAllPoints()
		header.Text:SetPoint("RIGHT", header.MinimizeButton, "LEFT", -30, 0)
		header.Text:SetJustifyH("RIGHT")
        
        -- Header texture
        local headerTex = header:CreateTexture(nil, "BACKGROUND")
            headerTex:SetSize(OTF:GetWidth()/2, 5)
            headerTex:SetTexture(G.Tex)
            headerTex:SetVertexColor(G.Ccolors.r, G.Ccolors.g, G.Ccolors.b, .8)
            headerTex.bg = F.CreateBG(headerTex, 2, 2, .5)
            
            headerTex:ClearAllPoints()
            if header == ObjectiveTrackerFrame.Header then
                headerTex:SetPoint("TOPRIGHT", header, "BOTTOMRIGHT", -40, 10)
            else
                headerTex:SetPoint("TOPRIGHT", header, "BOTTOMRIGHT", -40, 6)
            end
	end

	for _, header in pairs(headers) do
		reskinHeader(header)
	end

    for _, header in pairs(headers) do
        local minimize = header.MinimizeButton
        if minimize and header ~= ObjectiveTrackerFrame.Header then
            F.CreateBG(minimize, 2, 2, .5)
        end
    end
end

--===================================================--
-----------------    [[ Collapse ]]    ----------------
--===================================================--

local isAutoCollapsed = false
local function updateCollapse()
    if not EKMinimapDB["AutoCollapse"] then return end

    local _, _, difficulty = GetInstanceInfo()
    local trackers = {
        CampaignQuestObjectiveTracker,
        QuestObjectiveTracker,
        AchievementObjectiveTracker,
        BonusObjectiveTracker,
        MonthlyActivitiesObjectiveTracker,
        ProfessionsRecipeTracker,
        WorldQuestObjectiveTracker,
        AdventureObjectiveTracker
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
        headerStyle()
    else
        C_Timer.After(2, function()
            if not InCombatLockdown() then updateCollapse() end
        end)
    end
end

local frame = CreateFrame("FRAME")
	frame:RegisterEvent("PLAYER_LOGIN")
	frame:RegisterEvent("PLAYER_ENTERING_WORLD")
    frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	frame:RegisterEvent("CHALLENGE_MODE_START")
	frame:SetScript("OnEvent", OnEvent)

    