local addon, ns = ...
local C, F, G, L = unpack(ns)
local Minimap = Minimap

-- 標題
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

-- 圖示
local function CreateIconButton(rootDescription, text, icon, callback)
	local atlasInfo = type(icon) == "string" and C_Texture.GetAtlasInfo(icon)
	local markup
	if atlasInfo then
		markup = CreateAtlasMarkup(icon, 16, 16)
	else
		markup = CreateSimpleTextureMarkup(icon, 16, 16)
	end
	rootDescription:CreateButton(markup.." "..text, callback)
end

-- 選單
local function GenerateMenu(_, rootDescription)
	CreateMenuTitle(rootDescription, MAINMENU_BUTTON)

	-- 角色："Interface\\PaperDollInfoFrame\\UI-EquipmentManager-Toggle"
	CreateIconButton(rootDescription, CHARACTER_BUTTON, "Interface\\ICONS\\INV_Chest_Plate01", function()
		if F.CombatError() then return end
		ToggleCharacter("PaperDollFrame")
	end)

	-- 法術書："Interface\\MINIMAP\\TRACKING\\Class"
	CreateIconButton(rootDescription, SPELLBOOK_ABILITIES_BUTTON, "Interface\\ICONS\\INV_Misc_Book_09", function()
		if F.CombatError() then return end
		ToggleSpellBook(BOOKTYPE_SPELL)
	end)

	-- 沿各版本原生天賦入口的可用條件。
	local canUseTalents
	if G.IsMists then
		canUseTalents = C_SpecializationInfo.CanPlayerUseTalentSpecUI()
	else
		canUseTalents = C_SpecializationInfo.CanPlayerUseTalentUI()
	end
	if canUseTalents then
		CreateIconButton(rootDescription, TALENTS, "Interface\\MINIMAP\\TRACKING\\Ammunition", function()
			if F.CombatError() then return end
			ToggleTalentFrame()
		end)
	end

	CreateIconButton(rootDescription, ACHIEVEMENT_BUTTON, "Interface\\ACHIEVEMENTFRAME\\UI-Achievement-Shield", function()
		if F.CombatError() then return end
		ToggleAchievementFrame()
	end)

	CreateIconButton(rootDescription, QUESTLOG_BUTTON, "Interface\\GossipFrame\\ActiveQuestIcon", function()
		if F.CombatError() then return end
		ToggleQuestLog()
	end)

	CreateIconButton(rootDescription, WORLD_MAP, "Interface\\WorldMap\\UI-World-Icon", function()
		if F.CombatError() then return end
		ToggleWorldMap()
	end)

	-- 公會與社群："Interface\\GossipFrame\\TabardGossipIcon"
	CreateIconButton(rootDescription, CommunitiesFrame_IsEnabled() and GUILD_AND_COMMUNITIES or GUILD, "UI-HUD-MicroMenu-GuildCommunities-Up", function()
		if F.CombatError() then return end
		ToggleGuildFrame()
	end)

	CreateIconButton(rootDescription, SOCIAL_BUTTON, "Interface\\FriendsFrame\\UI-Toast-ChatInviteIcon", function()
		if F.CombatError() then return end
		ToggleFriendsFrame(FRIEND_TAB_FRIENDS)
	end)

	-- 組隊："Interface\\TUTORIALFRAME\\UI-TutorialFrame-AttackCursor"
	CreateIconButton(rootDescription, LFG_BUTTON, "friends-icon-eye", function()
		if F.CombatError() then return end
		PVEFrame_ToggleFrame("GroupFinderFrame")
	end)

	CreateIconButton(rootDescription, PLAYER_V_PLAYER, "Interface\\MINIMAP\\TRACKING\\BattleMaster", function()
		if F.CombatError() then return end
		TogglePVPFrame()
	end)

	CreateIconButton(rootDescription, COLLECTIONS, "Interface\\CURSOR\\Crosshair\\WildPetCapturable", function()
		if F.CombatError() then return end
		ToggleCollectionsJournal()
	end)

	if CanShowEncounterJournal() then
		CreateIconButton(rootDescription, ENCOUNTER_JOURNAL, "Interface\\ENCOUNTERJOURNAL\\UI-EJ-HeroicTextIcon", function()
			if F.CombatError() then return end
			ToggleEncounterJournal()
		end)
	end

	rootDescription:QueueSpacer()
	CreateMenuTitle(rootDescription, OTHER)

	CreateIconButton(rootDescription, BACKPACK_TOOLTIP, "Interface\\MINIMAP\\TRACKING\\Banker", function()
		if F.CombatError() then return end
		ToggleAllBags()
	end)

	CreateIconButton(rootDescription, RAID, "Interface\\Buttons\\UI-GuildButton-PublicNote-Up", function()
		if F.CombatError() then return end
		ToggleRaidFrame()
	end)

	CreateIconButton(rootDescription, GM_EMAIL_NAME, "Interface\\CHATFRAME\\UI-ChatIcon-Blizz", function()
		if F.CombatError() then return end
		ToggleHelpFrame()
	end)

	-- 頻道："Interface\\CHATFRAME\\UI-ChatIcon-ArmoryChat-AwayMobile"
	CreateIconButton(rootDescription, CHANNEL, "chatframe-button-icon-voicechat", function()
		if F.CombatError() then return end
		ToggleChannelFrame()
	end)

	CreateIconButton(rootDescription, STOPWATCH_TITLE, "Interface\\Icons\\INV_Misc_PocketWatch_01", function()
		if F.CombatError() then return end
		TimeManager_LoadUI()
		TimeManager_Toggle()
	end)

	CreateIconButton(rootDescription, L.Calendar, "ui-hud-calendar-1-up", function()
		if F.CombatError() then return end
		ToggleCalendar()
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

local function OnEvent(self)
	self:UnregisterEvent("PLAYER_LOGIN")
	if not F.GetEKMOption("ClickMenu") then return end

	Minimap:SetScript("OnMouseUp", function(self, button)
		if IsAltKeyDown() then return end

		if button == "RightButton" then
			MenuUtil.CreateContextMenu(self, GenerateMenu)
		elseif button == "MiddleButton" then
			MiniMapTrackingButton:OpenMenu()
		else
			Minimap_OnClick(self)
		end
	end)
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", OnEvent)
