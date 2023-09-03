local addon, ns = ...
local C, F, G, L = unpack(ns)
local Minimap, EasyMenu, ToggleDropDownMenu = Minimap, EasyMenu, ToggleDropDownMenu
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
			icon = "Interface\\PaperDollInfoFrame\\UI-EquipmentManager-Toggle",
			func = function()
				if not CharacterFrame:IsShown() then ShowUIPanel(CharacterFrame) else HideUIPanel(CharacterFrame) end
			end,
			notCheckable = true,
		},
		{	-- 法術書
			text = SPELLBOOK_ABILITIES_BUTTON,
			icon = "Interface\\MINIMAP\\TRACKING\\Class",
			func = function() 
				if not SpellBookFrame:IsShown() then ShowUIPanel(SpellBookFrame) else HideUIPanel(SpellBookFrame) end
			end,
			notCheckable = true,
		},
		{	--天賦
			text = TALENTS,
			icon = "Interface\\MINIMAP\\TRACKING\\Ammunition",
			func = function()
				if UnitLevel("player") > 10 then
					if not PlayerTalentFrame then LoadAddOn("Blizzard_TalentUI") end
					if not TalentFrame:IsShown() then ShowUIPanel(TalentFrame) else HideUIPanel(TalentFrame) end
				end
			end,
			notCheckable = true,
		},
		{	-- 任務日誌
			text = QUESTLOG_BUTTON,
			icon = "Interface\\GossipFrame\\ActiveQuestIcon",
			func = function()
				if not QuestLogFrame:IsShown() then ShowUIPanel(QuestLogFrame) else HideUIPanel(QuestLogFrame) end
			end,
			notCheckable = true,
		},
		{	-- 地圖
			text = WORLD_MAP,
			icon = "Interface\\WorldMap\\UI-World-Icon",
			func = function()
				if not WorldMapFrame:IsShown() then ShowUIPanel(WorldMapFrame) else HideUIPanel(WorldMapFrame) end
			end,
			notCheckable = true,
		},
		{	-- 好友
			text = SOCIAL_BUTTON,
			icon = "Interface\\FriendsFrame\\UI-Toast-ChatInviteIcon",
			func = function()
				if not FriendsFrame:IsShown() then ShowUIPanel(FriendsFrame) else HideUIPanel(FriendsFrame) end
				securecall(ToggleFriendsFrame, 1) 
			end,
			notCheckable = true,
		},
		{	-- 公會
			text = GUILD,
			icon = "Interface\\GossipFrame\\TabardGossipIcon",
			arg1 = IsInGuild("player"),
			func = function()
				if not GuildFrame then LoadAddOn("Blizzard_GuildUI") end
				if not FriendsFrame:IsShown() then ShowUIPanel(FriendsFrame) else HideUIPanel(FriendsFrame) end
				securecall(ToggleFriendsFrame, 3)
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
		{	-- PVP
			text = PLAYER_V_PLAYER,
			icon = "Interface\\MINIMAP\\TRACKING\\BattleMaster",
			func = function()
				if UnitLevel("player") > 10 then
					securecall(ToggleCharacter, "HonorFrame")
				end
			end,
			notCheckable = true,
		},
		{	-- 團隊
			text = RAID,
			icon = "Interface\\Buttons\\UI-GuildButton-PublicNote-Up",
			func = function() 
				securecall(ToggleFriendsFrame, 4)
			end,
			notCheckable = true,
		},
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
		{	-- 碼表
			text = STOPWATCH_TITLE,
			icon = "Interface\\Icons\\INV_Misc_PocketWatch_01",
			func = function()
				if not TimeManagerFrame:IsShown() then ShowUIPanel(TimeManagerFrame) else HideUIPanel(TimeManagerFrame) end
			end,
			notCheckable = true
		},
		
		{	-- 區域地圖
			text = BATTLEFIELD_MINIMAP,
			colorCode = "|cff999999",
			func = function()
				if not BattlefieldMapFrame then LoadAddOn("Blizzard_BattlefieldMap") end
				if not BattlefieldMapFrame:IsShown() then ShowUIPanel(BattlefieldMapFrame) else HideUIPanel(BattlefieldMapFrame) end
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
		{
			text = L.ToggleConfig,
			colorCode = "|cff00FFFF",
			func = function()
				F.CreateEKMOptions()
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

	-- Right Click for Game Menu / 右鍵遊戲選單
	Minimap:SetScript("OnMouseUp", function(self, button)
		if button == "RightButton" then
			EasyMenu(menuList, menuFrame, self, (Minimap:GetWidth() * .7), -3, "MENU", 3)
		else
			Minimap_OnClick(self)
		end
	end)
end

local frame = CreateFrame("FRAME")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", OnEvent)

-- avoid taint / 避免taint
local initialize = CreateFrame("Frame")
	initialize:SetScript("OnEvent", function()
		ShowUIPanel(SpellBookFrame)
		HideUIPanel(SpellBookFrame)
	end)
	initialize:RegisterEvent("PLAYER_ENTERING_WORLD")