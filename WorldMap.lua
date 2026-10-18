local addon, ns = ...
local C, F, G, L = unpack(ns)
local WMF = WorldMapFrame

--====================================================--
-----------------    [[ Function ]]    -----------------
--====================================================--

local function isMouseOverMap()
	return not WMF:IsMouseOver()
end

--================================================--
-----------------    [[ Core ]]    -----------------
--================================================--

local function styleWMF()
	if not F.GetEKMOption("WorldMapStyle") then return end
	if C_AddOns.IsAddOnLoaded("Leatrix_Maps") then return end

	WMF:SetScale(F.GetEKMOption("WorldMapScale"))
	WMF.BlackoutFrame.Blackout:SetAlpha(0)		-- No background / 去背
	WMF.BlackoutFrame:EnableMouse(false)		-- Click through / 點擊穿透
	-- Cursor match scale / 滑鼠跟隨縮放
	WMF.ScrollContainer.GetCursorPosition = function(f)
		local x, y = MapCanvasScrollControllerMixin.GetCursorPosition(f)
		local s = WorldMapFrame:GetScale()

		return x/s, y/s
	end

	if F.GetEKMOption("WorldMapFade") then
		local alpha = F.GetEKMOption("WorldMapAlpha")
		PlayerMovementFrameFader.AddDeferredFrame(WMF, alpha, 1, .5, isMouseOverMap)
	else
		PlayerMovementFrameFader.RemoveFrame(WMF)
	end

	-- 讓原生 UIPanel 保留浮動世界地圖的錨點，保留放大與重置的原生定位。
	SetUIPanelAttribute(WMF, "area", "center")
	SetUIPanelAttribute(WMF, "centerFrameSkipAnchoring", true)
	WMF:SetMovable(true)
	WMF:SetUserPlaced(true)
	WMF:ClearAllPoints()
	WMF:SetPoint("LEFT", UIParent, 10, 0)		-- Default at left / 初始化於畫面左邊
	WorldMapScreenAnchor:StartMoving()
	WorldMapScreenAnchor:SetPoint("TOPLEFT", WMF)
	WorldMapScreenAnchor:StopMovingOrSizing()
	hooksecurefunc(WMF, "SynchronizeDisplayState", function(self)
		if not self:IsMaximized() then
			self:ClearAllPoints()
			self:SetPoint("TOPLEFT", WorldMapScreenAnchor)
		end
	end)

	-- Alt+right click to drag frame / alt+右鍵拖動
	WMF:RegisterForDrag("RightButton")
	WMF:SetScript("OnDragStart", function(self)
		if IsAltKeyDown() then
			WorldMapScreenAnchor:ClearAllPoints()
			self:ClearAllPoints()
			self:StartMoving()
		end
	end)
	WMF:SetScript("OnDragStop", function(self)
		self:StopMovingOrSizing()
		WorldMapScreenAnchor:StartMoving()
		WorldMapScreenAnchor:SetPoint("TOPLEFT", self)
		WorldMapScreenAnchor:StopMovingOrSizing()
	end)
end

local function OnEvent(self)
	self:UnregisterEvent("PLAYER_LOGIN")
	styleWMF()
end

local frame = CreateFrame("FRAME")
	frame:RegisterEvent("PLAYER_LOGIN")
	frame:SetScript("OnEvent", OnEvent)
