local addon, ns = ...
local C, F, G, L = unpack(ns)
local WMF = WorldMapFrame

--================================================--
-----------------    [[ Core ]]    -----------------
--================================================--

local function styleWMF()
	if not EKMinimapDB["WorldMapStyle"] then return end

	WMF:SetScale(EKMinimapDB["WorldMapScale"])	-- Scale / 縮放
	WMF.BlackoutFrame.Blackout:SetAlpha(0)		-- No background / 去背
	--WMF.BlackoutFrame.Blackout = function() end
	WMF.BlackoutFrame:EnableMouse(false)		-- Click through / 點擊穿透	
	-- Cursor match scale / 滑鼠跟隨縮放
	WMF.ScrollContainer.GetCursorPosition = function(f)
		local x,y = MapCanvasScrollControllerMixin.GetCursorPosition(f)
		local s = WorldMapFrame:GetScale()
		
		return x/s, y/s
	end
	
	-- Movable
	WMF:SetMovable(true)						-- 使地圖可移動
	WMF:SetUserPlaced(true)						-- 使框架可以超出畫面
	WMF:ClearAllPoints()
	WMF.ClearAllPoints = F.Dummy				-- 使座標可自訂義
	WMF:SetPoint("LEFT", UIParent)				-- Default at left / 初始化於畫面左邊
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
	
local function fadeWMF()
	if not EKMinimapDB["WorldMapStyle"] then return end
	if not EKMinimapDB["WorldMapFade"] then return end
	-- Fadeout when moving / 移動時淡出
	local MoveFade = CreateFrame("Frame")
	MoveFade:SetScript("OnEvent", function(_, event, ...)
		
		local PMFF = PlayerMovementFrameFader
		local alpha = EKMinimapDB["WorldMapAlpha"]
		
		if event == "PLAYER_STARTED_MOVING" then
			PMFF.AddDeferredFrame(WMF, alpha, 1, .5)
		elseif event == "PLAYER_STOPPED_MOVING" then
			PMFF.AddDeferredFrame(WMF, 1, 1, .5)
		end
	end)

	MoveFade:RegisterEvent("PLAYER_STARTED_MOVING")
	MoveFade:RegisterEvent("PLAYER_STOPPED_MOVING")
end

local function OnEvent()
	--if not IsAddOnLoaded("Blizzard_WorldMap") then
	--	LoadAddOn("Blizzard_WorldMap")
	--end
	
	styleWMF()
	fadeWMF()
end

local frame = CreateFrame("FRAME")
	frame:RegisterEvent("PLAYER_LOGIN")
	frame:SetScript("OnEvent", OnEvent)