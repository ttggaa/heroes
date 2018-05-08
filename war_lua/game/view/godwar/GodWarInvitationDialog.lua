--[[
    Filename:    GodWarInvitationDialog.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2017-04-10 22:09:48
    Description: File description
--]]

-- 邀请函
local GodWarInvitationDialog = class("GodWarInvitationDialog", BasePopView)

function GodWarInvitationDialog:ctor()
    GodWarInvitationDialog.super.ctor(self)
end

function GodWarInvitationDialog:onInit()
    self:registerClickEventByName("bg.closeBtn", function ()
        if OS_IS_WINDOWS then
            UIUtils:reloadLuaFile("godwar.GodWarInvitationDialog")
        end
        self:close()
    end)  

    local bg = self:getUI("bg.bg")
    bg:loadTexture("asset/bg/bg_godwar_002.png", 0)
    local ren = self:getUI("bg.bg.ren")
    ren:loadTexture("asset/bg/bg_godwar_004.png", 0)
    ren:setVisible(false)
    local chuo = self:getUI("bg.bg.chuo")
    chuo:setVisible(false)

end

function GodWarInvitationDialog:reflashUI(data)
    local richtextBg = self:getUI("bg.richtextBg")
    -- " \
    -- [color=ffffff]　　在大陆的东方出现了许多异族的身影，已经有三座城池被他们接连占领，将军，我们必须守卫自己的领土，而这一切需要你的力量。[-][][-] \
    -- [color=ffffff]　[-][][-][color=ffffff]　[-][][-][color=ffffff]1、将军需要经历15场战斗，每次胜利可以获得金币，符文材料，以及帝国的奖赏。[-][][-] \
    -- [color=ffffff]　[-][][-][color=ffffff]2、战斗中怪兽死亡将不能继续上阵，但是可以在编组外重新选择一个代替他。[-][][-] \
    -- [color=ffffff]　[-][][-][color=ffffff]3、战斗出现超时，则算作双方同归于尽。[-][][-] \
    -- [color=ffffff]　[-][][-][color=ffffff]4、将军需要特别小心脚下的土地，当您踏入禁魔大地时，您的魔法值将无法得到回复。[-][][-] \
    -- [color=ffffff]　[-][][-][color=ffffff]5、征战途中，您会遇到各种建筑，拜访他们可以获得奖励。[-][][-] \
    -- "
    -- local desc =  "[color=ffffff]　[-][][-][color=ffffff]5、征战途中，您会遇到各种建筑，拜访他们可以获得奖励。[-][][-]"
    local desc = data.con
    -- local month = TimeUtils.getDateString(data.st + 86400,"%m")
    -- local day = TimeUtils.getDateString(data.st + 86400,"%d")
    -- local timer = month .. "月" .. day .. "日 20:00:00"
    -- desc = string.gsub(desc, "{$offerdate}", timer)
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
        local godWarModel = self._modelMgr:getModel("GodWarModel")
        local flag = godWarModel:getClickGodwarBtn()
        if flag == 0 then
            self._serverMgr:sendMsg("GodWarServer", "getJoinList", {}, true, {}, function (result)
                self._viewMgr:showView("godwar.GodWarView")
            end)
        elseif flag == 1 then
            local openTimeStr = godWarModel:getOpenTime()
            self._viewMgr:showTip(openTimeStr)
        elseif flag == 2 then
            local openTimeStr = godWarModel:getOpenTime1()
            self._viewMgr:showTip(openTimeStr)
        elseif flag == 3 then
            self._viewMgr:showTip(lang("ZHENGBASAI_HEFU_TIPS"))
        end
    end)
end

return GodWarInvitationDialog
