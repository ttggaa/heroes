--[[
    Filename:    TestOnlineInfo.lua
    Author:      <huachangmiao@playcrab.com>
    Datetime:    2017-07-04 14:58:36
    Description: File description
--]]

local TestOnlineInfo = class("TestOnlineInfo", BaseView)

function TestOnlineInfo:ctor()
    TestOnlineInfo.super.ctor(self)

end

function TestOnlineInfo:onDestroy()

end

function TestOnlineInfo:onInit()
    G_patchTab["game.server.UserServer"] = function (UserServer) 
        function UserServer:onGetPlayerAction(result, error)
            self:callback(result)
        end
        function UserServer:onBubbleModify(result, error)
            self:callback(result)
        end  
    end

    local closeBtn = ccui.Button:create("globalBtnUI_quit.png", "globalBtnUI_quit.png", "globalBtnUI_quit.png", 1)
    closeBtn:setPosition(MAX_SCREEN_WIDTH - closeBtn:getContentSize().width * 0.5, MAX_SCREEN_HEIGHT - closeBtn:getContentSize().height * 0.5)
    self:registerClickEvent(closeBtn, function ()
        self:close()
    end)
    self:addChild(closeBtn)

    local btn1 = ccui.Button:create("globalButtonUI13_1_1.png", "globalButtonUI13_1_1.png", "globalButtonUI13_1_1.png", 1)
    btn1:setPosition(90, MAX_SCREEN_HEIGHT - 40)
    btn1:setTitleText("刷新")
    btn1:setTitleFontSize(22) 
    btn1:setTitleFontName(UIUtils.ttfName)
    btn1:enableOutline(cc.c4b(0, 0, 0, 255), 1)
    self:registerClickEvent(btn1, function ()
        self:updateID()
    end)
    self:addChild(btn1)

    local btn1 = ccui.Button:create("globalButtonUI13_1_1.png", "globalButtonUI13_1_1.png", "globalButtonUI13_1_1.png", 1)
    btn1:setPosition(90, MAX_SCREEN_HEIGHT - 220)
    btn1:setTitleText("下一个")
    btn1:setTitleFontSize(22) 
    btn1:setTitleFontName(UIUtils.ttfName)
    btn1:enableOutline(cc.c4b(0, 0, 0, 255), 1)
    self:registerClickEvent(btn1, function ()
        self._openIDIdx = self._openIDIdx + 1
        if self._openIDIdx > #self._openIDs then
            self._openIDIdx = 1
        end
        self:getInfo()
    end)
    self:addChild(btn1)

    self._openIDLabel = cc.Label:createWithTTF("openID:", UIUtils.ttfName, 20)
    self._openIDLabel:setPosition(20, MAX_SCREEN_HEIGHT - 120)
    self._openIDLabel:setAnchorPoint(0, 0.5)
    self._openIDLabel:enableOutline(cc.c4b(0, 0, 0, 255), 1)
    self:addChild(self._openIDLabel)

    self._groupLabel = cc.Label:createWithTTF("group:", UIUtils.ttfName, 20)
    self._groupLabel:setPosition(20, MAX_SCREEN_HEIGHT - 260)
    self._groupLabel:setAnchorPoint(0, 0.5)
    self._groupLabel:enableOutline(cc.c4b(0, 0, 0, 255), 1)
    self:addChild(self._groupLabel)

    self._countLabel = cc.Label:createWithTTF("0/0", UIUtils.ttfName, 20)
    self._countLabel:setPosition(80, MAX_SCREEN_HEIGHT - 170)
    self._countLabel:setAnchorPoint(0, 0.5)
    self._countLabel:enableOutline(cc.c4b(0, 0, 0, 255), 1)
    self:addChild(self._countLabel)
end

function TestOnlineInfo:updateID()
    local f = io.open("./script/test/online.txt", 'r')
    local str = f:read("*all")
    local list = string.split(str, "\n")
    f:close()
    local array = {}
    local map = {}
    for i = 1, #list do
        if not map[list[i]] then
            array[#array + 1] = list[i]
            map[list[i]] = true
        end
    end
    self._openIDs = array
    self._openIDIdx = 1
    self:getInfo()
end

function TestOnlineInfo:getInfo()
    self._countLabel:setString(self._openIDIdx .. "/" .. #self._openIDs)
    self._openID = self._openIDs[self._openIDIdx]
    self._openIDLabel:setString("openID: " .. self._openID)
    self:getRole()
end

function TestOnlineInfo:getRole()
    local ver1, group1, ver2, group2, ver3, group3
    if string.find(self._openID, "oQ1y") then
        ver1 = "2680"
        group1 = "iwx"
        ver2 = "2679"
        group2 = "awx"
    else
        ver1 = "2680"
        group1 = "iqq"
        ver2 = "2679"
        group2 = "aqq"     
    end
    ver3 = "2680"
    group3 = "iguest"
    self:httpReq(ver1, group1, function (data)
        if data then
            self:setRole(ver1, group1, data.result)
        else
            self:httpReq(ver2, group2, function (data)
                if data then
                    self:setRole(ver2, group2, data.result)
                else
                    self:httpReq(ver3, group3, function (data)
                        if data then
                            self:setRole(ver3, group3, data.result)
                        else

                        end
                    end)
                end
            end)
        end
    end)
end

function TestOnlineInfo:setRole(ver, group, data)
    if self._scrollView then
        self._scrollView:removeFromParent()
    end
    self._groupLabel:setString("group: "..group)
    local array = {}
    for k, v in pairs(data.roles) do
        array[#array + 1] = v
        v.id = k
        v.server = data.sec_info[tostring(k)]
    end
    table.sort(array, function (a, b)
        return a.level > b.level
    end)
    self._gs_token = data.gs_token
    dump(array)
    self._scrollView = cc.ScrollView:create() 
    self._scrollView:setViewSize(cc.size(MAX_SCREEN_WIDTH, MAX_SCREEN_HEIGHT - 120))
    self._scrollView:setPosition(0, 0)
    self._scrollView:setContentSize(cc.size(#array * 300, MAX_SCREEN_HEIGHT - 120))
    
    for i = 1, #array do
        local label = ccui.Text:create()
        label:setString(
            array[i].name.."\n"..
            "lv:"..array[i].level.."\n"..
            "id:"..array[i].rid.."\n" ..
            "usid:"..array[i].usid.."\n" ..
            "vip:"..array[i].vipLvl.."\n" ..
            "arena:"..array[i].maxarena.."\n" ..
            "logout:"..TimeUtils.getDateString(array[i].logoutTime)
            )
        label:setFontSize(18)
        label:setAnchorPoint(0, 0)
        label:setFontName(UIUtils.ttfName)
        label:setPosition((i - 1) * 300, 200)
        self._scrollView:addChild(label)


        local btn1 = ccui.Button:create("globalButtonUI13_2_1.png", "globalButtonUI13_2_1.png", "globalButtonUI13_2_1.png", 1)
        btn1:setPosition((i - 1) * 300 + 100, 160)
        btn1:setTitleText("踢人")
        btn1:setTitleFontSize(22) 
        btn1:setTitleFontName(UIUtils.ttfName)
        btn1:enableOutline(cc.c4b(0, 0, 0, 255), 1)
        self:registerClickEvent(btn1, function ()
            self:kick(array[i].server.ws, ver, group, array[i].id)
        end)
        self._scrollView:addChild(btn1)

        local btn1 = ccui.Button:create("globalButtonUI13_1_1.png", "globalButtonUI13_1_1.png", "globalButtonUI13_1_1.png", 1)
        btn1:setPosition((i - 1) * 300 + 100, 40)
        btn1:setTitleText("封号")
        btn1:setTitleFontSize(22) 
        btn1:setTitleFontName(UIUtils.ttfName)
        btn1:enableOutline(cc.c4b(0, 0, 0, 255), 1)
        self:registerClickEvent(btn1, function ()
            self:ban(array[i].server.ws, ver, group, array[i].id)
        end)
        self._scrollView:addChild(btn1)

        local btn1 = ccui.Button:create("globalButtonUI13_2_1.png", "globalButtonUI13_2_1.png", "globalButtonUI13_2_1.png", 1)
        btn1:setPosition((i - 1) * 300 + 100, 100)
        btn1:setTitleText("解封")
        btn1:setTitleFontSize(22) 
        btn1:setTitleFontName(UIUtils.ttfName)
        btn1:enableOutline(cc.c4b(0, 0, 0, 255), 1)
        self:registerClickEvent(btn1, function ()
            self:deban(array[i].server.ws, ver, group, array[i].id)
        end)
        self._scrollView:addChild(btn1)
    end
    self._scrollView:setContentOffset(cc.p(0, 0))
    self._scrollView:setDirection(0) 
    self:addChild(self._scrollView)
end

function TestOnlineInfo:kick(ip, ver, group, id)
    GameStatic.ipAddress = ip
    self._serverMgr:setVer(ver)
    local upgrade
    if string.find(group, "i") then
        upgrade = "ios_online"
    else
        upgrade = "android_online"
    end
    self._serverMgr._token = "aaa"
    self._serverMgr:setUpgrade(upgrade)
    self._serverMgr:initSocket(function ()
        local param = {
                sec = id, 
                gs_token = self._gs_token,
                account_id = self._openID,
                account_name = "",
                ver = ver,
                upgrade = upgrade,
                deviceId = "",
                pGroup = group,
            }
        self._serverMgr:sendMsg("UserServer", "login", param, true, {}, 
        function(result)
            self._serverMgr:sendMsg("UserServer", "getPlayerAction", param, true, {}, 
            function(result)
                if result and result["bubble"] and result["bubble"]["b3"] then
                    if result["bubble"]["b3"] >= 999000 then
                        self._viewMgr:showTip("踢下线成功, 已经被封号")
                    else
                        self._viewMgr:showTip("踢下线成功, b3="..result["bubble"]["b3"])
                    end
                else
                    self._viewMgr:showTip("踢下线成功")
                end
                self._serverMgr:clear()
            end,
            function (error, msg)
                self._viewMgr:showTip(msg)
                self._serverMgr:clear()
            end, false, function ()

            end) 
        end,
        function (error, msg)
            self._viewMgr:showTip(msg)
            self._serverMgr:clear()
        end, false, function ()

        end) 
    end, function (errorCode)

    end)
end

function TestOnlineInfo:ban(ip, ver, group, id)
    GameStatic.ipAddress = ip
    self._serverMgr:setVer(ver)
    local upgrade
    if string.find(group, "i") then
        upgrade = "ios_online"
    else
        upgrade = "android_online"
    end
    self._serverMgr._token = "aaa"
    self._serverMgr:setUpgrade(upgrade)
    self._serverMgr:initSocket(function ()
        local param = {
                sec = id, 
                gs_token = self._gs_token,
                account_id = self._openID,
                account_name = "",
                ver = ver,
                upgrade = upgrade,
                deviceId = "",
                pGroup = group,
            }
            
        self._serverMgr:sendMsg("UserServer", "login", param, true, {}, 
        function(result)
            self._serverMgr:sendMsg("UserServer", "getPlayerAction", param, true, {}, 
            function(result)
                local b3 = 0
                if result and result["bubble"] and result["bubble"]["b3"] then
                    b3 = result["bubble"]["b3"]
                end
                if b3 < 999000 then
                    self._serverMgr:sendMsg("UserServer", "bubbleModify", {num = 3, val = b3 + 999000}, true, {}, 
                    function(result)
                        dump(result)
                        self._viewMgr:showTip("封号成功, b3="..result["d"]["bubble"]["b3"])
                        self._serverMgr:clear()
                    end,
                    function (error, msg)
                        self._viewMgr:showTip(msg)
                        self._serverMgr:clear()
                    end, false, function ()

                    end) 
                else
                    self._viewMgr:showTip("已经封号, b3="..b3)
                    self._serverMgr:clear()   
                end
            end,
            function (error, msg)
                self._viewMgr:showTip(msg)
                self._serverMgr:clear()
            end, false, function ()

            end) 
        end,
        function (error, msg)
            self._viewMgr:showTip(msg)
            self._serverMgr:clear()
        end, false, function ()

        end) 
    end, function (errorCode)

    end)
end

function TestOnlineInfo:deban(ip, ver, group, id)
    GameStatic.ipAddress = ip
    self._serverMgr:setVer(ver)
    local upgrade
    if string.find(group, "i") then
        upgrade = "ios_online"
    else
        upgrade = "android_online"
    end
    self._serverMgr._token = "aaa"
    self._serverMgr:setUpgrade(upgrade)
    self._serverMgr:initSocket(function ()
        local param = {
                sec = id, 
                gs_token = self._gs_token,
                account_id = self._openID,
                account_name = "",
                ver = ver,
                upgrade = upgrade,
                deviceId = "",
                pGroup = group,
            }
            
        self._serverMgr:sendMsg("UserServer", "login", param, true, {}, 
        function(result)
            self._serverMgr:sendMsg("UserServer", "getPlayerAction", param, true, {}, 
            function(result)
                local b3 = 0
                if result and result["bubble"] and result["bubble"]["b3"] then
                    b3 = result["bubble"]["b3"]
                end
                if b3 >= 999000 then
                    self._serverMgr:sendMsg("UserServer", "bubbleModify", {num = 3, val = b3 - 999000}, true, {}, 
                    function(result)
                        self._viewMgr:showTip("解封成功, b3="..result["d"]["bubble"]["b3"])
                        self._serverMgr:clear()
                    end,
                    function (error, msg)
                        self._viewMgr:showTip(msg)
                        self._serverMgr:clear()
                    end, false, function ()

                    end) 
                else
                    self._viewMgr:showTip("未被封号, b3="..b3)
                    self._serverMgr:clear()   
                end
            end,
            function (error, msg)
                self._viewMgr:showTip(msg)
                self._serverMgr:clear()
            end, false, function ()

            end) 
        end,
        function (error, msg)
            self._viewMgr:showTip(msg)
            self._serverMgr:clear()
        end, false, function ()

        end) 
    end, function (errorCode)

    end)
end

function TestOnlineInfo:httpReq(ver, group, callback)
    local req = cc.XMLHttpRequest:new()
    req.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
    req:registerScriptHandler(function()
        if req.status == 200 then -- 成功
            local ret = cjson.decode(req.response)
            if ret.error then
                dump(ret.error)
                callback()
            else
                callback(ret)
            end
        else

        end
    end)
    req:open("post", "http://global.yxwd.qq.com:9000/index.php?")
    req.timeout = 10
    req:send("&account_name="..self._openID.."&sdk_type=Dev&channel_alias=&mod=global&channel_id=-1&method=Account.login&ver="..ver.."&device=&origin_data=eyJpZCI6MTAwMn0=&pGroup="..group)
end

return TestOnlineInfo