--[[
    Filename:    ProgressNode.lua
    Author:      <weiwei02@playcrab.com>
    Datetime:    2016-07-03 16:04:19
    Description: File description
--]]

local ProgressNode = class("ProgressNode", ccui.Widget)


function ProgressNode:ctor(inData)
    self:onInit(inData)
end


function ProgressNode:onExit()
    -- if self.__depleteSchedule ~= nil then 
    --     ScheduleMgr:unregSchedule(self.__depleteSchedule)
    --     self.__depleteSchedule = nil
    -- end
end

local nameColor = {cc.c4b(199, 88, 96, 255), cc.c4b(17, 93, 98, 255), cc.c4b(127, 223, 35, 255), cc.c4b(255, 255, 255, 255)}
function ProgressNode:onInit(inData)
    self._data = inData
    self:registerScriptHandler(function(eventType)
        if eventType == "exit" then 
            nameColor = nil
            UIUtils:reloadLuaFile("guild.map.ProgressNode")
            self:onExit()
        elseif eventType == "enter" then 
            -- self:onEnter()
        end
    end)   

    if self["onInitStyle" .. inData.style] == nil then 
        return
    end
    self["onInitStyle" .. inData.style](self)

    -- self.__depleteSchedule = ScheduleMgr:regSchedule(1, self, function()
    --     self:update()
    -- end)

end

function ProgressNode:onInitStyle1()
    local bg = cc.Sprite:createWithSpriteFrameName("guildMapImg_progressBg2.png")
    self:setContentSize(cc.size(bg:getContentSize().width, bg:getContentSize().height))
    bg:setPosition(cc.p(-30, 0))
    bg:setAnchorPoint(cc.p(0, 0))
    self:addChild(bg)
    local sp = cc.Sprite:createWithSpriteFrameName("guildMapImg_progress2.png")
    -- CCSprite* bg = CCSprite::create("2.png");  
    self._progress = cc.ProgressTimer:create(sp)
    self._progress:setPosition(cc.p(-30, 0))
    self._progress:setAnchorPoint(cc.p(0, 0))
    self._progress:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    self._progress:setMidpoint(cc.p(0, 0.5))
    self._progress:setBarChangeRate(cc.p(1, 0))    
    self._progress:setPercentage(0)
    self:setScaleX(0.8)
    -- self._progress:setScale(-1)
    self:addChild(self._progress)



    local effect = mcMgr:createViewMC("shangfangjian_guildmapzhanling", true)
    effect:setScale(0.6)
    effect:setPosition(-50, 5)
    self:addChild(effect)

    -- //从左到右  
    -- progressTimer->setMidpoint(ccp(0, 0.5));  
    -- progressTimer->setBarChangeRate(ccp(1, 0));  
  
    -- //从右到左  
    -- //    progressTimer->setMidpoint(ccp(1, 0.5));  
    -- //    progressTimer->setBarChangeRate(ccp(1, 0));  
  
    -- //从上到下  
    -- //    progressTimer->setMidpoint(ccp(0.5, 1));  
    -- //    progressTimer->setBarChangeRate(ccp(0, 1));  
  
    -- //从下到上  
    -- //    progressTimer->setMidpoint(ccp(0.5, 0));  
    -- //    progressTimer->setBarChangeRate(ccp(0, 1));  
end

function ProgressNode:onInitStyle2()
    local bg = cc.Sprite:createWithSpriteFrameName("citybattle_view_progbg.png")
    self:setContentSize(cc.size(bg:getContentSize().width, bg:getContentSize().height))
    bg:setPosition(cc.p(0, 0))
    bg:setAnchorPoint(cc.p(0, 0))
    self:addChild(bg)

    self._tempSp = cc.Sprite:createWithSpriteFrameName("citybattle_view_progss" .. self._data.type .. ".png")
    -- CCSprite* bg = CCSprite::create("2.png");  
    self._progress = cc.ProgressTimer:create(self._tempSp)
    self._progress:setPosition(cc.p(0, 0))
    self._progress:setAnchorPoint(cc.p(0, 0))
    self._progress:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    self._progress:setMidpoint(cc.p(0, 0.5))
    self._progress:setBarChangeRate(cc.p(1, 0))    
    self._progress:setPercentage(0)
    -- self._progress:setColor(cc.c4b(255, 58, 51, 255))
    self:setScaleX(0.8)
    self._progress.type = self._data.type
    -- self._progress:setScale(-1)
    -- self._progress:setColor(nameColor[self._data.type])
    self:addChild(self._progress)
end

function ProgressNode:updateProgress(inPercent)
    if  self._progress ~= nil then 
        self._progress:setPercentage(inPercent)
    end
end
 

function ProgressNode:updateType(inType)
    if self._progress.type == inType then return end
    self._tempSp:setSpriteFrame("citybattle_view_progss" .. inType .. ".png")
    self._progress.type = inType
end

return ProgressNode