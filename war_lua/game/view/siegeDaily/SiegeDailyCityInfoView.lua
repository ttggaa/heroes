--[[
    @FileName   SiegeDailyCityInfoView.lua
    @Authors    hexinping
    @Date       2017-09-14 
    @Email      <hexinping@playcrad.com>
    @Description   攻城城市信息UI
--]]

local  SiegeDailyCityInfoView = class("SiegeDailyCityInfoView",BasePopView)

function SiegeDailyCityInfoView:ctor(params)
    self.super.ctor(self)
    self._dailySiegeModel = self._modelMgr:getModel("DailySiegeModel")
end

function SiegeDailyCityInfoView:onInit()
    self._listView = self:getUI("bg.bg2.tableNode.listView")
    self._item     = self:getUI("bg.item")
    self:registerClickEventByName("bg.closeBtn", function()
        self:close()
        if self._callBack then
            self._callBack()
        end
        UIUtils:reloadLuaFile("siegeDaily.SiegeDailyCityInfoView")
    end)
    self:update()
end

function SiegeDailyCityInfoView:update()
    self._listView:removeAllItems()
    local cityDatas = self._dailySiegeModel:getAttackThemeInfo()
    for i,v in ipairs(cityDatas) do
        local item = self._item:clone()
        item:setVisible(true)
        local icon = item:getChildByFullName("targetBg.img")
        local name =  item:getChildByFullName("name")
        local des =  item:getChildByFullName("des")
        icon:loadTexture(v.iconPng,1)
        name:setString(v.name)
        
        local strDes = RichTextFactory:create(lang(v.des),355,52)
        strDes:formatText()
        strDes:setVerticalSpace(3)
        strDes:setAnchorPoint(cc.p(0,0))
        local w = strDes:getInnerSize().width
        local h = strDes:getVirtualRendererSize().height
        strDes:setPosition(cc.p(-w*0.5,-h*0.5))
        des:addChild(strDes)
        self._listView:pushBackCustomItem(item)
    end

    -- 开启回弹会导致偏移，重新刷一遍
    local itemH = self._item:getSize().height
    local innerContainer = self._listView:getInnerContainer()
    innerContainer:setPosition(0,-itemH*0.5)
    self._listView:refreshView()
end

function SiegeDailyCityInfoView:_clearVars()
    self._listView = nil
    self._item = nil
end

function SiegeDailyCityInfoView:onDestroy()
    self._listView:removeAllItems()
    self:_clearVars()
end

return SiegeDailyCityInfoView