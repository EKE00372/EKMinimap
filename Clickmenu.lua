local addon, ns = ...
local C, F, G, L = unpack(ns)
local Minimap, EasyMenu, ToggleDropDownMenu = Minimap, EasyMenu, ToggleDropDownMenu
local LibEasyMenu = LibStub:GetLibrary("LibEasyMenu")
local LibShowUIPanel = LibStub("LibShowUIPanel-1.0")
local ShowUIPanel = LibShowUIPanel.ShowUIPanel
local HideUIPanel = LibShowUIPanel.HideUIPanel

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
				--ToggleCharacter("PaperDollFrame")
				--securecall(ToggleCharacter, "PaperDollFrame")
				if not CharacterFrame:IsShown() then ShowUIPanel(CharacterFrame) CharacterFrameTab2:Click() CharacterFrameTab1:Click() else HideUIPanel(CharacterFrame) end
			end,
			notCheckable = true,
		},
		
		{	-- 專業技能
			text = PROFESSIONS_BUTTON,
			icon = "Interface\\MINIMAP\\TRACKING\\Class",
			func = function()
				if InCombatLockdown() then
					print("|cffffff00"..ERR_NOT_IN_COMBAT.."|r") return
				end
				ToggleProfessionsBook()
			end,
			notCheckable = true,
		},
		--[[
		{	-- 法術書
			text = SPELLBOOK,
			icon = "Interface\\MINIMAP\\TRACKING\\Class",
			func = function()
				-- edit mode error when toggle in combat
				--securecall(TogglePlayerSpellsFrame, 3)
			end,
			notCheckable = true,
		},
		]]--
		{	--天賦與法術書
			text = PLAYERSPELLS_BUTTON,	-- TALENTS_BUTTON
			icon = "Interface\\HELPFRAME\\HelpIcon-CharacterStuck",
			func = function() 
				--securecall(TogglePlayerSpellsFrame, 2)
				if not PlayerSpellsFrame:IsShown() then ShowUIPanel(PlayerSpellsFrame) else HideUIPanel(PlayerSpellsFrame) end
			end,
			notCheckable = true,
		},
		
		{	-- 成就
			text = ACHIEVEMENT_BUTTON,
			icon = "Interface\\MINIMAP\\TRACKING\\QuestBlob",
			func = function() 
				if not AchievementFrame then C_AddOns.LoadAddOn("Blizzard_AchievementUI") end
				if not AchievementFrame:IsShown() then ShowUIPanel(AchievementFrame) else HideUIPanel(AchievementFrame) end
			end,
			notCheckable = true,
		},

		{	-- 地圖與任務日誌
			text = MAP_AND_QUEST_LOG,	-- OLD: QUESTLOG_BUTTON
			icon = "Interface\\GossipFrame\\ActiveQuestIcon",
			func = function()
				if not WorldMapFrame:IsShown() then ShowUIPanel(WorldMapFrame) else HideUIPanel(WorldMapFrame) end
			end,
			notCheckable = true,
		},
		
		{	-- 社群
			text = COMMUNITIES_FRAME_TITLE,
			icon = "Interface\\FriendsFrame\\UI-Toast-ChatInviteIcon",
			arg1 = IsInGuild("player"),
			func = function()
				if not CommunitiesFrame then C_AddOns.LoadAddOn("Blizzard_Communities") end
				if not CommunitiesFrame:IsShown() then ShowUIPanel(CommunitiesFrame) else HideUIPanel(CommunitiesFrame) end
			end,
			notCheckable = true,
		},
		
		{	-- 好友
			text = SOCIAL_BUTTON,
			icon = "Interface\\CHATFRAME\\UI-ChatWhisperIcon",
			func = function() 
				if not FriendsFrame:IsShown() then ShowUIPanel(FriendsFrame) else HideUIPanel(FriendsFrame) end
			end,
			notCheckable = true,
		},
		
		{	-- 地城與團隊
			text = GROUP_FINDER,	-- DUNGEONS_BUTTON
			icon = "Interface\\TUTORIALFRAME\\UI-TutorialFrame-AttackCursor",
			func = function()
				--securecall(ToggleLFDParentFrame)
				if not PVEFrame:IsShown() then ShowUIPanel(PVEFrame) PVEFrameTab1:Click() else HideUIPanel(PVEFrame) end
			end,
			notCheckable = true,
		},
		
		{	-- 收藏
			text = COLLECTIONS,
			icon = "Interface\\CURSOR\\Crosshair\\WildPetCapturable",
			func = function()
				if not CollectionsJournal then LoadAddOn("Blizzard_Collections") end
				if not CollectionsJournal:IsShown() then ShowUIPanel(CollectionsJournal) else HideUIPanel(CollectionsJournal) end
			end,
			notCheckable = true,
		},
		
		{	-- 冒險指南
			text = ADVENTURE_JOURNAL,	-- OLD: ENCOUNTER_JOURNAL
			icon = "Interface\\ENCOUNTERJOURNAL\\UI-EJ-HeroicTextIcon",
			func = function()
				if not EncounterJournal then LoadAddOn("Blizzard_EncounterJournal") end
				if not EncounterJournal:IsShown() then ShowUIPanel(EncounterJournal) else HideUIPanel(EncounterJournal) end
			end,
			notCheckable = true,
		},
		
		{	-- 遊戲商城
			text = BLIZZARD_STORE,
			icon = "Interface\\MINIMAP\\TRACKING\\Auctioneer",
			func = function()
				if not StoreFrame then LoadAddOn("Blizzard_StoreUI") end
				securecall(ToggleStoreUI)
				--if not StoreFrame:IsShown() then ShowUIPanel(StoreFrame) else HideUIPanel(StoreFrame) end
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
			func = function()
				--if not ExpansionLandingPage:IsShown() then ShowUIPanel(ExpansionLandingPage) else HideUIPanel(ExpansionLandingPage) end
				securecall(ShowGarrisonLandingPage, 2)
			end,
			notCheckable = true,
		},
		--[[
		{	-- 要塞報告 海軍行動
			text = GARRISON_LANDING_PAGE_TITLE.." "..GARRISON_SHIPYARD_TITLE,
			icon = "Interface\\HELPFRAME\\OpenTicketIcon",
			func = function()
				if not ExpansionLandingPage:IsShown() then ShowUIPanel(GarrisonShipyardFrame) else ShowUIPanel(GarrisonShipyardFrame) end
			end,
			notCheckable = true,
		},
		]]--
		{	-- 職業大廳報告
			text = ORDER_HALL_LANDING_PAGE_TITLE,
			icon = "Interface\\GossipFrame\\WorkOrderGossipIcon",
			func = function()			
				securecall(ShowGarrisonLandingPage, 3)
			end,
			notCheckable = true,
		},
		
		{	-- 任務指揮桌
			text = EXPANSION_NAME7.." "..GARRISON_TYPE_8_0_LANDING_PAGE_TITLE,
			icon = "Interface\\HELPFRAME\\OpenTicketIcon",
			func = function()			
				securecall(ShowGarrisonLandingPage, 9)
			end,
			notCheckable = true,
		},
		
		{	-- 誓盟報告
			text = GARRISON_TYPE_9_0_LANDING_PAGE_TITLE,
			icon = "Interface\\GossipFrame\\WorkOrderGossipIcon",
			func = function()
				securecall(ShowGarrisonLandingPage, LE_GARRISON_TYPE_9_0)
			end,
			notCheckable = true,
		},
		--[[
		{	-- 巨龍時代
			text = DRAGONFLIGHT_LANDING_PAGE_TITLE,
			icon = "Interface\\HELPFRAME\\OpenTicketIcon",
			func = function()			
				if not ExpansionLandingPage:IsShown() then ShowUIPanel(GenericTraitFrame) else HideUIPanel(GenericTraitFrame) end
			end,
			notCheckable = true,
		},
		]]--
		{	-- 客服支援
			text = GM_EMAIL_NAME,
			icon = "Interface\\CHATFRAME\\UI-ChatIcon-Blizz",
			func = function() 
				if not HelpFrame:IsShown() then ShowUIPanel(HelpFrame) else HideUIPanel(HelpFrame) end
			end,
			notCheckable = true,
		},
		
		{	-- 語音
			text = CHANNEL,
			icon = "Interface\\CHATFRAME\\UI-ChatIcon-ArmoryChat-AwayMobile",
			func = function()
				if not ChannelFrame:IsShown() then ShowUIPanel(ChannelFrame) else HideUIPanel(ChannelFrame) end
			end,
			notCheckable = true
		},
		
		{	-- 行事曆
			text = L.Calendar,
			func = function()
				if not CalendarFrame then C_AddOns.LoadAddOn("Blizzard_Calendar") end
				if not CalendarFrame:IsShown() then ShowUIPanel(CalendarFrame) else HideUIPanel(CalendarFrame) end
			end,
			notCheckable = true,
		},
		
		{	-- 區域地圖
			text = BATTLEFIELD_MINIMAP,
			colorCode = "|cff999999",
			func = function()
				if not BattlefieldMapFrame then C_AddOns.LoadAddOn("Blizzard_BattlefieldMap") end
				if not BattlefieldMapFrame:IsShown() then ShowUIPanel(BattlefieldMapFrame) else HideUIPanel(BattlefieldMapFrame) end
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
	Minimap:SetScript("OnMouseUp", function(self, button)
		if button == "RightButton" then
			LibEasyMenu:EasyMenu(menuList, menuFrame, self, (Minimap:GetWidth() * .7), -3, "MENU", 2)
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
			Minimap:OnClick()
		end
	end)
end

local frame = CreateFrame("FRAME")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", OnEvent)

-- avoid spellbook taint / 避免taint
local initialize = CreateFrame("Frame")
	initialize:SetScript("OnEvent", function()
		C_AddOns.LoadAddOn("Blizzard_PlayerSpells")
		C_AddOns.LoadAddOn("Blizzard_ProfessionsBook")
		ShowUIPanel(PlayerSpellsFrame)
		HideUIPanel(PlayerSpellsFrame)
	end)
	initialize:RegisterEvent("PLAYER_ENTERING_WORLD")