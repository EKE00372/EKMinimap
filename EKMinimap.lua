local addon, ns = ...
local C, F, G, L = unpack(ns)
local Minimap, unpack, sub = Minimap, unpack, string.sub

--====================================================--
-----------------    [[ Function ]]    -----------------
--====================================================--

-- Create font style / 字型
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

--================================================--
-----------------    [[ Core ]]    -----------------
--================================================--

-- [[ Make A Square for minimap icon / 弄成方型 ]] --

function GetMinimapShape()
	return "SQUARE"
end

--====================-==============================--
-----------------    [[ Minimap ]]    -----------------
--===================================================--

local function CreateShadow()
	local MinimapSD = CreateFrame("Frame", nil, Minimap)
		MinimapSD:Hide()
		MinimapSD:ClearAllPoints()
		MinimapSD:SetPoint("TOPLEFT", Minimap, -5, 5)
		MinimapSD:SetPoint("BOTTOMRIGHT", Minimap, 5, -5)
		MinimapSD:SetFrameLevel(Minimap:GetFrameLevel() == 0 and 0 or Minimap:GetFrameLevel()-1)
		MinimapSD:SetBackdrop({
			edgeFile = G.Glow,	-- 陰影邊框
			edgeSize = 5,	-- 邊框大小
		})
		MinimapSD:SetBackdropBorderColor(0, 0, 0, 1)
		MinimapSD:Show()
end

local function updateMinimapPos()
	Minimap:ClearAllPoints()
	--Minimap:SetPoint(unpack(C.Point))
	Minimap:SetPoint(EKMinimapDB["MinimapAnchor"], UIParent, EKMinimapDB["MinimapX"], EKMinimapDB["MinimapY"])
end

local function updateMinimapSize()
	Minimap:SetSize(EKMinimapDB["MinimapSize"], EKMinimapDB["MinimapSize"])
	Minimap:SetScale(1)
end

local function setMinimap()
	updateMinimapPos()
	Minimap:SetClampedToScreen(true)
	Minimap:SetMovable(true)
	Minimap:EnableMouse(true)
	Minimap:RegisterForDrag("RightButton")
	
	updateMinimapSize()
	Minimap:SetMaskTexture(G.Tex)
	Minimap:SetFrameStrata("LOW")
	Minimap:SetFrameLevel(3)
	--CreateShadow()
	Minimap:SetArchBlobRingScalar(0)
	Minimap:SetQuestBlobRingScalar(0)
	
	-- Hide Blizzard / 隱藏暴雪的難度旗子
	MiniMapInstanceDifficulty:Hide()
	MiniMapInstanceDifficulty.Show = function() return end
	GuildInstanceDifficulty:Hide()
	GuildInstanceDifficulty.Show = function() return end

	-- Hide all frames / 隱藏各種
	local dummy = function() end
	local hideAll = {
		"MinimapBorder",			-- 大圈
		"MinimapBorderTop",
		"MinimapNorthTag",			-- 指北針
		"MiniMapWorldMapButton",	-- 世界地圖
		"MinimapZoneTextButton",	-- 區域名字
		"MinimapZoomIn",			-- 放大
		"MinimapZoomOut",			-- 縮小
		"GameTimeFrame",			-- 時間
		"MiniMapTracking",
		"ZoneTextFrame",
		"SubZoneTextFrame",
		"MiniMapChallengeMode",
		"DurabilityFrame",			-- 裝備耐久
		"VehicleSeatIndicator",
		"GarrisonLandingPageMinimapButton",
	}
	
	for i, v in pairs(hideAll) do
		getglobal(v).Show = dummy
		getglobal(v):Hide()
	end
	
	local anchor = EKMinimapDB["MinimapAnchor"]
	local myAnchor = sub(anchor, -4)				-- get minimap anchor left or rignt
	local iconAnchor = not not (myAnchor == "LEFT")	-- hope教我的語法糖
	
	-- Queue Button / 佇列圖示
	QueueStatusMinimapButton:ClearAllPoints()
	QueueStatusMinimapButton:SetParent(Minimap)
	QueueStatusMinimapButton:SetPoint(iconAnchor and "TOPRIGHT" or "TOPLEFT", Minimap, 0, 0)
	QueueStatusMinimapButtonBorder:Hide()
	QueueStatusMinimapButton:SetFrameLevel(10)
	
	-- Queue Tooltip fix / 佇列圖示提示
	QueueStatusFrame:ClearAllPoints()
	QueueStatusFrame:SetPoint(iconAnchor and "TOPRIGHT"or "TOPLEFT", Minimap, iconAnchor and "TOPRIGHT" or "TOPLEFT", 282, -10)
	
	-- Mail Frame / 信件提示
	MiniMapMailFrame:ClearAllPoints()
	MiniMapMailFrame:SetParent(Minimap)
	MiniMapMailFrame:SetPoint(iconAnchor and "BOTTOMLEFT" or "BOTTOMRIGHT", Minimap, 0, 0)
	MiniMapMailBorder:Hide()
	MiniMapMailIcon:SetTexture(G.Mail)
	MiniMapMailIcon:SetTexture("Interface\\MINIMAP\\TRACKING\\Mailbox.blp")
end
	
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

--===================================================--
-----------------    [[ Tooltip ]]    -----------------
--===================================================--

local Stat = CreateFrame("Button", "EKMinimapTooltipButton", Minimap)
	Stat:SetHitRectInsets(-5, -5, -5, 5)
	Stat:SetSize(28, 28)
	Stat:ClearAllPoints()
	Stat:SetFrameLevel(Minimap:GetFrameLevel()+2)
	Stat:SetNormalTexture(G.Report)
	Stat:SetPushedTexture(G.Report)
	Stat:SetHighlightTexture(G.Report)
	Stat:SetPoint(iconAnchor and "BOTTOMRIGHT" or "BOTTOMLEFT", Minimap, -3, 5)
	Stat:SetAlpha(0)

local function createGarrisonTooltip(self)
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOM", (Minimap:GetWidth() * .7), -3)
	GameTooltip:AddLine(CHARACTER)
	GameTooltip:AddLine(" ")

	-- Experience
	if UnitLevel("player") < MAX_PLAYER_LEVEL and not IsXPUserDisabled() then
		local cur, max = UnitXP("player"), UnitXPMax("player")
		local lvl = UnitLevel("player")
		local rested = GetXPExhaustion()
		
		GameTooltip:AddDoubleLine(XP, LEVEL.." "..lvl, 0, 1, .5, 0, 1, .5)
		GameTooltip:AddDoubleLine(cur.."/"..max, (max-cur).."("..rested..")", 1, 1, 1, 1, 1, 1)
	end
	
	-- Honor
	do
		local cur, max = UnitHonor("player"), UnitHonorMax("player")
		local lvl = UnitHonorLevel("player")
		
		GameTooltip:AddDoubleLine(HONOR, LEVEL.." "..lvl, 0, 1, .5, 0, 1, .5)
		GameTooltip:AddDoubleLine(cur.."/"..max, (max-cur), 1, 1, 1, 1, 1, 1)
	end
		
	-- Reputation
	do
		local name, standing, min, max, cur = GetWatchedFactionInfo()
		
		if name then
			GameTooltip:AddDoubleLine(name, _G["FACTION_STANDING_LABEL"..standing], 0, 1, 0.5, 0, 1, 0.5)
			GameTooltip:AddDoubleLine(cur.."/"..max, (max-cur), 1, 1, 1, 1, 1, 1)
		end
	end
		
	-- azerite
	do
		local azeriteItem = C_AzeriteItem.FindActiveAzeriteItem()
		
		if azeriteItem then
			local cur, max = C_AzeriteItem.GetAzeriteItemXPInfo(azeriteItem)
			local lvl = C_AzeriteItem.GetPowerLevel(azeriteItem)

			GameTooltip:AddDoubleLine(ARTIFACT_POWER, LEVEL.." "..lvl, 0, 1, .5, 0, 1, .5)
			GameTooltip:AddDoubleLine(cur.."/"..max, (max-cur), 1, 1, 1, 1, 1, 1)
		end
	end
	
	GameTooltip:Show()
end

--======================================================--
-----------------    [[ Difficulty ]]    -----------------
--======================================================--

local Diff = CreateFrame("Frame", "EKMinimapDungeonIcon", Minimap)
	Diff:SetSize(40, 40)
	Diff:ClearAllPoints()
	Diff:SetFrameLevel(Minimap:GetFrameLevel()+2)
	Diff:SetPoint(iconAnchor and "TOPLEFT" or "TOPRIGHT", Minimap,  -5, 5)
	Diff.Texture = Diff:CreateTexture(nil, "OVERLAY")
	Diff.Texture:SetAllPoints(Diff)
	Diff.Texture:SetTexture(G.Diff)
	Diff.Texture:SetVertexColor(G.Ccolors.r, G.Ccolors.g, G.Ccolors.b)

local function styleDifficulty(self)
	-- Difficulty Text / 難度文字
	local DiffText = CreateFS(Diff, "CENTER")
	DiffText:SetPoint("CENTER")
	
	local inInstance, instanceType = IsInInstance()
	local difficulty = select(3, GetInstanceInfo())
	local num = select(9, GetInstanceInfo())
	local mplus = select(1, C_ChallengeMode.GetActiveKeystoneInfo()) or ""
			
	if instanceType == "party" or instanceType == "raid" or instanceType == "scenario" then
		if difficulty == 1 then
			DiffText:SetText("5N")
		elseif difficulty == 2 then
			DiffText:SetText("5H")
		elseif difficulty == 3 then
			DiffText:SetText("10N")
		elseif difficulty == 4 then
			DiffText:SetText("25N")
		-- 5 普通十人 153 十人海島
		elseif difficulty == 5 then
			DiffText:SetText("10H")
		elseif difficulty == 6 then
			DiffText:SetText("25H")
		-- Old LFR (before SOO)
		elseif difficulty == 7 then
			DiffText:SetText("LFR")
		-- Challenge Mode and Mythic+
		elseif difficulty == 8 then
			DiffText:SetText("M"..mplus)	
		elseif difficulty == 9 then
			DiffText:SetText("40R")
		-- 11 MOP英雄事件 39 BFA英雄海嶼
		elseif difficulty == 11	or difficulty == 39 then
		DiffText:SetText("3H")
		-- 12 MOP普通事件 38 BFA普通海嶼
		elseif difficulty == 12 and difficulty == 38 then 
			DiffText:SetText("3N")
		-- 40 BFA傳奇海嶼
		elseif difficulty == 40 then 
			DiffText:SetText("3M")
		-- Flex normal raid
		elseif difficulty == 14	then
			DiffText:SetText(num .. "N")
		-- Flex heroic raid
		elseif difficulty == 15	then
			DiffText:SetText(num .. "H")
		-- Mythic raid since WOD
		elseif difficulty == 16	then
			DiffText:SetText("M")
		-- LFR
		elseif difficulty == 17	then
			DiffText:SetText(num .. "L")
		-- 18 Event 19 Event 20 Event Scenario(劇情事件) 30 Event 152 幻象
		elseif difficulty == 18 or difficulty == 19 or difficulty == 20 or difficulty == 30 then
			DiffText:SetText("E")
		elseif difficulty == 23	then
			DiffText:SetText("5M")
		-- 24 Timewalking(地城時光) 33 Timewalking(團隊時光) 151 隨機團隊時光
		elseif difficulty == 24 or difficulty == 33 then
			DiffText:SetText("T")
		-- 25 World PvP Scenario 32 World PvP Scenario 34 PVP 45 PVP
		elseif difficulty == 25 or difficulty == 32 or difficulty == 34 or difficulty == 45 then
			DiffText:SetText("PVP")
		-- 29 pvevp事件(這什麼玩意?)
		elseif difficulty == 29 then
			DiffText:SetText("PvEvP")
		-- 147 普通戰爭前線
		elseif difficulty == 147 then
		DiffText:SetText("WF")
		-- 147 英雄戰爭前線
		elseif difficulty == 149 then
			DiffText:SetText("HWF")
		end
	elseif instanceType == "pvp" or instanceType == "arena" then
		DiffText:SetText("PVP")
	else
		-- just notice you are in dungeon
		DiffText:SetText("D")
	end

	if not inInstance then
		--Diff:Hide()
		Diff:SetAlpha(0)
	else
		--Diff:Show()
		Diff:SetAlpha(1)
	end
	
end

--================================================--
-----------------    [[ Ping ]]    -----------------
--=================================================--

local function whoPing()
	local ping = CreateFrame("Frame", nil, Minimap)
	ping:SetSize(100, 20)
	ping:SetPoint("BOTTOM", Minimap, 0, 2)
	ping:RegisterEvent("MINIMAP_PING")

	ping.text = CreateFS(ping, "CENTER")
	ping.text:SetPoint("CENTER")

	local anim = ping:CreateAnimationGroup()
	anim:SetScript("OnPlay", function() ping:SetAlpha(1) end)
	anim:SetScript("OnFinished", function() ping:SetAlpha(0) end)
	anim.fader = anim:CreateAnimation("Alpha")
	anim.fader:SetFromAlpha(1)
	anim.fader:SetToAlpha(0)
	anim.fader:SetDuration(4)
	anim.fader:SetSmoothing("OUT")
	anim.fader:SetStartDelay(3)

	ping:SetScript("OnEvent", function(_, _, unit)
		local class = select(2, UnitClass(unit))
		local name = GetUnitName(unit)
		local classcolor = 	(CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[class]

		anim:Stop()
		ping.text:SetText(name)
		ping.text:SetTextColor(classcolor.r, classcolor.g, classcolor.b)
		anim:Play()
	end)
end

--==================================================--
-----------------    [[ Script ]]    -----------------
--==================================================--
	
	-- [[ Minimap ]] --
	
	-- Alt+right click to drag frame
	Minimap:SetScript("OnMouseWheel", OnMouseWheel)
	Minimap:SetScript("OnDragStart", function(self)
		if IsAltKeyDown() then
			self:StartMoving()
		end
	end)
	Minimap:SetScript("OnDragStop", function(self)
		self:StopMovingOrSizing()
	end)
	
	-- [[ Icon ]] --
	
	Stat:SetScript("OnEnter", function(self)
		createGarrisonTooltip(self)
		-- fade in
		securecall(UIFrameFadeIn, Stat, .4, 0, 1)
	end)
	Stat:SetScript("OnLeave", function()
		securecall(UIFrameFadeOut, Stat, .8, 1, 0)
		GameTooltip:Hide()
	end)
	Stat:SetScript("OnMouseDown", function(self, button)
		if InCombatLockdown() then
			UIErrorsFrame:AddMessage("|cffff0000"..ERR_NOT_IN_COMBAT.."|r")
			return
		end
		GarrisonLandingPageMinimapButton:Click()
	end)

	Diff:RegisterEvent("PLAYER_ENTERING_WORLD")
	Diff:RegisterEvent("PLAYER_DIFFICULTY_CHANGED")
	Diff:RegisterEvent("INSTANCE_GROUP_SIZE_CHANGED")
	Diff:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	Diff:RegisterEvent("CHALLENGE_MODE_START")
	Diff:RegisterEvent("CHALLENGE_MODE_COMPLETED")
	Diff:RegisterEvent("CHALLENGE_MODE_RESET")
	Diff:SetScript("OnEvent", styleDifficulty)

--=================================================--
-----------------    [[ Load ]]    -----------------
--=================================================--

-- Reset size / 重置
SlashCmdList["RESETSCALE"] = function()
	updateMinimapSize()
end
SLASH_RESETSCALE1 = "/resetscale"
SLASH_RESETSCALE2 = "/rms"

-- Reset position / 重置
SlashCmdList["RESETMINIMAP"] = function()
	updateMinimapPos()
end
SLASH_RESETMINIMAP1 = "/resetminimap"
SLASH_RESETMINIMAP2 = "/rm"

local function OnEvent(self, event, addon)
	-- Hide Clock / 隱藏時鐘
	if event == "ADDON_LOADED" and addon == "Blizzard_TimeManager" then
		TimeManagerClockButton:Hide()
		TimeManagerClockButton:SetScript("OnShow", function(self)
			TimeManagerClockButton:Hide()
		end)
		CreateShadow()
		
		self:UnregisterEvent("ADDON_LOADED")
	else
		whoPing()
		setMinimap()
	end
end

local frame = CreateFrame("FRAME")
	frame:RegisterEvent("PLAYER_LOGIN")
	frame:RegisterEvent("ADDON_LOADED")
	frame:SetScript("OnEvent", OnEvent)