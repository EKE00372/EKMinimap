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

	-- Texture
	G.Ccolors = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[select(2, UnitClass("player"))] -- Class color / 職業顏色
	G.Tex = "Interface\\Buttons\\WHITE8x8"
	G.Glow = MediaFolder.."glow.tga"
	G.Mail = "Interface\\MINIMAP\\TRACKING\\Mailbox.blp"
	G.Report = "Interface\\HelpFrame\\HelpIcon-ReportLag.blp"
	
	-- 字體 / font
	G.font = STANDARD_TEXT_FONT		-- 字型 / Font
	G.fontSize = 14					-- 大小 / size
	G.fontFlag = "THINOUTLINE"		-- 描邊 / outline

---------------------
-- Settings / 設定 --
---------------------

	-- Minimap
	C.MinimapScale = 1.2		-- Size / 尺寸
	C.ClickMenu = true			-- Enable Minimap Click Menu / 啟用右鍵微型選單
	C.CharacterIcon = true		-- Enable Character Icon / 啟用角色資訊圖示
	
	-- Quest Watch
	C.QuestWatchStyle = true	-- Enable Quest Watch Frame Style / 啟用任務追蹤美化
	C.QuestWatchClick = true	-- Make Quest Watch Frame Click-able / 使任務可點擊
	C.QuestWatchStar = true		-- show Quest Line Dash as A Star. / 項目星型標記
	-- ##NOTE: maybe you'll get "?" if your font dosn't support this.
	
	-- World Map
	C.WorldMapStyle = true		-- Enable Map fadeout and custom size / 啟用大地圖增強
	C.WorldMapScale = 0.6		-- 縮放 / Scale
	C.WorldMapFade = true		-- 移動時淡出 / Fadeout when moving
	C.WorldMapAlpha = 0.5		-- 淡出透明度 / Fadeout alpha
	
	-- Position
	C.MinimapPoint = {"TOPRIGHT", UIParent, -10, -10}					-- Minimap
	C.QuestWatchPoint = {"TOPRIGHT", UIParent, "TOPRIGHT", -170, -220} 	-- QuestWatch


	if GetLocale() == "zhTW" then
		L.Next = "下一級："
	elseif GetLocale() == "zhCN" then
		L.Next = "下一级："
	else
		L.Next = "Next: "
	end
----------------------
-- Functions / 功能 --
----------------------

F.CreateFS = function(parent, text, justify, anchor, x, y)
	local fs = parent:CreateFontString(nil, "OVERLAY")
	fs:SetFont(G.font, G.fontSize, G.fontFlag)
	fs:SetText(text)
	fs:SetShadowOffset(0, 0)
	fs:SetWordWrap(false)
	fs:SetJustifyH(justify)
	if anchor and x and y then
		fs:SetPoint(anchor, x, y)
	else
		fs:SetPoint("CENTER", 1, 0)
	end
	
	return fs
end

F.CreateBG = function(parent, size, offset, a)
	local frame = parent
	if parent:GetObjectType() == "Texture" then
		frame = parent:GetParent()
	end
	local lvl = frame:GetFrameLevel()

	local bg = CreateFrame("Frame", nil, frame)
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