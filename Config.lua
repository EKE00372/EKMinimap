local EKMinimap, ns = ...
ns[1] = {} -- C, config
ns[2] = {} -- G, globals (Optionnal)

local C, G = unpack(select(2, ...))

-- alt+右鍵按住標題移動任務，/rm 重置小地圖位置，/ro重置任務列表位置，alt分享ctrl放棄
-- alt+right click to drag, /rm reset minimap position, /ro reset quset position, alt click title share quest, ctrl abandon quest

-- [[ Global ]] --

C.objectFrame = true
C.clickMenu = true

-- [[ Textures ]] --

G.Mask = "Interface\\Buttons\\WHITE8x8"
G.Tex = "Interface\\Buttons\\WHITE8x8"
G.glow = "Interface\\addons\\EKMinimap\\Media\\glow"
G.mail = "Interface\\AddOns\\EKMinimap\\Media\\mail.tga"
G.report = "Interface\\HelpFrame\\HelpIcon-ReportLag.blp"
G.diff = "Interface\\AddOns\\EKMinimap\\Media\\difficulty.tga"
G.Ccolors = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[select(2,UnitClass("player"))] -- class color / 職業顏色

-- [[ Fonts ]] --

G.font = STANDARD_TEXT_FONT
-- minimap
G.fontSize = 14
G.fontFlag = "THINOUTLINE"
-- objectframe
G.obfontSize = 18
G.obfontFlag = "OUTLINE"

-- [[ Config ]] --

-- minimap
C.scale = 1  					-- 縮放/Scale
C.anchor = "TOPLEFT"
C.Point = {10, -20}
C.announce = false  			-- 行事曆有邀請時高亮邊框/show yellow border when get invite
-- objectframe
C.height = 600
C.star = true					-- show quest line desh as a star. maybe you'll get "?" if your font dosnt support this.