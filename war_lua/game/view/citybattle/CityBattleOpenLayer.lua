--[[
    Filename:    CityBattleOpenLayer.lua
    Author:      <lishunan@playcrab.com>
    Datetime:    2017-06-30 11:04:24
    Description: File description
--]]

local move_y
local endPoint 

local CityBattleOpenLayer = class("CityBattleOpenLayer", BaseLayer)
local MAX_SCREEN_WIDTH = MAX_SCREEN_WIDTH
local MAX_SCREEN_HEIGHT = MAX_SCREEN_HEIGHT
local ColorImage = {
    "citybattle_match_2.png",
    "citybattle_match_1.png",
    "citybattle_match_3.png"
}

function CityBattleOpenLayer:ctor(param)
    CityBattleOpenLayer.super.ctor(self)
    if param then
        self._callBack = param.callBack
    end
    self._cityBattleModel = self._modelMgr:getModel("CityBattleModel")
    self._userModel = self._modelMgr:getModel("UserModel")
    self._leagueModel = self._modelMgr:getModel("LeagueModel")
    self._serverColor = self._cityBattleModel:getData().c.co
    self._num = table.nums(self._serverColor)

    self._finalData = self:initData()
end

---1,2,3 红 蓝绿

function CityBattleOpenLayer:initData()
    -- local sec = self._userModel:getData().sec
    local sec = self._cityBattleModel:getMineSec()
    sec = tonumber(sec)
    local data = {}
    for serverid,value in pairs (self._serverColor) do 
        local temp = {}
        if tonumber(serverid) == sec then
            temp.rank = 4
        elseif value == 2 then
            temp.rank = 3
        elseif value == 1 then
            temp.rank = 2
        else
            temp.rank = 1
        end
        temp.sec = tonumber(serverid)
        temp.color = value
        table.insert(data,temp)
    end
    table.sort(data,function(a,b)
        return a.rank > b.rank
    end)
    return data
end




function CityBattleOpenLayer:onInit()
    self._maskLayer = ccui.Layout:create()
    self._maskLayer:setBackGroundColorOpacity(255)
    self._maskLayer:setBackGroundColorType(1)
    self._maskLayer:setBackGroundColor(cc.c3b(0,0,0))
    self._maskLayer:setContentSize(MAX_SCREEN_WIDTH, MAX_SCREEN_HEIGHT)
    self._maskLayer:setOpacity(200)
    self:addChild(self._maskLayer,-1)
    self._maskLayer:setAnchorPoint(0.5,0.5)
    self._maskLayer:setPosition(480,320)

    -- local close = self:getUI("bg.close")
    -- self:registerClickEvent(close,function()
    --     self:removeFromParent()
    --     if OS_IS_WINDOWS then
    --         UIUtils:reloadLuaFile("citybattle.CityBattleOpenLayer")
    --     end
    -- end)

    self._three = self:getUI("bg.three")
    self._three:setVisible(false)
    move_y = -520-(MAX_SCREEN_HEIGHT-640)/2

    endPoint = {cc.p(460,-move_y+260),
        cc.p(460,-move_y+220),
        cc.p(460,-move_y+180)
    }
    self._three:setPositionY(move_y)
    self._two = self:getUI("bg.two")
    self._two:setVisible(false)
    self._two:setPositionY(move_y)
    self._title = self:getUI("bg.title")
    self._title:setVisible(false)

    local layer = #self._finalData == 2 and self._two 
                    or #self._finalData == 3 and self._three
    local key = {"blue","red","green"}
    local mineSec = tonumber(self._cityBattleModel:getMineSec())
    for index,data in pairs (self._finalData) do 
        local colorImage = layer:getChildByFullName(key[index])
        colorImage:loadTexture(ColorImage[data.color],1)

        local sec = colorImage:getChildByFullName("sec")
        local name = self._cityBattleModel:getServerName(data.sec)
        sec:setString(name)



        local name = colorImage:getChildByFullName("name")
        -- local serverName = self._leagueModel:getServerName(data.sec)
        -- local strTab = string.split(serverName," ")

        -- if strTab[2] then
        --     name:setString(strTab[2])
        -- else
        --     name:setString(serverName)
        -- end
        name:setVisible(false)
        if tonumber(data.sec) == mineSec then
            name:setVisible(true)
            -- local label = ccui.Text:create()
            -- label:setFontName(UIUtils.ttfName)
            -- label:setFontSize(20)
            name:setString("己方战区")
            name:setColor(cc.c3b(255,255,140))
            name:enable2Color(1,cc.c3b(245,200,50))
            name:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
            -- colorImage:addChild(label)
        end
        -- name:setString("aaaaa")
        local mc1
        if data.color == 2 then
            mc1 = mcMgr:createViewMC("fuwuqiguang1_kaiqi", true, false)
        else
            mc1 = mcMgr:createViewMC("fuweuqiguang2_kaiqi", true, false)
        end
        mc1:setPosition(cc.p(colorImage:getContentSize().width/2, colorImage:getContentSize().height/2))
        colorImage:addChild(mc1,10)
        mc1:setScale(1.1)
        mc1:setCascadeOpacityEnabled(true)
        mc1:setOpacity(150)
    end

    self._titleMc = mcMgr:createViewMC("siqiangguang_godwar", true, false)
    self._titleMc:setPosition(cc.p(self._title:getContentSize().width/2, self._title:getContentSize().height))
    self._titleMc:gotoAndStop(5)
    self._title:addChild(self._titleMc,-1)
    self._titleMc:setVisible(false)


    self:onOpenAction()
end

function CityBattleOpenLayer:onOpenAction()

    self._title:setScale(3)
    self._title:setOpacity(0)
    self._title:setVisible(true)
    self._title:runAction(cc.Sequence:create(
        cc.Spawn:create(
            cc.FadeIn:create(0.1),
            cc.ScaleTo:create(0.1, 0.9)
        ),
        cc.ScaleTo:create(0.1, 1.0),
        cc.CallFunc:create(function()
            print("end")
            self._titleMc:setVisible(true)
        end)
    ))

    local fixY = 10
    local i = 1
    local function run_(table_)
        if not table_[i] then 
            self:endAction(table_)
            return 
        end
        local node = table_[i]
        node:setOpacity(0)
        node:runAction(cc.Sequence:create(
            cc.Spawn:create(
                cc.FadeIn:create(0.2),
                cc.MoveBy:create(0.2, cc.p(0,-move_y+fixY)),
                cc.Sequence:create(
                    cc.DelayTime:create(0.1),
                    cc.CallFunc:create(function()
                        i = i+1
                        run_(table_)
                    end)
                )
            ),
            cc.MoveBy:create(0.2,cc.p(0,-fixY)),
            cc.CallFunc:create(function()
                -- i = i+1
                -- run_(table_)
            end)
        ))
    end

    if self._num == 2 then
       self._two:setVisible(true)
       local blue = self._two:getChildByFullName("blue")
       local red = self._two:getChildByFullName("red")
       local data = {blue,red}
       run_(data)
    else
       self._three:setVisible(true)
       local blue = self._three:getChildByFullName("blue")
       local red = self._three:getChildByFullName("red")
       local green = self._three:getChildByFullName("green")
       local data = {blue,red,green}
       run_(data)
    end



end

function CityBattleOpenLayer:endAction(nodeTable)
    local time = {0.3,0.33,0.38}
    self._title:setCascadeOpacityEnabled(true,true)
    self._title:runAction(cc.Sequence:create(
        cc.DelayTime:create(1),
        cc.FadeOut:create(0.1),
        cc.CallFunc:create(function()
            for i=1,#nodeTable do 
                nodeTable[i]:setCascadeOpacityEnabled(true,true)
                nodeTable[i]:runAction(cc.Sequence:create(
                    cc.Spawn:create(
                        cc.MoveTo:create(time[i],endPoint[i]),
                        cc.ScaleTo:create(time[i],0.1),
                        cc.Sequence:create(
                            cc.DelayTime:create(0.1),
                            cc.FadeOut:create(time[i])
                        )
                    ),
                    cc.CallFunc:create(function()
                        if i == #nodeTable then
                            if self._callBack then
                                self._callBack()
                            end
                            self:removeFromParent()
                            if OS_IS_WINDOWS then
                                UIUtils:reloadLuaFile("citybattle.CityBattleOpenLayer")
                            end
                        end
                    end)
                ))
            end
        end)
    ))
end


function CityBattleOpenLayer:reflashUI()

end

function CityBattleOpenLayer:dtor()
    move_y = nil
end







return CityBattleOpenLayer
