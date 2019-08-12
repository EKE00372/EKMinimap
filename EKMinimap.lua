local C, G = unpack(select(2, ...))

-- [[ style ]] --

-- Create font style / �r��
local function CreateFS(parent, justify)
	local frame = parent:CreateFontString(nil, "OVERLAY")
	
	frame:SetFont(G.font, G.fontSize, G.fontFlag)
	frame:SetShadowColor(0, 0, 0, 0)
	frame:SetShadowOffset(0, 0)
	
	if justify then
		frame:SetJustifyH(justify)
	end
	
	return frame
end

-- Create shadow border / ���v���
local CreateShadow = function(parent, anchor, size)
	local sd = CreateFrame("Frame", nil, parent)
	local framelvl = parent:GetFrameLevel()
	
	sd:ClearAllPoints()
	sd:SetPoint("TOPLEFT", anchor, -size, size)
	sd:SetPoint("BOTTOMRIGHT", anchor, size, -size)
	sd:SetFrameLevel(framelvl == 0 and 0 or framelvl-1)
	sd:SetBackdrop({
		edgeFile = G.glow,	-- ���v���
		edgeSize = size,		-- ��ؤj�p
	})
	--sd:SetBackdropColor(0, 0, 0, 1)
	sd:SetBackdropBorderColor(0, 0, 0, 1)
	
	return sd
end

--================================================--
-----------------    [[ Core ]]    -----------------
--================================================--

-- [[ Make A Square / �˦��諬 ]] --

function GetMinimapShape()
	return "SQUARE"
end

-- [[ Minimap ]] --

local Minimap = Minimap
	-- Core
	Minimap:SetMaskTexture(G.Tex)
	Minimap:SetSize(160, 160)
	Minimap:SetScale(C.scale)
	Minimap:SetFrameStrata("LOW")
	Minimap:SetFrameLevel(3)
	-- Position
	Minimap:ClearAllPoints()
	Minimap:SetPoint(C.anchor, UIParent, unpack(C.Point))
	MinimapCluster:ClearAllPoints()
	MinimapCluster:SetAllPoints(Minimap)
	-- ���I��p�a�Ϫ���L�����A��p�@�[�׸���㨺�ǰ����N
	MinimapCluster:ClearAllPoints()
	MinimapCluster:SetAllPoints(Minimap)
	-- MinimapCluster:EnableMouse(false)
	-- Shadow Border
	Minimap.BG = CreateShadow(Minimap, Minimap, 5)

	-- Movable
	Minimap:SetMovable(true)
	Minimap:EnableMouse(true)
	-- Alt+right click to drag frame
	Minimap:RegisterForDrag("RightButton")
	Minimap:SetScript("OnDragStart", function(self)
		if IsAltKeyDown() then
			self:StartMoving()
		end
	end)
	Minimap:SetScript("OnDragStop", function(self)
		self:StopMovingOrSizing()
	end)
	-- Reset / ���m
	Minimap:SetUserPlaced(true)
	SlashCmdList["RESETMINIMAP"] = function()
		Minimap:SetUserPlaced(false)
		ReloadUI()
	end
	SLASH_RESETMINIMAP1 = "/resetminimap"
	SLASH_RESETMINIMAP2 = "/rm"

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
	"MinimapToggleButton",
	"MinimapZoomIn",
	"MinimapZoomOut",
	"GameTimeFrame",
	"SubZoneTextFrame",
	"DurabilityFrame",
}
for i, v in pairs(HideAll) do
	getglobal(v).Show = function() end
	getglobal(v):Hide()
end

--=====================================================--
-----------------    [[ Indicator ]]    -----------------
--=====================================================--

-- Mail Frame / �H�󴣥�
MiniMapMailFrame:ClearAllPoints()
MiniMapMailFrame:SetParent(Minimap)
if C.anchor == "TOPLEFT" or C.anchor == "BOTTOMLEFT" then
	MiniMapMailFrame:SetPoint("BOTTOMLEFT", Minimap, 0, 0)
else
	MiniMapMailFrame:SetPoint("BOTTOMRIGHT", Minimap, 0, 0)
end
MiniMapMailBorder:Hide()
MiniMapMailIcon:SetTexture(G.mail)

-- Minimap Tracker / �l��
MiniMapTrackingFrame:ClearAllPoints()
if C.anchor == "TOPLEFT" or C.anchor == "BOTTOMLEFT" then
	MiniMapTrackingFrame:SetPoint("BOTTOMRIGHT", Minimap, 0, 0)
else
	MiniMapTrackingFrame:SetPoint("BOTTOMLEFT", Minimap, 0, 0)
end
MiniMapTrackingBorder:Hide()
MiniMapTrackingIcon:SetScale(0.8)
MiniMapTrackingIcon:SetTexCoord(.08, .92, .08, .92)
MiniMapTrackingFrame.BG = CreateShadow(MiniMapTrackingFrame, MiniMapTrackingIcon, 3)

--================================================--
-----------------    [[ Misc ]]    -----------------
--================================================--

local WMF = WorldMapFrame
	WMF:SetScale(0.6)
	WMF.BlackoutFrame.Blackout:SetAlpha(0)
	--WMF.BlackoutFrame.Blackout = function() end
	WMF.BlackoutFrame:EnableMouse(false)
	WorldMapFrame.ScrollContainer.GetCursorPosition = function(f)
		local x,y = MapCanvasScrollControllerMixin.GetCursorPosition(f)
		local s = WorldMapFrame:GetScale()
		
		return x/s, y/s
	end
	-- Movable
	WMF:SetMovable(true)
	WMF:SetUserPlaced(true)
	WMF:ClearAllPoints()
	WMF.ClearAllPoints = function() end			-- �Ϯy�Хi�ۭq�q
	WMF:SetPoint("LEFT", UIParent)				-- �e������
	--WMF.SetPoint = function() end				-- �ϩ�ʹL����m�i�H�Q�x�s
	-- Alt+right click to drag frame
	WMF:RegisterForDrag("RightButton")
	WMF:SetScript("OnDragStart", function(self)
		if IsAltKeyDown() then
			self:StartMoving()
		end
	end)
	WMF:SetScript("OnDragStop", function(self)
		self:StopMovingOrSizing()
	end)
	-- Reset / ���m
	--[[SlashCmdList["RESETMAP"] = function()
		WMF:SetUserPlaced(false)
		ReloadUI()
	end
	SLASH_RESETMAP1 = "/resetmap"
	SLASH_RESETMAP2 = "/rmm"]]--
	-- Fadeout
	if event == "PLAYER_STOPPED_MOVING" then
		PlayerMovementFrameFader.AddDeferredFrame(WMF, 1, 3.0, .5)
	else
		PlayerMovementFrameFader.AddDeferredFrame(WMF, .3, 3.0, .5)
	end

-- [[ Scroll ]] --

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

-- [[ Ping ]] --

-- Show minimap ping / ��ܽ��I���F�p�a��
local WhoPing = CreateFrame("Frame", nil, Minimap)
	WhoPing:SetSize(100, 20)
	WhoPing:SetPoint("BOTTOM", Minimap, 0, 2)
	WhoPing:RegisterEvent("MINIMAP_PING")

	local WhoPingText = CreateFS(WhoPing, "CENTER")
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
		local class = select(2, UnitClass(unit))
		local name = GetUnitName(unit)
		local classcolor = 	(CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[class]

		anim:Stop()
		WhoPingText:SetText(name)
		WhoPingText:SetTextColor(classcolor.r, classcolor.g, classcolor.b)
		anim:Play()
	end)