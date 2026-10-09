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
	local anchor = F.GetEKMOption(value)
	local myAnchor = sub(anchor, -4)	-- get minimap anchor left or rignt
	return myAnchor == "LEFT"
end

--====================-==============================--
-----------------    [[ Minimap ]]    -----------------
--===================================================--

local function updateMiniimapTracking()
	if F.GetEKMOption("Tracking") then
		SetCVar("minimapTrackingShowAll", 1)
	else
		SetCVar("minimapTrackingShowAll", 0)
	end
end

local function updateMinimapPos()
	Minimap:ClearAllPoints()
	Minimap:SetPoint(F.GetEKMOption("MinimapAnchor"), UIParent, F.GetEKMOption("MinimapX"), F.GetEKMOption("MinimapY"))
end

local function updateMinimapScale()
	-- Default size is ~≈ 140
	-- Use SetScale() instead SetSize() because there's an issue happened on load order and addon icons.
	-- addon minimap icon may put themself to strange place because icon was created before EKMinimap addon loaded.
	
	-- To ignore editmode size config, we don't use MinimapCluster
	--MinimapCluster:SetScale(F.GetEKMOption("MinimapScale"))

	Minimap:SetIgnoreParentScale(true)
	Minimap:SetScale(F.GetEKMOption("MinimapScale"))
end

local function setMinimap()

	updateMinimapPos()
	Minimap:SetClampedToScreen(true)
	Minimap:SetMovable(true)
	Minimap:EnableMouse(true)
	Minimap:RegisterForDrag("RightButton")

	updateMinimapScale()
	Minimap:SetMaskTexture(G.Tex)
	Minimap:SetFrameStrata("LOW")
	Minimap:SetFrameLevel(3)
	EKMinimapClicker:SetFrameLevel(Minimap:GetFrameLevel() + 5)

	-- Where to test:  Queen Azshara, The Eternal Palace
	hooksecurefunc(UIWidgetBelowMinimapContainerFrame, "SetPoint", function(self, _, parent)
		if parent == "MinimapCluster" or parent == MinimapCluster then
			self:ClearAllPoints()
			self:SetClampedToScreen(true)
			self:SetPoint("TOP", Minimap, "BOTTOM")
		end
	end)

	MinimapCluster:EnableMouse(false)
	Minimap.bg = F.CreateBG(Minimap, 5, 5, 1)

	local coords = MinimapCluster.MinimapContainer.PlayerCoords
	if coords then
		coords:SetParent(Minimap)
		coords:ClearAllPoints()
		coords:SetPoint("BOTTOM", Minimap, "BOTTOM", 0, 8)
		local font, size = coords.CoordText:GetFont()
		coords.CoordText:SetFont(font, size, "OUTLINE")
	end

	Minimap:SetArchBlobRingScalar(0)
	Minimap:SetQuestBlobRingScalar(0)
	MinimapCluster.BorderTop:Hide()
	MinimapCluster.ZoneTextButton:Hide()

	-- Keep the housing static overlay available while hiding Blizzard's round border.
	if MinimapBackdrop and MinimapBackdrop.StaticOverlayTexture then
		MinimapBackdrop.StaticOverlayTexture:ClearAllPoints()
		MinimapBackdrop.StaticOverlayTexture:SetAllPoints(Minimap)
		MinimapBackdrop.StaticOverlayTexture:SetTexCoord(.2, .8, .2, .8)
	end
	
	-- Hide Blizzard
	local hideAll = {
		MinimapCompassTexture,
		Minimap.ZoomIn,
		Minimap.ZoomOut,
		MinimapCluster.InstanceDifficulty,
		GameTimeFrame,
		ExpansionLandingPageMinimapButton,
		MinimapCluster.DielFrame,	-- Forever 日夜指示
	}
	
	-- Optional hide frame
	local hideOptional = {
		["VehicleSeat"] = VehicleSeatIndicator,
		["Durability"] = DurabilityFrame,
	}

	for _, f in ipairs(hideAll) do
		f:Hide()
		hooksecurefunc(f, "Show", function(self) self:Hide() end)
	end
	
    for key, f in pairs(hideOptional) do
        if F.GetEKMOption(key) then
            f:Hide()
            hooksecurefunc(f, "Show", function(self) self:Hide() end)
        end
    end

	-- Mail Frame / 信件提示
	MailFrame:SetFrameLevel(11)
	MailFrame:SetScale(1.2)

	-- Tracking menu / 追蹤選單
	-- To keep menu, don't hide the icon
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
	if not F.GetEKMOption("QueueStatus") then return end
	
	QueueStatusButton:SetParent(Minimap)
	QueueStatusButton:SetFrameLevel(999)
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

	hookAnchor()
end

--===================================================--
-----------------    [[ Tooltip ]]    -----------------
--===================================================--

local Stat = CreateFrame("Button", "EKMinimapTooltipButton", Minimap)
    Stat:EnableMouse(true)
    Stat:RegisterForClicks("AnyUp")
    Stat:SetPropagateMouseClicks(false)
	Stat:SetHitRectInsets(-5, -5, -5, 5)
	Stat:SetSize(46, 46)
	Stat:ClearAllPoints()
	Stat:SetFrameLevel(Minimap:GetFrameLevel()+2)
	Stat:SetNormalTexture(G.Report)
	Stat:SetPushedTexture(G.Report)
	Stat:SetHighlightTexture(G.Report)
	Stat:SetAlpha(0)
	Stat:SetScale(1)
	AddonCompartmentFrame:SetParent(Minimap)	-- 先把按鈕移出 MinimapCluster 以免參與原生尺寸計算引起錯誤
	AddonCompartmentFrame:ClearAllPoints()
	AddonCompartmentFrame:SetAllPoints(Stat)
	AddonCompartmentFrame:SetAlpha(0)
	AddonCompartmentFrame:EnableMouse(false)

-- 資料片按鈕
local function canOpenLandingPage()
	if not GameRulesUtil.ShouldShowExpansionLandingPageButton() then return false end
	if ExpansionLandingPageMinimapButton:IsExpansionOverlayMode() then return true end
	if not ExpansionLandingPageMinimapButton:IsInGarrisonMode() then return false end

	local garrisonType = C_Garrison.GetLandingPageGarrisonType()
	return garrisonType ~= 0 and C_Garrison.IsLandingPageMinimapButtonVisible(garrisonType)
end

local function createGarrisonTooltip(self)
	if not F.GetEKMOption("CharacterIcon") then return end
	
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOM", findAnchor("MinimapAnchor") and (Minimap:GetWidth()*.7) or -(Minimap:GetWidth()*.7), -10)
	GameTooltip:AddLine(CHARACTER_BUTTON, .6,.8, 1)

	-- Experience
	if not GameRulesUtil.IsPlayerAtEffectiveMaxLevel() then
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
	if G.IsForever then
		local info = C_MajorFactions.GetMajorFactionProgressionInfo(2800)
		if info then
			local rank, cur, max = info.renownLevel, info.renownReputationEarned, info.renownLevelThreshold
			local rankText = PVP_RANK_0_NAME
			if rank > 0 then
				local faction = (UnitFactionGroup("player") == "Alliance" and 1) or 0
				local title = GetText("PVP_RANK_"..(Enum.PvPRanks.Rank_1 + rank - 1).."_"..faction, UnitSex("player"))
				rankText = PVP_RANK_NUMBER_AND_TITLE:format(rank, title)
			end

			GameTooltip:AddLine(" ")
			GameTooltip:AddDoubleLine(HONOR, rankText, 0, 1, .5, 0, 1, .5)
			if max > 0 and rank < info.maxLevel then
				GameTooltip:AddDoubleLine(REFORGE_CURRENT..HEADER_COLON, cur.."/"..max.." ("..floor(cur/max*100).."%)", 1, 1, 1, 1, 1, 1)
				GameTooltip:AddDoubleLine(NEXT_RANK_COLON, (max-cur), 1, 1, 1, 1, 1, 1)
			else
				GameTooltip:AddDoubleLine(REFORGE_CURRENT..HEADER_COLON, tostring(cur), 1, 1, 1, 1, 1, 1)
			end
		end
	else
		local lvl, cur, max = UnitHonorLevel("player"), UnitHonor("player"), UnitHonorMax("player")
		
		GameTooltip:AddLine(" ")
		GameTooltip:AddDoubleLine(HONOR, LEVEL.." "..lvl, 0, 1, .5, 0, 1, .5)
		GameTooltip:AddDoubleLine(REFORGE_CURRENT..HEADER_COLON, cur.."/"..max.." ("..floor(cur/max*100).."%)", 1, 1, 1, 1, 1, 1)
		GameTooltip:AddDoubleLine(NEXT_RANK_COLON, (max-cur), 1, 1, 1, 1, 1, 1)
	end
	
	-- Reputation
	local factionData = C_Reputation.GetWatchedFactionData()
	if factionData then
		local name = factionData.name
		local standing = factionData.reaction
		local min = factionData.currentReactionThreshold
		local max = factionData.nextReactionThreshold
		local cur = factionData.currentStanding
		local factionID = factionData.factionID
		
		GameTooltip:AddLine(" ")
		
		local repInfo = C_GossipInfo.GetFriendshipReputation(factionID)
		local friendID =  repInfo.friendshipFactionID
		local majorFactionData = C_Reputation.IsMajorFaction(factionID) and C_MajorFactions.GetMajorFactionData(factionID)

		if majorFactionData then
			GameTooltip:AddDoubleLine(name, JOURNEYS_RENOWN_LABEL.." "..majorFactionData.renownLevel, 0, 1, 0.5, 0, 1, 0.5)
		elseif friendID and friendID ~= 0 then
			GameTooltip:AddDoubleLine(name, repInfo.reaction, 0, 1, 0.5, 0, 1, 0.5)
		else
			GameTooltip:AddDoubleLine(name, _G["FACTION_STANDING_LABEL"..standing], 0, 1, 0.5, 0, 1, 0.5)
		end

		if C_Reputation.IsFactionParagonForCurrentPlayer(factionID) then
			local cur, max, _, hasRewardPending, _, paragonLevel = C_Reputation.GetFactionParagonInfo(factionID)
			if cur and max then
				GameTooltip:AddDoubleLine(REFORGE_CURRENT..HEADER_COLON, L.Paragon.." "..paragonLevel, 1, 1, 1, 1, 1, 1)
				GameTooltip:AddDoubleLine(NEXT_RANK_COLON, max-cur%max, 1, 1, 1, 1, 1, 1)
				if hasRewardPending then
					GameTooltip:AddDoubleLine(" ", WEEKLY_REWARDS_UNCLAIMED_TITLE, 1, 1, 1, 0, 1, 0.5)
				end
			end
		elseif majorFactionData then
			-- 10.0 以後的四大陣營
			local cur, max = majorFactionData.renownReputationEarned, majorFactionData.renownLevelThreshold

			GameTooltip:AddDoubleLine(REFORGE_CURRENT..HEADER_COLON, cur.."/"..max.." ("..floor(cur/max*100).."%)", 1, 1, 1, 1, 1, 1)
			GameTooltip:AddDoubleLine(NEXT_RANK_COLON, (max-cur), 1, 1, 1, 1, 1, 1)
		elseif friendID and friendID ~= 0 then
			-- 新式聲望，親密度：當前值, 當前階段最小值, 當前階段最大值
			local curRep, curThreshold, nextThreshold = repInfo.standing, repInfo.reactionThreshold, repInfo.nextThreshold
			
			if nextThreshold then
				cur, min, max = curRep, curThreshold, nextThreshold
				GameTooltip:AddDoubleLine(REFORGE_CURRENT..HEADER_COLON, cur - min.."/"..max - min.." ("..floor((cur - min)/(max - min)*100).."%)", 1, 1, 1, 1, 1, 1)
				GameTooltip:AddDoubleLine(NEXT_RANK_COLON, (max-cur), 1, 1, 1, 1, 1, 1)
			end
		else
			-- 傳統聲望	
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
	
	local landingTitle = canOpenLandingPage() and ExpansionLandingPageMinimapButton.title
	GameTooltip:AddLine(" ")
	if landingTitle then
		GameTooltip:AddDoubleLine(" ", "|TInterface\\TUTORIALFRAME\\UI-TUTORIAL-FRAME:13:11:0:-1:512:512:12:66:230:307|t "..landingTitle, 1,1,1,1,1,1)
	end
	GameTooltip:AddDoubleLine(" ", "|TInterface\\TUTORIALFRAME\\UI-TUTORIAL-FRAME:13:11:0:-1:512:512:12:66:333:411|t "..L.AddonCompartment, 1,1,1,1,1,1)


	GameTooltip:Show()
end

local function hideExpBar()
	if F.GetEKMOption("CharacterIcon") then
		StatusTrackingBarManager:UnregisterAllEvents()
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

local DifficultyTAG = {
		-- https://warcraft.wiki.gg/wiki/DifficultyID
		[1] = "5N",
		[2] = "5H",
		[3] = "10N",
		[4] = "25N",
		[5] = "10H",		-- 5 普通十人
		[6] = "25H",
		[7] = "L",			-- Old LFR (before SOO)
		[8] = "M",			-- Challenge Mode and Mythic+
		[9] = "40",
		[11] = "E",			-- 11 MOP英雄事件
		[12] = "E",			-- 12 MOP普通事件
		[14] = "N",			-- Flex normal raid
		[15] = "H",			-- Flex heroic raid
		[16] = "M",			-- Mythic raid since WOD
		[17] = "L",			-- Flex LFR raid
		[18] = "E",			-- 18 Event(raid)
		[19] = "E",			-- 19 Event(party)
		[20] = "E",			-- 20 Event(scenario)
	
		[23] = "5M",
		[24] = "T",			-- 24 Timewalking(party)
		[25] = "PvP",
		[29] = "PvP",		-- PvEvP Scenario
		[30] = "E",			-- 30 Event(scenario)
		[32] = "PvP",
		[33] = "T",			-- 33 Timewalking(raid)
		[34] = "PvP",
		[38] = "3N",		-- 38 普通海嶼
		[39] = "3H",		-- 39 英雄海嶼
		[40] = "3M",		-- 40 傳奇海嶼
		[45] = "PVP",		-- 45 PVP海嶼
		
		[147] = "WF",		-- 147 普通戰爭前線
		[149] = "HWF",		-- 147 英雄戰爭前線
		[151] = "T",		-- 151 Timewalking(LFR)
		[152] = "E",		-- 152 幻象
		--[153] = "10",		-- 153 十人海嶼
		-- 168/169/170/171 晉升之路
		[167] = "Tor",		-- 167 托加斯特
		[205] = "5",		-- 205 追随者地城
		--[208] = "D",		-- 208 探究
		--[220]	= "S"		-- 故事模式(raid)
	}

local function styleDifficulty(self)
	-- Difficulty Text / 難度文字
	local DiffText = self.Text
	local _, instanceType, difficulty, _, _, _, _, _, num = GetInstanceInfo()
	local text = DifficultyTAG[difficulty] or "D"
	if difficulty == 8 then
		local level = C_ChallengeMode.GetActiveKeystoneInfo()
		text = "M"..(level > 0 and level or "")
	elseif difficulty == 14 or difficulty == 15 or difficulty == 17 then
		text = num..text
	end

	if instanceType == "party" or instanceType == "raid" or instanceType == "scenario" then
		Diff:SetAlpha(1)
		DiffText:SetText(text)
	elseif instanceType == "pvp" or instanceType == "arena" then
		Diff:SetAlpha(1)
		DiffText:SetText("PVP")
	else
		Diff:SetAlpha(0)
		DiffText:SetText("")
	end
end

--=================================================--
-----------------    [[ Clock ]]    -----------------
--=================================================--

local function HoverClock()
	if not F.GetEKMOption("HoverClock") then return end
	
	local Clock = CreateFrame("Frame", "EKMinimapTimeIcon", Minimap)
	Clock:SetFrameLevel(EKMinimapClicker:GetFrameLevel()+1)
	Clock:SetSize(Minimap:GetWidth()*.8, 20)
	Clock:ClearAllPoints()
	Clock:SetPoint("TOP", Minimap, 0, -2)
	Clock.Text = F.CreateFS(Clock, "",  G.fontSize+4, "CENTER")
	Clock.Text:SetText("")
	Clock:SetAlpha(0)
	
	Clock:SetScript("OnEnter", function(self)
		-- 沿用原生的本地/伺服器時間與 12/24 小時格式
		Clock.Text:SetText((GameTime_GetTime(true)))
		securecall(UIFrameFadeIn, Clock, .2, 0, 1)
	end)
	Clock:SetScript("OnLeave", function(self)
		securecall(UIFrameFadeOut, Clock, .8, 1, 0)
	end)
	-- 保留滑鼠指向
	Clock:SetMouseMotionEnabled(true)
	Clock:SetPropagateMouseMotion(true)
	Clock:SetMouseClickEnabled(false)
end

--==================================================--
-----------------    [[ Script ]]    -----------------
--==================================================--
	
	-- [[ Minimap ]] --
	
	-- Alt+right click to drag frame
	local Clicker = CreateFrame("Frame", "EKMinimapClicker", Minimap)
	Clicker:SetAllPoints(Minimap)
	Clicker:EnableMouse(true)
	Clicker:EnableMouseWheel(true)
	Clicker:SetPassThroughButtons("LeftButton")
	Clicker:SetPropagateMouseMotion(true)
	Clicker:SetScript("OnMouseWheel", OnMouseWheel)
	Clicker:RegisterForDrag("RightButton")
	Clicker:SetScript("OnDragStart", function()
		if IsAltKeyDown() then
			Minimap:StartMoving()
		end
	end)
	Clicker:SetScript("OnDragStop", function()
		Minimap:StopMovingOrSizing()
	end)

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
		elseif button == "LeftButton" and canOpenLandingPage() then
			if F.CombatError() then return end
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

local mailAnchorHooked = false
local function updateIconPos()
	MailFrame:ClearAllPoints()
	Stat:ClearAllPoints()
    Diff:ClearAllPoints()
    Stat:SetFrameLevel(Clicker:GetFrameLevel() + 1)

	if findAnchor("MinimapAnchor") then
		Stat:SetPoint("BOTTOMRIGHT", Minimap, 4, -3)
		Diff:SetPoint("TOPLEFT", Minimap, -5, 5)
		MailFrame:SetPoint("BOTTOMLEFT", Minimap, "BOTTOMLEFT", 3, 3, true)
	else
		Stat:SetPoint("BOTTOMLEFT", Minimap, -4, -3)
		Diff:SetPoint("TOPRIGHT", Minimap, 5, 5)
		MailFrame:SetPoint("BOTTOMRIGHT", Minimap, "BOTTOMRIGHT", -3, 3, true)
	end

	if not mailAnchorHooked then
		hooksecurefunc(MailFrame, "SetPoint", function(frame, _, _, _, _, _, force)
			if force then return end

			frame:ClearAllPoints()
			if findAnchor("MinimapAnchor") then
				frame:SetPoint("BOTTOMLEFT", Minimap, "BOTTOMLEFT", 3, 3, true)
			else
				frame:SetPoint("BOTTOMRIGHT", Minimap, "BOTTOMRIGHT", -3, 3, true)
			end
		end)
		mailAnchorHooked = true
	end
end

F.ResetM = function()
	F.ApplyEKMPositionSettings()
	updateMinimapPos()
	updateMinimapScale()
	updateIconPos()
	updateMiniimapTracking()
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
		-- make sure MBB dont take my icon 益rz
		if MBB_Ignore then
			tinsert(MBB_Ignore, "EKMinimapTooltipButton")
		end
		
		setMinimap()
		QueueStatus()
		HoverClock()
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