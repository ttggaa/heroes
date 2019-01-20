--[[
    Filename:    CrossGodWarInvitationDialog.lua
    Author:      <haotaian@playcrab.com>
    Datetime:    2018-05-22 15:09:48
    Description: File description
--]]

-- 邀请函
local CrossGodWarInvitationDialog = class("CrossGodWarInvitationDialog", BasePopView)

function CrossGodWarInvitationDialog:ctor()
    CrossGodWarInvitationDialog.super.ctor(self)
end

function CrossGodWarInvitationDialog:onInit()
    self:registerClickEventByName("bg.closeBtn", function ()
        if OS_IS_WINDOWS then
            UIUtils:reloadLuaFile("crossGod.CrossGodWarInvitationDialog")
        end
        self:close()
    end)  

    local bg = self:getUI("bg.bg")
    bg:loadTexture("asset/bg/bg_godwar_002.png", 0)
    local ren = self:getUI("bg.bg.ren")
    ren:loadTexture("asset/bg/bg_crossGodwar_01.png", 0)
    ren:setVisible(false)
    local chuo = self:getUI("bg.bg.chuo")
    chuo:setVisible(false)

end

function CrossGodWarInvitationDialog:reflashUI(data)
    local richtextBg = self:getUI("bg.richtextBg")

    local desc = lang("crossFight_word_"..data.type)

    if not string.find(desc, "color=") then
        desc = "[color=ffffff]　　" .. desc .. "[-]" 
    end
    local richText = richtextBg:getChildByName("richText")
    richText = RichTextFactory:create(desc, richtextBg:getContentSize().width, richtextBg:getContentSize().height)
    richText:formatText()
    richText:enablePrinter(true)
    richText:setPosition(richtextBg:getContentSize().width*0.5, richtextBg:getContentSize().height - richText:getInnerSize().height*0.5)
    richText:setName("richText")
    richtextBg:addChild(richText)

    local xiaoren = self:getUI("bg.bg.ren")
    local move1 = cc.MoveBy:create(0.01, cc.p(-250, 0))
    local move2 = cc.MoveBy:create(0.05, cc.p(100, 0))
    local move3 = cc.MoveBy:create(0.1, cc.p(200, 0))
    local move4 = cc.MoveBy:create(0.1, cc.p(-50, 0))
    local callFunc = cc.CallFunc:create(function()
        xiaoren:setVisible(true)
    end)
    local seq = cc.Sequence:create(move1, callFunc, move2, move3, move4)
    xiaoren:runAction(seq)

    local chuo = self:getUI("bg.bg.chuo")
    local scale1 = cc.ScaleTo:create(0.2, 8)
    local scale2 = cc.ScaleTo:create(0.1, 0.9)
    local scale3 = cc.ScaleTo:create(0.1, 1)
    local callFunc = cc.CallFunc:create(function()
        chuo:setVisible(true)
    end)
    local seq = cc.Sequence:create(scale1, callFunc, scale2, scale3)
    chuo:runAction(seq)

    local gotoBattle = self:getUI("bg.gotoBattle")
    self:registerClickEvent(gotoBattle, function()
        local openData = tab.systemOpen["CrossGodWar"]
        local userLevel = self._modelMgr:getModel("UserModel"):getPlayerLevel()
        local godWarConstData = self._modelMgr:getModel("UserModel"):getGodWarConstData()
        local openTime = godWarConstData.FIRST_RACE_BEG + 43200 + 3*24*60*60*7
        local curTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
        if userLevel<tonumber(openData[1]) then
            self._viewMgr:showTip(lang(openData[3]))
        else
			if not GameStatic.is_open_crossGodWar then
				self._viewMgr:showTip("系统维护中")
				return
			end
            self._serverMgr:sendMsg("CrossGodWarServer", "enter", {}, true, {}, function(result)
                UIUtils:reloadLuaFile("crossGod.CrossGodWarView")
                self._viewMgr:showView("crossGod.CrossGodWarView")
                self:close()
            end)
        end
        
    end)
end

return CrossGodWarInvitationDialog
