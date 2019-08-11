local C, G = unpack(select(2, ...))

if not C.QuestWatch then return end

-- [[ Anchor ]] --

local QWF = QuestWatchFrame

local function SetQWF()
	-- parent frame
	--QWF:SetClampedToScreen(true)
	QWF:ClearAllPoints()	
	QWF:SetPoint(unpack(C.WatchFrame))
	QWF:SetMovable(true)
	QWF:SetUserPlaced(true)
end

-- [[ Moveable ]] --

-- Make a Frame for Drag / 創建一個供移動的框架
local QWFMove = CreateFrame("FRAME", "QWFdrag", QWF)
	-- Create frame for click
	QWFMove:SetSize(140, G.QfontSize + 2)
	QWFMove:SetPoint("TOPLEFT", QWF, 0, G.QfontSize)
	QWFMove:SetFrameStrata("HIGH")
	QWFMove:EnableMouse(true)
	-- Make it drag-able
	QWFMove:RegisterForDrag("RightButton")
	QWFMove:SetHitRectInsets(-5, -5, -5, -5)
	-- Alt+right click to drag frame
	QWFMove:SetScript("OnDragStart", function(self, button)
		if IsAltKeyDown() then
			local frame = self:GetParent()
			frame:StartMoving()
		end
	end)
	QWFMove:SetScript("OnDragStop", function(self, button)
		local frame = self:GetParent()
		frame:StopMovingOrSizing()
	end)

-- [[ Skin ]] --

local function SetQWFText()
	local HeaderBar = CreateFrame("StatusBar", nil, QWF)
	local HeaderText = HeaderBar:CreateFontString(nil, "OVERLAY")
	
	-- title line
	HeaderBar:SetSize(140, 3)
	HeaderBar:SetPoint("TOPLEFT", QWF, 0, -2)
	HeaderBar:SetStatusBarTexture(G.Tex)
	HeaderBar:SetStatusBarColor(G.Ccolors.r, G.Ccolors.g, G.Ccolors.b)

	sd = CreateFrame("Frame", nil, HeaderBar)
	sd:SetPoint("TOPLEFT", -3, 3)
	sd:SetPoint("BOTTOMRIGHT", 3, -3)
	sd:SetFrameStrata(HeaderBar:GetFrameStrata())
	sd:SetFrameLevel(0)
	sd:SetBackdrop({edgeFile = G.glow, edgeSize = 3,})
	sd:SetBackdropBorderColor(0, 0, 0)

	-- title
	HeaderText:SetFont(G.font, G.QfontSize, G.QfontFlag)
	HeaderText:SetTextColor(G.Ccolors.r, G.Ccolors.g, G.Ccolors.b)
	HeaderText:SetShadowOffset(0, 0)
	HeaderText:SetPoint("LEFT", HeaderBar, "LEFT", -2, G.QfontSize)
	HeaderText:SetText(CURRENT_QUESTS)
	
	-- Change font of watched quests
	for i = 1, 30 do
		local Line = _G["QuestWatchLine"..i]

		Line:SetFont(G.font, G.QfontSize-2, G.QfontFlag)
		Line:SetHeight(G.QfontSize+2)
		Line:SetShadowOffset(0, 0)
	end
end

local function LoadAddon()
	SetQWF()
	SetQWFText()
end

local function eventHandler(self, event, ...)
	LoadAddon()
end 

local EVENT = CreateFrame("FRAME", "defaultsetting")
	EVENT:RegisterEvent("PLAYER_LOGIN")
	EVENT:RegisterEvent("PLAYER_ENTERING_WORLD")
	EVENT:SetScript("OnEvent", eventHandler)