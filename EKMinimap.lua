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

--================================================--
-----------------    [[ Core ]]    -----------------
--================================================--

local function updateMinimapPos()
	Minimap:ClearAllPoints()
	Minimap:SetPoint(EKMinimapDB["MinimapAnchor"], UIParent, EKMinimapDB["MinimapX"], EKMinimapDB["MinimapY"])
end

local function updateMinimapSize()
	-- default size is 140
	-- We use SetScale() instead SetSize() because there's an issue happened on load order and addon icons.
	-- addon minimap icon may put themself to strange place because this addon load after then icons been created.
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
		"MiniMapTracking",			-- 追蹤選單
		"MinimapZoomIn",			-- 放大
		"MinimapZoomOut",			-- 縮小
		"GameTimeFrame",			-- 時間
		"SubZoneTextFrame",
		"DurabilityFrame",			-- 裝備耐久
		"MiniMapInstanceDifficulty",
	}
	for i, v in pairs(hideAll) do
		getglobal(v).Show = F.Dummy
		getglobal(v):Hide()
	end
	
	-- Mail Icon
	MiniMapMailBorder:Hide()
	MiniMapMailIcon:SetTexture(G.Mail)
	-- BG Icon
	MiniMapBattlefieldBorder:Hide()
	-- LFG Icon
	MiniMapLFGFrameBorder:Hide()
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
	Diff.Text = F.CreateFS(Diff, "", "CENTER")

local function styleDifficulty(self)
	-- Difficulty Text / 難度文字
	local DiffText = self.Text

	local inInstance, instanceType = IsInInstance()
	local difficulty = select(3, GetInstanceInfo())
	local num = select(9, GetInstanceInfo())
	
	if instanceType == "party" or instanceType == "raid" or instanceType == "scenario" then
		if difficulty == 1 then
			DiffText:SetText("5N")
		elseif difficulty == 2 then
			DiffText:SetText("5H")
		elseif difficulty == 3 then
			DiffText:SetText("10")
		elseif difficulty == 4 then
			DiffText:SetText("25")
		elseif instanceType == "pvp" or instanceType == "arena" then
			DiffText:SetText("PVP")
		end
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
--================================================--

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


--=================================================--
-----------------    [[ Clock ]]    -----------------
--=================================================--

local function HoverClock()
	if not EKMinimapDB["HoverClock"] then return end

	local Clock = CreateFrame("Frame", nil, Minimap)
	Clock:SetSize(80, 20)
	Clock.Text = F.CreateFS(Clock, "", "CENTER")
	Clock:ClearAllPoints()
	Clock:SetPoint("TOP", Minimap, 0, 0)
	Clock.Text:SetText("")
	Clock:SetAlpha(0)
	
	-- Alt+right click to drag frame
	Minimap:SetScript("OnEnter", function()
		local hour, minute
		if GetCVarBool("timeMgrUseLocalTime") then
			hour, minute = tonumber(date("%H")), tonumber(date("%M"))
		else
			hour, minute = GetGameTime()
		end
		
		Clock.Text:SetText(updateTimerFormat(hour, minute))
		securecall(UIFrameFadeIn, Clock, .2, 0, 1)
	end)
	Minimap:SetScript("OnLeave", function()
		securecall(UIFrameFadeOut, Clock, .8, 1, 0)
	end)
end

--==================================================--
-----------------    [[ Script ]]    -----------------
--==================================================--
	
	-- [[ Minimap ]] --
	
	Minimap:SetScript("OnMouseWheel", OnMouseWheel)
	Minimap:SetScript("OnDragStart", function(self)
		if IsAltKeyDown() then
			self:StartMoving()
		end
	end)
	Minimap:SetScript("OnDragStop", function(self)
		self:StopMovingOrSizing()
	end)

	-- [[ Difficulty ]] --
	
	Diff:RegisterEvent("PLAYER_ENTERING_WORLD")
	Diff:RegisterEvent("PLAYER_DIFFICULTY_CHANGED")
	Diff:RegisterEvent("INSTANCE_GROUP_SIZE_CHANGED")
	Diff:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	Diff:SetScript("OnEvent", styleDifficulty)
	
	--HookScript call bindingType should be 2
	--[[MiniMapLFGFrame:HookScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_TOP")
	end)]]--

	--[[hooksecurefunc("MiniMapLFGFrame_OnEnter", function(self)--EyeTemplate_OnUpdate?
		GameTooltip:SetOwner(self, "ANCHOR_TOP");
	end)]]--
	
--=================================================--
-----------------    [[ Load ]]    -----------------
--=================================================--

local function updateIconPos()
	MiniMapMailFrame:ClearAllPoints()
	MiniMapBattlefieldFrame:ClearAllPoints()
	MiniMapLFGFrame:ClearAllPoints()
	Diff:ClearAllPoints()

	if findAnchor("MinimapAnchor") then
		MiniMapMailFrame:SetPoint("BOTTOMLEFT", Minimap, 0, 0)
		MiniMapBattlefieldFrame:SetPoint("TOPRIGHT", Minimap, 0, 0)
		MiniMapLFGFrame:SetPoint("BOTTOMRIGHT", Minimap, 0, 0)
		Diff:SetPoint("TOPLEFT", Minimap,  -5, 5)
	else
		MiniMapMailFrame:SetPoint("BOTTOMRIGHT", Minimap, 0, 0)
		MiniMapBattlefieldFrame:SetPoint("TOPLEFT", Minimap, 0, 0)
		MiniMapLFGFrame:SetPoint("BOTTOMLEFT", Minimap, 0, 0)
		Diff:SetPoint("TOPRIGHT", Minimap,  5, 5)
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
		whoPing()
		setMinimap()
		updateIconPos()
		HoverClock()
	else
		return
	end
end

local frame = CreateFrame("FRAME")
	frame:RegisterEvent("PLAYER_LOGIN")
	frame:RegisterEvent("ADDON_LOADED")
	frame:SetScript("OnEvent", OnEvent)