local C, G = unpack(select(2, ...))

if not C.QuestWatch then return end

-- [[ Position ]] --

local QWF = QuestWatchFrame
	QWF:SetClampedToScreen(true)
	QWF:SetMovable(true)
	QWF:SetUserPlaced(true)
	QWF:ClearAllPoints()
	QWF.ClearAllPoints = function() end
	--QWF:SetPoint("TOPLEFT", UIParent, "TOPRIGHT", -300, -200)
	QWF:SetPoint(unpack(C.QWF))
	QWF.SetPoint = function() end

-- [[ Moveable ]] --

  --tooltip for icon func
local function QWF_Tooltip(self)
	GameTooltip:SetOwner(self, "ANCHOR_TOP")
	GameTooltip:AddLine(DRAG_MODEL, 0, 1, 0.5, 1, 1, 1)
	GameTooltip:Show()
end

-- Make a Frame for Drag / 創建一個供移動的框架
local QWFMove = CreateFrame("FRAME", "QWFdrag", QWF)
	-- Create frame for click
	QWFMove:SetSize(140, G.QfontSize + 2)
	QWFMove:SetPoint("TOPLEFT", QWF, 0, G.QfontSize)
	QWFMove:SetFrameStrata("BACKGROUND")
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
	-- Show tooltip for drag
	QWFMove:SetScript("OnEnter", function(self)
		QWF_Tooltip(self)
	end)
	QWFMove:SetScript("OnLeave", function(self)
		GameTooltip:Hide()
	end)
	-- Reset / 重置
	SlashCmdList["RESETQUEST"] = function() 
		QWF:SetUserPlaced(false)
		ReloadUI()
	end
	SLASH_RESETQUEST1 = "/resetquest"
	SLASH_RESETQUEST2 = "/rq"

-- [[ Style ]] --

local HeaderBar = CreateFrame("StatusBar", nil, QWF)
local HeaderText = HeaderBar:CreateFontString(nil, "OVERLAY")

	-- title line
	HeaderBar:SetSize(140, 3)
	HeaderBar:SetPoint("TOPLEFT", QWF, 0, -2)
	HeaderBar:SetStatusBarTexture(G.Tex)
	HeaderBar:SetStatusBarColor(G.Ccolors.r, G.Ccolors.g, G.Ccolors.b)
	-- title line shadow
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