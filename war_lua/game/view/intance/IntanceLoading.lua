--
-- Author: huachangmiao@playcrab.com
-- Date: 2016-07-29 19:45:29
--

-- 假新手引导 专用loading
local IntanceLoading = class("IntanceLoading", BaseView)

function IntanceLoading:ctor(data)
	IntanceLoading.super.ctor(self)
	self._guideStep = data.guideStep
    self._callback = data.callback
    self.noSound = true
end

function IntanceLoading:onInit()
    if self._callback then
        local beginTick = socket.gettime()
        -- local mc = mcMgr:createViewMC("kaiselin_kaiselinloading", true, false)
        -- mc:setPosition(MAX_SCREEN_WIDTH * 0.5, MAX_SCREEN_HEIGHT * 0.5)
        -- self:addChild(mc)
        -- mc:setCascadeOpacityEnabled(true)
        -- mc:setOpacity(0)
        -- mc:runAction(cc.FadeIn:create(0.3))

        local height = MAX_SCREEN_HEIGHT - 640 + 120
        local curtain1 = cc.LayerColor:create(cc.c4b(0, 0, 0, 255))   --下
        curtain1:setContentSize(cc.size(MAX_SCREEN_WIDTH, height)) 
        curtain1:setPosition(0, 0)
        self:addChild(curtain1,99)

        local curtain2 = cc.LayerColor:create(cc.c4b(0, 0, 0, 255))   --上
        curtain2:setContentSize(cc.size(MAX_SCREEN_WIDTH, height))  
        curtain2:setPosition(0, MAX_SCREEN_HEIGHT - height)
        self:addChild(curtain2,99)

        -- local label = cc.Label:createWithTTF("凯瑟琳和她的军队在海上失散了，几天后……", UIUtils.ttfName, 22)
        -- label:setPosition(MAX_SCREEN_WIDTH * 0.5, height * 0.5)
        -- curtain1:addChild(label)
        -- label:runAction(cc.FadeIn:create(0.3))

        -- tab:initTab_Async(2, function ()

        -- end,
        -- function ()
        --     local intanceModel = self._modelMgr:getModel("IntanceModel")
        --     intanceModel:setData(nil)
        --     local sectionId = 0
        --     if self._curSectionId == nil then 
        --         sectionId = intanceModel:getCurMainSectionId()
        --     else
        --         sectionId = self._curSectionId
        --     end
        --     local sysMainSectionMap = tab:MainSectionMap(sectionId)
        --     local loadingList = 
        --     {
        --         {"asset/ui/intance.plist", "asset/ui/intance.png"},
        --         {"asset/anim/yingxiongkaiselinimage.plist", "asset/anim/yingxiongkaiselinimage.png"},
        --         "asset/uiother/map/" .. sysMainSectionMap.img,
        --     }
        --     UIUtils:aysncLoadRes(loadingList, function ()
        --         local d = 3 - (socket.gettime() - beginTick)
        --         if d < 0 then d = 0 end
        --         label:runAction(cc.Sequence:create(cc.DelayTime:create(d), cc.FadeOut:create(0.3)))
        --         mc:runAction(cc.Sequence:create(cc.DelayTime:create(d), cc.FadeOut:create(0.3), cc.DelayTime:create(0.1), cc.CallFunc:create(function ()
        --             GuideUtils.unloginInitByStep(self._guideStep)
        --             self._callback()    
        --         end)))
        --     end)

        -- end)
        ScheduleMgr:delayCall(0, self, function()
            GuideUtils.unloginInitByStep(self._guideStep)
            self._callback()
        end)
    else

    	tab:initIntanceLoading()
    	local intanceModel = self._modelMgr:getModel("IntanceModel")
    	intanceModel:setData(nil)
        local sectionId = 0
        if self._curSectionId == nil then 
            sectionId = intanceModel:getCurMainSectionId()
        else
            sectionId = self._curSectionId
        end
        local sysMainSectionMap = tab:MainSectionMap(sectionId)
        local loadingList = 
        {
            {6},
            {2, {"asset/ui/intance.plist", "asset/ui/intance.png"}},
            {2, {"asset/ui/intance-HD.plist", "asset/ui/intance-HD.png"}},
            {2, {"asset/anim/yingxiongkaiselinimage.plist", "asset/anim/yingxiongkaiselinimage.png"}},
            {1, "asset/uiother/map/" .. sysMainSectionMap.img},
        }

        self._loadingView = self:createLayer("global.LoadingView", {type = 0, title = "正在进入游戏 ... ", noUI = self._callback ~= nil, isGuide = true})
        self:getLayerNode():addChild(self._loadingView)
        self._loadingView:reflashUI({progress = 0})
        self._loadingView:loadStart(loadingList, function ()
            tab:initNpc()
            GuideUtils.unloginInitByStep(self._guideStep)
            ViewManager:getInstance():switchView("intance.IntanceView", {})
            ViewManager:getInstance():doFirstViewGuide()
        end)
    end

end

return IntanceLoading
