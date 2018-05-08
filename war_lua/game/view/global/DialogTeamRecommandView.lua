--
-- Author: <wangguojun@playcrab.com>
-- Date: 2016-05-24 20:11:21
--
local NewFormationIconView = require("game.view.formation.NewFormationIconView")
local DialogTeamRecommandView = class("DialogTeamRecommandView",BasePopView)
function DialogTeamRecommandView:ctor()
    self.super.ctor(self)

end

-- 初始化UI后会调用, 有需要请覆盖
function DialogTeamRecommandView:onInit()
	self:registerClickEventByName("bg.layer.okBtn",function( )
		self:close()
        UIUtils:reloadLuaFile("global.DialogTeamRecommandView")
	end)
	self._des = self:getUI("bg.layer.des")
	-- self._bg1 = self:getUI("bg.layer.frame")

	local des1 = self:getUI("bg.layer.desBg1.des")
	des1:setColor(cc.c3b(248, 235, 84))
	des1:enable2Color(1,cc.c4b(230, 156, 6,255))
	des1:enableOutline(cc.c4b(78,35,2,255),2)
    des1:setFontName(UIUtils.ttfName)

	local des2 = self:getUI("bg.layer.desBg2.des")
	des2:setColor(cc.c3b(248, 235, 84))
	des2:enable2Color(1,cc.c4b(230, 156, 6,255))
	des2:enableOutline(cc.c4b(78,35,2,255),2)
    des2:setFontName(UIUtils.ttfName)

    self._heroImg = self:getUI("bg.layer.heroImg")
    self._teamImg = self:getUI("bg.layer.teamImg")
    self._changeImg = self:getUI("bg.layer.changeImg")
    self._newImg = self:getUI("bg.layer.newImg")
    self._animNode = self:getUI("bg.layer.animNode")
    self._loadingImg = self:getUI("bg.layer.loadingImg")
    self._loadingImg:loadTexture("asset/uiother/dizuo/teamBgDizuo106.png")

    local clipNode = cc.ClippingNode:create()
    clipNode:setPosition(5,26)
    clipNode:setContentSize(cc.size(100, 100))
    local mask = cc.Sprite:createWithSpriteFrameName("globalPanelUI7_zhezhao.png")
    mask:setScaleX(2)
    mask:setScaleY(1.6)
    mask:setAnchorPoint(0.5,0)
    clipNode:setStencil(mask)
    clipNode:setAlphaThreshold(0.05)
    clipNode:setInverted(true)

    local mcAnim = mcMgr:createViewMC("jianzhuguangxiao_intancebuildingeffect-HD", true, false)   
    mcAnim:setPosition(1, 10)
    mcAnim:setScale(0.6)
    clipNode:addChild(mcAnim)
    self._animNode:addChild(clipNode, -1)

    self._frame = self:getUI("bg.frame")
    self._layer = self:getUI("bg.layer")
    self._bg    = self:getUI("bg")
    self._layer:setVisible(false)
    -- self._layer:setContentSize(cc.size(960,640))

end

function DialogTeamRecommandView:animBegin(callback)
    if not self.viewType then
        audioMgr:playSound("ItemGain_1")
    end
    local showXian 
    local bgW,bgH = self._bg:getContentSize().width,self._bg:getContentSize().height
    self:addPopViewTitleAnim(self._bg, "bingtuanguanlian_huodetitleanim", 480, 480)
    ScheduleMgr:delayCall(700, self, function( )
        if callback and self._layer then
            callback()
        end
        -- self._layer:setVisible(true)
    end)
end
-- 接收自定义消息
function DialogTeamRecommandView:reflashUI(data)
	-- self._frame:removeAllChildren()
    local heroData
    -- print("=======DialogTeamRecommandView========",data.heroId)
    if data.heroId then
        heroData = tab:Hero(data.heroId)
    end
    local changeData
    -- print("============DialogTeamRecommandView==============",data.changeId)
    if data.changeId then
        changeData = tab:Team(tonumber(data.changeId))
    end
    local teamData    
    if data.teamId then
        teamData = tab:Team(data.teamId)
    end
    if teamData and teamData.race then
        self._loadingImg:loadTexture("asset/uiother/dizuo/teamBgDizuo".. teamData.race[1] ..".png")
    end
    -- print("========***********===",data.heroId,data.changeId,data.teamId)
    local teams = data.teams or {}
    self._des:setString(lang(data.des) or "")
   
    if heroData and heroData.shero then
        self._heroImg:loadTexture("asset/uiother/shero/" .. heroData.shero .. ".png")
    end    
    -- if data.heroId == 60401 then -- 特做罗德哈特 位置下移
    --     self._heroImg:setPositionY(self._heroImg:getPositionY()-40)
    -- end
    if changeData and changeData.steam then
        -- print("=======changeData.steam============",changeData.steam)
        self._changeImg:loadTexture("asset/uiother/steam/" .. changeData.steam .. ".png")
    -- else
        -- self._viewMgr:showTip("表配置有问题，不能变身")
    end
    if teamData and teamData.steam then
        self._teamImg:loadTexture("asset/uiother/steam/" .. teamData.steam .. ".png")
    end

    local bg1Height = 200
    local maxHeight = self._frame:getContentSize().height
    self._frame:setOpacity(0)
    self:animBegin(function( )
        -- self._frame:setAnchorPoint(0.5,1)
        self._frame:setPositionX(1024)
        self._frame:setContentSize(cc.size(self.bgWidth,bg1Height))
        -- self._frame:setPositionX(480)
        dump(self._frame:getAnchorPoint())
        print(self._frame:getPositionX(),self._frame:getPositionY(),self._layer:getPositionX(),self._layer:getPositionY())
        self._frame:setOpacity(255)
        local sizeSchedule
        local step = 0.5
        local stepConst = 30
        -- self._frame:setPositionY(self._frame:getPositionY()+self._frame:)
        local sizeSchedule
        sizeSchedule = ScheduleMgr:regSchedule(1,self,function( )
            stepConst = stepConst-step
            if stepConst < 1 then 
                stepConst = 1
            end
            bg1Height = bg1Height+stepConst
            if bg1Height < maxHeight then
                self._frame:setContentSize(cc.size(self.bgWidth,bg1Height))
            else
                self._frame:setContentSize(cc.size(self.bgWidth,maxHeight))
                self._frame:runAction(cc.Sequence:create(cc.ScaleTo:create(0.05,1,1.05),cc.ScaleTo:create(0.1,1,1)))
                ScheduleMgr:unregSchedule(sizeSchedule)
                self:addDecorateCorner()
                self._layer:setVisible(true)
            end
        end)
    end)

end

function DialogTeamRecommandView:getMaskOpacity()
    return 230
end

return DialogTeamRecommandView