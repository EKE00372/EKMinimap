local addon, ns = ...
local C, F, G, L = unpack(ns)

local OTF = ObjectiveTrackerFrame

--=================================================--
-----------------    [[ Block ]]    -----------------
--=================================================--

local function styleQuestBlock()
	if not EKMinimapDB["ObjectiveStyle"] then return end
	
	-- [[ main title / 分類標題 ]] --
	
	local headers = {
		ScenarioObjectiveTracker.Header,	-- 場景和副本
		UIWidgetObjectiveTracker.Header,	-- 本體
		CampaignQuestObjectiveTracker.Header,-- 戰役
		QuestObjectiveTracker.Header,		-- 任務
		AdventureObjectiveTracker.Header,
		AchievementObjectiveTracker.Header,	-- 成就
		MonthlyActivitiesObjectiveTracker.Header,-- 旅行者日誌
		ProfessionsRecipeTracker.Header,	-- 專業
		BonusObjectiveTracker.Header,		-- 區域獎勵任務
		WorldQuestObjectiveTracker.Header,	-- 世界任務
	}
	
	local function reskinHeader(header)
		header.Background:SetAtlas(nil)
		header.Background:Hide()
		
		header.Text:SetFont(G.font, G.obfontSize, G.obfontFlag)
		header.Text:SetTextColor(1, .75, 0)
		header.Text:SetShadowColor(0, 0, 0, 1)
		header.Text:SetShadowOffset(0, 0)
		header.Text:SetWordWrap(false)
		
		header.Text:SetWidth(OTF:GetWidth()-42)
		--header.Text:ClearAllPoints()
		--header.Text:SetPoint("RIGHT", header.MinimizeButton, "LEFT", -30, 0)
		header.Text:SetJustifyH("RIGHT")
	end

	for _, header in pairs(headers) do
		reskinHeader(header)
	end
	
	-- 大標題
	local collapsedTitle = OTF.Header.Text
		collapsedTitle:SetFont(G.font, G.obfontSize, G.obfontFlag)
		collapsedTitle:SetTextColor(1, .75, 0)
		collapsedTitle:SetShadowOffset(0, 0)
		collapsedTitle:SetShadowColor(0, 0, 0, 1)
	
	-- [[ minimize button ]] --
	
	-- [[ skin quest item icon ]] --
	
	--[[local function reskinQuestIcon(button)
		if not button then return end
		if not button.SetNormalTexture then return end

		if not button.styled then
			button:SetSize(24, 24)
			button:SetNormalTexture(0)
			button:SetPushedTexture(0)
			button:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
			local icon = button.icon or button.Icon
			if icon then
				button.bg = F.CreateBG(icon, 3, 3, 0)
				icon:SetTexCoord(.08, .92, .08, .92)
			end

			button.styled = true
		end

		if button.bg then
			button.bg:SetFrameLevel(0)
		end
	end

	local function reskinQuestIcons(_, block)
		reskinQuestIcon(block.itemButton)
		reskinQuestIcon(block.groupFinderButton)
	end

	hooksecurefunc(QuestObjectiveTracke, "SetBlockHeader", reskinQuestIcons)
	hooksecurefunc(WorldQuestObjectiveTracker, "AddObjective", reskinQuestIcons)
	hooksecurefunc(CampaignQuestObjectiveTracker, "AddObjective", reskinQuestIcons)
	hooksecurefunc(BonusObjectiveTracker, "AddObjective", reskinQuestIcons)]]--

	-- [[ 細項與內文 ]] --
	
	--[[local function skinText(self, block, objectiveKey, _, lineType)
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
				line.Dash:SetText(QUEST_DASH)
			end
			
			line.Dash:SetShadowColor(0, 0, 0, 1)
			line.Dash:SetShadowOffset(0, 0)
		end
	end
	
	hooksecurefunc(QuestObjectiveTracker, "AddObjective", skinText)
	hooksecurefunc(AchievementObjectiveTracker, "AddObjective", skinText)
	hooksecurefunc(CampaignQuestObjectiveTracker, "AddObjective", skinText)
	hooksecurefunc(WorldQuestObjectiveTracker, "AddObjective", skinText)
	hooksecurefunc(BonusObjectiveTracker, "AddObjective", skinText)
	hooksecurefunc(ScenarioObjectiveTracker, "AddObjective", skinText)
	hooksecurefunc(ProfessionsRecipeTracker, "AddObjective", skinText)
	hooksecurefunc(UIWidgetObjectiveTracker, "AddObjective", skinText)
	hooksecurefunc(MonthlyActivitiesObjectiveTracker, "AddObjective", skinText)]]--
	
	-- [[ Quick Click: Alt to Share, Ctrl to Abandon / 快速按鍵：alt分享ctrl放棄 ]]--

	hooksecurefunc(QuestObjectiveTracker, "OnBlockHeaderClick", function(self, block, mouseButton)
		local questLogIndex = C_QuestLog.GetLogIndexForQuestID(block.id)
		
		if mouseButton == "RightButton" and IsModifiedClick() then
			if IsControlKeyDown() and C_QuestLog.CanAbandonQuest(block.id) then
				QuestMapQuestOptions_AbandonQuest(block.id)
				
				--[[if QuestLogPopupDetailFrame:IsShown() then
					HideUIPanel(QuestLogPopupDetailFrame)
				end]]--
				
				for i = 1, STATICPOPUP_NUMDIALOGS do
					local dialog = _G["StaticPopup"..i]
					if (dialog.which == "ABANDON_QUEST" or dialog.which == "ABANDON_QUEST_WITH_ITEMS") and dialog:IsVisible() then
						StaticPopup_OnClick(dialog, 1)
						break
					end
				end
			
			elseif IsAltKeyDown() and C_QuestLog.IsPushableQuest(questLogIndex) then
				QuestMapQuestOptions_ShareQuest(block.id)
			end
		end
	end)
end

--====================================================--
-----------------    [[ Collapse ]]    -----------------
--====================================================--

local function mythicCollapse()
	local difficulty = select(3, GetInstanceInfo())
	
	local whitelist = {
	   ["ScenarioObjectiveTracker"] = true,
	   ["UIWidgetObjectiveTracker"] = true,
	}

	if difficulty == 8 then
		local changed = false
		for i, v in pairs(ObjectiveTrackerFrame.MODULES) do 
			if not whitelist[v.friendlyName] then
				v:SetCollapsed(true)
				changed = true
			end
		end
		
		if changed then ObjectiveTracker_Update() end
	end
end

local function doMythicCollapse(_, event)
	if event == "PLAYER_ENTERING_WORLD" then
		C_Timer.After(1, function()
			if ObjectiveTrackerFrame.initialized and not InCombatLockdown() then mythicCollapse() end
		end)
	--elseif event == "CHALLENGE_MODE_COMPLETED" then
	else
		mythicCollapse()
	end
end

local mcol = CreateFrame("FRAME")
	mcol:RegisterEvent("PLAYER_ENTERING_WORLD")
	mcol:RegisterEvent("CHALLENGE_MODE_START")
	mcol:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	--mcol:RegisterEvent("CHALLENGE_MODE_COMPLETED")
	mcol:SetScript("OnEvent", doMythicCollapse)

--================================================--
-----------------    [[ Load ]]    -----------------
--================================================--


local function OnEvent()
	if not IsAddOnLoaded("Blizzard_ObjectiveTracker") then
		LoadAddOn("Blizzard_ObjectiveTracker")
	end
	
	styleQuestBlock()
end

local frame = CreateFrame("FRAME")
	frame:RegisterEvent("PLAYER_LOGIN")
	frame:SetScript("OnEvent", OnEvent)