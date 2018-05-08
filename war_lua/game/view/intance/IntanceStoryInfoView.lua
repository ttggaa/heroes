--[[
    Filename:    IntanceStoryInfoView.lua
    Author:      <weiwei02@playcrab.com>
    Datetime:    2017-01-31 22:39:57
    Description: File description
--]]


local IntanceStoryInfoView = class("IntanceStoryInfoView", BasePopView)

function IntanceStoryInfoView:ctor(data)
    self._showTitle = data.title
    self._showDesc = lang(data.story)
    print("self._showDesc==============", self._showDesc, data.story)
    self._musicName = data.story
    self._callback = data.callback

    self._isBegin = data.isBegin or 1
    
    IntanceStoryInfoView.super.ctor(self)
    self._printerJump = false
    self._isClose = false
    -- if data.test == 1 then
    --     local sfc = cc.SpriteFrameCache:getInstance()
    --     sfc:addSpriteFrames("asset/ui/intanceWorld.plist", "asset/ui/intanceWorld.png")
    -- end

end


function IntanceStoryInfoView:onInit()
    local bg1 = self:getUI("bg.bg1")
    bg1:loadTexture("asset/bg/bg_godwar_002.png")
    -- bg1:setScale(1)
    -- bg1:setScale(0.9)
    self:registerClickEvent(self._widget, function ()
        if self._printerJump == false and not self._printerText:allFinished() then 
            self._printerText:finishAll()
            self._printerJump = true
            return 
        end
        if self._isClose == true then 
            return
        end
        self._isClose = true
        if self._callback ~= nil then
            self._callback()
        end
        audioMgr:playMusic("campaign", true)
        self:close()
    end)
    self:registerScriptHandler(function(eventType)
        if eventType == "exit" then 
            UIUtils:reloadLuaFile("intance.IntanceStoryInfoView")
            audioMgr:stopSound(self._soundId)
        elseif eventType == "enter" then 

        end
    end)

end

function IntanceStoryInfoView:reflashUI()
    local title = self:getUI("bg.title")
    -- UIUtils:setTitleFormat(title, 1)
    title:setColor(UIUtils.colorTable.ccUIBaseColor6)
    if self._isBegin == 1 then
        title:setString(self._showTitle .. lang("mainstorytitle_start"))   
    else
        title:setString(self._showTitle .. lang("mainstorytitle_end"))
    end
    local leftImg = self:getUI("bg.Image_54")
    leftImg:setPositionX(title:getPositionX() - title:getContentSize().width * 0.5 - 25)

    local rightImg = self:getUI("bg.Image_54_0")
    rightImg:setPositionX(title:getPositionX() + title:getContentSize().width * 0.5 + 25)

    local str = self._showDesc
    if string.find(str, "color=") == nil then
        str = "[color=000000]".. str .."[-]"
    end
    -- str = " \
    -- [color=ffffff]　　在大陆的东方出现了许多异族的身影，已经有三座城池被他们接连占领，将军，我们必须守卫自己的领土，而这一切需要你的力量。[-][][-] \
    -- [color=ffffff]　[-][][-][color=ffffff]　[-][][-][color=ffffff]1、将军需要经历15场战斗，每次胜利可以获得金币，符文材料，以及帝国的奖赏。[-][][-] \
    -- [color=ffffff]　[-][][-][color=ffffff]2、战斗中怪兽死亡将不能继续上阵，但是可以在编组外重新选择一个代替他。[-][][-] \
    -- [color=ffffff]　[-][][-][color=ffffff]3、战斗出现超时，则算作双方同归于尽。[-][][-] \
    -- [color=ffffff]　[-][][-][color=ffffff]4、将军需要特别小心脚下的土地，当您踏入禁魔大地时，您的魔法值将无法得到回复。[-][][-] \
    -- [color=ffffff]　[-][][-][color=ffffff]5、征战途中，您会遇到各种建筑，拜访他们可以获得奖励。[-][][-] \
    -- "
    self._descBg = self:getUI("bg.descBg")
    self._printerText = RichTextFactory:create(str, self._descBg:getContentSize().width, 0)
    self._printerText:setPrintInterval(0.1)
    self._printerText:setPixelNewline(true)
    self._printerText:enablePrinter(true)
    self._printerText:formatText()

    local height  = self._descBg:getContentSize().height
    if height < self._printerText:getRealSize().height then
        height = self._printerText:getRealSize().height
    end
    self._printerText:setPosition(self._descBg:getContentSize().width/2, self._descBg:getContentSize().height - self._printerText:getRealSize().height/2)
    self._descBg:addChild(self._printerText)

    
    self._soundId = audioMgr:playSound(self._musicName)
    -- self._printerText:finishAll()
end

return IntanceStoryInfoView