--[[
    Filename:    MFRobDialog.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2016-10-13 11:42:53
    Description: File description
--]]


-- 航海规则
local MFRobDialog = class("MFRobDialog", BasePopView)

function MFRobDialog:ctor()
    MFRobDialog.super.ctor(self)
end


function MFRobDialog:onInit()
    local title = self:getUI("bg.titleBg.title")
    UIUtils:setTitleFormat(title, 6)
    -- title:setFontName(UIUtils.ttfName)
    -- -- title:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 2)
    -- title:setFontSize(30)

    self:registerClickEventByName("bg.backBtn", function ()
        if OS_IS_WINDOWS then
            UIUtils:reloadLuaFile("MF.MFRobDialog")
        end
        self:close()
    end)
    self:registerClickEventByName("bg.closeBtn", function ()
        if OS_IS_WINDOWS then
            UIUtils:reloadLuaFile("MF.MFRobDialog")
        end
        self:close()
    end)
end

function MFRobDialog:reflashUI(data)
    dump(data, "data ===", 10)

    local robType = data.robType
    local tempTask = data.tempTask
    local num = table.nums(data.tempTask.robbed)
    local robbed = data.tempTask.robbed[num]

    local taskTab = tab:MfTask(tempTask.taskId)
    local str
    local tempNum = num
    if tempNum == 2 then
        local name1 = data.tempTask.robbed[1]["_id"]
        local name2 = data.tempTask.robbed[2]["_id"]
        if name1 == name2 then
            tempNum = 1
        end
    end

    if tempNum == 2 then
        local name1 = data.tempTask.robbed[1]["name"]
        local name2 = data.tempTask.robbed[2]["name"]

        if data.robType == 2 then
            str = lang("MF_LOOT12")
            str = string.gsub(str, "{$name}", name1)
            str = string.gsub(str, "{$name1}", name2)
            str = string.gsub(str, "{$num1}", num)
        else
            str = lang("MF_LOOT13")
            str = string.gsub(str, "{$name}", name1)
            str = string.gsub(str, "{$name1}", name2)
            str = string.gsub(str, "{$num}", taskTab["time"])
            str = string.gsub(str, "{$num1}", (taskTab["time"]+num))
        end
    else
        if data.robType == 2 then
            str = lang("MF_LOOT1")
            str = string.gsub(str, "{$name}", robbed.name)
            str = string.gsub(str, "{$num1}", num)
        else
            str = lang("MF_LOOT11")
            str = string.gsub(str, "{$name}", robbed["name"])
            str = string.gsub(str, "{$num}", taskTab["time"])
            str = string.gsub(str, "{$num1}", (taskTab["time"]+num))
        end
    end

    local panel = self:getUI("bg.panel")
    local richText = RichTextFactory:create(str, panel:getContentSize().width, 0)
    richText:formatText()
    local height  = panel:getContentSize().height
    if height < richText:getRealSize().height then
        height = richText:getRealSize().height
    end
    richText:setPosition(panel:getContentSize().width/2, richText:getRealSize().height*0.5)
    panel:addChild(richText)
end

return MFRobDialog