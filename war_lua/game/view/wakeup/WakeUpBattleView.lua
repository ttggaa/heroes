--[[
    Filename:    WakeUpBattleView.lua
    Author:      <weiwei02@playcrab.com>
    Datetime:    2017-04-25 16:53:48
    Description: File description
--]]

local WakeUpBattleView = class("WakeUpBattleView", BasePopView)

function WakeUpBattleView:ctor()
    WakeUpBattleView.super.ctor(self)

end

function WakeUpBattleView:onInit()
    self:registerScriptHandler(function(eventType)
        if eventType == "exit" then 
            UIUtils:reloadLuaFile("wakeup.WakeUpBattleView")
        elseif eventType == "enter" then 

        end
    end)


    self._bg = self:getUI("bg")
    self._desBg = self:getUI("bg.descBg")
    self._btn1 = self:getUI("bg.btn1")
    self._btn2 = self:getUI("bg.btn2")



    self:registerClickEvent(self._btn2, function ()
        WakeUpUtils.setOpenBattleView(false)
        self:close(false,self._callback)
    end)
    self._title = self:getUI("bg.title")   
    UIUtils:setTitleFormat(self._title, 6)

    self._titleTip = self:getUI("bg.titleTip")  
    UIUtils:setTitleFormat(self._titleTip, 6)
end

function WakeUpBattleView:reflashUI(data)
    self._battleInfo = data.result
    self._callback = data.callback

    self:registerClickEvent(self._btn1, function ()
        WakeUpUtils.setOpenBattleView(false)
        self:getBattleInfo()
    end)
    local str = lang("REPORTSHARE_DESIN" .. self._battleInfo.bt)
    str = string.gsub(str, "{$name1}", self._battleInfo.l or "")
    str = string.gsub(str, "{$name2}", self._battleInfo.r or "")
    if string.find(str, "color=") == nil then
        str = "[color=000000]".. str .."[-]"
    end   
    local richText = RichTextFactory:create(str, self._desBg:getContentSize().width, 0)
    richText:setPixelNewline(true)
    richText:formatText() 
    richText:setPosition(self._desBg:getContentSize().width * 0.5 + (self._desBg:getContentSize().width - richText:getRealSize().width) * 0.5, self._desBg:getContentSize().height * 0.5 - richText:getRealSize().height * 0.5 * 0.5)
    self._desBg:addChild(richText) 
end


-- 获取服务器列表
function WakeUpBattleView:getBattleInfo()
    local globalServerUrl = AppInformation:getInstance():getValue("global_server_url", GameStatic.httpAddress_global)
    if GameStatic.use_globalExPort and RestartMgr.globalUrl_planB then
        globalServerUrl = RestartMgr.globalUrl_planB
    end
    print("globalServerUrl: ", globalServerUrl)
    local param = {}
    param.mod = "global"
    param.act = "getBattleReport"
    param.reportKey = self._battleInfo.k
    -- self._battleInfo.k
    param.sec = self._battleInfo.s
    param.method = "system.sysInterface"
    HttpManager:getInstance():sendMsg(globalServerUrl, nil, param, 
    function(inData)
        if inData.result ~= nil and inData.result.bcode ~= 1 then
            if tonumber(self._battleInfo.bt) == 1 then
                self:reviewArenaBattle(inData.result)
            else
                self:reviewHeroDuelBattle(inData.result)
            end
        else
            self._viewMgr:showTip(lang("REPORTSHARE_ERROR"))
        end
    end,
    function(status, errorCode, response)
        self._viewMgr:showTip(lang("REPORTSHARE_ERROR"))
    end,
    GameStatic.useHttpDns_Global)
end

function WakeUpBattleView:reviewStageBattle(result)
    local left = BattleUtils.jsonData2lua_battleData(result.atk)
    BattleUtils.enterBattleView_Fuben(result, result.def, true,
    function (info, callback)
        callback(info)
    end,
    function (info)

    end)
end

function WakeUpBattleView:reviewArenaBattle(result)
    local left = BattleUtils.jsonData2lua_battleData(result.atk)
    local right = BattleUtils.jsonData2lua_battleData(result.def)
    BattleUtils.enterBattleView_Arena(left, right, result.r1, result.r2, 2, false,
    function (info, callback)
        if isMeAtk and isWin then
            local arenaInfo = {}
            arenaInfo.rank,arenaInfo.preRank,arenaInfo.preHRank = reportData.defRank,reportData.atkRank,reportData.atkRank
            info.arenaInfo = arenaInfo
        end
        callback(info)
    end,
    function (info)
        -- 退出战斗
        if self.close ~= nil then
            self:close(false)
        end
    end)
end


function WakeUpBattleView:reviewHeroDuelBattle(result)
    local left  = BattleUtils.jsonData2lua_battleData(result.atk)
    local right = BattleUtils.jsonData2lua_battleData(result.def)
    BattleUtils.disableSRData()
    BattleUtils.enterBattleView_HeroDuel(left, right, result.r1, result.r2, 1, result.def.rid == self._modelMgr:getModel("UserModel"):getRID(),
    function (info, callback)
        callback(info)

    end,
    function (info)
        if self.close ~= nil then
            self:close(false)
        end
    end)
end
return WakeUpBattleView