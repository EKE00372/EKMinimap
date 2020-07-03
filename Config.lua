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
elseif GetLocale() == "zhTW" then
	L.ClickMenuOpt = "启用小地图点击菜单"
	L.MinimapSizeOpt = "小地图尺寸"
	L.MinimapPosOpt = "小地图座标"
	L.XOpt = "X 座标"
	L.YOpt = "Y 座标"
	L.ObjectiveStarOpt = "使用 ★ 星星标记追踪项目"
	L.ObjectTrackerOpt = "启用追踪框美化"
	L.ObjectHeightOpt = "追踪框高度"
else
	L.ClickMenuOpt = "Enable minimap click menu"
	L.MinimapSizeOpt = "Minimap size"
	L.MinimapPosOpt = "Minimap Position"
	L.XOpt = "X coordinate"
	L.YOpt = "Y coordinate"
	L.ObjectiveStarOpt = "Mark tracking objective as ★ star"
	L.ObjectTrackerOpt = "Enable objective track style"
	L.ObjectHeightOpt = "Objective tracker height"
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
	s:SetPoint("TOPRIGHT", MainFrame, -30, -70)
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
	
	local ClickMenuBox = CreateCheckBox(MainFrame)
	ClickMenuBox:SetPoint("TOPLEFT", MainFrame, 30, -40)
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
	--[[
	local EditOTFBox = CreateEditBox(MainFrame, 40, 20)
	EditOTFBox:SetPoint("BOTTOM", StarBox, 2, -30)
	EditOTFBox:SetAutoFocus(false)
	EditOTFBox:SetText(EKMinimapDB["ObjectiveHeight"])
	EditOTFBox:SetScript("OnEnterPressed", function(self)
		local n = tonumber(self:GetText())
		if n then
			EKMinimapDB["ObjectiveHeight"] = n
		end
		self:ClearFocus()
	end)
    EditOTFBox:SetScript("OnEscapePressed", function(self)
		self:SetText(EKMinimapDB["ObjectiveHeight"])
	end)
	
	local EditOTFText = CreateFS(EditOTFBox, L.ObjectHeightOpt)
	EditOTFText:SetPoint("LEFT", EditOTFBox, "RIGHT", 4, 0)]]--
	--[[
	local s = CreateFrame("Slider", nil, MainFrame, "OptionsSliderTemplate")
	s:SetWidth(140)
	s:SetMinMaxValues(100, 300)
	s:SetPoint("TOP", EditOTFBox, "BOTTOM", s:GetWidth()/2, -30)
	s:SetValue(EKMinimapDB["EKMinimapSize"])]]--
	
	--[[local s = CreateFrame("Slider", "SB", MainFrame, "OptionsSliderTemplate")
	s:SetPoint("TOPRIGHT", MainFrame, -30, -70)
	s:SetSize(160, 20)
	_G[s:GetName().."Low"]:SetText("100")
	_G[s:GetName().."High"]:SetText("300")
	_G[s:GetName().."Text"]:ClearAllPoints()
	
	_G[s:GetName().."Text"]:SetPoint("BOTTOM", s, "TOP", 0, 5)
	s:SetMinMaxValues(120, 300)
	s:SetValue(EKMinimapDB["MinimapSize"])
	s:SetObeyStepOnDrag(true)
	s:SetValueStep(10)
	s:SetOrientation("HORIZONTAL")
	_G[s:GetName().."Text"]:SetText(L.MinimapSizeOpt.." "..EKMinimapDB["MinimapSize"])
	s:SetScript("OnValueChanged", function(self)
		local n = tonumber(self:GetValue())
		if n then
			EKMinimapDB["MinimapSize"] = n
		end
		_G[s:GetName().."Text"]:SetText(L.MinimapSizeOpt.." "..EKMinimapDB["MinimapSize"])
	end)
	]]--
	local mapSizeBar = CreateBar(MainFrame, "Size", 160, 20, 120, 300, 10)
	mapSizeBar:SetPoint("TOPRIGHT", MainFrame, -30, -70)
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
	
	local otfHeightBar = CreateBar(MainFrame, "Height", 160, 20, 200, 1200, 100)
	otfHeightBar:SetPoint("TOP", mapSizeBar, "BOTTOM", 0, -70)
	otfHeightBar:SetValue(EKMinimapDB["ObjectiveHeight"])
	
	local otfHeightText = CreateFS(mapSizeBar, L.ObjectHeightOpt.." "..EKMinimapDB["ObjectiveHeight"])
	otfHeightText:SetPoint("BOTTOM", otfHeightBar, "TOP", 0, 5)
	
	otfHeightBar:SetScript("OnValueChanged", function(self)
		local n = tonumber(self:GetValue())
		if n then
			EKMinimapDB["ObjectiveHeight"] = n
		end
		otfHeightText:SetText(L.MinimapSizeOpt.." "..EKMinimapDB["ObjectiveHeight"])
	end)
	
	local mapPosText = CreateFS(MainFrame, L.MinimapPosOpt)
	mapPosText:SetPoint("LEFT", MainFrame, 30, 0)
	
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
	
	--local mapAnchor = CreateDropDown(MainFrame, 120, 20, optList)
	local mapAnchor = CreateDropDown(MainFrame, 120, 20, optList)
	mapAnchor:SetPoint("LEFT", mapPosText, 30, -30)
	mapAnchor.Text = CreateFS(mapAnchor, EKMinimapDB["MinimapAnchor"])
	mapAnchor.Text:SetPoint("CENTER", mapAnchor, 0, 0)
	--local mapAnchorText = CreateFS(mapAnchor, EKMinimapDB["MinimapAnchor"])
	--mapAnchorText:SetPoint("CENTER", mapAnchor, 0, 0)
	--mapAnchor:SetText()
	--mapSizeBar:GetName()
	--mapSizeBar:SetValue(EKMinimapDB["EKMinimapSize"])
	--_G[mapSizeBar:GetName().."Text"]:SetText(L.MinimapSizeOpt.." "..EKMinimapDB["MinimapSize"])
	--[[mapSizeBar:SetScript("OnValueChanged", function(self)
		local n = tonumber(mapSizeBar:GetName():GetValue())
		if n then
			EKMinimapDB["MinimapSize"] = n
		end
		_G[mapSizeBar:GetName().."Text"]:SetText(L.MinimapSizeOpt.." "..EKMinimapDB["MinimapSize"])
	end)]]--
	--[[s:SetValue(EKMinimapDB["EKMinimapSize"])
	s.SetDisplayValue = s.SetValue
	s:SetWidth(16)]]--
	--[[s:SetScript("OnValueChanged", function (self, value)
		self:GetParent():SetVerticalScroll(value)
	end)]]--
	--[[s.bg = s:CreateTexture(nil, "BACKGROUND")
	s.bg:SetAllPoints(s)
	s.bg:SetTexture(0, 0, 0, 0.4)]]--
	--local mapSize = CreateBar(MainFrame, 120, 320)
	--mapSize:SetPoint("BOTTOM", EditOTFBox, 2, -30)
	--mapSize:SetPoint(EKMinimapDB["MinimapSize"])
	--mapSize:SetValue(160)
	
	--[[mapSize:SetScript("OnValueChanged", function(self)
		local current = tonumber(self:GetValue)
		EKMinimapDB["ObjectiveHeight"] = current
	end)]]--
--[[
	local EditMSBox = CreateEditBox(MainFrame, 40, 20)
    EditMSBox:SetPoint("BOTTOM", EditOTFBox, 0, -30)
    --EditMSBox:SetAutoFocus(false)
    EditMSBox:SetText(C.Cfg.MinimapSize)
    EditMSBox:SetScript("OnEnterPressed", function(self)
		local n = tonumber(self:GetText())
		if n then
			C.Cfg.MinimapSize = n
		end
		self:ClearFocus()
	end)
    EditMSBox:SetScript("OnEscapePressed", function(self)
		self:SetText(C.Cfg.MinimapSize)
	end)
	
	TextMS = CreateFS(EditMSBox, L.MinimapSizeOpt)
	TextMS:SetPoint("LEFT", EditMSBox, "RIGHT", 4, 0)]]--
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