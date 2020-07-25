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
local v = GetAddOnMetadata("EKMinimap", "Version")
local CreateFrame, tonumber, pairs = CreateFrame, tonumber, pairs

--===================================================--
-----------------    [[ Initial	]]    -----------------
--===================================================--

	G.Ccolors = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[select(2, UnitClass("player"))]
	G.Mask = MediaFolder.."mask.blp"
	G.Tex = "Interface\\Buttons\\WHITE8x8"
	--G.Tex = "Interface\\ChatFrame\\ChatFrameBackground"
	G.Glow = MediaFolder.."glow.tga"
	G.Mail = "Interface\\MINIMAP\\TRACKING\\Mailbox.blp"  -- "Interface\\HELPFRAME\\ReportLagIcon-Mail.blp"
	G.Diff = MediaFolder.."difficulty.tga"
	G.Report = "Interface\\HelpFrame\\HelpIcon-ReportLag.blp"
	-- 字體 / font
	G.font = STANDARD_TEXT_FONT
	-- minimap / 小地圖字型
	G.fontSize = 14
	G.fontFlag = "THINOUTLINE"
	-- objectframe / 追蹤字型
	G.obfontSize = 18
	G.obfontFlag = "OUTLINE"

--====================================================--
-----------------    [[ Settings ]]    -----------------
--====================================================--

	C.defaultSettings = {
		["ObjectiveStyle"] = true,
		["ObjectiveStar"] = true,
		["ObjectiveHeight"] = 600,
		["ObjectiveAnchor"] = "TOPRIGHT",
		["ObjectiveX"] = -100,
		["ObjectiveY"] = -170,
		["MinimapScale"] = 1.2,
		["MinimapAnchor"] = "TOPLEFT",
		["MinimapY"] = -10,
		["MinimapX"] = 10,
		["ClickMenu"] = true,
		["CharacterIcon"] = true,
	}

--===================================================--
-----------------    [[ Locales ]]    -----------------
--===================================================--

if GetLocale() == "zhTW" then
	L.ClickMenuOpt = "啟用點擊選單"
	L.MinimapOpt = "小地圖"
	L.SizeOpt = "縮放"
	L.AnchorOpt = "錨點"
	L.XOpt = "X 座標"
	L.YOpt = "Y 座標"
	L.ObjectiveOpt = "追蹤框"
	L.ObjectiveStarOpt = "使用 ★ 標記追蹤項目"
	L.ObjectiveStyleOpt = "啟用追蹤框美化"
	L.HeightOpt = "高度"
	L.IconOpt = "角色資訊提示"
	
	L.Calendar = SLASH_CALENDAR2:gsub("/(.*)","%1")
	L.Left = "左"
	L.Right = "右"
	
	L.Apply = "更改後點擊「"..APPLY.."」立即重載生效。"
	L.posApply = APPLY..L.SizeOpt.."座標"
	
	L.tempTip1 = "Alt 功能是臨時性功能，提供給需要追蹤某些特定目標的偶發情況，所以它們的變動不會被儲存。"
	L.tempTip2 = "所有 Alt 功能造成的更改會在重載介面或點擊「"..L.posApply.."」後復原。"
	L.tempTip3 = "設定時，單純更改尺寸和座標而不更改選項，可以點擊「"..L.posApply.."」來直接套用而不需重載。"
	L.cmdInfo = "/ej1 /ej2 彈出載具乘客"
	L.dragInfo = "Alt+右鍵：臨時性拖動框體"
	L.scrollInfo = "Alt+滾輪：臨時縮放小地圖"
elseif GetLocale() == "zhCN" then
	L.ClickMenuOpt = "启用点击菜单"
	L.MinimapOpt = "小地图"
	L.SizeOpt = "缩放"
	L.AnchorOpt = "锚点"
	L.XOpt = "X 座标"
	L.YOpt = "Y 座标"
	L.ObjectiveOpt = "追踪框"
	L.ObjectiveStarOpt = "使用 ★ 标记追踪项目"
	L.ObjectiveStyleOpt = "启用追踪框美化"
	L.HeightOpt = "高度"
	L.IconOpt = "角色信息提示"
	
	L.Calendar = "行事历"
	L.Left = "左"
	L.Right = "右"
	
	L.Apply = "更改后点击＂"..APPLY.."＂立即重载生效。"
	L.posApply = APPLY..L.SizeOpt.."座标"
	
	L.tempTip1 = "Alt 功能是临时性功能，提供给需要追踪某些特定目标的偶发情况，所以它们的变动不会被保存。"
	L.tempTip2 = "所有 Alt 功能造成的更改会在重载界面或点击＂"..L.posApply.."＂后复原。"
	L.tempTip3 = "设置时，单纯更改尺寸和座标而不更改选项，可以点击＂"..L.posApply.."＂来直接套用而不需重载。"
	L.cmdInfo = "/ej1 /ej2 弹出载具乘客"
	L.dragInfo = "Alt+右键临时性拖动框体"
	L.scrollInfo = "Alt+滚轮临时性缩放小地图"
else
	L.ClickMenuOpt = "Enable click menu"
	L.MinimapOpt = "Minimap"
	L.SizeOpt = "Scale"
	L.AnchorOpt = "Anchor"
	L.XOpt = "X"
	L.YOpt = "Y"
	L.ObjectiveOpt = "Objective tracker"
	L.ObjectiveStarOpt = "Mark object as ★ star"
	L.ObjectiveStyleOpt = "Enable tracker style"
	L.HeightOpt = "Height"
	L.IconOpt = "Character icon tooltip"
	
	L.Calendar = SLASH_CALENDAR1:gsub("/(.*)","%1")
	L.Left = "Left"
	L.Right = "Right"
	
	L.Apply = "Click "..APPLY.." to active changes."
	L.posApply = APPLY.." Size and Pos"
	
	L.tempTip1 = "Alt-function is a temporary function, for people wanna track something recently, they will not be saved to settgins."
	L.tempTip2 = 'Any scale and position change caused by alt-function will reset after you reload or click "'..L.posApply..'" button.'
	L.tempTip3 = 'If wanna config position and scale only (did not change check box), you can directly click"'..L.posApply..'" to apply them	without reload.'
	L.cmdInfo = "/ej1 /ej2 Eject Passenger"
	L.dragInfo = "Alt-right click drag frame"
	L.scrollInfo = "Alt-scroll scale minimap"
end

--===================================================--
-----------------    [[ Initial ]]    -----------------
--===================================================--

local default = CreateFrame("Frame")
	default:RegisterEvent("ADDON_LOADED")
	default:SetScript("OnEvent", function(self, _, addonName)
		if addonName == addon then
			if not EKMinimapDB then EKMinimapDB = {} end
			-- 載入存在於表中，但不存在於設定的数据
			for key, value in pairs(C.defaultSettings) do
				if EKMinimapDB[key] == nil then
					EKMinimapDB[key] = value
				end
			end
			-- 删除不存在於表中，但存在於設定的数据
			for key in pairs(EKMinimapDB) do
				if C.defaultSettings[key] == nil then
					EKMinimapDB[key] = nil
				end
			end
		end
	end)

--=====================================================--
-----------------    [[ Functions ]]    -----------------
--=====================================================--

F.CreateFS = function(parent, text, justify, anchor, x, y)
	local fs = parent:CreateFontString(nil, "OVERLAY")
	fs:SetFont(G.font, G.fontSize, G.fontFlag)
	fs:SetText(text)
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

-- variable check: check if value update, or simply get value for show
local function GLOBEVARIABLE(value, newValue)
	if newValue ~= nil then
		EKMinimapDB[value] = newValue
	else
		return EKMinimapDB[value]
	end
end

-- click buttons
local function CreateButton(self, width, height, text)
	local bu = CreateFrame("Button", nil, self)
	bu:SetSize(width, height)
	bu.bg = F.CreateBG(bu, 3, 3, .5)
	
	bu:SetNormalTexture("")
	bu:SetHighlightTexture("")
	bu:SetPushedTexture("")
	bu:SetDisabledTexture("")
	
	bu.Text = F.CreateFS(bu, text, "CENTER", "CENTER", 0, 0)
	
	if bu.Left then bu.Left:SetAlpha(0) end
	if bu.Middle then bu.Middle:SetAlpha(0) end
	if bu.Right then bu.Right:SetAlpha(0) end
	if bu.LeftSeparator then bu.LeftSeparator:Hide() end
	if bu.RightSeparator then bu.RightSeparator:Hide() end
	
	bu:SetScript("OnEnter", function() bu.bg:SetBackdropColor(0, 1, 1, .5) end)
	bu:SetScript("OnLeave", function() bu.bg:SetBackdropColor(0, 0, 0, .5) end)
	
	return bu
end

-- check box
local function CreateCheckBox(self, text, value)
	local cb = CreateFrame("CheckButton", nil, self, "InterfaceOptionsCheckButtonTemplate")
	cb:SetHighlightTexture("Interface\\ChatFrame\\ChatFrameBackground")
	cb:SetHitRectInsets(-5, -5, -5, -5)
	
	local hl = cb:GetHighlightTexture()
	hl:SetPoint("TOPLEFT", 5, -5)
	hl:SetPoint("BOTTOMRIGHT", -5, 5)
	hl:SetVertexColor(0, 1, 1, .25)

	local bd = F.CreateBG(cb, -4, 1, .5)

	local ch = cb:GetCheckedTexture()
	ch:SetDesaturated(true)
	ch:SetVertexColor(0, 1, 1)

	cb:SetChecked(GLOBEVARIABLE(value) == true)
	cb:SetScript("OnClick", function(self)
		GLOBEVARIABLE(value, self:GetChecked())
	end)
	
	cb.text = F.CreateFS(cb, text, "LEFT")
	cb.text:SetPoint("LEFT", cb, "RIGHT", 4, 0)
	
	return cb
end

-- edit box
local function CreateEditBox(self, width, height, value)
	local eb = CreateFrame("EditBox", nil, self)
	eb:SetSize(width, height)
	eb.bg = F.CreateBG(eb, 3, 3, .5)
	eb:SetAutoFocus(false)
	
	eb:SetTextInsets(5, 5, 0, 0)
	eb:SetMaxLetters(500)
	eb:SetFont(G.font, G.fontSize, G.fontFlag)
	eb:SetText(GLOBEVARIABLE(value))
	
	eb:HookScript("OnEnterPressed", function(self)
		local n = tonumber(self:GetText())
		if n then
			GLOBEVARIABLE(value, n)
		end
		self:ClearFocus()
	end)
	eb:HookScript("OnEscapePressed", function(self)
		self:SetText(GLOBEVARIABLE(value))
	end)
	eb:SetScript("OnEnter", function() eb.bg:SetBackdropColor(0, 1, 1, .5) end)
	eb:SetScript("OnLeave", function() eb.bg:SetBackdropColor(0, 0, 0, .5) end)
	
	return eb
end

-- drop down menu arrow icon
local function CreateGear(name)
	local bu = CreateFrame("Button", name, name)
	bu:SetSize(21, 21)
	bu.Icon = bu:CreateTexture(nil, "ARTWORK")
	bu.Icon:SetAllPoints()
	bu.Icon:SetTexture("Interface/minimap/minimap-deadarrow")
	bu.Icon:SetRotation(math.rad(180))

	return bu
end

-- custom drop down menu
local function CreateDropDown(self, width, height, data, value)
	local dd = CreateFrame("Frame", nil, self)
	dd:SetSize(width, height)
	dd.bg = F.CreateBG(dd, 3, 3, .5)
	dd.options = {}
	
	dd.Text = F.CreateFS(dd, "", "CENTER", 0, 0)
	dd.Text:SetText(GLOBEVARIABLE(value))
	
	local bu = CreateGear(dd)
	bu:SetPoint("LEFT", dd, "RIGHT", -2, 0)
	
	local list = CreateFrame("Frame", nil, dd)
	list:SetPoint("TOP", dd, "BOTTOM", 0, -2)
	list.bg = F.CreateBG(list, 0, 3, .2)
	list:Hide()
	
	bu:SetScript("OnShow", function() list:Hide() end)
	bu:SetScript("OnClick", function()
		ToggleFrame(list)
	end)
	dd.button = bu

	local opt, index = {}, 0
	for i, j in pairs(data) do
		opt[i] = CreateFrame("Button", nil, list)
		opt[i]:SetPoint("TOPLEFT", 3, -4 - (i-1)*(height+2))
		opt[i]:SetSize(width - 6, height)
		opt[i].bg = F.CreateBG(opt[i], 1, 1, .7)
		
		local text = F.CreateFS(opt[i], j, "CENTER", "LEFT", 5, 0)
		text:SetPoint("RIGHT", -5, 0)
		opt[i].text = j
		opt[i].__owner = dd
		opt[i]:SetScript("OnClick", function(self)
			self.__owner.Text:SetText(self.text)
			self:GetParent():Hide()
		end)
		opt[i]:HookScript("OnClick", function(self)
			GLOBEVARIABLE(value, self.__owner.Text:GetText())
		end)
		opt[i]:SetScript("OnEnter", function() opt[i].bg:SetBackdropColor(0, 1, 1, .7) end)
		opt[i]:SetScript("OnLeave", function() opt[i].bg:SetBackdropColor(0, 0, 0, .7) end)

		dd.options[i] = opt[i]
		index = index + 1
	end
	list:SetSize(width, index*(height+2) + 6)

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

--===============================================--
-----------------    [[ GUI ]]    -----------------
--===============================================--

local function CreateOptions()
	if MainFrame ~= nil then
		MainFrame:Show()
		return
	end
	
	MainFrame = CreateFrame("Frame", "EKMinimapOptions", UIParent)
	tinsert(UISpecialFrames, "EKMinimapOptions")
	
	MainFrame:SetFrameStrata("DIALOG")
	MainFrame:SetWidth(500)
	MainFrame:SetHeight(420)
	MainFrame:SetPoint("CENTER", UIParent)
	MainFrame:SetMovable(true)
	MainFrame:EnableMouse(true)
	MainFrame:RegisterForDrag("LeftButton")
	MainFrame.bg = F.CreateBG(MainFrame, 5, 5, .4)
	MainFrame:SetClampedToScreen(true)
	MainFrame:SetScript("OnDragStart", function() MainFrame:StartMoving() end)
	MainFrame:SetScript("OnDragStop", function() MainFrame:StopMovingOrSizing() end)
	
	-- Main title
	local Title = F.CreateFS(MainFrame, "|cff00ffffEK|rMinimap "..v, "CENTER", "TOP", 0, 10)
	
	-- minimap / 小地圖
	
	local mapTitle = F.CreateFS(MainFrame, L.MinimapOpt, "LEFT", "TOPLEFT", 30, -30)

	local ClickMenuBox = CreateCheckBox(MainFrame, L.ClickMenuOpt, "ClickMenu")
	ClickMenuBox:SetPoint("TOPLEFT", MainFrame, 30, -60)
	
	local IconBox = CreateCheckBox(MainFrame, L.IconOpt, "CharacterIcon")
	IconBox:SetPoint("BOTTOM", ClickMenuBox, 0, -30)
	
	local mapPosText = F.CreateFS(MainFrame, L.AnchorOpt, "LEFT")
	mapPosText:SetPoint("TOPLEFT", IconBox, "BOTTOMLEFT", 10, -10)
	
	local mapAnchor = CreateDropDown(MainFrame, 120, 20, optList, "MinimapAnchor")
	mapAnchor:SetPoint("LEFT", mapPosText, "RIGHT", 4, 0)
	
	local mapXText = F.CreateFS(MainFrame, L.XOpt, "LEFT")
	mapXText:SetPoint("LEFT", mapPosText, 0, -30)
	
	local mapXBox = CreateEditBox(MainFrame, 100, 20, "MinimapX")
	mapXBox:SetPoint("LEFT", mapXText, "RIGHT", 4, 0)
	
	local mapYText = F.CreateFS(MainFrame, L.YOpt, "LEFT")
	mapYText:SetPoint("LEFT", mapXText, 0, -30)
	
	local mapYBox = CreateEditBox(MainFrame, 100, 20, "MinimapY")
	mapYBox:SetPoint("LEFT", mapYText, "RIGHT", 4, 0)

	local mapSizeBar = CreateBar(MainFrame, "Size", 160, 20, 10, 20, 1)
	mapSizeBar:SetPoint("TOP", mapYText, "BOTTOM", 80, -34)
	mapSizeBar:SetValue(EKMinimapDB["MinimapScale"]*10)
	_G[mapSizeBar:GetName().."Low"]:SetText(1)
	_G[mapSizeBar:GetName().."High"]:SetText(2)
	
	local mapSizeText = F.CreateFS(mapSizeBar, L.SizeOpt.." "..EKMinimapDB["MinimapScale"], "LEFT")
	mapSizeText:SetPoint("BOTTOM", mapSizeBar, "TOP", 0, 5)
	
	mapSizeBar:SetScript("OnValueChanged", function(self)
		local n = tonumber(self:GetValue())
		if n then
			GLOBEVARIABLE("MinimapScale", n/10)
			--EKMinimapDB["MinimapScale"] = n/10
		end
		mapSizeText:SetText(L.SizeOpt.." "..EKMinimapDB["MinimapScale"], "LEFT")
	end)
	
	-- objective tracker
	
	local otfTitle = F.CreateFS(MainFrame, L.ObjectiveOpt, "LEFT", "TOPLEFT", 260, -30)
	
	local OTFBox = CreateCheckBox(MainFrame, L.ObjectiveStyleOpt, "ObjectiveStyle")
	OTFBox:SetPoint("TOP", MainFrame, 20, -60)
	
	local StarBox = CreateCheckBox(MainFrame, L.ObjectiveStarOpt, "ObjectiveStar")
	StarBox:SetPoint("BOTTOM", OTFBox, 0, -30)
	
	local otfPosText = F.CreateFS(MainFrame, L.AnchorOpt, "LEFT")
	otfPosText:SetPoint("TOPLEFT", StarBox, "BOTTOMLEFT", 10, -10)
	
	local otfAnchor = CreateDropDown(MainFrame, 120, 20, optList, "ObjectiveAnchor")
	otfAnchor:SetPoint("LEFT", otfPosText, "RIGHT", 4, 0)
	
	local otfXText = F.CreateFS(MainFrame, L.XOpt, "LEFT")
	otfXText:SetPoint("LEFT", otfPosText, 0, -30)
	
	local otfXBox = CreateEditBox(MainFrame, 100, 20, "ObjectiveX")
	otfXBox:SetPoint("LEFT", otfXText, "RIGHT", 4, 0)
	
	local otfYText = F.CreateFS(MainFrame, L.YOpt, "LEFT")
	otfYText:SetPoint("LEFT", otfXText, 0, -30)
	
	local otfYBox = CreateEditBox(MainFrame, 100, 20, "ObjectiveY")
	otfYBox:SetPoint("LEFT", otfYText, "RIGHT", 4, 0)

	local otfHeightBar = CreateBar(MainFrame, "Height", 160, 20, 200, 1200, 100)
	otfHeightBar:SetPoint("TOP", otfYText, "BOTTOM", 80, -34)
	otfHeightBar:SetValue(EKMinimapDB["ObjectiveHeight"])
	
	local otfHeightText = F.CreateFS(otfHeightBar, L.HeightOpt.." "..EKMinimapDB["ObjectiveHeight"], "LEFT")
	otfHeightText:SetPoint("BOTTOM", otfHeightBar, "TOP", 0, 5)
	
	otfHeightBar:SetScript("OnValueChanged", function(self)
		local n = tonumber(self:GetValue())
		if n then
			GLOBEVARIABLE("ObjectiveHeight", n)
			--EKMinimapDB["ObjectiveHeight"] = n
		end
		otfHeightText:SetText(L.HeightOpt.." "..EKMinimapDB["ObjectiveHeight"])
	end)
	
	-- infos
	
	local info = F.CreateFS(MainFrame, INFO, "LEFT", "BOTTOMLEFT", 30, 120)
	
	local q = CreateFrame("Button", nil, MainFrame)
	q:SetPoint("BOTTOMLEFT", MainFrame, 30, 60)
	q:SetSize(G.fontSize*3, G.fontSize*3)
	q.Icon = q:CreateTexture(nil, "ARTWORK")
	q.Icon:SetAllPoints()
	q.Icon:SetTexture("Interface\\HelpFrame\\HelpIcon-KnowledgeBase")
	q:SetHighlightTexture("Interface\\HelpFrame\\HelpIcon-KnowledgeBase")
	q:SetScript("OnEnter", function(self)
		GameTooltip:ClearLines()
		GameTooltip:SetOwner(self, "ANCHOR_LEFT", -20, 0)
		GameTooltip:AddLine(INFO)
		GameTooltip:AddLine(L.tempTip1, 1, 1, 1, true)
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(L.tempTip2, 1, 1, 1, true)
		GameTooltip:Show()
	end)
	q:SetScript("OnLeave", function() GameTooltip:Hide() end)
	
	local infoCmd = F.CreateFS(MainFrame, L.cmdInfo, "LEFT")
	infoCmd:SetPoint("TOPLEFT", q, "TOPRIGHT", 4, 8)
	
	local infoDrag = F.CreateFS(MainFrame, L.dragInfo, "LEFT")
	infoDrag:SetPoint("LEFT", q, "RIGHT", 4, 2)
	
	local infoScroll = F.CreateFS(MainFrame, L.scrollInfo, "LEFT")
	infoScroll:SetPoint("BOTTOMLEFT", q, "BOTTOMRIGHT", 4, -4)
	
	local infoApply = F.CreateFS(MainFrame, L.Apply, "LEFT", "BOTTOMLEFT", 30, 30)
	
	-- buttons
	
	local closeButton = CreateButton(MainFrame, 22, 22, "X")
	closeButton:SetPoint("TOPRIGHT", MainFrame, -8, -8)
	closeButton:SetScript("OnClick", function() MainFrame:Hide() end)
	
	local reloadButton = CreateButton(MainFrame, 80, 30, APPLY)
	reloadButton:SetPoint("BOTTOMRIGHT", MainFrame, -20, 20)
	reloadButton:SetScript("OnClick", function() ReloadUI() end)
	
	local reposButton = CreateButton(MainFrame, 170, 30, L.posApply)
	reposButton:SetPoint("BOTTOMRIGHT", MainFrame, -20, 60)
	reposButton:SetScript("OnClick", function() F.ResetM() F.ResetO() end)
	
	local i = CreateFrame("Button", nil, MainFrame)
	i:SetPoint("TOPRIGHT", reposButton, 8, 8)
	i:SetSize(G.fontSize+2, G.fontSize+2)
	i.Icon = i:CreateTexture(nil, "ARTWORK")
	i.Icon:SetAllPoints()
	i.Icon:SetTexture("Interface\\FriendsFrame\\InformationIcon")
	i:SetHighlightTexture("Interface\\FriendsFrame\\InformationIcon")
	i:SetScript("OnEnter", function(self)
		GameTooltip:ClearLines()
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT", 0, 0)
		GameTooltip:AddLine(INFO)
		GameTooltip:AddLine(L.tempTip3, 1, 1, 1, true)
		GameTooltip:Show()
	end)
	i:SetScript("OnLeave", function() GameTooltip:Hide() end)
	
	local resetButton = CreateButton(MainFrame, 80, 30, RESET)
	resetButton:SetPoint("RIGHT", reloadButton, "LEFT", -10, 0)
	resetButton:SetScript("OnClick", function()
		EKMinimapDB = C.defaultSettings
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

	-- HopeASD, Felix S., sakaras, ape47, 
	-- iMinimap by Chiril, ooMinimap by Ooglogput, intMinimap by Int0xMonkey
	-- DifficultyID list
	-- https://wow.gamepedia.com/DifficultyID
	-- rStatusButton by zork
	-- https://www.wowinterface.com/downloads/info24772-rStatusButton.html
	-- Hide order hall bar
	-- https://github.com/destroyerdust/Class-Hall
	-- NeavUI by Neal: https://www.wowinterface.com/downloads/info13981-NeavUI.html#info
	-- ClickMenu by 10leej: https://www.wowinterface.com/downloads/info22660-ClickMenu.html