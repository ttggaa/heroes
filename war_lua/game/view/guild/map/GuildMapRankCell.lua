--[[
    Filename:    GuildMapRankCell.lua
    Author:      <weiwei02@playcrab.com>
    Datetime:    2017-04-14 10:35:12
    Description: File description
--]]



local GuildMapRankCell = class("GuildMapRankCell", cc.TableViewCell)

function GuildMapRankCell:ctor(inContainer)
    -- GuildMapRankCell.super.ctor(self)
    self:registerScriptHandler(function(eventType)
        if eventType == "exit" then 
            UIUtils:reloadLuaFile("guild.map.GuildMapRankCell")
        elseif eventType == "enter" then 
        end
    end)
    self._rankItem = inContainer
    self:onInit()
end

function GuildMapRankCell:onInit()
    print("GuildMapRankCell================1")
    if self._rankItem ~= nil then
        self._rankItem:setAnchorPoint(0, 0)
        self._rankItem:setPosition(2, 4)
        self:addChild(self._rankItem)

        local selfTag = self._rankItem:getChildByFullName("selfTag")
        selfTag:setVisible(false)

        local nameLab = self._rankItem:getChildByFullName("nameLab")
        nameLab:setColor(cc.c4b(70,40,0,255))
        local guildNameLab = self._rankItem:getChildByFullName("guildNameLab")
        guildNameLab:setColor(cc.c4b(70,40,0,255))
        guildNameLab:setPositionX(guildNameLab:getPositionX()-5)
        local scoreLab = self._rankItem:getChildByFullName("scoreLab")
        scoreLab:setColor(cc.c4b(70,40,0,255))        
    end
end

function GuildMapRankCell:reflashUI(inData)  -- 442/119
    local rankImgs = {"firstImg","secondImg","thirdImg"}
    self._rankItem:setVisible(true)
    self._currItem = self._rankItem
    self._rankItem:setVisible(true)
    self._rankItem.data = inData
    local rank = inData.rank
    local score = inData.score

    local nameLab = self._rankItem:getChildByFullName("nameLab")
    nameLab:setString(inData.name)
    
    local guildNameLab = self._rankItem:getChildByFullName("guildNameLab")
    guildNameLab:setString(inData.guildName)
    
    local scoreLab = self._rankItem:getChildByFullName("scoreLab")
    scoreLab:setString(score)

    local txt  = self._rankItem:getChildByFullName("txt")
    if txt then
        txt:setVisible(false)
        txt:removeFromParent()
    end
    local rankLab = self._rankItem:getChildByName("rankLab")
    if not rankLab then
        rankLab = ccui.Text:create()
        rankLab:setAnchorPoint(cc.p(0.5,0.5))
        rankLab:setFontSize(30)
        rankLab:setColor(cc.c4b(60,42,30,255))
        rankLab:setPosition(62, 50)
        rankLab:setName("rankLab")
        self._rankItem:addChild(rankLab, 1)
    end
    rankLab:setString(rank or 0)

    -- if rank <= 3 and rank > 0 then
    --     self._rankItem:loadTexture("arenaRankUI_cellBg".. rank ..".png",1)
    -- else
    --     self._rankItem:loadTexture("arenaRankUI_cellBg4.png",1)
    -- end
    -- self._rankItem:setCapInsets(cc.rect(160,40,1,1))
    for i=1,3 do
        local rankImg = self._rankItem:getChildByFullName(rankImgs[tonumber(i)])
        rankImg:setVisible(false)
    end
    if rankImgs[tonumber(rank)] then
        rankLab:setVisible(false)
        local rankImg = self._rankItem:getChildByFullName(rankImgs[tonumber(rank)])
        -- rankImg:setScale(2)
        rankImg:setVisible(true)
    else
        rankLab:setVisible(true)
        rankLab:setPosition(62,50)
    end
    -- registerClickEvent(self._rankItem,function( )
    --     if not self._inScrolling then
    --         self:itemClicked(self._rankItem.data)          
    --     else
    --         self._inScrolling = false
    --     end
    -- end)
    self._rankItem:setSwallowTouches(false)

end

function GuildMapRankCell:setCallback(inCallback)
    self._callback = inCallback
end

return GuildMapRankCell