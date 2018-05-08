--[[
    Filename:    CrossDetailDialog.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2017-11-13 16:26:50
    Description: File description
--]]

-- 积分详情

local CrossDetailDialog = class("CrossDetailDialog", BasePopView)

function CrossDetailDialog:ctor()
    CrossDetailDialog.super.ctor(self)
end

function CrossDetailDialog:onInit()
    self:registerClickEventByName("bg.closeBtn", function()
        if OS_IS_WINDOWS then
            UIUtils:reloadLuaFile("cross.CrossDetailDialog")
        end
        self:close()
    end)

    self._crossModel = self._modelMgr:getModel("CrossModel")


    local title = self:getUI("bg.titleBg.title")
    UIUtils:setTitleFormat(title, 1)

    self:refreshUI()

    for i=1,3 do
        self:updateArenaScore(i)
    end
    -- self:registerClickEvent(title, function()
    --     self:test()
    -- end)
end


function CrossDetailDialog:updateArenaScore(indexId)
    local arenaData = self._crossModel:getData()
    local regiontype = arenaData["regiontype" .. indexId]
    local titleStr = lang("cp_nameRegion" .. regiontype)

    local sname1 = self:getUI("bg.serverLayer1.sname" .. indexId)
    local sname2 = self:getUI("bg.serverLayer2.sname" .. indexId)

    sname1:setString(titleStr)
    sname2:setString(titleStr)

    local sscore1 = self:getUI("bg.serverLayer1.sscore" .. indexId)
    local sscore2 = self:getUI("bg.serverLayer2.sscore" .. indexId)


    local sec1score = arenaData["sec1region" .. indexId .. "score"] or 0
    local sec2score = arenaData["sec2region" .. indexId .. "score"] or 0

    local scoreStr = sec1score .. "分"
    sscore1:setString(scoreStr)
    local scoreStr = sec2score .. "分"
    sscore2:setString(scoreStr)

    sname1:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    sname2:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    sscore1:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    sscore2:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)


    sscore1:setPositionX(sname1:getPositionX()+sname1:getContentSize().width+10)
    sscore2:setPositionX(sname2:getPositionX()-sname2:getContentSize().width-10)

    local sProgressBg1 = self:getUI("bg.serverLayer1.sProgressBg" .. indexId)
    local sProgressBg2 = self:getUI("bg.serverLayer2.sProgressBg" .. indexId)
    local sProgress1 = self:getUI("bg.serverLayer1.sProgress" .. indexId)
    local sProgress2 = self:getUI("bg.serverLayer2.sProgress" .. indexId)

    -- local arena = self:getUI("bg.arena" .. indexId)
    -- UIUtils:adjustTitle(arena)

    local setStr1 = arenaData["sec1"]
    local setStr2 = arenaData["sec2"]
    local sec = arenaData[setStr] 
    local sNameStr1 = self._crossModel:getServerName(setStr1)
    local sNameStr2 = self._crossModel:getServerName(setStr2)

    local secAllScore = sec1score+sec2score
    local percentStr1, percentStr2 = 0, 0
    if secAllScore == 0 then
        percentStr1 = 0.05
        percentStr2 = 0.05
    else
        percentStr1 = sec1score/secAllScore
        percentStr2 = sec2score/secAllScore
    end
    print("666===============", indexId, secAllScore, sec1score, sec2score)
    print("666=======", percentStr1, percentStr2)

    if percentStr1 <= 0 then
        percentStr1 = 0.05
    end
    if percentStr1 > 1 then
        percentStr1 = 0.95
    end
    if percentStr2 <= 0 then
        percentStr2 = 0.05
    end
    if percentStr2 > 1 then
        percentStr2 = 0.95
    end

    sProgress1:setScaleX(percentStr1)
    sProgress2:setScaleX(percentStr2)
    -- sProgressBg1:setScaleX(percentStr1)
    -- sProgressBg2:setScaleX(percentStr2)
    sProgressBg1:setVisible(false)
    sProgressBg2:setVisible(false)
end

function CrossDetailDialog:refreshUI()
    local arenaData = self._crossModel:getData()
    dump(arenaData)
    local setStr1 = arenaData["sec1"]
    local setStr2 = arenaData["sec2"]
    local sec = arenaData[setStr] 
    local sNameStr1 = self._crossModel:getServerName(setStr1)
    local sNameStr2 = self._crossModel:getServerName(setStr2)

    local bProgress = self:getUI("bg.barpanel.expBg.sProgress1")
    -- local sProgress2 = self:getUI("bg.barpanel.expBg.sProgress2")
    local sname1 = self:getUI("bg.barpanel.sname1")
    local sname2 = self:getUI("bg.barpanel.sname2")
    local sscore1 = self:getUI("bg.barpanel.sscore1")
    local sscore2 = self:getUI("bg.barpanel.sscore2")
    sname1:setString(sNameStr1)
    sname2:setString(sNameStr2)


    local sec1score = arenaData["sec1score"] or 0
    local sec2score = arenaData["sec2score"] or 0
    local scoreStr = "(" .. sec1score .. "分)"
    sscore1:setString(scoreStr)
    local scoreStr = "(" .. sec2score .. "分)"
    sscore2:setString(scoreStr)

    sscore1:setPositionX(sname1:getPositionX()+sname1:getContentSize().width)
    sscore2:setPositionX(sname2:getPositionX()-sname2:getContentSize().width)

    if sec1score == 0 then
        sec1score = 1
    end
    if sec2score == 0 then
        sec2score = 1
    end
    local percentStr = sec1score/(sec1score+sec2score)
    if percentStr < 0 then
        percentStr = 0
    end
    if percentStr > 1 then
        percentStr = 1
    end
    bProgress:setScaleX(percentStr)

end


-- function CrossDetailDialog:updateArenaScore(indexId)
--     local arenaData = self._crossModel:getData()

--     local titleLab = self:getUI("bg.arena" .. indexId .. ".titleLab")
--     local regiontype = arenaData["regiontype" .. indexId]
--     titleLab:setString(lang("cp_nameRegion" .. regiontype))
--     local arena = self:getUI("bg.arena" .. indexId)
--     UIUtils:adjustTitle(arena)

--     local setStr1 = arenaData["sec1"]
--     local setStr2 = arenaData["sec2"]
--     local sec = arenaData[setStr] 
--     local sNameStr1 = self._crossModel:getServerName(setStr1)
--     local sNameStr2 = self._crossModel:getServerName(setStr2)

--     local sProgress1 = self:getUI("bg.arena" .. indexId .. ".sProgress1")
--     local sProgress2 = self:getUI("bg.arena" .. indexId .. ".sProgress2")
--     local sname1 = self:getUI("bg.arena" .. indexId .. ".sname1")
--     local sname2 = self:getUI("bg.arena" .. indexId .. ".sname2")
--     local sscore1 = self:getUI("bg.arena" .. indexId .. ".sscore1")
--     local sscore2 = self:getUI("bg.arena" .. indexId .. ".sscore2")
--     sname1:setString(sNameStr1)
--     sname2:setString(sNameStr2)

--     local sec1score = arenaData["sec1region" .. indexId .. "score"] or 0
--     local sec2score = arenaData["sec2region" .. indexId .. "score"] or 0

--     local scoreStr = sec1score .. "分"
--     sscore1:setString(scoreStr)
--     local scoreStr = sec2score .. "分"
--     sscore2:setString(scoreStr)

--     -- sscore1:setPositionX(sname1:getPositionX()+sname1:getContentSize().width)
--     -- sscore2:setPositionX(sname2:getPositionX()-sname2:getContentSize().width)

--     if sec1score == 0 then
--         sec1score = 1
--     end
--     if sec2score == 0 then
--         sec2score = 1
--     end
--     local percentStr = sec1score/(sec1score+sec2score)
--     if percentStr < 0 then
--         percentStr = 0
--     end
--     if percentStr > 1 then
--         percentStr = 1
--     end
--     sProgress1:setScaleX(percentStr)
-- end
return CrossDetailDialog