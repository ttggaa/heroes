--
-- Author: <ligen@playcrab.com>
-- Date: 2017-01-24 15:29:26
--
local HeroDuelSelectLayer = class("HeroDuelSelectLayer", BaseLayer)

function HeroDuelSelectLayer:ctor(data)
    HeroDuelSelectLayer.super.ctor(self)

    self._mainData = data.mainData
    self._selectedData = data.mainData["selected"]
    self._toSelectData = data.mainData["toSelect"]
    self._completeCallBack = data.callBack

    self._cardList = {}

    self._curSelectIndex = 2

    self._kCardNormalScale = 0.6
    self._kCardSelcetScale = 0.7
    self._kCardSmallScale = 0.56

    self._kCardStateList = {
        [1] = {posX = 284, posY = 350, scale = 0.56, bright = -50, opacity = 200},
        [2] = {posX = 497, posY = 350, scale = 0.7, bright = 0, opacity = 255},
        [3] = {posX = 710, posY = 350, scale = 0.56, bright = -50, opacity = 200}
    }

    self._kFlyPos = {
        [1] = {posX = MAX_SCREEN_WIDTH * 0.5 - 173, posY = 10},
        [2] = {posX = MAX_SCREEN_WIDTH * 0.5 - 109, posY = 10},
        [3] = {posX = MAX_SCREEN_WIDTH * 0.5 - 47, posY = 10},
        [4] = {posX = MAX_SCREEN_WIDTH * 0.5 + 19, posY = 10},
        [5] = {posX = MAX_SCREEN_WIDTH * 0.5 + 84, posY = 10},

        [100] = {posX = MAX_SCREEN_WIDTH * 0.5 + 177, posY = 10}
    }

    self._hModel = self._modelMgr:getModel("HeroDuelModel")
end

function HeroDuelSelectLayer:onInit()
    self._bg = self:getUI("bg")
    self:setSelfContentSize(1136, MAX_SCREEN_HEIGHT)

    self._layer = self._bg:getChildByFullName("layer")

    local bgTitle = self._bg:getChildByFullName("bgTitle")

    local titleLabel = bgTitle:getChildByFullName("titleLabel")
    titleLabel:setString("请选择你的卡牌")
    UIUtils:setTitleFormat(titleLabel, 1)

    local cardCountNode = self._bg:getChildByFullName("leftNode.cardCountNode")
    if MAX_SCREEN_WIDTH < 1136 then
        cardCountNode:setPositionX(0)
    end

    self._countNodePosY1 = cardCountNode:getChildByFullName("bg1"):getPositionY()
    self._countNodePosY2 = cardCountNode:getChildByFullName("bg2"):getPositionY()
    self._countNodePosY3 = cardCountNode:getChildByFullName("bg3"):getPositionY()

    self._curBorder = cardCountNode:getChildByFullName("selectBound")
    
    self._heroLabel1 = cardCountNode:getChildByFullName("heroLabel1")
    self._heroLabel2 = cardCountNode:getChildByFullName("heroLabel2")
    self._teamLabel = cardCountNode:getChildByFullName("teamLabel")
    self._heroLabel1:setColor(cc.c3b(73,58,42))
    self._heroLabel2:setColor(cc.c3b(73,58,42))
    self._teamLabel:setColor(cc.c3b(73,58,42))


    self._heroCount1 = cardCountNode:getChildByFullName("heroCount1")
    self._heroCount2 = cardCountNode:getChildByFullName("heroCount2")
    self._teamCount = cardCountNode:getChildByFullName("teamCount")
    self._heroCount1:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 2)
    self._heroCount2:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 2)
    self._teamCount:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 2)

    self:updateCountNode()

    if self._toSelectData then
        local cellIndex = 0
        for k, v in pairs(self._toSelectData) do
            local cardCell = self:createCard(v)
            cardCell.id = v
            cellIndex = cellIndex + 1
            cardCell.index = cellIndex
            cardCell:setScale(self._kCardNormalScale)
            cardCell.pos = cellIndex
            table.insert(self._cardList, cardCell)

            self:registerClickEvent(cardCell, function()
                self:clickCell(cardCell.index)
            end)
        end
    end

    self._confirmBtn = self:getUI("bg.layer.confirmBtn")
    self:registerClickEvent(self._confirmBtn,function()
        self:onConfirm()
    end)
end

function HeroDuelSelectLayer:createCard(id)
    local cardCell = nil
    if self._hModel:isHeroOrTeam(id) == "HERO" then
        cardCell = CardUtils:createHeroDuelHeroCard({heroD = tab:Hero(id)})
    else
        local teamD = tab:Team(id)
        cardCell = CardUtils:createHeroDuelTeamCard({
             teamD = teamD, 
             borderTp = CardUtils.kHeroDuelCardBorder, 
             isAwaking = self._hModel:isTeamJx(id)
        })
        if teamD.zizhi == 3 then
            local fireMc = mcMgr:createViewMC("zizhi15_gezhongdun", true, false)
            fireMc:setName("fireMc")
            fireMc:setScale(1.5)
            fireMc:setPosition(142,96)
            fireMc:setCascadeOpacityEnabled(true)
            cardCell:addChild(fireMc, -1)
        end
    end

    local detailBtn = ccui.ImageView:create("globalBtnUI_preViewBtn.png", 1)
    detailBtn:setScaleAnim(true)
    detailBtn:setScale(0.8)
    detailBtn:setAnchorPoint(0.5, 0.5)
    detailBtn:setPosition(214, 62)
    cardCell:addChild(detailBtn)

    self:registerClickEvent(detailBtn,specialize(self.onDetail, self))
    return cardCell
end

function HeroDuelSelectLayer:onDetail(sender)
    local id = sender:getParent().id
    local detailType = nil
    local NewFormationIconView = require "game.view.formation.NewFormationIconView"
    if self._hModel:isHeroOrTeam(id) == "HERO" then
        detailType = NewFormationIconView.kIconTypeHero
    else
        detailType = NewFormationIconView.kIconTypeTeam
    end

    local param = {
        isCustom = true, 
        iconType = detailType, 
        iconId = id,
        formationType = self._modelMgr:getModel("FormationModel").kFormationTypeHeroDuel
    }
    self._viewMgr:getInstance():showDialog("formation.NewFormationDescriptionView", param, true)
end


function HeroDuelSelectLayer:updateCard(cell, id)
    if self._hModel:isHeroOrTeam(id) == "HERO" then
        CardUtils:updateHeroDuelHeroCard(cell, {heroD = tab:Hero(id)})
    else
        local teamD = tab:Team(id)
        if teamD.zizhi ~= 3 and cell:getChildByName("fireMc") then
            cell:removeChildByName("fireMc")
        end
        if teamD.zizhi == 3 and cell:getChildByName("fireMc") == nil then
            local fireMc = mcMgr:createViewMC("zizhi15_gezhongdun", true, false)
            fireMc:setName("fireMc")
            fireMc:setScale(1.5)
            fireMc:setPosition(142,96)
            fireMc:setCascadeOpacityEnabled(true)
            cell:addChild(fireMc, -1)
        end

        CardUtils:updateHeroDuelTeamCard(
            cell, 
            {teamD = tab:Team(id),isAwaking = self._hModel:isTeamJx(id)}
        )
    end
end

-- 更新记牌板
function HeroDuelSelectLayer:updateCountNode()
    local hasSelectHero1 = 0
    local hasSelectHero2 = 0
    local hasSelectTeam = 0
    if self._selectedData ~= nil then
        if self._selectedData.heros ~= nil then
            if #self._selectedData.heros == 1 then
                hasSelectHero1 = 1
            elseif #self._selectedData.heros == 2 then
                hasSelectHero1 = 1
                hasSelectHero2 = 1
            end
        end

        if self._selectedData.teams ~= nil then
            for k, v in pairs(self._selectedData.teams) do
                hasSelectTeam = hasSelectTeam + 1
            end
        end
    end

    self._heroCount1:setString(hasSelectHero1 .. "/1")
    self._heroCount2:setString(hasSelectHero2 .. "/1")
    self._teamCount:setString(hasSelectTeam .. "/16")

    if hasSelectHero1 == 0 then
        self._curBorder:setPositionY(self._countNodePosY1)

        self._heroLabel1:setColor(cc.c3b(173,159,106))
        self._teamLabel:setColor(cc.c3b(73,58,42))
        self._heroLabel2:setColor(cc.c3b(73,58,42))

    elseif hasSelectTeam < 16 then
        self._curBorder:setPositionY(self._countNodePosY2)

        self._heroLabel1:setColor(cc.c3b(73,58,42))
        self._teamLabel:setColor(cc.c3b(173,159,106))
        self._heroLabel2:setColor(cc.c3b(73,58,42))
    else
        self._curBorder:setPositionY(self._countNodePosY3)

        self._heroLabel1:setColor(cc.c3b(73,58,42))
        self._teamLabel:setColor(cc.c3b(73,58,42))
        self._heroLabel2:setColor(cc.c3b(173,159,106))
    end

end

function HeroDuelSelectLayer:clickCell(index)
    if index == self._curSelectIndex or self._lockClick then return end

    self:hideSelectMc()

    local cardsMoveComplete = function()
        self:showSelectMc()
    end

    local clickCell = self._cardList[index]
    local clickCellPos = clickCell.pos
    for i = 1, #self._cardList do
        local moveToPos = nil
        if clickCellPos == 1 then
            moveToPos = (self._cardList[i].pos + 1) % 3
            moveToPos = moveToPos == 0 and 3 or moveToPos
        elseif clickCellPos == 3 then
            moveToPos = self._cardList[i].pos - 1
            moveToPos = moveToPos == 0 and 3 or moveToPos
        end
        self._cardList[i].pos = moveToPos
        self._cardList[i]:getParent():reorderChild(self._cardList[i], moveToPos == 2 and 2 or 1)
        local posState = self._kCardStateList[moveToPos]
        self._cardList[i]:stopAllActions()
        self._cardList[i]:runAction(cc.Sequence:create(
            cc.Spawn:create(
                cc.EaseOut:create(cc.MoveTo:create(0.2, cc.p(posState.posX, posState.posY)),3),
                cc.EaseOut:create(cc.ScaleTo:create(0.2, posState.scale),3),
                cc.CallFunc:create(function()
                    self._cardList[i]:setBrightness(posState.bright)
                    self._cardList[i]:setOpacity(posState.opacity)
                end)
            ),
            cc.CallFunc:create(cardsMoveComplete)
        ))
    end

    self._curSelectIndex = index
end

function HeroDuelSelectLayer:onConfirm()
    self._confirmBtn:setVisible(false)
    self._lockClick = true
    local param = {id = self._cardList[self._curSelectIndex].id}

    self._serverMgr:sendMsg("HeroDuelServer", "hDuelSelectCards", param, true, {}, function(result)
        self._hModel:addCardsInfo(result.id)
        self._selectedData = self._hModel:getCardsInfo()
        self:updateCountNode()

        dump(result)
        self:hideSelectMc()
        self:cardFly(result)
    end)
end

-- 选中后飞出
function HeroDuelSelectLayer:cardFly(result)
    for i = 1, #self._cardList do
        local cardCell = self._cardList[i]
        if cardCell.pos == 2 then
            
            local worldPos = {}
            if self._hModel:isHeroOrTeam(cardCell.id) == "HERO" then
                worldPos = self._kFlyPos[100]
            else
                local teamD = tab:Team(cardCell.id) 
                worldPos = self._kFlyPos[teamD.class]
            end

            local flyPos = self._layer:convertToNodeSpace(cc.p(worldPos.posX, worldPos.posY))

            cardCell:runAction(cc.Sequence:create(
                cc.Spawn:create(cc.MoveTo:create(0.2, flyPos), cc.ScaleTo:create(0.2, 0)),
                cc.CallFunc:create(function()
                    self:doAfterSelect(result)
                end)
            ))
            break
        end
    end
end

-- 刷新卡牌
function HeroDuelSelectLayer:doAfterSelect(data)
    if data.fin == 0 then
        for i = 1, #data.toSelect do
            local newIdLen = string.len(tostring(data.toSelect[i]))
            local oldIdLen = string.len(tostring(self._cardList[i].id))

            -- 判断两轮抽卡是否同为兵团
            if newIdLen == oldIdLen then
                self:updateCard(self._cardList[i], data.toSelect[i])
            else
                local cardCell = self:createCard(data.toSelect[i])
                cardCell.id = data.toSelect[i]
                cardCell.index = i
                self._cardList[i]:removeFromParent(true)
                self:registerClickEvent(cardCell, function()
                    self:clickCell(cardCell.index)
                end)
                self._cardList[i] = cardCell
            end


            self._cardList[i]:setScale(self._kCardNormalScale)
            self._cardList[i].pos = i
            self._cardList[i].id = data.toSelect[i]

            self._cardList[i]:stopAllActions()
        end

        self._curSelectIndex = 2
        self:showCards()

    elseif data.fin == 1 then
        self._hModel:updateHeroDuelData({status = 2})
        self._viewMgr:showDialog("heroduel.HeroDuelCardFinishView")
        self._completeCallBack()
    end
end

-- 卡牌出现动画
function HeroDuelSelectLayer:showCards()
    for i = 1, #self._cardList do
        local cardCell = self._cardList[i]
        cardCell:setPosition(self._kCardStateList[i].posX, self._kCardStateList[i].posY + 250)
        cardCell:setOpacity(0)
        cardCell:setCascadeOpacityEnabled(true)
        if cardCell:getParent() == nil then
            self._layer:addChild(cardCell)
        end

        cardCell:runAction(cc.Sequence:create(
            cc.DelayTime:create(i * 0.05),
            cc.Spawn:create(
                cc.EaseOut:create(cc.MoveBy:create(0.2, cc.p(0, -260)),3),
                cc.FadeIn:create(0.1)
            ),
            cc.MoveBy:create(0.1, cc.p(0, 10)),
            cc.CallFunc:create(function()
                local scaleParam = nil
                if i == self._curSelectIndex then
                    scaleParam = self._kCardSelcetScale
                else
                    scaleParam = self._kCardSmallScale
                end
                cardCell:runAction(cc.EaseIn:create(cc.ScaleTo:create(0.2, scaleParam),3))
                cardCell:setBrightness(self._kCardStateList[i].bright)
                cardCell:setOpacity(self._kCardStateList[i].opacity)
            end)
        ))

        self._confirmBtn:runAction(cc.Sequence:create(
            cc.DelayTime:create(0.7),
            cc.CallFunc:create(function()
                self._confirmBtn:setVisible(true)
                self._lockClick = false
                self:showSelectMc()
            end)
        ))
    end
end

function HeroDuelSelectLayer:showSelectMc()
    if self._selectMc ~= nil then
        self._selectMc:setVisible(true)
        return
    end
    self._selectMc = mcMgr:createViewMC("xuanzhongkuang_duizhanui", true, false)
    self._selectMc:setScale(0.77)
    self._selectMc:setPosition(497, 348)
    self._selectMc:setCascadeOpacityEnabled(true)
    self._layer:addChild(self._selectMc, -1)
end

function HeroDuelSelectLayer:hideSelectMc()
    if self._selectMc ~= nil then
        self._selectMc:setVisible(false)
    end
end

function HeroDuelSelectLayer:onShow()
    self:showCards()

end

function HeroDuelSelectLayer:onTop()
end

-- 交锋关闭
function HeroDuelSelectLayer:onHDuelClose()

end

-- 交锋开启
function HeroDuelSelectLayer:onHDuelOpen()


end
return HeroDuelSelectLayer