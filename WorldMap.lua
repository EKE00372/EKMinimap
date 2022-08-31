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
	if not EKMinimapDB["WorldMapStyle"] then return end
	if IsAddOnLoaded("Leatrix_Maps") or IsAddOnLoaded("Mapster") then return end
	
	-- SetScale
	WMF:SetScale(EKMinimapDB["WorldMapScale"])
	
	-- No background / 去背
	WMF.BlackoutFrame:Hide()
	WMF.BorderFrame:SetAlpha(0)
	WMF.BorderFrame.BG = F.CreateBG(WMF,3,3,.7)
	
	-- Options in middle
	WorldMapFrame:SetFrameStrata("MEDIUM")
	WorldMapFrame.BorderFrame:SetFrameStrata("MEDIUM")
	WorldMapFrame.BorderFrame:SetFrameLevel(1)
	WorldMapFrame:SetAttribute("UIPanelLayout-area", "center")
	WorldMapFrame:SetAttribute("UIPanelLayout-enabled", false)
	WorldMapFrame:SetAttribute("UIPanelLayout-allowOtherPanels", true)
	WorldMapFrame.HandleUserActionToggleSelf = function()
		if WorldMapFrame:IsShown() then WorldMapFrame:Hide() else WorldMapFrame:Show() end
	end
	tinsert(UISpecialFrames, "WorldMapFrame")
	
	-- Cursor match scale / 滑鼠跟隨縮放
	WMF.ScrollContainer.GetCursorPosition = function(f)
		local x, y = MapCanvasScrollControllerMixin.GetCursorPosition(f)
		local s = WorldMapFrame:GetScale()
		
		return x/s, y/s
	end
	
	-- Fix scroll zooming / 縮放修正
	WorldMapFrame.ScrollContainer:HookScript("OnMouseWheel", function(self, delta)
		local x, y = self:GetNormalizedCursorPosition()
		local nextZoomOutScale, nextZoomInScale = self:GetCurrentZoomRange()
		if delta == 1 then
			if nextZoomInScale > self:GetCanvasScale() then
				self:InstantPanAndZoom(nextZoomInScale, x, y)
			end
		else
			if nextZoomOutScale < self:GetCanvasScale() then
				self:InstantPanAndZoom(nextZoomOutScale, x, y)
			end
		end
	end)
	
	-- Fade when moving
	if EKMinimapDB["WorldMapFade"] then
		local alpha = EKMinimapDB["WorldMapAlpha"]
		PlayerMovementFrameFader.AddDeferredFrame(WMF, alpha, 1, .5, isMouseOverMap)
	else
		PlayerMovementFrameFader.RemoveFrame(WMF)
	end
	
	-- Movable
	WMF:SetMovable(true)						-- 使地圖可移動
	WMF:SetUserPlaced(true)						-- 使框架可以超出畫面
	WMF:ClearAllPoints()
	WMF.ClearAllPoints = F.Dummy				-- 使座標可自訂義
	WMF:SetPoint("LEFT", UIParent, 10, 0)		-- Default at left / 初始化於畫面左邊
	WMF.SetPoint = F.Dummy						-- 使拖動過的位置可以被儲存
	
	-- Alt+right click to drag frame / alt+右鍵拖動
	WMF:RegisterForDrag("RightButton")
	WMF:SetScript("OnDragStart", function(self)
		if IsAltKeyDown() then
			self:StartMoving()
		end
	end)
	WMF:SetScript("OnDragStop", function(self)
		self:StopMovingOrSizing()
	end)
end

local function OnEvent()
	styleWMF()
end

local frame = CreateFrame("FRAME")
	frame:RegisterEvent("PLAYER_LOGIN")
	frame:SetScript("OnEvent", OnEvent)