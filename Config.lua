----------------------
-- Dont touch this! --
----------------------

local EKMinimap, ns = ...
	ns[1] = {} -- C, config
	ns[2] = {} -- G, globals (Optionnal)

local C, G = unpack(select(2, ...))
	
	G.Ccolors = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[select(2,UnitClass("player"))] -- class color / 職業顏色

local MediaFolder = "Interface\\AddOns\\EKMinimap\\Media\\"

------------
-- Golbal --
------------

	C.ObjectTracker = true	-- Style Objetc frame / 啟用追蹤美化
	C.ClickMenu = true		-- Minimap clickmenu / 啟用點擊選單
	
	-- slash cmd / 指令
	-- /rm 重置小地圖位置 / reset minimap frame position
	-- /ro 重置任務列表位置 / reset object frame position
	
	-- 小地圖中鍵追蹤選單，右鍵微型選單 / middle button click: tracking menu; right click: micro menu
	-- 滾輪縮放區域，alt+滾輪縮放大小 / scroll to scale zone, alt+scroll to scale minimap frame
	-- alt+右鍵按住移動 / alt+right click to drag
	-- alt分享ctrl放棄 / alt click title share quest, ctrl click abandon quest
	
-------------
-- Texture --
-------------

	G.Mask = MediaFolder.."mask.blp"
	G.Tex = "Interface\\Buttons\\WHITE8x8"
	G.Glow = MediaFolder.."glow.tga"
	G.Mail = "Interface\\MINIMAP\\TRACKING\\Mailbox.blp"  -- "Interface\\HELPFRAME\\ReportLagIcon-Mail.blp"
	G.Diff = MediaFolder.."difficulty.tga"
	G.Report = "Interface\\HelpFrame\\HelpIcon-ReportLag.blp"

-----------
-- Fonts --
-----------

	G.font = STANDARD_TEXT_FONT		-- 字體 / font
	-- minimap / 小地圖字型
	G.fontSize = 14
	G.fontFlag = "THINOUTLINE"
	-- objectframe / 追蹤字型
	G.obfontSize = 18
	G.obfontFlag = "OUTLINE"

----------------------
-- Minimap settings --
----------------------

	C.Scale = 1  								-- 縮放 / Scale
	C.Size = 160  								-- 縮放 / Scale
	C.Point = {"TOPLEFT", UIParent, 10, -10}	-- 位置 / Position
	--C.Point = {"TOPRIGHT", UIParent, -10, -10}-- 位置 / Position

----------------------
-- Object settings --
----------------------

	C.OTF = {"TOPRIGHT", UIParent, "TOPRIGHT", -100, -170}
	C.height = 600					-- 追蹤框高度 / Object frame hight
	C.star = true					-- 項目星型標記 / show quest line desh as a star. maybe you'll get "?" if your font dosnt support this.
	
-------------
-- Credits --
-------------

	-- Felix S., sakaras, ape47, iMinimap by Chiril, ooMinimap by Ooglogput, intMinimap by Int0xMonkey
	-- DifficultyID list
	-- https://wow.gamepedia.com/DifficultyID
	-- rStatusButton by zork
	-- https://www.wowinterface.com/downloads/info24772-rStatusButton.html
	-- Hide order hall bar
	-- https://github.com/destroyerdust/Class-Hall