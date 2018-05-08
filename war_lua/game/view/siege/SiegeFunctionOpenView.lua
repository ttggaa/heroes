--[[
    @FileName   SiegeFunctionOpenView.lua
    @Authors    zhangtao
    @Date       2017-09-20 11:17:24
    @Email      <zhangtao@playcrad.com>
    @Description   描述
--]]
local SiegeFunctionOpenView = class("SiegeFunctionOpenView",BasePopView)
function SiegeFunctionOpenView:ctor(params)
    self.super.ctor(self)
    self._currLevel = params.level
    self._siegeModel = self._modelMgr:getModel("SiegeModel")
end

-- 初始化UI后会调用, 有需要请覆盖
function SiegeFunctionOpenView:onInit()
    local closeBtn = self:getUI("bg.closeBtn")
    self:registerClickEvent(closeBtn,function()
        self:close()
        UIUtils:reloadLuaFile("siege.SiegeFunctionOpenView")
    end)

    local title = self:getUI("bg.titleBg.title")
    UIUtils:setTitleFormat(title, 1)

    self._listView = self:getUI("bg.panel.listView")
    self._item     = self:getUI("bg.panel.cell")
    self._item:setVisible(false)
end


-- 接收自定义消息
function SiegeFunctionOpenView:reflashUI(data)
    self._listView:removeAllItems()
    local cityDatas = self._siegeModel:getWallFunctionInfo()
    for i,v in ipairs(cityDatas) do
        local item = self._item:clone()
        item:setVisible(true)
        local icon = item:getChildByFullName("icon")
        local name =  item:getChildByFullName("name")
        local openLevel = item:getChildByFullName("openLevel")
        local des =  item:getChildByFullName("desText")
        local zhezhao = item:getChildByFullName("zhezhao")
        icon:loadTexture(v.icon,1)
        name:setString(v.name)
        des:setString(v.des)

        local condition = v.openLevel
        if self._currLevel < condition then
            openLevel:setString("(城墙"..condition.."级开启)")
            zhezhao:setVisible(true)
            item:loadTexture("globalPanelUI7_cellBg22.png",1)
        else
            openLevel:setString("")
            zhezhao:setVisible(false)
            item:loadTexture("globalPanelUI7_innerBg2.png",1)
        end 
        self._listView:pushBackCustomItem(item)
    end
end

function SiegeFunctionOpenView:_clearVars()
    self._listView = nil
    self._item = nil
end

function SiegeFunctionOpenView:onDestroy()
    self._listView:removeAllItems()
    self:_clearVars()
end


return SiegeFunctionOpenView