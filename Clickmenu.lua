local addon, ns = ...
local C, F, G, L = unpack(ns)
local Minimap = Minimap

-- 標題沿用原生字體與顏色，只在文字右側補分隔線。
local function CreateMenuTitle(rootDescription, text)
	local title = MenuUtil.CreateTitle(text)
	title:SetFinalInitializer(function(frame)
		local line = frame:AttachTexture()
		line:SetColorTexture(.6, .65, .65, .3)
		line:SetHeight(1)
		line:SetPoint("LEFT", frame.fontString, "RIGHT", 8, 0)
		line:SetPoint("RIGHT", frame, "RIGHT", -2, 0)
	end)
	rootDescription:Insert(title)
end

-- 圖示與文字放在同一行，使用與主分支相同的 16px 尺寸。
local function CreateIconButton(rootDescription, text, icon, callback)
	local atlasInfo = type(icon) == "string" and C_Texture.GetAtlasInfo(icon)
	local markup
	if atlasInfo then
		markup = CreateAtlasMarkup(icon, 16, 16)
	else
		markup = CreateSimpleTextureMarkup(icon, 16, 16)
	end
	return rootDescription:CreateButton(markup.." "..text, callback)
end

-- 每次開啟時產生選單，讓天賦與榮譽入口跟隨目前角色狀態。
local function GenerateMenu(_, rootDescription)
	CreateMenuTitle(rootDescription, MAINMENU_BUTTON)

	-- 舊圖示："Interface\\PaperDollInfoFrame\\UI-EquipmentManager-Toggle"
	CreateIconButton(rootDescription, CHARACTER_BUTTON, "Interface\\ICONS\\INV_Chest_Plate01", function()
		if F.CombatError() then return end
		ToggleCharacter("PaperDollFrame")
	end)

	-- 舊圖示："Interface\\MINIMAP\\TRACKING\\Class"
	CreateIconButton(rootDescription, SPELLBOOK_ABILITIES_BUTTON, "Interface\\ICONS\\INV_Misc_Book_09", function()
		if F.CombatError() then return end
		ToggleSpellBook(BOOKTYPE_SPELL)
	end)

	if C_SpecializationInfo.CanPlayerUseTalentUI() then
		CreateIconButton(rootDescription, TALENTS, "Interface\\MINIMAP\\TRACKING\\Ammunition", function()
			if F.CombatError() then return end
			ToggleTalentFrame()
		end)
	end

	CreateIconButton(rootDescription, QUESTLOG_BUTTON, "Interface\\GossipFrame\\ActiveQuestIcon", function()
		if F.CombatError() then return end
		ToggleQuestLog()
	end)

	CreateIconButton(rootDescription, WORLD_MAP, "Interface\\WorldMap\\UI-World-Icon", function()
		if F.CombatError() then return end
		ToggleWorldMap()
	end)

	CreateIconButton(rootDescription, SOCIAL_BUTTON, "Interface\\FriendsFrame\\UI-Toast-ChatInviteIcon", function()
		if F.CombatError() then return end
		ToggleFriendsFrame(FRIEND_TAB_FRIENDS)
	end)

	CreateIconButton(rootDescription, GUILD, "Interface\\GossipFrame\\TabardGossipIcon", function()
		if F.CombatError() then return end
		ToggleFriendsFrame(FRIEND_TAB_GUILD)
	end)

	rootDescription:QueueSpacer()
	CreateMenuTitle(rootDescription, OTHER)

	CreateIconButton(rootDescription, BACKPACK_TOOLTIP, "Interface\\MINIMAP\\TRACKING\\Banker", function()
		if F.CombatError() then return end
		ToggleAllBags()
	end)

	if G.IsTBC or HonorSystemEnabled() then
		CreateIconButton(rootDescription, PLAYER_V_PLAYER, "Interface\\MINIMAP\\TRACKING\\BattleMaster", function()
			if F.CombatError() then return end
			ToggleCharacter(G.IsTBC and "PVPFrame" or "HonorFrame")
		end)
	end

	CreateIconButton(rootDescription, RAID, "Interface\\Buttons\\UI-GuildButton-PublicNote-Up", function()
		if F.CombatError() then return end
		ToggleFriendsFrame(FRIEND_TAB_RAID)
	end)

	CreateIconButton(rootDescription, GM_EMAIL_NAME, "Interface\\CHATFRAME\\UI-ChatIcon-Blizz", function()
		if F.CombatError() then return end
		ToggleHelpFrame()
	end)

	-- 舊圖示："Interface\\CHATFRAME\\UI-ChatIcon-ArmoryChat-AwayMobile"
	CreateIconButton(rootDescription, CHANNEL, "chatframe-button-icon-voicechat", function()
		if F.CombatError() then return end
		ToggleChannelFrame()
	end)

	CreateIconButton(rootDescription, STOPWATCH_TITLE, "Interface\\Icons\\INV_Misc_PocketWatch_01", function()
		if F.CombatError() then return end
		TimeManager_LoadUI()
		TimeManager_Toggle()
	end)

	CreateIconButton(rootDescription, BATTLEFIELD_MINIMAP, "Interface\\ICONS\\INV_Misc_Map_01", function()
		if F.CombatError() then return end
		ToggleBattlefieldMap()
	end)

	rootDescription:QueueSpacer()
	CreateMenuTitle(rootDescription, ADDONS)

	rootDescription:CreateButton("|cff00FFFF"..L.ToggleConfig.."|r", function()
		F.CreateEKMOptions()
	end):AddInitializer(function(button)
		local icon = button:AttachTexture()
		icon:SetColorTexture(0, 1, 1, 1)
		icon:SetSize(12, 12)
		icon:SetPoint("LEFT", 4, 0)
		button.fontString:SetPoint("LEFT", icon, "RIGHT", 8, 0)
	end)

	rootDescription:CreateButton("|cff999999"..RELOADUI.."|r", function()
		ReloadUI()
	end)
end

local function OnEvent()
	if not F.GetEKMOption("ClickMenu") then return end

	Minimap:SetScript("OnMouseUp", function(self, button)
		if IsAltKeyDown() then return end

		if button == "RightButton" then
			MenuUtil.CreateContextMenu(self, GenerateMenu)
		elseif button == "MiddleButton" and G.IsTBC then
			MiniMapTrackingButton:OpenMenu()
		else
			Minimap_OnClick(self)
		end
	end)
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", OnEvent)
