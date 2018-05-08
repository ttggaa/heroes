--[[
    Filename:    CityBattleDetailDialog.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2016-11-26 11:53:00
    Description: File description
--]]

-- GVG城市详情
local CityBattleDetailDialog = class("CityBattleDetailDialog", BasePopView)

function CityBattleDetailDialog:ctor(param)
    CityBattleDetailDialog.super.ctor(self)
    self._cityId = param.cbId
end

function CityBattleDetailDialog:onInit()
    self._formationModel = self._modelMgr:getModel("FormationModel")
    self._teamModel = self._modelMgr:getModel("TeamModel")
    self._heroModel = self._modelMgr:getModel("HeroModel")
    self._cityBattleModel = self._modelMgr:getModel("CityBattleModel")
    
    self:registerClickEventByName("bg.closeBtn", function()
        if OS_IS_WINDOWS then
            UIUtils:reloadLuaFile("citybattle.CityBattleDetailDialog")
        end
        self:close()
    end)
    -- local burst = self:getUI("bg.layer.burst")

    self._title = self:getUI("bg.layer.title")
    UIUtils:setTitleFormat(self._title, 1)

    local layer = self:getUI("bg.layer")
    layer:loadTexture("asset/bg/global_info_bg.png", 0)

    local labBg1 = self:getUI("bg.layer.labBg1")
    self._atkfight1 = cc.LabelBMFont:create("1", UIUtils.bmfName_zhandouli)
    self._atkfight1:setAnchorPoint(cc.p(0,0.5))
    self._atkfight1:setScale(0.7)
    self._atkfight1:setPosition(cc.p(128, 12))
    labBg1:addChild(self._atkfight1, 1)

    self._deffight1 = cc.LabelBMFont:create("1", UIUtils.bmfName_zhandouli)
    self._deffight1:setAnchorPoint(cc.p(0,0.5))
    self._deffight1:setScale(0.7)
    self._deffight1:setPosition(cc.p(275, 12))
    labBg1:addChild(self._deffight1, 1)

    -- local labBg2 = self:getUI("bg.layer.labBg2")
    -- self._atkfight2 = cc.LabelBMFont:create("1", UIUtils.bmfName_zhandouli)
    -- self._atkfight2:setAnchorPoint(cc.p(0,0.5))
    -- self._atkfight2:setScale(0.8)
    -- self._atkfight2:setPosition(cc.p(128, 12))
    -- labBg2:addChild(self._atkfight2, 1)

    -- self._deffight2 = cc.LabelBMFont:create("1", UIUtils.bmfName_zhandouli)
    -- self._deffight2:setAnchorPoint(cc.p(0,0.5))
    -- self._deffight2:setScale(0.8)
    -- self._deffight2:setPosition(cc.p(275, 12))
    -- labBg2:addChild(self._deffight2, 1)

    self._atkfight2 = self:getUI("bg.layer.labBg2.atkfightNum")
    self._deffight2 = self:getUI("bg.layer.labBg2.deffightNum")

    self._chanchuImg = self:getUI("bg.layer.labBg3.img1")
    self._chanchuLab = self:getUI("bg.layer.labBg3.chanchuLab")

    self._tequan = self:getUI("bg.layer.tequan")
    self._tequanImg = self:getUI("bg.layer.tequan.img1")
    self._tequanLab = self:getUI("bg.layer.tequan.freedomLab")

    self._zhuangtai = self:getUI("bg.layer.zhuangtai")
    self._zhuangtaiLab = self:getUI("bg.layer.zhuangtai.zhuangtai")
    self._jieshi = self:getUI("bg.layer.zhuangtai.jieshi")

    self._iconBg = self:getUI("bg.layer.iconBg")
    self._headIconBg = self:getUI("bg.layer.iconBg.headIconBg")
    self._state = self:getUI("bg.layer.iconBg.headIconBg.state")
    self._playerName = self:getUI("bg.layer.iconBg.headIconBg.playerName")

    self._cityImg = self:getUI("bg.layer.iconBg.cityImg")

    self._witnessBtn = self:getUI("bg.layer.witnessBtn")

    local dispatch = self:getUI("bg.layer.dispatch")
    local dispatchflag = self._cityBattleModel:getCityDispatchDataById(self._cityId)
    if dispatchflag == true then
        dispatch:setVisible(true)
    else
        dispatch:setVisible(false)
    end
    self:registerClickEvent(dispatch, function()
        print("dispatch===派遣", self._cityId)
        -- local cityD = self._cityBattleModel:getCityDataById(self._cityId)
        -- dump(cityD)
        self._viewMgr:showDialog("citybattle.CityBFDispatchDialog", {cityId = self._cityId})
    end)

    self:listenReflash("CityBattleModel", self.reflashUI)
end

-- 根据id获取是否可派遣城池
function CityBattleDetailDialog:getCityDispatchDataById(cityId)
    local cityD = self._cityBattleModel:getCityDataById(self._cityId)
    -- local cityData = {}
    -- if self._data["c"] and self._data["c"]["c"] then
    --     cityData = self._data["c"]["c"][tostring(cityId)]
    -- end
    -- return cityData
end


function CityBattleDetailDialog:reflashUI()
    print('self._cityId===============================', self._cityId)

    local serverNum = self._cityBattleModel:getGVGServerNum()

    local cityTab = tab:CityBattle(self._cityId)
    self._title:setString(lang(cityTab.name))

    -- dump(cityTab, "cityTab===", 10)
    if serverNum == 2 or serverNum == 3 then
        --todo
    end
    local cityscore = cityTab["cityscore" .. serverNum]
    local waitnum = cityTab["waitnum" .. serverNum]

    -- 特权
    local citypvl = cityTab["citypvl" .. serverNum]
    if not citypvl then
        self._tequan:setVisible(false)
    else
        local cityPriTab = tab:CityBattlePrivilege(citypvl)
        self._tequan:setVisible(true)
        self._tequanImg:loadTexture(cityPriTab.icon .. ".png", 1)
        self._tequanLab:setString(lang(cityPriTab.des))
    end

    local cityreward = cityTab["cityreward" .. serverNum]
    if cityreward then
        local itemId = cityreward[2]
        local itemNum = cityreward[3]
        if IconUtils.iconIdMap[cityreward[1]] then
            itemId = IconUtils.iconIdMap[cityreward[1]]
        end
        local toolD = tab:Tool(itemId)
        self._chanchuImg:loadTexture(toolD.art .. ".png", 1)
        self._chanchuLab:setString(itemNum)
        -- self._chanchuLab:setString(lang(toolD.name))
    end

    if not conditions then
        self._headIconBg:setVisible(false)
    end

    if not conditions then
        self._zhuangtai:setVisible(false)
        -- self._zhuangtaiLab = self:getUI("bg.layer.zhuangtai.zhuangtai")
        -- self._jieshi = self:getUI("bg.layer.zhuangtai.jieshi")
    end


    self._cityImg:loadTexture("citybattle_maincity_" .. cityTab.cityart .. ".png", 1)

    -- self._witnessBtn = self:getUI("bg.layer.witnessBtn")

    local cityD = self._cityBattleModel:getCityDataById(self._cityId)
    dump(cityD, "cityD=====")
    local as = math.ceil(cityD.as/10000) .. "w"
    self._atkfight1:setString(as)
    local ds = math.ceil(cityD.ds/10000) .. "w"
    self._deffight1:setString(ds)

    self._atkfight2:setString(cityD.an)
    self._deffight2:setString(cityD.dn)

    if self._cityBattleModel:getCheckState() then
        self._witnessBtn:setTitleText("观战")
        self:registerClickEvent(self._witnessBtn, function()
            self._viewMgr:showView("citybattle.CityBattleFightView", {cityId = self._cityId})
        end)
    else
        self._witnessBtn:setTitleText("查看")
        self:registerClickEvent(self._witnessBtn, function()
            print("witnessBtn===查看")
            local param = {cid = self._cityId}
            self:getAtkQueue(param, callback)
        end)
    end

    -- self:registerClickEvent(self._witnessBtn, function()
    --     self:test()
    -- end)
end

function CityBattleDetailDialog:test()
    local temp = {}
    for i=1,20 do
        temp[i] = {i}
    end
    dump(temp, "===========")
    -- table.remove(temp, 1)
    dump(temp, "temp======")
    table.insert(temp, 16, 1)
    dump(temp, "temp====1111==")

end

-- 获取列表
function CityBattleDetailDialog:getAtkQueue(param, callback)
    local param = {cityId = self._cityId, ltype = ltype}
    self._viewMgr:showDialog("citybattle.CityBFDispatchListDialog", param)
    -- self._serverMgr:sendMsg("CityBattleServer", "getAtkQueue", param, true, {}, function (result)
    --     dump(result, "result=========", 10)
    --     if self.getAtkQueueFinish then
    --         self:getAtkQueueFinish(result)
    --     end
    -- end)
end

function CityBattleDetailDialog:getAtkQueueFinish(result)
    local ltype = 1
    if table.nums(result) == 0 then
        ltype = 2
    end
    local param = {atkList = result, ltype = ltype}
    self._viewMgr:showDialog("citybattle.CityBFDispatchListDialog", param)
end

return CityBattleDetailDialog