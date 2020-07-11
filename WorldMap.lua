local addon, ns = ...
local C, F, G = unpack(ns)
if not C.WorldMapStyle then return end
if IsAddOnLoaded("Leatrix_Maps") then return end

local WMF, PMFF = WorldMapFrame, PlayerMovementFrameFader

--================================================--
-----------------    [[ Core ]]    -----------------
--================================================--

	-- Style
	WMF:SetScale(C.WorldMapScale)
	WMF.BlackoutFrame.Blackout:SetAlpha(0)		-- No background / 去背
	--WMF.BlackoutFrame.Blackout = function() end
	WMF.BlackoutFrame:EnableMouse(false)		-- Click through / 點擊穿透	
	-- Cursor match scale / 滑鼠跟隨縮放
	WMF.ScrollContainer.GetCursorPosition = function(f)
		local x, y = MapCanvasScrollControllerMixin.GetCursorPosition(f)
		local s = WorldMapFrame:GetScale()
		
		return x/s, y/s
	end
	
	-- Fade
	if C.WorldMapFade then
		local function isMouseOverMap()
			return not WMF:IsMouseOver()
		end
		PMFF.AddDeferredFrame(WMF, C.WorldMapAlpha, 1, .5, isMouseOverMap)
	else
		PMFF.RemoveFrame(WMF)
	end
	
	-- Movable
	WMF:ClearAllPoints()
	WMF.ClearAllPoints = F.Dummy
	WMF:SetPoint("LEFT", UIParent, 10, 0)		-- Default at left / 初始化於畫面左邊
	WMF.SetPoint = F.Dummy
	WMF:SetMovable(true)
	WMF:SetUserPlaced(true)

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
	
	-- Reset / 重置
	SlashCmdList["RESETWM"] = function()
		WMF:SetUserPlaced(false)
		ReloadUI()
	end
	SLASH_RESETWM1 = "/resetwm"
	SLASH_RESETWM2 = "/rwm"