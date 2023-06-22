local addon, ns = ...
local C, F, G, L = unpack(ns)

local WatchFrame, gsub = WatchFrame, string.gsub
local GetNumQuestWatches = GetNumQuestWatches


--================================================--
-----------------    [[ Core ]]    -----------------
--================================================--

local ObjectiveFrameHolder = CreateFrame("Frame", "WatchFrameHoler", UIParent)
	ObjectiveFrameHolder:SetSize(160, G.fontSize + 4)

local function updateWatchFramePos()
	ObjectiveFrameHolder:ClearAllPoints()
	ObjectiveFrameHolder:SetPoint(EKMinimapDB["QuestWatchAnchor"], UIParent, EKMinimapDB["QuestWatchX"], EKMinimapDB["QuestWatchY"])
	ObjectiveFrameHolder:SetMovable(true)
	ObjectiveFrameHolder:SetClampedToScreen(true)
	
	WatchFrame:SetParent(ObjectiveFrameHolder)
	WatchFrame:ClearAllPoints()
	WatchFrame:SetPoint("TOPRIGHT", ObjectiveFrameHolder)
end

local function setWatchFrame()
	if not EKMinimapDB["QuestWatchStyle"] then return end
	
	updateWatchFramePos()
	WatchFrame:SetClampedToScreen(true)
	WatchFrame:SetMovable(true)
	WatchFrame:SetUserPlaced(true)
	WatchFrame:SetHeight(GetScreenHeight()*.5)
	hooksecurefunc(WatchFrame, "SetPoint", function(self, _, parent)
		if parent ~= ObjectiveFrameHolder then
			self:ClearAllPoints()
			self:SetPoint("TOPRIGHT", ObjectiveFrameHolder)
		end
	end)
	
	-- Skin Title
	local Title = WatchFrameTitle
	Title:SetFont(G.font, G.fontSize+2, G.fontFlag)
	Title:SetShadowOffset(0, 0)
	Title:SetShadowColor(0, 0, 0, 1)
	local Header = WatchFrameHeader 
	Header:ClearAllPoints()
	Header:SetPoint("RIGHT", WatchFrameCollapseExpandButton, "LEFT", -8, 0)
	--Header.bar = F.CreateBG(Header, 3, 3, .3)
	
	-- Skin Icon
	local function reskinQuestIcon(button)
		if not button then return end
		if not button.SetNormalTexture then return end

		if not button.styled then
			button:SetSize(24, 24)
			button:SetNormalTexture("")
			button:SetPushedTexture("")
			button:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
			local icon = _G[button:GetName().."IconTexture"]
			if icon then
				button.bg = F.CreateBG(icon, 3, 3, 0)
				icon:SetTexCoord(.08, .92, .08, .92)
			end

			button.styled = true
		end

		if button.bg then
			button.bg:SetFrameLevel(0)
		end
	end
	
	hooksecurefunc("WatchFrameItem_UpdateCooldown", function(button)
		reskinQuestIcon(button)
	end)
	
	-- Skin Collapse
	local Button = WatchFrameCollapseExpandButton
	Button:SetNormalTexture("")
	Button:GetNormalTexture():SetAlpha(0)
	Button:SetHighlightTexture("")
	Button:GetHighlightTexture():SetAlpha(0)
	Button:SetPushedTexture("")
	Button:GetPushedTexture():SetAlpha(0)
	
	Button.bg = F.CreateBG(WatchFrameCollapseExpandButton, 3, 3, .5)
	Button.text = F.CreateFS(Button, "-", "CENTER", "CENTER", 0, 0)
	Button.text:SetFont(G.font, G.fontSize, G.fontFlag)
	Button.text:SetTextColor(1, .8, 0)
	
	local function updateMinimizeButton(self)
		self.collapse = not self.collapse
		if self.collapse then
			Button.text:SetText("+")
		else
			Button.text:SetText("-")
		end
	end

	hooksecurefunc("WatchFrame_Collapse", function(self)
		updateMinimizeButton(self)
	end)
	hooksecurefunc("WatchFrame_Expand", function(self)
		updateMinimizeButton(self)
	end)
	
	Button:SetScript("OnEnter", function(self)
		Button.bg:SetBackdropBorderColor(1, .8, 0, 1)
	end)
	
	Button:SetScript("OnLeave", function(self)
		Button.bg:SetBackdropBorderColor(0, 0, 0, 1)
	end)
	
	-- Star
	if EKMinimapDB["QuestWatchStar"] then
		_G.QUEST_DASH = "★"
	end

	-- Outline
	--[[local nextline = 1
	hooksecurefunc("WatchFrame_Update", function()
		--SetFontObject(SystemFont_Shadow_Med1_Outline)
		
		for i = nextline, 50 do
			local line = _G["WatchFrameLines."..i]
			if line then
				--if not line then break end
				line.text:SetFont(G.font, G.fontSize, G.fontFlag)
				line.text:SetShadowOffset(0, 0)
				
				line.dash:SetFont(G.font, G.fontSize, G.fontFlag)
				line.dash:SetShadowOffset(0, 0)
			else
				nexline = i 
				break
			end
		end
	end)]]--
	
	
	-- Block text outline
	local function ReskinFont(font, size)
		local oldSize = select(2, font:GetFont())
		size = size or oldSize
		local fontSize = G.fontSize
		font:SetFont(G.font, G.fontSize, G.fontFlag)
		font:SetShadowColor(0, 0, 0, 0)
	end
	--if EKMinimapDB["QuestOutline"] then
		ReskinFont(SystemFont_Shadow_Med1)
	--end
	
	-- Drag tooltip
	local function WatchFrame_Tooltip(self)
		if GetNumQuestWatches() == 0 then return end
		
		GameTooltip:SetOwner(self, "ANCHOR_TOP")
		GameTooltip:AddDoubleLine(DRAG_MODEL, "Alt + |TInterface\\TUTORIALFRAME\\UI-TUTORIAL-FRAME:13:11:0:-1:512:512:12:66:333:411|t", 0, 1, 0.5, 1, 1, 1)
		GameTooltip:Show()
	end
	
	local function WatchFrame_Drag(self)
		if GetNumQuestWatches() == 0 then return end
		
		if IsAltKeyDown() then
			local frame = self:GetParent()
			frame:StartMoving()
		end
	end
	
	-- Drag move
	local WatchFrameMove = CreateFrame("FRAME", "WatchFramedrag", ObjectiveFrameHolder)
		-- Create frame for click
		WatchFrameMove:SetSize(160, G.fontSize + 2)
		WatchFrameMove:SetPoint("TOP", ObjectiveFrameHolder, 0, G.fontSize)
		WatchFrameMove:SetFrameStrata("BACKGROUND")
		WatchFrameMove:EnableMouse(GetNumQuestWatches() > 0)
		--WatchFrameMove:Hide()
		--WatchFrameMove:SetShown(numWatches > 0)
		-- Make it drag-able
		WatchFrameMove:RegisterForDrag("RightButton")
		WatchFrameMove:SetHitRectInsets(-5, -5, -5, -5)
		-- Alt+right click to drag frame
		WatchFrameMove:SetScript("OnDragStart", function(self)
			WatchFrame_Drag(self)
		end)
		WatchFrameMove:SetScript("OnDragStop", function(self)
			local frame = self:GetParent()
			frame:StopMovingOrSizing()
		end)
		-- Show tooltip for drag
		WatchFrameMove:SetScript("OnEnter", function(self)
			WatchFrame_Tooltip(self)
		end)
		WatchFrameMove:SetScript("OnLeave", function(self)
			GameTooltip:Hide()
		end)
end

--============================================================--
-----------------    [[ ModernQuestWatch ]]    -----------------
--============================================================--

-- Reset / 重置
F.ResetO = function()
	updateWatchFramePos()
end

local function OnEvent()
	setWatchFrame()
end

local frame = CreateFrame("FRAME")
	frame:RegisterEvent("PLAYER_LOGIN")
	frame:SetScript("OnEvent", OnEvent)