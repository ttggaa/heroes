--[[
    Filename:    GodWarWorshipNumDialog.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2017-06-13 20:44:30
    Description: File description
--]]


-- 提示
local GodWarWorshipNumDialog = class("GodWarWorshipNumDialog", BasePopView)

function GodWarWorshipNumDialog:ctor()
    GodWarWorshipNumDialog.super.ctor(self)
end

function GodWarWorshipNumDialog:onInit()
    self:registerClickEventByName("bg.closeBtn", function ()
        if OS_IS_WINDOWS then
            UIUtils:reloadLuaFile("godwar.GodWarWorshipNumDialog")
        end
        self:close()
    end)  
    self._userModel = self._modelMgr:getModel("UserModel")
    self._godWarModel = self._modelMgr:getModel("GodWarModel")
    self._godWarModel:setWorShipDialog()
    local title = self:getUI("bg.titleBg.title")
    UIUtils:setTitleFormat(title, 1)
end

function GodWarWorshipNumDialog:reflashUI(data)
    local showStr = lang("GODWAR_MOBAITIP")
    local xiaoren = self:getUI("bg.xiaoren")
    showStr = "[color=645252,fontsize=24]　　" .. showStr .. "[-]"
    local richTextBg = self:getUI("bg.richTextBg")
    local richText = RichTextFactory:create(showStr, richTextBg:getContentSize().width, 0)
    richText:formatText()
    richText:setPosition(richTextBg:getContentSize().width/2, richTextBg:getContentSize().height - richText:getRealSize().height/2)
    richTextBg:addChild(richText)

    local bg = self:getUI("bg")
    local caidai = mcMgr:createViewMC("caidai_huodetitleanim", false, true)
    caidai:setPosition(bg:getContentSize().width*0.5,bg:getContentSize().height*0.5+100)
    bg:addChild(caidai,5)

    local yanhua = mcMgr:createViewMC("yanhua_juanxiandonghua", false, true)
    yanhua:setPosition(bg:getContentSize().width*0.5,bg:getContentSize().height*0.5+150)
    bg:addChild(yanhua,5)
    
    self:showAnim()
end

function GodWarWorshipNumDialog:getWorNum()
    local dispersedData = self._godWarModel:getDispersedData()
    local secopentime = self._userModel:getData().sec_open_time
    local worship = dispersedData["worship"]
    local worNum = worship+500*secopentime/(60+secopentime)
    print("worNum===========", worNum, worship)
    return math.floor(worNum)
end

function GodWarWorshipNumDialog:showAnim()
    local worNum = self:getWorNum()
    local animShip = self:getUI("bg.numPanel")
    local tempNum = worNum
    local num = {}
    num[1] = math.floor(tempNum/10000)
    tempNum = tempNum - num[1] * 10000
    num[2] = math.floor(tempNum/1000)
    tempNum = tempNum - num[2] * 1000
    num[3] = math.floor(tempNum/100)
    tempNum = tempNum - num[3] * 100
    num[4] = math.floor(tempNum/10)
    tempNum = tempNum - num[4] * 10
    num[5] = math.fmod(tempNum, 10)

    for i=1,5 do
        local worNumBg = self:getUI("bg.numPanel.worNum" .. i)
        local rollNumNode = self:rollNumAnim(num[i],0.08,(i-1)*5+10)
        rollNumNode:setPosition(5, 5)
        rollNumNode.start()
        worNumBg:addChild(rollNumNode)
    end

    -- for i=1,5 do
    --     local worNumBg = self:getUI("bg.numPanel.worNum" .. i)
    --     local worNumLab = cc.Label:createWithTTF(num[i], UIUtils.ttfName, 40)
    --     worNumLab:setPosition(worNumBg:getContentSize().width*0.5, worNumBg:getContentSize().height*0.5)
    --     worNumLab:setName("worNumLab")
    --     worNumBg:addChild(worNumLab)

    --     local xishu = 0.06 - i*0.01 + 0.01 -- 0.03 -- (5-i)*0.01 -- 0.03 -- (5-i)*0.01
    --     local fade1 = cc.FadeTo:create(xishu, 50)
    --     local fade2 = cc.FadeTo:create(xishu, 255)
    --     local move1 = cc.MoveBy:create(xishu, cc.p(0, 15))
    --     local move3 = cc.MoveBy:create(xishu, cc.p(0, -15))
    --     local spawn1 = cc.Spawn:create(fade1, move1)
    --     local spawn2 = cc.Spawn:create(fade2, move3)
    --     local callFunc = cc.CallFunc:create(function()
    --         if worNumLab then
    --             local rand = GRandom(9)
    --             worNumLab:setString(rand)
    --         end
    --     end)
    --     local seq = cc.Sequence:create(spawn1, callFunc, spawn2)
    --     local repNum = i*i + 1
    --     -- print("=repNum=============", i, xishu, repNum, xishu*repNum)
    --     local rep = cc.Repeat:create(seq, repNum)
    --     local callfunc1 = cc.CallFunc:create(function()
    --         if worNumLab then
    --             worNumLab:setString(num[i])
    --             worNumLab:setOpacity(255)
    --             worNumLab:setPosition(worNumBg:getContentSize().width*0.5, worNumBg:getContentSize().height*0.5)
    --         end
    --     end)
    --     local seq1 = cc.Sequence:create(cc.DelayTime:create(0.1*i), rep, callfunc1)
    --     worNumLab:runAction(seq1)
    -- end
    -- local num1 = math.floor(tempNum/10000)
    -- tempNum = tempNum - num1 * 10000
    -- local num2 = math.floor(tempNum/1000)
    -- tempNum = tempNum - num2 * 1000
    -- local num3 = math.floor(tempNum/100)
    -- tempNum = tempNum - num3 * 100
    -- local num4 = math.floor(tempNum/10)
    -- tempNum = tempNum - num4 * 10
    -- local num5 = math.fmod(tempNum, 10)

    -- for i=1,5 do
    --     local a = "num" .. i
    --     local result = loadstring(a)()
    --     print("num==========", result)
    -- end
end

-- 参数，最终显示数，滚动速度，滚动时间
function GodWarWorshipNumDialog:rollNumAnim( num,speed,time )
    local boxW,boxH = 40,50
    local boxNode = --ccui.Widget:create() 
    cc.ScrollView:create() 
    boxNode:setViewSize(cc.size(boxW,boxH))
    boxNode:setDirection(0) --设置滚动方向
    boxNode:setBounceable(false)
    boxNode:setTouchEnabled(false)

    local num1 = ccui.Text:create()
    num1:setFontSize(40)
    num1:setName("num1")
    num1:setFontName(UIUtils.ttfName)
    num1:setString("0")
    num1.endTime = time
    num1:setPosition(0,0)
    boxNode:addChild(num1)

    local num2 = ccui.Text:create()
    num2:setFontSize(40)
    num2:setName("num2")
    num2:setFontName(UIUtils.ttfName)
    num2:setString("1")
    num2.endTime = time
    num2:setPosition(0,0)
    boxNode:addChild(num2)

    -- 滚动动画
    local delayTime = 0.0--speed
    local offsetY = 0
    local step = num1:getContentSize().height-10
    local posUp = cc.p(20,boxH+step/2+offsetY)
    local posCenter = cc.p(20,boxH/2+offsetY)
    local posDown = cc.p(20,-step/2+offsetY)
    local runNumOutAction = function( numLab, callback )
        numLab:runAction(cc.Sequence:create(
            cc.Spawn:create(
                cc.MoveTo:create(speed,cc.p(posUp)),
                cc.FadeOut:create(speed)
            ),
            cc.DelayTime:create(delayTime),
            cc.CallFunc:create(function(  )
                numLab:setPosition(posDown)
                numLab.endTime = numLab.endTime - 1
                numLab:stopAllActions()
                if numLab.inAction and num2.endTime > 0 then
                    numLab:setString((tonumber(numLab:getString())+1)%10)
                    numLab.inAction(numLab)
                else
                    numLab:setString(num)
                    num1:stopAllActions()
                    num1:setPosition(posCenter)
                    num1:setOpacity(255)
                    num1:setString(num)
                    num2:stopAllActions()
                    num2:setPosition(posDown)
                    num2:setString(num)
                end
            end)
        ))
    end

    local runNumInAction = function( numLab )
        numLab:runAction(cc.Sequence:create(
            cc.Spawn:create(
                cc.MoveTo:create(speed,cc.p(posCenter)),
                cc.FadeIn:create(speed)
            ),
            cc.DelayTime:create(delayTime),
            cc.CallFunc:create(function(  )
                numLab.endTime = numLab.endTime - 1
                numLab:stopAllActions()
                if numLab.outAction and numLab.endTime > 0 then
                    numLab:setString((tonumber(numLab:getString())+1)%10)
                    numLab.outAction(numLab)
                else
                    numLab:setString(num)
                    num1:stopAllActions()
                    num1:setPosition(posCenter)
                    num1:setOpacity(255)
                    num1:setString(num)
                    num2:stopAllActions()
                    num2:setPosition(posDown)
                    num2:setString(num)
                end
            end)
        ))
    end
    -- 初始化滚动条件
    num1.inAction = runNumInAction
    num1.outAction = runNumOutAction
    num1:setPosition(posCenter)
    
    num2.inAction = runNumInAction
    num2.outAction = runNumOutAction
    num2:setPosition(posDown)
    -- 节点的动画
    boxNode.start = function(  )
        num1:setPosition(posCenter)
        runNumOutAction(num1)
        num2:setPosition(posDown)
        runNumInAction(num2)
    end

    return boxNode
end


return GodWarWorshipNumDialog
