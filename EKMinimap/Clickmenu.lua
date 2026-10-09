local addon, ns = ...
local C, F, G, L = unpack(ns)
local Minimap, MinimapCluster = Minimap, MinimapCluster

local GarrisonType = Enum.GarrisonType
local GARRISON_TYPE_DRAENOR = GarrisonType.Type_6_0_Garrison
local GARRISON_TYPE_LEGION = GarrisonType.Type_7_0_Garrison
local GARRISON_TYPE_BFA = GarrisonType.Type_8_0_Garrison
local GARRISON_TYPE_SHADOWLANDS = GarrisonType.Type_9_0_Garrison

---------------
-- Functions --
---------------

-- 誓盟報告需要誓盟
local function hasMissionTable(garrisonType)
	return C_Garrison.HasGarrison(garrisonType)
		and (garrisonType ~= GARRISON_TYPE_SHADOWLANDS or C_Covenants.GetActiveCovenantID() > 0)
end

-- 任務桌
local function openMissionTable(garrisonType)
	if not hasMissionTable(garrisonType) then return end

	if F.CombatError() then return end
	securecall(ShowGarrisonLandingPage, garrisonType)
end

---------------
-- Menu lsit --
---------------

-- 建立包含圖示的選項
local function CreateIconButton(rootDescription, text, icon, callback)
	local atlasInfo = type(icon) == "string" and C_Texture.GetAtlasInfo(icon)
	local markup
	if atlasInfo then
		markup = CreateAtlasMarkup(icon, 16, 16)	-- 引用原生micro menu atlas
	else
		markup = CreateSimpleTextureMarkup(icon, 16, 16)	-- 自定材質路徑
	end

	return rootDescription:CreateButton(markup.." "..text, callback)	-- 選項文字，點擊該選項要執行的功能
end

-- 每次開啟重新判斷可見項目
local function GenerateMenu(_, rootDescription)
	-- 標題
	rootDescription:CreateTitle(MAINMENU_BUTTON)

	-- 角色
	CreateIconButton(rootDescription, CHARACTER_BUTTON, "Interface\\PVPFrame\\PVP-Banner-Emblem-3", function()
		if F.CombatError() then return end
		securecall(ToggleCharacter, "PaperDollFrame")
	end)

	-- 專業技能
	CreateIconButton(rootDescription, PROFESSIONS_BUTTON, "Interface\\MINIMAP\\TRACKING\\Class", function()
		if F.CombatError() then return end
			ToggleProfessionsBook()
	end)

	-- Forever 天賦 / Retail 天賦與法術書
	if UnitLevel("player") >= 10 then
		CreateIconButton(rootDescription, (G.IsForever and TALENTS) or PLAYERSPELLS_BUTTON,
			"Interface\\HELPFRAME\\HelpIcon-CharacterStuck", function()
				if F.CombatError() then return end
				securecall(TogglePlayerSpellsFrame, 2)
		end)
	end

	if G.IsForever then
		-- Forever 法術書
		CreateIconButton(rootDescription, SPELLBOOK, "Interface\\ICONS\\INV_Misc_Book_09", function()
			if F.CombatError() then return end
				securecall(TogglePlayerSpellsFrame, 3)
		end)
	end

	if G.IsForever then
		-- Forever 傳承
		CreateIconButton(rootDescription, LEGACY_BUTTON, "UI-HUD-MicroMenu-Legacy-Up", function()
			if F.CombatError() then return end
			securecall(ToggleLegacySystemUI)
		end)
	else
		-- Retail 成就
		CreateIconButton(rootDescription, ACHIEVEMENT_BUTTON, "Interface\\MINIMAP\\TRACKING\\QuestBlob", function()
			if F.CombatError() then return end
			securecall(ToggleAchievementFrame)
		end)
	end

	-- 地圖與任務日誌
	CreateIconButton(rootDescription, MAP_AND_QUEST_LOG, "Interface\\GossipFrame\\ActiveQuestIcon", function()
		if F.CombatError() then return end
		securecall(ToggleWorldMap)
	end)

	-- Retail 房屋資訊看板
	if not G.IsForever then
		CreateIconButton(rootDescription, HOUSING_MICRO_BUTTON, 7252953, function()
			if (not C_Housing.IsHousingServiceEnabled()) or F.CombatError() then return end
			_G.HousingFramesUtil.ToggleHousingDashboard()
		end)
	end

	-- 社群 "Interface\\FriendsFrame\\UI-Toast-ChatInviteIcon"
	CreateIconButton(rootDescription, COMMUNITIES_FRAME_TITLE, "UI-HUD-MicroMenu-GuildCommunities-Up", function()
		if F.CombatError() then return end
		securecall(ToggleCommunitiesFrame)
	end)

	-- 好友
	CreateIconButton(rootDescription, SOCIAL_BUTTON, "Interface\\CHATFRAME\\UI-ChatWhisperIcon", function()
		if F.CombatError() then return end
		securecall(ToggleFriendsFrame, 1)
	end)

	-- 組隊搜尋 "Interface\\TUTORIALFRAME\\UI-TutorialFrame-AttackCursor"
	CreateIconButton(rootDescription, (G.IsForever and LFG_TITLE) or GROUP_FINDER, "UI-HUD-MicroMenu-Groupfinder-Up", function()
		if F.CombatError() then return end
		securecall((G.IsForever and ToggleGroupFinderFrame) or ToggleLFDParentFrame)
	end)

	-- 收藏
	CreateIconButton(rootDescription, COLLECTIONS, "Interface\\CURSOR\\Crosshair\\WildPetCapturable", function()
		if F.CombatError() then return end
		securecall(ToggleCollectionsJournal, 1)
	end)

	-- Retail 冒險指南
	if not G.IsForever then
		CreateIconButton(rootDescription, ADVENTURE_JOURNAL, "Interface\\ENCOUNTERJOURNAL\\UI-EJ-HeroicTextIcon", function()
			if F.CombatError() then return end
			securecall(ToggleEncounterJournal)
		end)
	end

	-- 遊戲商城
	CreateIconButton(rootDescription, BLIZZARD_STORE, "Interface\\MINIMAP\\TRACKING\\Auctioneer", function()
		if not StoreFrame then C_AddOns.LoadAddOn("Blizzard_StoreUI") end
		securecall(ToggleStoreUI)
	end)

	-- 空行
	rootDescription:QueueSpacer()

	-- 其他
	rootDescription:QueueTitle(OTHER)

	-- Retail 要塞報告
	if hasMissionTable(GARRISON_TYPE_DRAENOR) then
		CreateIconButton(rootDescription, GARRISON_LANDING_PAGE_TITLE, "Interface\\HELPFRAME\\OpenTicketIcon", function()
			openMissionTable(GARRISON_TYPE_DRAENOR)
		end)
	end

	-- Retail 職業大廳報告
	if hasMissionTable(GARRISON_TYPE_LEGION) then
		CreateIconButton(rootDescription, ORDER_HALL_LANDING_PAGE_TITLE, "Interface\\GossipFrame\\WorkOrderGossipIcon", function()
			openMissionTable(GARRISON_TYPE_LEGION)
		end)
	end

	-- Retail 任務指揮桌
	if hasMissionTable(GARRISON_TYPE_BFA) then
		CreateIconButton(rootDescription, EXPANSION_NAME7.." "..GARRISON_TYPE_8_0_LANDING_PAGE_TITLE, "Interface\\HELPFRAME\\OpenTicketIcon", function()
			openMissionTable(GARRISON_TYPE_BFA)
		end)
	end

	-- Retail 誓盟報告
	if hasMissionTable(GARRISON_TYPE_SHADOWLANDS) then
		CreateIconButton(rootDescription, GARRISON_TYPE_9_0_LANDING_PAGE_TITLE, "Interface\\GossipFrame\\WorkOrderGossipIcon", function()
			openMissionTable(GARRISON_TYPE_SHADOWLANDS)
		end)
	end

	-- 客服支援
	CreateIconButton(rootDescription, GM_EMAIL_NAME, "Interface\\CHATFRAME\\UI-ChatIcon-Blizz", function()
		if F.CombatError() then return end
		securecall(ToggleHelpFrame)
	end)

	-- 對話頻道
	CreateIconButton(rootDescription, CHANNEL, "Interface\\CHATFRAME\\UI-ChatIcon-ArmoryChat-AwayMobile", function()
		if F.CombatError() then return end
		securecall(ToggleChannelFrame)
	end)

	-- 行事曆
	rootDescription:CreateButton(L.Calendar, function()
		if F.CombatError() then return end
		securecall(ToggleCalendar)
	end)

	-- 區域地圖
	rootDescription:CreateButton("|cff999999"..BATTLEFIELD_MINIMAP.."|r", function()
		if F.CombatError() then return end
		securecall(ToggleBattlefieldMap)
	end)

	rootDescription:CreateButton("|cff00FFFF"..L.ToggleConfig.."|r", function()
		F.CreateEKMOptions()
	end)

	-- 空行
	rootDescription:QueueSpacer()

	-- 彈出乘客
	rootDescription:QueueTitle(EJECT_PASSENGER)

	-- 彈出乘客1
	rootDescription:CreateButton(L.Left, function()
		EjectPassengerFromSeat(1)
	end)

	-- 彈出乘客2
	rootDescription:CreateButton(L.Right, function()
		EjectPassengerFromSeat(2)
	end)

	-- 空行
	rootDescription:QueueSpacer()

	-- 插件標題
	rootDescription:QueueTitle(ADDONS)

	-- BigWigs
	if SlashCmdList.BigWigs then
		rootDescription:CreateButton("BigWigs", function()
			SlashCmdList.BigWigs()
		end)
	end

	-- DBM
	if SlashCmdList.DEADLYBOSSMODS then
		rootDescription:CreateButton("DBM", function()
			SlashCmdList.DEADLYBOSSMODS("")	-- /dbm 無子命令時仍需空字串，供 handler 解析。
		end)
	end

	-- oUF_Ruri
	if SlashCmdList.OUFRURI then
		rootDescription:CreateButton("oUF_Ruri", function()
			SlashCmdList.OUFRURI()
		end)
	end

	-- oUF_Hankk
	if SlashCmdList.OUFHANKK then
		rootDescription:CreateButton("oUF_Hankk", function()
			SlashCmdList.OUFHANKK()
		end)
	end

	-- Anyon
	if SlashCmdList.ANYON then
		rootDescription:CreateButton("Anyon", function()
			SlashCmdList.ANYON()
		end)
	end

	rootDescription:CreateButton("|cff999999"..RELOADUI.."|r", function()
		ReloadUI()
	end)
end

local function OnEvent()
	if not F.GetEKMOption("ClickMenu") then return end

	-- 右鍵 context menu；中鍵追蹤選單。
	local clicker = EKMinimapClicker
	clicker:SetScript("OnMouseUp", function(self, button)
		local stat = EKMinimapTooltipButton
		if stat and stat:IsMouseOver() then return end
		if IsAltKeyDown() then return end

		if button == "RightButton" then
			MenuUtil.CreateContextMenu(self, GenerateMenu)
		elseif button == "MiddleButton" then
			local button = MinimapCluster.Tracking.Button
			if button then
				button:OpenMenu()
				if button.menu then
					button.menu:ClearAllPoints()
					button.menu:SetPoint("CENTER", self, (Minimap:GetWidth() * .7), -(Minimap:GetHeight()/2))
				end
			end
		else
			return
		end
	end)
end

local frame = CreateFrame("FRAME")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", OnEvent)