----------------------
-- Dont touch this! --
----------------------

local addon, ns = ...
	ns[1] = {} -- C, config
	ns[2] = {} -- F, functions, constants, variables
	ns[3] = {} -- G, globals (Optionnal)
	ns[4] = {} -- L, localization
	
	if EKPlateDB == nil then EKPlateDB = {} end

local C, F, G, L = unpack(ns)
	
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

	C.Size = 160  								-- Size
	C.Point = {"TOPLEFT", UIParent, 10, -10}	-- 位置 / Position
	--C.Point = {"TOPRIGHT", UIParent, -10, -10}-- 位置 / Position

----------------------
-- Object settings --
----------------------

	C.OTF = {"TOPRIGHT", UIParent, "TOPRIGHT", -100, -170}
	C.Height = 600					-- 追蹤框高度 / Object frame hight
	C.Star = true					-- 項目星型標記 / show quest line desh as a star. maybe you'll get "?" if your font dosnt support this.
	
if GetLocale() == "zhTW" then
	L.ClickMenuOpt = "啟用小地圖點擊選單"
	L.MinimapSizeOpt = "小地圖尺寸"
	L.ObjectiveStarOpt = "使用 ★ 星星標記項目"
	L.ObjectTrackerOpt = "啟用追蹤框美化"
	L.ObjectHeightOpt = "追蹤框高度"
elseif GetLocale() == "zhTW" then
	L.ClickMenuOpt = "启用小地图点击菜单"
	L.MinimapSizeOpt = "小地图尺寸"
	L.ObjectiveStarOpt = "使用 ★ 星星标记项目"
	L.ObjectTrackerOpt = "启用追踪框美化"
	L.ObjectHeightOpt = "追踪框高度"
else
	L.ClickMenuOpt = "Enable minimap click menu"
	L.MinimapSizeOpt = "Minimap size"
	L.ObjectiveStarOpt = "Mark objective as ★ star"
	L.ObjectTrackerOpt = "Enable objective track style"
	L.ObjectHeightOpt = "Objective tracker height"
end
--[[
local EKPlateDB = {

}]]--
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
	-- NeavUI by Neal: https://www.wowinterface.com/downloads/info13981-NeavUI.html#info
	-- ClickMenu by 10leej: https://www.wowinterface.com/downloads/info22660-ClickMenu.html

--====================================================--
-----------------    [[ Function ]]    -----------------
--====================================================--

-- Frame Text
local function CreateFS(parent, text, anchor, x, y)
	--local function CreateFS(parent, text, anchor, x, y, r, g, b)
	local fs = parent:CreateFontString(nil, "OVERLAY")
	fs:SetFont(G.font, G.fontSize, G.fontFlag)
	fs:SetText(text)
	fs:SetWordWrap(false)
	if anchor and x and y then
		fs:SetPoint(anchor, x, y)
	else
		fs:SetPoint("CENTER", 1, 0)
	end
	
	return fs
end

local function CreateBG(parent, offset)
	local frame = parent
	if parent:GetObjectType() == "Texture" then frame = parent:GetParent() end
	offset = offset or 3
	local lvl = frame:GetFrameLevel()

	local bg = CreateFrame("Frame", nil, frame)
	bg:SetPoint("TOPLEFT", parent, -offset, offset)
	bg:SetPoint("BOTTOMRIGHT", parent, offset, -offset)
	bg:SetFrameLevel(lvl == 0 and 0 or lvl - 1)
	
	return bg
end

local function CreateButton(self, width, height, text)
	local bu = CreateFrame("Button", nil, self)
	bu:SetSize(width, height)
	bu:SetBackdrop({
		bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
		edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
		edgeSize = 1,
	})
	bu:SetBackdropColor(0, 0, 0, .3)
	bu:SetBackdropBorderColor(0, 0, 0)
	bu:SetNormalTexture("")
	bu:SetHighlightTexture("")
	bu:SetPushedTexture("")
	bu:SetDisabledTexture("")
	
	bu.Text = CreateFS(bu, text, "CENTER", 0, 0)
	
	if bu.Left then bu.Left:SetAlpha(0) end
	if bu.Middle then bu.Middle:SetAlpha(0) end
	if bu.Right then bu.Right:SetAlpha(0) end
	if bu.LeftSeparator then bu.LeftSeparator:Hide() end
	if bu.RightSeparator then bu.RightSeparator:Hide() end
	
	bu:SetScript("OnEnter", function() bu:SetBackdropBorderColor(0, 1, 1, 1) end)
	bu:SetScript("OnLeave", function() bu:SetBackdropBorderColor(0, 0, 0, 1) end)
	
	return bu
end

local function CreateCheckBox(self)
	local cb = CreateFrame("CheckButton", nil, self, "InterfaceOptionsCheckButtonTemplate")
	cb:SetHighlightTexture("Interface\\ChatFrame\\ChatFrameBackground")
	cb:SetHitRectInsets(-5, -5, -5, -5)
	
	local hl = cb:GetHighlightTexture()
	hl:SetPoint("TOPLEFT", 5, -5)
	hl:SetPoint("BOTTOMRIGHT", -5, 5)
	hl:SetVertexColor(0, 1, 1, .25)

	local bd = CreateBG(cb, -4)
	bd:SetBackdropColor(0, 0, 0, .5)
	bd:SetBackdropBorderColor(0, 0, 0)

	local ch = cb:GetCheckedTexture()
	ch:SetDesaturated(true)
	ch:SetVertexColor(0, 1, 1)

	--cb.Type = "CheckBox"
	
	return cb
end

local function CreateEditBox(self, width, height)
	local function editBoxClearFocus(self)
		self:ClearFocus()
	end
	
	local eb = CreateFrame("EditBox", nil, self)
	eb:SetSize(width, height)
	eb:SetBackdrop({
		bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
		edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
		edgeSize = 1,
	})
	eb:SetBackdropColor(0, 0, 0, .3)
	eb:SetBackdropBorderColor(0, 0, 0)
	eb:SetAutoFocus(false)
	eb:SetTextInsets(5, 5, 0, 0)
	eb:SetMaxLetters(500)
	eb:SetFont(G.font, G.fontSize, G.fontFlag)
	
	eb:SetScript("OnEscapePressed", editBoxClearFocus)
	eb:SetScript("OnEnterPressed", editBoxClearFocus)

	--eb.Type = "EditBox"
		
	return eb
end

--[[
local optionList = {
	-- typpe, key, name, horizon, doubleline
	{1, "ObjectTracker", L["ObjectTracker"], true},
}

local function CreateOption(i)
	local parent, offset = MainFrame, 20
	
	for _, option in pairs(optionList[i]) do
		local optType, value, name, horizon = unpack(option)
		
		-- Checkboxes
		if optType == 1 then
			local cb = M_CreateCheckBox(parent)
			cb:SetHitRectInsets(-5, -5, -5, -5)
			if horizon2 then cb:SetPoint("TOPLEFT", 470, -offset + 32)
			elseif horizon then cb:SetPoint("TOPLEFT", 240, -offset + 32)
			else cb:SetPoint("TOPLEFT", 20, -offset) offset = offset + 32
			end
			cb.name = M_CreateFS(cb, 14, name, false, "LEFT", 30, 0)
			cb:SetChecked(GLOBEVARIABLE(value))
			cb:SetScript("OnClick", function()
				GLOBEVARIABLE(value, cb:GetChecked())
				if callback then callback() end
			end)
			if data and type(data) == "function" then
				local bu = M_CreateGear(parent)
				bu:SetPoint("LEFT", cb.name, "RIGHT", -2, 1)
				bu:SetScript("OnClick", data)
			end
	]]--		
local function CreateOptions()
	if MainFrame ~= nil then
		MainFrame:Show()
		return
	end
	
	MainFrame = CreateFrame("Frame", "EKMinimapOptions", UIParent)
	tinsert(UISpecialFrames, "EKMinimapOptions")
	MainFrame:SetFrameStrata("DIALOG")
	MainFrame:SetWidth(500)
	MainFrame:SetHeight(400)
	MainFrame:SetPoint("CENTER", UIParent)
	MainFrame:SetMovable(true)
	MainFrame:EnableMouse(true)
	MainFrame:RegisterForDrag("LeftButton")
	MainFrame:SetBackdrop({ bgFile = "Interface\\ChatFrame\\ChatFrameBackground", edgeFile = "Interface\\ChatFrame\\ChatFrameBackground", edgeSize = 3, })
	MainFrame:SetBackdropColor(0, 0, 0, .5)
	MainFrame:SetBackdropBorderColor(0, 0, 0)
	MainFrame:SetClampedToScreen(true)
	MainFrame:SetScript("OnDragStart", function() MainFrame:StartMoving() end)
	MainFrame:SetScript("OnDragStop", function() MainFrame:StopMovingOrSizing() end)
	
	MainFrame.Title = CreateFS(MainFrame, "|cff00ffffEK|rMinimap", "TOP", 0, -10)
	
	local ClickMenuBox = CreateCheckBox(MainFrame)
	ClickMenuBox:SetPoint("TOPLEFT", MainFrame, 30, -40)
	ClickMenuBox:SetChecked(C.ClickMenu == true)
	ClickMenuBox:SetScript("OnClick", function(self)
		C.ClickMenu = (self:GetChecked() or false)
	end)
	
	local ClickMenuText = CreateFS(ClickMenuBox, L.ClickMenuOpt)
	ClickMenuText:SetPoint("LEFT", ClickMenuBox, "RIGHT", 4, 0)

	local OTFBox = CreateCheckBox(MainFrame)
	OTFBox:SetPoint("BOTTOM", ClickMenuBox, 0, -30)
	OTFBox:SetChecked(C.ObjectTracker == true)
	OTFBox:SetScript("OnClick", function(self)
		C.ObjectTracker = (self:GetChecked() or false)
	end)
	
	local OTFText = CreateFS(OTFBox, L.ObjectTrackerOpt)
	OTFText:SetPoint("LEFT", OTFBox, "RIGHT", 4, 0)
	
	local StarBox = CreateCheckBox(MainFrame)
	StarBox:SetPoint("BOTTOM", OTFBox, 0, -30)
	StarBox:SetChecked(C.Star == true)
	StarBox:SetScript("OnClick", function(self)
		C.Star = (self:GetChecked() or false)
	end)
	
	local StarText = CreateFS(StarBox, L.ObjectiveStarOpt)
	StarText:SetPoint("LEFT", StarBox, "RIGHT", 4, 0)
	
	local EditOTFBox = CreateEditBox(MainFrame, 40, 20)
	EditOTFBox:SetPoint("BOTTOM", StarBox, 2, -30)
	EditOTFBox:SetAutoFocus(false)
	EditOTFBox:SetText(C.Height)
	EditOTFBox:SetScript("OnEnterPressed", function(self)
		local n = tonumber(self:GetText())
		if n then
			C.Height = n
		end
	end)
    EditOTFBox:SetScript("OnEscapePressed", function(self)
		self:SetText(C.Height)
	end)
	
	local EditOTFText = CreateFS(EditOTFBox, L.ObjectHeightOpt)
	EditOTFText:SetPoint("LEFT", EditOTFBox, "RIGHT", 4, 0)

	local EditMSBox = CreateEditBox(MainFrame, 40, 20)
    EditMSBox:SetPoint("BOTTOM", EditOTFBox, 0, -30)
    EditMSBox:SetAutoFocus(false)
    EditMSBox:SetText(C.Size)
    EditMSBox:SetScript("OnEnterPressed", function(self)
		local n = tonumber(self:GetText())
		if n then
			C.Size = n
		end
	end)
    EditMSBox:SetScript("OnEscapePressed", function(self)
		self:SetText(C.Size)
	end)
	
	TextMS = CreateFS(EditMSBox, L.MinimapSizeOpt)
	TextMS:SetPoint("LEFT", EditMSBox, "RIGHT", 4, 0)
	--[[ButtonCM = CreateFrame("CheckButton", "EKMButtonCM", MainFrame, "UICheckButtonTemplate")
	ButtonCM:SetPoint("TOPLEFT", MainFrame, 30, -40)
	_G[ButtonCM:GetName() .. "Text"]:SetText("Click Menu")
	_G[ButtonCM:GetName() .. "Text"]:SetFontObject("GameFontHighlight")
	ButtonCM:SetChecked(C.ClickMenu == true)
	ButtonCM:SetScript("OnClick", function(self)
		C.ClickMenu = (self:GetChecked() or false)
	end)
	
	ButtonOTF = CreateFrame("CheckButton", "EKMButtonOTF", MainFrame, "UICheckButtonTemplate")
	ButtonOTF:SetPoint("BOTTOM", ButtonCM, 0, -30)
	_G[ButtonOTF:GetName() .. "Text"]:SetText("Objectiv Tracker")
	_G[ButtonOTF:GetName() .. "Text"]:SetFontObject("GameFontHighlight")
	ButtonOTF:SetChecked(C.ObjectTracker == true)
	ButtonOTF:SetScript("OnClick", function(self)
		C.ObjectTracker = (self:GetChecked() or false)
	end)
	
	ButtonStar = CreateFrame("CheckButton", "EKMButtonStar", MainFrame, "UICheckButtonTemplate")
	ButtonStar:SetPoint("BOTTOM", ButtonOTF, 0, -30)
	_G[ButtonStar:GetName() .. "Text"]:SetText("Objective Star")
	_G[ButtonStar:GetName() .. "Text"]:SetFontObject("GameFontHighlight")
	ButtonStar:SetChecked(C.Star == true)
	ButtonStar:SetScript("OnClick", function(self)
		C.Star = (self:GetChecked() or false)
	end)

	EditBoxOTF = CreateFrame("EditBox", "OTFEditBox", MainFrame, "InputBoxTemplate")
    EditBoxOTF:SetPoint("BOTTOM", ButtonStar, 12, -34)
    EditBoxOTF:SetSize(40, 40)
    EditBoxOTF:SetAutoFocus(false)
    EditBoxOTF:SetText(C.Height)
    EditBoxOTF:SetScript("OnEnterPressed", function(self)
		local n = tonumber(self:GetText())
		if n then
			C.Height = n
		end
	end)
    EditBoxOTF:SetScript("OnEscapePressed", function(self)
		self:SetText(C.Height)
	end)
	
	TextOTF = CreateFS(EditBoxOTF, "Objective Height")
	TextOTF:SetPoint("LEFT", EditBoxOTF, "RIGHT", 2, 0)
	
	EditBoxMS = CreateFrame("EditBox", "SizeEditBox", MainFrame, "InputBoxTemplate")
    EditBoxMS:SetPoint("BOTTOM", EditBoxOTF, 0, -30)
    EditBoxMS:SetSize(40, 40)
    EditBoxMS:SetAutoFocus(false)
    EditBoxMS:SetText(C.Size)
    EditBoxMS:SetScript("OnEnterPressed", function(self)
		local n = tonumber(self:GetText())
		if n then
			C.Size = n
		end
	end)
    EditBoxMS:SetScript("OnEscapePressed", function(self)
		self:SetText(C.Size)
	end)
	
	TextMS = CreateFS(EditBoxMS, "Minimap Size")
	TextMS:SetPoint("LEFT", EditBoxMS, "RIGHT", 2, 0)]]--

	local closeButton = CreateButton(MainFrame, 22, 22, "X")
	closeButton:SetPoint("TOPRIGHT", MainFrame, -8, -8)
	closeButton:SetScript("OnClick", function() MainFrame:Hide() end)
	
	local reloadButton = CreateButton(MainFrame, 80, 30, RELOADUI)
	reloadButton:SetPoint("BOTTOMRIGHT", MainFrame, -20, 20)
	reloadButton:SetScript("OnClick", function() ReloadUI() end)
	
	local resetButton = CreateButton(MainFrame, 80, 30, RESET)
	resetButton:SetPoint("RIGHT", reloadButton, "LEFT", -10, 0)
	resetButton:SetScript("OnClick", function()
		EKPlateDB = {}
		ReloadUI()
	end)
	--[[
	ButtonRL = CreateFrame("Button", "EKMinimapReloadButton", MainFrame, "UIPanelButtonTemplate")
	ButtonRL:SetSize(80, 30)
	ButtonRL:SetNormalFontObject("GameFontNormalSmall")
	ButtonRL:SetText(RELOADUI)
	ButtonRL:SetPoint("BOTTOMRIGHT", MainFrame, -20, 20)
	ButtonRL:SetScript("OnClick", function()
		ReloadUI()
	end)

	-- reset settings
	ButtonRS = CreateFrame("Button", "EKMinimapResetButton", MainFrame, "UIPanelButtonTemplate")
	ButtonRS:SetSize(80, 30)
	ButtonRS:SetNormalFontObject("GameFontNormalSmall")
	ButtonRS:SetText(RESET)
	ButtonRS:SetPoint("RIGHT", ButtonRL, "LEFT", -10, 0)
	ButtonRS:SetScript("OnClick", function()
		EKPlateDB = {}
		ReloadUI()
	end)
	]]--
end

SlashCmdList["EKMINIMAP"] = function()
	CreateOptions()
end
SLASH_EKMINIMAP1 = "/ekm"
SLASH_EKMINIMAP2 = "/ekminimap"