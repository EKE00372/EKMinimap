-- [[ Credit ]] --
-- NeavUI by Neal: https://www.wowinterface.com/downloads/info13981-NeavUI.html#info
-- ClickMenu by 10leej: https://www.wowinterface.com/downloads/info22660-ClickMenu.html

--  [[ Click Menu ]] --

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
		icon = "Interface\\PaperDollInfoFrame\\UI-EquipmentManager-Toggle",
		func = function()
			securecall(ToggleCharacter, "PaperDollFrame") 
		end,
		notCheckable = true,
	},
	{	-- 法術書
		text = SPELLBOOK_ABILITIES_BUTTON,
		icon = "Interface\\MINIMAP\\TRACKING\\Class",
		func = function() 
			--securecall(ToggleSpellBook, SpellBookFrame)
			if not SpellBookFrame:IsShown() then
				ShowUIPanel(SpellBookFrame)
			else
				HideUIPanel(SpellBookFrame)
			end
		end,
		notCheckable = true,
	},
	{	--天賦
		text = TALENTS_BUTTON,
		icon = "Interface\\MINIMAP\\TRACKING\\Ammunition",
		func = function() 
			if (not PlayerTalentFrame) then
				LoadAddOn("Blizzard_TalentUI")
			end
			if (not GlyphFrame) then
				LoadAddOn("Blizzard_GlyphUI")
			end
			securecall(ToggleFrame, PlayerTalentFrame)
		end,
		notCheckable = true,
	},
	{		-- 成就
		text = ACHIEVEMENT_BUTTON,
		icon = "Interface\\ACHIEVEMENTFRAME\\UI-Achievement-Shield",
		func = function() 
			securecall(ToggleAchievementFrame) 
		end,
		notCheckable = true,
	},
	{	-- 地圖與任務日誌
		text = MAP_AND_QUEST_LOG,	-- OLD: QUESTLOG_BUTTON
		icon = "Interface\\GossipFrame\\ActiveQuestIcon",
		func = function() 
			securecall(ToggleFrame, WorldMapFrame)
		end,
		notCheckable = true,
	},
	{	-- 公會和社群
		text = COMMUNITIES,		-- OLD: COMMUNITIES_FRAME_TITLE
		icon = "Interface\\GossipFrame\\ChatBubbleGossipIcon",
		arg1 = IsInGuild("player"),
		func = function() 
			ToggleCommunitiesFrame()
		end,
		notCheckable = true,
	},
	{	-- 公會
		text = GUILD,
		icon = "Interface\\GossipFrame\\TabardGossipIcon",
		arg1 = IsInGuild("player"),
		func = function() 
			if (not GuildFrame) then
				LoadAddOn("Blizzard_GuildUI")
			end
			--GuildFrame_Toggle()
			securecall(ToggleFrame, GuildFrame)
		end,
		notCheckable = true,
	},
	{	-- 好友
		text = SOCIAL_BUTTON,
		icon = "Interface\\FriendsFrame\\PlusManz-BattleNet",
		func = function() 
			securecall(ToggleFriendsFrame, 1) 
		end,
		notCheckable = true,
	},
	{	-- 地城與團隊
		text = GROUP_FINDER,	-- DUNGEONS_BUTTON
		icon = "Interface\\LFGFRAME\\BattleNetWorking0",
		func = function() 
			securecall(ToggleLFDParentFrame)	--OR securecall(PVEFrame_ToggleFrame, "GroupFinderFrame")
		end,
		notCheckable = true,
	},
	{	-- 收藏
		text = COLLECTIONS, -- OLD: MOUNTS_AND_PETS
		icon = "Interface\\MINIMAP\\TRACKING\\Reagents",
		func = function() 
			if InCombatLockdown() then
				print("|cffffff00"..ERR_NOT_IN_COMBAT.."|r") return
			end
			securecall(ToggleCollectionsJournal, 1)
		end,
		notCheckable = true,
	},	
	{	-- 冒險指南
		text = ADVENTURE_JOURNAL,	-- OLD: ENCOUNTER_JOURNAL
		icon = "Interface\\MINIMAP\\TRACKING\\Profession",
		func = function() 
			securecall(ToggleEncounterJournal)
		end,
		notCheckable = true,
	},
	{	-- 遊戲商城
		text = BLIZZARD_STORE,
		icon = "Interface\\MINIMAP\\TRACKING\\Auctioneer",
		func = function()
			if (not StoreFrame) then
				LoadAddOn("Blizzard_StoreUI")
			end
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
	{	-- 背包
		text = BACKPACK_TOOLTIP,
		icon = "Interface\\MINIMAP\\TRACKING\\Banker",
		func = function()
			securecall(ToggleAllBags)
		end,
		notCheckable = true,
	},
	{	-- 要塞報告
		text = GARRISON_LANDING_PAGE_TITLE,
		icon = "Interface\\HELPFRAME\\OpenTicketIcon",
		func = function()			
			securecall(ShowGarrisonLandingPage, 2)
			--HideUIPanel(GarrisonLandingPage)
			--ShowGarrisonLandingPage(LE_GARRISON_TYPE_6_0)
		end,
		notCheckable = true,
	},
	{	-- 職業大廳報告
		text = ORDER_HALL_LANDING_PAGE_TITLE,
		icon = "Interface\\GossipFrame\\WorkOrderGossipIcon",
		func = function()			
			securecall(ShowGarrisonLandingPage, 3)
			--HideUIPanel(GarrisonLandingPage)
			--ShowGarrisonLandingPage(LE_GARRISON_TYPE_6_0)
		end,
		notCheckable = true,
	},
	{	-- PVP
		text = PLAYER_V_PLAYER,
		icon = "Interface\\MINIMAP\\TRACKING\\BattleMaster",
		func = function() 
			securecall(TogglePVPUI, 1) 
		end,
		notCheckable = true,
	},
	{	-- 團隊
		text = RAID,
		icon = "Interface\\TARGETINGFRAME\\UI-TargetingFrame-Skull",
		func = function() 
			securecall(ToggleFriendsFrame, 3)
		end,
		notCheckable = true,
	},
	{	-- 客服支援
		text = GM_EMAIL_NAME,
		icon = "Interface\\CHATFRAME\\UI-ChatIcon-Blizz",
		func = function() 
			securecall(ToggleHelpFrame) 
		end,
		notCheckable = true,
	},
	{	-- 行事曆
		text = SLASH_CALENDAR1:gsub("/(.*)","%1"),	-- 沒有合適的global strings，而且也無法通用全語系本地化，只能將就
		func = function()
			if not CalendarFrame then 
				LoadAddOn("Blizzard_Calendar") 
			end
			Calendar_Toggle()
		end,
		notCheckable = true,
	},
	{	-- 區域地圖
		text = BATTLEFIELD_MINIMAP,
		colorCode = "|cff999999",
		func = function()
			if not BattlefieldMapFrame then 
				LoadAddOn("Blizzard_BattlefieldMap") 
			end
			BattlefieldMapFrame:Toggle()
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
	{	-- bigwigs
		text = "BigWigs",
		func = function()
			if not IsAddOnLoaded("Bigwigs") then
				print("尚未啟用Bigwigs")
			else
				SlashCmdList["BigWigs"]("BigWigs1")
			end
		end,
		notCheckable = true,
	},
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
	if (button == "RightButton") then
		EasyMenu(menuList, menuFrame, self, (Minimap:GetWidth() * .7), -3, "MENU", 3)
	elseif (button == "MiddleButton") then
		ToggleDropDownMenu(1, nil, MiniMapTrackingDropDown, self, (Minimap:GetWidth() * .7), -3)
	else
		Minimap_OnClick(self)
	end
end)

-- avoid taint / 避免taint
local initialize = CreateFrame("Frame")
initialize:SetScript("OnEvent", function()
	ShowUIPanel(SpellBookFrame)
	HideUIPanel(SpellBookFrame)
end)
initialize:RegisterEvent("PLAYER_ENTERING_WORLD")