--[[
    Filename:    GuildManageNewView.lua
    Author:      <lishunan@playcrab.com>
    Datetime:    2016-04-11 14:56:20
    Description: File description
--]]

-- 联盟管理界面,二级弹窗
local GuildManageNewView = class("GuildManageNewView", BasePopView, require("game.view.guild.GuildBaseView"))

function GuildManageNewView:ctor()


    GuildManageNewView.super.ctor(self)
    self._membersData = {}
    self.initAnimType = 3
    self._needClean = false
    cc.SpriteFrameCache:getInstance():addSpriteFrames("asset/ui/alliance1.plist", "asset/ui/alliance1.png")
    cc.SpriteFrameCache:getInstance():addSpriteFrames("asset/ui/alliance2.plist", "asset/ui/alliance2.png")

end

function GuildManageNewView:onInit()

    print("GuildManageNewView:onInit")
    -- [[ 板子动画
    self._playAnimBg = self:getUI("bg.rightBg")
    self._playAnimBgOffX = 0
    self._playAnimBgOffY = -30
    --]]
    self._userModel = self._modelMgr:getModel("UserModel")
    self._guildModel = self._modelMgr:getModel("GuildModel")

    local allianceName = self:getUI("bg.allianceName")
    -- allianceName:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    -- allianceName:setFontName(UIUtils.ttfName)

    local userData = self._userModel:getData()
    local huizhang = self:getUI("bg.huizhang")
    self._btnLayer = self:getUI("bg.chengyuan")
    if userData.roleGuild["pos"] == 3 then
        huizhang:setVisible(false)
        self._btnLayer:setVisible(true)
    else
        self._btnLayer:setVisible(false)
        huizhang:setVisible(true)
        self._btnLayer = huizhang
    end

    self._shouci = self:getUI("bg.shouci")
    local seq = cc.Sequence:create(cc.ScaleTo:create(1, 1+1*0.2), cc.ScaleTo:create(1, 1))
    self._shouci:runAction(cc.RepeatForever:create(seq))
    self._shouci:setVisible(false)
    local shouciLab = self:getUI("bg.shouci.lab")
    shouciLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    local bindBtn = self._btnLayer:getChildByFullName("bindingqq")
    -- UIUtils:setButtonFormat(bindBtn, 3)
    bindBtn:setVisible(false)
    bindBtn:setTitleFontSize(14)
    local bindBtn = self._btnLayer:getChildByFullName("bindingwx")
    -- UIUtils:setButtonFormat(bindBtn, 3)
    bindBtn:setVisible(false)
    bindBtn:setTitleFontSize(14)

    --已加入群提示
    self._haveIn = self:getUI("bg.chengyuan.have_in")
    self._haveIn:setVisible(false)

    self._pingtai = "bindingqq"
    local sdkMgr = SdkManager:getInstance()
    if sdkMgr:isQQ() then
        self._pingtai = "bindingqq"
    elseif sdkMgr:isWX() then
        self._pingtai = "bindingwx"
    end

    self:setBtnFont()

    self._playerCell = self:getUI("cell")
    self._playerCell:setVisible(false)
    self:addTableView()

    -- 审核上的红点
    local userData = self._userModel:getData()
    local hintTip = self:getUI("bg.huizhang.agreeBtn.hintTip")
    if userData.guildApply ~= 0 then
        hintTip:setVisible(true)
    else
        hintTip:setVisible(false)
    end

    -- 联盟必须监听
    self._modelMgr:getModel("GuildModel"):setQuitAlliance(false)
    self:listenReflash("GuildModel", self.reflashUI)
    self:listenReflash("UserModel", self.reflashQuitAlliance)
    -- 通用动态背景
    self:addAnimBg()
end

-- 更新公告
function GuildManageNewView:updateGonggao()
    local allianceDetail = self._modelMgr:getModel("GuildModel"):getAllianceDetail()
    local gonggao = self:getUI("bg.gonggao")
    if allianceDetail["notice"] == "" then
        gonggao:setString(lang("GUIlDENOTICE_WORD"))
    else
        gonggao:setString(allianceDetail["notice"])
    end
end

-- 设置按钮
function GuildManageNewView:setBtnFont()
    -- 改名
    local changeNameCallback = function()
        if self._userModel:getData()["roleGuild"]["pos"] == 3 then
            self._viewMgr:showTip(lang("GUILD_AUTHORITY_LIMIT"))
            return
        end
        self._viewMgr:showDialog("guild.manager.GuildChangeNameDialog",{callback = function(str)
            local allianceName = self:getUI("bg.allianceName")
            allianceName:setString(str)
        end})
    end
    local changeName = self._btnLayer:getChildByFullName("changeNameBtn") 
    if changeName then
        self:registerClickEvent(changeName, function()
            changeNameCallback()
        end)
    end
    local changeNameBtn = self._btnLayer:getChildByFullName("changeName") 
    if changeNameBtn then
        changeNameBtn:setScaleAnim(true)
        self:registerClickEvent(changeNameBtn, function()
            changeNameCallback()
        end)
    end

    -- 修改旗子
    local changeFlagFun = function( ... )
        if self._userModel:getData()["roleGuild"]["pos"] == 3 then
            self._viewMgr:showTip(lang("GUILD_AUTHORITY_LIMIT"))
            return
        end
        self._viewMgr:showDialog("guild.dialog.GuildSelectFlagsDialog", {callback = function(param)
            self._acatar = param
            local guildModel = self._modelMgr:getModel("GuildModel")
            local allianceD = guildModel:getAllianceDetail()
            allianceD.avatar1 = self._acatar.avatar1
            allianceD.avatar2 = self._acatar.avatar2
            self:createAvatar()
        end})
        print("修改联盟旗子")
    end

    local headAllianceBtn = self._btnLayer:getChildByFullName("headAllianceBtn")
    self._acatar = {}
    if headAllianceBtn then
        self:registerClickEvent(headAllianceBtn, function()
            changeFlagFun()
        end)
    end
    
    local allianceBtnImg = self:getUI("bg.huizhang.headAllianceBtn.Image_131")
    allianceBtnImg:setTouchEnabled(true)
    allianceBtnImg:setScaleAnim(true)
    self:registerClickEvent(allianceBtnImg, function()
        changeFlagFun()
    end)

    -- 公告
    self:updateGonggao()
    local gonggaoCallback = function()
        if self._userModel:getData()["roleGuild"]["pos"] == 3 then
            self._viewMgr:showTip(lang("GUILD_AUTHORITY_LIMIT"))
            return
        end
        self._viewMgr:showDialog("guild.dialog.GuildChangeADDialog")
    end
    local gonggaoBtn = self._btnLayer:getChildByFullName("gonggaoBtn")
    if gonggaoBtn then
        self:registerClickEvent(gonggaoBtn, function()
            gonggaoCallback()
        end)
    end
   
    local gonggaoxiugai = self._btnLayer:getChildByFullName("xiugai")
    if gonggaoxiugai then
        gonggaoxiugai:setScaleAnim(true)
        self:registerClickEvent(gonggaoxiugai, function()
            gonggaoCallback()
        end)
    end

    -- 日志列表
    local getLogBtn = self._btnLayer:getChildByFullName("getLogBtn") -- self:getUI("bg.getLogBtn")
    self:registerClickEvent(getLogBtn, function()
        -- self._viewMgr:showDialog("guild.manager.GuildManageLogLayer")
        if self:checkCondition() then return end
        self:getGuildEvent()
        print("查看日志")
    end)

    -- 进入联盟
    local jinru = self:getUI("bg.jinru")
    self:registerClickEvent(jinru, function()
        local roleGuild = self._modelMgr:getModel("UserModel"):getData().roleGuild
        if roleGuild and roleGuild.guildId ~= 0 and roleGuild.guildId ~= "0" then
            if not self._viewMgr:isViewLoad("guild.GuildView") then
                self._viewMgr:showView("guild.GuildView")
            end
        else
            self._needClean = true
            self._viewMgr:showTip("你还没有联盟")
        end
        self:close()
    end)

    -- close
    local closeBtn = self:getUI("bg.closeBtn")
    self:registerClickEvent(closeBtn, function()
        self._needClean = true
        self:close()
    end)

    -- 世界招募
    local zhaomuBtn = self._btnLayer:getChildByFullName("zhaomuBtn")
    self._acatar = {}
    if zhaomuBtn then
        self:registerClickEvent(zhaomuBtn, function()
            if self:checkCondition(2) then return end

            local flag, showTimeStr = self._guildModel:getGuildJoinCDTime()
            if flag == true then
                local allianceD = self._guildModel:getAllianceDetail()
                local param1 = {
                    zhaomu = {
                        guildId = allianceD.guildId or -1, 
                        guildLevel = allianceD.level or 0,
                        guildName = allianceD.name or "", 
                        lvlimit = allianceD.lvlimit or 0}}

                --世界聊天招募  wangyan
                local _, isInfoBanned,sendData = self._modelMgr:getModel("ChatModel"):paramHandle("zhaomu", param1)
                if isInfoBanned == true then
                    self._chatModel:pushData(sendData)
                else
                    self._serverMgr:sendMsg("ChatServer", "sendMessage", sendData, true, {}, function (result)  end)   
                    self._viewMgr:showTip(lang("GUILD_RECRUIT_TIP_1"))
                end
               
            else
                local tempStr = string.gsub(lang("GUILD_RECRUIT_TIP_2"), "{$cd}", showTimeStr)
                self._viewMgr:showTip(tempStr)
            end
        end)
    end
    

    -- 审批管理
    local agreeBtn = self._btnLayer:getChildByFullName("agreeBtn")
    if agreeBtn then
        self:registerClickEvent(agreeBtn, function()
            if self:checkCondition(2) then return end

            self._viewMgr:showDialog("guild.manager.GuildManageAgreeLayer",{callback = function(str)
                local allianceValue6 = self:getUI("bg.xinxi.allianceValue6")
                allianceValue6:setString(str)
            end, callback1 = function()
                print("+++++++++++++++++++++++")
                -- 审核红点
                local userData = self._userModel:getData()
                local hintTip = self:getUI("bg.huizhang.agreeBtn.hintTip")
                if userData.guildApply ~= 0 then
                    hintTip:setVisible(true)
                else
                    hintTip:setVisible(false)
                end
            end})
            print("联盟审核")
        end)
    end
    
    -- 邮件
    local youjian = self._btnLayer:getChildByFullName("youjian")
    if youjian then
        if self._userModel:getData()["roleGuild"]["pos"] == 1 then
            youjian:setVisible(true)
        else
            youjian:setVisible(false)
        end
        self:registerClickEvent(youjian, function()
            if self:checkCondition(1) then return end
            local timesNum = self._modelMgr:getModel("GuildModel"):getSenderTimes()
            if timesNum > 0 then
                self._viewMgr:showDialog("mailbox.MailBoxSenderDialog", {})
            else
                self._viewMgr:showTip("发送次数已达今日上限，请明天再来")
            end
        end)
    end
    

    -- 群礼包
    local libao = self._btnLayer:getChildByFullName("libao")
    libao:setVisible(false)
    self:registerClickEvent(libao, function()
        sdkMgr:loadUrl({url = GameStatic.wxDiscussUrl})
        print(GameStatic.wxDiscussUrl)
    end)

    -- 绑定群
    local bindBtn = self._btnLayer:getChildByFullName(self._pingtai)
    -- UIUtils:setButtonFormat(bindBtn, 3)
    bindBtn:setVisible(true)
    if GameStatic.appleExamine == true then
        bindBtn:setVisible(false)
    end

    self:updateBindBtn()
end

--[[
    权限检测，checkType 1 检测联盟长权限，2 检测管理权限
]]
function GuildManageNewView:checkCondition(checkType)
    local guildId = self._userModel:getData().guildId
    if not guildId or guildId == 0 then
        self._viewMgr:returnMain()
        ViewManager:getInstance():showTip("您已被踢出联盟！")
        return true
    end
    if checkType == 2 then
        if self._userModel:getData()["roleGuild"]["pos"] == 3 then
            self._viewMgr:showTip(lang("GUILD_AUTHORITY_LIMIT"))
            return true
        end
    elseif checkType == 1 then
        if self._userModel:getData()["roleGuild"]["pos"] ~= 1 then
            self._viewMgr:showTip(lang("GUILD_AUTHORITY_LIMIT"))
            return true
        end
    end
end

function GuildManageNewView:onDestroy()
    if self._needClean == true then
        local sfc = cc.SpriteFrameCache:getInstance()
        local tc = cc.Director:getInstance():getTextureCache()
        sfc:removeSpriteFramesFromFile("asset/ui/alliance1.plist")
        tc:removeTextureForKey("asset/ui/alliance1.png")
        sfc:removeSpriteFramesFromFile("asset/ui/alliance2.plist")
        tc:removeTextureForKey("asset/ui/alliance2.png")
    end
    GuildManageNewView.super.onDestroy(self)
end


-- -- 设置按钮
-- function GuildManageNewView:setBtnPos(_type)
--     if true then
--         return
--     end
--     -- 审批管理
--     local agreeBtn = self._btnLayer:getChildByFullName("agreeBtn") 
--     -- 日志列表
--     local getLogBtn = self._btnLayer:getChildByFullName("getLogBtn")
--     -- 世界招募
--     local zhaomuBtn = self._btnLayer:getChildByFullName("zhaomuBtn")
--     -- 绑定
--     local bindBtn = self._btnLayer:getChildByFullName("exitBtn")

--     local userData = self._userModel:getData()
--     if userData.roleGuild["pos"] == 3 and _type == 1 then
--         -- if _type == 1 then
--         --     getLogBtn:setPosition(97, -73)
--         -- elseif _type == 2 then
--         --     getLogBtn:setPosition(39, -73)
--         --     bindBtn:setPosition(162, -73)
--         -- end
--     end
-- end

-- 更新绑定状态
function GuildManageNewView:updateBindBtn()
    local bindBtn = self._btnLayer:getChildByFullName(self._pingtai)

    if (not sdkMgr:isOpenBindGroup()) and (not sdkMgr:isOpenJoinGroup()) then
        bindBtn:setVisible(false)
        -- self:setBtnPos(1)
        return
    end

    local userData = self._userModel:getData()
    local roleGuild = userData.roleGuild
    local bindGuildGroup = roleGuild.bindGuildGroup
    if bindGuildGroup and bindGuildGroup == 1 then
        print("领取过钻石", bindGuildGroup)
        self._shouci:setVisible(false)
    else
        self._shouci:setVisible(true)
        if GameStatic.appleExamine == true then
            self._shouci:setVisible(false)
        end
    end

    local bindGroup = self._guildModel:getAllianceDetail().bindGroup
    dump(bindGroup, "bindGroup=======" , 10)
    if bindGroup == nil then 
        bindGroup = {}
    end
    if bindGroup.error and bindGroup.error == 1 then
        bindBtn:setTitleText("  加载中")
        registerClickEvent(bindBtn, function()
            self._viewMgr:showTip("加载中...")
        end)
        return
    end

    local status = 0
    local tempBtnNum = 1
    if bindGroup.hadBind == nil or bindGroup.hadBind == "" or tonumber(bindGroup.hadBind) == 0 then 
        status = 1
    end

    local libao = self._btnLayer:getChildByFullName("libao")
    libao:setVisible(false)
    if (roleGuild.pos == 1 and status == 0) or (roleGuild.pos ~= 1 and bindGroup.hadJoin == 1) then
        local sdkMgr = SdkManager:getInstance()
        if sdkMgr:isWX() == true then
            -- libao:setVisible(true)
        end
    end

    local allianceD = self._guildModel:getAllianceDetail()
    local guildName = allianceD.name
    local userData = self._userModel:getData()
    local guildPlayName = userData.name

    print("status==================", status)
    if status == 1 then -- 未绑定
        print("status=====1111=====", status)
        if roleGuild.pos == 1 then 
            print("bindPlatformGroup============绑定===")
            bindBtn:setTitleText("  绑定群")
            registerClickEvent(bindBtn, function()
                if self._userModel:getData()["roleGuild"]["pos"] ~= 1 then
                    self._viewMgr:showTip("你已不是联盟长")
                    return
                end
                self._requestBindState = 1
                print("bindPlatformGroup============绑定===")
                local param = {}
                param.union_id = tostring(userData.guildId)
                param.union_name = guildName
                param.room_name  = guildName
                param.sec = tostring(userData.sec)
                param.nick_name = guildPlayName
                sdkMgr:bindPlatformGroup(param, function(code, data)

                end)
            end)
        else
            self._shouci:setVisible(false)
            bindBtn:setTitleText("  提醒建群")
            -- bindBtn:setVisible(false)
            registerClickEvent(bindBtn, function()
                self._viewMgr:showTip("已提醒联盟长建群！")
            end)
        end
        tempBtnNum = 2
    elseif status == 0 then 
        print("status======0000====", status)
        if roleGuild.pos ~= 1 and bindGroup.hadJoin == 1 then 
            bindBtn:setTitleText("  加入群")
            registerClickEvent(bindBtn, function()
                -- self:applicationWillEnterForeground()
                self:getBindGuildInfo()
                self._viewMgr:showTip("您已加入联盟群")
            end)
        -- elseif roleGuild.pos ~= 1 and (bindGroup.hadJoin == nil or bindGroup.hadJoin == 0) then
        elseif bindGroup.hadJoin == nil or bindGroup.hadJoin == 0 then
            tempBtnNum = 2
            bindBtn:setTitleText("  加入群")
            print("bindPlatformGroup============加入===")
            registerClickEvent(bindBtn, function()
                self._requestBindState = 1
                local param = {}
                param.union_id = tostring(userData.guildId)
                param.union_name = guildName
                param.sec = tostring(userData.sec)
                param.nick_name = guildPlayName
                param.group_key = bindGroup.groupKey
                sdkMgr:joinPlatformGroup(param, function(code, data)

                end)
            end)
        elseif roleGuild.pos == 1 then
            tempBtnNum = 2 
            print("bindPlatformGroup============解绑===")
            bindBtn:setTitleText("  解  绑")
            registerClickEvent(bindBtn, function()
                if self._userModel:getData()["roleGuild"]["pos"] ~= 1 then
                    self._viewMgr:showTip("你已不是联盟长")
                    return
                end
                self:unBindGuild()
            end)
        end

        ----显示已加入群的提示
        if roleGuild.pos ~= 1 and bindGuildGroup and bindGuildGroup == 1 and bindGroup and bindGroup.hadJoin == 1 then
            bindBtn:setVisible(false)
            self._haveIn:setVisible(true)
        end
    end
    -- self:setBtnPos(2)
end

function GuildManageNewView:isGetGem()
    local isGetGem = nil
    local userData = self._userModel:getData()
    local roleGuild = userData.roleGuild
    if roleGuild and roleGuild.bindGuildGroup and roleGuild.bindGuildGroup == 1 then --领取过钻石
        isGetGem = true
    end
    return isGetGem
end

function GuildManageNewView:showGemReward(param)
    print("GuildManageNewView:showGemReward")
    DialogUtils.showGiftGet( {
        gifts = {num = 100,type = "gem",typeId = 0},
        title = "恭喜获得",
        callback = function()
        if param and param.callback then
            param.callback()
        end
    end})
end

    
-- 返回游戏获取绑定信息
function GuildManageNewView:applicationWillEnterForeground()
    if self._requestBindState == 1 then 
        local userData = self._userModel:getData()
        local roleGuild = userData.roleGuild
        local bindGroup = self._guildModel:getAllianceDetail().bindGroup
        if roleGuild.pos == 1 then 
            if bindGroup and bindGroup.hadBind and tonumber(bindGroup.hadBind) == 1 then
                self._serverMgr:sendMsg("GuildServer", "getGameGuildInfo", {}, true, {}, function (result)
                    if result then
                        dump(result,"GuildManageNewView:applicationWillEnterForeground=",10)
                        self:updateBindBtn()
                    end
                end)
            else
                self:bindGuild()
            end
        else
            self:getBindGuildInfo()
        end
        self._requestBindState = 0
    end
end

function GuildManageNewView:getBindGuildInfo()
    print("getBindGuildInfo=========================")
    -- local _isGetGem = self:isGetGem()
    self._serverMgr:sendMsg("GuildServer", "getBindGuildInfo", {}, true, {}, function (result)
        if result == nil then 
            return
        end
        dump(result, "test", 10)
        print("test==============-------------")
        local userData = self._userModel:getData()
        print("userData.guildId======================", userData.guildId, userData.sec)
        local roleGuild = userData.roleGuild
        self._guildModel:getAllianceDetail().bindGroup = result
        self:updateBindBtn()
        -- local status = self:isGetGem()
        if result.give and result.give == 1 then
            self:showGemReward()
        end
    end)
end

-- 解绑
function GuildManageNewView:unBindGuild()
    self._viewMgr:showDialog("global.GlobalMessageDialog", {desc = "是否确认解除绑定?", button = "确认", callback = function ()
        self._serverMgr:sendMsg("GuildServer", "unBindGuild", {}, true, {}, function (result)
            dump(result, "test" , 10)
            if result.res == 1 then
                local bindGroup = self._guildModel:getAllianceDetail().bindGroup
                self._guildModel:getAllianceDetail().bindGroup = {}
                self:updateBindBtn()
                self._viewMgr:showTip("解绑成功")
            end
        end)
    end})

end

function GuildManageNewView:bindGuild()
    print("GuildManageNewView:bindGuild")
    local _isGetGem = self:isGetGem()
    if _isGetGem then
        print("GuildManageNewView:bindGuild 1")
    else
        print("GuildManageNewView:bindGuild 2")
    end
    self._serverMgr:sendMsg("GuildServer", "bindGuild", {}, true, {}, function (result)
        if result == nil then 
            return
        end
        self._guildModel:getAllianceDetail().bindGroup = result
        self:updateBindBtn()

        local userData = self._userModel:getData()
        local roleGuild = userData.roleGuild

        local bindGroup = self._guildModel:getAllianceDetail().bindGroup
        if bindGroup == nil then 
            bindGroup = {}
        end
        if bindGroup.error and bindGroup.error == 1 then
            return
        end

        local status_ = self:isGetGem() 
        if status_ then
            print("GuildManageView:bindGuild 3")
        else
            print("GuildManageView:bindGuild 4")
        end
        if not _isGetGem and status_ then
            self:showGemReward({callback = function ()
                local status = 0
                local tempBtnNum = 1
                local bindGroup = self._guildModel:getAllianceDetail().bindGroup
                if bindGroup.hadBind == nil or bindGroup.hadBind == "" or tonumber(bindGroup.hadBind) == 0 then 
                    status = 1
                end
                if status == 1 then -- 未绑定
                elseif status == 0 then 
                    print("status======0000====", status)
                    if roleGuild.pos == 1 then
                        self._viewMgr:showDialog("mailbox.MailBoxSenderDialog", {ftype = 1})
                    end
                end
            end})
        else
            local status = 0
            local tempBtnNum = 1
            if bindGroup.hadBind == nil or bindGroup.hadBind == "" or tonumber(bindGroup.hadBind) == 0 then 
                status = 1
            end
            if status == 1 then -- 未绑定
            elseif status == 0 then 
                print("status======0000====", status)
                if roleGuild.pos == 1 then
                    self._viewMgr:showDialog("mailbox.MailBoxSenderDialog", {ftype = 1})
                end
            end
        end
    end)
end

-- function GuildManageNewView:getGuildGroupAward()
--     self._serverMgr:sendMsg("UserServer", "getGuildGroupAward", {}, true, {}, function (result)
--         if result == nil then 
--             return
--         end
--         DialogUtils.showGiftGet({gifts = result.reward})
--     end)
-- end

-- function GuildManageNewView:getGuildInfo()
--     self._serverMgr:sendMsg("GuildServer", "getGameGuildInfo", {}, true, {}, function (result)
--         self._modelMgr:getModel("GuildModel"):setGuildTempData(false)
--         self._tableView:reloadData()
--         -- self:getGuildInfoFinish(result)
--     end)
-- end

-- function GuildManageNewView:getGuildInfoFinish(result)
--     -- dump(result,"result ===================")
--     -- if result == nil then
--     --     self._onBeforeAddCallback(2)
--     --     return 
--     -- end
--     -- self._onBeforeAddCallback(1)
--     -- self:reflashUI()
-- end

function GuildManageNewView:reflashUI(data)

    print("刷新数据")
    dump(data, "data ----------====")

    -- if 1 then
    --     return
    -- end
    local guildModel = self._modelMgr:getModel("GuildModel")
    self._membersData = guildModel:getAllianceList()

    local allianceD = guildModel:getAllianceDetail()
    -- dump(self._membersData,"allianceD ========")
    local allianceName = self:getUI("bg.allianceName")
    allianceName:setString(allianceD.name)
    -- local allianceLevel = self:getUI("bg.allianceLevel")
    -- allianceLevel:setString("Lv. " .. allianceD.level)
    local allianceValue1 = self:getUI("bg.xinxi.allianceValue1")
    allianceValue1:setString(allianceD.mName)
    local allianceValue2 = self:getUI("bg.xinxi.allianceValue2")
    allianceValue2:setString(allianceD.guildId)
    local allianceValue3 = self:getUI("bg.xinxi.allianceValue3")
    allianceValue3:setString(allianceD.level)
    local allianceValue4 = self:getUI("bg.xinxi.allianceValue4")
    allianceValue4:setString(allianceD.rank)
    local allianceValue5 = self:getUI("bg.xinxi.allianceValue5")
    allianceValue5:setString(allianceD.roleNum .. "/" .. allianceD.roleNumLimit)

    local levelLab, needApply
    if allianceD.lvlimit == 0 then
        levelLab = ""
    else
        levelLab = allianceD.lvlimit .. "级"
    end
    if allianceD.status == 0 then
        needApply = "自由加入"
    else
        needApply = "需审核"
    end
    local str = levelLab .. needApply

    local allianceValue6 = self:getUI("bg.xinxi.allianceValue6")
    allianceValue6:setString(str)

    -- 联盟旗子
    self._acatar = {avatar1 = allianceD.avatar1, avatar2 = allianceD.avatar2}
    self:createAvatar()

    -- local changeName = self:getUI("bg.changeName")
    -- if self._modelMgr:getModel("UserModel"):getData()["roleGuild"]["pos"] ~= 3 then
    --     changeName:setVisible(true)
    -- else
    --     changeName:setVisible(false)
    -- end

    -- 成员列表
    if self._modelMgr:getModel("GuildModel"):getGuildTempData() == true then
        self:getGuildInfo1()
    else
        self:refreshNotReload()
    end
    self:updateGonggao()
end

function GuildManageNewView:refreshNotReload()
    if self._tableView then
        if not self._firstIn then
            self._firstIn = true
            self._tableView:reloadData()
        else
            local currentOff = self._tableView:getContentOffset().y
            self._tableView:reloadData()
            local minOff = self._tableView:minContainerOffset().y
            local adjustOff = math.max(minOff,currentOff)
            self._tableView:setContentOffset(cc.p(0,adjustOff))
        end
    end
end

function GuildManageNewView:updateCell(inView, data)
    if data == nil then
        return
    end
    -- dump(data,"data ====================")
    local userId = self._modelMgr:getModel("UserModel"):getData()["_id"]
    local cellBg = inView:getChildByFullName("cellBg")
    if cellBg then
        if userId == data["memberId"] then
            cellBg:loadTexture("globalPanelUI7_cellBg1.png", 1)
        else
            cellBg:loadTexture("globalPanelUI7_cellBg1.png", 1)
        end
    end

    local iconBg = inView:getChildByFullName("iconBg")
    if iconBg then
        local tencetTp = data["qqVip"]
        local param1 = {avatar = data.avatar, tp = 4,avatarFrame = data["avatarFrame"], tencetTp = tencetTp}
        local icon = iconBg:getChildByName("icon")
        if not icon then
            icon = IconUtils:createHeadIconById(param1)
            icon:setName("icon")
            icon:setScale(0.8)
            icon:setPosition(cc.p(-5,-8))
            iconBg:addChild(icon)
        else
            IconUtils:updateHeadIconByView(icon, param1)
        end
    end

    local name = inView:getChildByFullName("name")
    if name then
        name:setString(data.name)
    end

    local level = inView:getChildByFullName("level")
    if level and data.lvl then
        local inParam = {lvlStr = "Lv." .. data.lvl, lvl = data.lvl, plvl = data.plvl}
        tempLevl = UIUtils:adjustLevelShow(level, inParam, 1)
    end

    local vipImg = inView:getChildByFullName("vipImg")
    if vipImg and data.vipLvl then
        local isHideVip = UIUtils:isHideVip(data.hideVip,"guild")
        if data.vipLvl == 0 or isHideVip then
            vipImg:setVisible(false)
        else
            vipImg:setVisible(true)
        end
        -- vipImg:setString("V" .. data.vipLvl)  
        vipImg:loadTexture("chatPri_vipLv" .. math.max(1, data.vipLvl) .. ".png", 1)
        -- vipLab:setPositionX(level:getPositionX() + level:getContentSize().width + 5)
    end

    local jobLab = inView:getChildByFullName("jobLab")
    if jobLab then
        if data.pos == 1 then
            jobLab:setString("联盟长")
            -- jobLab:setColor(cc.c3b(255,214,24))
            -- jobLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        elseif data.pos == 2 then
            jobLab:setString("副联盟长")
            -- jobLab:setColor(cc.c3b(255,214,24))
            -- jobLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        elseif data.pos == 3 then
            jobLab:setString("成员")
            -- jobLab:setColor(cc.c3b(72,210,255))
            -- jobLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        end
    end

    local loginTime = inView:getChildByFullName("loginTime")
    if loginTime then
        if data.online == 1 then
            loginTime:setString("在线")
            loginTime:setColor(cc.c4b(28, 162, 22, 255))
        else
            local des,color = GuildUtils:getLoginTimeDes(data.lt)
            loginTime:setString(des)
            if color then
                loginTime:setColor(color)
            else
                loginTime:setColor(cc.c4b(78, 50, 13, 255))
            end
        end
    end

    local contribeValue = inView:getChildByFullName("contribeValue")
    if contribeValue then
        contribeValue:setString(data.dNum)
    end
    
    local todayNum = inView:getChildByFullName("todayValue_0")
    if todayNum and data.ddnum then
        local str = "(今日:"..data.ddnum..")"
        todayNum:setString(str)
    end

    --启动特权类型
--	data["tequan"] = "sq_gamecenter"
	local tequanImg = IconUtils.tencentIcon[data["tequan"]] or "globalImageUI6_meiyoutu.png"

    if inView.tequanIcon == nil then
	    local tequanIcon = ccui.ImageView:create(tequanImg, 1)
        tequanIcon:setScale(0.65)
        tequanIcon:setPosition(cc.p(156, 15))
	    inView:addChild(tequanIcon)
        inView.tequanIcon = tequanIcon
    else
        inView.tequanIcon:loadTexture(tequanImg, 1)
    end
end

-- 退出联盟
function GuildManageNewView:quitGuild()
    print("载入=============数据====")
    self._serverMgr:sendMsg("GuildServer", "quitGuild", {}, true, {}, function (result)
        -- self._callback()
        -- self:quitGuildFinish(result)

        --删除全局抢红包界面  wangyan
        if self._viewMgr._redBoxLayer.robLayer ~= nil then
            self._viewMgr._redBoxLayer.robLayer:removeFromParent(true)
            self._viewMgr._redBoxLayer.robLayer = nil
        end
    end)
end 

-- function GuildManageNewView:quitGuildFinish(result)
--     if result == nil then 
--         return 
--     end
-- end

function GuildManageNewView:createAvatar()
    local iconBg = self:getUI("bg.iconBg")
    local avatarIcon = iconBg:getChildByName("avatarIcon")
    local param = {flags = self._acatar.avatar1, logo = self._acatar.avatar2}
    -- dump(param)
    if not avatarIcon then
        -- print("11111111111111")
        avatarIcon = IconUtils:createGuildLogoIconById(param)
        avatarIcon:setPosition(7, 10)
        avatarIcon:setName("avatarIcon")
        avatarIcon:setScale(0.85)
        iconBg:addChild(avatarIcon)
    else
        -- print("111111111111112")
        IconUtils:updateGuildLogoIconByView(avatarIcon, param)
    end
end

-- 快速加入
function GuildManageNewView:quickJoinGuild()
    local allianceId = self._modelMgr:getModel("UserModel"):getData().guildId
    if allianceId and allianceId ~= 0 then
        self._viewMgr:showTip("你已加入联盟")
        self._viewMgr:showView("guild.GuildView")
        self._viewMgr:popView()
        return
    end
    print("快速加入")
    self._serverMgr:sendMsg("GuildServer", "joinGuildQuickly", {}, true, {}, function(result)
        dump(result)
        self._viewMgr:showView("guild.GuildView")
        self._viewMgr:popView()
    end, function(errorId)
        if tonumber(errorId) == 2715 then
            self._viewMgr:showTip("未找到合适的联盟")
        end
    end)
end

-- function GuildManageNewView:onBeforeAdd(callback, errorCallback)

--     print("GuildManageNewView:onBeforeAdd")
--     self._onBeforeAddCallback = function(inType) cc.SpriteFrameCache:getInstance():addSpriteFrames("asset/anim/datianshiimage.plist", "asset/anim/datianshiimage.png")
--         if inType == 1 then 
--             callback()
--         else
--             errorCallback()
--         end
--     end
--     self:getGuildInfo()
-- end

function GuildManageNewView:getGuildInfo1()
    self._serverMgr:sendMsg("GuildServer", "getGameGuildInfo", {}, true, {}, function (result)
        self._modelMgr:getModel("GuildModel"):setGuildTempData(false)
        self:reflashUI()
    end)
end

function GuildManageNewView:getGuildInfo()
    self._serverMgr:sendMsg("GuildServer", "getGameGuildInfo", {}, true, {}, function (result)
        self:getGuildInfoFinish(result)
    end)
end

function GuildManageNewView:getGuildInfoFinish(result)
    dump(result,"result ===================")
    if result == nil then
        self._onBeforeAddCallback(2)
        return 
    end
    self._onBeforeAddCallback(1)
    self._modelMgr:getModel("GuildModel"):setGuildTempData(false)
    self:reflashUI()
    self:updateBindBtn()
end

function GuildManageNewView:getAsyncRes()
    return {
    -- {"asset/ui/alliance.plist", "asset/ui/alliance.png"},
    -- {"asset/ui/alliance1.plist", "asset/ui/alliance1.png"},
    -- {"asset/ui/alliance2.plist", "asset/ui/alliance2.png"}
}
end

-- 渲染时会调用, 改变元件坐标在这里
function GuildManageNewView:onAdd()

end


function GuildManageNewView:getMaskOpacity()
    return 178
end



function GuildManageNewView:onPopEnd()
    print("GuildManageNewView:onPopEnd")
    if (not sdkMgr:isOpenBindGroup()) and (not sdkMgr:isOpenJoinGroup()) then
        return
    end
    local userData = self._userModel:getData()
    local roleGuild = userData.roleGuild

    local bindGroup = self._guildModel:getAllianceDetail().bindGroup
    dump(bindGroup, "bindGroup=======" , 10)
    if bindGroup == nil then 
        bindGroup = {}
    end
    if bindGroup.error and bindGroup.error == 1 then
        return
    end

    local status = 0
    local tempBtnNum = 1
    if bindGroup.hadBind == nil or bindGroup.hadBind == "" or tonumber(bindGroup.hadBind) == 0 then 
        status = 1
    end

    -- local flag = self._modelMgr:getModel("GuildModel"):getGuildADJoinShow()
    -- if flag == 0 then
    --     return
    -- elseif flag == 2 then
    --     local rand = GRandom(100)
    --     if rand < 80 then
    --         return
    --     end
    -- end
    
    local result = self._modelMgr:getModel("GuildModel"):checkJoinOrBindTips()
    if not result then
       return 
    end

    local allianceD = self._guildModel:getAllianceDetail()
    local guildName = allianceD.name
    local userData = self._userModel:getData()
    local guildPlayName = userData.name

    local callback
    local stype = 0
    print("status==================", status)
    if status == 1 then -- 未绑定
        print("status=====1111=====", status)
        if roleGuild.pos == 1 then 
            stype = 1
            callback = function()
                if self._userModel:getData()["roleGuild"]["pos"] ~= 1 then
                    self._viewMgr:showTip("你已不是联盟长")
                    return
                end
                self._requestBindState = 1
                print("bindPlatformGroup============绑定===")
                local param = {}
                param.union_id = tostring(userData.guildId)
                param.union_name = guildName
                param.room_name  = guildName
                param.sec = tostring(userData.sec)
                param.nick_name = guildPlayName
                sdkMgr:bindPlatformGroup(param, function(code, data)

                end)
            end
        end
        tempBtnNum = 2
    elseif status == 0 then 
        print("status======0000====", status)
        if roleGuild.pos ~= 1 and (bindGroup.hadJoin == nil or bindGroup.hadJoin == 1) then 
            -- self._viewMgr:showTip("您已加入联盟群")
            return
        elseif roleGuild.pos ~= 1 and (bindGroup.hadJoin == nil or bindGroup.hadJoin == 0) then
            stype = 2
            callback = function()
                self._requestBindState = 1
                local param = {}
                param.union_id = tostring(userData.guildId)
                param.union_name = guildName
                param.sec = tostring(userData.sec)
                param.nick_name = guildPlayName
                param.group_key = bindGroup.groupKey
                sdkMgr:joinPlatformGroup(param, function(code, data)

                end)
            end
            print("bindPlatformGroup============加入群===")
        end
    end

    print("===========stypestypestypestype==", stype)

    if GameStatic.appleExamine == true then
        return
    end

    if stype == 1 then
        ---当联盟里只有联盟长一个人时，联盟长不会弹出提醒建群的提示 优化#11184
        local memberCount = table.nums(self._guildModel:getAllianceList())
        if memberCount <= 1 then
            return
        end
        self._viewMgr:showDialog("guild.dialog.GuildTipBindDialog", {callback = callback})
    elseif stype == 2 then
        self._viewMgr:showDialog("guild.dialog.GuildTipJoinDialog", {callback = callback})
    end

end


-- -- 切换动画完毕时候调用, 界面动画在这里, 发请求最好也在这里
-- function GuildManageNewView:onAnimEnd()

--     print("GuildManageNewView:onAnimEnd")
--     if (not sdkMgr:isOpenBindGroup()) and (not sdkMgr:isOpenJoinGroup()) then
--         return
--     end

--     local userData = self._userModel:getData()
--     local roleGuild = userData.roleGuild

--     local bindGroup = self._guildModel:getAllianceDetail().bindGroup
--     dump(bindGroup, "bindGroup=======" , 10)
--     if bindGroup == nil then 
--         bindGroup = {}
--     end
--     if bindGroup.error and bindGroup.error == 1 then
--         return
--     end

--     local status = 0
--     local tempBtnNum = 1
--     if bindGroup.hadBind == nil or bindGroup.hadBind == "" or tonumber(bindGroup.hadBind) == 0 then 
--         status = 1
--     end

--     -- local flag = self._modelMgr:getModel("GuildModel"):getGuildADJoinShow()
--     -- if flag == 0 then
--     --     return
--     -- elseif flag == 2 then
--     --     local rand = GRandom(100)
--     --     if rand < 80 then
--     --         return
--     --     end
--     -- end

--     local allianceD = self._guildModel:getAllianceDetail()
--     local guildName = allianceD.name
--     local userData = self._userModel:getData()
--     local guildPlayName = userData.name

--     local callback
--     local stype = 0
--     print("status==================", status)
--     if status == 1 then -- 未绑定
--         print("status=====1111=====", status)
--         if roleGuild.pos == 1 then 
--             stype = 1
--             callback = function()
--                 if self._userModel:getData()["roleGuild"]["pos"] ~= 1 then
--                     self._viewMgr:showTip("你已不是联盟长")
--                     return
--                 end
--                 self._requestBindState = 1
--                 print("bindPlatformGroup============绑定===")
--                 local param = {}
--                 param.union_id = userData.guildId
--                 param.union_name = guildName
--                 param.sec = userData.sec
--                 param.nick_name = guildPlayName
--                 sdkMgr:bindPlatformGroup(param, function(code, data)

--                 end)
--             end
--         end
--         tempBtnNum = 2
--     elseif status == 0 then 
--         print("status======0000====", status)
--         if roleGuild.pos ~= 1 and (bindGroup.hadJoin == nil or bindGroup.hadJoin == 1) then 
--             -- self._viewMgr:showTip("您已加入联盟群")
--             return
--         elseif roleGuild.pos ~= 1 and (bindGroup.hadJoin == nil or bindGroup.hadJoin == 0) then
--             stype = 2
--             callback = function()
--                 self._requestBindState = 1
--                 local param = {}
--                 param.union_id = userData.guildId
--                 param.union_name = guildName
--                 param.sec = userData.sec
--                 param.nick_name = guildPlayName
--                 param.group_key = bindGroup.groupKey
--                 sdkMgr:joinPlatformGroup(param, function(code, data)

--                 end)
--             end
--             print("bindPlatformGroup============加入群===")
--         end
--     end

--     print("===========stypestypestypestype==", stype)


--     if stype == 1 then
--         ---当联盟里只有联盟长一个人时，联盟长不会弹出提醒建群的提示 优化#11184
--         local memberCount = table.nums(self._guildModel:getAllianceList())
--         if memberCount <= 1 then
--             return
--         end
--         self._viewMgr:showDialog("guild.dialog.GuildTipBindDialog", {callback = callback})
--     elseif stype == 2 then
--         self._viewMgr:showDialog("guild.dialog.GuildTipJoinDialog", {callback = callback})
--     end
-- end


-- 查看日志
function GuildManageNewView:getGuildEvent()
    local param = {defId = 0, type = 2}
    self._serverMgr:sendMsg("GuildServer", "getGuildEvent", param, true, {}, function (result)
        -- self._logData = self._modelMgr:getModel("GuildModel"):getLogData()
        -- self._tableView:reloadData()
        self._viewMgr:showDialog("guild.manager.GuildManageLogLayer")
    end)
end 


--[[
用tableview实现
--]]
function GuildManageNewView:addTableView()
    local tableViewBg = self:getUI("bg.bg1.tableViewBg")
    self._tableView = cc.TableView:create(cc.size(tableViewBg:getContentSize().width, tableViewBg:getContentSize().height))
    self._tableView:setDelegate()
    self._tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self._tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._tableView:setPosition(cc.p(0, 0))
    self._tableView:registerScriptHandler(function(table, cell) return self:tableCellTouched(table,cell) end,cc.TABLECELL_TOUCHED)
    self._tableView:registerScriptHandler(function(table, idx) return self:cellSizeForTable(table,idx) end,cc.TABLECELL_SIZE_FOR_INDEX)
    self._tableView:registerScriptHandler(function(table, idx) return self:tableCellAtIndex(table, idx) end,cc.TABLECELL_SIZE_AT_INDEX)
    self._tableView:registerScriptHandler(function(table) return self:numberOfCellsInTableView(table) end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._tableView:setBounceable(true)
    -- if self._tableView.setDragSlideable ~= nil then 
    --     self._tableView:setDragSlideable(true)
    -- end
    
    tableViewBg:addChild(self._tableView)
end


-- 触摸时调用
function GuildManageNewView:tableCellTouched(table,cell)
    -- self._viewMgr:showDialog("guild.dialog.GuildPlayerDialog", {detailData = self._membersData[cell:getIdx()+1], dataType = 1}, true)
    -- print("==========================", cell:getIdx())

    local detailData = self._membersData[cell:getIdx()+1]
    self._serverMgr:sendMsg("UserServer", "getTargetUserBattleInfo", {tagId = detailData.memberId, fid= 1}, true, {}, function(result) 
        local data = result
        -- dump(result, "result====", 10)
        -- data.rank = curlUser.rank
        -- data.usid = curlUser.usid
        -- -- data.isNotShowBtn = true
        for key,value in pairs (detailData) do 
            if key ~= "hero" then
                data[key] = value
            end
        end
        data.hScore = detailData.score or data.score
        data.lvl = data.lv 
        data.hero.heroId = detailData.heroId
        -- self._viewMgr:showDialog("arena.DialogArenaUserInfo",data,true)
        self._viewMgr:showDialog("guild.dialog.GuildPlayerDialog", {detailData = data, dataType = 1}, true)
    end) 
end

-- cell的尺寸大小
function GuildManageNewView:cellSizeForTable(table,idx) 
    local width = 582 
    local height = 106
    return height, width
end

-- 创建在某个位置的cell
function GuildManageNewView:tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    local param = self._membersData[idx+1]
    if nil == cell then
        cell = cc.TableViewCell:new()
        local playerCell = self._playerCell:clone() 
        playerCell:setVisible(true)
        playerCell:setAnchorPoint(cc.p(0,0))
        playerCell:setPosition(cc.p(0,0))
        playerCell:setName("playerCell")
        cell:addChild(playerCell)

        -- local vipLab = playerCell:getChildByFullName("vipLab")
        -- vipLab:setFntFile(UIUtils.bmfName_vip)
        local name = playerCell:getChildByFullName("name")
        -- UIUtils:setTitleFormat(name, 2)
        -- name:setFontName(UIUtils.ttfName)
        -- name:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        local nameBg = playerCell:getChildByFullName("nameBg")
        -- nameBg:setOpacity(150)
        local level = playerCell:getChildByFullName("level")
        -- level:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
        -- level:setFontName(UIUtils.ttfName)
        -- level:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        local loginTime = playerCell:getChildByFullName("loginTime")
        -- loginTime:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        local contribeValue = playerCell:getChildByFullName("contribeValue")
        -- contribeValue:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        local jobLab = playerCell:getChildByFullName("jobLab")
        jobLab:setColor(UIUtils.colorTable.ccUIBaseTextColor2)

        self:updateCell(playerCell, param)
        playerCell:setSwallowTouches(false)
    else
        local playerCell = cell:getChildByName("playerCell")
        if playerCell then
            self:updateCell(playerCell, param)
            playerCell:setSwallowTouches(false)
        end
    end

    return cell
end

-- 返回cell的数量
function GuildManageNewView:numberOfCellsInTableView(table)
    return #self._membersData --table.nums(self._membersData)
end

-- function GuildManageNewView:reflashUI()

--     -- local userData = self._modelMgr:getModel("UserModel"):getData()
--     -- local tab4 = self:getUI("bg.rightSubBg.tab4")
--     -- if userData.roleGuild["pos"] == 3 then
--     --     tab4:setVisible(false)
--     -- else
--     --     tab4:setVisible(true)
--     -- end

--     -- if self._logLayer and self._logLayer:isVisible() then
--     --     self._logLayer:reflashUI()
--     -- elseif self._infoLayer and self._infoLayer:isVisible() then
--     --     self._infoLayer:reflashUI()
--     -- elseif self._rankLayer and self._rankLayer:isVisible() then
--     --     self._rankLayer:reflashUI()
--     -- elseif self._agreeLayer and self._agreeLayer:isVisible() then
--     --     self._agreeLayer:reflashUI()
--     -- end



-- end


function GuildManageNewView:setNavigation()
    self._viewMgr:showNavigation("global.UserInfoView",{types = {"GuildCoin","Gold","Gem"},title = "globalTitleUI_alliance.png",titleTxt = "联盟"})
end

-- function GuildManageNewView:getBgName()
--     return "bg_007.jpg"
-- end

function GuildManageNewView:setNoticeBar()
    self._viewMgr:hideNotice(true)
end

return GuildManageNewView