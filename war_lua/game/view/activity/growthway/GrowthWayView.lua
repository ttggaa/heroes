--[[
    @FileName   GrowthWayView.lua
    @Authors    cuiyake
    @Date       2018-05-22 21:21:18
    @Email      <cuiyake@playcrad.com>
    @Description   成长之路
--]]
require ("game.view.activity.growthway.GrowthWayConst")

local GrowthWayView = class("GrowthWayView",BasePopView)
function GrowthWayView:ctor(param)
    GrowthWayView.super.ctor(self)
    self._callback = param.callback
    self._growthModel = self._modelMgr:getModel("GrowthWayModel")
    self._currentIndex = GrowthWayConst.Page[1]
    self._growthData = self._growthModel:getData()
    
end

-- 初始化UI后会调用, 有需要请覆盖
function GrowthWayView:onInit()
    self._bg = self:getUI("bg")
    self._Panel1 = self:getUI("bg.Panel1")
    self._Panel2 = self:getUI("bg.Panel2")
    self._animPanel1 = self:getUI("bg.Panel1.animPanel")
    self._animPanel2 = self:getUI("bg.Panel2.animPanel")


    local closeBtn1 = self._Panel1:getChildByFullName("closeBtn")
    self:registerClickEvent(closeBtn1, function ( )
        if self._callback then
            self._callback()
        end
        self:close(true)
        UIUtils:reloadLuaFile("activity.growthway.GrowthWayView")
    end)

    self._growthBtn = self._Panel1:getChildByFullName("growthBtn")
    self:registerClickEvent(self._growthBtn, function ( )
        self._Panel1:setVisible(false)
        self._Panel2:setVisible(true)

        if self._animPanel2._chenzhangzhilu2 ~= nil then
            self._animPanel2._chenzhangzhilu2:removeFromParent()
            self._animPanel2._chenzhangzhilu2 = nil
        end
        local chenzhangzhilu2 = mcMgr:createViewMC("chengzhangzhilu2_chengzhangzhilu2", true,false,function( _,sender )
            sender:gotoAndPlay(30)
        end)
        local mcContentSize = self._animPanel2:getContentSize()
        chenzhangzhilu2:setPosition(mcContentSize.width / 2,mcContentSize.height / 2)
        self._animPanel2._chenzhangzhilu2 = chenzhangzhilu2
        self._animPanel2:addChild(chenzhangzhilu2)

    end)
    -- 查看完之后的分享按钮页面
    local closeBtn2 = self._Panel2:getChildByFullName("closeBtn")
    self:registerClickEvent(closeBtn2, function ( )
        if self._callback then
            self._callback()
        end
        self:close(true)
        UIUtils:reloadLuaFile("activity.growthway.GrowthWayView")
    end)
    
    self._btnPanel = self._Panel1:getChildByFullName("btnPanel")
    local continueBtn = self._btnPanel:getChildByFullName("continueBtn")
    self:registerClickEvent(continueBtn, function ( )
        self._Panel1:setVisible(false)
        self._Panel2:setVisible(true)
        self._currentIndex = GrowthWayConst.Page[1]
        self:updateDesText()
    end)

    local knowBtn = self._btnPanel:getChildByFullName("knowBtn")
    self:registerClickEvent(knowBtn, function ( )
        if self._callback then
            self._callback()
        end
        self:close(true)
        UIUtils:reloadLuaFile("activity.growthway.GrowthWayView")
    end)

    local shareBtn = self._btnPanel:getChildByFullName("shareBtn")
    self:registerClickEvent(shareBtn, function ( )
        self._viewMgr:showDialog("share.ShareBaseView", {moduleName = "ShareGrowthWayModule"})
    end)

    self._shareBtn2 =  self:getUI("bg.Panel2.shareBtn2")
    self:registerClickEvent(self._shareBtn2, function ( )
        self._viewMgr:showDialog("share.ShareBaseView", {moduleName = "ShareGrowthWayModule"})
    end)

    --点击成长之路显示第二个页面
    self._rolepic = self._Panel2:getChildByFullName("rolepic")
    self._leftBtn = self._Panel2:getChildByFullName("leftBtn")
    self:registerClickEvent(self._leftBtn, function ( )
        self:previousPage()
    end)
    self._rightBtn = self._Panel2:getChildByFullName("rightBtn")
    self:registerClickEvent(self._rightBtn, function ( )
        self:nextPage()
    end)

    self._getedImg = self._Panel2:getChildByFullName("getedimg")
    self._getawardBtn = self._Panel2:getChildByFullName("getawardBtn")

    self:registerClickEvent(self._getawardBtn, function ( )
        self._serverMgr:sendMsg("RoadOfGrowthServer", "getRoadOfGrowthReward", {}, true, {}, function(result, success) 
            --dump(result,"------resultre-----------")
            if result["reward"] ~= nil then
                DialogUtils.showGiftGet( {gifts = result["reward"],callback = function ( )
                    self._Panel1:setVisible(true)
                    self._Panel2:setVisible(false)
                    self._growthBtn:setVisible(false)
                    self._btnPanel:setVisible(true)
                    self._modelMgr:getModel("GrowthWayModel"):setAwardStatus(true) 
                    self:updateAwardBtn()

                end})
            end 
        end)
    end)



    local chenzhangzhilu1 = mcMgr:createViewMC("chengzhangzhilu1_chengzhangzhilu1", true,false,function( _,sender )
        sender:gotoAndPlay(20)
    end)
    local mcContentSize = self._animPanel1:getContentSize()
    chenzhangzhilu1:setPosition(mcContentSize.width / 2,mcContentSize.height / 2)
    self._animPanel1:addChild(chenzhangzhilu1)
    
    self:updateDesText()
end

function GrowthWayView:updateAwardBtn()
    local isShow = self._currentIndex == GrowthWayConst.Page[7] and true or false
    local awardStatus = self._modelMgr:getModel("GrowthWayModel"):getAwardStatus() 
    self._getawardBtn:setVisible(not awardStatus and isShow)
    self._getedImg:setVisible(awardStatus and isShow)
    self._shareBtn2:setVisible(awardStatus and isShow)
    -- UIUtils:setGray(self._getawardBtn,awardStatus)
    -- if awardStatus then
    --     self._getawardBtn:setTitleText("已领取")
    -- else
    --     self._getawardBtn:setTitleText("立即领取")    
    -- end
end

function GrowthWayView:updateDesText()
    if self._desTxt then
        self._desTxt:removeFromParent()
        self._desTxt = nil
    end
       
    local rtxStr = self._growthModel:getPageDataByIndex(self._currentIndex) 
    self._desTxt = RichTextFactory:create(rtxStr,300,100)
    self._desTxt:formatText()
    self._desTxt:setVerticalSpace(3)
    self._desTxt:setName("desTxt")
    self._desTxt:setAnchorPoint(cc.p(0.5,0.5))
    self._desTxt:setPosition(575,400)
    self._Panel2:addChild(self._desTxt,3)

    self._getawardBtn:setVisible(self._currentIndex == table.nums(GrowthWayConst.Page))
    self._leftBtn:setEnabled(self._currentIndex ~= GrowthWayConst.Page[1])
    self._rightBtn:setEnabled(self._currentIndex ~= table.nums(GrowthWayConst.Page))
    UIUtils:setGray(self._leftBtn,self._currentIndex == GrowthWayConst.Page[1])
    UIUtils:setGray(self._rightBtn,self._currentIndex == table.nums(GrowthWayConst.Page))

    
    local picName = GrowthWayConst.PagePictures[self._currentIndex][1]
    self._rolepic:setScale(GrowthWayConst.PagePictures[self._currentIndex][2])
    self._rolepic:setFlippedX(GrowthWayConst.PagePictures[self._currentIndex][3])
    local posX,posY = GrowthWayConst.PagePictures[self._currentIndex][4]["x"],GrowthWayConst.PagePictures[self._currentIndex][4]["y"]
    -- posX = 900
    -- posY = 335
    self._rolepic:setPosition(posX,posY)
    local sfc = cc.SpriteFrameCache:getInstance()
    if not sfc:getSpriteFrameByName(picName) then
        self._rolepic:loadTexture(picName)
    else
        self._rolepic:loadTexture(picName,1)
    end

    if self._currentIndex == GrowthWayConst.Page[2] then
        local arenaHeroId = self._growthData.arenaHero
        if arenaHeroId and arenaHeroId ~= "" then
           local campId = tab.hero[tonumber(arenaHeroId)]["masterytype"]
           if GrowthWayConst.HeroCamp[campId] then
               local campPicName = GrowthWayConst.HeroCamp[campId][2]
               self._rolepic:loadTexture(campPicName)
               self._rolepic:setScale(GrowthWayConst.HeroCamp[campId][3])
               self._rolepic:setFlippedX(GrowthWayConst.HeroCamp[campId][4])
               local campposX,campposY = GrowthWayConst.HeroCamp[campId][5]["x"],GrowthWayConst.HeroCamp[campId][5]["y"]
               self._rolepic:setPosition(campposX,campposY)
           end
          
        end
    end

    if self._currentIndex == GrowthWayConst.Page[5] then
        local frist15LvTeamId = self._growthData.frist15LvTeamId
        if frist15LvTeamId and frist15LvTeamId ~= "" then
           if GrowthWayConst.First15Team[tonumber(frist15LvTeamId)] then
               local campPicName = tab.team[tonumber(frist15LvTeamId)]["steam"]
               campPicName = "asset/uiother/steam/" .. campPicName .. ".png"
               self._rolepic:loadTexture(campPicName)
               self._rolepic:setScale(GrowthWayConst.First15Team[tonumber(frist15LvTeamId)][1])
               self._rolepic:setFlippedX(GrowthWayConst.First15Team[tonumber(frist15LvTeamId)][2])
               local teamposX,teamposY = GrowthWayConst.First15Team[tonumber(frist15LvTeamId)][3]["x"],GrowthWayConst.First15Team[tonumber(frist15LvTeamId)][3]["y"]
               self._rolepic:setPosition(teamposX,teamposY)
           end
        end
    end

    --刷新已领取图片
    self:updateAwardBtn()

end

-- 第一次进入调用, 有需要请覆盖
function GrowthWayView:onShow()
    self._viewMgr:enableScreenWidthBar()
end

function GrowthWayView:onHide()
    self._viewMgr:disableScreenWidthBar()
end

function GrowthWayView:onDestroy()
    self._viewMgr:disableScreenWidthBar()
end

-- 第一次被加到父节点时候调用
function GrowthWayView:onAdd()

end

function GrowthWayView:onTop()
end

-- 接收自定义消息
function GrowthWayView:reflashUI(data)

end
function GrowthWayView:getAsyncRes()
    return 
    {
        {"asset/ui/growthway.plist", "asset/ui/growthway.png"},
    }
end
function GrowthWayView:previousPage()
    self._currentIndex = self._currentIndex - 1
    self:updateDesText()
end
function GrowthWayView:nextPage()
    self._currentIndex = self._currentIndex + 1
    self:updateDesText()
end


return GrowthWayView