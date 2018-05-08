--
-- Author: <wangguojun@playcrab.com>
-- Date: 2017-01-20 15:03:55
--
local mcMgr = mcMgr
local ShoutBox = class("ShoutBox", BaseLayer)
local _3dVertex1 = cc.Vertex3F(26, 0, 0)
local red = cc.c3b(162, 13, 20)
local blue = cc.c3b(0, 107, 189)
local black = cc.c4b(0, 0, 0, 255)
local brown = cc.c3b(70, 40, 10)

function ShoutBox:ctor(params)
    ShoutBox.super.ctor(self)
    params = params or {}
    self._selfNode  =  params.selfNode and params.selfNode()
    self._getSelfNodeFunc = params.selfNode and params.selfNode
    self._rivalNode =  params.rivalNode
    self._maxTime   =  params.maxTime
    self._selfPos   =  params.selfPos
    self._rivalPos   =  params.rivalPos
end

function ShoutBox:onInit()
    self._chatBtn        = self:getUI("bg.chatBtn")
    self._chatBtn.circle = self:getUI("bg.chatCircle")
    self._chatBtn.btn1   = self:getUI("bg.chatCircle.btn1")
    self._chatBtn.btn2   = self:getUI("bg.chatCircle.btn2")
    self._chatBtn.btn3   = self:getUI("bg.chatCircle.btn3")
    self._chatBtn.btn4   = self:getUI("bg.chatCircle.btn4")
    self._chatBtn.circle:setScale(0)
    local titles = {"吹牛","问候","不服","调侃"}
    for i = 1, 4 do
        self._chatBtn["btn"..i].idx = i
        self._chatBtn["btn"..i]:setTitleText(titles[i])
        self._chatBtn["btn"..i]:setTitleFontSize(18)
        self._chatBtn["btn"..i]:getTitleRenderer():enableOutline(cc.c4b(124, 64, 0, 255), 2)
    end
    -- self._chatBtn:setVisible(false)
    self:registerClickEvent(self._chatBtn, specialize(self.onChatBtnClicked, self))

    self:registerClickEvent(self._chatBtn.btn1, specialize(self.onChatBtnClicked, self))
    self:registerClickEvent(self._chatBtn.btn2, specialize(self.onChatBtnClicked, self))
    self:registerClickEvent(self._chatBtn.btn3, specialize(self.onChatBtnClicked, self))
    self:registerClickEvent(self._chatBtn.btn4, specialize(self.onChatBtnClicked, self))

    -- 对方喊话逻辑
    self._rivalAITime = 0
    if self._rivalNode and not tolua.isnull(self._rivalNode) then
        self:runAction(cc.RepeatForever:create(
            cc.Sequence:create(
                cc.DelayTime:create(1),
                cc.CallFunc:create(function( )
                    self._rivalAITime = self._rivalAITime + 1
                    self:randRivalChat()
                end)
            )
        ))
    end
    self._widget:setSwallowTouches(false)
end

function ShoutBox:onChatBtnClicked(btn)
    if tolua.isnull(self._selfNode) and self._getSelfNodeFunc then self._selfNode = self._getSelfNodeFunc() end
	-- if not btn or not self._selfNode or not tolua.isnull(self._selfNode) then return end
    if btn.hadTouched then return end
    btn.hadTouched = true
    -- [[ 高亮
    local btnClone = btn:clone()
    btnClone:setTitleText("")
    btnClone:setPurityColor(255, 255, 255)
    btnClone:setVisible(false)
    btnClone:setPosition(btnClone:getContentSize().width/2,btnClone:getContentSize().height/2)
    btn:addChild(btnClone)
    btnClone:setOpacity(200)
    btnClone:runAction(cc.Sequence:create(
        -- cc.DelayTime:create(.01),
        cc.CallFunc:create(function( )
            btnClone:setVisible(true)
        end),
        cc.ScaleTo:create(0.01,1.1),
        cc.Spawn:create(
            cc.FadeOut:create(.05),
            cc.ScaleTo:create(0.05,1.12)
        ),
        cc.CallFunc:create(function( )
            btnClone:setOpacity(255)
            btnClone:removeFromParent()
        end)
    ))
    --]]
    local circle = self._chatBtn.circle
    if btn.idx then
        self:onChat(lang("CALL_BATTLE_0"..btn.idx.."_0"..GRandom(3)), 1, self._selfNode,false,self._selfPos)
        circle.extend = false
        circle:stopAllActions()
        circle:runAction(cc.Sequence:create(
            cc.ScaleTo:create(0.1, 0),
            cc.CallFunc:create(function( )
                btn.hadTouched = false
            end)
        ))
    else
        circle:stopAllActions()
        if circle.extend then
            circle:runAction(cc.Sequence:create(
                cc.ScaleTo:create(0.1, 0),
                cc.CallFunc:create(function( )
                    btn.hadTouched = false
                end)
            ))
        else
            circle:runAction(cc.Sequence:create(
                cc.ScaleTo:create(0.1, 1),
                cc.CallFunc:create(function( )
                    btn.hadTouched = false
                end)
            ))
        end
        circle.extend = not circle.extend
    end
end

function ShoutBox:onChat(msg, camp, shoutNode, clear, pos, color)
    if shoutNode == nil then return end
    if clear then
        if shoutNode._chatBg then
            shoutNode._chatBg:removeFromParent()
            shoutNode._chatBg = nil
        end
    end
    -- local camp = self._camp
    local chatBg, label
    local width1
    if clear or not shoutNode._chatBg then
        label = ccui.Text:create()
        label:setFontSize(16)
        label:setFontName(UIUtils.ttfName)
        label:setString(msg)
        label:getVirtualRenderer():setMaxLineWidth(136)
        --cc.Label:createWithTTF(msg, UIUtils.ttfName, 16)
        if color == nil then
            label:setColor(brown)
        elseif color == 1 then
            label:setColor(blue)
        else
            label:setColor(red)
        end
        chatBg = ccui.ImageView:create()
        chatBg:loadTexture("globalImageUI_shout_qipaobg.png",1)
        chatBg:setScale9Enabled(true)
        chatBg:setAnchorPoint(0.5,0)
        --cc.Scale9Sprite:createWithSpriteFrameName("qipao_battle"..camp..".png")
        if camp == 1 then
            chatBg:setCapInsets(cc.rect(60, 23, 1, 1))
        else
            chatBg:setCapInsets(cc.rect(30, 23, 1, 1))
        end
            
        chatBg.label = label
        chatBg:addChild(label)
        chatBg.label = label
        local node = cc.Node:create()
        if pos.is3D then
            node:setRotation3D(_3dVertex1)
        end
        chatBg:setPositionY(85)
        node:addChild(chatBg,999)
        -- print("pos.x",pos.x,"pos.y",pos.y)
        node:setPosition(pos.x,pos.y)
        shoutNode:addChild(node, 1)
        chatBg:setLocalZOrder(shoutNode:getLocalZOrder())
        chatBg:setCascadeOpacityEnabled(true)
    else
        chatBg = shoutNode._chatBg
        label = chatBg.label
        label:setString(msg)
    end
    local labelW,labelH = label:getContentSize().width,label:getContentSize().height
    local bgW,bgH = math.max(labelW+40,97),math.max(labelH+40,63)
    chatBg:setContentSize(cc.size(bgW,bgH))
    label:setAnchorPoint(0.5,0.5)
    label:setPosition(bgW/2,bgH/2+5)
    if color == nil then
        label:setColor(brown)
    elseif color == 1 then
        label:setColor(blue)
    else
        label:setColor(red)
    end

    if clear then
        chatBg:runAction(cc.Sequence:create(cc.ScaleTo:create(0.1, 1.4), cc.ScaleTo:create(0.1, 1.2), cc.DelayTime:create(2.5), cc.ScaleTo:create(0.1, 0.2), 
            cc.CallFunc:create(function () shoutNode._chatBg = nil end),
            cc.RemoveSelf:create(true)))
    else
        chatBg:runAction(cc.Sequence:create(cc.DelayTime:create(2.5), cc.ScaleTo:create(0.1, 0.2), 
            cc.CallFunc:create(function () shoutNode._chatBg = nil end),
            cc.RemoveSelf:create(true)))
    end
    shoutNode._chatBg = chatBg
end

function ShoutBox:randRivalChat( )
    if self._rivalAITime <= 5 or (self._rivalAITime >= self._maxTime - 5) then
        if(self._rHadShout and GRandom(33) or  GRandom(6)) == 1 then 
            self:onChat(lang("CALL_BATTLE_0"..GRandom(4).."_0"..GRandom(3)), 2, self._rivalNode,true,self._rivalPos)
            self._rHadShout = true
        end
    else
        if (self._rHadShout and GRandom(33) or GRandom(20)) == 1 then 
            self:onChat(lang("CALL_BATTLE_0"..GRandom(4).."_0"..GRandom(3)), 2, self._rivalNode,true,self._rivalPos)
            self._rHadShout = true
        end
    end
end

return ShoutBox