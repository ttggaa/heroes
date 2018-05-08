-- local BattleScene = require("game.view.battle.display.BattleScene")
-- local logic = BC.logic
-- local objLayer = BC.objLayer
-- local viewMgr = ViewManager:getInstance()
-- -- 介绍NPC
-- function BattleScene:introduceNPC(info, callback)
--     if #info[1] < 3 then
--         self:introduceHero(info, callback)
--         return 
--     end
--     local id = info[1][1]
--     local pos = info[1][2]
--     local skillIndex = info[1][3]
--     if skillIndex == nil then
--         skillIndex = 4
--     end
--     local team = logic:getTeamByCampAnaId(2, self._battleInfo.intanceD["m"..pos][1])
--     local x, y = self:convertToScreenPt(team.x, team.y)
--     if team.volume >= 5 then
--         y = y + 55
--     else
--         local _, h = team.soldier[1]:getRealSize()
--         y = y + h * 0.5
--     end
--     viewMgr:guideMaskEnable(x, y, 200, 200)
--     viewMgr:_guide_quan(x, y)

--     local teamD = tab:Team(507)
--     local race = teamD["race"][1]
--     if race == 109 then
--         race = 102
--     end
--     ScheduleMgr:delayCall(1000, self, function()
--         viewMgr:guideMaskDisable()
--         local touchMask = ccui.Layout:create()
--         touchMask:setBackGroundColorOpacity(0)
--         touchMask:setBackGroundColorType(1)
--         touchMask:setBackGroundColor(cc.c3b(0,0,0))
--         touchMask:setContentSize(MAX_SCREEN_WIDTH, MAX_SCREEN_HEIGHT)
--         touchMask:setTouchEnabled(false)
--         viewMgr:getOtherLayer():addChild(touchMask, 1000)
--         -- 介绍UI

--         local isQuit = false
--         local bgimage = cc.Scale9Sprite:createWithSpriteFrameName("globalPanelUI11_frame5.png")
--         bgimage:setCapInsets(cc.rect(247, 0, 1, 1))
--         bgimage:setContentSize(920, 471)
--         touchMask:addChild(bgimage)
--         bgimage:setPosition(MAX_SCREEN_WIDTH * 0.5, MAX_SCREEN_HEIGHT * 0.5) -- x, y
--         bgimage:setScale(0.5)
--         bgimage:setOpacity(0)

--         local bg = cc.Layer:create()
--         bg:setContentSize(995, 486)
--         -- bg:setPosition(885 * 0.5, 394 * 0.5)
--         bg:setAnchorPoint(0.5, 0.5)
--         bg:setScale(0.7)
--         bg:setCascadeOpacityEnabled(true)
--         bg:setOpacity(0)
--         bgimage:addChild(bg, 5)
--         bg:setVisible(false)
--         bg:runAction(cc.Sequence:create(cc.DelayTime:create(0.14), cc.CallFunc:create(function () bg:setVisible(true) end), cc.Spawn:create(cc.ScaleTo:create(0.1, 1), cc.FadeTo:create(0.1, 255))))

--         bgimage:runAction(cc.Sequence:create(cc.Spawn:create(cc.ScaleTo:create(0.1, 1), cc.FadeTo:create(0.1, 255)), cc.MoveTo:create(0.1, cc.p(MAX_SCREEN_WIDTH * 0.5, MAX_SCREEN_HEIGHT * 0.5)) ))
--         touchMask:addClickEventListener(function (sender)
--             if isQuit then return end
--             isQuit = true
--             bgimage:runAction(cc.Sequence:create(cc.Spawn:create(cc.ScaleTo:create(0.1, 0), cc.MoveTo:create(0.1, cc.p(x, y))), 
--             cc.CallFunc:create(function ()
--                 touchMask:removeFromParent()
--                 if self._lihuiName then
--                     cc.Director:getInstance():getTextureCache():removeTextureForKey(self._lihuiName)
--                     cc.Director:getInstance():getTextureCache():removeTextureForKey("asset/uiother/skillpre/skillpre_"..id..".png")
--                     self._lihuiName = nil
--                 end

--                 callback()
--             end)))
--         end)

--         touchMask:setTouchEnabled(false)
--         ScheduleMgr:delayCall(1000, self, function()
--             if isQuit then return end
--             touchMask:setTouchEnabled(true)
--         end)

--         if teamD then
--             local centerx = bgimage:getContentSize().width * 0.5
--             local centery = bgimage:getContentSize().height * 0.5

            
--             local clipNode = ccui.Layout:create()
--             clipNode:setContentSize(bgimage:getContentSize().width + 200, 1024)
--             clipNode:setPosition(0, 9)
--             clipNode:setClippingEnabled(true)
--             bgimage:addChild(clipNode)

--             local lihui = string.sub(teamD["art1"], 4, string.len(teamD["art1"]))
--             self._lihuiName = "asset/uiother/team/t_".. lihui ..".png"

--             local cardoffset = teamD["card"]

--             local roleSp = cc.Sprite:create(self._lihuiName)
--             roleSp:setAnchorPoint(0, 0)
--             clipNode:addChild(roleSp)
--             local scale = .8
--             roleSp:setPosition(217, -202)
--             roleSp:setScale(cardoffset[3] * scale)
--             roleSp:setVisible(false)
--             roleSp:setOpacity(50)
--             roleSp:runAction(cc.Sequence:create(cc.DelayTime:create(0.1), cc.CallFunc:create(function () roleSp:setVisible(true) end), cc.Spawn:create(cc.MoveTo:create(0.1, cc.p(217, -152)), cc.FadeTo:create(0.1, 255))))

--             -- 阵营
--             local raceIcon = cc.Sprite:create("asset/uiother/battle/bg_tt2_"..race.."-HD.png")
--             raceIcon:setPosition(120, 360)
--             bgimage:addChild(raceIcon)

--             -- 左下定位框
--             local dingweiIcon = cc.Sprite:createWithSpriteFrameName("v"..teamD["volume"].."_battle.png")
--             dingweiIcon:setPosition(780, 90)
--             bgimage:addChild(dingweiIcon)  

--             local volumeValue = {0, 16, 9, 4, 1, 0}
--             local dingweiLabel = cc.Label:createWithTTF("型"..volumeValue[teamD["volume"]].."人兵团", UIUtils.ttfName, 20)
--             dingweiLabel:setColor(cc.c3b(140, 96, 35))
--             dingweiLabel:setAnchorPoint(0, 0.5)
--             dingweiLabel:enableOutline(cc.c4b(236, 221, 178, 255), 2)
--             dingweiLabel:setPosition(751, 35)
--             bgimage:addChild(dingweiLabel)   
--             local colors = 
--             {
--                 cc.c3b(205,32,30),
--                 cc.c3b(127,102,0),
--                 cc.c3b(25,123,212),
--                 cc.c3b(52,123,50),
--                 cc.c3b(191,30,205),
--             }
--             local dingweiLabel2 = cc.Label:createWithTTF(lang("CLASS_10"..teamD["class"].."0"), UIUtils.ttfName, 20)
--             dingweiLabel2:setColor(colors[teamD["class"]])
--             dingweiLabel2:enableOutline(cc.c4b(236, 221, 178, 255), 2)
--             dingweiLabel2:setPosition(731, 35)
--             bgimage:addChild(dingweiLabel2)   

--             local skillyanshi = cc.Label:createWithTTF("技能演示", UIUtils.ttfName, 26)
--             skillyanshi:setColor(cc.c3b(63, 45, 35))
--             skillyanshi:enableOutline(cc.c4b(236, 221, 178, 255), 2)
--             skillyanshi:setPosition(260, 256)
--             bgimage:addChild(skillyanshi)

--             local line1 = cc.Sprite:createWithSpriteFrameName("globalImageUI12_infoPropmtBg.png")
--             line1:setPosition(260, 256)
--             line1:setScale(1.2)
--             bgimage:addChild(line1)  

--             local picName = "asset/uiother/skillpre/skillpre_"..id..".png"
--             if not cc.FileUtils:getInstance():isFileExist(picName) then
--                 picName = "asset/uiother/skillpre/skillpre_103.png"
--             end
--             local skillpre = cc.Sprite:create(picName)
--             skillpre:setScale(.8)
--             skillpre:setPosition(260, 140)
--             bgimage:addChild(skillpre)

--             local tsl = teamD["tsl"]
--             if tsl then
--                 local skillDes = cc.Label:createWithTTF(lang(tsl), UIUtils.ttfName, 18)
--                 skillDes:setColor(cc.c3b(140, 96, 35))
--                 skillDes:setPosition(260, 35)
--                 skillDes:enableOutline(cc.c4b(236, 221, 178, 255), 2)
--                 bgimage:addChild(skillDes)
--             end

--             local str = lang(teamD["name"])
--             local size
--             local len = string.len(str)
--             if len == 6 then
--                 size = 70
--             elseif len == 9 then
--                 size = 62
--             elseif len == 12 then
--                 size = 56
--             elseif len == 15 then
--                 size = 44
--             end
--             local name = cc.Label:createWithTTF(str, UIUtils.ttfName_Title, size)
--             name:setAnchorPoint(0.5, 0.5)
--             name:setColor(cc.c3b(63, 45, 35))
--             name:enableOutline(cc.c4b(236, 221, 178, 255), 2)
--             name:setPosition(300, 360)
--             bgimage:addChild(name)

--             local englishName = cc.Label:createWithTTF(lang(teamD["ename"]), UIUtils.ttfName_Title, 20)
--             englishName:setAnchorPoint(1, 0)
--             englishName:setColor(cc.c3b(102, 84, 84))
--             englishName:enableOutline(cc.c4b(236, 221, 178, 255), 2)
--             bgimage:addChild(englishName)

--             local carddes = cc.Label:createWithTTF(lang("CARDDES_"..teamD["carddes"]), UIUtils.ttfName, 24)
--             carddes:setColor(cc.c3b(140, 96, 35))
--             carddes:enableOutline(cc.c4b(236, 221, 178, 255), 2)
--             bgimage:addChild(carddes)

--             if len == 6 then
--                 englishName:setAnchorPoint(0.5, 0)
--                 name:setPosition(290, 360)
--                 englishName:setPosition(290, 318 + name:getContentSize().height + 2)
--                 carddes:setPosition(290, 310)
--             elseif len == 9 then
--                 englishName:setPosition(300 + name:getContentSize().width * 0.5 - 2, 326 + name:getContentSize().height + 2)
--                 carddes:setPosition(300, 310)
--             elseif len == 12 then
--                 englishName:setPosition(300 + name:getContentSize().width * 0.5 - 2, 330 + name:getContentSize().height + 2)
--                 carddes:setPosition(300, 310)
--             elseif len == 15 then
--                 name:setPosition(300, 356)
--                 englishName:setPosition(300 + name:getContentSize().width * 0.5 - 2, 330 + name:getContentSize().height + 2)
--                 carddes:setPosition(300, 310)
--             end

--             local carddes = cc.Label:createWithTTF("点击任意位置关闭", UIUtils.ttfName, 20)
--             carddes:setColor(cc.c3b(177, 177, 177))
--             carddes:setPosition(458, -26)
--             bgimage:addChild(carddes)

--             local mask = ccui.Layout:create()
--             mask:setBackGroundColorOpacity(255)
--             mask:setBackGroundColorType(1)
--             mask:setBackGroundColor(cc.c3b(0,0,0))
--             mask:setContentSize(MAX_SCREEN_WIDTH, MAX_SCREEN_HEIGHT)
--             mask:setOpacity(128)
--             touchMask:addChild(mask, -10)   

--         end
--     end)
-- end