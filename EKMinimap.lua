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

local function findAnchor(value)
	local anchor = EKMinimapDB[value]
	local myAnchor = sub(anchor, -4)				-- get minimap anchor left or rignt
	local iconAnchor = not not (myAnchor == "LEFT")	-- hope教我的語法糖
	
	return iconAnchor
end

--================================================--
-----------------    [[ Core ]]    -----------------
--================================================--

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
	
	MinimapCluster:EnableMouse(false)
	Minimap.bg = F.CreateBG(Minimap, 5, 5, 1)

	-- Hide all frames / 隱藏各種
	local hideAll = {
		"MinimapBorder",			-- 大圈
		"MinimapBorderTop",
		"MinimapNorthTag",			-- 指北針
		"MiniMapWorldMapButton",	-- 世界地圖
		"MinimapZoneTextButton",	-- 區域名字
		"MinimapToggleButton",		-- 選單
		"MinimapZoomIn",			-- 放大
		"MinimapZoomOut",			-- 縮小
		"GameTimeFrame",			-- 時間
		"SubZoneTextFrame",
		"DurabilityFrame",			-- 裝備耐久
	}
	for i, v in pairs(hideAll) do
		getglobal(v).Show = F.Dummy
		getglobal(v):Hide()
	end
	
	-- Mail Frame / 信件提示
	MiniMapMailBorder:Hide()
	MiniMapMailIcon:SetTexture(G.Mail)

	-- Minimap Tracker / 追蹤
	MiniMapTrackingBorder:Hide()
	MiniMapTrackingIcon:SetScale(0.8)
	MiniMapTrackingIcon:SetTexCoord(.08, .92, .08, .92)
	MiniMapTrackingIcon.bg = F.CreateBG(MiniMapTrackingIcon, 3, 3, 1)
	
	MiniMapBattlefieldBorder:Hide()
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
	if UnitLevel("player") < MAX_PLAYER_LEVEL then
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
				GameTooltip:AddDoubleLine(L.Next, (max-cur), 1, 1, 1, 1, 1, 1)
			end
		end
	end
	
	GameTooltip:Show()
end

--======================================================--
-----------------    [[ Difficulty ]]    -----------------
--======================================================--

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
	
	Stat:SetScript("OnEnter", function(self)
		createGarrisonTooltip(self)
		-- fade in
		securecall(UIFrameFadeIn, Stat, .4, 0, 1)
	end)
	Stat:SetScript("OnLeave", function()
		securecall(UIFrameFadeOut, Stat, .8, 1, 0)
		GameTooltip:Hide()
	end)

--=================================================--
-----------------    [[ Load ]]    -----------------
--=================================================--

local function updateIconPos()
	MiniMapMailFrame:ClearAllPoints()
	MiniMapBattlefieldFrame:ClearAllPoints()
	MiniMapTrackingFrame:ClearAllPoints()
	Stat:ClearAllPoints()

	if findAnchor("MinimapAnchor") then
		MiniMapMailFrame:SetPoint("BOTTOMLEFT", Minimap, 0, 0)
		Stat:SetPoint("BOTTOMRIGHT", Minimap, 1, 2)
		MiniMapBattlefieldFrame:SetPoint("TOPRIGHT", 0, 0)
		MiniMapTrackingFrame:SetPoint("TOPLEFT", Minimap, 0, 0)
	else
		MiniMapMailFrame:SetPoint("BOTTOMRIGHT", Minimap, 0, 0)
		Stat:SetPoint("BOTTOMLEFT", Minimap, -1, 2)
		MiniMapBattlefieldFrame:SetPoint("TOPLEFT", 0, 0)
		MiniMapTrackingFrame:SetPoint("TOPRIGHT", Minimap, 0, 0)
	end
end

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
		-- make sure MBB dont take my icon 益rz
		tinsert(MBB_Ignore, "EKMinimapTooltipButton")
		
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