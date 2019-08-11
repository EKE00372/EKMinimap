local C, G = unpack(select(2, ...))

if not C.objectFrame then return end

-- [[ Anchor ]] --

local OTF = QuestWatchFrame

local function SetOTF()
	OTF:SetClampedToScreen(true)
	OTF:ClearAllPoints()
	--OTF:SetPoint("TOP", Minimap, "BOTTOM", -100, -60)
	OTF:SetPoint(unpack(C.WatchFrame))
	OTF:SetHeight(C.height)
	OTF:SetMovable(true)
	OTF:SetUserPlaced(true)
end

-- [[ Skin ]] --

local function SetOTFText()
	local HeaderBar = CreateFrame("StatusBar", nil, QuestWatchFrame)
	local HeaderText = HeaderBar:CreateFontString(nil, "OVERLAY")
	
	HeaderBar:SetSize(QuestWatchFrame:GetWidth(), 2)
	HeaderBar:SetPoint("TOPLEFT", QuestWatchFrame, 0, -2)
	HeaderBar:SetStatusBarTexture(G.Tex)
	HeaderBar:SetStatusBarColor(G.Ccolors.r, G.Ccolors.g, G.Ccolors.b)

	sd = CreateFrame("Frame", nil, HeaderBar)
	sd:SetPoint("TOPLEFT", -3, 3)
	sd:SetPoint("BOTTOMRIGHT", 3, -3)
	sd:SetFrameStrata(HeaderBar:GetFrameStrata())
	sd:SetFrameLevel(0)
	sd:SetBackdrop({edgeFile = G.glow, edgeSize = 3,})
	sd:SetBackdropBorderColor(0, 0, 0)

	HeaderText:SetFont(G.font, G.obfontSize, G.obfontFlag)
	HeaderText:SetTextColor(G.Ccolors.r, G.Ccolors.g, G.Ccolors.b)
	HeaderText:SetShadowOffset(0, 0)
	HeaderText:SetPoint("LEFT", HeaderBar, "LEFT", -2, 18)
	HeaderText:SetText(CURRENT_QUESTS)
	
	-- Change font of watched quests
	for i = 1, 30 do
		local Line = _G["QuestWatchLine"..i]

		Line:SetFont(G.font, G.obfontSize-2, G.obfontFlag)
		Line:SetHeight(G.obfontSize)
		Line:SetShadowOffset(0, 0)
	end
end

local function loadAddon()
	SetOTF()
	SetOTFText()
end

local function eventHandler(self, event, ...)
	loadAddon() 
end 

local EVENT = CreateFrame("FRAME", "defaultsetting")
	EVENT:RegisterEvent("PLAYER_LOGIN")
	EVENT:RegisterEvent("PLAYER_ENTERING_WORLD")
	EVENT:RegisterEvent("VARIABLES_LOADED")
	EVENT:SetScript("OnEvent", eventHandler)
