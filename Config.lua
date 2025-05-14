local addon, ns = ...
local C, F, G, L = unpack(ns)

local v = C_AddOns.GetAddOnMetadata("EKMinimap", "Version")
local CreateFrame, tonumber, pairs, tinsert = CreateFrame, tonumber, pairs, table.insert
local MainFrame = MainFrame

------
	
	-- EKMinimap 現在有了遊戲內控制台，請輸入 /ekm 或 /ekminimap 打開控制台更改設定
	-- EKMinimap have in-game config. type /ekm or /ekminimap to toggle options

------

--===================================================--
-----------------    [[ Initial	]]    -----------------
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

-- 取 InterfaceOptionsCheckButtonTemplate 的預設高度，通常是 26
local function GetBlizzardButtonHeight()
    if not F._CHECKBOX_ROW_H then
        local dummy = CreateFrame("CheckButton", nil, UIParent, "InterfaceOptionsCheckButtonTemplate")
        F._CHECKBOX_ROW_H = dummy:GetHeight()
        dummy:Hide() -- 取完扔掉，節省開銷
    end
    return F._CHECKBOX_ROW_H
end


-- click buttons
local function CreateButton(self, width, height, text)
	local bu = CreateFrame("Button", nil, self)
	bu:SetSize(width, height)
	bu.bg = F.CreateBG(bu, 3, 3, .5)
	
	bu:SetNormalTexture(0)
	bu:SetHighlightTexture(0)
	bu:SetPushedTexture(0)
	bu:SetDisabledTexture(0)
	
	bu.Text = F.CreateFS(bu, text, G.fontSize, "CENTER", "CENTER", 0, 0)
	
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
	
	cb.text = F.CreateFS(cb, text,  G.fontSize, "LEFT")
	cb.text:SetPoint("LEFT", cb, "RIGHT", 4, 0)
	
	return cb
end

-- edit box
local function CreateEditBox(self, text, width, height, value)
	-- 建立容器，打包選項名字和輸入框
	local container = CreateFrame("Frame", nil, self)
    container:SetSize(1, GetBlizzardButtonHeight())
	-- 選項名字
    container.text = F.CreateFS(container, text, G.fontSize, "LEFT")
    container.text:SetPoint("LEFT", container, "LEFT", 0, 0)
	-- 輸入框
    local eb = CreateFrame("EditBox", nil, container)
	eb:SetSize(width, height)
	eb:SetPoint("LEFT", container.text, "RIGHT", 4, 0) 
	eb.bg = F.CreateBG(eb, 3, 3, .5)
	eb:SetAutoFocus(false)
	
	eb:SetTextInsets(5, 5, 0, 0)
	eb:SetMaxLetters(10)
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
	
	-- 對齊 container，取值用 container.editBox:GetText()
	container.editBox = eb
	return container
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
local function CreateDropDown(self, text, width, height, data, value)
	-- 建立容器，打包選項名字和選單
	local container = CreateFrame("Frame", nil, self)
	container:SetSize(1, GetBlizzardButtonHeight())
	-- 選項名字
	container.text = F.CreateFS(container, text, G.fontSize, "LEFT")
	container.text:SetPoint("LEFT", container, "LEFT", 0, 0)
	-- 選單
	local dd = CreateFrame("Frame", nil, container)
	dd:SetSize(width, height)
	dd:SetPoint("LEFT", container.text, "RIGHT", 4, 0) 
	dd.bg = F.CreateBG(dd, 3, 3, .5)
	dd.options = {}
	
	dd.Text = F.CreateFS(dd, "",  G.fontSize, "CENTER", 0, 0)
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
		
		local text = F.CreateFS(opt[i], j,  G.fontSize, "CENTER", "LEFT", 5, 0)
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

	container.dd = dd
	return container
end

-- slider bar
local function CreateBar(self, name, width, height, min, max, step, value, text, coeff)
	local s = CreateFrame("Slider", name.."Bar", self, "OptionsSliderTemplate")
	s:SetSize(width, height)
	_G[s:GetName().."Low"]:SetText(min * coeff)
	_G[s:GetName().."High"]:SetText(max * coeff)
	
	s:SetMinMaxValues(min, max)
	s:SetObeyStepOnDrag(true)
	s:SetValueStep(step)
	s:SetOrientation("HORIZONTAL")
	
	s:SetValue(GLOBEVARIABLE(value)/coeff)
	
	s.text = F.CreateFS(s, text.." "..GLOBEVARIABLE(value),  G.fontSize, "LEFT")
	s.text:SetPoint("BOTTOM", s, "TOP", 0, 5)
	
	s:SetScript("OnValueChanged", function(self)
		local n = tonumber(self:GetValue())
		if n then
			GLOBEVARIABLE(value, n * coeff)
		end
		s.text:SetText(text.." "..GLOBEVARIABLE(value), "LEFT")
	end)
	
	return s
end

-- tooltip
local function CreateTooltip(self, tex, anchor, text)
	local i = CreateFrame("Button", nil, self)
	--local f = i:GetParent()
	i:SetSize(G.fontSize+2, G.fontSize+2)
	--i:SetFrameLevel(f:GetFrameLevel()+2)
	i.Icon = i:CreateTexture(nil, "ARTWORK")
	i.Icon:SetAllPoints()
	i.Icon:SetTexture(tex)
	i:SetHighlightTexture(tex)
	
	i:SetScript("OnEnter", function(self)
		GameTooltip:ClearLines()
		GameTooltip:SetOwner(self, anchor, 0, 0)
		GameTooltip:AddLine(text, 1, 1, 1, true)
		GameTooltip:Show()
	end)
	i:SetScript("OnLeave", function() GameTooltip:Hide() end)
	
	return i
end

--===============================================--
-----------------    [[ GUI ]]    -----------------
--===============================================--

F.CreateEKMOptions = function()
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
	local Title = F.CreateFS(MainFrame, "|cff00ffffEK|rMinimap "..v,  G.fontSize+6, "CENTER", "TOP", 0, 14)

	-- minimap / 小地圖
	local mapTitle = F.CreateFS(MainFrame,  MINIMAP_LABEL, G.fontSize+2, "LEFT", "TOPLEFT", 30, -30)

	-- 選項表
	local optionData = {
		-- CheckBox
		{ type = "check", text = L.ClickMenuOpt,  key = "ClickMenu"      },
		{ type = "check", text = L.HoverClockOpt, key = "HoverClock"     },
		{ type = "check", text = L.IconOpt,       key = "CharacterIcon"  },
		{ type = "check", text = L.TrackingOpt,   key = "Tracking"       },
		{ type = "check", text = L.QueueOpt,      key = "QueueStatus"    },
		-- DropDown
		{ type = "dropdown", text = L.AnchorOpt,  key = "MinimapAnchor", width = 120, height = 20, data = optList },
		-- EditBox
		{ type = "edit", text = L.XOpt, key = "MinimapX", width = 100, height = 20 },
		{ type = "edit", text = L.YOpt, key = "MinimapY", width = 100, height = 20 },
	}

	local function CreateOption(parent, cfg)
		if cfg.type == "check" then
			return CreateCheckBox(parent, cfg.text, cfg.key)
		elseif cfg.type == "dropdown" then
			return CreateDropDown(parent, cfg.text, cfg.width, cfg.height, cfg.data, cfg.key)
		elseif cfg.type == "edit" then
			return CreateEditBox(parent, cfg.text, cfg.width, cfg.height, cfg.key)
		end
	end

	-- 建立選項
	local prevWidget, QueueBox -- 前一個選項元件用來決定錨點，最後一個選項元件給之後的選項定位用
	local padding = 4   -- 間距

	for i, cfg in ipairs(optionData) do
		local w = CreateOption(MainFrame, cfg)

		if i == 1 then
			w:SetPoint("TOPLEFT", MainFrame, 40, -60)
		else
			local offset = -(prevWidget:GetHeight() + padding)
			w:SetPoint("TOPLEFT", prevWidget, "TOPLEFT", 0, offset)
		end

		prevWidget = w
		if cfg.key == "QueueStatus" then QueueBox = w end
	end

	local mapSizeBar = CreateBar(MainFrame, "Size", 160, 20, 5, 20, 1, "MinimapScale", L.SizeOpt, .1)
	mapSizeBar:SetPoint("TOP", prevWidget, "BOTTOM", 75, -34)

	-- infos
	
	local info = F.CreateFS(MainFrame, INFO,  G.fontSize+2, "LEFT", "TOPLEFT", 260, -210)
	local q = CreateTooltip(MainFrame, G.Question, "ANCHOR_LEFT", L.tempTip1.."\n\n"..L.tempTip2)
	q:SetPoint("TOPLEFT", MainFrame, 260, -230)
	q:SetSize(G.fontSize*3, G.fontSize*3)
	
	local infoDrag = F.CreateFS(MainFrame, L.dragInfo, G.fontSize, "LEFT")
	infoDrag:SetPoint("LEFT", q, "RIGHT", 4, 2)
	
	local infoScroll = F.CreateFS(MainFrame, L.scrollInfo, G.fontSize, "LEFT")
	infoScroll:SetPoint("BOTTOMLEFT", q, "BOTTOMRIGHT", 4, -4)
	
	local infoApply = F.CreateFS(MainFrame, L.Apply,  G.fontSize, "LEFT", "TOPLEFT", 260, -290)
	
	-- buttons
	
	local closeButton = CreateButton(MainFrame, 22, 22, "X")
	closeButton:SetPoint("TOPRIGHT", MainFrame, -8, -8)
	closeButton:SetScript("OnClick", function() MainFrame:Hide() end)
	
	local reloadButton = CreateButton(MainFrame, 80, 30, APPLY)
	reloadButton:SetPoint("BOTTOMRIGHT", MainFrame, -20, 20)
	reloadButton:SetScript("OnClick", function() ReloadUI() end)
	
	local reposButton = CreateButton(MainFrame, 170, 30, L.posApply)
	reposButton:SetPoint("BOTTOMRIGHT", MainFrame, -20, 60)
	reposButton:SetScript("OnClick", function() F.ResetM() end)
	
	local i = CreateTooltip(reposButton, G.Info, "ANCHOR_RIGHT", L.tempTip3)
	i:SetPoint("TOPRIGHT", reposButton, 8, 8)

	local resetButton = CreateButton(MainFrame, 80, 30, RESET)
	resetButton:SetPoint("RIGHT", reloadButton, "LEFT", -10, 0)
	resetButton:SetScript("OnClick", function()
		EKMinimapDB = C.defaultSettings
		ReloadUI()
	end)
end

SlashCmdList["EKMINIMAP"] = function()
	F.CreateEKMOptions()
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