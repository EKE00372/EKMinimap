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

	G.IsForever = LE_EXPANSION_LEVEL_CURRENT == LE_EXPANSION_CLASSIC
	
-------------------
-- Golbal / 全局 --
-------------------

	G.Ccolors = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[select(2, UnitClass("player"))] -- Class color / 職業顏色
	G.ErrColor = "|cffffff00"
	G.Tex = "Interface\\Buttons\\WHITE8x8"
	G.Glow = MediaFolder.."glow.tga"
	G.Diff = MediaFolder.."difficulty.tga"
	--G.Mail = "Interface\\MINIMAP\\TRACKING\\Mailbox.blp"
	G.Report = "Interface\\HelpFrame\\HelpIcon-ReportLag.blp"
	
	G.Question = "Interface\\HelpFrame\\HelpIcon-KnowledgeBase"
	G.Info = "Interface\\FriendsFrame\\InformationIcon"
	G.MiddleButton = " |TInterface\\TUTORIALFRAME\\UI-TUTORIAL-FRAME:14:10:0:-1:512:512:12:66:127:204|t "
	G.RightButton = " |TInterface\\TUTORIALFRAME\\UI-TUTORIAL-FRAME:14:10:0:-1:512:512:12:66:333:411|t "
	
	-- 字體 / font
	G.font = STANDARD_TEXT_FONT		-- 字型 / Font
	-- minimap / 小地圖字型
	G.fontSize = 12
	G.fontFlag = "OUTLINE"
	-- objectframe / 追蹤字型
	G.obfontSize = 18
	G.obfontFlag = "OUTLINE"

-------------------------
-- Settings / 預設設定 --
-------------------------

	-- 選項、預設值與 GUI 順序共用一份定義；label／tooltip 在建立 GUI 時解析。
	F.GUIOptionGroups = {
		{
			name = MINIMAP_LABEL,
			options = {
				{ type = "toggle", key = "ClickMenu", label = "ClickMenuOpt", tooltip = "MenuTip", default = true },
				{ type = "toggle", key = "HoverClock", label = "HoverClockOpt", default = false },
				{ type = "toggle", key = "CharacterIcon", label = "IconOpt", tooltip = "IconTip", default = true },
				{ type = "toggle", key = "Tracking", label = "TrackingOpt", default = true },
				{ type = "toggle", key = "QueueStatus", label = "QueueOpt", default = true },
				{ type = "dropdown", key = "MinimapAnchor", label = "AnchorOpt", default = "TOPLEFT", width = 120, height = 20 },
				{ type = "edit", key = "MinimapX", label = "XOpt", default = 10, width = 120, height = 20 },
				{ type = "edit", key = "MinimapY", label = "YOpt", default = -10, width = 120, height = 20 },
				{ type = "slider", key = "MinimapScale", label = "SizeOpt", default = 1, min = 5, max = 20, step = 1, coeff = .1 },
			},
		},
		{
			name = OTHER,
			options = {
				{ type = "toggle", key = "VehicleSeat", label = "VehicleSeatOpt", default = true },
				{ type = "toggle", key = "Durability", label = "DurabilityOpt", default = true },
				{ type = "toggle", key = "TrackerStyle", label = "TrackerStyleOpt", default = true },
				{ type = "toggle", key = "AutoCollapse", label = "AutoCollapseOpt", tooltip = "CollapseTip", default = false, hidden = G.IsForever },
			},
		},
	}

	local activeOptions = {}
	C.defaultSettings = {}
	for _, group in ipairs(F.GUIOptionGroups) do
		for _, option in ipairs(group.options) do
			C.defaultSettings[option.key] = option.default
		end
	end

	-- 功能模組只讀本次登入的快照，GUI 寫入不會半途改變模組狀態。
	F.GetEKMOption = function(key)
		return activeOptions[key]
	end
	F.GetSavedEKMOption = function(key)
		return EKMinimapDB[key]
	end
	F.SetEKMOption = function(key, value)
		EKMinimapDB[key] = value
	end

	F.HasPendingEKMChanges = function()
		for key in pairs(C.defaultSettings) do
			if EKMinimapDB[key] ~= activeOptions[key] then return true end
		end
		return false
	end

	-- 保留尺寸座標的單獨套用；其他功能開關仍等重載。
	F.ApplyEKMPositionSettings = function()
		for _, key in ipairs({ "MinimapAnchor", "MinimapX", "MinimapY", "MinimapScale" }) do
			activeOptions[key] = EKMinimapDB[key]
		end
	end

	local dbLoader = CreateFrame("Frame")
	dbLoader:RegisterEvent("ADDON_LOADED")
	dbLoader:SetScript("OnEvent", function(self, event, name)
		if name ~= addon then return end
		if type(EKMinimapDB) ~= "table" then EKMinimapDB = {} end
		for key, value in pairs(C.defaultSettings) do
			if EKMinimapDB[key] == nil then EKMinimapDB[key] = value end
			activeOptions[key] = EKMinimapDB[key]
		end
		for key in pairs(EKMinimapDB) do
			if C.defaultSettings[key] == nil then EKMinimapDB[key] = nil end
		end
		self:UnregisterEvent(event)
		self:SetScript("OnEvent", nil)
	end)

----------------------
-- Functions / 功能 --
----------------------

-- 戰鬥時提示並回傳 true，讓呼叫端停止操作。
F.CombatError = function()
	if InCombatLockdown() then
		UIErrorsFrame:AddMessage(G.ErrColor..ERR_NOT_IN_COMBAT)
		return true
	end
	return false
end

F.CreateFS = function(parent, text, fontsize, justify, anchor, x, y)
	local fs = parent:CreateFontString(nil, "OVERLAY")
	fs:SetFont(G.font, fontsize, G.fontFlag)
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
	-- https://www.wowinterface.com/downloads/info13981-NeavUI.html#info
	-- ClickMenu by 10leej
	-- https://www.wowinterface.com/downloads/info22660-ClickMenu.html
	-- rQuestWatchTracker by zork
	-- https://www.wowinterface.com/downloads/info18322-rQuestWatchTracker.html