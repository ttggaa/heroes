--[[
    Filename:    GuildMapEquipView.lua
    Author:      <weiwei02@playcrab.com>
    Datetime:    2017-04-06 21:42:59
    Description: File description
--]]


local GuildMapEquipView = class("GuildMapEquipView", BasePopView)

function GuildMapEquipView:ctor(data)
    GuildMapEquipView.super.ctor(self)

    self:registerScriptHandler(function(eventType)
        if eventType == "exit" then 
            UIUtils:reloadLuaFile("guild.map.GuildMapEquipView")
        elseif eventType == "enter" then 
        end
    end)   

    
end


function GuildMapEquipView:onInit()
    local closeBtn = self:getUI("bg.closeBtn")
    self:registerClickEvent(closeBtn, function ()
        self:close()
    end)

    local bg = self:getUI("bg")
    bg:loadTexture("asset/bg/guildMap/guild_map_equip_bg.png")

    local titleLab = self:getUI("bg.titleBg.titleLab")
    UIUtils:setTitleFormat(titleLab, 5)

    local attackTipLab = self:getUI("bg.attackTipLab")
    attackTipLab:setColor(UIUtils.colorTable.ccUIBaseTextColor2)

    local defTipLab = self:getUI("bg.defTipLab")
    defTipLab:setColor(UIUtils.colorTable.ccUIBaseTextColor2)

    local intelTipLab = self:getUI("bg.intelTipLab")
    intelTipLab:setColor(UIUtils.colorTable.ccUIBaseTextColor2)

    local knowledgeTipLab = self:getUI("bg.knowledgeTipLab")
    knowledgeTipLab:setColor(UIUtils.colorTable.ccUIBaseTextColor2)


    local attackLab = self:getUI("bg.attackLab")
    attackLab:setColor(UIUtils.colorTable.ccUIBaseColor2)
    attackLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    
    local defLab = self:getUI("bg.defLab")
    defLab:setColor(UIUtils.colorTable.ccUIBaseColor2)
    defLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)

    local intelLab = self:getUI("bg.intelLab")
    intelLab:setColor(UIUtils.colorTable.ccUIBaseColor2)
    intelLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)

    local knowledgeLab = self:getUI("bg.knowledgeLab")
    knowledgeLab:setColor(UIUtils.colorTable.ccUIBaseColor2)
    knowledgeLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)

    local userData = self._modelMgr:getModel("UserModel"):getData()
    local lvl = userData.lvl

    for k,v in pairs(tab.guildEquipment) do
        local numBg = self:getUI("bg.positionBg" .. v.position .. ".numBg")
        numBg:setVisible(false)
    end
    
    local attackNum = 0
    local defNum = 0
    local intelNum = 0
    local knowledgeNum = 0
    print("userData.roleGuild.mapequip====")
    dump(userData.roleGuild.mapequip, "test", 10)
    if userData.roleGuild ~= nil and userData.roleGuild.mapequip ~= nil then 
        for k,v in pairs(userData.roleGuild.mapequip) do
            local sysEquip = tab.guildEquipment[tonumber(k)]
            if sysEquip ~= nil then
                local positionBg = self:getUI("bg.positionBg".. sysEquip.position)

   
                local icon = cc.Sprite:createWithSpriteFrameName(sysEquip.art .. ".png")
                icon:setPosition(positionBg:getContentSize().width * 0.5, positionBg:getContentSize().height * 0.5)
                icon:setScale(0.5)
                positionBg:addChild(icon)

                self:registerClickEvent(positionBg, function ()
                    positionBg.offsetX = positionBg:getContentSize().width + 5
                    self._viewMgr:showHintView("global.GlobalTipView", { tipType = 19, node = positionBg, id = sysEquip.id, notAutoClose=true})
                end)
    
                if v > 1 then  
                    local numBg = positionBg:getChildByName("numBg")
                    numBg:setVisible(true)

                    local numLab = numBg:getChildByName("numLab")
                    numLab:setString(v)
                    numLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
                end
                -- 整理属性加成
                local attr = {}
                for k,v1 in pairs(sysEquip.arrt) do
                    if v1[1][1] <= lvl and lvl <= v1[1][2] then
                        attr = v1[2]                                               
                        break
                    end
                end
                for k,v2 in pairs(attr) do
                    if v2[1] == 110 then 
                        attackNum = attackNum + v2[2] * v
                    elseif v2[1] == 113 then 
                        defNum = defNum + v2[2] * v
                    elseif v2[1] == 116 then 
                        intelNum = intelNum + v2[2] * v
                    elseif v2[1] == 119 then 
                        knowledgeNum = knowledgeNum + v2[2] * v
                    end
                end 

            end
        end
    end

    attackLab:setString("+" .. attackNum)

    defLab:setString("+" .. defNum)

    intelLab:setString("+" .. intelNum)

    knowledgeLab:setString("+" .. knowledgeNum)
end

return GuildMapEquipView