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
	if IsAddOnLoaded("Leatrix_Maps") then return end
	
	WMF:SetScale(EKMinimapDB["WorldMapScale"])
	WMF.BlackoutFrame.Blackout:SetAlpha(0)		-- No background / 去背
	--WMF.BlackoutFrame.Blackout = function() end
	WMF.BlackoutFrame:EnableMouse(false)		-- Click through / 點擊穿透	
	-- Cursor match scale / 滑鼠跟隨縮放
	WMF.ScrollContainer.GetCursorPosition = function(f)
		local x, y = MapCanvasScrollControllerMixin.GetCursorPosition(f)
		local s = WorldMapFrame:GetScale()
		
		return x/s, y/s
	end
	
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