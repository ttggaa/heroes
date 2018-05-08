--[[
    Filename:    CrusadeBufferBuildNode.lua
    Author:      <weiwei02@playcrab.com>
    Datetime:    2015-12-01 18:24:17
    Description: File description
--]]

local CrusadeBufferBuildNode = class("CrusadeBufferBuildNode", BasePopView)

function CrusadeBufferBuildNode:ctor()
    CrusadeBufferBuildNode.super.ctor(self)
end

function CrusadeBufferBuildNode:onInit()
    local Image_34 = self:getUI("bg.Image_34") 
	self:registerClickEventByName("bg.closeBtn", function ()
        self:close()
    end)
end

function CrusadeBufferBuildNode:reflashUI(data)
	self._curCrusadeId = data.crusadeId
    self._buffList = data.netData.buffList
    self._buildId = data.crusadeData.buildId
    self._token = data.netData.token
    self._callback = data.callback
    self._parentView = data.parentView

    local sysCrusadeBuild = tab:CrusadeBuild(self._buildId)

    local titleLab = self:getUI("bg.titleLab") 
    UIUtils:setTitleFormat(titleLab, 1)
    titleLab:setString(lang(sysCrusadeBuild.name))
    -- titleLab:setColor(cc.c3b(255, 255, 255))
    -- titleLab:enableOutline(cc.c4b(60, 30, 10,255), 1)

    local unlockLab = self:getUI("bg.bufferBg3.Label_30")
    unlockLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

    local descBg = self:getUI("bg.descBg")
    local richText = RichTextFactory:create(lang(sysCrusadeBuild.des1), 550, 100)
    richText:formatText()
    richText:setPosition(richText:getInnerSize().width/2 + (richText:getInnerSize().width - richText:getRealSize().width)/2, descBg:getContentSize().height/2)
    descBg:addChild(richText)

    self:showSelectBuff()   --可选择buff
    self:showCurBuff()      --当前buff
end

function CrusadeBufferBuildNode:createLockIcon(inObj)
    local dropIcon = ccui.Widget:create()

    local iconBg = cc.Sprite:createWithSpriteFrameName("globalImageUI6_itembg_1.png")
    iconBg:setPosition(dropIcon:getContentSize().width * 0.5, dropIcon:getContentSize().height * 0.5)
    dropIcon:addChild(iconBg)

    local secret = cc.Sprite:createWithSpriteFrameName("globalImageUI_secretIcon.png")
    secret:setPosition(dropIcon:getContentSize().width * 0.5, dropIcon:getContentSize().height * 0.5)
    dropIcon:addChild(secret)
        
    dropIcon:setAnchorPoint(0, 0.5)
    dropIcon:setScale(0.9)
    dropIcon:setPosition(inObj:getPosition())
    inObj:getParent():addChild(dropIcon, 1)
end

function CrusadeBufferBuildNode:showSelectBuff()
    local bg = self:getUI("bg")
    self._selectIndex = 0
    
    local privilegesModel = self._modelMgr:getModel("PrivilegesModel")
    local isOpenthirdBuffer = privilegesModel:getPeerageEffect(PrivilegeUtils.peerage_ID.YuanZhengBUFF)

    local buffPic = tab.crusadeBuffPic
    for i=1,3 do
        local sysBuf = self._buffList[i]
        local bufferBg = self:getUI("bg.bufferBg" .. i)
        local bufferIcon = bufferBg:getChildByName("Image_57")
        local unlockLab = self:getUI("bg.bufferBg3.Label_30")
        if isOpenthirdBuffer == 0 and i == 3 then  
            -- bufferIcon:loadTexture("pokeImage_suo.png", 1)
            unlockLab:setVisible(true)
            self:createLockIcon(bufferIcon)
        else
            bufferIcon:loadTexture(buffPic[sysBuf[1]].pic .. ".png", 1)
            unlockLab:setVisible(false)
        end

        local textBg = bufferBg:getChildByName("Image_62")
        local str = ""
        if isOpenthirdBuffer == 0 and i == 3 then 
            str = lang("CRUSADE_BUFF_TIPS")
            local uresult,count1 = string.gsub(str, "$peerage", lang(tab:Peerage(PrivilegeUtils.peerage_ID.YuanZhengBUFF).name))
            if count1 > 0 then 
                str = uresult
            end
        else
            str = lang("CRUSADE_BUFF_" .. sysBuf[1])
            local result, count = string.gsub(str, "$num", sysBuf[2])
            if count > 0 then 
                str = result
            end
        end
        
        local richText = RichTextFactory:create(str, 160, 40)
        richText:formatText()
        richText:setPosition(textBg:getContentSize().width/2 + (textBg:getContentSize().width - richText:getRealSize().width)/2+3, textBg:getContentSize().height/2)

        textBg:addChild(richText)
        registerTouchEvent(bufferBg,
            function()
                local buffmc = bg:getChildByName("buffmc_selected")
                if buffmc == nil then 
                    buffmc = mcMgr:createViewMC("xuanzhong_crusadebufferselected", false, false)
                    buffmc:setName("buffmc_selected")
                    bg:addChild(buffmc, 5)
                    buffmc:clearCallbacks()
                    buffmc:addEndCallback(function(_, sender) sender:stop() end)
                end
                buffmc:setVisible(true)
                buffmc:stop()
                buffmc:gotoAndPlay(0)
                buffmc:setPosition(bufferBg:getPositionX(), bufferBg:getPositionY() + 2)
            end,
            nil,
            function()
                local buffmc = bg:getChildByName("buffmc_selected")
                if buffmc ~= nil then 
                    buffmc:setVisible(false)
                end

                if isOpenthirdBuffer == 0 and i == 3 then
                    self._viewMgr:showTip(lang("CRUSADE_TIPS_8"))
                    return
                end
                self._selectIndex = i
                self:enterSelected(i, str)
            end,
            function()
                local buffmc = bg:getChildByName("buffmc_selected")
                if buffmc ~= nil then 
                    buffmc:setVisible(false)
                end
            end)
    end
end

function CrusadeBufferBuildNode:showCurBuff()
    local userBuffs = self._modelMgr:getModel("CrusadeModel"):getData().buff


    local bufferBg = self:getUI("bg.curBuffPanel")
    local tipDes = self:getUI("bg.tipDes")

    --普通buff
    if userBuffs and next(userBuffs) ~= nil then
        bufferBg:setVisible(true)
        tipDes:setVisible(false)
        
        local sysBuffPic = tab.crusadeBuffPic
        local buffOrderKeys = table.keys(userBuffs)
        local sortFunc = function(a, b) return tonumber(b) > tonumber(a) end
        table.sort(buffOrderKeys, sortFunc)

        local startPos = 11
        for k,v in pairs(buffOrderKeys) do
            local buff = userBuffs[v]
            local desc = lang("CRUSADE_BUFF_" .. v)   --text
            local result,count = string.gsub(desc, "$num", buff)
            if count > 0 then 
                desc = result
            end
            local richText = RichTextFactory:create(desc, 180 , 0)
            richText:setScale(0.97)
            richText:formatText()
            richText:setPosition(startPos + richText:getContentSize().width/2, 20)
            startPos = startPos + richText:getRealSize().width + 5
            richText:setName("richText" .. k)
            bufferBg:addChild(richText)
        end
    else
        bufferBg:setVisible(false)
        tipDes:setVisible(true)
    end
end

function CrusadeBufferBuildNode:enterSelected(index, cstr)
    local sysBuf = self._buffList[self._selectIndex]
    if sysBuf[1] == 999 then 
        local formationModel = self._modelMgr:getModel("FormationModel")
        local formationData = formationModel:getFormationDataByType(formationModel.kFormationTypeCrusade)
        local teamNum, inTeamdieNum, dieNum = formationModel:getFormationTeamCountWithFilter(formationModel.kFormationTypeCrusade)

        if dieNum <= 0 then 
            self._viewMgr:showTip(lang("CRUSADE_TIPS_10"))
            return
        end
        self:setVisible(false)
        self._viewMgr:showDialog("crusade.CrusadeReviveTeamNode",{
                    crusadeId = self._curCrusadeId, 
                    buffId = sysBuf[1], 
                    token = self._token ,
                    callback = function(inType)
                        if inType == 1 then 
                            self:setVisible(true)
                        else
                            if self._callback ~= nil then 
                                self._callback()
                            end  
                            self:close(false)  

                        end
                    end},true) 
    else
        local tipInfo = "[color=3c2a1e,fontsize=20]是否确认选择[-]" .. string.gsub(cstr, "ffffff", "00ff22")  
        self._viewMgr:showDialog("global.GlobalSelectDialog",
            {
                desc = tipInfo,
                button1 = "确定" ,
                button2 = "取消", 
                callback1 = function ()
                    self:getCrusadeEventReward(sysBuf[1], index)
                end,
                callback2 = function()
                  
                end
            }, true)       
    end
end

function CrusadeBufferBuildNode:getCrusadeEventReward(inBuffId, index)
    self._curBuffId = inBuffId
    self._serverMgr:sendMsg("CrusadeServer", "getCrusadeEventReward", {id = self._curCrusadeId, token = self._token, args =json.encode({buffId = inBuffId})}, true, {}, function (result)
        return self:getCrusadeEventRewardFinish(result, index)
    end)
end

function CrusadeBufferBuildNode:getCrusadeEventRewardFinish(result, index)
    if result["d"] == nil then 
        return 
    end

    --point1
    local bufferBg = self:getUI("bg.bufferBg" .. self._selectIndex)
    local bufferIcon = bufferBg:getChildByName("Image_57")
    local point1 = bufferIcon:convertToWorldSpace(cc.p(0, 0))
    point1 = self:convertToNodeSpace(point1)

    --point2
    local bufferBtn = self._parentView:getUI("bufferBtn")
    local point2 = bufferBtn:convertToWorldSpace(cc.p(0, 0)) 
    point2 = self:convertToNodeSpace(point2)
    point2.x = point2.x + bufferBtn:getContentSize().width/2
    point2.y = point2.y + bufferBtn:getContentSize().height/2

    self._viewMgr:lock(99999)
    local tempPoint = cc.p(point1.x + bufferIcon:getContentSize().width/2 * 0.9, point1.y + bufferIcon:getContentSize().height/2 * 0.9)

    --pic
    local buffPic = tab.crusadeBuffPic  
    local bufferSp = ccui.ImageView:create(buffPic[self._curBuffId].pic .. ".png", 1)
    bufferSp:setAnchorPoint(0.5, 0.5)
    bufferSp:setPosition(point1.x + bufferIcon:getContentSize().width/2 * 0.9, point1.y + bufferIcon:getContentSize().height/2 * 0.9)
    self:addChild(bufferSp, 1000)

    --picFrame
    local picFrame = ccui.ImageView:create("globalImageUI4_squality5.png", 1)
    picFrame:setPosition(bufferSp:getContentSize().width/2, bufferSp:getContentSize().height/2)
    bufferSp:addChild(picFrame)

    --angle
    local angle = 360 - MathUtils.angleAtan2(tempPoint, point2) + 90

    --widget
    local pointDis = MathUtils.pointDistance(point1, point2)
    local moveX = (point2.x - tempPoint.x) * 100 / pointDis
    local moveY = (point2.y - tempPoint.y) * 100 / pointDis
    local wiget = ccui.Layout:create()
    wiget:setPosition(tempPoint.x + moveX, tempPoint.y + moveY)
    wiget:setRotation(angle)
    self:addChild(wiget)

    local buffmc = mcMgr:createViewMC("buffguangxiao_crusademap", false, true)
    buffmc:addCallbackAtFrame(20, function()  
        local buffmc1 = mcMgr:createViewMC("guangquan_crusademap", false, true, function()
            --feixing1 xingxing
            local feixing1 = mcMgr:createViewMC("guangqiu_lianmengjihuo", true)
            wiget:addChild(feixing1)

            --feixing2
            local wiget1 = ccui.Layout:create()
            wiget1:setScaleX(1.5)
            wiget:addChild(wiget1)
            local feixing2 = mcMgr:createViewMC("lashentiao_lianmengjihuo", true)
            wiget1:addChild(feixing2)

            wiget:runAction(cc.Sequence:create(
                cc.MoveTo:create(0.5, cc.p(point2.x, point2.y)),
                cc.DelayTime:create(0.1),
                cc.CallFunc:create(function()
                    wiget:removeAllChildren()
                    wiget:removeFromParent(true)
                    wiget = nil

                    local endAinm = mcMgr:createViewMC("fankui_lianmengjihuo", false, true)
                    endAinm:setPosition(point2)
                    self:addChild(endAinm, 1000)
                    endAinm:addCallbackAtFrame(8, function() 
                        self._viewMgr:unlock()
                        if self._callback ~= nil then 
                            self._callback()
                        end
                        self:close()
                        end)
                    end)
                ))
            end)
        buffmc1:setPosition(tempPoint)
        self:addChild(buffmc1, 1001)
        end)
    buffmc:setPosition(point1.x + bufferSp:getContentSize().width/2 - 5, point1.y+ bufferSp:getContentSize().height/2 + 4)
    self:addChild(buffmc, 1001)

    bufferSp:runAction(cc.Sequence:create(
        cc.DelayTime:create(1),
        cc.ScaleTo:create(0.1, 0.5),
        cc.CallFunc:create(function()
            bufferSp:removeFromParent()
         end)
        ))

    local bg = self:getUI("bg")
    bg:setAnchorPoint(0.5, 0.5)
    bg:stopAllActions()
    bg:runAction(cc.Sequence:create(cc.ScaleTo:create(0.05, 0.7), cc.CallFunc:create(function ()
        self._widget:setVisible(false)
        self._parentView:setMaskLayerOpacity(0)
    end)))
end

return CrusadeBufferBuildNode