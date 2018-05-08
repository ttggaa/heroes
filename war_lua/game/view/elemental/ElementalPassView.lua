--[[
    @FileName   ElementalPassView.lua
    @Authors    zhangtao
    @Date       2017-08-21 12:01:47
    @Email      <zhangtao@playcrad.com>
    @Description   通关奖励
--]]
local ElementalPassView = class("ElementalPassView", BasePopView)

function ElementalPassView:ctor(data)
    ElementalPassView.super.ctor(self)
    -- self._passCount = data.passCount
    self._param = data.param
    self._callBack = data.callBack
    self._allCross = data.allCross
end

function ElementalPassView:getMaskOpacity()
    return 229
end

function ElementalPassView:onInit()
    self:registerClickEventByName("bg", function()
        self:getUI("bg"):setTouchEnabled(false)
        if self._callBack ~= nil then
            self._callBack()
        end
        self:close()
        UIUtils:reloadLuaFile("elemental.ElementalPassView")
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

    local touchPannel = self._nodeDown:getChildByFullName("Image_24")
    registerClickEvent(touchPannel,function()
    end)

    self:updateView()


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


function ElementalPassView:updateView()
    local resultData = self._modelMgr:getModel("ElementModel"):getCrossData()
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
    self._desLabel:setVisible(not self._allCross)

    local countLabel = self._rewardTitle:clone()
    countLabel:setFontName(UIUtils.ttfName)
    countLabel:setString(tostring(resultData["totalPass"]))
    countLabel:setColor(cc.c3b(255, 218, 71))
    countLabel:setFontSize(52)
    countLabel:setAnchorPoint(0, 0.5)
    self._nodeUp:addChild(countLabel)

    local lOffsetX = -(self._desLabel1:getContentSize().width + self._desLabel2:getContentSize().width + countLabel:getContentSize().width + 4 - 346) / 2
    self._desLabel1:setPositionX(self._desLabel1:getPositionX() + lOffsetX)
    countLabel:setPosition(self._desLabel1:getPositionX() + self._desLabel1:getContentSize().width / 2 + 2, self._desLabel1:getPositionY() + 3)
    self._desLabel2:setPositionX(countLabel:getPositionX() + countLabel:getContentSize().width + self._desLabel2:getContentSize().width / 2 + 2)

    local rewardData = resultData["reward"]
    dump(rewardData)
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

function ElementalPassView:onShow()
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

return ElementalPassView