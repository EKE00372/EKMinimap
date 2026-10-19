----------------------
-- Dont touch this! --
----------------------

local addon, ns = ...
	ns[1] = {} -- C, config
	ns[2] = {} -- F, functions, constants, variables
	ns[3] = {} -- G, globals (Optionnal)
	ns[4] = {} -- L, localization

local C, F, G, L = unpack(ns)
local MediaFolder = "Interface\\AddOns\\EKMinimap\\Media\\"

G.IsTBC = (WOW_PROJECT_ID == WOW_PROJECT_BURNING_CRUSADE_CLASSIC)

-------------------
-- Golbal / 全局 --
-------------------

	G.Ccolors = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[select(2, UnitClass("player"))] -- Class color / 職業顏色
	G.Tex = "Interface\\Buttons\\WHITE8x8"
	G.Glow = MediaFolder.."glow.tga"
	G.Mail = "Interface\\MINIMAP\\TRACKING\\Mailbox.blp"
	G.Report = "Interface\\HelpFrame\\HelpIcon-ReportLag.blp"

	G.Question = "Interface\\HelpFrame\\HelpIcon-KnowledgeBase"
	G.Info = "Interface\\FriendsFrame\\InformationIcon"

	-- 字體 / font
	G.font = STANDARD_TEXT_FONT		-- 字型 / Font
	G.fontSize = 12					-- 大小 / size
	G.fontFlag = "OUTLINE"		-- 描邊 / outline

-------------------------
-- Settings / 預設設定 --
-------------------------

	F.AnchorOptions = { "TOP", "TOPLEFT", "TOPRIGHT", "CENTER", "LEFT", "BOTTOM", "BOTTOMLEFT", "BOTTOMRIGHT", "RIGHT" }
	F.GUIOptionGroups = {
		{ label = "QuestWatchOpt", column = 2, y = 24, options = {
			{ type = "toggle", key = "QuestWatchStyle", label = "QuestWatchStyleOpt", default = true },
			{ type = "toggle", key = "QuestWatchStar", label = "QuestWatchStarOpt", default = true },
			{ type = "toggle", key = "QuestWatchClick", label = "QuestWatchClickOpt", default = true },
			{ type = "dropdown", key = "QuestWatchAnchor", label = "AnchorOpt", default = "TOPRIGHT", width = 120, height = 20 },
			{ type = "edit", key = "QuestWatchX", label = "XOpt", default = -170, width = 50, height = 20, rowColumn = 1 },
			{ type = "edit", key = "QuestWatchY", label = "YOpt", default = -230, width = 50, height = 20, rowColumn = 2 },
		} },
		{ name = WORLDMAP_BUTTON, column = 1, y = 232, options = {
			{ type = "toggle", key = "WorldMapStyle", label = "WorldMapStyleOpt", tooltip = "WMFTip", default = true },
			{ type = "toggle", key = "WorldMapFade", label = "fadeOpt", default = true },
			{ type = "slider", key = "WorldMapScale", label = "SizeOpt", default = .8, min = 4, max = 12, step = 1, coeff = .1 },
			{ type = "slider", key = "WorldMapAlpha", label = "AlphaOpt", default = .5, min = 0, max = 10, step = 1, coeff = .1 },
		} },
		{ name = MINIMAP_LABEL, column = 1, y = 24, options = {
			{ type = "toggle", key = "ClickMenu", label = "ClickMenuOpt", default = true },
			{ type = "toggle", key = "CharacterIcon", label = "IconOpt", default = true },
			{ type = "toggle", key = "HoverClock", label = "HoverClockOpt", default = true },
			{ type = "dropdown", key = "MinimapAnchor", label = "AnchorOpt", default = "TOPRIGHT", width = 120, height = 20 },
			{ type = "edit", key = "MinimapX", label = "XOpt", default = -10, width = 50, height = 20, rowColumn = 1 },
			{ type = "edit", key = "MinimapY", label = "YOpt", default = -10, width = 50, height = 20, rowColumn = 2 },
			{ type = "slider", key = "MinimapScale", label = "SizeOpt", default = 1.2, min = 5, max = 20, step = 1, coeff = .1 },
		} },
	}

	local positionOptions = {
		MinimapAnchor = true, MinimapX = true, MinimapY = true, MinimapScale = true,
		QuestWatchAnchor = true, QuestWatchX = true, QuestWatchY = true,
	}
	local activeOptions = {}
	C.defaultSettings = {}
	for _, group in ipairs(F.GUIOptionGroups) do
		for _, option in ipairs(group.options) do C.defaultSettings[option.key] = option.default end
	end
	F.GetEKMOption = function(key) return activeOptions[key] end
	F.GetSavedEKMOption = function(key) return EKMinimapDB[key] end
	F.SetEKMOption = function(key, value) EKMinimapDB[key] = value end
	-- 位置與小地圖縮放由套用生效，不列入重載提示。
	F.HasPendingEKMChanges = function()
		for key in pairs(C.defaultSettings) do
			if not positionOptions[key] and EKMinimapDB[key] ~= activeOptions[key] then return true end
		end
		return false
	end
	-- 套用只更新小地圖尺寸／位置與追蹤框位置；功能開關及世界地圖仍等重載。
	F.ApplyEKMPositionSettings = function()
		for key in pairs(positionOptions) do
			activeOptions[key] = EKMinimapDB[key]
		end
	end
	local dbLoader = CreateFrame("Frame")
	dbLoader:RegisterEvent("ADDON_LOADED")
	dbLoader:SetScript("OnEvent", function(self, event, name)
		if name ~= addon then return end
		if type(EKMinimapDB) ~= "table" then EKMinimapDB = {} end
		-- 只搬移舊預設位置一次；自訂座標與之後手動選回的座標都保留。
		if EKMinimapDB.TrackerLayoutVersion == nil or EKMinimapDB.TrackerLayoutVersion == 1 then
			local oldDefaultY = EKMinimapDB.TrackerLayoutVersion == 1 and -240 or -220
			if EKMinimapDB.QuestWatchY == oldDefaultY
				and (EKMinimapDB.QuestWatchAnchor == nil or EKMinimapDB.QuestWatchAnchor == "TOPRIGHT")
				and (EKMinimapDB.QuestWatchX == nil or EKMinimapDB.QuestWatchX == -170) then
				EKMinimapDB.QuestWatchY = -230
			end
			EKMinimapDB.TrackerLayoutVersion = 2
		end
		for _, group in ipairs(F.GUIOptionGroups) do
			for _, option in ipairs(group.options) do
				local value = EKMinimapDB[option.key]
				local valid = (type(value) == type(option.default))
				if valid and type(value) == "number" then
					valid = (value == value and value > -math.huge and value < math.huge)
					if valid and option.type == "slider" then
						valid = (value >= option.min * option.coeff and value <= option.max * option.coeff)
					end
				elseif valid and option.type == "dropdown" then
					valid = tContains(F.AnchorOptions, value)
				end
				if not valid then EKMinimapDB[option.key] = option.default end
				activeOptions[option.key] = EKMinimapDB[option.key]
			end
		end
		for key in pairs(EKMinimapDB) do
			if C.defaultSettings[key] == nil and key ~= "TrackerLayoutVersion" then EKMinimapDB[key] = nil end
		end
		self:UnregisterEvent(event)
		self:SetScript("OnEvent", nil)
	end)

----------------------
-- Functions / 功能 --
----------------------

F.CombatError = function()
	if InCombatLockdown() then
		UIErrorsFrame:AddMessage("|cffffff00"..ERR_NOT_IN_COMBAT)
		return true
	end
	return false
end

F.CreateFS = function(parent, text, justify, anchor, x, y, size)
	local fs = parent:CreateFontString(nil, "OVERLAY")
	fs:SetFont(G.font, size or G.fontSize, G.fontFlag)
	fs:SetText(text)
	fs:SetShadowOffset(0, 0)
	fs:SetWordWrap(false)
	fs:SetJustifyH(justify)
	if anchor and x and y then
		fs:SetPoint(anchor, x, y)
	else
		fs:SetPoint("CENTER", 0, 0)
	end

	return fs
end

F.CreateBG = function(parent, size, offset, a)
	local frame = parent
	if parent:GetObjectType() == "Texture" then
		frame = parent:GetParent()
	end
	local lvl = frame:GetFrameLevel()

	local bg = CreateFrame("Frame", nil, frame, "BackdropTemplate")
	bg:ClearAllPoints()
	bg:SetPoint("TOPLEFT", parent, -size, size)
	bg:SetPoint("BOTTOMRIGHT", parent, size, -size)
	bg:SetFrameLevel(lvl == 0 and 0 or lvl - 1)
	bg:SetBackdrop({
			bgFile = G.Tex,
			tile = false,
			edgeFile = G.Glow,	-- 陰影邊框
			edgeSize = offset,	-- 邊框大小
			insets = { left = offset, right = offset, top = offset, bottom = offset },
		})
	bg:SetBackdropColor(0, 0, 0, a)
	bg:SetBackdropBorderColor(0, 0, 0, 1)

	return bg
end

--------------------
-- Credits / 銘謝 --
--------------------

	-- Felix S., sakaras, ape47
	-- iMinimap by Chiril, ooMinimap by Ooglogput, intMinimap by Int0xMonkey
	-- NeavUI by Neal
	-- https://www.wowinterface.com/downloads/info13981-NeavUI.html
	-- ClickMenu by 10leej
	-- https://www.wowinterface.com/downloads/info22660-ClickMenu.html
	-- rQuestWatchTracker by zork
	-- https://www.wowinterface.com/downloads/info18322-rQuestWatchTracker.html
