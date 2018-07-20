-- [[ Credit ]] --

-- Felix S. , sakaras, ape47, iMinimap by Chiril, ooMinimap by Ooglogput, intMinimap by Int0xMonkey

-- [[ Config ]] --

-- shift+alt������D���ʡA/rm ���m�p�a�Ϧ�m�A/ro���m���ȦC���m�Aalt����ctrl���
local Scale = 1  					-- �Y��/Scale
local x , y = 10, -20 				-- �y��/Position
local AnchorPoint = "TOPLEFT" 		-- ���I/Anchor point 
local Announce = false  			-- ��ƾ䦳�ܽЮɰ��G���/show yellow border when get invite

-- [[ style ]] --

-- class color / ¾�~�C��
local ClassColor = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[select(2,UnitClass("player"))]

-- Create font Style / �r��
local function CreateFS(parent, size, justify)
	local frame = parent:CreateFontString(nil, "OVERLAY") 
	frame:SetFont(GameFontNormal:GetFont(), 14, "THINOUTLINE")
	frame:SetShadowColor(0, 0, 0, 0)
	frame:SetShadowOffset(0, 0)
	if justify then
		frame:SetJustifyH(justify)
	end
	return frame
end

-- [[ Core ]] --

local Minimap = Minimap

-- Make A Square / �˦��諬
function GetMinimapShape()
	return "SQUARE"
end
--Minimap:SetHitRectInsets(left, right, top, bottom)	-- �ͭn�誺 ���n��
Minimap:SetMaskTexture("Interface\\Buttons\\WHITE8x8")
Minimap:SetSize(160, 160)
Minimap:SetScale(Scale)
Minimap:SetFrameStrata("LOW")
Minimap:SetFrameLevel(3)

Minimap:ClearAllPoints()
Minimap:SetPoint(AnchorPoint, UIParent, x, y)
MinimapCluster:ClearAllPoints()
MinimapCluster:SetAllPoints(Minimap)

-- Shift+Alt+Drag to move / shift+alt������
Minimap:SetMovable(true)
Minimap:EnableMouse(true)
Minimap:RegisterForDrag("RightButton")
Minimap:SetScript("OnDragStart", function(self)
	if IsAltKeyDown() then
		self:StartMoving()
	end
end)
Minimap:SetScript("OnDragStop", function(self)
	self:StopMovingOrSizing()
end)

-- Reset place / ���m��m
Minimap:SetUserPlaced(true)
SlashCmdList["RESETMINIMAP"] = function() 
    Minimap:SetUserPlaced(false)
    ReloadUI()
end
SLASH_RESETMINIMAP1 = "/resetminimap"
SLASH_RESETMINIMAP2 = "/rm"

-- Background / �I��
local Background = Minimap:CreateTexture(nil, "BACKGROUND")
Background:SetTexture("Interface\\Buttons\\WHITE8x8")
Background:SetPoint("TOPLEFT", Minimap , "TOPLEFT", -1, 1)
Background:SetPoint("BOTTOMRIGHT", Minimap , "BOTTOMRIGHT", 1, -1)
Background:SetVertexColor(0, 0, 0)

Background.shadow = CreateFrame("Frame", nil, Minimap)
Background.shadow:SetPoint("TOPLEFT", -5, 5)
Background.shadow:SetPoint("BOTTOMRIGHT", 5, -5)
Background.shadow:SetFrameStrata(Minimap:GetFrameStrata())
Background.shadow:SetFrameLevel(Minimap:GetFrameLevel()-1)
Background.shadow:SetFrameLevel(0)
Background.shadow:SetBackdrop({edgeFile = "Interface\\addons\\EKMinimap\\Media\\glow", edgeSize = 5,})
Background.shadow:SetBackdropBorderColor(0,0,0)

-- ���ö��
Minimap:SetArchBlobRingScalar(0)
Minimap:SetQuestBlobRingScalar(0)

-- Border Announce for Calendar / ��ƾ䦳�ܽЮ��ܶ�
local CalendarAnnouncer = CreateFrame("Frame")
CalendarAnnouncer:SetScript("OnEvent", function(self, event, ...)
	if Announce then
		if CalendarGetNumPendingInvites() > 0 then
			Background:SetVertexColor(1, 1, 0)
		else
			Background:SetVertexColor(0, 0, 0)
		end
	else return end
end)
CalendarAnnouncer:RegisterEvent("CALENDAR_UPDATE_PENDING_INVITES")
CalendarAnnouncer:RegisterEvent("PLAYER_ENTERING_WORLD")

-- Better Place For World State Frame / �Գ��귽��
--[[local function WorldStateFix()
	WorldStateAlwaysUpFrame:ClearAllPoints()
	WorldStateAlwaysUpFrame:SetPoint("TOP", "UIParent", "TOP", 0, -10)
	for i = 1, NUM_ALWAYS_UP_UI_FRAMES do
		local frame = _G["AlwaysUpFrame" .. i]
		
		local text = _G["AlwaysUpFrame" .. i .. "Text"]
		text:ClearAllPoints()
		text:SetPoint("CENTER", frame, "CENTER", -i, 0)
		text:SetFont(GameFontNormal:GetFont(), 14, "OUTLINE")
		text:SetShadowColor(0, 0, 0, 0)
		text:SetJustifyH("CENTER")
		
		local icon = _G["AlwaysUpFrame" .. i .. "Icon"]
		icon:ClearAllPoints()
		icon:SetPoint("RIGHT", text, "LEFT", 12, -8)
	end
end
hooksecurefunc("WorldStateAlwaysUpFrame_Update", WorldStateFix)]]--

--BattlegroundChatFiltersMisin
-- [[ Hide Script ]] --

-- Hide Clock / ���î���
local ClockFrame = CreateFrame("Frame", nil, UIParent)
ClockFrame:SetScript("OnEvent", function(self, event, name)
	 if name == "Blizzard_TimeManager" then
		  TimeManagerClockButton:Hide()
		  TimeManagerClockButton:SetScript("OnShow", function(self)
				TimeManagerClockButton:Hide()
		  end)
	 end
end)
ClockFrame:RegisterEvent("ADDON_LOADED")

-- Hide All / ���æU��
local HideAll = {
	"MinimapBorder",
	"MinimapBorderTop",
	"MinimapNorthTag",
	"MiniMapWorldMapButton",
	"MinimapZoneTextButton",
	"MinimapZoomIn",
	"MinimapZoomOut",
	"GameTimeFrame",
	"MiniMapTracking",
	"ZoneTextFrame",
	"SubZoneTextFrame",
	"MiniMapChallengeMode",
	"DurabilityFrame",
	"VehicleSeatIndicator",
}
for i, v in pairs(HideAll) do
	getglobal(v).Show = function() end
	getglobal(v):Hide()
	--getglobal(v):UnregisterAllEvents()
end

-- [[ Indicator ]] --

-- Queue Button /��C�ϥ�
QueueStatusMinimapButton:ClearAllPoints()
QueueStatusMinimapButton:SetParent(Minimap)
if AnchorPoint == "TOPLEFT" or AnchorPoint == "BOTTOMLEFT" then
	QueueStatusMinimapButton:SetPoint("TOPRIGHT", Minimap, 0, 0)
else
	QueueStatusMinimapButton:SetPoint("TOPLEFT", Minimap, 0, 0)
end
QueueStatusMinimapButtonBorder:Hide()
QueueStatusMinimapButton:SetFrameLevel(10)

-- Queue Tooltip fix / �ƹ����ܦ�m�վ�
if AnchorPoint == "TOPLEFT" or AnchorPoint == "BOTTOMLEFT" then
	QueueStatusFrame:ClearAllPoints()
	QueueStatusFrame:SetPoint("TOPRIGHT", Minimap, "TOPRIGHT", 282, -10)
else
	QueueStatusFrame:ClearAllPoints()
	QueueStatusFrame:SetPoint("TOPLEFT", Minimap, "TOPLEFT", -282, -10)
end

-- Mail Frame / �H�󴣥�
MiniMapMailFrame:ClearAllPoints()
MiniMapMailFrame:SetParent(Minimap)
if AnchorPoint == "TOPLEFT" or AnchorPoint == "BOTTOMLEFT" then
	MiniMapMailFrame:SetPoint("BOTTOMLEFT", Minimap, 0, 0)
else
	MiniMapMailFrame:SetPoint("BOTTOMRIGHT", Minimap, 0, 0)
end
MiniMapMailBorder:Hide()
MiniMapMailIcon:SetTexture("Interface\\AddOns\\EKMinimap\\Media\\mail.tga")
--MiniMapMailIcon:SetTexture("Interface\\HelpFrame\\ReportLagIcon-Mail.blp")
--MiniMapMailIcon:SetSize(24,24)

-- Garrison Icon / �n��M¾�~�j�U
GarrisonLandingPageMinimapButton:ClearAllPoints()
GarrisonLandingPageMinimapButton:SetParent(Minimap)
if AnchorPoint == "TOPLEFT" or AnchorPoint == "BOTTOMLEFT" then
	GarrisonLandingPageMinimapButton:SetPoint("BOTTOMRIGHT", Minimap, -3, 5)
else
	GarrisonLandingPageMinimapButton:SetPoint("BOTTOMLEFT", Minimap, 3, 5)
end
hooksecurefunc("GarrisonLandingPageMinimapButton_UpdateIcon", function(button)
	button:GetNormalTexture():SetTexture("Interface\\HelpFrame\\HelpIcon-ReportLag.blp")
		button:GetPushedTexture():SetTexture("Interface\\HelpFrame\\HelpIcon-ReportLag.blp")
	end)
GarrisonLandingPageMinimapButton:SetScale(0.5)

-- Oderhall Mouseover FadeIn / �H�X�H�J
GarrisonLandingPageMinimapButton:SetAlpha(0)
GarrisonLandingPageMinimapButton:SetScript("OnEnter", function()
	securecall(UIFrameFadeIn, GarrisonLandingPageMinimapButton, 0.4, 0, 1)
end)
GarrisonLandingPageMinimapButton:SetScript("OnLeave", function()
	securecall(UIFrameFadeOut, GarrisonLandingPageMinimapButton, 0.8, 1, 0)
end)

-- MiniMapTracking / �p�a�ϰl��
--[[MiniMapTracking:SetParent(Minimap)
MiniMapTracking:SetScale(0.8)
MiniMapTracking:ClearAllPoints()
MiniMapTracking:SetPoint("BOTTOM", GarrisonLandingPageMinimapButton, "TOP", 0, 0)
MiniMapTrackingButton:SetNormalTexture("Interface\\HelpFrame\\HelpIcon-CharacterStuck.blp")
--MiniMapTrackingButton:SetHighlightTexture(nil)
MiniMapTrackingButton:SetPushedTexture(nil)
MiniMapTrackingBackground:Hide()
MiniMapTrackingButtonBorder:Hide()

MiniMapTracking:SetAlpha(0)
MiniMapTrackingButton:SetScript("OnEnter", function()
	securecall(UIFrameFadeIn, MiniMapTracking, 0.4, 0, 1)
end)
MiniMapTrackingButton:SetScript("OnLeave", function()
	securecall(UIFrameFadeOut, MiniMapTracking, 0.8, 1, 0)
end)
]]--
-- [[ Instance Difficulty ]] -- 

-- Hide Blizzard / ���üɳ������׺X�l
MiniMapInstanceDifficulty:Hide()
MiniMapInstanceDifficulty.Show = function() return end
GuildInstanceDifficulty:Hide()
GuildInstanceDifficulty.Show = function() return end

-- Creat Frame / �Ыخ���
local RaidDifficulty = CreateFrame("Frame", nil, Minimap)
RaidDifficulty:SetSize(44, 44)
if AnchorPoint == "TOPLEFT" or AnchorPoint == "BOTTOMLEFT" then
	RaidDifficulty:SetPoint("TOPLEFT", Minimap,  -5, 5)
else
	RaidDifficulty:SetPoint("TOPRIGHT", Minimap, 5, 5)
end
RaidDifficulty.Texture = RaidDifficulty:CreateTexture(nil, 'OVERLAY')
RaidDifficulty.Texture:SetAllPoints(true)
RaidDifficulty.Texture:SetTexture("Interface\\AddOns\\EKMinimap\\Media\\difficulty.tga")
RaidDifficulty.Texture:SetAlpha(.8)
RaidDifficulty.Texture:SetVertexColor(ClassColor.r, ClassColor.g, ClassColor.b)
RaidDifficulty:Hide()
RaidDifficulty:RegisterEvent("PLAYER_ENTERING_WORLD")
RaidDifficulty:RegisterEvent("PLAYER_DIFFICULTY_CHANGED")
RaidDifficulty:RegisterEvent("GUILD_PARTY_STATE_UPDATED")
RaidDifficulty:RegisterEvent("INSTANCE_GROUP_SIZE_CHANGED")
RaidDifficulty:RegisterEvent("ZONE_CHANGED_NEW_AREA")
RaidDifficulty:RegisterEvent("CHALLENGE_MODE_START")
RaidDifficulty:RegisterEvent("CHALLENGE_MODE_COMPLETED")
RaidDifficulty:RegisterEvent("CHALLENGE_MODE_RESET")

-- Difficulty Text / ���פ�r
local RaidDifficultyText = CreateFS(RaidDifficulty, 10, "CENTER")
RaidDifficultyText:SetPoint("CENTER")

-- Difficulty / �a������(�P���|�ζ�)
RaidDifficulty:SetScript("OnEvent", function()
	local _, instanceType = IsInInstance()
	local difficulty = select(3, GetInstanceInfo())
	local num = select(9, GetInstanceInfo())
	--local _, instanceType, difficulty, _, _, _, _, _, instanceGroupSize = GetInstanceInfo()
	local mplus = select(1, C_ChallengeMode.GetActiveKeystoneInfo()) or ""
	
	if instanceType == "party" or instanceType == "raid" or instanceType == "scenario" then
		if difficulty == 1 then
			RaidDifficultyText:SetText("5N")
		elseif difficulty == 2 then
			RaidDifficultyText:SetText("5H")
		elseif difficulty == 3 then
			RaidDifficultyText:SetText("10N")
		elseif difficulty == 4 then
			RaidDifficultyText:SetText("25N")
		elseif difficulty == 5 then
			RaidDifficultyText:SetText("10H")
		elseif difficulty == 6 then
			RaidDifficultyText:SetText("25H")
		elseif difficulty == 7 then
			RaidDifficultyText:SetText("LFR")
		elseif difficulty == 8 then
			RaidDifficultyText:SetText("M"..mplus)	-- Challenge Mode and Mythic+
		elseif difficulty == 9 then
			RaidDifficultyText:SetText("40R")
		elseif difficulty == 11	then
			RaidDifficultyText:SetText("3H")
		elseif difficulty == 12	then 
			RaidDifficultyText:SetText("3N")
		elseif difficulty == 14	then
			RaidDifficultyText:SetText(num .. "N")
		elseif difficulty == 15	then
			RaidDifficultyText:SetText(num .. "H")
		elseif difficulty == 16	then
			RaidDifficultyText:SetText("M")
		elseif difficulty == 17	then
			RaidDifficultyText:SetText(num .. "L")
		elseif difficulty == 18 or difficulty == 19 or difficulty == 20 then
			RaidDifficultyText:SetText("E")
		elseif difficulty == 23	then
			RaidDifficultyText:SetText("5M")
		elseif difficulty == 24 then
			RaidDifficultyText:SetText("T")
		end
	elseif instanceType == "pvp" or instanceType == "arena" then
		RaidDifficultyText:SetText("PVP")
	else
		RaidDifficultyText:SetText("")
	end
	
	if not IsInInstance() then
		RaidDifficulty:Hide()
	else
		RaidDifficulty:Show()
	end
	
	--[[if GuildInstanceDifficulty:IsShown() then
		RaidDifficultyText:SetTextColor(0, .9, 0)
	else
		RaidDifficultyText:SetTextColor(1, 1, 1)
	end]]--
end)

-- [[ Misc ]] --

-- Scroll Zoom, Alt+Scroll Scale / �u���Y��ϰ�Aalt�u���Y��j�p
local function OnMouseWheel(self, delta)
	if IsAltKeyDown() then
		local i = Minimap:GetScale()
		 if delta > 0 and i < 4 then
			Minimap:SetScale(i+0.1)
		 elseif delta < 0 and i > 0.5 then
			Minimap:SetScale(i-0.1)
		end
	else
		if delta > 0 then
			Minimap_ZoomIn()
		else
			Minimap_ZoomOut()
		end
	end
end
Minimap:SetScript("OnMouseWheel", OnMouseWheel)

-- Show minimap ping / ��ܽ��I���F�p�a��
local WhoPing = CreateFrame("Frame", nil, Minimap)
WhoPing:SetSize(100, 20)
WhoPing:SetPoint("BOTTOM", Minimap, 0, 2)
WhoPing:RegisterEvent("MINIMAP_PING")

local WhoPingText = CreateFS(WhoPing, 10, "CENTER")
WhoPingText:SetPoint("CENTER")

local anim = WhoPing:CreateAnimationGroup()
anim:SetScript("OnPlay", function()
	WhoPing:SetAlpha(1)
end)
anim:SetScript("OnFinished", function()
	WhoPing:SetAlpha(0)
end)
anim.fader = anim:CreateAnimation("Alpha")
anim.fader:SetFromAlpha(1)
anim.fader:SetToAlpha(0)
anim.fader:SetDuration(4)
anim.fader:SetSmoothing("OUT")
anim.fader:SetStartDelay(3)

WhoPing:SetScript("OnEvent", function(_, _, unit)
	local name = GetUnitName(unit)
	anim:Stop()
	WhoPingText:SetText(name)
	WhoPingText:SetTextColor(ClassColor.r, ClassColor.g, ClassColor.b)
	anim:Play()
end)

-- Hide order hall bar: https://github.com/destroyerdust/Class-Hall
local HideOH = CreateFrame("Frame")
HideOH:SetScript("OnUpdate", function(self,...)
	local OrderHallCommandBar = OrderHallCommandBar
	if OrderHallCommandBar then
		OrderHallCommandBar:Hide()
		OrderHallCommandBar:UnregisterAllEvents()
		OrderHallCommandBar.Show = function() end
	end
	OrderHall_CheckCommandBar = function () end
	self:SetScript("OnUpdate", nil)
end)
	
--right click toggle garrison page
--[[
GarrisonLandingPageMinimapButton:SetScript("OnClick", function(self, button, down)
	if button == "LeftButton" then
		if (GarrisonLandingPage and GarrisonLandingPage:IsShown()) then
			HideUIPanel(GarrisonLandingPage)
		else
			ShowGarrisonLandingPage(C_Garrison.GetLandingPageGarrisonType())
		end
	elseif button == "RightButton" then
		if (GarrisonLandingPage and GarrisonLandingPage:IsShown()) then
			HideUIPanel(GarrisonLandingPage)
		else
			ShowGarrisonLandingPage(LE_GARRISON_TYPE_6_0)
		end
	end
end)
GarrisonLandingPageMinimapButton:RegisterForClicks("LeftButtonUp", "RightButtonUp")
]]--

--[[
GarrisonLandingPageMinimapButton:HookScript("OnClick", function(self, button, down)
   if not (button == "RightButton" and not down) then return end
   HideUIPanel(GarrisonLandingPage)
   ShowGarrisonLandingPage(LE_GARRISON_TYPE_6_0)
end)
GarrisonLandingPageMinimapButton:RegisterForClicks("LeftButtonUp", "RightButtonUp")]]--