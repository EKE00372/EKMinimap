local addon, ns = ...
local C, F, G, L = unpack(ns)
local Minimap, sub, floor, CreateFrame = Minimap, string.sub, math.floor, CreateFrame

--====================================================--
-----------------    [[ Function ]]    -----------------
--====================================================--

--================================================--
-----------------    [[ Core ]]    -----------------
--================================================--

-- [[ Make A Square for minimap icon / 弄成方型 ]] --

function GetMinimapShape()
	return "SQUARE"
end

local function findAnchor(value)
	--local anchor = EKMinimapDB["MinimapAnchor"]
	local anchor = EKMinimapDB[value]
	local myAnchor = sub(anchor, -4)				-- get minimap anchor left or rignt
	local iconAnchor = not not (myAnchor == "LEFT")	-- hope教我的語法糖
	
	return iconAnchor
end

--====================-==============================--
-----------------    [[ Minimap ]]    -----------------
--===================================================--

local function updateMinimapPos()
	Minimap:ClearAllPoints()
	Minimap:SetPoint(EKMinimapDB["MinimapAnchor"], UIParent, EKMinimapDB["MinimapX"], EKMinimapDB["MinimapY"])
end

local function updateMinimapSize()
	-- default size is ≈ 140
	-- We use SetScale() instead SetSize() because there's an issue happened on load order and addon icons.
	-- addon minimap icon may put themself to strange place because this addon load after then icons been created.
	-- 如果使用 SetScale() 而非 SetSize()，會導致小地圖圖示跑到奇怪的地方
	-- 因為插件的載入順序不同，本插件的小地圖尺寸更改晚於別的插件生成圖示，是於無法獲取正確的座標
	Minimap:SetSize(140, 140)
	Minimap:SetScale(EKMinimapDB["MinimapScale"])
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
	
	--MinimapCluster:ClearAllPoints()
	--MinimapCluster:SetAllPoints(Minimap)
	MinimapCluster:EnableMouse(false)
	
	Minimap.bg = F.CreateBG(Minimap, 5, 5, 1)
	
	hooksecurefunc(UIWidgetBelowMinimapContainerFrame, "SetPoint", function(self, _, parent)
		if parent == "MinimapCluster" or parent == MinimapCluster then
			self:ClearAllPoints()
			self:SetClampedToScreen(true)
			self:SetPoint("TOP", Minimap, "BOTTOM", 0, -20)
		end
	end)
	
	Minimap:SetArchBlobRingScalar(0)
	Minimap:SetQuestBlobRingScalar(0)
	
	-- Hide Blizzard / 隱藏暴雪的難度旗子
	MiniMapInstanceDifficulty:Hide()
	MiniMapInstanceDifficulty.Show = F.Dummy
	GuildInstanceDifficulty:Hide()
	GuildInstanceDifficulty.Show = F.Dummy

	-- Hide all frames / 隱藏各種
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
		"VehicleSeatIndicator",		-- Vehicle / 載具
		"GarrisonLandingPageMinimapButton",
	}
	
	for i, v in pairs(hideAll) do
		getglobal(v).Show = F.Dummy
		getglobal(v):Hide()
	end
	
	-- Queue Button / 佇列圖示
	QueueStatusMinimapButtonBorder:Hide()
	QueueStatusMinimapButton:SetFrameLevel(10)
	-- Mail Frame / 信件提示
	MiniMapMailBorder:Hide()
	MiniMapMailIcon:SetTexture(G.Mail)
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
	Stat:SetAlpha(0)
	Stat:SetScale(1)

local function createGarrisonTooltip(self)
	if not EKMinimapDB["CharacterIcon"] then return end
	
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOM", findAnchor("MinimapAnchor") and (Minimap:GetWidth()*.7) or -(Minimap:GetWidth()*.7), -10)
	GameTooltip:AddLine(CHARACTER_BUTTON, .6,.8, 1)

	-- Experience
	if UnitLevel("player") < MAX_PLAYER_LEVEL and not IsXPUserDisabled() then
		local cur, max = UnitXP("player"), UnitXPMax("player")
		local lvl = UnitLevel("player")
		local rested = GetXPExhaustion()
		
		GameTooltip:AddLine(" ")
		GameTooltip:AddDoubleLine(CHARACTER, LEVEL.. " "..lvl, 0, 1, .5, 0, 1, .5)
		GameTooltip:AddDoubleLine(XP..HEADER_COLON, cur.." / "..max.." ("..floor(cur/max*100).."%)", 1,1,1,1,1,1)
		if rested then
			GameTooltip:AddDoubleLine(TUTORIAL_TITLE26..HEADER_COLON, rested.." ("..floor(rested/max*100).."%)", 1,1,1,1,1,1)
		end
	end
	
	-- Honor
	do
		local cur, max = UnitHonor("player"), UnitHonorMax("player")
		local lvl = UnitHonorLevel("player")
		
		GameTooltip:AddLine(" ")
		GameTooltip:AddDoubleLine(HONOR, LEVEL.." "..lvl, 0, 1, .5, 0, 1, .5)
		GameTooltip:AddDoubleLine(REFORGE_CURRENT..HEADER_COLON, cur.."/"..max.." ("..floor(cur/max*100).."%)", 1, 1, 1, 1, 1, 1)
		GameTooltip:AddDoubleLine(NEXT_RANK_COLON, (max-cur), 1, 1, 1, 1, 1, 1)
	end
		
	-- Reputation
	do
		local name, standing, min, max, cur = GetWatchedFactionInfo()
		
		if name then
			GameTooltip:AddLine(" ")
			GameTooltip:AddDoubleLine(name, _G["FACTION_STANDING_LABEL"..standing], 0, 1, 0.5, 0, 1, 0.5)
			if standing == MAX_REPUTATION_REACTION then
				max = min + 1e3
				cur = max - 1
			end
			GameTooltip:AddDoubleLine(REFORGE_CURRENT..HEADER_COLON, cur - min.." / "..max - min.." ("..floor((cur - min)/(max - min)*100).."%)", 1, 1, 1, 1, 1, 1)
			if standing ~= 8 then
				GameTooltip:AddDoubleLine(NEXT_RANK_COLON, (max-cur), 1, 1, 1, 1, 1, 1)
			end
		end
	end
	
	-- azerite
	do
		local azeriteItem = C_AzeriteItem.FindActiveAzeriteItem()
		
		if azeriteItem then
			local cur, max = C_AzeriteItem.GetAzeriteItemXPInfo(azeriteItem)
			local lvl = C_AzeriteItem.GetPowerLevel(azeriteItem)
			
			GameTooltip:AddLine(" ")
			GameTooltip:AddDoubleLine(ARTIFACT_POWER, LEVEL.." "..lvl, 0, 1, .5, 0, 1, .5)
			GameTooltip:AddDoubleLine(REFORGE_CURRENT..HEADER_COLON, cur.."/"..max.." ("..floor(cur/max*100).."%)", 1, 1, 1, 1, 1, 1)
			GameTooltip:AddDoubleLine(NEXT_RANK_COLON, (max-cur), 1, 1, 1, 1, 1, 1)
		end
	end
	
	GameTooltip:Show()
end

--======================================================--
-----------------    [[ Difficulty ]]    -----------------
--======================================================--

local Diff = CreateFrame("Frame", "EKMinimapDungeonIcon", Minimap)
	Diff:SetSize(40, 40)
	Diff:SetFrameLevel(Minimap:GetFrameLevel()+2)
	Diff.Texture = Diff:CreateTexture(nil, "OVERLAY")
	Diff.Texture:SetAllPoints(Diff)
	Diff.Texture:SetTexture(G.Diff)
	Diff.Texture:SetVertexColor(G.Ccolors.r, G.Ccolors.g, G.Ccolors.b)

local function styleDifficulty(self)
	-- Difficulty Text / 難度文字
	local DiffText = F.CreateFS(self, "", "CENTER")
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
		Diff:SetAlpha(0)
	else
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
	ping.text = F.CreateFS(ping, "", "CENTER")

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
	
	--Stat:RegisterEvent("PLAYER_ENTERING_WORLD")
	--Stat:SetScript("OnEvent", StatPos)
	
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

local function updateIconPos()
	QueueStatusMinimapButton:ClearAllPoints()
	QueueStatusFrame:ClearAllPoints()	-- Queue Tooltip fix / 佇列圖示提示
	MiniMapMailFrame:ClearAllPoints()
	
	Stat:ClearAllPoints()
	Diff:ClearAllPoints()

	if findAnchor("MinimapAnchor") then
		QueueStatusMinimapButton:SetPoint("TOPRIGHT", Minimap, 0, 0)
		QueueStatusFrame:SetPoint("TOPLEFT", Minimap, "TOPRIGHT", 10, -2)
		MiniMapMailFrame:SetPoint("BOTTOMLEFT", Minimap, 0, 0)
		
		Stat:SetPoint("BOTTOMRIGHT", Minimap, -1, 2)
		Diff:SetPoint("TOPLEFT", Minimap,  -5, 5)
	else
		QueueStatusMinimapButton:SetPoint("TOPLEFT", Minimap, 0, 0)
		QueueStatusFrame:SetPoint("TOPRIGHT", Minimap, "TOPLEFT", -10, -2)
		MiniMapMailFrame:SetPoint("BOTTOMRIGHT", Minimap, 0, 0)
		
		Stat:SetPoint("BOTTOMLEFT", Minimap, -1, 2)
		Diff:SetPoint("TOPRIGHT", Minimap,  5, 5)
	end
end

SlashCmdList["EJCET1"] = function()
	EjectPassengerFromSeat(1)
end
SLASH_EJCET11 = "/ej1"
SLASH_EJCET12 = "/eject1"

-- Reset size / 重置
SlashCmdList["EJCET2"] = function()
	EjectPassengerFromSeat(2)
end
SLASH_EJCET21 = "/ej2"
SLASH_EJCET22 = "/ejct2"

F.ResetM = function()
	updateMinimapPos()
	updateMinimapSize()
	updateIconPos()
	
end

local function OnEvent(self, event, addon)
	-- Hide Clock / 隱藏時鐘
	if event == "ADDON_LOADED" and addon == "Blizzard_TimeManager" then
		TimeManagerClockButton:Hide()
		TimeManagerClockButton:SetScript("OnShow", function(self)
			TimeManagerClockButton:Hide()
		end)
		self:UnregisterEvent("ADDON_LOADED")
	elseif event == "PLAYER_LOGIN" then
		whoPing()
		setMinimap()
		updateIconPos()
	else
		return
	end
end

local frame = CreateFrame("FRAME")
	frame:RegisterEvent("PLAYER_LOGIN")
	frame:RegisterEvent("ADDON_LOADED")
	frame:SetScript("OnEvent", OnEvent)

local HideOH = CreateFrame("Frame")
	HideOH:SetScript("OnUpdate", function(self,...)
		local OrderHallCommandBar = OrderHallCommandBar
		
		if OrderHallCommandBar then
			OrderHallCommandBar.Show = F.Dummy
			OrderHallCommandBar:Hide()
			OrderHallCommandBar:UnregisterAllEvents()
		end
		
		OrderHall_CheckCommandBar = F.Dummy
		self:SetScript("OnUpdate", nil)
	end)