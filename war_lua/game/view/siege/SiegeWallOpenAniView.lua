--[[
    @FileName   SiegeWallOpenAniView.lua
    @Authors    zhangtao
    @Date       2017-10-16 20:30:08
    @Email      <zhangtao@playcrad.com>
    @Description   描述
--]]
local  SiegeWallOpenAniView= class("SiegeWallOpenAniView",BasePopView)
function SiegeWallOpenAniView:ctor(data)
    self.super.ctor(self)
    -- self._parent = data.parent
    self._name = data.name
    self._icon = data.icon
    self._callBack = data.callBack
end

-- 初始化UI后会调用, 有需要请覆盖
function SiegeWallOpenAniView:onInit()
    print("========SiegeWallOpenAniView==========")
    local bg = self:getUI("bg")
    self:registerClickEventByName("bg", function ()
        UIUtils:reloadLuaFile("siege.SiegeWallOpenAniView")
        self:close()
        -- self._parent:showWallOpen()
        self._callBack()
    end)
    local innerBg = self:getUI("bg.innerBg")
    local innerContentSize = innerBg:getContentSize()
    local mc = mcMgr:createViewMC("diguang_lianmengjihuo", true, false, function (_, sender)

    end, RGBA8888)  
    -- mc:setScale(1.2)       
    mc:setPosition(innerContentSize.width * 0.5, innerContentSize.height * 0.5-10)
    innerBg:addChild(mc, 1)

    self:getUI("bg.innerBg.borderBg.icon"):loadTexture(self._icon,1)
    self:getUI("bg.innerBg.borderBg.name"):setString(self._name)
end

-- 第一次进入调用, 有需要请覆盖
function SiegeWallOpenAniView:onShow()

end


-- 接收自定义消息
function SiegeWallOpenAniView:reflashUI(data)

end

return SiegeWallOpenAniView