local addon, ns = ...
local C, F, G, L = unpack(ns)
local GetLocale = GetLocale

--===================================================--
-----------------    [[ Locales ]]    -----------------
--===================================================--

if GetLocale() == "zhTW" then

	L.QuestWatchOpt = "追蹤框"
	L.SizeOpt = "縮放"
	L.AlphaOpt = "淡出透明度"
	L.AnchorOpt = "錨點"
	L.Next = "下一級："
	L.Calendar = SLASH_CALENDAR2:gsub("/(.*)","%1")
	
	L.ClickMenuOpt = "啟用點擊選單"
	L.IconOpt = "角色資訊提示"
	
	L.QuestWatchStyleOpt = "啟用追蹤框美化"
	L.QuestWatchStarOpt = "使用 ★ 標記追蹤項目"
	L.QuestWatchClickOpt = "使任務標題可點擊"

	L.WorldMapStyleOpt = "啟用世界地圖微調"
	L.fadeOpt = "移動中淡出"

	L.Apply = "更改後點擊「"..APPLY.."」立即重載生效。"
	L.posApply = APPLY..L.SizeOpt.."和座標"

	L.WMFTip = "世界地圖模組會在你同時啟用 Leatrix Maps 時自動禁用。"
	L.tempTip1 = "Alt 功能是臨時性功能，提供給需要追蹤某些特定目標的偶發情況，所以它們的變動不會被儲存。"
	L.tempTip2 = "所有 Alt 功能造成的更改會在重載介面或點擊「"..L.posApply.."」後復原。"
	L.tempTip3 = "設定時，單純更改尺寸和座標而不更改選項，可以點擊「"..L.posApply.."」來直接套用而不需重載。"
	L.dragInfo = "Alt+右鍵：臨時性拖動框體"
	L.scrollInfo = "Alt+滾輪：臨時縮放小地圖"
	
elseif GetLocale() == "zhCN" then
	
	L.QuestWatchOpt = "追踪框"
	L.SizeOpt = "缩放"
	L.AlphaOpt = "淡出透明度"
	L.AnchorOpt = "锚点"
	L.Next = "下一级："
	L.Calendar = "行事历"
	
	L.ClickMenuOpt = "启用点击菜单"
	L.IconOpt = "角色信息提示"
	
	L.QuestWatchStarOpt = "使用 ★ 标记追踪项目"
	L.QuestWatchClickOpt = "使任务标题可点击"
	L.QuestWatchStyleOpt = "启用追踪框美化"
	
	L.WorldMapStyleOpt = "启用世界地图调整"
	L.fadeOpt = "移动中淡出"
	
	L.Apply = "更改后点击＂"..APPLY.."＂立即重载生效。"
	L.posApply = APPLY..L.SizeOpt.."和座标"
	
	L.WMFTip = "世界地图模块会在你同时启用 Leatrix Maps 时自动禁用。"
	L.tempTip1 = "Alt 功能是临时性功能，提供给需要追踪某些特定目标的偶发情况，所以它们的变动不会被保存。"
	L.tempTip2 = "所有 Alt 功能造成的更改会在重载界面或点击＂"..L.posApply.."＂后复原。"
	L.tempTip3 = "设置时，单纯更改尺寸和座标而不更改选项，可以点击＂"..L.posApply.."＂来直接套用而不需重载。"
	L.dragInfo = "Alt+右键临时性拖动框体"
	L.scrollInfo = "Alt+滚轮临时缩放小地图"
	
else

	L.QuestWatchOpt = "QuestWatch"
	L.SizeOpt = "Scale"
	L.AlphaOpt = "Fade out alpha"
	L.AnchorOpt = "Anchor"
	L.Next = "Next: "
	L.Calendar = SLASH_CALENDAR1:gsub("/(.*)","%1")
	
	L.ClickMenuOpt = "Enable click menu"
	L.IconOpt = "Character icon tooltip"

	L.QuestWatchStarOpt = "Mark object as ★ star"
	L.QuestWatchClickOpt = "Click-able quest title"
	L.QuestWatchStyleOpt = "Enable tracker style"
	
	L.WorldMapStyleOpt = "Enable World Map style"
	L.fadeOpt = "Fade out when moving"

	L.Apply = "Click "..APPLY.." to active changes."
	L.posApply = APPLY.." Size and Pos"
	
	L.WMFTip = "World map module will automatically disable when 'Leatrix Maps' is enable."
	L.tempTip1 = "Alt-function is a temporary function, for people wanna track something recently, they will not be saved to settgins."
	L.tempTip2 = 'Any scale and position change caused by alt-function will reset after you reload or click "'..L.posApply..'" button.'
	L.tempTip3 = 'If wanna config position and scale only (did not change check box), you can directly click"'..L.posApply..'" to apply them	without reload.'
	L.dragInfo = "Alt-right click to drag"
	L.scrollInfo = "Alt-scroll scale minimap"
end
