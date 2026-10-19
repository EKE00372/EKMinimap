local addon, ns = ...
local C, F, G, L = unpack(ns)
local GetLocale = GetLocale

L.Calendar = (SLASH_CALENDAR1 ~= "/calendar" and SLASH_CALENDAR1 or SLASH_CALENDAR2):sub(2)

--===================================================--
-----------------    [[ Locales ]]    -----------------
--===================================================--

if GetLocale() == "zhTW" then

	L.ToggleConfig = "開啟設定選項"

	L.QuestWatchOpt = "追蹤框"
	L.SizeOpt = "縮放"
	L.AlphaOpt = "淡出透明度"
	L.AnchorOpt = "錨點"
	L.Next = "下一級："
	L.XOpt = "X 座標"
	L.YOpt = "Y 座標"
	L.ReloadUI = "重載 UI"
	L.StatusChanged = "設定已變更，重載介面後生效。"

	L.ClickMenuOpt = "啟用點擊選單"
	L.IconOpt = "角色資訊提示"
	L.HoverClockOpt = "指向顯示時間"

	L.QuestWatchStyleOpt = "啟用追蹤框美化"
	L.QuestWatchStarOpt = "使用 ★ 標記追蹤項目"

	L.fadeOpt = "移動中淡出"

	L.posApply = APPLY..L.SizeOpt.."和座標"

	L.WMFTip = "世界地圖模組會在你同時啟用 Leatrix Maps 或 Mapster 時自動禁用。"
	L.tempTip1 = "Alt 功能是臨時性功能，提供給需要追蹤某些特定目標的偶發情況，所以它們的變動不會被儲存。"
	L.tempTip2 = "Alt 臨時調整會在重載介面後復原；小地圖與追蹤框也可點擊「"..L.posApply.."」復原。"
	L.tempTip3 = "小地圖的尺寸和座標、追蹤框的座標，可點擊「"..L.posApply.."」直接套用。功能開關與世界地圖設定需重載介面後生效。"
	L.dragInfo = "Alt+右鍵：臨時性拖動框體"
	L.scrollInfo = "Alt+滾輪：臨時縮放小地圖"

elseif GetLocale() == "zhCN" then

	L.ToggleConfig = "开启设置选项"

	L.QuestWatchOpt = "追踪框"
	L.SizeOpt = "缩放"
	L.AlphaOpt = "淡出透明度"
	L.AnchorOpt = "锚点"
	L.Next = "下一级："
	L.XOpt = "X 坐标"
	L.YOpt = "Y 坐标"
	L.ReloadUI = "重载 UI"
	L.StatusChanged = "设置已更改，重载界面后生效。"

	L.ClickMenuOpt = "启用点击菜单"
	L.IconOpt = "角色信息提示"
	L.HoverClockOpt = "指向显示时间"

	L.QuestWatchStarOpt = "使用 ★ 标记追踪项目"
	L.QuestWatchStyleOpt = "启用追踪框美化"

	L.fadeOpt = "移动中淡出"

	L.posApply = APPLY..L.SizeOpt.."和座标"

	L.WMFTip = "世界地图模块会在你同时启用 Leatrix Maps 或 Mapster 时自动禁用。"
	L.tempTip1 = "Alt 功能是临时性功能，提供给需要追踪某些特定目标的偶发情况，所以它们的变动不会被保存。"
	L.tempTip2 = "Alt 临时调整会在重载界面后复原；小地图与追踪框也可点击＂"..L.posApply.."＂复原。"
	L.tempTip3 = "小地图的尺寸和坐标、追踪框的坐标，可点击＂"..L.posApply.."＂直接应用。功能开关与世界地图设置需重载界面后生效。"
	L.dragInfo = "Alt+右键临时性拖动框体"
	L.scrollInfo = "Alt+滚轮临时缩放小地图"

else

	L.ToggleConfig = "EkMinimap Options"

	L.QuestWatchOpt = "QuestWatch"
	L.SizeOpt = "Scale"
	L.AlphaOpt = "Fade out alpha"
	L.AnchorOpt = "Anchor"
	L.Next = "Next: "
	L.XOpt = "X"
	L.YOpt = "Y"
	L.ReloadUI = RELOADUI
	L.StatusChanged = "Settings changed. Reload the UI to apply."

	L.ClickMenuOpt = "Enable click menu"
	L.IconOpt = "Character icon tooltip"
	L.HoverClockOpt = "Hover clock"

	L.QuestWatchStarOpt = "Mark object as ★ star"
	L.QuestWatchStyleOpt = "Enable tracker style"

	L.fadeOpt = "Fade out when moving"

	L.posApply = APPLY.." Size and Pos"

	L.WMFTip = "World map module will automatically disable when Leatrix Maps or Mapster is enabled."
	L.tempTip1 = "Alt-function is a temporary function, for people wanna track something recently, they will not be saved to settgins."
	L.tempTip2 = 'Reloading the UI restores temporary Alt adjustments. You can also restore minimap size/position and tracker position with "'..L.posApply..'".'
	L.tempTip3 = 'Apply minimap size and position and tracker position without reloading. Feature switches and world map settings take effect after a UI reload.'
	L.dragInfo = "Alt-right click to drag"
	L.scrollInfo = "Alt-scroll scale minimap"
end
