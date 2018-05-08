--[[
    Filename:    TextView.lua
    Author:      huachangmiao@playcrab.com
    Datetime:    2016-03-16 20:43:31
    Description: File description
--]]

local TextView = class("TextView", BaseView)

function TextView:ctor(data)
    TextView.super.ctor(self)
end

function TextView:onInit()
    self.noSound = true
    GameStatic.showClickMc = false
    -- 四个角的图
    local sp = cc.Sprite:create("asset/uiother/loading/global_cg_kuang.png")
    sp:setFlippedY(true)
    sp:setAnchorPoint(0, 0)
    sp:setPosition(40, 40)
    self:addChild(sp)
     local sp = cc.Sprite:create("asset/uiother/loading/global_cg_kuang.png")
    sp:setAnchorPoint(0, 1)
    sp:setPosition(40, MAX_SCREEN_HEIGHT - 40)
    self:addChild(sp)
    local sp = cc.Sprite:create("asset/uiother/loading/global_cg_kuang.png")
    sp:setFlippedX(true)
    sp:setFlippedY(true)
    sp:setAnchorPoint(1, 0)
    sp:setPosition(MAX_SCREEN_WIDTH - 40, 40)
    self:addChild(sp)
    local sp = cc.Sprite:create("asset/uiother/loading/global_cg_kuang.png")
    sp:setFlippedX(true)
    sp:setAnchorPoint(1, 1)
    sp:setPosition(MAX_SCREEN_WIDTH - 40, MAX_SCREEN_HEIGHT - 40)
    self:addChild(sp)  

    self._mask = ccui.Layout:create()
    self._mask:setBackGroundColorOpacity(255)
    self._mask:setBackGroundColorType(1)
    self._mask:setBackGroundColor(cc.c3b(0,0,0))
    self._mask:setContentSize(MAX_SCREEN_WIDTH, MAX_SCREEN_HEIGHT)
    self._mask.noSound = true
    self:addChild(self._mask, 99)

    self._mask:runAction(cc.Sequence:create(cc.FadeOut:create(0.3), cc.CallFunc:create(function ()
    	self:textBegin()

	   	self:registerClickEvent(self._mask, function ()
	    	if self._isOver then return end
	    	self:initText1(true)
	    	self:initText2(true)
	    	self:initText3(true)
	    	self:initText4(true)
	    	self:initText5(true)
	    	ScheduleMgr:cleanMyselfDelayCall(self)
	    	self:over()
	    end)
    end)))
end

function TextView:initText1(now)
	if self._richText1 == nil then
		self._richText1 = RichTextFactory:create("[color=DED992,fontsize=24]多年前的经典《魔法门之英雄无敌III》，曾经满载着玩家的回忆。[-]", 
			960, 300)
	 	self._richText1:setPrintInterval(0.03)
	    self._richText1:enablePrinter(true)
	    self._richText1:formatText()
	    self._richText1:setPosition(MAX_SCREEN_WIDTH * 0.5 + 140, MAX_SCREEN_HEIGHT * 0.5 + 120)
	    self:addChild(self._richText1)
	end
	if now then
		self._richText1:finishAll()
	end
end

function TextView:initText2(now)
	if self._richText2 == nil then
		self._richText2 = RichTextFactory:create("[color=DED992,fontsize=24]神秘的世界，为我们打开想象的大门。[-]", 
			960, 300)
	 	self._richText2:setPrintInterval(0.03)
	    self._richText2:enablePrinter(true)
	    self._richText2:formatText()
	    self._richText2:setPosition(MAX_SCREEN_WIDTH * 0.5 + 140, MAX_SCREEN_HEIGHT * 0.5 + 80)
	    self:addChild(self._richText2)
	end
	if now then
		self._richText2:finishAll()
	end
end

function TextView:initText3(now)
	if self._richText3 == nil then
	    self._richText3 = RichTextFactory:create("[color=DED992,fontsize=24]精彩的战斗，伴我们度过难忘的夜晚。[-]", 
			960, 300)
	 	self._richText3:setPrintInterval(0.03)
	    self._richText3:enablePrinter(true)
	    self._richText3:formatText()
	    self._richText3:setPosition(MAX_SCREEN_WIDTH * 0.5 + 140, MAX_SCREEN_HEIGHT * 0.5 + 40)
	    self:addChild(self._richText3)
	end
	if now then
		self._richText3:finishAll()
	end
end

function TextView:initText4(now)
	if self._richText4 == nil then
	    self._richText4 = RichTextFactory:create("[color=DED992,fontsize=24]今天它将以全新的形式回到大家面前，英雄的脚步不曾停止。[-]", 
			960, 300)
	 	self._richText4:setPrintInterval(0.03)
	    self._richText4:enablePrinter(true)
	    self._richText4:formatText()
	    self._richText4:setPosition(MAX_SCREEN_WIDTH * 0.5 + 140, MAX_SCREEN_HEIGHT * 0.5 - 80)
	    self:addChild(self._richText4)
	end
	if now then
		self._richText4:finishAll()
	end
end

function TextView:initText5(now)
	if self._richText5 == nil then
	    self._richText5 = RichTextFactory:create("[color=DED992,fontsize=24]此刻再次燃起岁月的沉淀，那份激情和执着从未改变。[-]", 
			960, 300)
	 	self._richText5:setPrintInterval(0.03)
	    self._richText5:enablePrinter(true)
	    self._richText5:formatText()
	    self._richText5:setPosition(MAX_SCREEN_WIDTH * 0.5 + 140, MAX_SCREEN_HEIGHT * 0.5 - 120)
	    self:addChild(self._richText5)
	end
	if now then
		self._richText5:finishAll()
	end
end

function TextView:textBegin()
	self:initText1()

    ScheduleMgr:delayCall(1000, self, function()
		self:initText2()
	end)

    ScheduleMgr:delayCall(1600, self, function()
	    self:initText3()
    end)

    ScheduleMgr:delayCall(2200, self, function()
	    self:initText4()
	end)

    ScheduleMgr:delayCall(3200, self, function()
	    self:initText5()
	end)

	ScheduleMgr:delayCall(4200, self, function()
		self:over()
	end)
end

function TextView:over()
	if self._isOver then return end
	self._isOver = true
	ScheduleMgr:delayCall(50, self, function()
		tab:initNpc()
		ApiUtils.playcrab_device_monitor_action("text")
		tab:initTab_Async(2, function ()

        end,
        function ()

    	    local intanceModel = self._modelMgr:getModel("IntanceModel")
		    intanceModel:setData(nil)
		    local sectionId = 0
		    if self._curSectionId == nil then 
		        sectionId = intanceModel:getCurMainSectionId()
		    else
		        sectionId = self._curSectionId
		    end
		    local sysMainSectionMap = tab:MainSectionMap(sectionId)
		
		    cc.Director:getInstance():getTextureCache():addImage("asset/uiother/map/" .. sysMainSectionMap.img)
		    self._mask:runAction(cc.Sequence:create(cc.FadeIn:create(0.3), cc.DelayTime:create(0.1), cc.CallFunc:create(function ()
		    	GameStatic.showClickMc = true
		    	self._viewMgr:showView("logo.VideoView", {runType = 1})
		    	-- GuideUtils.unloginGuide()
		    end)))
		end)
	end)
end

function TextView:getAsyncRes()
    return 
    {   
        {"asset/ui/intance.plist", "asset/ui/intance.png"},
        {"asset/ui/intance-HD.plist", "asset/ui/intance-HD.png"},
        {"asset/anim/yingxiongkaiselinimage.plist", "asset/anim/yingxiongkaiselinimage.png"},
    }
end

function TextView:onDestroy()

    TextView.super.onDestroy(self)
end


return TextView