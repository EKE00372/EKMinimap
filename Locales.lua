local addon, ns = ...
local C, F, G, L = unpack(ns)
local GetLocale = GetLocale

--===================================================--
-----------------    [[ Locales ]]    -----------------
--===================================================--

if GetLocale() == "zhTW" then

	L.ToggleConfig = "開啟設定選項"
	
	L.ClickMenuOpt = "啟用點擊選單"
	L.TrackingOpt = "完整追蹤選單"
	L.IconOpt = "角色資訊提示"
	L.HoverClockOpt = "指向顯示時間"
	L.QueueOpt = "移動隊列按鈕"
	
	L.SizeOpt = "縮放"
	L.AnchorOpt = "錨點"
	L.XOpt = "X 座標"
	L.YOpt = "Y 座標"
	
	L.ObjectiveOpt = "追蹤框"
	L.ObjectiveStarOpt = "使用 ★ 標記追蹤項目"
	L.ObjectiveStyleOpt = "啟用追蹤框美化"
	
	L.Calendar = SLASH_CALENDAR2:gsub("/(.*)","%1")
	L.Left = "左"
	L.Right = "右"
	L.BFAReport = "任務指揮桌"
	
	L.Apply = "更改後點擊「"..APPLY.."」立即重載生效。"
	L.posApply = APPLY..L.SizeOpt.."座標"
	
	L.tempTip1 = "Alt 功能是臨時性功能，提供給需要追蹤某些特定目標的偶發情況，所以它們的變動不會被儲存。"
	L.tempTip2 = "所有 Alt 功能造成的更改會在重載介面或點擊「"..L.posApply.."」後復原。"
	L.tempTip3 = "設定時，單純更改尺寸和座標而不更改選項，可以點擊「"..L.posApply.."」來直接套用而不需重載。"
	L.dragInfo = "Alt+右鍵：臨時性拖動框體"
	L.scrollInfo = "Alt+滾輪：臨時縮放小地圖"
	
elseif GetLocale() == "zhCN" then

	L.ToggleConfig = "开启设置选项"
	
	L.ClickMenuOpt = "启用点击菜单"
	L.TrackingOpt = "完整追踪清单"

	L.SizeOpt = "缩放"
	L.AnchorOpt = "锚点"
	L.XOpt = "X 座标"
	L.YOpt = "Y 座标"
	L.ObjectiveOpt = "追踪框"
	L.ObjectiveStarOpt = "使用 ★ 标记追踪项目"
	L.ObjectiveStyleOpt = "启用追踪框美化"
	L.IconOpt = "角色信息提示"
	L.HoverClockOpt = "指向显示时间"
	L.QueueOpt = "移动队列按钮"
	
	L.Calendar = "行事历"
	L.Left = "左"
	L.Right = "右"
	L.BFAReport = "任务安官桌"

	L.Apply = "更改后点击＂"..APPLY.."＂立即重载生效。"
	L.posApply = APPLY..L.SizeOpt.."座标"
	
	L.tempTip1 = "Alt 功能是临时性功能，提供给需要追踪某些特定目标的偶发情况，所以它们的变动不会被保存。"
	L.tempTip2 = "所有 Alt 功能造成的更改会在重载界面或点击＂"..L.posApply.."＂后复原。"
	L.tempTip3 = "设置时，单纯更改尺寸和座标而不更改选项，可以点击＂"..L.posApply.."＂来直接套用而不需重载。"
	L.dragInfo = "Alt+右键临时性拖动框体"
	L.scrollInfo = "Alt+滚轮临时性缩放小地图"
	
else
	
	L.ToggleConfig = "EkMinimap Options"

	L.ClickMenuOpt = "Enable click menu"
	L.TrackingOpt = "Full tracking list"
	L.IconOpt = "Character icon tooltip"
	L.HoverClockOpt = "Show hover clock"
	L.QueueOpt = "QueueStatus on Minimap"
	
	L.SizeOpt = "Scale"
	L.AnchorOpt = "Anchor"
	L.XOpt = "X"
	L.YOpt = "Y"
	L.ObjectiveOpt = "Objective tracker"
	L.ObjectiveStarOpt = "Mark object as ★ star"
	L.ObjectiveStyleOpt = "Enable tracker style"

	L.Calendar = SLASH_CALENDAR1:gsub("/(.*)","%1")
	L.Left = "Left"
	L.Right = "Right"
	L.BFAReport = "BFA Report"

	L.Apply = "Click "..APPLY.." to active changes."
	L.posApply = APPLY.." Size and Pos"
	
	L.tempTip1 = "Alt-function is a temporary function, for people wanna track something recently, they will not be saved to settgins."
	L.tempTip2 = 'Any scale and position change caused by alt-function will reset after you reload or click "'..L.posApply..'" button.'
	L.tempTip3 = 'If wanna config position and scale only (did not change check box), you can directly click"'..L.posApply..'" to apply them	without reload.'
	L.dragInfo = "Alt-right click drag frame"
	L.scrollInfo = "Alt-scroll scale minimap"
	
end