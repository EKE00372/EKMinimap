-- [[ Credit ]] --

-- Felix S. , sakaras, ape47, iMinimap by Chiril, ooMinimap by Ooglogput, intMinimap by Int0xMonkey
-- DifficultyID list
-- https://wow.gamepedia.com/DifficultyID
-- rStatusButton by zork
-- https://www.wowinterface.com/downloads/info24772-rStatusButton.html
-- Hide order hall bar
-- https://github.com/destroyerdust/Class-Hall

-- [[ Config ]] --

-- shift+alt按住標題移動任務，/rm 重置小地圖位置，/ro重置任務列表位置，alt分享ctrl放棄
-- shift+alt quest title to drag ，/rm reset minimap position，/ro reset quset position，alt share quest, ctrl abandon quest

local Scale = 1  					-- 縮放/Scale
local x , y = 10, -20 				-- 座標/Position
local AnchorPoint = "TOPLEFT" 		-- 錨點/Anchor point 
local Announce = false  			-- 行事曆有邀請時高亮邊框/show yellow border when get invite

-- [[ style ]] --

-- class color / 職業顏色
local ClassColor = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[select(2,UnitClass("player"))]

-- Create font Style / 字型
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

-- should do this at first
local Minimap = Minimap

-- Make A Square / 弄成方型
local function GetMinimapShape()
	return "SQUARE"
end
--Minimap:SetHitRectInsets(left, right, top, bottom)	-- 俺要方的 不要扁的 所以不切
Minimap:SetMaskTexture("Interface\\Buttons\\WHITE8x8")
Minimap:SetSize(160, 160)
Minimap:SetScale(Scale)
Minimap:SetFrameStrata("LOW")
Minimap:SetFrameLevel(3)

Minimap:ClearAllPoints()
Minimap:SetPoint(AnchorPoint, UIParent, x, y)
MinimapCluster:ClearAllPoints()
MinimapCluster:SetAllPoints(Minimap)

-- Shift+Alt+Drag to move / shift+alt按住移動
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

-- Reset place / 重置位置
Minimap:SetUserPlaced(true)
SlashCmdList["RESETMINIMAP"] = function()
    Minimap:SetUserPlaced(false)
    ReloadUI()
end
SLASH_RESETMINIMAP1 = "/resetminimap"
SLASH_RESETMINIMAP2 = "/rm"

-- Background / 背景
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

-- 隱藏圓圈
Minimap:SetArchBlobRingScalar(0)
Minimap:SetQuestBlobRingScalar(0)

-- Border Announce for Calendar / 行事曆有邀請時變黃
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

-- [[ Hide Script ]] --

-- Hide Clock / 隱藏時鐘
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

-- Hide All / 隱藏各種
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

-- Queue Button /佇列圖示
QueueStatusMinimapButton:ClearAllPoints()
QueueStatusMinimapButton:SetParent(Minimap)
if AnchorPoint == "TOPLEFT" or AnchorPoint == "BOTTOMLEFT" then
	QueueStatusMinimapButton:SetPoint("TOPRIGHT", Minimap, 0, 0)
else
	QueueStatusMinimapButton:SetPoint("TOPLEFT", Minimap, 0, 0)
end
QueueStatusMinimapButtonBorder:Hide()
QueueStatusMinimapButton:SetFrameLevel(10)

-- Queue Tooltip fix / 滑鼠提示位置調整
if AnchorPoint == "TOPLEFT" or AnchorPoint == "BOTTOMLEFT" then
	QueueStatusFrame:ClearAllPoints()
	QueueStatusFrame:SetPoint("TOPRIGHT", Minimap, "TOPRIGHT", 282, -10)
else
	QueueStatusFrame:ClearAllPoints()
	QueueStatusFrame:SetPoint("TOPLEFT", Minimap, "TOPLEFT", -282, -10)
end

-- Mail Frame / 信件提示
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

-- Garrison Icon / 要塞和職業大廳
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

-- Oderhall Mouseover FadeIn / 淡出淡入
GarrisonLandingPageMinimapButton:SetAlpha(0)
GarrisonLandingPageMinimapButton:SetScript("OnEnter", function(self)
	-- fade in
	securecall(UIFrameFadeIn, GarrisonLandingPageMinimapButton, 0.4, 0, 1)
	
	-- show exp/rep tooltip
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOM", (Minimap:GetWidth() * .7), -3)
	--experience
	if UnitLevel("player") < MAX_PLAYER_LEVEL and not IsXPUserDisabled() then
		local cur, max = UnitXP("player"), UnitXPMax("player")
		local lvl = UnitLevel("player")
		local rested = GetXPExhaustion()
		
		GameTooltip:AddDoubleLine(XP, LEVEL.." "..lvl, 0, 1, 0.5, 0, 1, 0.5)
		GameTooltip:AddDoubleLine( cur.."/"..max, (max-cur).."("..rested..")", 1, 1, 1, 1, 1, 1)
	end
	--honor
	--if InActiveBattlefield() or IsInActiveWorldPVP() then
		local cur, max = UnitHonor("player"), UnitHonorMax("player")
		local lvl = UnitHonorLevel("player")
		GameTooltip:AddDoubleLine(HONOR, LEVEL.." "..lvl, 0, 1, 0.5, 0, 1, 0.5)
		GameTooltip:AddDoubleLine( cur.."/"..max, (max-cur), 1, 1, 1, 1, 1, 1)
	--end
	--reputation
	local name, standing, min, max, cur = GetWatchedFactionInfo()
	if name then
		GameTooltip:AddDoubleLine(name, _G["FACTION_STANDING_LABEL"..standing], 0, 1, 0.5, 0, 1, 0.5)
		GameTooltip:AddDoubleLine( cur.."/"..max, (max-cur), 1, 1, 1, 1, 1, 1)
	end
	--azerite
	local azeriteItem = C_AzeriteItem.FindActiveAzeriteItem()
	if azeriteItem then
		local cur, max = C_AzeriteItem.GetAzeriteItemXPInfo(azeriteItem)
		local lvl = C_AzeriteItem.GetPowerLevel(azeriteItem)

		GameTooltip:AddDoubleLine(ARTIFACT_POWER, LEVEL.." "..lvl, 0, 1, 0.5, 0, 1, 0.5)
		GameTooltip:AddDoubleLine( cur.."/"..max, (max-cur), 1, 1, 1, 1, 1, 1)
	end
	--islandweekly
	local iwqID = C_IslandsQueue.GetIslandsWeeklyQuestID()
	if iwqID and IsQuestFlaggedCompleted(iwqID) then
		GameTooltip:AddDoubleLine(ISLANDS_HEADER, COMPLETE, 0, 1, 0.5, 0, 1, 0.5)
	elseif iwqID then
		local _, _, _, cur, max = GetQuestObjectiveInfo(iwqID, 1, false)
		GameTooltip:AddDoubleLine(ISLANDS_HEADER, INCOMPLETE, 0, 1, 0.5, 0, 1, 0.5)
		GameTooltip:AddDoubleLine( cur.."/"..max, (max-cur), 1, 1, 1, 1, 1, 1)
  end
	GameTooltip:Show()
end)
GarrisonLandingPageMinimapButton:SetScript("OnLeave", function()
	securecall(UIFrameFadeOut, GarrisonLandingPageMinimapButton, 0.8, 1, 0)
end)

-- [[ Instance Difficulty ]] -- 

-- Hide Blizzard / 隱藏暴雪的難度旗子
MiniMapInstanceDifficulty:Hide()
MiniMapInstanceDifficulty.Show = function() return end
GuildInstanceDifficulty:Hide()
GuildInstanceDifficulty.Show = function() return end

-- Creat Frame / 創建框體
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

-- Difficulty Text / 難度文字
local RaidDifficultyText = CreateFS(RaidDifficulty, 10, "CENTER")
RaidDifficultyText:SetPoint("CENTER")

-- Difficulty / 地城難度(與公會團隊)
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
		-- Old LFR (before SOO)
		elseif difficulty == 7 then
			RaidDifficultyText:SetText("LFR")
		-- Challenge Mode and Mythic+
		elseif difficulty == 8 then
			RaidDifficultyText:SetText("M"..mplus)	
		elseif difficulty == 9 then
			RaidDifficultyText:SetText("40R")
		-- 11 MOP英雄事件 39 BFA英雄海嶼
		elseif difficulty == 11	or difficulty == 39 then
			RaidDifficultyText:SetText("3H")
		-- 12 MOP普通事件 38 BFA普通海嶼
		elseif difficulty == 12 and difficulty == 38 then 
			RaidDifficultyText:SetText("3N")
		-- 40 BFA傳奇海嶼
		elseif difficulty == 40 then 
			RaidDifficultyText:SetText("3M")
		-- Flex normal raid
		elseif difficulty == 14	then
			RaidDifficultyText:SetText(num .. "N")
		-- Flex heroic raid
		elseif difficulty == 15	then
			RaidDifficultyText:SetText(num .. "H")
		-- Mythic raid since WOD
		elseif difficulty == 16	then
			RaidDifficultyText:SetText("M")
		-- LFR
		elseif difficulty == 17	then
			RaidDifficultyText:SetText(num .. "L")
		-- 18 Event 19 Event 20 Event Scenario(劇情事件) 30 Event
		elseif difficulty == 18 or difficulty == 19 or difficulty == 20 or difficulty == 30 then
			RaidDifficultyText:SetText("E")
		elseif difficulty == 23	then
			RaidDifficultyText:SetText("5M")
		-- 24 Timewalking(地城時光) 33 Timewalking(團隊時光)
		elseif difficulty == 24 or difficulty == 33 then
			RaidDifficultyText:SetText("T")
		-- 25 World PvP Scenario 32 World PvP Scenario( 34 PVP 45 PVP
		elseif difficulty == 25 or difficulty == 32 or difficulty == 34 or difficulty == 45 then
			RaidDifficultyText:SetText("PVP")
		-- 29 pvevp事件(這什麼玩意?)
		elseif difficulty == 29 then
			RaidDifficultyText:SetText("PvEvP")
		end
	elseif instanceType == "pvp" or instanceType == "arena" then
		RaidDifficultyText:SetText("PVP")
	else
		-- just notice you are in dungeon
		RaidDifficultyText:SetText("D")
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

-- Scroll Zoom, Alt+Scroll Scale / 滾輪縮放區域，alt滾輪縮放大小
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

-- Show minimap ping / 顯示誰點擊了小地圖
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

-- Hide order hall bar
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