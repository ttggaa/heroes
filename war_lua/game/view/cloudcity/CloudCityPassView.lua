--
-- Author: <ligen@playcrab.com>
-- Date: 2016-10-27 15:36:03
--
local CloudCityPassView = class("CloudCityPassView", BasePopView)

function CloudCityPassView:ctor(data)
    CloudCityPassView.super.ctor(self)

    self._passCount = data.passCount
    self._viewType = data.viewType or 1
    self._param = data.param
    self._callBack = data.callBack
end

function CloudCityPassView:getMaskOpacity()
    return 229
end

function CloudCityPassView:onInit()
    self:registerClickEventByName("bg", function()
        self:getUI("bg"):setTouchEnabled(false)
        if self._callBack ~= nil then
            self._callBack()
        end
        self._modelMgr:getModel("GuildRedModel"):checkRandRed()
        self:close()
        UIUtils:reloadLuaFile("cloudcity.CloudCityPassView")
    end )

    self._layer = self:getUI("bg.layer")

    self._nodeUp = self:getUI("bg.layer.nodeUp")
    self._nodeDown = self:getUI("bg.layer.nodeDown")
    self._spineNode = self:getUI("bg.layer.spineNode")

    self._nodeUp:setVisible(false)
    self._nodeDown:setVisible(false)

    self._rewardTitle = self._nodeDown:getChildByFullName("titleLabel")
    self._rewardTitle:setColor(cc.c3b(0, 0, 0))
    self._rewardTitle:setFontName(UIUtils.ttfName)  


    if self["updateView" .. self._viewType] ~= nil then 
        self["updateView" .. self._viewType](self)
    end


    self._passMc = mcMgr:createViewMC("gongxitongguan_qianjin", false)
    self._passMc:setPosition(640, 435)
    self._passMc:gotoAndStop(1) 
    self._layer:addChild(self._passMc)

    spineMgr:createSpine("xinshouyindao", function (spine)
        -- spine:setVisible(false)
        spine.endCallback = function ()
            spine:setAnimation(0, "pingdan", true)
        end 
        local anim = "pingdan"
        spine:setAnimation(0, anim, true)
        spine:setPosition(0, 0)
        spine:setScale(1)
        self._spineNode:addChild(spine)
    end)
    self._spineNode:setVisible(false)

    local flowerMc = mcMgr:createViewMC("piaoluocaidai_leaguejinjiechenggong", true, false)
    flowerMc:setPosition(450,600)
    self._layer:addChild(flowerMc)
end


function CloudCityPassView:updateView1()
    self._desLabel1 = self._nodeUp:getChildByFullName("desLabel1")
    self._desLabel1:setFontName(UIUtils.ttfName)
    self._desLabel1:setColor(cc.c3b(254, 235, 177))
    self._desLabel2 = self._nodeUp:getChildByFullName("desLabel2")
    self._desLabel2:setFontName(UIUtils.ttfName)
    self._desLabel2:setColor(cc.c3b(254, 235, 177))
    self._desLabel3 = self._nodeUp:getChildByFullName("desLabel3")
    self._desLabel3:setFontName(UIUtils.ttfName)
    self._desLabel3:setColor(cc.c3b(254, 235, 177))

    self._rewardTitle = self._nodeDown:getChildByFullName("titleLabel")
    self._rewardTitle:setColor(cc.c3b(0, 0, 0))
    self._rewardTitle:setFontName(UIUtils.ttfName)

    self._desLabel = self._nodeDown:getChildByFullName("desLabel")
    self._desLabel:setColor(cc.c3b(254, 235, 177))
    self._desLabel:setString("下一关有更好的奖励呦~")

    local countLabel = self._rewardTitle:clone()
    countLabel:setFontName(UIUtils.ttfName)
    countLabel:setString(tostring(self._passCount))
    countLabel:setColor(cc.c3b(255, 218, 71))
    countLabel:setFontSize(52)
    countLabel:setAnchorPoint(0, 0.5)
    self._nodeUp:addChild(countLabel)

    local lOffsetX = -(self._desLabel1:getContentSize().width + self._desLabel2:getContentSize().width + countLabel:getContentSize().width + 4 - 346) / 2
    self._desLabel1:setPositionX(self._desLabel1:getPositionX() + lOffsetX)
    countLabel:setPosition(self._desLabel1:getPositionX() + self._desLabel1:getContentSize().width / 2 + 2, self._desLabel1:getPositionY() + 3)
    self._desLabel2:setPositionX(countLabel:getPositionX() + countLabel:getContentSize().width + self._desLabel2:getContentSize().width / 2 + 2)


    local rewardData = self._modelMgr:getModel("CloudCityModel"):getRewardData()
    if rewardData ~= nil and next(rewardData) ~= nil then
        rewards = {}
        for _,v in pairs(rewardData) do
            table.insert(rewards, v)
        end
        local itemCount = table.nums(rewards)
        local inv = 100
        local beginX = 79
        for i = 1, itemCount do
            local item
            local itemId
            local isEffect = true
            if rewards[i] then
                itemId = rewards[i]["typeId"] or rewards[i][2]
                if itemId == 0 then
                    itemId = IconUtils.iconIdMap[rewards[i]["type"] or rewards[i][1]]
                end
                if tonumber(itemId) >= 3100 and tonumber(itemId) <= 4000 then
                    isEffect = false
                end
                item = IconUtils:createItemIconById( { itemId = itemId, num = rewards[i]["num"] or rewards[i][3], itemData = tab:Tool(rewards[i]["typeId"] or rewards[i][2]), effect = isEffect, isBranchDrop = true })
                item:setScale(82 / item:getContentSize().width)

                local mc1 = mcMgr:createViewMC("wupinguang_itemeffectcollection", true)
                mc1:setPosition(item:getContentSize().width / 2, item:getContentSize().height / 2)
                item:addChild(mc1, 9)

                item:setAnchorPoint(0.5, 0.5)
                item:setPosition(beginX +(i - 1) * inv, inv / 2 + 4)
                self._nodeDown:addChild(item)
            end
        end
    end
end


function CloudCityPassView:updateView2()
    self._nodeUp:removeAllChildren()

    local children = self._nodeDown:getChildren()
    for k,v in pairs(children) do
        if v:getName() ~= "Image_24" and v:getName() ~= "titleLabel" then 
            v:removeFromParent()
        end
    end

    local nodes = {}
    if self._param.newLevel > self._param.oldLevel then
        nodes[1] = cc.Label:createWithTTF("您首次获得了", UIUtils.ttfName, 24)
    else
        nodes[1] = cc.Label:createWithTTF("您再次获得了", UIUtils.ttfName, 24)

    end

    nodes[1]:setColor(cc.c3b(254, 235, 177))

    nodes[2] = cc.Sprite:createWithSpriteFrameName("intanceImage_heroAttr" .. self._param.newLevel .. ".png")

    nodes[3] = cc.Label:createWithTTF("级评价", UIUtils.ttfName, 24)
    nodes[3]:setColor(cc.c3b(254, 235, 177))

    local node = UIUtils:createHorizontalNode(nodes)
    node:setAnchorPoint(0.5, 0.5)
    node:setPosition(self._nodeUp:getContentSize().width * 0.5, self._nodeUp:getContentSize().height * 0.5)
    self._nodeUp:addChild(node)

    
    local rewardBg = self._nodeDown:getChildByName("Image_24")

    local height = rewardBg:getContentSize().height + 28 * (self._param.newLevel - self._param.oldLevel - 1)
    rewardBg:setContentSize(self._nodeDown:getContentSize().width, height)
    rewardBg:setPosition(rewardBg:getPositionX(), rewardBg:getPositionY() - (28 * (self._param.newLevel - self._param.oldLevel - 1) * 0.5 ))
    
    local  showY  = height - 28 * (self._param.newLevel - self._param.oldLevel - 1) - 10
    if self._param.oldLevel == 3 then 
        showY = height - 28 * (self._param.newLevel - self._param.oldLevel - 1) - 20
    end
    local minLevel = 1
    if self._param.oldLevel > 0 then 
        minLevel = self._param.oldLevel + 1
    end
    local sysBranchHeroAdd = tab:BranchHeroAdd(self._param.branchId)
    local heroAttrPics = {[112] = "hero_tip_1.png", [115] = "hero_tip_2.png", [118] = "hero_tip_4.png", [121] = "hero_tip_3.png" }
    for i=minLevel, self._param.newLevel do
        local reward = sysBranchHeroAdd["reward" .. i]
        if reward then 
            showY = showY - 35

            local nodes = {}
            nodes[1] = cc.Sprite:createWithSpriteFrameName(heroAttrPics[reward[1][1]])
            nodes[2] = cc.Label:createWithTTF(lang("ARTIFACTDES_PRO_" .. reward[1][1]), UIUtils.ttfName, 24)
            nodes[2]:setColor(cc.c3b(254, 235, 177))            
            nodes[3] = cc.Label:createWithTTF("+" .. reward[1][2], UIUtils.ttfName, 24)
            nodes[3]:setColor(cc.c3b(254, 235, 177))   

            local node = UIUtils:createHorizontalNode(nodes)
            node:setAnchorPoint(0.5, 1)
            node:setPosition(self._nodeDown:getContentSize().width * 0.5, showY)
            self._nodeDown:addChild(node)
        end
    end
    if self._param.newLevel <= self._param.oldLevel then
        self._nodeDown:setCascadeOpacityEnabled(true, true)
        self._nodeDown:setOpacity(0)
        local labTip = cc.Label:createWithTTF("继续努力可获得更高评价，再次增加属性哟~", UIUtils.ttfName, 24)
        labTip:setPosition(self._nodeUp:getContentSize().width * 0.5, - 30)
        labTip:setColor(cc.c3b(254, 235, 177))   
        self._nodeUp:addChild(labTip)
    end



end

function CloudCityPassView:onShow()
    self._nodeUp:setPositionX(self._nodeUp:getPositionX() - 50)
    self._nodeDown:setPositionY(self._nodeDown:getPositionY() - 80)
    self._spineNode:setPositionX(self._spineNode:getPositionX() - 100)

    self._spineNode:setVisible(true)
    self._spineNode:runAction(cc.Sequence:create(cc.MoveBy:create(0.2, cc.p(200, 0)), cc.CallFunc:create(function()
            self._passMc:gotoAndPlay(1)

            ScheduleMgr:delayCall(400, self, function()
                self._nodeUp:setVisible(true)

                self._nodeUp:runAction(cc.Sequence:create(cc.MoveBy:create(0.1, cc.p(60, 0)), cc.MoveBy:create(0.1, cc.p(-10, 0))))

                ScheduleMgr:delayCall(200, self, function()
                    self._nodeDown:setVisible(true)
                    self._nodeDown:runAction(cc.Sequence:create(
                        cc.MoveBy:create(0.1, cc.p(0, 90)), cc.CallFunc:create(function()
                            self._nodeUp:runAction(cc.Sequence:create(cc.MoveBy:create(0.1, cc.p(0, 10)), cc.MoveBy:create(0.1, cc.p(0, -10))))
                            self._nodeDown:runAction(cc.MoveBy:create(0.1, cc.p(0, -10)))
                            self:unlock()
                            if self._param and self._param.oldFight ~= nil then
                                self:runAction(cc.Sequence:create(cc.DelayTime:create(0.5), cc.CallFunc:create(function()
                                    -- 战斗力提示
                                    local posX, posY = self:getContentSize().width* 0.5 , self:getContentSize().height* 0.5
                                    TeamUtils:setFightAnim(self, {oldFight = self._param.oldFight, newFight = TeamUtils:updateFightNum(), x = posX, y = posY})
                                end)))
                            end
                        end)))
                end)
            end)
        end))) 
end

return CloudCityPassView