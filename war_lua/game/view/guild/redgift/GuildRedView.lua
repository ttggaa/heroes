--[[
    Filename:    GuildRedView.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2016-06-04 18:30:16
    Description: File description
--]]

-- 联盟红包
local GuildRedView = class("GuildRedView", BaseView, require("game.view.guild.GuildBaseView"))

function GuildRedView:ctor(data)
    GuildRedView.super.ctor(self)
    self.initAnimType = 6
    self._delayAnima = 100
end


function GuildRedView:onInit()
    local bg = self:getUI("bg")
    -- 系统红包
    local tab1 = self:getUI("bg.rightBg.tab1")
    -- 玩家发红包
    local tab2 = self:getUI("bg.rightBg.tab2")
    -- 玩家红包列表
    local tab3 = self:getUI("bg.rightBg.tab3")
    -- 历史记录
    local tab4 = self:getUI("bg.rightBg.tab4")

    tab1:setTitleFontName(UIUtils.ttfName)
    tab2:setTitleFontName(UIUtils.ttfName)
    tab3:setTitleFontName(UIUtils.ttfName)
    tab4:setTitleFontName(UIUtils.ttfName)

    local off = -20
    UIUtils:setTabChangeAnimEnable(tab1,off,function(sender)self:tabButtonClick(sender, 1)end)
    UIUtils:setTabChangeAnimEnable(tab2,off,function(sender)self:tabButtonClick(sender, 2)end)
    UIUtils:setTabChangeAnimEnable(tab3,off,function(sender)self:tabButtonClick(sender, 3)end)
    UIUtils:setTabChangeAnimEnable(tab4,off,function(sender)self:tabButtonClick(sender, 4)end)

    self._tabEventTarget = {}
    table.insert(self._tabEventTarget, tab1)
    table.insert(self._tabEventTarget, tab2)
    table.insert(self._tabEventTarget, tab3)
    table.insert(self._tabEventTarget, tab4)

    -- [[ 板子动画
    self._playAnimBg = self:getUI("bg.rightBg")
    self._playAnimBg:setOpacity(0)
    self._playAnimBgOffX = 49
    self._playAnimBgOffY = -20

    -- self._customOffX =0
    -- self._customOffY = -10 
    self._animBtns = self._tabEventTarget
    --]]
    -- local userData = self._modelMgr:getModel("UserModel"):getData()
    -- if userData.roleGuild["pos"] == 3 then
    --     tab4:setVisible(false)
    -- end


    self._modelMgr:getModel("GuildModel"):setQuitAlliance(false)
    self:listenReflash("UserModel", self.reflashQuitAlliance)
    self:listenReflash("GuildRedModel", self.reflashUI)
    self:listenReflash("VipModel", self.refreshSenderAnima)

    -- tab1:setVisible(false)
    -- self:tabButtonClick(tab1, 1)
    -- tab1._appearSelect = true
    self:initTabClick()
    
    -- self:addAnimBg()
end

function GuildRedView:initTabClick()
    local isShowBubble = self._modelMgr:getModel("GuildRedModel"):isShowHalfRed()
    if isShowBubble then
        local tab2 = self:getUI("bg.rightBg.tab2")
        -- tab1:setVisible(false)
        self:tabButtonClick(tab2, 2)
        tab2._appearSelect = true
    else
        local tab1 = self:getUI("bg.rightBg.tab1")
        tab1:setVisible(false)
        self:tabButtonClick(tab1, 1)
        tab1._appearSelect = true
    end
end
-- x1= x1+(xy-x1)*0.2


function GuildRedView:refreshSenderAnima()
    if self._senderRedLayer and self._senderRedLayer:isVisible() then
        self._senderRedLayer:initSugessAnima()
    end
end

function GuildRedView:beforePopAnim()
    
end

function GuildRedView:tabButtonClick(sender, key)
    if sender == nil then 
        return 
    end
    if self._tabName == sender:getName() then 
        return 
    end
    for k,v in pairs(self._tabEventTarget) do
        if v ~= sender then
            self:tabButtonState(v, false, k)
        end
    end
    if self._preBtn then
        UIUtils:tabChangeAnim(self._preBtn,nil,true)
    end
    self._preBtn = sender
    UIUtils:tabChangeAnim(sender,function( )
        self:tabButtonState(sender, true, key)
        audioMgr:playSound("Tab")

        local tempBaseInfoNode = self:getUI("bg.rightSubBg")

        if sender:getName() == "tab1" then
            print("This is signin")
            if self._sysRedLayer == nil then
                self._sysRedLayer = self:createLayer("guild.redgift.GuildRedSysLayer")
                tempBaseInfoNode:addChild(self._sysRedLayer)
            end
            self._sysRedLayer:setVisible(true)
            self._sysRedLayer:reflashUI(true)
            if self._robRedLayer then
                self._robRedLayer:setVisible(false)
            end
            if self._senderRedLayer then
                self._senderRedLayer:setVisible(false)
            end
            if self._historyRedLayer then
                self._historyRedLayer:setVisible(false)
            end
        elseif sender:getName() == "tab2" then
            print("This is create")
            if self._senderRedLayer == nil then
                self._senderRedLayer = self:createLayer("guild.redgift.GuildRedSenderLayer")
                tempBaseInfoNode:addChild(self._senderRedLayer)
            end
            self._senderRedLayer:setVisible(true)
            self._senderRedLayer:reflashUI()
            if self._sysRedLayer then
                self._sysRedLayer:setVisible(false)
            end
            if self._robRedLayer then
                self._robRedLayer:setVisible(false)
            end
            if self._historyRedLayer then
                self._historyRedLayer:setVisible(false)
            end
        elseif sender:getName() == "tab3" then
            print("This is GuildManageLogLayer")
            if self._robRedLayer == nil then
                self._robRedLayer = self:createLayer("guild.redgift.GuildRedRobLayer")
                tempBaseInfoNode:addChild(self._robRedLayer)
            end
            self._robRedLayer:setVisible(true)
            self._robRedLayer:reflashUI()
            if self._sysRedLayer then
                self._sysRedLayer:setVisible(false)
            end
            if self._senderRedLayer then
                self._senderRedLayer:setVisible(false)
            end
            if self._historyRedLayer then
                self._historyRedLayer:setVisible(false)
            end
        elseif sender:getName() == "tab4" then
            print("This is tab4")
            if self._historyRedLayer == nil then
                self._historyRedLayer = self:createLayer("guild.redgift.GuildRedHistoryLayer")
                tempBaseInfoNode:addChild(self._historyRedLayer)
            end
            self._historyRedLayer:setVisible(true)
            self._historyRedLayer:reflashUI()
            if self._sysRedLayer then
                self._sysRedLayer:setVisible(false)
            end
            if self._senderRedLayer then
                self._senderRedLayer:setVisible(false)
            end
            if self._robRedLayer then
                self._robRedLayer:setVisible(false)
            end
        end
    end)
end

function GuildRedView:tabButtonState(sender, isSelected, key)
    local titleNames = {
        " 红包 ",
        " 犒赏 ",
        " 领赏 ",
        " 历史 ",
    }
    local shortTitleNames = {
        " 红包 ",
        " 犒赏 ",
        " 领赏 ",
        " 历史 ",
    }

    local tabtxt = sender:getChildByFullName("tabtxt")
    tabtxt:setString("")

    sender:setBright(not isSelected)
    sender:setEnabled(not isSelected)
    sender:getTitleRenderer():disableEffect()
    -- sender:setTitleFontSize(30)
    -- sender:setTitleFontName(UIUtils.ttfName)
    if isSelected then
        sender:setTitleText(titleNames[key])
        sender:setTitleColor(UIUtils.colorTable.ccUITabColor2)
    else
        sender:setTitleText(shortTitleNames[key])
        sender:setTitleColor(UIUtils.colorTable.ccUITabColor1)
    end
end

-- function GuildRedView:tabButtonState(sender, isSelected)
--     local tabtxt = sender:getChildByFullName("tabtxt")
--     tabtxt:setFontName(UIUtils.ttfName)

--     sender:setBright(not isSelected)
--     sender:setEnabled(not isSelected)
--     -- tabtxt01:setVisible(not isSelected)
--     -- tabtxt02:setVisible( isSelected)

--     if isSelected then
--         tabtxt:setColor(UIUtils.colorTable.ccUITabColor2)
--         tabtxt:setFontSize(30)
--     else
--         tabtxt:setColor(UIUtils.colorTable.ccUITabColor1)
--         tabtxt:disableEffect()
--         tabtxt:setFontSize(30)
--     end
-- end

function GuildRedView:reflashUI()

    -- local userData = self._modelMgr:getModel("UserModel"):getData()
    -- local tab4 = self:getUI("bg.rightSubBg.tab4")
    -- if userData.roleGuild["pos"] == 3 then
    --     tab4:setVisible(false)
    -- else
    --     tab4:setVisible(true)
    -- end

    if self._robRedLayer and self._robRedLayer:isVisible() then
        self._robRedLayer:reflashUI()
    elseif self._sysRedLayer and self._sysRedLayer:isVisible() then
        self._sysRedLayer:reflashUI()
    elseif self._senderRedLayer and self._senderRedLayer:isVisible() then
        self._senderRedLayer:reflashUI()
    elseif self._historyRedLayer and self._historyRedLayer:isVisible() then
        self._historyRedLayer:reflashUI()
    end

end

function GuildRedView:onBeforeAdd(callback, errorCallback)
    self._onBeforeAddCallback = function(inType)
        print("inType =============", inType)
        if inType == 1 then 
            callback()
        else
            errorCallback()
            -- self._showMgr:unlock()
            -- self._showMgr:showTip("5点可参与红包活动")
        end
    end
    self:getGuildRed()
    
end

function GuildRedView:onAnimEnd( )
    -- local tab1 = self:getUI("bg.rightBg.tab1")
    -- self:tabButtonClick(tab1, 1)
    -- tab1._appearSelect = true
    local tab1 = self:getUI("bg.rightBg.tab1")
    if tab1 then
        tab1:setVisible(true)
    end
end

-- 获取红包数据
function GuildRedView:getGuildRed()
    self._serverMgr:sendMsg("GuildRedServer", "getGuildRed", {}, true, {}, function (result)
        self:getGuildRedFinish(result)
    end,function( errorCode )
        if errorCode == 2801 then
            self._viewMgr:showTip("退出联盟时间不足24小时")
            self._viewMgr:clearLock()
        end
    end)
end

function GuildRedView:getGuildRedFinish(result)
    -- dump(result,"result ===================")
    if result == nil then
        self._onBeforeAddCallback(2)
        return 
    end
    self._onBeforeAddCallback(1)
    self:reflashUI()
end

function GuildRedView:setNavigation()
    self._viewMgr:showNavigation("global.UserInfoView",{types = {"Texp","Gold","Gem"},title = "allicance_redLab.png",titleTxt = "联盟红包"})
end

function GuildRedView:getAsyncRes()
    return {{"asset/ui/alliancered.plist", "asset/ui/alliancered.png"}}
end

function GuildRedView:getBgName()
    return "bg_007.jpg"
end

function GuildRedView:setNoticeBar()
    self._viewMgr:hideNotice(true)
end

return GuildRedView