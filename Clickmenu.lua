local addon, ns = ...
local C, F, G, L = unpack(ns)
local Minimap, MinimapCluster = Minimap, MinimapCluster

local GarrisonType = Enum and Enum.GarrisonType
local GARRISON_TYPE_DRAENOR = GarrisonType and GarrisonType.Type_6_0_Garrison or 2
local GARRISON_TYPE_LEGION = GarrisonType and GarrisonType.Type_7_0_Garrison or 3
local GARRISON_TYPE_BFA = GarrisonType and GarrisonType.Type_8_0_Garrison or 9
local GARRISON_TYPE_SHADOWLANDS = GarrisonType and GarrisonType.Type_9_0_Garrison or 111

--===================================================--
-----------------    [[ EasyMenu ]]    ----------------
--===================================================--

local function IsMenuItemHidden(value)
	if type(value.hidden) == "function" then
		return value.hidden()
	end

	return value.hidden
end

local function EasyMenu_Initialize(frame, level, menuList)
	for index = 1, #menuList do
		local value = menuList[index]
		if value.text and not IsMenuItemHidden(value) then
			value.index = index
			UIDropDownMenu_AddButton(value, level)
		end
	end
end

local function EasyMenu(menuList, menuFrame, anchor, x, y, displayMode, autoHideDelay)
	if displayMode == "MENU" then
		menuFrame.displayMode = displayMode
	end

	UIDropDownMenu_Initialize(menuFrame, EasyMenu_Initialize, displayMode, nil, menuList)
	ToggleDropDownMenu(1, nil, menuFrame, anchor, x, y, menuList, nil, autoHideDelay)
end

--===================================================--
-----------------    [[ Function ]]    ----------------
--===================================================--

-- Mission table visibility
local function hasMissionTable(garrisonType)
	return C_Garrison and C_Garrison.HasGarrison and C_Garrison.HasGarrison(garrisonType)
end

local function openMissionTable(garrisonType)
	if not hasMissionTable(garrisonType) then return end

	if InCombatLockdown() then
		UIErrorsFrame:AddMessage(G.ErrColor..ERR_NOT_IN_COMBAT)
	else
		securecall(ShowGarrisonLandingPage, garrisonType)
	end
end

--====================================================--
-----------------    [[ ClickMenu ]]    ----------------
--====================================================--

local function OnEvent()
	if not EKMinimapDB["ClickMenu"] then return end
	
	-- Right Click Menu List
	local menuFrame = CreateFrame("Frame", "MinimapRightClickMenu", UIParent, "UIDropDownMenuTemplate")
	local menuList = {
		{	-- 標題
			text = MAINMENU_BUTTON,
			isTitle = true,
			notCheckable = true,
		},
		
		{	-- 角色
			text = CHARACTER_BUTTON,
			icon = "Interface\\PVPFrame\\PVP-Banner-Emblem-3",
			func = function()
				if InCombatLockdown() then UIErrorsFrame:AddMessage(G.ErrColor..ERR_NOT_IN_COMBAT) else securecall(ToggleCharacter, "PaperDollFrame") end
			end,
			notCheckable = true,
		},
		
		{	-- 專業技能
			text = PROFESSIONS_BUTTON,
			icon = "Interface\\MINIMAP\\TRACKING\\Class",
			func = function()
				if InCombatLockdown() then UIErrorsFrame:AddMessage(G.ErrColor..ERR_NOT_IN_COMBAT) else ToggleProfessionsBook() end
				
			end,
			notCheckable = true,
		},

		{	--天賦與法術書
			text = PLAYERSPELLS_BUTTON,	-- TALENTS_BUTTON
			icon = "Interface\\HELPFRAME\\HelpIcon-CharacterStuck",
			func = function() 
				if InCombatLockdown() then UIErrorsFrame:AddMessage(G.ErrColor..ERR_NOT_IN_COMBAT) else securecall(TogglePlayerSpellsFrame, 2) end
			end,
			notCheckable = true,
		},
		
		{	-- 成就
			text = ACHIEVEMENT_BUTTON,
			icon = "Interface\\MINIMAP\\TRACKING\\QuestBlob",
			func = function() 
				if InCombatLockdown() then UIErrorsFrame:AddMessage(G.ErrColor..ERR_NOT_IN_COMBAT) return end
				if not AchievementFrame then C_AddOns.LoadAddOn("Blizzard_AchievementUI") end
				securecall(ToggleAchievementFrame)
			end,
			notCheckable = true,
		},

		{	-- 地圖與任務日誌
			text = MAP_AND_QUEST_LOG,	-- OLD: QUESTLOG_BUTTON
			icon = "Interface\\GossipFrame\\ActiveQuestIcon",
			func = function()
				if InCombatLockdown() then UIErrorsFrame:AddMessage(G.ErrColor..ERR_NOT_IN_COMBAT) else securecall(ToggleFrame, WorldMapFrame) end
			end,
			notCheckable = true,
		},
		
		{	-- 房屋資訊看板
			text = HOUSING_MICRO_BUTTON,
			icon = 7252953,
			func = function()
				if not C_Housing.IsHousingServiceEnabled() then return end
				if InCombatLockdown() then
					UIErrorsFrame:AddMessage(G.ErrColor..ERR_NOT_IN_COMBAT)
				else
					_G.HousingFramesUtil.ToggleHousingDashboard()
				end
			end,
			notCheckable = true,
		},
		
		{	-- 社群
			text = COMMUNITIES_FRAME_TITLE,
			icon = "Interface\\FriendsFrame\\UI-Toast-ChatInviteIcon",
			func = function()
				if InCombatLockdown() then UIErrorsFrame:AddMessage(G.ErrColor..ERR_NOT_IN_COMBAT) return end
				if not CommunitiesFrame then C_AddOns.LoadAddOn("Blizzard_Communities") end
				securecall(ToggleCommunitiesFrame)
			end,
			notCheckable = true,
		},
		
		{	-- 好友
			text = SOCIAL_BUTTON,
			icon = "Interface\\CHATFRAME\\UI-ChatWhisperIcon",
			func = function() 
				if InCombatLockdown() then UIErrorsFrame:AddMessage(G.ErrColor..ERR_NOT_IN_COMBAT) else securecall(ToggleFriendsFrame, 1) end
			end,
			notCheckable = true,
		},
		
		{	-- 地城與團隊
			text = GROUP_FINDER,	-- DUNGEONS_BUTTON
			icon = "Interface\\TUTORIALFRAME\\UI-TutorialFrame-AttackCursor",
			func = function()
				if InCombatLockdown() then UIErrorsFrame:AddMessage(G.ErrColor..ERR_NOT_IN_COMBAT) else securecall(ToggleLFDParentFrame) end
			end,
			notCheckable = true,
		},
		
		{	-- 收藏
			text = COLLECTIONS,
			icon = "Interface\\CURSOR\\Crosshair\\WildPetCapturable",
			func = function()
				if InCombatLockdown() then UIErrorsFrame:AddMessage(G.ErrColor..ERR_NOT_IN_COMBAT) return end
				if not CollectionsJournal then C_AddOns.LoadAddOn("Blizzard_Collections") end
				securecall(ToggleCollectionsJournal, 1)
			end,
			notCheckable = true,
		},
		
		{	-- 冒險指南
			text = ADVENTURE_JOURNAL,	-- OLD: ENCOUNTER_JOURNAL
			icon = "Interface\\ENCOUNTERJOURNAL\\UI-EJ-HeroicTextIcon",
			func = function()
				if InCombatLockdown() then UIErrorsFrame:AddMessage(G.ErrColor..ERR_NOT_IN_COMBAT) return end
				if not EncounterJournal then C_AddOns.LoadAddOn("Blizzard_EncounterJournal") end
				securecall(ToggleEncounterJournal)
			end,
			notCheckable = true,
		},
		
		{	-- 遊戲商城
			text = BLIZZARD_STORE,
			icon = "Interface\\MINIMAP\\TRACKING\\Auctioneer",
			func = function()
				if not StoreFrame then C_AddOns.LoadAddOn("Blizzard_StoreUI") end
				securecall(ToggleStoreUI)
			end,
			notCheckable = true,
		},
		
		{	-- 空行
			text = "",
			isTitle = true,
			notCheckable = true,
		},
		
		{	-- 其他
			text = OTHER,
			isTitle = true,
			notCheckable = true,
		},
		
		{	-- 要塞報告
			text = GARRISON_LANDING_PAGE_TITLE,
			icon = "Interface\\HELPFRAME\\OpenTicketIcon",
			hidden = function() return not hasMissionTable(GARRISON_TYPE_DRAENOR) end,
			func = function()
				openMissionTable(GARRISON_TYPE_DRAENOR)
			end,
			notCheckable = true,
		},

		{	-- 職業大廳報告
			text = ORDER_HALL_LANDING_PAGE_TITLE,
			icon = "Interface\\GossipFrame\\WorkOrderGossipIcon",
			hidden = function() return not hasMissionTable(GARRISON_TYPE_LEGION) end,
			func = function()
				openMissionTable(GARRISON_TYPE_LEGION)
			end,
			notCheckable = true,
		},
		
		{	-- 任務指揮桌
			text = EXPANSION_NAME7.." "..GARRISON_TYPE_8_0_LANDING_PAGE_TITLE,
			icon = "Interface\\HELPFRAME\\OpenTicketIcon",
			hidden = function() return not hasMissionTable(GARRISON_TYPE_BFA) end,
			func = function()
				openMissionTable(GARRISON_TYPE_BFA)
			end,
			notCheckable = true,
		},
		
		{	-- 誓盟報告
			text = GARRISON_TYPE_9_0_LANDING_PAGE_TITLE,
			icon = "Interface\\GossipFrame\\WorkOrderGossipIcon",
			hidden = function() return not hasMissionTable(GARRISON_TYPE_SHADOWLANDS) end,
			func = function()
				openMissionTable(GARRISON_TYPE_SHADOWLANDS)
			end,
			notCheckable = true,
		},

		{	-- 客服支援
			text = GM_EMAIL_NAME,
			icon = "Interface\\CHATFRAME\\UI-ChatIcon-Blizz",
			func = function() 
				if InCombatLockdown() then UIErrorsFrame:AddMessage(G.ErrColor..ERR_NOT_IN_COMBAT) else securecall(ToggleHelpFrame) end
			end,
			notCheckable = true,
		},
		
		{	-- 對話頻道
			text = CHANNEL,
			icon = "Interface\\CHATFRAME\\UI-ChatIcon-ArmoryChat-AwayMobile",
			func = function()
				if InCombatLockdown() then UIErrorsFrame:AddMessage(G.ErrColor..ERR_NOT_IN_COMBAT) else securecall(ToggleChannelFrame) end
			end,
			notCheckable = true
		},
		
		{	-- 行事曆
			text = L.Calendar,
			func = function()
				if InCombatLockdown() then UIErrorsFrame:AddMessage(G.ErrColor..ERR_NOT_IN_COMBAT) return end
				if not CalendarFrame then C_AddOns.LoadAddOn("Blizzard_Calendar") end
				securecall(ToggleCalendar)
			end,
			notCheckable = true,
		},
		
		{	-- 區域地圖
			text = BATTLEFIELD_MINIMAP,
			colorCode = "|cff999999",
			func = function()
				if InCombatLockdown() then UIErrorsFrame:AddMessage(G.ErrColor..ERR_NOT_IN_COMBAT) return end
				if not BattlefieldMapFrame then C_AddOns.LoadAddOn("Blizzard_BattlefieldMap") end
				securecall(ToggleFrame, BattlefieldMapFrame)
			end,
			notCheckable = true,
		},
		
		{
			text = L.ToggleConfig,
			colorCode = "|cff00FFFF",
			func = function()
				F.CreateEKMOptions()
			end,
			notCheckable = true,
		},
		
		{	-- 空行
			text = "",
			isTitle = true,
			notCheckable = true,
		},
		
		{	-- 彈出乘客
			text = EJECT_PASSENGER,
			isTitle = true,
			notCheckable = true,
		},
		
		{	-- 彈出乘客1
			text = L.Left,
			func = function()
				EjectPassengerFromSeat(1)
			end,
			notCheckable = true,
		},
		
		{	-- 彈出乘客2
			text = L.Right,
			func = function()
				EjectPassengerFromSeat(2)
			end,
			notCheckable = true,
		},

		{	-- 空行
			text = "",
			isTitle = true,
			notCheckable = true,
		},
		
		{	-- 插件標題
			text = ADDONS,
			isTitle = true,
			notCheckable = true,
		},
		--[[{	-- bigwigs
			text = "BigWigs",
			func = function()
				if not IsAddOnLoaded("Bigwigs") then
					print("尚未啟用Bigwigs")
				else
					SlashCmdList["BigWigs"]("BigWigs1")
				end
			end,
			notCheckable = true,
		},]]--
		{	-- 重載
			text = RELOADUI,
			colorCode = "|cff999999",
			func = function()
				ReloadUI()
			end,
			notCheckable = true,
		},
	}

	-- Right Click for Game Menu, Left Click for Track Menu / 右鍵遊戲選單，中鍵追蹤選單
	local clicker = EKMinimapClicker or Minimap
	clicker:SetScript("OnMouseUp", function(self, button)
		local stat = EKMinimapTooltipButton
		if stat and stat:IsMouseOver() then return end
		if IsAltKeyDown() then return end

		if button == "RightButton" then
			EasyMenu(menuList, menuFrame, self, (Minimap:GetWidth() * .7), -3, "MENU", 2)
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