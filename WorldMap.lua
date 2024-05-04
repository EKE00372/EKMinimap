local addon, ns = ...
local C, F, G, L = unpack(ns)
local WMF = WorldMapFrame

--================================================--
-----------------    [[ Core ]]    -----------------
--================================================--

local function styleWMF()
	if IsAddOnLoaded("Leatrix_Maps") or IsAddOnLoaded("Mapster") then return end
	
	-- Fade when moving
	if EKMinimapDB["WorldMapFade"] then
		local alpha = EKMinimapDB["WorldMapAlpha"]
		PlayerMovementFrameFader.AddDeferredFrame(WMF, alpha, 1, .5, isMouseOverMap)
	else
		PlayerMovementFrameFader.RemoveFrame(WMF)
	end
end

local function OnEvent()
	styleWMF()
end

local frame = CreateFrame("FRAME")
	frame:RegisterEvent("PLAYER_LOGIN")
	frame:SetScript("OnEvent", OnEvent)