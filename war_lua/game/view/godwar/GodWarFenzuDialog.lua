--[[
    Filename:    GodWarFenzuDialog.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2017-05-04 22:12:58
    Description: File description
--]]

-- 分组决定弹窗
local GodWarFenzuDialog = class("GodWarFenzuDialog", BasePopView)

function GodWarFenzuDialog:ctor(param)
    GodWarFenzuDialog.super.ctor(self)
    self._callback = param.callback
end

function GodWarFenzuDialog:onInit()
    self:registerClickEventByName("closeBtn", function ()
        if OS_IS_WINDOWS then
            UIUtils:reloadLuaFile("godwar.GodWarFenzuDialog")
        end
        if self._callback then
            self._callback()
        end
        self:close()
    end)  

    self._godWarModel = self._modelMgr:getModel("GodWarModel")
    self._godWarModel:setGodWarShowType(1)
    local xiaoren = self:getUI("bg.xiaoren")
    xiaoren:loadTexture("asset/bg/global_reward3_img.png", 0)
    xiaoren:setVisible(false)

    local qizi = self:getUI("bg.qizi")
    qizi:setVisible(false)

    local des4 = self:getUI("bg.qizi.des4")
    local tip1 = lang("GODWAR_TIP_05")
    des4:setString(tip1)
    self:defPlayerSelf()
end

function GodWarFenzuDialog:defPlayerSelf()
    local flag = self._godWarModel:isMyJoin()
    local des4 = self:getUI("bg.qizi.des4")
    local des5 = self:getUI("bg.qizi.des5")
    local des6 = self:getUI("bg.qizi.des6")
    local leftIcon = self:getUI("bg.qizi.leftIcon")
    local rightIcon = self:getUI("bg.qizi.rightIcon")
    if flag == true then
        local groupNum = self._godWarModel:getMyGroup()
        des6:setString("第" .. groupNum .. "小组")
        des4:setVisible(false)
        des5:setVisible(true)
        des6:setVisible(true)
        leftIcon:setVisible(true)
        rightIcon:setVisible(true)
    else
        des4:setVisible(true)
        des5:setVisible(false)
        des6:setVisible(false)
        leftIcon:setVisible(false)
        rightIcon:setVisible(false)
    end
end 

function GodWarFenzuDialog:reflashUI()
    local xiaoren = self:getUI("bg.xiaoren")
    local move1 = cc.MoveBy:create(0.01, cc.p(-200, 0))
    local move2 = cc.MoveBy:create(0.05, cc.p(60, 0))
    local move3 = cc.MoveBy:create(0.1, cc.p(150, 0))
    local move4 = cc.MoveBy:create(0.1, cc.p(-10, 0))
    local callFunc = cc.CallFunc:create(function()
        xiaoren:setVisible(true)
    end)
    local seq = cc.Sequence:create(move1, callFunc, move2, move3, move4)
    xiaoren:runAction(seq)

    local qizi = self:getUI("bg.qizi")
    local qmove1 = cc.MoveBy:create(0.01, cc.p(0, 300))
    local qmove2 = cc.MoveBy:create(0.05, cc.p(0, -130))
    local qmove3 = cc.MoveBy:create(0.1, cc.p(0, -250))
    local qmove4 = cc.MoveBy:create(0.1, cc.p(0, 80))
    local callFunc = cc.CallFunc:create(function()
        qizi:setVisible(true)
    end)
    local seq = cc.Sequence:create(qmove1, callFunc, qmove2, qmove3, qmove4)
    qizi:runAction(seq)

    local bg = self:getUI("bg")
    local caidai = mcMgr:createViewMC("piaoluocaidai_leaguejinjiechenggong", true, false)
    caidai:setPosition(bg:getContentSize().width*0.5,bg:getContentSize().height*0.5+200)
    bg:addChild(caidai,5)
end

return GodWarFenzuDialog
