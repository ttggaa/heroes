--[[
    Filename:    GodWarMatchTimeDialog.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2017-04-20 10:52:12
    Description: File description
--]]

-- 赛程
local GodWarMatchTimeDialog = class("GodWarMatchTimeDialog", BasePopView)

function GodWarMatchTimeDialog:ctor()
    GodWarMatchTimeDialog.super.ctor(self)
end

function GodWarMatchTimeDialog:getAsyncRes()
    return {
        {"asset/ui/godwar2.plist", "asset/ui/godwar2.png"},
    }
end

function GodWarMatchTimeDialog:onInit()
    self:registerClickEventByName("bg.closeBtn", function ()
        if OS_IS_WINDOWS then
            UIUtils:reloadLuaFile("godwar.GodWarMatchTimeDialog")
        end
        self.dontRemoveRes = true
        self:close()
    end)  

    local titleLab = self:getUI("bg.layer.titleLab")
    local leftAdorn = self:getUI("bg.layer.leftAdorn")
    if leftAdorn ~= nil then
        leftAdorn:setPositionX(titleLab:getPositionX() - titleLab:getContentSize().width * 0.5 - 30)
    end
    local rightAdorn = self:getUI("bg.layer.rightAdorn")
    if rightAdorn ~= nil then
        rightAdorn:setPositionX(titleLab:getPositionX() + titleLab:getContentSize().width * 0.5 + 30)
    end

    self._userModel = self._modelMgr:getModel("UserModel")
    self._godWarModel = self._modelMgr:getModel("GodWarModel")

    for i=1,7 do
        local anpai = self:getUI("bg.layer.anpai" .. i)
        local weekdey = anpai:getChildByFullName("weekdey")
        local time = anpai:getChildByFullName("time")
        local pname = anpai:getChildByFullName("pname")
        local jinxing = anpai:getChildByFullName("jinxing")

        time:setString(lang("GODWARTIME_" .. i))
        pname:setString(lang("GODWARPART_" .. i))
        weekdey:setString(lang("GODWARDATE_" .. i))
    end
end

function GodWarMatchTimeDialog:reflashUI()
    local state, staIndexId = self._godWarModel:getStatus()
    local curServerTime = self._userModel:getCurServerTime()
    local warMatchTime = self._godWarModel:getGodWarMatchTime()
    local warMatchData = warMatchTime[staIndexId]
    for i=1,7 do
        local anpai = self:getUI("bg.layer.anpai" .. i)
        local pname = anpai:getChildByFullName("pname")
        local jinxing = anpai:getChildByFullName("jinxing")
        local jieshu = anpai:getChildByFullName("jieshu")

        local flag = 1
        if state > i then
            flag = 4
        elseif state == i then
            if state == 1 then
                flag = 3
            elseif state == 2 then
                flag = 3
            else
                if warMatchData[4] == 0 then
                    flag = 2
                elseif warMatchData[4] == 1 then
                    if curServerTime > warMatchData[2] then
                        flag = 3
                    else
                        flag = 2
                    end
                else
                    flag = 4
                end
            end
        end
        print("flao===========",state, flag)
        if flag == 2 then -- 即将开始
            jieshu:setVisible(false)
            jinxing:setColor(cc.c3b(255,238,160))
            jinxing:setString("(即将开始)")
            jinxing:setVisible(true)
        elseif flag == 3 then -- 正在进行
            jieshu:setVisible(false)
            jinxing:setVisible(true)
            jinxing:setColor(cc.c3b(28,162,22))
            jinxing:setString("(正在进行)")
            
            local jinxingzhong = mcMgr:createViewMC("jinxingzhong_guanjundansheng", true, false)
            jinxingzhong:setPosition(anpai:getContentSize().width*0.5-2, anpai:getContentSize().height*0.5+1)
            jinxingzhong:setName("jinxingzhong")
            anpai:addChild(jinxingzhong)
        elseif flag == 4 then -- 已结束
            jieshu:setVisible(true)
            jinxing:setVisible(false)
        else
            jieshu:setVisible(false)
            jinxing:setVisible(false)
        end
    end
end


return GodWarMatchTimeDialog
