--[[
    Filename:    ShareArenaWinModule.lua
    Author:      <wangyan@playcrab.com>
    Datetime:    2017-04-21 17:16:52
    Description: File description
--]]

local ShareBaseView = require("game.view.share.ShareBaseView")

--[[
    竞技场胜利分享
    data
        left 
            头像 avartar
            最佳输出 team1
            最佳防御 team2
        right 
            头像 avartar
            最佳输出 team1
            最佳防御 team2
--]]

function ShareBaseView:updateModuleView(data)
    local shareLayer = self:getShareLayer()

    local centerX, centerY = shareLayer:getContentSize().width * 0.5, shareLayer:getContentSize().height * 0.5

    ---------------我方
    local dataL = data["left"]
    local avartarL = IconUtils:createHeadIconById({
        art = dataL["user"]["art"],
        avatar = dataL["user"]["avatar"], 
        avatarFrame = dataL["user"]["avatarFrame"],
        tp = 4, 
        eventStyle = 1})
    avartarL:setPosition(99, 493)
    avartarL:setScale(1.2)
    shareLayer:addChild(avartarL)

    -- local teamL1 = IconUtils:createSysTeamIconById({   --最佳输出
    --     sysTeamData = dataL["team1"].sysTeamData, 
    --     eventStyle = 0})
    local quality = ModelManager:getInstance():getModel("TeamModel"):getTeamQualityByStage(dataL["team1"].teamData.stage)
    local teamL1 = IconUtils:createTeamIconById({teamData = {id = dataL["team1"].teamData.teamId, star = dataL["team1"].teamData.star}, sysTeamData = dataL["team1"].sysTeamData, quality = quality[1], quaAddition = quality[2],  eventStyle = 0})
    
    teamL1:setPosition(173, 261)
    teamL1:setScale(0.9)
    shareLayer:addChild(teamL1)

    local des1 = ccui.Text:create()
    des1:setString("最佳输出")
    des1:setAnchorPoint(cc.p(0, 0.5))
    des1:setColor(UIUtils.colorTable.ccUIBaseColor1)
    des1:enable2Color(1, cc.c4b(204, 193, 133, 255))
    des1:setFontName(UIUtils.ttfName)
    des1:setFontSize(22)
    des1:setPosition(295, 305)
    shareLayer:addChild(des1)
    
    -- local teamL2 = IconUtils:createSysTeamIconById({   --最佳防御
    --     sysTeamData = dataL["team2"].sysTeamData, 
    --     eventStyle = 0})
    local quality = ModelManager:getInstance():getModel("TeamModel"):getTeamQualityByStage(dataL["team2"].teamData.stage)
    local teamL2 = IconUtils:createTeamIconById({teamData = {id = dataL["team2"].teamData.teamId, star = dataL["team2"].teamData.star}, sysTeamData = dataL["team2"].sysTeamData, quality = quality[1], quaAddition = quality[2],  eventStyle = 0})
    
    teamL2:setPosition(172, 150)
    teamL2:setScale(0.9)
    shareLayer:addChild(teamL2)

    local des2 = ccui.Text:create()
    des2:setString("最佳防御")
    des2:setAnchorPoint(cc.p(0, 0.5))
    des2:setColor(UIUtils.colorTable.ccUIBaseColor1)
    des2:enable2Color(1, cc.c4b(204, 193, 133, 255))
    des2:setFontName(UIUtils.ttfName)
    des2:setFontSize(22)
    des2:setPosition(295, 195)
    shareLayer:addChild(des2)

    local name1 = ccui.Text:create()             --玩家名
    local userName = ModelManager:getInstance():getModel("UserModel"):getData().name or ""
    name1:setFontName(UIUtils.ttfName)
    name1:setString(userName)
    name1:setAnchorPoint(cc.p(0.5, 0.5))
    name1:setColor(UIUtils.colorTable.ccUIBaseColor1)
    name1:enable2Color(1, cc.c4b(204, 193, 133, 255))
    name1:enableOutline(cc.c4b(0,0,0,255),1)
    name1:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 2)
    name1:setFontSize(26)
    name1:setPosition(345, 600)
    shareLayer:addChild(name1)
    
    ------------敌方
    local dataR = data["right"]
    local avartarR = IconUtils:createHeadIconById({
        art = dataR["user"]["art"],
        avatar = dataR["user"]["avatar"], 
        avatarFrame = dataR["user"]["avatarFrame"],
        tp = 4, 
        eventStyle = 1})
    avartarR:setPosition(928, 493)
    avartarR:setScale(1.2)
    shareLayer:addChild(avartarR)
    
    local quality = ModelManager:getInstance():getModel("TeamModel"):getTeamQualityByStage(dataR["team1"].teamData.stage)
    local teamR1 = IconUtils:createTeamIconById({teamData = {id = dataR["team1"].teamData.teamId, star = dataR["team1"].teamData.star}, sysTeamData = dataR["team1"].sysTeamData, quality = quality[1], quaAddition = quality[2],  eventStyle = 0})
            
    teamR1:setPosition(870, 261)
    teamR1:setScale(0.9)
    shareLayer:addChild(teamR1)

    local des3 = ccui.Text:create()
    des3:setString("最佳输出")
    des3:setAnchorPoint(cc.p(1, 0.5))
    des3:setColor(UIUtils.colorTable.ccUIBaseColor1)
    des3:enable2Color(1, cc.c4b(204, 193, 133, 255))
    des3:setFontName(UIUtils.ttfName)
    des3:setFontSize(22)
    des3:setPosition(847, 305)
    shareLayer:addChild(des3)
    
    local quality = ModelManager:getInstance():getModel("TeamModel"):getTeamQualityByStage(dataR["team2"].teamData.stage)
    local teamR2 = IconUtils:createTeamIconById({teamData = {id = dataR["team2"].teamData.teamId, star = dataR["team2"].teamData.star}, sysTeamData = dataR["team2"].sysTeamData, quality = quality[1], quaAddition = quality[2],  eventStyle = 0})
    
    teamR2:setPosition(871, 150)
    teamR2:setScale(0.9)
    shareLayer:addChild(teamR2)

    local des4 = ccui.Text:create()
    des4:setString("最佳防御")
    des4:setAnchorPoint(cc.p(1, 0.5))
    des4:setColor(UIUtils.colorTable.ccUIBaseColor1)
    des4:enable2Color(1, cc.c4b(204, 193, 133, 255))
    des4:setFontName(UIUtils.ttfName)
    des4:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 2)
    des4:setFontSize(22)
    des4:setPosition(847, 195)
    shareLayer:addChild(des4)

    local localData = ModelManager:getInstance():getModel("ArenaModel"):getCurEnemyInfo()
    local enemyNameStr 
    if localData.def and localData.def.battle and localData.def.battle.name then
        enemyNameStr = localData.def.battle.name
    end
    local lastReportBattleEnemyName = ModelManager:getInstance():getModel("ArenaModel"):getLastEnemyName()
    local enemyName = lastReportBattleEnemyName or enemyNameStr or ""
    local name2 = ccui.Text:create()             --玩家名
    name2:setFontName(UIUtils.ttfName)
    name2:setString(enemyName)
    name2:setAnchorPoint(cc.p(0.5, 0.5))
    name2:setColor(UIUtils.colorTable.ccUIBaseColor1)
    name2:enable2Color(1, cc.c4b(204, 193, 133, 255))
    name2:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 2)
    name2:setFontSize(26)
    name2:setPosition(790, 600)
    shareLayer:addChild(name2)
    ModelManager:getInstance():getModel("ArenaModel"):setLastEnemyName()
end

function ShareBaseView:getShareBgName()
    return "asset/bg/share/share_arena1.jpg"
end

function ShareBaseView:getInfoPosition()
    return 846, 510
end

function ShareBaseView:getShareId()
    return 11
end