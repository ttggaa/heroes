--
-- Author: <wangguojun@playcrab.com>
-- Date: 2016-07-25 20:43:07
--
local LeagueUpStageView = class("LeagueUpStageView",BasePopView)
function LeagueUpStageView:ctor(data)
    self.super.ctor(self)
    self._callback = data and data.callback
end

-- 初始化UI后会调用, 有需要请覆盖
function LeagueUpStageView:onInit()
	-- self._titleImg = self:getUI("bg.titleImg")
	-- self._stageName = self:getUI("bg.stageName")
	self._stageImg = self:getUI("bg.stageImg")

	self._bg = self:getUI("bg")

	self:registerClickEventByName("closePanel",function( )
        if self._down == true then
            if self._callback then
                self._callback()
            end
    		self:close()
            UIUtils:reloadLuaFile("league.LeagueUpStageView")
        end
	end)

    self._closeTip = self:getUI("bg.closeTip")
    self._closeTip:setVisible(false)
    -- 新动画界面 2016.9.7
    self._stageBg = self:getUI("bg.stageBg")
    self._stageBg:setCascadeOpacityEnabled(true)
    self._stageBg:setOpacity(0)
    self._awardBg = self:getUI("bg.awardBg")
    self._awardBg:setCascadeOpacityEnabled(true)
    self._awardBg:setOpacity(0)
    self._zoneImg = self:getUI("bg.stageBg.zoneImg")
    self._award = self:getUI("bg.awardBg.award")
    self._getBtn = self:getUI("bg.awardBg.getBtn")
    self._rankLab = self:getUI("bg.rankLab")
     self._rankLab:setVisible(false)
    self._rankLab:setColor(cc.c3b(240, 200, 145))
    -- self._rankLab:setFontSize()
    local rank = self._modelMgr:getModel("LeagueModel"):getData().rank or ""
    self._rankLab:setString("您的排名是".. rank)
    -- self._getBtn:setPositionX(200)
    self:registerClickEvent(self._getBtn,function( )
        local callback = self._callback 
        local leagueData = tab:LeagueRank(self._zone)
        local awards = leagueData and clone(leagueData.onceaward) or {}
        if leagueData and leagueData.onceavartarFrame then
            table.insert(awards,leagueData.onceavartarFrame)
        end
        DialogUtils.showGiftGet({gifts = self._reward or awards,callback=function( )
            if callback then 
                callback()
            end
        end})
        self:close()
        UIUtils:reloadLuaFile("league.LeagueUpStageView")
    end)
    for i=1,3 do
        local des = self:getUI("bg.stageBg.des" .. i)
        des:setFontName(UIUtils.ttfName)
        des:setColor(cc.c3b(240, 200, 145))
    end
    local awardBgTitle = self:getUI("bg.awardBg.title")
    awardBgTitle:setFontName(UIUtils.ttfName)
    -- 有后边引导不引导第一个
    self._modelMgr:getModel("LeagueModel"):isCurBatchFirstIn(true)
    --shareBtn  by wangyan
    local shareInfo = {inParam = {moduleName = "ShareLeagueUpstageModule", stage = self._zone}}
    local shareNode = require("game.view.share.GlobalShareBtnNode").new({mType = "ShareLeagueUpstageModule"})
    shareNode:setPosition(123, 23)
    shareNode:setCascadeOpacityEnabled(true, true)
    self._awardBg:addChild(shareNode, 10)
    shareNode:registerClick(function()
        return {moduleName = "ShareLeagueUpstageModule", stage = self._zone, isHideBtn = true}
        end)
end

-- 接收自定义消息
function LeagueUpStageView:reflashUI(data)
    local down = data.down -- 通过后端来判断 
    self._down = true -- 没领取接口时暂时不显示
    local zone = data.zone or 1
    self._zone = zone
    self:getUI("bg.stageBg.des3"):setVisible(self._zone ~= 9)
    local changeReward = self._modelMgr:getModel("LeagueModel"):getLeague().changeReward
    if not changeReward or not changeReward[tostring(zone)] or tonumber(changeReward[tostring(zone)]) == 1 then
        self._down = false
        ServerManager:getInstance():sendMsg("LeagueServer", "getChangeZoneAward", {id=self._zone}, true, {}, function(result)
            if self._zone then
                self._reward = result.reward
            end
        end)        
        audioMgr:playSound("LeagueEnhance")
    end
    local curLeagueRank = tab:LeagueRank(zone or 1)
    -- self._stageName:setString(lang(curLeagueRank.name))
    self._stageImg:loadTexture(tab:LeagueRank(math.max(self._zone-1,1)).icon .. ".png",1)
    -- self:animBegin()
    self:stageImgAnim(function( )
        self:awardAnim()
    end)
end

function LeagueUpStageView:stageImgAnim( callback )
    local stageImg = self._stageImg
    stageImg:runAction(cc.RepeatForever:create(cc.Sequence:create(
        cc.MoveBy:create(0.1,cc.p(-3,0)),
        cc.MoveBy:create(0.1,cc.p(3,0))
        )))
    local changeMc = mcMgr:createViewMC("qiehuanguangxiao_leaguejinjiechenggong", false, true,function( _,sender )
        stageImg:loadTexture(tab:LeagueRank(self._zone).icon .. ".png",1)
        if self._zone == 9 then
            local curRank,preRank = self._modelMgr:getModel("LeagueModel"):getCurRank()
            local tail = "1"
            if curRank <= 32 then
                stageImg:loadTexture(tab:LeagueRank(self._zone).icon .. "_1.png",1)
                tail = "2"
            end
            stageImg:setOpacity(0)
            local chuanqiMc = mcMgr:createViewMC("chuanqi".. tail .."_leaguechuanqi", false, false,function( _,sender )
                local rankInImg = ccui.Text:create()
                rankInImg:setFontSize(24)
                rankInImg:setColor(cc.c4b(255,255,221,255))
                rankInImg:setFontName(UIUtils.ttfName)
                rankInImg:setPosition(stageImg:getContentSize().width/2,stageImg:getContentSize().height/2-16)
                rankInImg:setString(curRank)
                stageImg:addChild(rankInImg,11)
                sender:stop()
            end,RGBA8888)
            chuanqiMc:setPosition(stageImg:getContentSize().width/2,stageImg:getContentSize().height/2+10)
            stageImg:addChild(chuanqiMc,10)
        end
        stageImg:stopAllActions()
                
        local stageAnimImg = stageImg:clone()
        stageAnimImg:setBrightness(40)
        stageAnimImg:setPurityColor(255, 255, 255)
        stageImg:addChild(stageAnimImg)
        stageAnimImg:runAction(cc.Sequence:create(
            cc.ScaleTo:create(0.15,1.3),
            -- cc.DelayTime:create(0.1),
            cc.Spawn:create(cc.FadeOut:create(0.1),cc.ScaleTo:create(0.05,1)),
            cc.CallFunc:create(function( )
                stageAnimImg:removeFromParent()
                local bgW,bgH = self._bg:getContentSize().width,self._bg:getContentSize().height
                local bgMc = mcMgr:createViewMC("huodedaojudiguang_commonlight", true, false,function( _,sender )
                    sender:gotoAndPlay(10)
                end,RGBA8888)
                bgMc:setPosition(105,130)
                stageImg:addChild(bgMc,-1)
                stageImg:runAction(cc.Sequence:create(
                    cc.DelayTime:create(0.1),
                    cc.EaseOut:create(cc.MoveTo:create(0.15,cc.p(100,170)),0.7),
                    cc.CallFunc:create(function( )
                        if callback then
                            callback() 
                        end
                    end))
                )
            end)
            )
        )
    end,RGBA8888)
    changeMc:setPlaySpeed(0.8)
    changeMc:setPosition(105,130)
    stageImg:addChild(changeMc)
end

function LeagueUpStageView:awardAnim( callack )
    self._zoneImg:loadTexture("zone" .. self._zone .. "_league.png",1)
    local stagePosY = 80
    local awardBg = self._awardBg
    if not self._down then
        stagePosY = 181
        local awards = tab:LeagueRank(self._zone).onceaward
        for i,v in ipairs(awards) do
            local itemId
            if v[1] == "tool" then
                itemId = v[2]
            else
                itemId = IconUtils.iconIdMap[v[1]]
            end
            local icon = IconUtils:createItemIconById({itemId = itemId,num = v[3]})
            icon:setPosition((i-1)*110+45,70)
            icon:setScale(0.8)
            icon:setScaleAnim(true)
            awardBg:addChild(icon)
        end
        awardBg:setPosition(205,-25)
        awardBg:runAction(cc.Sequence:create(cc.Spawn:create(
            cc.MoveTo:create(0.1,cc.p(265,-25)),
            cc.FadeIn:create(0.2)
        )))
        self._closeTip:setVisible(false)
    else
        awardBg:setVisible(false)
        self._closeTip:setVisible(true)
    end
    local stageBg = self._stageBg
    stageBg:setPosition(205,stagePosY)
    stageBg:runAction(cc.Sequence:create(cc.Spawn:create(
        cc.MoveTo:create(0.1,cc.p(265,stagePosY)),
        cc.FadeIn:create(0.2),
        cc.CallFunc:create(function( )
            self._rankLab:setVisible(self._zone == 9)
        end)
    )))
    mcMgr:loadRes("leaguejinjiechenggong",function( )
        local mc = mcMgr:createViewMC("piaoluocaidai_leaguejinjiechenggong", true, false)
        mc:setPosition(285,400)
        self._bg:addChild(mc,99)
    end)
end

return LeagueUpStageView