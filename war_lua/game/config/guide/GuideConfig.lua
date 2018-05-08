--[[
    Filename:    GuideConfig.lua
    Author:      huachangmiao@playcrab.com
    Datetime:    2015-12-21 16:12:05
    Description: File description
--]]
local debug = false
if GameStatic.showGuideDebug ~= nil then 
	debug = GameStatic.showGuideDebug
end
local guideConfig = {
	ENABLE = true,
	ENABLE_BATTLE = true,
	ENABLE_TRIGGER = true,
	DEBUG = false,
--[[=======================================================================================================
	参数说明1

	delay 延迟时间
	unLock 事件结束后是否解锁

	save 记录点  该条引导过后, 会告知服务器, 相对值 
	     由于 战斗后才能知道战斗结果, 所以战斗记录点自动在战后协议触发
		 
	jump 当正常流程往下走的时候会按照jump跳过, 当beginning的时候不会跳过

	beginning 进游戏第一个进的界面, 触发

	trigger 触发条件 
		0. done 上一步完成触发
		1. view 当view显示的时候触发
		2. layer 当layer显示的时候触发
		3. popshow 当popView显示的时候触发
		4. popclose 当popView关闭的时候触发
		5. storyover 当对话结束的时候触发
		6. newover 新功能开启结束
		7. custom 自定义

	event 引导事件类型
		1. click 点击事件
				clickName 控件名称  全名称, 从rootlayer搜起, 只要不是重名, 总会搜的到
				mask mask = {type = 1, scalex = 1, scaley = 1, x = 0, y = 0},
					type 1为圆形 2为方形 默认圆形 
					scalex x缩放 默认1.0
					scaley y缩放 默认1.0
					x x微调 默认0
					y y微调 默认0
				clickArea 点击区域微调 clickArea = {x = 0, y = 0, w = 0, h = 0},
					x x微调 默认0
					y y微调 默认0
					w 宽 默认为控件的宽
					h 高 默认为控件的高
				talk 提示文字 没有就不显示 talk = {str = "asdasdasd", x = 0, y = 0}
					str 文字
					x x微调 默认0 位置默认屏幕中心
					y y微调 默认0
					cx 光圈微调
					cy
				
				shouzhi 提示箭头 shouzhi = {angle = 0}
					angle 角度 0 - 360 默认0
					x x微调 默认0
					y y微调 默认0
				tip 弱文字提示 没有就不显示 tip = {str = "asdasdasd", x = 0, y = 0}
					str 文字
					x x微调 默认0 位置默认屏幕中心
					y y微调 默认0	
				
				scaleanim  缩放动画

		2. close 退出当前界面
		3. story  对话
				storyid = 1 对话id 详见 GuideStoryConfig
		4. prompt 提示事件, 点击任意关闭
				text 文字提示 没有就不显示 text = {str = "asdasdasd", x = 0, y = 0}
					str 文字
					x x微调 默认0 位置默认屏幕中心
					y y微调 默认0	
		5. drag 拖动事件 布阵专用
				dragName1 	起始
				dragName2   dragName2 = "formation.NewFormationView.root.bg.layer_left_touch",
				dragName3   结束

				talk 提示文字 没有就不显示 talk = {str = "asdasdasd", x = 0, y = 0}
					str 文字
					x x微调 默认0 位置默认屏幕中心
					y y微调 默认0
					cx 光圈微调
				1	cy
				
				tip 弱文字提示 没有就不显示 tip = {str = "asdasdasd", x = 0, y = 0}
					str 文字
					x x微调 默认0 位置默认屏幕中心
					y y微调 默认0	
		6. rush 介绍兵种
				kind 介绍种类 1 近战 2 突击 3 远程
				str 文字 str = "XINSHOU_999"
		7. zhanling 占领动画
		8. herozhuanchang 英雄专长引导


=======================================================================================================]]--
--1
				{
					delay = 100, unLock = true,
					trigger = "view", name = "intance.IntanceView",
					beginning = "intance.IntanceView",
					event = "click", clickName = "intance.IntanceView.IntanceMapLayer.branch_icon_700001",
					talk = {str = "XINSHOU_01", x = 200, y = 50},
					sound = "g12",
					shouzhi = {angle = 270, x = -50}, 
					--完成
				},
--2
				{
					delay = 100, unLock = true,
					trigger = "popclose", name = "global.GlobalShowCardDialog",
					beginning = "intance.IntanceView",
					event = "click", clickName = "intance.IntanceView.IntanceMapLayer.branch_icon_700002",
					sound = "g13",
					shouzhi = {angle = 270, x = -50}, 
					--完成
				},
--3
				{
					delay = 300, unLock = false,
					trigger = "popclose", name = "global.GlobalShowCardDialog",
					beginning = "intance.IntanceView",
					event = "click", clickName = "intance.IntanceView.IntanceMapLayer.building_icon7100101",
					talk = {str = "XINSHOU_02", x = -200, y = 100},
					sound = "g14",					
					shouzhi = {angle = 270, x = -50}, 
				},
--4
				{
					delay = 500, unLock = false,
					trigger = "view", name = "intance.IntanceView",
					beginning = "intance.IntanceView",
					event = "story", storyid = 2,
				},
--5
				{
					delay = 1000, unLock = false,
					trigger = "storyover",
					event = "click", clickName = "intance.IntanceView.IntanceMapLayer.building_icon7100102",
					shouzhi = {angle = 270, x = -50}, 
				},
--6
				{
					delay = 100, unLock = false,
					beginning = "main.MainView",
					trigger = "view", name = "main.MainView",
					event = "story", storyid = 4,
				},
--7
				{
					delay = 100, unLock = false,
					beginning = "main.MainView",
					trigger = "storyover",
					event = "click", clickName = "main.MainView.root.bg.midBg1.chouka",
					talk = {str = "XINSHOU_04", x = -200, y = 120},
					sound = "g33",
					shouzhi = {angle = 270, x = -40, y =20, cx=0, cy=20},
				},
--8
				{
					delay = 100, unLock = false,
					trigger = "view", name = "flashcard.FlashCardView",
					event = "click", clickName = "flashcard.FlashCardView.root.bg.gemLayer",
					talk = {str = "XINSHOU_05", x = -200, y = -100},
					sound = "g34",
					shouzhi = {angle = 270, x = -40},
				},
--9
				{
					delay = 800, unLock = true, save = 2,
					trigger = "done",
					event = "click", clickName = "flashcard.FlashCardView.root.bg.gemBtnLayer.buyOneBtn",
					shouzhi = {angle = 270, x = -80},
					sound = "g35",
				},
--10
				{
					delay = 0, unLock = false,
					trigger = "popclose", name = "flashcard.DialogFlashCardResult",
					event = "close",
				},
--11
				{
					delay = 200, unLock = false,
					trigger = "view", name = "main.MainView",
					beginning = "main.MainView",
					event = "click", clickName = "main.MainView.root.bottomLayer.instanceBtn",
					talk = {str = "XINSHOU_06", x = -200, y = -100},
					sound = "g36",
					shouzhi = {angle = 270, x = -50},
				},
--12
				{
					delay = 300, unLock = false,
					trigger = "view", name = "intance.IntanceView",
					event = "click", clickName = "intance.IntanceView.IntanceMapLayer.building_icon7100103",
					shouzhi = {angle = 270, x = -50}, 
					sound = "g37",
				},
--13
				{
					delay = 500, unLock = true,
					trigger = "layer", name = "intance.IntanceStageInfoNode",
					event = "click", clickName = "intance.IntanceStageInfoNode.root.bg.battleBtn",
					shouzhi = {angle = 270, x = -50},
					sound = "g38", 
				},
--14
				{
					delay = 100, unLock = false,
					beginning = "main.MainView",
					trigger = "popclose", name = "global.DialogUserLevelUp",
					event = "click", clickName = "main.MainView.root.bottomLayer.extendBar.bg.monsterBtn",
					talk = {str = "XINSHOU_07", x = -220, y = -100},
					shouzhi = {angle = 270, x = -50},
					sound = "g39", 
				},
--15
				{
					delay = 300, unLock = false,
					trigger = "view", name = "team.TeamListView",
					event = "click", clickName = "team.TeamListView.root.tableViewBg.102",
					shouzhi = {angle = 270, x = -50, cx = 0},
					sound = "g40",
				},
--16
				{
					delay = 300, unLock = false,
					trigger = "view", name = "team.TeamView",
					event = "click", clickName = "team.TeamView.root.bg1.rightSubBg.team.TeamLiftingNode.root.bg.vessel.runeBg.equipBg1",
					shouzhi = {angle = 270, x = -50},
					sound = "g41",
				},
--17
				{
					delay = 300, unLock = false, save = 2,
					trigger = "popshow", name = "team.TeamRuneView",
					event = "click", clickName = "team.TeamRuneView.root.bg.panel1.upgradeStageBtn",
					shouzhi = {angle = 270, x = -50},
					sound = "g42",
				},
--18
				{
					delay = 300, unLock = false,
					trigger = "done",
					event = "click", clickName = "team.TeamRuneView.root.bg.equiptList.equip2",
					shouzhi = {angle = 270, x = -50},
					sound = "g43",
				},
--19P过程
				--------------------------------------JUMP----------------------------------------------------------
				{
					delay = 100, unLock = false,  jump = 3,
					beginning = "main.MainView",
					event = "click", clickName = "main.MainView.root.bottomLayer.extendBar.bg.monsterBtn",
					talk = {str = "XINSHOU_07", x = -220, y = -100},
					shouzhi = {angle = 270, x = -50},
					sound = "g39",
				},
--20
				{
					delay = 300, unLock = false,
					trigger = "view", name = "team.TeamListView",
					event = "click", clickName = "team.TeamListView.root.tableViewBg.102",
					shouzhi = {angle = 270, x = -50, cx = 0},
					sound = "g40",
				},
--21
				{
					delay = 300, unLock = false,
					trigger = "view",name = "team.TeamView",
					event = "click", clickName = "team.TeamView.root.bg1.rightSubBg.team.TeamLiftingNode.root.bg.vessel.runeBg.equipBg2",
					shouzhi = {angle = 270, x = -50},
					sound = "g43",
				},
--22
				--------------------------------------------------------------------------------------------------------
				{
					delay = 300, unLock = false, save = 18, save = 2,
					trigger = "done",
					event = "click", clickName = "team.TeamRuneView.root.bg.panel1.upgradeStageBtn",
					shouzhi = {angle = 270, x = -50},
					sound = "g44",
				},
--23
				{
					delay = 300, unLock = false,
					trigger = "done",
					event = "click", clickName = "team.TeamRuneView.root.bg.equiptList.equip3",
					shouzhi = {angle = 270, x = -50},
					sound = "g45",
				},
--24P过程
				------------------------------------------JUMP--------------------------------------------------------------------
				{
					delay = 100, unLock = false,  jump = 3,
					beginning = "main.MainView",
					event = "click", clickName = "main.MainView.root.bottomLayer.extendBar.bg.monsterBtn",
					talk = {str = "XINSHOU_07", x = -220, y = -100},
					shouzhi = {angle = 270, x = -50},
					sound = "g39",
				},
--25
				{
					delay = 300, unLock = false,
					trigger = "view", name = "team.TeamListView",
					event = "click", clickName = "team.TeamListView.root.tableViewBg.102",
					shouzhi = {angle = 270, x = -50, cx = 0},
					sound = "g40",
				},
--26
				{
					delay = 500, unLock = false,
					trigger = "view",name = "team.TeamView",
					event = "click", clickName = "team.TeamView.root.bg1.rightSubBg.team.TeamLiftingNode.root.bg.vessel.runeBg.equipBg3",
					shouzhi = {angle = 270, x = -50},
					sound = "g45",
				},
--27
				-----------------------------------------------------------------------------------------------------------------------------------
				{
					delay = 300, unLock = false,
					trigger = "done",
					event = "click", clickName = "team.TeamRuneView.root.bg.Image_113.Image1.itemIcon", textureName = "globalImageUI4_squality1.png",
					tip = {str = "RUOTIP_07", y = 30},
					shouzhi = {angle = 270, x = -50},
					sound = "g46",
				},
--28
				{
					delay = 300, unLock = false,
					trigger = "popshow", name = "bag.DialogAccessTo",
					event = "click", clickName = "bag.DialogAccessTo.root.bg.scrollView.1",
					shouzhi = {angle = 270, x = -200, cx = -150},
					sound = "g47",
				},
--29
				{
					delay = 500, unLock = false,
					trigger = "view", name = "intance.IntanceView",
					event = "click", clickName = "intance.IntanceView.IntanceMapLayer.building_icon7100104",
					shouzhi = {angle = 270, x = -50}, 
					sound = "g48",
				},
--30
				{
					delay = 300, unLock = true,
					trigger = "layer", name = "intance.IntanceStageInfoNode",
					event = "click", clickName = "intance.IntanceStageInfoNode.root.bg.battleBtn",
					shouzhi = {angle = 270, x = -50}, 
					sound = "g49",
				},
--31
				{
					delay = 100, unLock = false,
					trigger = "popclose", name = "global.DialogUserLevelUp",
					event = "click", clickName = "intance.IntanceView.root.closeBtn",
					shouzhi = {angle = 270, x = -50},
					sound = "g51", 
				},
--32
				{
					delay = 500, unLock = false, save =7,
					trigger = "done", name = "bag.DialogAccessTo",
					event = "click", clickName = "team.TeamRuneView.root.bg.panel1.upgradeStageBtn",
					shouzhi = {angle = 270, x = -50},
					sound = "g52", 
				},
--33
				---------------------------------------JUMP-------------------------------------------------------------------
				{
					delay = 100, unLock = false, jump =4,
					beginning = "main.MainView",
					event = "click", clickName = "main.MainView.root.bottomLayer.extendBar.bg.monsterBtn",
					talk = {str = "XINSHOU_07", x = -220, y = -100},
					shouzhi = {angle = 270, x = -50},
					sound = "g39", 
				},
--34
				{
					delay = 300, unLock = false,
					trigger = "view", name = "team.TeamListView",
					event = "click", clickName = "team.TeamListView.root.tableViewBg.102",
					shouzhi = {angle = 270, x = -50, cx = 0},
					sound = "g40",
				},
--35
				{
					delay = 300, unLock = false,
					trigger = "view",name = "team.TeamView",
					event = "click", clickName = "team.TeamView.root.bg1.rightSubBg.team.TeamLiftingNode.root.bg.vessel.runeBg.equipBg3",
					shouzhi = {angle = 270, x = -50},
					sound = "g45",
				},
--36
				{
					delay = 100, unLock = false, save = 3,
					trigger = "popshow", name = "team.TeamRuneView",
					event = "click", clickName = "team.TeamRuneView.root.bg.panel1.upgradeStageBtn",
					shouzhi = {angle = 270, x = -50},
					sound = "g52",
				},
--37
				----------------------------------------------------------------------------------------------------------------------------
				{
					delay = 300, unLock = false, save =2,
					trigger = "done",
					event = "click", clickName = "team.TeamRuneView.root.bg.equiptList.equip4",
					shouzhi = {angle = 270, x = -50},
					sound = "g53",
				},
--38
				{
					delay = 300, unLock = false, save =8,
					trigger = "done",
					event = "click", clickName = "team.TeamRuneView.root.bg.panel1.upgradeStageBtn",
					shouzhi = {angle = 270, x = -50},
				},
--39
				----------------------------------------JUMP------------------------------------------------------
				{
					delay = 100, unLock = false, jump =4,
					beginning = "main.MainView",
					event = "click", clickName = "main.MainView.root.bottomLayer.extendBar.bg.monsterBtn",
					talk = {str = "XINSHOU_07", x = -220, y = -100},
					shouzhi = {angle = 270, x = -50},
					sound = "g39",
				},
--40
				{
					delay = 300, unLock = false,
					trigger = "view", name = "team.TeamListView",
					event = "click", clickName = "team.TeamListView.root.tableViewBg.102",
					shouzhi = {angle = 270, x = -50, cx = 0},
					sound = "g40",
				},
--41
				{
					delay = 300, unLock = false,
					trigger = "view",name = "team.TeamView",
					event = "click", clickName = "team.TeamView.root.bg1.rightSubBg.team.TeamLiftingNode.root.bg.vessel.runeBg.equipBg4",
					shouzhi = {angle = 270, x = -50},
					sound = "g53",
				},
--42
				{
					delay = 100, unLock = false, save = 4,
					trigger = "popshow", name = "team.TeamRuneView",
					event = "click", clickName = "team.TeamRuneView.root.bg.panel1.upgradeStageBtn",
					shouzhi = {angle = 270, x = -50},
				},

				--------------------------------------------------------------------------------------------------------
--43程
				{
					delay = 300, unLock = false,
					trigger = "done",
					event = "click", clickName = "team.TeamRuneView.root.bg.closeBtn",
					shouzhi = {angle = 270, x = -50},
					sound = "g55",
				},
--44程
				{
					delay = 300, unLock = true, save = 6,
					trigger = "popclose", name = "team.TeamRuneView",
					event = "click", clickName = "team.TeamView.root.bg1.rightSubBg.team.TeamLiftingNode.root.bg.vessel.updateStageBtn",
					talk = {str = "XINSHOU_08", x = -200, y = -100},
					shouzhi = {angle = 270, x = -80},
					sound = "g56",
				},
--45
				{
					delay = 0, unLock = false,
					trigger = "popclose", name = "team.TeamUpStageSuccessView",
					event = "close",
				},
--46MP过程
				-------------------------------------------------JUMP------------------------------------------------------------
				{
					delay = 100, unLock = false,  jump = 4,
					beginning = "main.MainView",
					event = "click", clickName = "main.MainView.root.bottomLayer.extendBar.bg.monsterBtn",
					talk = {str = "XINSHOU_07", x = -220, y = -100},
					shouzhi = {angle = 270, x = -50},
					sound = "g39",
				},
--47
				{
					delay = 300, unLock = false,
					trigger = "view", name = "team.TeamListView",
					event = "click", clickName = "team.TeamListView.root.tableViewBg.102",
					shouzhi = {angle = 270, x = -50, cx = 0},
					sound = "g40",
				},
--48过程
				{
					delay = 300, unLock = true, save = 2,
					trigger = "view", name = "team.TeamView",
					event = "click", clickName = "team.TeamView.root.bg1.rightSubBg.team.TeamLiftingNode.root.bg.vessel.updateStageBtn",
					talk = {str = "XINSHOU_08", x = -200, y = -100},
					shouzhi = {angle = 270, x = -50},
					sound = "g56",
				},
--49程
				{
					delay = 0, unLock = false,
					trigger = "popclose", name = "team.TeamUpStageSuccessView",
					event = "close",
				},
--50
				---------------------------------------------------------------------------------------------------------------------------
				{
					delay = 200, unLock = true,
					beginning = "main.MainView",
					trigger = "view", name = "main.MainView",
					event = "click", clickName = "main.MainView.root.bottomLayer.instanceBtn",
					talk = {str = "XINSHOU_09", x = -200, y = -100},
					sound = "g57",
					shouzhi = {angle = 270, x = -50},
				},
--51
				{
					delay = 200, unLock = false,
					trigger = "view", name = "intance.IntanceView",
					event = "story", storyid = 5,
				},
--52
				{
					delay = 200, unLock = false,
					trigger = "storyover",
					event = "click", clickName = "intance.IntanceView.IntanceMapLayer.building_icon7100105",
					talk = {str = "XINSHOU_10", x = 200, y = 100},
					sound = "g61",
					shouzhi = {angle = 270, x = -50}, 	
				},
--53
				{
					delay = 200, unLock = true,
					trigger = "layer", name = "intance.IntanceStageInfoNode",
					event = "click", clickName = "intance.IntanceStageInfoNode.root.bg.battleBtn",
					sound = "g62",
					shouzhi = {angle = 270, x = -50},
				},
--54点
				{
					delay = 200, unLock = false,
					beginning = "intance.IntanceView",
					trigger = "popclose", name = "global.DialogUserLevelUp",
					event = "story", storyid = 6,
				},
--55
				{
					delay = 0, unLock = false, save = 2,
					trigger = "storyover",
					event = "click", clickName = "intance.IntanceView.root.Panel_18.star1Panel.box1.reward1Btn",
					shouzhi = {angle = 270, x = -50},
					sound = "g67",
					talk = {str = "XINSHOU_11", x = -200, y = -100},
				},
--56
				{
					delay = 500, unLock = false,
					trigger = "done",
					event = "click", clickName = "intance.IntanceView.root.closeBtn",
					shouzhi = {angle = 270, x = -50},
					sound = "g68",
					talk = {str = "XINSHOU_12", x = -200, y = -100},
				},
--57
				{
					delay = 100, unLock = false,
					beginning = "main.MainView",
					trigger = "view", name = "main.MainView",
					event = "click", clickName = "main.MainView.root.bottomLayer.extendBar.bg.monsterBtn",
					talk = {str = "XINSHOU_13", x = -200, y = -100},
					sound = "g69",
					shouzhi = {angle = 270, x = -50},
				},
--58
				{
					delay = 300, unLock = true, save = 2,
					trigger = "view", name = "team.TeamListView",
					event = "click", clickName = "team.TeamListView.root.tableViewBg.101",
					shouzhi = {angle = 270, x = -50, cx = 0},
					sound = "g70",
				},
--59点
				{
					delay = 0, unLock = false,
					trigger = "popclose", name = "global.GlobalShowCardDialog",
					event = "close",
				},
--60点
				{
					delay = 200, unLock = false,
					beginning = "main.MainView",
					trigger = "view", name = "main.MainView",
					event = "click", clickName = "main.MainView.root.bottomLayer.extendBar.bg.bagBtn",
					talk = {str = "XINSHOU_72", x = -260, y = -100},
					sound = "g71",
					shouzhi = {angle = 270, x = -50},
				},
--61点
				{
					delay = 200, unLock = false, save = 2,
					trigger = "view", name = "bag.BagView",
					event = "click", clickName = "bag.BagView.root.bg.layer.itemInfo.flexoBtn",
					sound = "g72",
					shouzhi = {angle = 270, x = -50},
				},
--62点
				{
					delay = 500, unLock = false,
					trigger = "done",
					event = "close",
				},
--63点
				{
					delay = 200, unLock = false,
					beginning = "main.MainView",
					trigger = "view", name = "main.MainView",
					event = "click", clickName = "main.MainView.root.bottomLayer.extendBar.bg.monsterBtn",
					talk = {str = "XINSHOU_14", x = -260, y = -100},
					sound = "g73",
					shouzhi = {angle = 270, x = -50,},
				},
--64点
				{
					delay = 200, unLock = false,
					trigger = "view", name = "team.TeamListView",
					event = "click", clickName = "team.TeamListView.root.tableViewBg.101",
					sound = "g74",
					shouzhi = {angle = 270, x = -50, cx = 0},
				},
--65
				{
					delay = 200, unLock = false,
					trigger = "view", name = "team.TeamView",
					event = "click", clickName = "team.TeamView.root.bg1.rightSubBg.tab2",
					sound = "g75",
					shouzhi = {angle = 270, x = -50},
				},
--66
				{
					delay = 200, unLock = false, save = 3,
					trigger = "done",
					event = "click", clickName = "team.TeamView.root.bg1.rightSubBg.team.TeamGradeNode.root.bg.scrollView.infoNode.upFiveTeamBtn",
					sound = "g76",
					shouzhi = {angle = 270, x = -50},
				},
--67
				{
					delay = 200, unLock = false,
					trigger = "done",
					event = "click", clickName = "global.UserInfoView.root.closeBtn",
					talk = {str = "XINSHOU_15", x = -200, y = -100},
					shouzhi = {angle = 270, x = -50},
					sound = "g77",
				},
--68
				{
					delay = 0, unLock = false,
					trigger = "view", name = "team.TeamListView",
					event = "close",
				},
--69
				{
					delay = 300, unLock = false,
					beginning = "main.MainView",
					trigger = "view", name = "main.MainView",
					event = "click", clickName = "main.MainView.root.bottomLayer.extendBar.bg.formationBtn",
					shouzhi = {angle = 270, x = -50},
					tip = {str = "RUOTIP_10",y = 51},
					sound = "g78",
				},
--70
				{
					delay = 300, unLock = false,
					trigger = "view", name = "formation.NewFormationView",
					event = "drag", 
					dragName1 = "formation.NewFormationView.root.bg.layer_left.layer_list.layer_items.cell_0.item_0",
					dragName2 = "formation.NewFormationView.root.bg.layer_left_touch",
					dragName3 = "formation.NewFormationView.root.bg.layer_left.layer_team_formation.formation_icon_7",
					scale1 = true,
					talk = {str = "XINSHOU_58", x = 200, y = -65},
					sound = "g79",
				},
--71
				{
					delay = 200, unLock = false,   save = 1,
					trigger = "done",
					event = "click", clickName = "formation.NewFormationView.root.bg.btn_return",
					shouzhi = {angle = 270, x = -50},
					sound = "g80",
				},
--72
				{
					delay = 200, unLock = true, save =1 ,
					beginning = "main.MainView",
					trigger = "view", name = "main.MainView",
					event = "click", clickName = "main.MainView.root.bottomLayer.instanceBtn",
					talk = {str = "XINSHOU_16", x = -200, y = -100},
					shouzhi = {angle = 270, x = -50},
					sound = "g81",
				},
--73
				{
					delay = 5000, unLock = false,
					beginning = "intance.IntanceView",
					trigger = "custom", name = "IntanceWorldLayer71002",
					event = "click", clickName = "intance.IntanceView.IntanceMapLayer.building_icon7100201",
					talk = {str = "XINSHOU_17", x = -200, y = -100},
					shouzhi = {angle = 270, x = -50}, 
					sound = "g89",
				},
--74
				{
					delay = 300, unLock = true,
					trigger = "layer", name = "intance.IntanceStageInfoNode",
					event = "click", clickName = "intance.IntanceStageInfoNode.root.bg.battleBtn",
					shouzhi = {angle = 270, x = -50}, 
				},
--75
				{
					delay = 300, unLock = false,
					beginning = "intance.IntanceView",
					trigger = "popclose", name = "global.DialogUserLevelUp",
					event = "story", storyid = 9,
					shouzhi = {angle = 270, x = -50},
				},
--76
				{
					delay = 300, unLock = false,
					beginning = "intance.IntanceView",
					trigger = "storyover",
					event = "click", clickName = "intance.IntanceView.IntanceMapLayer.branch_icon_710021",
					shouzhi = {angle = 270, x = -55,cx = -5},
					sound = "g98",
				},
--77
				{
					delay = 1000, unLock = false,
					trigger = "popshow", name = "intance.IntanceBranchView",
					event = "click", clickName = "intance.IntanceBranchView.root.bgSpecial.enterBtn",
					shouzhi = {angle = 270, x = -50},
					sound = "g99",
				},
--78
				{
					delay = 300, unLock = true,
					trigger = "view", name = "formation.NewFormationView",
					event = "click", clickName = "formation.NewFormationView.root.bg.layer_information.btn_battle",
					shouzhi = {angle = 270, x = -50}, 
					sound = "g100",
				},
--79
				{
					delay = 0, unLock = false,
					trigger = "view", name = "intance.IntanceView",
				},
--80
				{
					delay = 500, unLock = false,
					beginning = "intance.IntanceView",
					trigger = "view", name = "intance.IntanceView",
					event = "click", clickName = "intance.IntanceView.IntanceMapLayer.branch_icon_710121",
					shouzhi = {angle = 270, x = -40, cx = 10},
					sound = "g103",
				},
--81
				{
					delay = 300, unLock = true,
					trigger = "popshow", name = "intance.IntanceBranchView", save =2,
					event = "click", clickName = "intance.IntanceBranchView.root.bg6.enterBtn",
					shouzhi = {angle = 270, x = -50},
				},
--82
				{
					delay = 1000, unLock = false,
					trigger = "done", name = "intance.IntanceView",
					event = "story", storyid = 10,
				},
--83
				-----------------------------------------------------------------------------
				{
					delay = 2500, unLock = false,
					trigger = "storyover",
					beginning = "intance.IntanceView",
					event = "click", clickName = "intance.IntanceView.IntanceMapLayer.building_icon7100202",
					talk = {str = "XINSHOU_18", x = -200, y = -100},
					sound = "g106",
					shouzhi = {angle = 270, x = -50}, 
				},
--84
				{
					delay = 300, unLock = false,
					trigger = "layer", name = "intance.IntanceStageInfoNode",
					event = "click", clickName = "intance.IntanceStageInfoNode.root.bg.battleBtn",
					shouzhi = {angle = 270, x = -50}, 
					sound = "g108",
				},
--85
				{
					delay = 300, unLock = true,
					trigger = "view", name = "formation.NewFormationView",
					event = "click", clickName = "formation.NewFormationView.root.bg.layer_information.btn_battle",
					shouzhi = {angle = 270, x = -50}, 
				},
--86特权
				{
					level = 9,
					delay = 100, unLock = false,
					trigger = "newover",
					event = "story", storyid = 28,
				},
--87示免费抽卡
				{
					delay = 100, unLock = true,
					trigger = "storyover",
					event = "click", clickName = "main.MainView.root.bottomLayer.extendBar.bg.privilegeBtn",
					shouzhi = {angle = 270, x = -50},
					sound = "g114",
				},
--88精英副本
				{
					level = 10,
					delay = 100, unLock = false,
					trigger = "newover",
					event = "click", clickName = "main.MainView.root.bottomLayer.instanceBtn",
					shouzhi = {angle = 270, x = -50},
					talk = {str = "XINSHOU_26", x = -200, y = -100},
					sound = "g115",
				},
--89下副本入口
				{
					delay = 1500, unLock = false,
					trigger = "view", name = "intance.IntanceView",
					event = "click", clickName = "intance.IntanceView.IntanceWorldLayer.sceneLayer.bgLayer.world_elite_btn",
					shouzhi = {angle = 90, x = 50},
					sound = "g116",
					showBtn = "et",					
				},
--90击地下副本1-1
				{
					delay = 100, unLock = true,
					trigger = "view", name = "intance.IntanceEliteView",
					event = "click", clickName = "intance.IntanceEliteView.root.building_icon7200101",
					shouzhi = {angle = 90, x = 50},
					talk = {str = "XINSHOU_27", x = 200, y = -100},
					sound = "g117",
				},
--91级触发引导任务
				{
					level = 12,
					delay = 500, unLock = true,
					trigger = "newover",
					event = "click", clickName = "main.MainView.root.bottomLayer.extendBar.bg.taskBtn",
					shouzhi = {angle = 270, x = -50},
					talk = {str = "XINSHOU_25", x = -200, y = -100},
					sound = "g118",
				},
				
--92级触发引导竞技场
				{
					level = 15,
					delay = 500, unLock = false,
					trigger = "newover",
					event = "click", clickName = "main.MainView.root.bg.midBg3.pve",
					shouzhi = {angle = 270, x = -50},
					talk = {str = "XINSHOU_28", x = -200, y = -100},
					sound = "g119",
				},
--93级触发引导竞技场
				{
					delay = 100, unLock = true,
					trigger = "view", name = "pvp.PvpInView",
					event = "click", clickName = "pvp.PvpInView.root.bg.scrollView.hole1",
					shouzhi = {angle = 270, x = -50},
					sound = "g120",
				},
--94英雄升星引导
				{
					level = 16,
					delay = 500, unLock = false, 
					trigger = "newover",
					event = "story", storyid = 26,

				},
--95英雄升星引导
				{
					delay = 500, unLock = true,
					trigger = "storyover",
					event = "click", clickName = "main.MainView.root.bottomLayer.extendBar.bg.heroBtn",
					shouzhi = {angle = 270, x = -50},
				},	
--96点击英雄查看
				{
					delay = 500, unLock = true,
					trigger = "view", name = "hero.HeroView",
					event = "click", clickName = "hero.HeroView.root.bg.layer.hero_description_bg.btn_check",
					shouzhi = {angle = 270, x = -50},
				},				
--97级触发矮人宝物
				{
					level = 18,
					delay = 500, unLock = false,
					trigger = "newover",
					event = "click", clickName = "main.MainView.root.bg.midBg4.yuanzheng",
					shouzhi = {angle = 270, x = -50, cx = 5},
					talk = {str = "XINSHOU_34", x = 200, y = -100},
				},
--98点击矮人宝物
				{
					delay = 500, unLock = false,
					trigger = "view", name = "pve.PveView",
					event = "click", clickName = "pve.PveView.root.bg.scrollView.holeNode2",
					shouzhi = {angle = 270, x = -50 ,cx =0},
				},
--99点击矮人宝物
				{
					delay = 100, unLock = true,
					trigger = "view", name = "pve.AiRenMuWuView",
					event = "prompt",
					text = {str = "RUOTIP_20", x = 293, y = -117},
				},
--100级触发英雄系统
				{
					level = 20,
					delay = 500, unLock = false, 
					trigger = "newover",
					event = "click", clickName = "main.MainView.root.bottomLayer.extendBar.bg.heroBtn",
					shouzhi = {angle = 270, x = -50},
					talk = {str = "XINSHOU_36", x = -100, y = -100},
				},
--101点击英雄查看
				{
					delay = 500, unLock = false,
					trigger = "view", name = "hero.HeroView",
					event = "click", clickName = "hero.HeroView.root.bg.layer.hero_description_bg.btn_check",
					shouzhi = {angle = 270, x = -50},
				},
--102点击英雄查看
				{
					delay = 300, unLock = true,
					trigger = "popshow", name = "hero.HeroDetailsView",
					event = "click", clickName = "hero.HeroDetailsView.root.bg.layer_hero_skill_information.hero.HeroSkillInformationView.root.bg.layer.layer_skill.layer_right.skill_des_title_bg_3.btn_study",
					shouzhi = {angle = 270, x = -50},
					talk = {str = "XINSHOU_37", x = -200, y = -100},
				},
--103级触发墓穴
				{
					level = 21,
					delay = 500, unLock = false,
					trigger = "newover",
					event = "click", clickName = "main.MainView.root.bg.midBg4.yuanzheng",
					shouzhi = {angle = 270, x = -50, cx = 5},
					talk = {str = "XINSHOU_38", x = 200, y = -100},
				},
--104点击墓穴
				{
					delay = 500, unLock = false,
					trigger = "view", name = "pve.PveView",
					event = "click", clickName = "pve.PveView.root.bg.scrollView.holeNode1",
					shouzhi = {angle = 270, x = -50 ,cx =0},
				},
--105点击墓穴
				{
					delay = 300, unLock = true,
					trigger = "view", name = "pve.ZombieView",
					event = "prompt",
					text = {str = "RUOTIP_28", x = 300, y = -117},
					shouzhi = {angle = 270, x = -50},
				},
--106级触发联盟系统
				{
					level = 22,
					delay = 500, unLock = true, 
					trigger = "newover",
					showGuildTuDialog = 1,
				},
--107级触发联盟系统
				{
					trigger = "popclose", name = "global.CommonNewGuideDialog",
					delay = 300, unLock = true, 
					event = "click", clickName = "main.MainView.root.bg.midBg4.home",
					shouzhi = {angle = 270, x = -120 ,y=-50,cx = -70, cy = -50},
					talk = {str = "XINSHOU_92", x = -100, y = -100},
				},
--108级触发神秘商店
				{
					level = 23,
					delay = 500, unLock = true, 
					trigger = "newover",
					event = "click", clickName = "main.MainView.root.bg.midBg1.market",
					shouzhi = {angle = 270, x = -50},
					tip = {str = "RUOTIP_29", x = 0, y = 40},
				},

--109级触发图鉴系统
				{
					level = 24,
					delay = 500, unLock = true, 
					trigger = "newover",
					event = "click", clickName = "main.MainView.root.bg.midBg2.congress",
					shouzhi = {angle = 270, x = -10 ,cx =40},
					talk = {str = "XINSHOU_65", x = -100, y = 100},
				},
--110
				{
					delay = 100, unLock = false, 
					trigger = "view", name = "pokedex.PokedexView",
					showTuJianDialog = 1,
				},
--111
				{
					delay = 100, unLock = false,
					trigger = "popclose", name = "pokedex.PokedexShowDialog",								
					event = "click", clickName = "pokedex.PokedexView.root.bg.poke1",
					shouzhi = {angle = 270, x = -50 ,},
					talk = {str = "XINSHOU_70", x = 100, y = -100},
				},
--112
				{
					delay = 500, unLock = true, 
					trigger = "view", name = "pokedex.PokedexDetailView",
					event = "click", clickName = "pokedex.PokedexDetailView.root.bg.quickadd",
					shouzhi = {angle = 270, x = -50 ,},
					talk = {str = "XINSHOU_71", x = -100, y = -100},
				},
--113级触发远征
				{
					level = 26,
					delay = 300, unLock = false, 
					trigger = "newover",
					event = "click", clickName = "main.MainView.root.bg.midBg4.chuanwu",
					shouzhi = {angle = 270, x = -50, cx = 5},
					tip = {str = "RUOTIP_22", x = 5, y = 50},
				},
--114点击远征
				{
					delay = 1500, unLock = true,
					trigger = "view", name = "crusade.CrusadeView",
					event = "click", clickName = "crusade.CrusadeView.root.ScrollView.Crusade_1",
					shouzhi = {angle = 270, x = -50},
					talk = {str = "RUOTIP_23", x = 200, y = -100},
				},
--115级触发魔法行会系统
				{
					level = 28,
					delay = 500, unLock = true, 
					trigger = "newover",
					event = "click", clickName = "main.MainView.root.bg.midBg1.mana",
					shouzhi = {angle = 270, x = -70, cx = -26},
					talk = {str = "XINSHOU_67", x = -100, y = -100},
				},

--116级英雄专精刷新
				{
					level = 31,
					delay = 500, unLock = false, 
					trigger = "newover",
					event = "click", clickName = "main.MainView.root.bottomLayer.extendBar.bg.heroBtn",
					shouzhi = {angle = 270, x = -50},
					tip = {str = "RUOTIP_30", x = 0, y = 47},
				},
--117点击英雄查看
				{
					delay = 100, unLock = false,
					trigger = "view", name = "hero.HeroView",
					event = "click", clickName = "hero.HeroView.root.bg.layer.hero_description_bg.btn_check",
					shouzhi = {angle = 270, x = -50},
				},
--118点击详情
				{
					delay = 100, unLock = false,
					trigger = "popshow", name = "hero.HeroDetailsView",
					event = "click", clickName = "hero.HeroDetailsView.root.bg.btn_mastery_information",
					shouzhi = {angle = 270, x = -50},
				},
--119点击刷新
				{
					delay = 100, unLock = true,
					trigger = "done",
					event = "click", clickName = "hero.HeroDetailsView.root.bg.layer_hero_basic_information.hero.HeroBasicInformationView.root.bg.layer.layer_right_1.layer_mastery_refresh.btn_refresh",
					shouzhi = {angle = 90, x = 50},
				},

--120级触发龙之国系统
				{
					level = 34,
					delay = 500, unLock = false,
					trigger = "newover",
					event = "click", clickName = "main.MainView.root.bg.midBg4.yuanzheng",
					shouzhi = {angle = 270, x = -50, cx = 5},
					talk = {str = "XINSHOU_69", x = 200, y = -100},
				},
--121点击龙之国
				{
					delay = 500, unLock = true,
					trigger = "view", name = "pve.PveView",
					event = "click", clickName = "pve.PveView.root.bg.scrollView.holeNode3",
					shouzhi = {angle = 270, x = -50 ,cx =0},
				},
	
--				{
--					level = 33,
--					delay = 500, unLock = false, 
--					trigger = "newover",
--					event = "click", clickName = "main.MainView.root.bottomLayer.extendBar.bg.monsterBtn",
--					shouzhi = {angle = 270, x = -50},
--					talk = {str = "XINSHOU_79", x = -100, y = -100},
--				},
--				{
--					delay = 300, unLock = false,
--					trigger = "view", name = "team.TeamListView",
--					event = "click", clickName = "team.TeamListView.root.tableViewBg.105",
--					shouzhi = {angle = 270, x = -50, cx = 0},
--					showTeam = 105,
--				},
--				{
--					delay = 300, unLock = false,
--					trigger = "view", name = "team.TeamView",
--					event = "click", clickName = "team.TeamView.root.bg1.rightSubBg.tab4",
--					shouzhi = {angle = 270, x = -50},
--				},
--			{
--					delay = 500, unLock = true,
--					trigger = "done",
--					event = "click", clickName = "team.TeamView.root.bg1.rightSubBg.team.TeamSkillNode.root.bg.scrollView.skillBg1.permit.Image_52",
--					talk = {str = "XINSHOU_80", x = -200, y = -100},
--					shouzhi = {angle = 270, x = -50},
--				},				

--122战争学院
				{
					level = 37,
					delay = 500, unLock = false, 
					trigger = "newover",
					event = "click", clickName = "main.MainView.root.bottomLayer.extendBar.bg.monsterBtn",
					shouzhi = {angle = 270, x = -50},
					talk = {str = "XINSHOU_75", x = -100, y = -100},
				},
--123战争学院
				{
					delay = 500, unLock = false, 
					trigger = "view", name = "team.TeamListView",
					event = "click", clickName = "team.TeamListView.root.tableViewBg.106",
					shouzhi = {angle = 270, x = -50, cx = 0},
					showTeam = 106,
				},
--124战争学院
				{
					delay = 300, unLock = true,
					trigger = "view", name = "team.TeamView",
					event = "click", clickName = "team.TeamView.root.bg1.talentBtn",
					shouzhi = {angle = 270, x = -50},
				},
--				{
--					level = 39,
--					delay = 500, unLock = false, 
--					trigger = "newover",
--					event = "click", clickName = "main.MainView.root.bottomLayer.extendBar.bg.heroBtn",
--					shouzhi = {angle = 270, x = -50},
--					talk = {str = "XINSHOU_90", x = -200, y = -100},
--				},	
--				{
--					delay = 500, unLock = true,
--					trigger = "view", name = "hero.HeroView",
--					event = "click", clickName = "hero.HeroView.root.bg.layer.hero_description_bg.btn_memoirist",
--					shouzhi = {angle = 270, x = -50},
--				},
--125MF
				{
					level = 39,
					delay = 100, unLock = false,
					trigger = "newover",
					event = "click", clickName = "main.MainView.root.bottomLayer.instanceBtn",
					shouzhi = {angle = 270, x = -50},
					talk = {str = "XINSHOU_74", x = -200, y = -100},
				},
--126MF
				{
					delay = 1500, unLock = false,
					trigger = "view", name = "intance.IntanceView",
					event = "click", clickName = "intance.IntanceView.IntanceWorldLayer.sceneLayer.bgLayer.world_mf_btn",
					shouzhi = {angle = 90, x = 50},
					showBtn = "mf",
				},
--127MF
				{
					delay = 500, unLock = false,
					trigger = "view", name = "MF.MFView",
					event = "click", clickName = "MF.MFView.root.bg.scrollView.layer.daoyu1",
					shouzhi = {angle = 270, x = -28 , y = 37 , cx = 22 , cy =37},
					talk = {str = "XINSHOU_81", x = -200, y = -100},
				},
--128MF
				{
					delay = 100, unLock = false,
					trigger = "view", name = "MF.MFTaskView",
					event = "click", clickName = "MF.MFTaskView.root.bg.downBg.downPanel.quickAdd",
					talk = {str = "XINSHOU_82", x = -200, y = 0},
					shouzhi = {angle = 270, x = -50},
				},
--129MF
				{
					delay = 500, unLock = false,
					trigger = "done",
					event = "click", clickName = "MF.MFTaskView.root.bg.downBg.downPanel.startTask",
					shouzhi = {angle = 270, x = -50},
					talk = {str = "XINSHOU_83", x = -200, y = 0},
				},
--130MF
				{
					delay = 100, unLock = false,
					trigger = "done",
					event = "click", clickName = "MF.MFTaskView.root.bg.downBg.jiasu",
					shouzhi = {angle = 270, x = -50},
					talk = {str = "XINSHOU_84", x = 200, y = 0},
				},
--131MF
				{
					delay = 100, unLock = false,
					trigger = "done",
					event = "click", clickName = "MF.MFTaskView.root.bg.downBg.downPanel.startTask",
					shouzhi = {angle = 270, x = -80},
				},
--132点
				{
					delay = 1000, unLock = false,
					trigger = "done",
					event = "close",
				},
--133点
				{
					delay = 200, unLock = true,
					trigger = "view", name = "main.MainView",
					event = "click", clickName = "main.MainView.root.bg.midBg5.chaoxue",
					shouzhi = {angle = 270, x = -50},
					talk = {str = "XINSHOU_85", x = -200, y = -100},
				},	
--134云中城
				{
					level = 41,
					delay = 500, unLock = false,
					trigger = "newover",
					event = "click", clickName = "main.MainView.root.bottomLayer.instanceBtn",
					shouzhi = {angle = 270, x = -50},
					talk = {str = "XINSHOU_76", x = -200, y = -100},
				},
--135云中城
				{
					delay = 1500, unLock = false,
					trigger = "view", name = "intance.IntanceView",
					event = "click", clickName = "intance.IntanceView.IntanceWorldLayer.sceneLayer.bgLayer.world_cloudcity_btn",
					shouzhi = {angle = 90, x = 50},
					showBtn = "ct",
				},
--136云中城
				{
					delay = 1300, unLock = false,
					trigger = "view", name = "cloudcity.CloudCityView",
					event = "click", clickName = "cloudcity.CloudCityView.root.bg.startNode.startBtn",
					shouzhi = {angle = 90, x = 50},
				},
--137云中城
				{
					delay = 1000, unLock = false,
					trigger = "popshow", name = "cloudcity.CloudCityBattleView",
					event = "click", clickName = "cloudcity.CloudCityBattleView.root.bg.layer.bgRight",
					talk = {str = "XINSHOU_77", x = 200, y = -100},
					shouzhi = {angle = 90, x = 50},
				},
--138云中城
				{
					delay = 300, unLock = true,
					trigger = "done",
					event = "click", clickName = "cloudcity.CloudCityBattleView.root.bg.layer.battleBtn",
					shouzhi = {angle = 90, x = 50},
					talk = {str = "XINSHOU_78", x = -200, y = -100},
				},
--139云中城
				{
					delay = 200, unLock = true,
					trigger = "view", name = "formation.NewFormationView",
					event = "story", storyid = 32,
				},
--140MF
				{
					level = 60,
					delay = 100, unLock = false,
					trigger = "newover",
					event = "click", clickName = "main.MainView.root.bottomLayer.instanceBtn",
					shouzhi = {angle = 270, x = -50},
					talk = {str = "XINSHOU_93", x = -200, y = -100},
				},
--141MF
				{
					delay = 1500, unLock = true,
					trigger = "view", name = "intance.IntanceView",
					event = "click", clickName = "intance.IntanceView.IntanceWorldLayer.sceneLayer.bgLayer.world_element_btn",
					shouzhi = {angle = 90, x = 50},
					showBtn = "el",
				},
--142 法术书 点魔法行会
				{
					level = 70,
					delay = 100, unLock = false,
					trigger = "newover",
					event = "click", clickName = "main.MainView.root.bg.midBg1.mana",
					shouzhi = {angle = 270, x = -50},
					talk = {str = "XINSHOU_95", x = -200, y = -100},
				},
--143 法术书 点法术祈愿
				{
					delay = 300, unLock = true,
					trigger = "view", name = "talent.CollegeView",
					event = "click", clickName = "talent.CollegeView.root.bg.trainingNode3",
					shouzhi = {angle = 270, x = -50},
					talk = {str = "XINSHOU_96", x = -200, y = -100},
				},
				--=======================================================================================================、
		} 
return guideConfig