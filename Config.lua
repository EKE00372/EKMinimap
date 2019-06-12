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

	C.objectFrame = true	-- Style Objetc frame
	C.clickMenu = true		-- Minimap clickmenu
	
	-- /rm 重置小地圖位置 / reset minimap frame position
	-- /ro 重置任務列表位置 / reset object frame position
	
	-- 小地圖中鍵追蹤選單，右鍵微型選單 / middle button click: tracking menu; right click: micro menu
	-- alt+右鍵按住移動 / alt+right click to drag
	-- alt分享ctrl放棄 / alt click title share quest, ctrl abandon quest
	
-------------
-- Texture --
-------------

	G.Tex = "Interface\\Buttons\\WHITE8x8"
	G.glow = MediaFolder.."glow.tga"
	G.mail = MediaFolder.."mail.tga"
	G.diff = MediaFolder.."difficulty.tga"
	G.report = "Interface\\HelpFrame\\HelpIcon-ReportLag.blp"

-----------
-- Fonts --
-----------

	G.font = STANDARD_TEXT_FONT		-- 字體 / font (or use"GameFontHighlight:GetFont()"to get default game font
	-- minimap
	G.fontSize = 14
	G.fontFlag = "THINOUTLINE"
	-- objectframe
	G.obfontSize = 18
	G.obfontFlag = "OUTLINE"

----------------------
-- Minimap settings --
----------------------

	C.scale = 1  					-- 縮放 / Scale
	C.anchor = "TOPLEFT"			-- 錨點 / Anchor "TOPLEFT" "TOPRIGHT" "BOTTOMLEFT" etc.
	C.Point = {10, -20}				-- 位置 / Position
	C.announce = false  			-- 行事曆有邀請時高亮邊框/show yellow border when get invite

----------------------
-- Object settings --
----------------------

	C.ObFrame = {"TOPRIGHT", UIParent, "TOPRIGHT", -100, -170}
	C.height = 600
	C.star = true					-- show quest line desh as a star. maybe you'll get "?" if your font dosnt support this.
	
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