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

-------------------
-- Golbal / 全局 --
-------------------

	G.Ccolors = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[select(2, UnitClass("player"))] -- Class color / 職業顏色
	G.ErrColor = "|cffffff00"
	G.Tex = "Interface\\Buttons\\WHITE8x8"
	G.Glow = MediaFolder.."glow.tga"
	G.Diff = MediaFolder.."difficulty.tga"
	G.Mail = "Interface\\MINIMAP\\TRACKING\\Mailbox.blp"
	G.Report = "Interface\\HelpFrame\\HelpIcon-ReportLag.blp"
	
	G.Question = "Interface\\HelpFrame\\HelpIcon-KnowledgeBase"
	G.Info = "Interface\\FriendsFrame\\InformationIcon"
	
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

	C.defaultSettings = {
		["MinimapScale"] = 1,
		["MinimapAnchor"] = "TOPLEFT",
		["MinimapY"] = -10,
		["MinimapX"] = 10,
		["ClickMenu"] = true,
		["HoverClock"] = true,
		["CharacterIcon"] = true,
		["Tracking"] = true,
		["QueueStatus"] = true,
	}

----------------------
-- Functions / 功能 --
----------------------

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

	local bg = CreateFrame("Frame", nil, frame, BackdropTemplateMixin and "BackdropTemplate")
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

F.Dummy = function() end

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