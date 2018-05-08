--[[
    Filename:    ItemUtils.lua
    Author:      <libolong@playcrab.com>
    Datetime:    2015-05-29 15:13:37
    Description: File description
--]]

local ItemUtils = {}

ItemUtils.ITEM_KIND_TEAMSOUL = 1      -- 怪兽魂魄
ItemUtils.ITEM_KIND_MATERIAL = 2      -- 装备技能材料
ItemUtils.ITEM_KIND_TREASURE = 3   -- 英雄宝物
ItemUtils.ITEM_KIND_HEROSOUL = 4  -- 英雄魂
ItemUtils.ITEM_KIND_CONSUMABLES = 9   -- 消耗品

ItemUtils.ITEM_BUT_NIL = 0        -- 空
ItemUtils.ITEM_BUT_SPLICE = 1     -- 拼合
ItemUtils.ITEM_BUT_USE = 2        -- 批量使用(使用)
ItemUtils.ITEM_BUT_INFO = 3       -- 详情
ItemUtils.ITEM_BUT_EXP = 4        -- 经验道具(使用)
ItemUtils.ITEM_TYPE_SPLICE = 1     -- 怪兽碎片
ItemUtils.ITEM_TYPE_MATERIAL = 2   -- 符文材料
ItemUtils.ITEM_TYPE_EXP = 3        -- 经验材料
ItemUtils.ITEM_TYPE_GIFT = 4       -- 礼包
ItemUtils.ITEM_TYPE_TREASURE = 5   -- 英雄宝物
ItemUtils.ITEM_TYPE_HEROSPLICE = 6   -- 英雄魂魄
ItemUtils.ITEM_TYPE_AWAKESPLICE = 13 -- 觉醒碎片
ItemUtils.ITEM_TYPE_SKILL       = 14 -- 法术碎片
ItemUtils.ITEM_TYPE_OTHER = 99     -- 其他道具

ItemUtils.formatItemCount = function( number,symbol )
    local num = tonumber(number)
    if num == nil then return number end
    if num > 99999 then
        local integer = math.floor(num/10000)
        symbol = symbol or "万"
        if num < 1000000 then
            local decimal = math.floor(num/1000)%10
            num = integer+decimal/10
        else
            num = integer
        end
    else
        symbol = ""
    end
    return num .. symbol
end
-- 根据数量确认资源道具图标底和框的颜色
ItemUtils.findResIconColor = function( itemId,num )
    local color
    -- local itemcolorIdx = tab.itemcolor[itemId]
    local toolD = tab.tool[itemId]
    if toolD and toolD.color == 9 then
        local num  = tonumber(num) or 0
        local low,high = toolD.range[1],toolD.range[2]
        if num <= low then
            color = 3
        elseif num > low and num < high then
            color = 4
        elseif num >= high then
            color = 5
        end
    end
    if not color and tab:Tool(itemId) and tab:Tool(itemId).color then
        color = tab:Tool(itemId).color
    end
    return color or 1
end
-- 随机名字
local nameDepartIndexMap
ItemUtils.randUserName = function( )
    if nameDepartIndexMap == nil then
        nameDepartIndexMap = {}
        local name = tab.name
        local style = 1
        table.insert(nameDepartIndexMap,style)
        for i,v in ipairs(name) do
            if v.nametype ~= style then
                table.insert(nameDepartIndexMap,i)
                style = v.nametype
            end
        end
        table.insert(nameDepartIndexMap,#name)
    end
    local str = ""  
    local clockT = math.floor(os.clock()*10)
    GRandomSeed(tostring(os.time()+clockT):reverse():sub(1, 6)) 
    local rand1 = (GRandom(1,nameDepartIndexMap[2]))
    GRandomSeed(tostring(os.time()+clockT):reverse():sub(1, 7)) 
    local rand2 = GRandom(nameDepartIndexMap[2],nameDepartIndexMap[3])
    GRandomSeed(tostring(os.time()+clockT):reverse():sub(1, 5)) 
    local rand3 = GRandom(nameDepartIndexMap[3],nameDepartIndexMap[4])
 -- print("rand",rand1,rand2,rand3)
    local firstName = tab:Name(rand1)[GameStatic.language] or tab:Name(rand1)["cn"]
    local midName = tab:Name(rand2)[GameStatic.language] or tab:Name(rand2)["cn"]
    local lastName = tab:Name(rand3)[GameStatic.language] or tab:Name(rand3)["cn"]
    str = firstName .. midName .. "·" .. lastName 
    return str
end

-- ItemUtils.formatItemCount = function( number )
--     local num = tonumber(number)
--     if num == nil then return number end
--     local symbol = ""
--     if num > 9999 then
--         local temp = num / 1000
--         num = math.floor(num / 1000)
--         if temp <= num then
--             symbol = "k"
--         else
--             symbol = "k+"
--         end
--         if num > 999 then
--             temp = num / 1000
--             num = math.floor(num / 1000)
--             if temp <= num then
--                 symbol = "m"
--             else
--                 symbol = "m+"
--             end
--             if num > 999 then
--                 temp = num / 1000
--                 num = math.floor(num / 1000)
--                 if temp <= num then
--                     symbol = "b"
--                 else
--                     symbol = "b+"
--                 end
--             end
--         end
--     end
--     return num .. symbol,symbol
-- end

function ItemUtils.dtor()
    ItemUtils = nil
    nameDepartIndexMap = nil
end

function ItemUtils.createRewardNode(inRwd, inParam)
    local node = ccui.Layout:create()
    node:setContentSize(cc.size(70, 35))

    local scale = inParam["scale"] or 1
    local noOutLine = inParam["noOutLine"]

    -- 物品
    local curType = inRwd[1] or inRwd["type"]
    local itemId = inRwd[2] or inRwd["id"]
    if curType == "tool" then

    elseif curType == "crusading" then
        itemId = IconUtils.iconIdMap["crusading"]

    elseif curType == "gold" then
        itemId = IconUtils.iconIdMap["gold"]

    elseif curType == "gem" then
        itemId = IconUtils.iconIdMap["gem"]

    elseif curType == "treasureCoin" then
        itemId = IconUtils.iconIdMap["treasureCoin"]

    elseif curType == "texp" then
        itemId = IconUtils.iconIdMap["texp"]
    end

    local sysItem = tab:Tool(itemId)
    local item = IconUtils:createItemIconById({itemId = itemId, itemData = sysItem})
    item:setAnchorPoint(cc.p(0, 0.5))
    item:setPosition(0, 15)
    item:setScale(scale)
    node:addChild(item)

    if sysItem.typeId == ItemUtils.ITEM_TYPE_TREASURE then
        local mc1 = mcMgr:createViewMC("wupinguang_itemeffectcollection", true)
        mc1:setPosition(item:getContentSize().width/2 ,item:getContentSize().height/2)
        item:addChild(mc1, 10)
    end

    local width = item:getContentSize().width * item:getScale()
    local num = cc.Label:createWithTTF(inRwd[3], UIUtils.ttfName, 20)
    num:setAnchorPoint(cc.p(0, 0.5))
    num:setPosition(width + 5, 15)
    
    if noOutLine then
        num:setColor(UIUtils.colorTable.ccUIBaseDescTextColor1)
    else
        num:setColor(UIUtils.colorTable.ccUIBaseColor1)
        num:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    end
    node:addChild(num)

    width = width + num:getContentSize().width + 15
    return node, width
end

return ItemUtils
