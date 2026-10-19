local addon, ns = ...
local C, F, G, L = unpack(ns)
local Minimap, CreateFrame = Minimap, CreateFrame
local sub, floor, tinsert = string.sub, math.floor, table.insert

--====================================================--
-----------------    [[ Function ]]    -----------------
--====================================================--

-- [[ Make A Square / 弄成方型 ]] --

function GetMinimapShape()
	return "SQUARE"
end

-- [[ Custom API for anchor ]] --
local function findAnchor(value)
	local anchor = F.GetEKMOption(value)
	return sub(anchor, -4) == "LEFT"
end
--================================================--
-----------------    [[ Core ]]    -----------------
--================================================--

local function updateMinimapPos()
	Minimap:ClearAllPoints()
	Minimap:SetPoint(F.GetEKMOption("MinimapAnchor"), UIParent, F.GetEKMOption("MinimapX"), F.GetEKMOption("MinimapY"))
end

local function updateMinimapSize()
	-- 保留 Classic 的 140px 基準，以縮放調整整體並隔離編輯模式的父層縮放。
	Minimap:SetSize(140, 140)
	Minimap:SetIgnoreParentScale(true)
	Minimap:SetScale(F.GetEKMOption("MinimapScale"))
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

	MinimapCluster:EnableMouse(false)
	Minimap.bg = F.CreateBG(Minimap, 5, 5, 1)

	-- Hide all frames / 隱藏各種
	local hideAll = {
		MinimapBorder,
		MinimapCluster.BorderTop,
		MinimapNorthTag,
		MiniMapWorldMapButton,
		MinimapZoneTextButton,
		MinimapToggleButton,
		MinimapZoomIn,
		MinimapZoomOut,
		GameTimeFrame,
		SubZoneTextFrame,
		DurabilityFrame,
	}
	for _, frame in ipairs(hideAll) do
		frame:Hide()
		hooksecurefunc(frame, "Show", frame.Hide)
	end

	-- Mail Frame / 信件提示
	MiniMapMailBorder:Hide()
	MiniMapMailIcon:SetTexture(G.Mail)
	MiniMapMailIcon:SetSize(20, 20)

	-- Minimap Tracker / 追蹤
	MiniMapTracking:SetParent(Minimap)
	MiniMapTrackingButtonBorder:Hide()
	MiniMapTrackingBackground:Hide()
	MiniMapTrackingButton:SetHighlightTexture(0)
	-- 圖示固定 20px，柔邊外擴 3px；不繼承材質縮放造成的不等距偏移。
	MiniMapTrackingIcon:SetScale(1)
	MiniMapTrackingIcon:SetSize(20, 20)
	MiniMapTrackingIcon.bg = F.CreateBG(MiniMapTrackingIcon, 3, 3, 1)
	-- 原生優先顯示啟用中的追蹤法術；透明的服務圖示與未追蹤圖示不裁邊、不加方框。
	local function updateTrackingStyle()
		local isSpell = false
		for id = 1, C_Minimap.GetNumTrackingTypes() do
			local info = C_Minimap.GetTrackingInfo(id)
			if info and info.active and info.type == "spell" then
				isSpell = true
				break
			end
		end
		MiniMapTrackingIcon.bg:SetShown(isSpell)
		local crop = isSpell and .08 or 0
		MiniMapTrackingIcon:SetTexCoord(crop, 1 - crop, crop, 1 - crop)
	end
	hooksecurefunc("MinimapTracking_Update", updateTrackingStyle)
	updateTrackingStyle()

	MiniMapBattlefieldBorder:Hide()

	LFGMinimapFrame:SetParent(Minimap)
	-- 64px 動畫格含透明留白；補償後眼皮約與 20px 追蹤圖示同大，顯隱與佇列操作沿原生。
	LFGMinimapFrame:SetSize(28, 28)
	LFGMinimapFrame.eye:SetSize(36, 36)
	LFGMinimapFrameBorder:Hide()
	LFGMinimapFrame:SetHighlightTexture(0)

	-- 原生已管理團隊、英雄、公會與挑戰難度；只移位，保留事件、圖案與提示。
	for _, frame in ipairs({ MiniMapInstanceDifficulty, GuildInstanceDifficulty, MiniMapChallengeMode }) do
		frame:SetParent(Minimap)
		frame:ClearAllPoints()
		frame:SetPoint("TOP", Minimap, "TOP", 0, -20)
	end
end

local function OnMouseWheel(self, delta)
	if IsAltKeyDown() then
		local i = Minimap:GetScale()
		if delta > 0 and i < 4 then
			Minimap:SetScale(math.min(4, i+0.1))
		elseif delta < 0 and i > 0.5 then
			Minimap:SetScale(math.max(0.5, i-0.1))
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
	-- 此圖示只提供提示；點擊交給小地圖的原生動作與右鍵選單。
	Stat:SetMouseClickEnabled(false)
	Stat:SetMouseMotionEnabled(true)
	Stat:SetHitRectInsets(-5, -5, -5, 5)
	Stat:SetSize(28, 28)
	Stat:ClearAllPoints()
	Stat:SetFrameLevel(Minimap:GetFrameLevel()+2)
	Stat:SetNormalTexture(G.Report)
	Stat:SetPushedTexture(G.Report)
	Stat:SetHighlightTexture(G.Report)
	-- 放大材質以補償透明留白，保留原本的按鈕與滑鼠範圍。
	for _, texture in ipairs({ Stat:GetNormalTexture(), Stat:GetPushedTexture(), Stat:GetHighlightTexture() }) do
		texture:ClearAllPoints()
		texture:SetPoint("CENTER", Stat)
		texture:SetSize(36, 36)
	end
	Stat:SetAlpha(0)
	Stat:SetScale(1)

local function createGarrisonTooltip(self)
	if not F.GetEKMOption("CharacterIcon") then return end

	GameTooltip:SetOwner(self, "ANCHOR_BOTTOM", findAnchor("MinimapAnchor") and (Minimap:GetWidth()*.7) or -(Minimap:GetWidth()*.7), -10)
	GameTooltip:AddLine(CHARACTER_BUTTON, .6,.8, 1)

	-- Experience
	if UnitLevel("player") < GameRulesUtil.GetEffectiveMaxLevelForPlayer() then
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

	-- Reputation
	do
		local faction = C_Reputation.GetWatchedFactionData()

		if faction and faction.factionID ~= 0 then
			local standing = faction.reaction
			local min, max, cur = faction.currentReactionThreshold, faction.nextReactionThreshold, faction.currentStanding
			local reaction = GetText("FACTION_STANDING_LABEL"..standing, UnitSex("player"))
			local isCapped = (standing == MAX_REPUTATION_REACTION)
			-- MoP 的個人友情有獨立門檻與稱號；最高階沒有 nextThreshold，沿原生聲望條顯示滿條。
			local friendship = C_GossipInfo.GetFriendshipReputation(faction.factionID)
			if friendship and friendship.friendshipFactionID > 0 then
				reaction = friendship.reaction
				isCapped = (friendship.nextThreshold == nil)
				if isCapped then
					min, max, cur = 0, 1, 1
				else
					min, max, cur = friendship.reactionThreshold, friendship.nextThreshold, friendship.standing
				end
			end
			GameTooltip:AddLine(" ")
			GameTooltip:AddDoubleLine(faction.name, reaction, 0, 1, 0.5, 0, 1, 0.5)
			local total, current = max - min, cur - min
			-- 原生聲望條在已達最高階且區間為零時，以滿條呈現。
			if isCapped and total == 0 then
				total, current = 1, 1
			end
			GameTooltip:AddDoubleLine(REFORGE_CURRENT..HEADER_COLON, current.." / "..total.." ("..floor(current/total*100).."%)", 1, 1, 1, 1, 1, 1)
			if not isCapped then
				GameTooltip:AddDoubleLine(L.Next, (max-cur), 1, 1, 1, 1, 1, 1)
			end
		end
	end

	GameTooltip:Show()
end

--================================================--
-----------------    [[ Ping ]]    -----------------
--=================================================--

local function whoPing()
	local ping = CreateFrame("Frame", nil, Minimap)
	ping:SetSize(100, 20)
	ping:SetPoint("BOTTOM", Minimap, 0, 2)
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

	-- MINIMAP_PING 已改由 callback 傳入 payload，沒有舊 OnEvent 的 event 參數。
	ping:RegisterEventCallback("MINIMAP_PING", function(_, unit)
		local class = select(2, UnitClass(unit))
		local name = GetUnitName(unit)
		local classcolor = 	(CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[class]

		anim:Stop()
		ping.text:SetText(name)
		ping.text:SetTextColor(classcolor.r, classcolor.g, classcolor.b)
		anim:Play()
	end)
end

--=================================================--
-----------------    [[ Clock ]]    -----------------
--=================================================--

local function HoverClock()
	if not F.GetEKMOption("HoverClock") then return end

	local Clock = CreateFrame("Frame", nil, Minimap)
	Clock:SetSize(80, 20)
	Clock.Text = F.CreateFS(Clock, "", "CENTER")
	Clock:ClearAllPoints()
	Clock:SetPoint("TOP", Minimap, 0, 0)
	Clock.Text:SetText("")
	Clock:SetAlpha(0)

	Minimap:HookScript("OnEnter", function()
		local time = GameTime_GetTime(true)
		Clock.Text:SetText(time)
		UIFrameFadeIn(Clock, .2, 0, 1)
	end)
	Minimap:HookScript("OnLeave", function()
		UIFrameFadeOut(Clock, .8, 1, 0)
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
		UIFrameFadeIn(Stat, .4, 0, 1)
	end)
	Stat:SetScript("OnLeave", function()
		UIFrameFadeOut(Stat, .8, 1, 0)
		GameTooltip:Hide()
	end)

--=================================================--
-----------------    [[ Load ]]    -----------------
--=================================================--

local function updateIconPos()
	MiniMapMailFrame:ClearAllPoints()
	MiniMapMailIcon:ClearAllPoints()
	MiniMapBattlefieldFrame:ClearAllPoints()
	MiniMapTracking:ClearAllPoints()
	MiniMapTrackingIcon:ClearAllPoints()
	Stat:ClearAllPoints()
	LFGMinimapFrame:ClearAllPoints()

	if findAnchor("MinimapAnchor") then
		MiniMapMailFrame:SetPoint("BOTTOMLEFT", Minimap, 0, 0)
		MiniMapMailIcon:SetPoint("BOTTOMLEFT", MiniMapMailFrame, "BOTTOMLEFT", 4, 4)
		Stat:SetPoint("BOTTOMRIGHT", Minimap, 0, 0)
		-- Titan 沿原生分開顯示戰場按鈕；MoP 的戰場佇列由原生眼睛統合。
		MiniMapBattlefieldFrame:SetPoint("TOPRIGHT", Minimap, "TOPRIGHT", 0, -36)
		MiniMapTracking:SetPoint("TOPLEFT", Minimap, 0, 0)
		MiniMapTrackingIcon:SetPoint("TOPLEFT", MiniMapTracking, "TOPLEFT", 4, -4)
		LFGMinimapFrame:SetPoint("TOPRIGHT", Minimap, "TOPRIGHT", 0, 0)
	else
		MiniMapMailFrame:SetPoint("BOTTOMRIGHT", Minimap, 0, 0)
		MiniMapMailIcon:SetPoint("BOTTOMRIGHT", MiniMapMailFrame, "BOTTOMRIGHT", -4, 4)
		Stat:SetPoint("BOTTOMLEFT", Minimap, 0, 0)
		MiniMapBattlefieldFrame:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 0, -36)
		MiniMapTracking:SetPoint("TOPRIGHT", Minimap, 0, 0)
		MiniMapTrackingIcon:SetPoint("TOPRIGHT", MiniMapTracking, "TOPRIGHT", -4, -4)
		LFGMinimapFrame:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 0, 0)
	end
end

F.ResetM = function()
	updateMinimapPos()
	updateMinimapSize()
	updateIconPos()
end

local function OnEvent(self, event, addon)
	if event == "ADDON_LOADED" then
		if addon ~= "Blizzard_TimeManager" then return end
		TimeManagerClockButton:Hide()
		TimeManagerClockButton:HookScript("OnShow", TimeManagerClockButton.Hide)
		self:UnregisterEvent("ADDON_LOADED")
	elseif event == "PLAYER_LOGIN" then
		-- TimeManager 可能先於本插件載入，兩種載入順序都隱藏原生時鐘。
		if TimeManagerClockButton then
			TimeManagerClockButton:Hide()
			TimeManagerClockButton:HookScript("OnShow", TimeManagerClockButton.Hide)
		else
			self:RegisterEvent("ADDON_LOADED")
		end
		-- make sure MBB dont take my icon 益rz
		if MBB_Ignore then
			tinsert(MBB_Ignore, "EKMinimapTooltipButton")
		end

		whoPing()
		setMinimap()
		updateIconPos()
		HoverClock()
		self:UnregisterEvent("PLAYER_LOGIN")
	end
end

local frame = CreateFrame("FRAME")
	frame:RegisterEvent("PLAYER_LOGIN")
	frame:SetScript("OnEvent", OnEvent)
