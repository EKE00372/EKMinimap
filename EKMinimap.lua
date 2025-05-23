local addon, ns = ...
local C, F, G, L = unpack(ns)
local Minimap, MinimapCluster, sub, floor, CreateFrame = Minimap, MinimapCluster, string.sub, math.floor, CreateFrame
local MailFrame = MinimapCluster.IndicatorFrame.MailFrame
local AddonCompartmentFrame = AddonCompartmentFrame

--====================================================--
-----------------    [[ Function ]]    -----------------
--====================================================--

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

--[[ Format 24/12 hour clock ]]--

local function updateTimerFormat(hour, minute)
	if not EKMinimapDB["HoverClock"] then return end
	
	if GetCVarBool("timeMgrUseMilitaryTime") then
		return format(TIMEMANAGER_TICKER_24HOUR, hour, minute)
	else
		local timerUnit = hour < 12 and " AM" or " PM"
		
		if hour > 12 then
			hour = hour - 12
		end
		
		return format(TIMEMANAGER_TICKER_12HOUR..timerUnit, hour, minute)
	end
end

--====================-==============================--
-----------------    [[ Minimap ]]    -----------------
--===================================================--

local function updateMiniimapTracking()
	if EKMinimapDB["Tracking"] then
		SetCVar("minimapTrackingShowAll", 1)
	else
		SetCVar("minimapTrackingShowAll", 0)
	end
end

local function updateMinimapPos()
	Minimap:ClearAllPoints()
	Minimap:SetPoint(EKMinimapDB["MinimapAnchor"], UIParent, EKMinimapDB["MinimapX"], EKMinimapDB["MinimapY"])
end

local function updateMinimapSize()
	-- default size is ≈ 140
	-- We use SetScale() instead SetSize() because there's an issue happened on load order and addon icons.
	-- addon minimap icon may put themself to strange place because this addon load after then icons been created.
	MinimapCluster:SetScale(EKMinimapDB["MinimapScale"])
end

local function setMinimap()
	
	--MinimapCluster.SetPoint = F.Dummy
	--MinimapCluster.ClearAllPoints = F.Dummy
	updateMinimapPos()
	
	Minimap:SetClampedToScreen(true)
	Minimap:SetMovable(true)
	Minimap:EnableMouse(true)
	Minimap:RegisterForDrag("RightButton")
	
	updateMinimapSize()
	Minimap:SetMaskTexture(G.Tex)
	Minimap:SetFrameStrata("LOW")
	Minimap:SetFrameLevel(3)

	--[[hooksecurefunc(Minimap, "SetPoint", function(frame, _, _, _, _, _, force)
		if force then return end
		frame:ClearAllPoints()
		frame:SetPoint("TOPRIGHT", Minimap, "TOPRIGHT", 0, 0, true)
	end)]]--
	
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
	
	-- Hide Blizzard
	local hideAll = {
		MinimapBackdrop,
		MinimapCluster.BorderTop,
		MinimapCluster.ZoneTextButton,
		Minimap.ZoomIn,
		Minimap.ZoomOut,
		--MinimapCluster.Tracking,
		MinimapCluster.InstanceDifficulty,
		GameTimeFrame,
		DurabilityFrame,
		VehicleSeatIndicator,
		ExpansionLandingPageMinimapButton,
	}
	
	for _, f in ipairs(hideAll) do
		f.Show = F.Dummy
		f:Hide()
	end
	
	-- Mail Frame / 信件提示
	MailFrame:SetFrameLevel(11)
	MailFrame:SetScale(1.2)
	-- Tracking menu / 追蹤選單
	_G.MinimapCluster.Tracking:SetAlpha(0)
	_G.MinimapCluster.Tracking:SetScale(0.0001)
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

--=================================================--
-----------------    [[ Queue ]]    -----------------
--=================================================--

local function QueueStatus()
	if not EKMinimapDB["QueueStatus"] then return end
	
	QueueStatusButton:SetFrameLevel(999)
	QueueStatusButton:SetParent(Minimap)
	QueueStatusButton:SetScale(.8)
	
	local function hookAnchor()
		QueueStatusButton:ClearAllPoints()
		QueueStatusFrame:ClearAllPoints()
		
		if findAnchor("MinimapAnchor") then
			QueueStatusButton:SetPoint("TOPRIGHT", Minimap, -5, -5)
			QueueStatusFrame:SetPoint("TOPLEFT", Minimap, "TOPRIGHT", 10, -2)
		else
			QueueStatusButton:SetPoint("TOPLEFT", Minimap, 5, -5)
			QueueStatusFrame:SetPoint("TOPRIGHT", Minimap, "TOPLEFT", -10, -2)
		end
	end
	
	hooksecurefunc(QueueStatusFrame, "Update", hookAnchor)
end

--===================================================--
-----------------    [[ Tooltip ]]    -----------------
--===================================================--

local Stat = CreateFrame("Button", "EKMinimapTooltipButton", Minimap)
	Stat:SetHitRectInsets(-5, -5, -5, 5)
	Stat:SetSize(46, 46)
	Stat:ClearAllPoints()
	Stat:SetFrameLevel(Minimap:GetFrameLevel()+2)
	Stat:SetNormalTexture(G.Report)
	Stat:SetPushedTexture(G.Report)
	Stat:SetHighlightTexture(G.Report)
	Stat:SetAlpha(0)
	Stat:SetScale(1)
	AddonCompartmentFrame:ClearAllPoints()
	AddonCompartmentFrame:SetAllPoints(Minimap)
	AddonCompartmentFrame:SetPoint("CENTER", Stat)
	AddonCompartmentFrame:SetAlpha(0)
	AddonCompartmentFrame:EnableMouse(false)

local function createGarrisonTooltip(self)
	if not EKMinimapDB["CharacterIcon"] then return end
	
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOM", findAnchor("MinimapAnchor") and (Minimap:GetWidth()*.7) or -(Minimap:GetWidth()*.7), -10)
	GameTooltip:AddLine(CHARACTER_BUTTON, .6,.8, 1)

	-- Experience
	if not IsPlayerAtEffectiveMaxLevel() then
		local cur, max = UnitXP("player"), UnitXPMax("player")
		local lvl = UnitLevel("player")
		local rested = GetXPExhaustion()
		
		GameTooltip:AddLine(" ")
		GameTooltip:AddDoubleLine(CHARACTER, LEVEL.. " "..lvl, 0, 1, .5, 0, 1, .5)
		GameTooltip:AddDoubleLine(XP..HEADER_COLON, cur.."/"..max.." ("..floor(cur/max*100).."%)", 1,1,1,1,1,1)
		if rested then
			GameTooltip:AddDoubleLine(TUTORIAL_TITLE26..HEADER_COLON, rested.." ("..floor(rested/max*100).."%)", 1,1,1,1,1,1)
		end
	end
	
	-- Honor
	do
		local lvl, cur, max = UnitHonorLevel("player"), UnitHonor("player"), UnitHonorMax("player")
		
		GameTooltip:AddLine(" ")
		GameTooltip:AddDoubleLine(HONOR, LEVEL.." "..lvl, 0, 1, .5, 0, 1, .5)
		GameTooltip:AddDoubleLine(REFORGE_CURRENT..HEADER_COLON, cur.."/"..max.." ("..floor(cur/max*100).."%)", 1, 1, 1, 1, 1, 1)
		GameTooltip:AddDoubleLine(NEXT_RANK_COLON, (max-cur), 1, 1, 1, 1, 1, 1)
	end
		
	-- Reputation
	if C_Reputation.GetWatchedFactionData() then
		local GetWatchedFactionData = C_Reputation.GetWatchedFactionData()
		local name = GetWatchedFactionData.name
		local standing = GetWatchedFactionData.reaction
		local min = GetWatchedFactionData.currentReactionThreshold
		local max = GetWatchedFactionData.nextReactionThreshold
		local cur = GetWatchedFactionData.currentStanding
		local factionID = GetWatchedFactionData.factionID
		
		GameTooltip:AddLine(" ")
		
		local repInfo = C_GossipInfo.GetFriendshipReputation(factionID)
		local friendID =  repInfo.friendshipFactionID

		if factionID and C_Reputation.IsMajorFaction(factionID) then
			-- 10.0 四大陣營
			local majorFactionData = C_MajorFactions.GetMajorFactionData(factionID)
			local renownLevel, cur, min, max = majorFactionData.renownLevel, majorFactionData.renownReputationEarned, 0, majorFactionData.renownLevelThreshold
			
			GameTooltip:AddDoubleLine(name, RENOWN_LEVEL_LABEL..renownLevel, 0, 1, 0.5, 0, 1, 0.5)
			GameTooltip:AddDoubleLine(REFORGE_CURRENT..HEADER_COLON, cur.."/"..max.." ("..floor(cur/max*100).."%)", 1, 1, 1, 1, 1, 1)
			GameTooltip:AddDoubleLine(NEXT_RANK_COLON, (max-cur), 1, 1, 1, 1, 1, 1)
		elseif friendID and friendID ~= 0 then
			-- 新式聲望，親密度
			
			-- 當前值, 當前階段, 當前階段最小值, 當前階段最大值
			local curRep, curReaction, curThreshold, nextThreshold = repInfo.standing, repInfo.reaction, repInfo.reactionThreshold, repInfo.nextThreshold
			GameTooltip:AddDoubleLine(name, curReaction, 0, 1, 0.5, 0, 1, 0.5)
			
			if nextThreshold then
				cur, min, max = curRep, curThreshold, nextThreshold
				GameTooltip:AddDoubleLine(REFORGE_CURRENT..HEADER_COLON, cur - min.."/"..max - min.." ("..floor((cur - min)/(max - min)*100).."%)", 1, 1, 1, 1, 1, 1)
				GameTooltip:AddDoubleLine(NEXT_RANK_COLON, (max-cur), 1, 1, 1, 1, 1, 1)
			end
		else
			-- 傳統聲望
			GameTooltip:AddDoubleLine(name, _G["FACTION_STANDING_LABEL"..standing], 0, 1, 0.5, 0, 1, 0.5)
			
			if standing == MAX_REPUTATION_REACTION then
				max = min + 1e3
				cur = max - 1
			end
			GameTooltip:AddDoubleLine(REFORGE_CURRENT..HEADER_COLON, cur - min.."/"..max - min.." ("..floor((cur - min)/(max - min)*100).."%)", 1, 1, 1, 1, 1, 1)
			if standing ~= 8 then
				GameTooltip:AddDoubleLine(NEXT_RANK_COLON, (max-cur), 1, 1, 1, 1, 1, 1)
			end
		end
	end
	
	GameTooltip:AddLine(" ")
	GameTooltip:AddDoubleLine(" ", "|TInterface\\TUTORIALFRAME\\UI-TUTORIAL-FRAME:13:11:0:-1:512:512:12:66:333:411|t "..L.AddonCompartment, 1,1,1,1,1,1)

	GameTooltip:Show()
end

local function hideExpBar()
	if EKMinimapDB["CharacterIcon"] then
		StatusTrackingBarManager.Show = F.Dummy
		StatusTrackingBarManager:Hide()
	end
end
--======================================================--
-----------------    [[ Difficulty ]]    -----------------
--======================================================--

local Diff = CreateFrame("Frame", "EKMinimapDungeonIcon", Minimap)
	Diff:SetSize(46, 46)
	Diff:SetFrameLevel(Minimap:GetFrameLevel()+2)
	Diff.Texture = Diff:CreateTexture(nil, "OVERLAY")
	Diff.Texture:SetAllPoints(Diff)
	Diff.Texture:SetTexture(G.Diff)
	Diff.Texture:SetVertexColor(G.Ccolors.r, G.Ccolors.g, G.Ccolors.b)
	Diff.Text = F.CreateFS(Diff, "",  G.fontSize+4, "CENTER")


local function styleDifficulty(self)
	-- Difficulty Text / 難度文字
	local DiffText = self.Text

	local inInstance, instanceType = IsInInstance()
	local difficulty = select(3, GetInstanceInfo())
	local num = select(9, GetInstanceInfo())
	local mplus = select(1, C_ChallengeMode.GetActiveKeystoneInfo()) or ""
	local DifficultyTAG = {
		-- https://warcraft.wiki.gg/wiki/DifficultyID
		[1] = "5N",
		[2] = "5H",
		[3] = "10N",
		[4] = "25N",
		[5] = "10H",		-- 5 普通十人
		[6] = "25H",
		[7] = "L",			-- Old LFR (before SOO)
		[8] = "M" .. mplus,	-- Challenge Mode and Mythic+
		[9] = "40",
		[11] = "E",		-- 11 MOP英雄事件
		[12] = "E",		-- 12 MOP普通事件
		[14] = num .. "N",	-- Flex normal raid
		[15] = num .. "H",	-- Flex heroic raid
		[16] = "M",			-- Mythic raid since WOD
		[17] = num .. "L",	-- Flex LFR raid
		[18] = "E",			-- 18 Event(raid)
		[19] = "E",			-- 19 Event(party)
		[20] = "E",			-- 20 Event(scenario)
	
		[23] = "5M",
		[24] = "T",			-- 24 Timewalking(地城時光)
		[25] = "PVP",
		[29] = "PEP",
		[30] = "E",			-- 30 Event(scenario)
		[32] = "PVP",
		[33] = "T",			-- 33 Timewalking(團隊時光)
		[34] = "PVP",
		[38] = "3N",		-- 38 BFA普通海嶼
		[39] = "3H",		-- 39 BFA英雄海嶼
		[40] = "3M",		-- 40 BFA傳奇海嶼
		[45] = "PVP",		-- 45 PVP海嶼?
		
		[147] = "WF",		-- 147 戰爭前線
		[149] = "HWF",		-- 147 英雄戰爭前線
		[151] = "T",		-- 151 Timewalking(隨機團隊時光)
		[152] = "E",		-- 152 幻象
		[153] = "10",		-- 153 十人海島
		-- 168/169/170/171 晉升之路
		[167] = "TOR",		-- 167 托加斯特
		--[208] = "D"			-- 208 探索/地下堡 delve
	}
	
	if instanceType == "party" or instanceType == "raid" or instanceType == "scenario" then
		DiffText:SetText(DifficultyTAG[difficulty] or "D")
	elseif instanceType == "pvp" or instanceType == "arena" then
		DiffText:SetText("PVP")
	else
		DiffText:SetText("D")
	end

	if not inInstance then
		Diff:SetAlpha(0)
	else
		Diff:SetAlpha(1)
	end
end

--=================================================--
-----------------    [[ Clock ]]    -----------------
--=================================================--

local function HoverClock()
	if not EKMinimapDB["HoverClock"] then return end
	
	local Clock = CreateFrame("Frame", "EKMinimapTimeIcon", Minimap)
	Clock:SetFrameLevel(Minimap:GetFrameLevel()+2)
	Clock:SetSize(Minimap:GetWidth()*.8, 20)
	Clock:EnableMouse(false)
	Clock:ClearAllPoints()
	Clock:SetPoint("TOP", Minimap, 0, -2)
	Clock.Text = F.CreateFS(Clock, "",  G.fontSize+4, "CENTER")
	Clock.Text:SetText("")
	Clock:SetAlpha(0)
	
	Clock:SetScript("OnEnter", function(self)
		local hour, minute
		if GetCVarBool("timeMgrUseLocalTime") then
			hour, minute = tonumber(date("%H")), tonumber(date("%M"))
		else
			hour, minute = GetGameTime()
		end
		
		Clock.Text:SetText(updateTimerFormat(hour, minute))
		securecall(UIFrameFadeIn, Clock, .2, 0, 1)
	end)
	Clock:SetScript("OnLeave", function(self)
		securecall(UIFrameFadeOut, Clock, .8, 1, 0)
	end)
end
--================================================--
-----------------    [[ Ping ]]    -----------------
--=================================================--

local function whoPing()
	local ping = CreateFrame("Frame", nil, Minimap)
	ping:SetSize(100, 20)
	ping:SetPoint("BOTTOM", Minimap, 0, 2)
	ping:RegisterEvent("MINIMAP_PING")
	ping.text = F.CreateFS(ping, "",  G.fontSize+4, "CENTER")

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
	Stat:SetScript("OnMouseUp", function(self, button)
		if button == "RightButton" then
			local button = AddonCompartmentFrame
			button:OpenMenu()
			if button.menu then
				button.menu:ClearAllPoints()
				button.menu:SetPoint("TOP", self, "BOTTOM", findAnchor("MinimapAnchor") and (Minimap:GetWidth() * .5) or -(Minimap:GetWidth() * .5), -3)
			end
		else
			ExpansionLandingPageMinimapButton:Click()
		end
	end)
	
	Diff:RegisterEvent("PLAYER_ENTERING_WORLD")
	Diff:RegisterEvent("PLAYER_DIFFICULTY_CHANGED")
	Diff:RegisterEvent("INSTANCE_GROUP_SIZE_CHANGED")
	Diff:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	Diff:RegisterEvent("CHALLENGE_MODE_START")
	Diff:RegisterEvent("CHALLENGE_MODE_COMPLETED")
	Diff:RegisterEvent("CHALLENGE_MODE_RESET")
	Diff:SetScript("OnEvent", styleDifficulty)

--================================================--
-----------------    [[ Load ]]    -----------------
--================================================--

local function updateIconPos()
	MailFrame:ClearAllPoints()
	Stat:ClearAllPoints()
	Diff:ClearAllPoints()

	if findAnchor("MinimapAnchor") then
		--MailFrame:SetPoint("BOTTOMLEFT", Minimap, 3, 5)
		Stat:SetPoint("BOTTOMRIGHT", Minimap, 4, -3)
		Diff:SetPoint("TOPLEFT", Minimap,  -5, 5)
		
		local function updateMapAnchor(frame, _, _, _, _, _, force)
			if force then return end
			frame:ClearAllPoints()
			frame:SetPoint("BOTTOMLEFT", Minimap, "BOTTOMLEFT", 3, 3, true)
		end
		hooksecurefunc(MailFrame, "SetPoint", updateMapAnchor)
	else
		--MailFrame:SetPoint("BOTTOMRIGHT", Minimap, -3, 3)
		Stat:SetPoint("BOTTOMLEFT", Minimap, -4, -3)
		Diff:SetPoint("TOPRIGHT", Minimap,  5, 5)
		
		local function updateMapAnchor(frame, _, _, _, _, _, force)
			if force then return end
			frame:ClearAllPoints()
			frame:SetPoint("BOTTOMRIGHT", Minimap, "BOTTOMRIGHT", -3, 3, true)
		end
		hooksecurefunc(MailFrame, "SetPoint", updateMapAnchor)
	end
end

F.ResetM = function()
	updateMinimapPos()
	updateMinimapSize()
	updateIconPos()
	updateMiniimapTracking()
end

local ignoredFrames = {
	["MinimapCluster"] = function() return true end,
	["VehicleSeatIndicator"] = function() return true end,
}

local shutdownMode = {
	"OnEditModeEnter",
	"OnEditModeExit",
	"HasActiveChanges",
	"HighlightSystem",
	"SelectSystem",
}

local function OnEvent(self, event, addon)
	-- Hide Clock / 隱藏時鐘
	if event == "ADDON_LOADED" and addon == "Blizzard_TimeManager" then
		TimeManagerClockButton:Hide()
		TimeManagerClockButton:SetScript("OnShow", function(self)
			TimeManagerClockButton:Hide()
		end)
		self:UnregisterEvent("ADDON_LOADED")
	elseif event == "PLAYER_LOGIN" then
		-- make sure MBB dont take my icon 益rz
		if MBB_Ignore then
			tinsert(MBB_Ignore, "EKMinimapTooltipButton")
		end
		
		-- remove the initial registers
		local editMode = _G.EditModeManagerFrame
		local registered = editMode.registeredSystemFrames
		for i = #registered, 1, -1 do
			local frame = registered[i]
			local ignore = ignoredFrames[frame:GetName()]

			if ignore and ignore() then
				for _, key in next, shutdownMode do
					frame[key] = F.Dummy
				end
			end
		end
		
		QueueStatus()
		HoverClock()
		whoPing()
		setMinimap()
		updateIconPos()
		hideExpBar()
		updateMiniimapTracking()
	else
		return
	end
end

local frame = CreateFrame("FRAME")
	frame:RegisterEvent("PLAYER_LOGIN")
	frame:RegisterEvent("ADDON_LOADED")
	frame:SetScript("OnEvent", OnEvent)