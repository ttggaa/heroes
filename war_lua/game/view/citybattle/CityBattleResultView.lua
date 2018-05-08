
--[[
    Filename:    CityBattleResultView.lua
    Author:      <lishunan@playcrab.com>
    Datetime:    2017-7-15 10:26:00
    Description: File description
--]]

local CityBattleResultView = class("CityBattleResultView",BaseView)

--showType 1 战中结算 2 赛季结算
function CityBattleResultView:ctor(param)
    self._showType = param and param.showType or 1
    self._callBack = param.callBack

    CityBattleResultView.super.ctor(self)
    self:registerScriptHandler(function(eventType)
        if eventType == "exit" then 
            UIUtils:reloadLuaFile("citybattle.CityBattleResultView")
        elseif eventType == "enter" then 
        end
    end)    
    self._cityBattleModel = self._modelMgr:getModel("CityBattleModel")
    self._leagueModel = self._modelMgr:getModel("LeagueModel")
    self._userModel = self._modelMgr:getModel("UserModel")

end


function CityBattleResultView:onInit()
    local titleImage = self:getUI("resultType")
    if self._showType == 1 then
        titleImage:loadTexture("citybattle_result_titleImage1.png",1)
    else
        titleImage:loadTexture("citybattle_result_titleImage2.png",1)
    end
    -- self._tabType = 1
    local dayBtn = self:getUI("bg.dayBtn")
    local personBtn = self:getUI("bg.personBtn")

    local middleBg = self:getUI("bg.listBg")
    middleBg:loadTexture("asset/uiother/gvg/citybattle_resultBg.png")

    local closeBtn = self:getUI("bg.closeBtn")
    if closeBtn then
        self:registerClickEvent(closeBtn,function()
            self:close()
        end)
    end
    self._titleTxtBg = self:getUI("bg.titleTxtBg1")
    self:registerClickEvent(dayBtn,function()
        self:onTabClick(dayBtn,1)
    end)
    self:registerClickEvent(personBtn,function()
        self:onTabClick(personBtn,2)
    end)
    self:onTabClick(dayBtn,1)

    
    self.initAnimType = 7
    self._animationBg = self:getUI("bg")
    self._titleBg = self:getUI("resultType")

    for i=1,4 do 
        local content = self._titleTxtBg:getChildByFullName("content"..i)
        if content then
            content:setVisible(false)
        end
    end
end

function CityBattleResultView:onAnimEnd()
    local mc2 = mcMgr:createViewMC("piaoluocaidai_leaguejinjiechenggong", true, false,function()
           
    end)
    mc2:setPosition(MAX_SCREEN_WIDTH/2,MAX_SCREEN_HEIGHT)
    self:addChild(mc2,100)
    mc2:setCascadeOpacityEnabled(true)
    mc2:setOpacity(0)
    mc2:runAction(cc.FadeIn:create(0.2))
end

function CityBattleResultView:refreshTitle(_type)
    local titleTxt = {
        {
            "服务器",
            "占领城池数",
            "总计击杀"
        },
        {
            "队列",
            "击杀数量",
            "获得积分"
        }
    }
    for i=1,3 do 
       local title = self._titleTxtBg:getChildByFullName("title"..i)
       title:setString(titleTxt[_type][i])
   end
   local reslutTitleImage = self:getUI("bg.titleImageBg.reslutTitleImage")
   if self._tabType == 1 then
      reslutTitleImage:loadTexture("citybattle_day_result.png",1)
   else
      reslutTitleImage:loadTexture("citybattle_person_result.png",1)
   end
end

local battleName = {
    "赤焰战区",
    "碧蓝战区",
    "苍星战区"
}

function CityBattleResultView:getServerDes(sec)
    local sec = tonumber(sec)
    local realSec = tostring(self._cityBattleModel:getRealServerId(sec))
    local des = ""
    local co = self._cityBattleModel:getData()["c"]["co"]
    local num = co[realSec]
    if not num then 
        realSec =  tostring(sec)
        num = co[realSec]
        if not num then return "" end
    end
    des = battleName[num]

    local mysec = tonumber(self._userModel:getData().sec)
    local myRealSec = tonumber(self._cityBattleModel:getRealServerId(mysec))
    local isMine = false
    if myRealSec == sec then
       des = des .. " (己方)" 
       isMine = true
    else
       des = des .. " (敌方)"
    end

    -- local sdkMgr = SdkManager:getInstance()
    -- local des = ""
    -- if sec and sec >= 5001 and sec < 7000 then
    --     des = "双线"
    -- elseif sdkMgr:isQQ() then
    --     des = "qq"
    -- elseif sdkMgr:isWX() then
    --     des = "微信"
    -- else
    --     des = "win"
    -- end
    return des, isMine
end

function CityBattleResultView:refreshContent(result)
    -- dump(result)
    for i=1,4 do 
        local content = self._titleTxtBg:getChildByFullName("content"..i)
        if content then
            content:setVisible(false)
        end
    end
    if self._tabType == 1 then
        local cityServerData = self._cityBattleModel:getCityServerList()
        -- dump(cityServerData,"aaa",10)
        local cityData = self._cityBattleModel:getServerCityData()
        -- dump(cityData)
        local serverNum = #cityServerData
        for i=1,serverNum do 
            local content = self._titleTxtBg:getChildByFullName("content"..i)
            content:setVisible(true)
            local serverName = content:getChildByFullName("serverName")
            local sec = cityServerData[i].sec
            local name = self._leagueModel:getServerName(sec)
            local plat, isMine = self:getServerDes(sec)
            local des = plat
            serverName:setString(des)
            serverName:setFontSize(18)
            local cityNum = content:getChildByFullName("cityNum")
            cityNum:setString(cityData[i]["cityNum"])
            local killNum = content:getChildByFullName("killNum")
            if result[sec] then
                killNum:setString(result[sec] .. "人")
            else
                killNum:setString("0人")
            end
            if isMine then
                serverName:setColor(cc.c4b(39,247,58,255))
                cityNum:setColor(cc.c4b(39,247,58,255))
                killNum:setColor(cc.c4b(39,247,58,255))
            else
                serverName:setColor(cc.c4b(255,247,207,255))
                cityNum:setColor(cc.c4b(255,247,207,255))
                killNum:setColor(cc.c4b(255,247,207,255))
            end
        end
    elseif self._tabType == 2 then
        local p = result.cb or {} 
        local teamKey = {"17","18","19","20"}
        local index = 1
        if p and table.nums(p) > 0 then
            for i=1,4 do 
                local data = p[teamKey[i]]
                if data then
                    local heroid = tonumber(data.hid) or 0
                    local heroData = tab:Hero(heroid)
                    if heroData then
                        local content = self._titleTxtBg:getChildByFullName("content"..index)
                        content:setVisible(true)
                        local heroName = lang(heroData.heroname)
                        local serverName = content:getChildByFullName("serverName") 
                        serverName:setString(heroName .. "部队")
                        local killNum = content:getChildByFullName("killNum")
                        killNum:setString(data.p)
                        local kl = data.k or 0 
                        local cityNum = content:getChildByFullName("cityNum")
                        cityNum:setString(kl .. "人")
                        serverName:setColor(cc.c4b(255,247,207,255))
                        cityNum:setColor(cc.c4b(255,247,207,255))
                        killNum:setColor(cc.c4b(255,247,207,255))
                    end
                    index = index + 1
                end
            end
        end
    end
end

function CityBattleResultView:onTabClick(sender,clickType)
    if self._tabType == clickType then
        return
    end
    print("sssss")
    self._tabType = clickType
    if self._preBtn then
        self._preBtn:setTouchEnabled(true)
        self._preBtn:setBright(true)
    end
    self._preBtn = sender
    sender:setTouchEnabled(false)
    sender:setBright(false)
    self:refreshTitle(clickType)
    if self._tabType == 1 and self._requestData then
        self:refreshContent(self._requestData)
    elseif self._tabType == 2 then
        if self._requestData2 then
            self:refreshContent(self._requestData2)
        else
            self._serverMgr:sendMsg("CityBattleServer", "getPeopleResult", {}, true, {}, function (result, error)
                if result then
                    dump(result)
                    self._requestData2 = result
                    self:refreshContent(result)
                end
            end)
        end
    end
end

function CityBattleResultView:setNavigation()
    self._viewMgr:showNavigation("global.UserInfoView",{hideInfo = true, hideHead = true})
end

function CityBattleResultView:getAsyncRes()
    return {     
    		"asset/uiother/gvg/citybattle_resultBg.png"
}
end

function CityBattleResultView:getBgName()
    if self._showType == 1 then
        return "gvg/citybattle_result1.jpg"
    else
        return "gvg/citybattle_result2.jpg"
    end
end

function CityBattleResultView:onDestroy()
    if self._callBack then
        self._callBack()
    end
	CityBattleResultView.super.onDestroy(self)
end

function CityBattleResultView:onBeforeAdd(callback, errorCallback)
    self._requestData = false
    self._serverMgr:sendMsg("CityBattleServer", "getSectionResult", {}, true, {}, function (result, error)
        if result then
            callback()
            self._requestData = result
            self:refreshContent(result)
        else
            errorCallback()
        end
    end)
end

return CityBattleResultView