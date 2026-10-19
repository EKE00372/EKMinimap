local addon, ns = ...
local C, F, G, L = unpack(ns)
local WMF = WorldMapFrame

-- 移動中仍保留指向地圖時的完整不透明度。
local function isMouseOverMap()
	return not WMF:IsMouseOver()
end

local function OnEvent(self)
	self:UnregisterEvent("PLAYER_LOGIN")
	if C_AddOns.IsAddOnLoaded("Leatrix_Maps") or C_AddOns.IsAddOnLoaded("Mapster") then return end

	if F.GetEKMOption("WorldMapFade") then
		PlayerMovementFrameFader.AddDeferredFrame(WMF, F.GetEKMOption("WorldMapAlpha"), 1, .5, isMouseOverMap)
	else
		PlayerMovementFrameFader.RemoveFrame(WMF)
	end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", OnEvent)
