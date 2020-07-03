----------------------
-- Dont touch this! --
----------------------

local addon, ns = ...
	ns[1] = {} -- C, config
	ns[2] = {} -- F, functions, constants, variables
	ns[3] = {} -- G, globals (Optionnal)
	ns[4] = {} -- L, localization
	
	--if EKMinimapDB == nil then EKMinimapDB = {} end
	
local C, F, G, L = unpack(ns)
local MediaFolder = "Interface\\AddOns\\EKMinimap\\Media\\"

--------------
-- Settings --
--------------

local default = CreateFrame("Frame")
default:RegisterEvent("ADDON_LOADED")
default:SetScript("OnEvent", function(self, _, addonName)
	if addonName == addon then
		if not EKPlateDB then
			EKPlateDB = {}
		end
		if EKMinimapDB["ClickMenu"] == nil then EKMinimapDB["ClickMenu"] = true end
		if EKMinimapDB["Objective"] == nil then EKMinimapDB["Objective"] = true end
		if EKMinimapDB["ObjectiveAnchor"] == nil then EKMinimapDB["ObjectiveAnchor"] = "TOPRIGHT" end
		if EKMinimapDB["ObjectiveX"] == nil then EKMinimapDB["ObjectiveX"] = -100 end
		if EKMinimapDB["ObjectiveY"] == nil then EKMinimapDB["ObjectiveY"] = -170 end
		if EKMinimapDB["ObjectiveHeight"] == nil then EKMinimapDB["ObjectiveHeight"] = 6 end
		if EKMinimapDB["ObjectiveStar"] == nil then EKMinimapDB["ObjectiveStar"] = true end
		if EKMinimapDB["MinimapSize"] == nil then EKMinimapDB["MinimapSize"] = 160 end
		if EKMinimapDB["MinimapAnchor"] == nil then EKMinimapDB["MinimapAnchor"] = "TOPLEFT" end
		if EKMinimapDB["MinimapX"] == nil then EKMinimapDB["MinimapX"] = 10 end
		if EKMinimapDB["MinimapY"] == nil then EKMinimapDB["MinimapY"] = -10 end
	end
end)

------------
-- Golbal --
------------

	G.Ccolors = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[select(2, UnitClass("player"))]

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

------------
-- Locale --
------------
	
if GetLocale() == "zhTW" then
	L.ClickMenuOpt = "啟用小地圖點擊選單"
	L.MinimapSizeOpt = "小地圖尺寸"
	L.MinimapPosOpt = "小地圖座標"
	L.XOpt = "X 座標"
	L.YOpt = "Y 座標"
	L.ObjectiveStarOpt = "使用 ★ 星星標記追蹤項目"
	L.ObjectTrackerOpt = "啟用追蹤框美化"
	L.ObjectHeightOpt = "追蹤框高度"
	L.ObjectPosOpt = "追蹤框座標"
elseif GetLocale() == "zhTW" then
	L.ClickMenuOpt = "启用小地图点击菜单"
	L.MinimapSizeOpt = "小地图尺寸"
	L.MinimapPosOpt = "小地图座标"
	L.XOpt = "X 座标"
	L.YOpt = "Y 座标"
	L.ObjectiveStarOpt = "使用 ★ 星星标记追踪项目"
	L.ObjectTrackerOpt = "启用追踪框美化"
	L.ObjectHeightOpt = "追踪框高度"
	L.ObjectPosOpt = "追踪框座标"
else
	L.ClickMenuOpt = "Enable minimap click menu"
	L.MinimapSizeOpt = "Minimap size"
	L.MinimapPosOpt = "Minimap Position"
	L.XOpt = "X coordinate"
	L.YOpt = "Y coordinate"
	L.ObjectiveStarOpt = "Mark tracking objective as ★ star"
	L.ObjectTrackerOpt = "Enable objective track style"
	L.ObjectHeightOpt = "Objective tracker height"
	L.ObjectPosOpt = "Objective tracker Position"
end

local optList = {
	[1] = "TOP",
	[2] = "TOPLEFT",
	[3] = "TOPRIGHT",
	[4] = "CENTER",
	[5] = "LEFT",
	[6] = "BOTTOM",
	[7] = "BOTTOMLEFT",
	[8] = "BOTTOMRIGHT",
	[9] = "RIGHT",
	}

local function optOnClick(self)
	--PlaySound(SOUNDKIT.GS_TITLE_OPTION_OK)
	local opt = self.__owner.options
	local text = self.__owner.Text
	for i = 1, #opt do
		if self == opt[i] then
			opt[i]:SetBackdropColor(0, 1, 1, .25)
			text[i]:SetTextColor(0, 1, 1)
			opt[i].selected = true
		else
			opt[i]:SetBackdropColor(0, 0, 0)
			text[i]:SetTextColor(1, 1, 1)
			opt[i].selected = false
		end
	end
	--self.__owner.Text:SetText(self.text)
	text:SetText(self.text)
	EKMinimapDB["MinimapAnchor"] = self.text
	self:GetParent():Hide()
end

local function optOnEnter(self)
	if self.selected then return end
	self:SetBackdropColor(0, 1, 1, .25)
end

local function optOnLeave(self)
	if self.selected then return end
	self:SetBackdropColor(0, 0, 0)
end

------------
-- Config --
------------

local function CreateFS(parent, text, anchor, x, y)
	--local function CreateFS(parent, text, anchor, x, y, r, g, b)
	local fs = parent:CreateFontString(nil, "OVERLAY")
	fs:SetFont(G.font, G.fontSize, G.fontFlag)
	fs:SetText(text)
	--fs:SetJustifyH("LEFT")
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

local function CreateGear(name)
	local bu = CreateFrame("Button", name, name)
	bu:SetSize(21, 21)
	bu.Icon = bu:CreateTexture(nil, "ARTWORK")
	bu.Icon:SetAllPoints()
	bu.Icon:SetTexture("Interface/minimap/minimap-deadarrow")
	bu.Icon:SetRotation(math.rad(180))
	
	return bu
end

local function CreateDropDown(self, width, height, data)
	local dd = CreateFrame("Frame", nil, self)
	dd:SetSize(width, height)
	dd:SetBackdrop({
		bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
		edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
		edgeSize = 1,
	})
	dd:SetBackdropColor(0, 0, 0, .5)
	dd:SetBackdropBorderColor(0, 0, 0)
	--dd.Text = CreateFS(dd, text, "LEFT", 5, 0)
	--dd.Text:SetPoint("RIGHT", -5, 0)
	dd.options = {}

	local bu = CreateGear(dd)
	bu:SetPoint("LEFT", dd, "RIGHT", -2, 0)
	
	local list = CreateFrame("Frame", nil, dd)
	list:SetPoint("TOP", dd, "BOTTOM", 0, -2)
	list:SetBackdrop({
		bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
		edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
		edgeSize = 1,
	})
	list:SetBackdropColor(0, 0, 0, .8)
	list:SetBackdropBorderColor(0, 0, 0)
	list:Hide()
	
	bu:SetScript("OnShow", function() list:Hide() end)
	bu:SetScript("OnClick", function()
		--PlaySound(SOUNDKIT.GS_TITLE_OPTION_OK)
		ToggleFrame(list)
	end)
	dd.button = bu

	local opt, index = {}, 0
	for i, j in pairs(data) do
		opt[i] = CreateFrame("Button", nil, list)
		opt[i]:SetPoint("TOPLEFT", 4, -4 - (i-1)*(height+2))
		opt[i]:SetSize(width - 8, height)
		opt[i]:SetBackdropColor(0, 0, 0, .8)
		opt[i]:SetBackdropBorderColor(0, 0, 0)
		local text = CreateFS(opt[i], j, "LEFT", 5, 0)
		text:SetPoint("RIGHT", -5, 0)
		opt[i].text = j
		opt[i].__owner = dd
		opt[i]:SetScript("OnClick", optOnClick)
		opt[i]:SetScript("OnEnter", optOnEnter)
		opt[i]:SetScript("OnLeave", optOnLeave)

		dd.options[i] = opt[i]
		index = index + 1
	end
	list:SetSize(width, index*(height+2) + 6)

	--dd.Type = "DropDown"
	
	return dd
end

local function CreateBar(self, name, width, height, min, max, step)
	local s = CreateFrame("Slider", name.."Bar", self, "OptionsSliderTemplate")
	s:SetSize(width, height)
	_G[s:GetName().."Low"]:SetText(min)
	_G[s:GetName().."High"]:SetText(max)
	
	s:SetMinMaxValues(min, max)
	s:SetObeyStepOnDrag(true)
	s:SetValueStep(step)
	s:SetOrientation("HORIZONTAL")
	
	return s
end

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
	
	local Title = CreateFS(MainFrame, "|cff00ffffEK|rMinimap", "TOP", 0, -10)
	local Option = CreateFS(MainFrame, OPTIONS, "LEFT", 30, -40)
	
	local ClickMenuBox = CreateCheckBox(MainFrame)
	ClickMenuBox:SetPoint("TOPLEFT", Option, 0, -30)
	ClickMenuBox:SetChecked(EKMinimapDB["ClickMenu"] == true or false)
	ClickMenuBox:SetScript("OnClick", function(self)
		EKMinimapDB["ClickMenu"] = (self:GetChecked())
	end)
	
	local ClickMenuText = CreateFS(ClickMenuBox, L.ClickMenuOpt)
	ClickMenuText:SetPoint("LEFT", ClickMenuBox, "RIGHT", 4, 0)

	local OTFBox = CreateCheckBox(MainFrame)
	OTFBox:SetPoint("BOTTOM", ClickMenuBox, 0, -30)
	OTFBox:SetChecked(EKMinimapDB["Objective"] == true)
	OTFBox:SetScript("OnClick", function(self)
		EKMinimapDB["Objective"] = (self:GetChecked() or false)
	end)
	
	local OTFText = CreateFS(OTFBox, L.ObjectTrackerOpt)
	OTFText:SetPoint("LEFT", OTFBox, "RIGHT", 4, 0)
	
	local StarBox = CreateCheckBox(MainFrame)
	StarBox:SetPoint("BOTTOM", OTFBox, 0, -30)
	StarBox:SetChecked(EKMinimapDB["ObjectiveStar"] == true)
	StarBox:SetScript("OnClick", function(self)
		EKMinimapDB["ObjectiveStar"] = (self:GetChecked() or false)
	end)
	
	local StarText = CreateFS(StarBox, L.ObjectiveStarOpt)
	StarText:SetPoint("LEFT", StarBox, "RIGHT", 4, 0)
		
	-- minimap position
	
	local mapPosText = CreateFS(MainFrame, L.MinimapPosOpt)
	mapPosText:SetPoint("TOPLEFT", MainFrame, 30, -40)
	
	local mapAnchor = CreateDropDown(MainFrame, 120, 20, optList)
	mapAnchor:SetPoint("LEFT", mapPosText, 30, -30)
	mapAnchor.Text = CreateFS(mapAnchor, EKMinimapDB["MinimapAnchor"])
	mapAnchor.Text:SetPoint("CENTER", mapAnchor, 0, 0)
	
	local mapXText = CreateFS(MainFrame, L.XOpt)
	mapXText:SetPoint("LEFT", mapPosText, 30, -60)
	
	local mapXBox = CreateEditBox(MainFrame, 100, 20)
	mapXBox:SetPoint("LEFT", mapXText, "RIGHT", 4, 0)
	mapXBox:SetAutoFocus(false)
	mapXBox:SetText(EKMinimapDB["MinimapX"])
	mapXBox:SetScript("OnEnterPressed", function(self)
		local n = tonumber(self:GetText())
		if n then
			EKMinimapDB["MinimapX"] = n
		end
		self:ClearFocus()
	end)
    mapXBox:SetScript("OnEscapePressed", function(self)
		self:SetText(EKMinimapDB["MinimapX"])
	end)
	
	local mapYText = CreateFS(MainFrame, L.YOpt)
	mapYText:SetPoint("LEFT", mapXText, 0, -30)
	
	local mapYBox = CreateEditBox(MainFrame, 100, 20)
	mapYBox:SetPoint("LEFT", mapYText, "RIGHT", 4, 0)
	mapYBox:SetAutoFocus(false)
	mapYBox:SetText(EKMinimapDB["MinimapY"])
	mapYBox:SetScript("OnEnterPressed", function(self)
		local n = tonumber(self:GetText())
		if n then
			EKMinimapDB["MinimapY"] = n
		end
		self:ClearFocus()
	end)
    mapYBox:SetScript("OnEscapePressed", function(self)
		self:SetText(EKMinimapDB["MinimapY"])
	end)
	
	local mapSizeBar = CreateBar(MainFrame, "Size", 160, 20, 120, 300, 10)
	mapSizeBar:SetPoint("TOP", mapYText, "BOTTOM", 50, -40)
	mapSizeBar:SetValue(EKMinimapDB["MinimapSize"])
	
	local mapSizeText = CreateFS(mapSizeBar, L.MinimapSizeOpt.." "..EKMinimapDB["MinimapSize"])
	mapSizeText:SetPoint("BOTTOM", mapSizeBar, "TOP", 0, 5)
	
	mapSizeBar:SetScript("OnValueChanged", function(self)
		local n = tonumber(self:GetValue())
		if n then
			EKMinimapDB["MinimapSize"] = n
		end
		mapSizeText:SetText(L.MinimapSizeOpt.." "..EKMinimapDB["MinimapSize"])
	end)
	
	-- objctive tracker position

	local otfPosText = CreateFS(MainFrame, L.ObjectPosOpt)
	otfPosText:SetPoint("TOPLEFT", MainFrame, 280, -40)
	
	local otfAnchor = CreateDropDown(MainFrame, 120, 20, optList)
	otfAnchor:SetPoint("LEFT", otfPosText, 30, -30)
	otfAnchor.Text = CreateFS(otfAnchor, EKMinimapDB["ObjectiveAnchor"])
	otfAnchor.Text:SetPoint("CENTER", otfAnchor, 0, 0)
	
	local otfXText = CreateFS(MainFrame, L.XOpt)
	otfXText:SetPoint("LEFT", otfPosText, 30, -60)
	
	local otfXBox = CreateEditBox(MainFrame, 100, 20)
	otfXBox:SetPoint("LEFT", otfXText, "RIGHT", 4, 0)
	otfXBox:SetAutoFocus(false)
	otfXBox:SetText(EKMinimapDB["ObjectiveX"])
	otfXBox:SetScript("OnEnterPressed", function(self)
		local n = tonumber(self:GetText())
		if n then
			EKMinmapfDB["ObjectiveX"] = n
		end
		self:ClearFocus()
	end)
    otfXBox:SetScript("OnEscapePressed", function(self)
		self:SetText(EKMinimapDB["ObjectiveX"])
	end)
	
	local otfYText = CreateFS(MainFrame, L.YOpt)
	otfYText:SetPoint("LEFT", otfXText, 0, -30)
	
	local otfYBox = CreateEditBox(MainFrame, 100, 20)
	otfYBox:SetPoint("LEFT", otfYText, "RIGHT", 4, 0)
	otfYBox:SetAutoFocus(false)
	otfYBox:SetText(EKMinimapDB["ObjectiveY"])
	otfYBox:SetScript("OnEnterPressed", function(self)
		local n = tonumber(self:GetText())
		if n then
			EKMinimapDB["ObjectiveY"] = n
		end
		self:ClearFocus()
	end)
    otfYBox:SetScript("OnEscapePressed", function(self)
		self:SetText(EKMinimapDB["ObjectiveY"])
	end)
	
	local otfHeightBar = CreateBar(MainFrame, "Height", 160, 20, 200, 1200, 100)
	otfHeightBar:SetPoint("TOP", otfYText, "BOTTOM", 50, -40)
	otfHeightBar:SetValue(EKMinimapDB["ObjectiveHeight"])
	
	local otfHeightText = CreateFS(otfHeightBar, L.ObjectHeightOpt.." "..EKMinimapDB["ObjectiveHeight"])
	otfHeightText:SetPoint("BOTTOM", otfHeightBar, "TOP", 0, 5)
	
	otfHeightBar:SetScript("OnValueChanged", function(self)
		local n = tonumber(self:GetValue())
		if n then
			EKMinimapDB["ObjectiveHeight"] = n
		end
		otfHeightText:SetText(L.MinimapSizeOpt.." "..EKMinimapDB["ObjectiveHeight"])
	end)
	
	local closeButton = CreateButton(MainFrame, 22, 22, "X")
	closeButton:SetPoint("TOPRIGHT", MainFrame, -8, -8)
	closeButton:SetScript("OnClick", function() MainFrame:Hide() end)
	
	local reloadButton = CreateButton(MainFrame, 80, 30, APPLY)
	reloadButton:SetPoint("BOTTOMRIGHT", MainFrame, -20, 20)
	reloadButton:SetScript("OnClick", function() ReloadUI() end)
	
	local resetButton = CreateButton(MainFrame, 80, 30, RESET)
	resetButton:SetPoint("RIGHT", reloadButton, "LEFT", -10, 0)
	resetButton:SetScript("OnClick", function()
		EKMinimapDB = {
			["ObjectiveStar"] = true,
			["ObjectiveX"] = -100,
			["ObjectiveAnchor"] = "TOPRIGHT",
			["Objective"] = true,
			["ObjectiveY"] = -170,
			["MinimapSize"] = 160,
			["MinimapX"] = 10,
			["ClickMenu"] = true,
			["MinimapY"] = -10,
			["ObjectiveHeight"] = 600,
			["MinimapAnchor"] = "TOPLEFT",
		}
		ReloadUI()
	end)
end

SlashCmdList["EKMINIMAP"] = function()
	CreateOptions()
end
SLASH_EKMINIMAP1 = "/ekm"
SLASH_EKMINIMAP2 = "/ekminimap"


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