--[[
    Filename:    MainActionOpenDialog.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2016-02-17 10:50:01
    Description: File description
--]]

local MainActionOpenDialog = class("MainActionOpenDialog",BasePopView)

function MainActionOpenDialog:ctor(param)
    self.super.ctor(self)
    self._inType = param.inType 
    self._userModel = self._modelMgr:getModel("UserModel")
end

-- 初始化UI后会调用, 有需要请覆盖
function MainActionOpenDialog:onInit()
    self._name = self:getUI("bg.showBg.name")
    self._icon = self:getUI("bg.showBg.icon")
    self._levelOpen = self:getUI("bg.showBg.levelOpen")
    self._des = self:getUI("bg.showBg.des")

    local bgLayer = ccui.Layout:create()
    bgLayer:setTouchEnabled(true)
    bgLayer:setContentSize(MAX_SCREEN_WIDTH, MAX_SCREEN_HEIGHT)
    self:addChild(bgLayer, 1)
    registerClickEvent(bgLayer, function ()
        local mainViewModel = self._modelMgr:getModel("MainViewModel")
        mainViewModel:setQipao()
        mainViewModel:reflashMainView()
        self:close()
    end)

    self:setActionAdvance()
end

-- 接收自定义消息
function MainActionOpenDialog:reflashUI(data)

end


-- 设置新功能开启预告
function MainActionOpenDialog:setActionAdvance()
    local noticeType = 1
    local userlvl = self._modelMgr:getModel("UserModel"):getData().lvl 
    local userlevelTab = tab:UserLevel(userlvl)
    local systemnotice -- = userlevelTab.systemnotice

    local notice
    if self._inType == 1 then
        systemnotice = userlevelTab.systemnotice
        notice = tab:SystemDes(systemnotice)
    else
        systemnotice = self._modelMgr:getModel("MainViewModel"):isShowNotice()
        notice = tab:STimeOpen(systemnotice)
    end

    -- local notice = tab:SystemDes(systemnotice)
    self._name:setString(lang(notice.name))
    self._name:setFontName(UIUtils.ttfName)
    self._name:setColor(cc.c3b(251, 243, 134))
    self._name:enable2Color(1, cc.c4b(242, 161, 46, 255))
    self._name:enableOutline(cc.c4b(96, 31, 0, 255), 2)
    self._name:setFontSize(36)

    self._levelOpen:setColor(cc.c3b(255, 240, 194))
    self._levelOpen:enableOutline(cc.c4b(81, 61, 36, 255), 2)
    if self._inType == 2 then
        local userData = self._modelMgr:getModel("UserModel"):getData()
        local sysOpenTime = userData.sec_open_time
        local tempTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(sysOpenTime,"%Y-%m-%d 05:00:00"))
        if sysOpenTime < tempTime then
            sysOpenTime = sysOpenTime - 86400
        end
        local openTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(sysOpenTime + notice["opentime"]*86400,"%Y-%m-%d 00:00:00"))
        local subTime = 86400 - (notice["openhour"])*3600
        local tempTime = openTime - self._modelMgr:getModel("UserModel"):getCurServerTime() - subTime
        if notice.prevelege == 0 then
            if tempTime > 0 then
                -- tempTime = tempTime - self._modelMgr:getModel("UserModel"):getCurServerTime() + 1
                self._levelOpen:runAction(cc.RepeatForever:create(
                    cc.Sequence:create(cc.CallFunc:create(function()
                        tempTime = openTime - self._modelMgr:getModel("UserModel"):getCurServerTime() - subTime
                        local tempValue = tempTime
                        local hour, minute, second
                        hour = math.floor(tempValue/3600)
                        tempValue = tempValue - hour*3600
                        minute = math.floor(tempValue/60)
                        tempValue = tempValue - minute*60
                        second = math.fmod(tempValue, 60)
                        local showTime = string.format("%.2d:%.2d:%.2d", hour, minute, second)

                        if tempTime <= 0 then
                            showTime = "00:00:00"
                            self._levelOpen:stopAllActions()
                            self._levelOpen:setString(showTime)
                            self:close()
                            return
                        end
                        if self._levelOpen then
                            self._levelOpen:setString(showTime)
                        end
                    end), cc.DelayTime:create(1))
                ))
            else
                local str = notice.level .. "级开启"
                self._levelOpen:setString(str)  
            end
        else
            if userlvl >= notice.level then
                -- tempTime = tempTime - self._modelMgr:getModel("UserModel"):getCurServerTime() + 1
                self._levelOpen:runAction(cc.RepeatForever:create(
                    cc.Sequence:create(cc.CallFunc:create(function()
                        tempTime = tempTime - 1
                        local tempValue = tempTime
                        local hour, minute, second
                        hour = math.floor(tempValue/3600)
                        tempValue = tempValue - hour*3600
                        minute = math.floor(tempValue/60)
                        tempValue = tempValue - minute*60
                        second = math.fmod(tempValue, 60)
                        local showTime = string.format("%.2d:%.2d:%.2d", hour, minute, second)

                        if tempTime <= 0 then
                            showTime = "00:00:00"
                            self._levelOpen:stopAllActions()
                            self._levelOpen:setString(showTime)
                            self:close()
                            return
                        end
                        if self._levelOpen then
                            self._levelOpen:setString(showTime)
                        end
                    end), cc.DelayTime:create(1))
                ))
            else
                local str = notice.level .. "级开启"
                self._levelOpen:setString(str)  
            end
        end
    else
        local str = notice.level .. "级开启" -- string.gsub(lang(notice.des), "%b[]", "")
        self._levelOpen:setString(str)
    end

    str = string.gsub(lang(notice.des), "%b[]", "")
    self._des:setString(str)
    self._des:setColor(cc.c3b(183, 143, 91))

    self._icon:loadTexture(IconUtils.iconPath .. notice.art .. ".png", 1)
    local mc = mcMgr:createViewMC("jinjiewupinguang_comtreasurebg", true, false,nil,RGBA8888)
    mc:setName("anim")
    mc:setPosition(self._icon:getContentSize().width * 0.5, self._icon:getContentSize().height * 0.5)
    self._icon:addChild(mc, -1)

    self._levelOpen:setPositionX(self._name:getPositionX() + self._name:getContentSize().width + 10)

end

return MainActionOpenDialog 