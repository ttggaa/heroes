-- local BattleScene = require("game.view.battle.display.BattleScene")
-- local logic = BC.logic
-- local objLayer = BC.objLayer
-- local viewMgr = ViewManager:getInstance()
-- -- 介绍英雄
-- function BattleScene:introduceHero(info, callback)
--     local id = info[1][1]
--     local hero = logic:getHero(2)
--     local x, y = self:convertToScreenPt(hero.x, hero.y)
--     y = y + 30
--     viewMgr:guideMaskEnable(x, y, 200, 200)
--     viewMgr:_guide_quan(x, y)
--     ScheduleMgr:delayCall(1000, self, function()
--         viewMgr:guideMaskDisable()
--         local touchMask = ccui.Layout:create()
--         touchMask:setBackGroundColorOpacity(0)
--         touchMask:setBackGroundColorType(1)
--         touchMask:setBackGroundColor(cc.c3b(0,0,0))
--         touchMask:setContentSize(MAX_SCREEN_WIDTH, MAX_SCREEN_HEIGHT)
--         touchMask:setTouchEnabled(false)
--         viewMgr:getRootLayer():addChild(touchMask, 100)
--         -- 介绍UI

--         local isQuit = false
--         local bgimage = cc.Scale9Sprite:createWithSpriteFrameName("globalPanelUI11_frame5.png")
--         bgimage:setCapInsets(cc.rect(247, 0, 1, 1))
--         bgimage:setContentSize(920, 471)
--         touchMask:addChild(bgimage)
--         bgimage:setPosition(MAX_SCREEN_WIDTH * 0.5, MAX_SCREEN_HEIGHT * 0.5) -- x, y
--         bgimage:setScale(0.5)

--         local bg = cc.Layer:create()
--         bg:setContentSize(885, 394)
--         -- bg:setPosition(885 * 0.5, 394 * 0.5)
--         bg:setAnchorPoint(0.5, 0.5)
--         bg:setScale(0.7)
--         bg:setCascadeOpacityEnabled(true)
--         bg:setOpacity(0)
--         bgimage:addChild(bg, 5)
--         bg:setVisible(false)
--         bg:runAction(cc.Sequence:create(cc.DelayTime:create(0.14), cc.CallFunc:create(function () bg:setVisible(true) end), cc.Spawn:create(cc.ScaleTo:create(0.1, 1), cc.FadeTo:create(0.1, 255))))

--         bgimage:runAction(cc.Sequence:create(cc.Spawn:create(cc.ScaleTo:create(0.1, 1), cc.MoveTo:create(0.1, cc.p(MAX_SCREEN_WIDTH * 0.5, MAX_SCREEN_HEIGHT * 0.5)))))
--         touchMask:addClickEventListener(function (sender)
--             if isQuit then return end
--             isQuit = true
--             bgimage:runAction(cc.Sequence:create(cc.Spawn:create(cc.ScaleTo:create(0.1, 0), cc.MoveTo:create(0.1, cc.p(x, y))), 
--             cc.CallFunc:create(function ()
--                 touchMask:removeFromParent()
--                 if self._lihuiName then
--                     cc.Director:getInstance():getTextureCache():removeTextureForKey(self._lihuiName)
--                     self._lihuiName = nil
--                 end
--                 if self._race then
--                     cc.Director:getInstance():getTextureCache():removeTextureForKey(self._race)
--                     self._race = nil
--                 end
--                 callback()
--             end)))
--         end)

--         touchMask:setTouchEnabled(false)
--         ScheduleMgr:delayCall(1000, self, function()
--             if isQuit then return end
--             touchMask:setTouchEnabled(true)
--         end)

--         local heroD = tab:Hero(id)
--         if heroD then
--             local centerx = bg:getContentSize().width * 0.5
--             local centery = bg:getContentSize().height * 0.5
--             self._race = "asset/uiother/battle/bg_tt2_"..heroD["race"].."-HD.png"
--             local raceSp = cc.Sprite:create(self._race)
--             raceSp:setScale(.75)
--             raceSp:setPosition(128, 380)
--             bg:addChild(raceSp)
            
--             local clipNode = ccui.Layout:create()
--             clipNode:setContentSize(bg:getContentSize().width + 25, 1024)
--             clipNode:setPositionY(5)
--             clipNode:setClippingEnabled(true)
--             bgimage:addChild(clipNode)

--             self._lihuiName = "asset/uiother/hero/".. heroD["crusadeRes"] ..".png"


--             local roleSp = cc.Sprite:create(self._lihuiName)
--             roleSp:setAnchorPoint(0.5, 0)
--             clipNode:addChild(roleSp)
--             local scale = 1.2
--             roleSp:setPosition(centerx + 230, -50)
--             roleSp:setScale(-scale, scale)
--             roleSp:setOpacity(50)
--             roleSp:setVisible(false)
--             roleSp:runAction(cc.Sequence:create(cc.DelayTime:create(0.1), cc.CallFunc:create(function () roleSp:setVisible(true) end), cc.Spawn:create(cc.MoveTo:create(0.1, cc.p(centerx + 230, 3)), cc.FadeTo:create(0.1, 255))))

--             local str = lang(heroD["heroname"])
--             local size = 32
--             local len = string.len(str)
--             if len == 6 then
--                 size = 56
--             elseif len == 9 then
--                 size = 56
--             elseif len == 12 then
--                 size = 44
--             elseif len == 15 then
--                 size = 32
--             end

--             local name = cc.Label:createWithTTF(lang(heroD["heroname"]), UIUtils.ttfName, size)
--             name:setColor(cc.c3b(60, 42, 30))
--             name:enableOutline(cc.c4b(236, 221, 178, 255), 2)
--             name:setPosition(260, 370)
--             bg:addChild(name, 30)

--             local des = cc.Label:createWithTTF("　"..lang(heroD["herodes"]), UIUtils.ttfName, 16)
--             des:setColor(cc.c3b(109, 90, 96))
--             des:setAnchorPoint(0, 1)
--             des:setDimensions(280, 600)
--             des:setVerticalAlignment(0)
--             des:setPosition(80, 336)
--             bg:addChild(des)

--             if info[2] then
--                 local rush = cc.Label:createWithTTF(lang(info[2]), UIUtils.ttfName, 20)
--                 rush:setColor(cc.c3b(255, 240, 0))
--                 rush:enableOutline(cc.c4b(81, 19, 0, 255), 2)        
--                 rush:setPosition(centerx, 32)
--                 bg:addChild(rush)
--             end

--             -- 专长
--             local sp = cc.Scale9Sprite:createWithSpriteFrameName("globalImageUI12_infoPropmtBg.png")
--             sp:setCapInsets(cc.rect(90, 14, 1, 1))
--             sp:setContentSize(260, 28)
--             sp:setScale(1.1)
--             sp:setOpacity(153)
--             sp:setPosition(216, 250)
--             bg:addChild(sp)

--             local name = cc.Label:createWithTTF("专长", UIUtils.ttfName, 24)
--             name:setColor(cc.c3b(60, 42, 30))
--             name:setPosition(216, 250)
--             bg:addChild(name)

--             local id = tonumber(heroD["special"]..1)
--             local heroMasteryD = tab.heroMastery[id]
--             local icon = cc.Sprite:createWithSpriteFrameName(IconUtils.iconPath .. heroMasteryD["icon"] .. ".jpg")
--             icon:setPosition(216 - 90, 190)
--             icon:setScale(0.8)
--             bg:addChild(icon)

--             local zhuanchang = cc.Sprite:createWithSpriteFrameName("label_specialty_hero.png")
--             zhuanchang:setRotation(-45)
--             zhuanchang:setPosition(100, 216)
--             bg:addChild(zhuanchang)

--             local des = cc.Label:createWithTTF(lang("HEROSPECIALDES_"..heroD["special"]), UIUtils.ttfName, 20)
--             des:setColor(cc.c3b(128, 90, 28))
--             des:setAnchorPoint(0, 1)
--             des:setDimensions(180, 600)
--             des:setVerticalAlignment(0)
--             des:setPosition(170, 202)
--             bg:addChild(des)


--             local circle = cc.Sprite:createWithSpriteFrameName("globalImageUI4_iquality0.png")
--             circle:setPosition(icon:getContentSize().width * 0.5, icon:getContentSize().height * 0.5)
--             circle:setScale(0.9)
--             icon:addChild(circle)

--             -- 大招
--             local sp = cc.Scale9Sprite:createWithSpriteFrameName("globalImageUI12_infoPropmtBg.png")
--             sp:setCapInsets(cc.rect(90, 14, 1, 1))
--             sp:setContentSize(260, 28)
--             sp:setScale(1.1)
--             sp:setOpacity(153)
--             sp:setPosition(216, 132)
--             bg:addChild(sp)

--             local name = cc.Label:createWithTTF("技能", UIUtils.ttfName, 24)
--             name:setColor(cc.c3b(60, 42, 30))
--             name:setPosition(216, 132)
--             bg:addChild(name)

--             local id = tonumber(heroD["spell"][4])
--             local skillD = tab.playerSkillEffect[id]
--             local icon = cc.Sprite:createWithSpriteFrameName(IconUtils.iconPath .. skillD["art"] .. ".png")
--             icon:setPosition(216 - 90, 66)
--             icon:setScale(0.8)
--             bg:addChild(icon)

--             local circle = cc.Sprite:createWithSpriteFrameName("skill_bg_battle.png")
--             circle:setPosition(icon:getContentSize().width * 0.5, icon:getContentSize().height * 0.5)
--             circle:setScale(1.2)
--             icon:addChild(circle)

--             local dazhao = cc.Sprite:createWithSpriteFrameName("final_skill_battle.png")
--             dazhao:setPosition(216 - 116, 90)
--             dazhao:setScale(.9)
--             bg:addChild(dazhao)

--             local str = string.gsub(lang("PLAYERSKILLDES4_"..id),"%b[]","")
--             str = string.gsub(str,"%b{}","")
--             local des = cc.Label:createWithTTF(str, UIUtils.ttfName, 18)
--             des:setColor(cc.c3b(128, 90, 28))
--             des:setAnchorPoint(0, 1)
--             des:setDimensions(180, 600)
--             des:setVerticalAlignment(0)
--             des:setPosition(170, 104)
--             bg:addChild(des)
--         end
--     end)
-- end