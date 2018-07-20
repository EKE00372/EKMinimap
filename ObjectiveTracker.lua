-- [[ Credits ]] --

-- [[ Config ]] --

local height = 600
local fontsize = 18
local ClassColor = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[select(2,UnitClass("player"))] 

-- [[ Core ]] --

if not IsAddOnLoaded("Blizzard_ObjectiveTracker") then
	LoadAddOn("Blizzard_ObjectiveTracker")
end

-- Setting
local OTF = ObjectiveTrackerFrame
OTF:SetClampedToScreen(true)
OTF:ClearAllPoints()
OTF:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -100, -170)
OTF:SetHeight(height)
OTF:SetMovable(true)
OTF:SetUserPlaced(true)

-- Make a Frame for Drag / 創建一個供移動的框架
local OTFMove = CreateFrame("FRAME", nil, OTF)
OTFMove:SetHeight(20)
OTFMove:SetPoint("TOPLEFT", OTF)
OTFMove:SetPoint("TOPRIGHT", OTF)
--OTFMove:SetFrameStrata("HIGH")
OTFMove:EnableMouse(true)
OTFMove:RegisterForDrag("RightButton")
OTFMove:SetHitRectInsets(-5, -5, -5, -5)

OTFMove:SetScript("OnDragStart", function(self, button)
	if IsAltKeyDown() then
		local frame = self:GetParent()
		frame:StartMoving()
	end
end)

OTFMove:SetScript("OnDragStop", function(self, button)
	local frame = self:GetParent()
	frame:StopMovingOrSizing()
end)

-- Reset place / 重置位置
SlashCmdList["RESETQUEST"] = function() 
	OTF:SetUserPlaced(false)
	ReloadUI()
end
SLASH_RESETQUEST1 = "/resetobjective"
SLASH_RESETQUEST2 = "/ro"

-- [[ Collapse Icon ]] --

-- creat icon  / 創建按鈕
local Minimize = OTF.HeaderMenu.MinimizeButton
Minimize:SetSize(16, 20)
Minimize:SetNormalTexture("")
Minimize:SetPushedTexture("")

-- Close  / 關閉按鈕
Minimize.minus = Minimize:CreateFontString(nil, "OVERLAY")
Minimize.minus:SetFont(STANDARD_TEXT_FONT, fontsize, "OUTLINE")
Minimize.minus:SetText(">")
Minimize.minus:SetPoint("CENTER")
Minimize.minus:SetTextColor(1, 1, 1)
Minimize.minus:SetShadowOffset(0, 0)
Minimize.minus:SetShadowColor(0, 0, 0, 1)

-- Open / 開啟按鈕
Minimize.plus = Minimize:CreateFontString(nil, "OVERLAY")
Minimize.plus:SetFont(STANDARD_TEXT_FONT, fontsize, "OUTLINE")
Minimize.plus:SetText("<")
Minimize.plus:SetPoint("CENTER")
Minimize.plus:SetTextColor(1, 1, 1)
Minimize.plus:SetShadowOffset(0, 0)
Minimize.plus:SetShadowColor(0, 0, 0, 1)
Minimize.plus:Hide()

-- Close Title / 收起後的標題
local Title = OTF.HeaderMenu.Title
Title:SetFont(STANDARD_TEXT_FONT, fontsize, "OUTLINE")
Title:SetShadowOffset(0, 0)
Title:SetShadowColor(0, 0, 0, 1)
Title:ClearAllPoints()
Title:SetPoint("RIGHT", Minimize, "LEFT", 0, 0)

-- Let It Work / 使其工作
Minimize:HookScript("OnEnter", function()
	Minimize.minus:SetTextColor(.7, .5, 0)
	Minimize.plus:SetTextColor(.7, .5, 0)
end)
Minimize:HookScript("OnLeave", function()
	Minimize.minus:SetTextColor(1, 1, 1)
	Minimize.plus:SetTextColor(1, 1, 1)
end)
hooksecurefunc("ObjectiveTracker_Collapse", function()
	Minimize.plus:Show()
	Minimize.minus:Hide()
end)
hooksecurefunc("ObjectiveTracker_Expand",  function()
	Minimize.plus:Hide()
	Minimize.minus:Show()
end)

-- [[ Misc ]] --

-- Quick Click: Alt to Share, Ctrl to Abandon / 快速按鍵：alt分享ctrl放棄
local function QuestHook(id)
local questLogIndex = GetQuestLogIndexByID(id)
	if IsControlKeyDown() and CanAbandonQuest(id) then
		QuestMapQuestOptions_AbandonQuest(id)
	elseif IsAltKeyDown() and GetQuestLogPushable(questLogIndex) then
		QuestMapQuestOptions_ShareQuest(id)
	end
end
hooksecurefunc(QUEST_TRACKER_MODULE, "OnBlockHeaderClick", function(self, block)
	QuestHook(block.id)
end)
hooksecurefunc("QuestMapLogTitleButton_OnClick", function(self)
	QuestHook(self.questID)
end)

-- [[ Skin ]] --

-- 大標題
if IsAddOnLoaded("Blizzard_ObjectiveTracker") then
	hooksecurefunc("ObjectiveTracker_Update", function(reason, id)
	   if OTF.MODULES then
			for i = 1, #OTF.MODULES do
				OTF.MODULES[i].Header.Background:SetAtlas(nil)
				OTF.MODULES[i].Header.Background:Hide()
				OTF.MODULES[i].Header.Text:SetFont(STANDARD_TEXT_FONT, fontsize, "OUTLINE")
				OTF.MODULES[i].Header.Text:SetShadowOffset(0, 0)
				OTF.MODULES[i].Header.Text:SetWordWrap(true)
				OTF.MODULES[i].Header.Text:ClearAllPoints()
				OTF.MODULES[i].Header.Text:SetPoint("RIGHT", OTF.MODULES[i].Header, 0, 0)
				OTF.MODULES[i].Header.Text:SetJustifyH("RIGHT")
				OTF.MODULES[i].Header:SetWidth(OTF:GetWidth()-20)
			end
		end
	end)
end

-- 任務標題
hooksecurefunc(QUEST_TRACKER_MODULE, "SetBlockHeader", function(_, block)
	block.HeaderText:SetFont(STANDARD_TEXT_FONT, fontsize-2, "OUTLINE")
	block.HeaderText:SetShadowColor(0, 0, 0, 1)
	block.HeaderText:SetShadowOffset(0, 0)
	block.HeaderText:SetTextColor(ClassColor.r, ClassColor.g, ClassColor.b)
	block.HeaderText:SetJustifyH("LEFT")
	block.HeaderText:SetWidth(OTF:GetWidth()-20)
	block.HeaderText:SetHeight(15)
	
	local heightcheck = block.HeaderText:GetNumLines()
	if heightcheck == 2 then
		local height = block:GetHeight()
		block:SetHeight(height + 2)
	end
end)
local function hoverquest(_, block)
	block.HeaderText:SetTextColor(ClassColor.r, ClassColor.g, ClassColor.b)
end
hooksecurefunc(QUEST_TRACKER_MODULE, "OnBlockHeaderEnter", hoverquest)
hooksecurefunc(QUEST_TRACKER_MODULE, "OnBlockHeaderLeave", hoverquest)

-- 成就標題
hooksecurefunc(ACHIEVEMENT_TRACKER_MODULE, "SetBlockHeader", function(_, block)
	local trackedAchievements = {GetTrackedAchievements()}

	for i = 1, #trackedAchievements do
		local achieveID = trackedAchievements[i]
		local _, achievementName, _, completed, _, _, _, description, _, icon, _, _, wasEarnedByMe = GetAchievementInfo(achieveID)

		if not wasEarnedByMe then
			block.HeaderText:SetFont(STANDARD_TEXT_FONT, fontsize-2, "OUTLINE")
			block.HeaderText:SetShadowColor(0, 0, 0, 1)
			block.HeaderText:SetShadowOffset(0, 0)
			block.HeaderText:SetTextColor(ClassColor.r, ClassColor.g, ClassColor.b)
			block.HeaderText:SetJustifyH("LEFT")
			block.HeaderText:SetWidth(OTF:GetWidth()-20)
		end
	end
end)
local function hoverachieve(_, block)
	block.HeaderText:SetTextColor(ClassColor.r, ClassColor.g, ClassColor.b)
end
hooksecurefunc(ACHIEVEMENT_TRACKER_MODULE, "OnBlockHeaderEnter", hoverachieve)
hooksecurefunc(ACHIEVEMENT_TRACKER_MODULE, "OnBlockHeaderLeave", hoverachieve)

-- 地城標題
ScenarioStageBlock:HookScript("OnShow", function()
	if not ScenarioStageBlock.skinned then
		ScenarioStageBlock.NormalBG:SetAlpha(0)
		ScenarioStageBlock.FinalBG:SetAlpha(0)
		ScenarioStageBlock.GlowTexture:SetTexture(nil)

		ScenarioStageBlock.Stage:SetFont(STANDARD_TEXT_FONT, fontsize-2, "OUTLINE")
		ScenarioStageBlock.Stage:SetTextColor(1, 1, 1)
		ScenarioStageBlock.Stage:SetShadowOffset(0, 0)

		ScenarioStageBlock.Name:SetFont(STANDARD_TEXT_FONT, fontsize-2, "OUTLINE")
		ScenarioStageBlock.Name:SetShadowOffset(0, 0)

		ScenarioStageBlock.CompleteLabel:SetFont(STANDARD_TEXT_FONT, fontsize-2, "OUTLINE")
		ScenarioStageBlock.CompleteLabel:SetTextColor(1, 1, 1)
		ScenarioStageBlock.CompleteLabel:SetShadowOffset(0, 0)
		ScenarioStageBlock.skinned = true
	end
end)

-- 內文
hooksecurefunc(DEFAULT_OBJECTIVE_TRACKER_MODULE, "AddObjective", function(self, block, objectiveKey, _, lineType)
	local line = self:GetLine(block, objectiveKey, lineType)
	line.Text:SetWidth(OTF:GetWidth()-20)
	
	line.Text:SetFont(STANDARD_TEXT_FONT, fontsize-4, "OUTLINE")
	line.Text:SetShadowOffset(0, 0)
	line.Text:SetShadowColor(0, 0, 0, 1)
		
	--[[if  line.FadeOutAnim then   -- ?
		local a = line.FadeOutAnim:GetAnimations()
		a:SetStartDelay(0)
	end]]--
	
	if line.Dash and line.Dash:IsShown() then
		line.Dash:SetFont(STANDARD_TEXT_FONT, fontsize-4, "OUTLINE")
		line.Dash:SetText("-")
	end
end)