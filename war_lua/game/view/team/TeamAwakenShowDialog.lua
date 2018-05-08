--[[
    Filename:    TeamAwakenShowDialog.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2017-08-21 19:48:37
    Description: File description
--]]

-- 觉醒
local TeamAwakenShowDialog = class("TeamAwakenShowDialog", BasePopView)
local TeamUtils = TeamUtils

function TeamAwakenShowDialog:ctor(params)
    TeamAwakenShowDialog.super.ctor(self)
    if not params then
        params = {}
    end
    self._selectTeamId = params.teamId or 106
    self._showType = params.showtype or 1
end


function TeamAwakenShowDialog:onInit()
    self:registerClickEventByName("closeBtn", function ()
        if OS_IS_WINDOWS then
            UIUtils:reloadLuaFile("team.TeamAwakenShowDialog")
        end
        self:close()
    end)
    self._teamModel = self._modelMgr:getModel("TeamModel")

    self._selectSkill = 0

    local raceImg = self:getUI("bg.raceImg")
    local systeam = tab.team[self._selectTeamId]
    local race = tab:Race(systeam["race"][1])
    self._raceImg = race
    raceImg:loadTexture("asset/uiother/race/awake_race_" .. race.pic .. ".jpg", 0)
    local fScale = MAX_SCREEN_WIDTH/1022
    raceImg:setScale(fScale)

    local bg = self:getUI("bg")
    if race.pic == 3 then
        local muyuanyanwu = mcMgr:createViewMC("muyuanyanwu_tianfushu", true, false)
        muyuanyanwu:setName("muyuanyanwu")
        muyuanyanwu:setPosition(bg:getContentSize().width*0.5, bg:getContentSize().height*0.5)
        muyuanyanwu:setScale(1.1)
        bg:addChild(muyuanyanwu,1)  
    end

    local awakingBtn = self:getUI("bg.leftLayer.awakingBtn")
    if self._showType == 2 then
        awakingBtn:setVisible(false)
    end

    local awakingOpen = tab:Setting("AWAKINGOPEN").value
    self._curSelectTeam = self._teamModel:getTeamAndIndexById(self._selectTeamId)
    self:registerClickEvent(awakingBtn, function()
        -- local param = {teamId = self._selectTeamId, old = self._curSelectTeam, new = self._curSelectTeam}
        -- self._viewMgr:showDialog("team.TeamAwakenSuccessDialog", param)
        dump(self._curSelectTeam)
        print(self._curSelectTeam.stage, awakingOpen)
        if self._curSelectTeam.stage < awakingOpen then
            self._viewMgr:showTip(lang("AWAKING_TIPS"))
            return
        end
        local teamId = self._modelMgr:getModel("AwakingModel"):getCurrentAwakingTeamId()
        if teamId ~= 0 then
            local str = lang("AWAKING_TIPS_1")
            self._viewMgr:showTip(str)
            return
        end
        -- print("========开始觉醒")
        -- local callback = function()
        --     ViewManager:getInstance():switchView("task.TaskView",{viewType = 1000})
        -- end
        -- local param = {teamId = self._selectTeamId, callback = callback}
        -- self._viewMgr:showDialog("team.TeamAwakenOpenTaskDialog", param)

        self:openAwakingTask()
    end)

    local starTip = self:getUI("bg.starTip")
    starTip:setVisible(false)
    local closeTip = self:getUI("bg.starTip.closeTip")
    self:registerClickEvent(closeTip, function()
        local starTip = self:getUI("bg.starTip")
        starTip:setVisible(false)
    end)


end

-- 开启觉醒任务
function TeamAwakenShowDialog:openAwakingTask()
    local param = {teamId = self._selectTeamId}
    self._serverMgr:sendMsg("AwakingServer", "openAwakingTask", param, true, {}, function (result)
        -- dump(result, "result ===", 10)
        local callback = function()
            ViewManager:getInstance():switchView("task.TaskView",{viewType = 1000})
            -- self:close()
        end
        local param = {teamId = self._selectTeamId, callback = callback}
        self._viewMgr:showDialog("team.TeamAwakenOpenTaskDialog", param)
    end)
end

-- -- awakingActivate 觉醒
-- function TeamAwakenShowDialog:awakingActivate()
--     self._serverMgr:sendMsg("AwakingServer", "awakingActivate", {}, true, {}, function (result)
--         dump(result, "result ===", 10)
--         local param = {teamId = self._curSelectTeam.teamId}
--         self._viewMgr:showDialog("team.TeamAwakenOpenTaskDialog", param)
--     end)
-- end

function TeamAwakenShowDialog:selectClick(flag)
    local tree, class = self:getTreeAndClass()
    if tree == 0 then
        local skillbg = self:getUI("bg.leftLayer.starIcon")
        local selectSkill = skillbg:getChildByFullName("selectSkill")
        if not selectSkill then
            selectSkill = mcMgr:createViewMC("xuanzhong_itemeffectcollection", true, false)
            selectSkill:setName("selectSkill")
            selectSkill:gotoAndStop(1)
            selectSkill:setPosition(skillbg:getContentSize().width*0.5, skillbg:getContentSize().height*0.5)
            selectSkill:setScale(0.7)
            selectSkill:setVisible(false)
            skillbg:addChild(selectSkill,2)       
        end
        selectSkill:setVisible(flag)
    else
        if class == 1 then
            local skillbg = self:getUI("bg.leftLayer.skillcircle" .. tree .. class)
            local selectSkill = skillbg:getChildByFullName("selectSkill")
            if not selectSkill then
                selectSkill = mcMgr:createViewMC("xuanzhong_tianfushu", true, false)
                selectSkill:setName("selectSkill")
                selectSkill:setPosition(skillbg:getContentSize().width*0.5, skillbg:getContentSize().height*0.5)
                selectSkill:setScale(1.1)
                skillbg:addChild(selectSkill,1)       
            end
            selectSkill:setVisible(flag)
        else
            local skillbg = self:getUI("bg.leftLayer.skillcircle" .. tree .. class)
            local selectSkill = skillbg:getChildByFullName("selectSkill")
            if not selectSkill then
                selectSkill = mcMgr:createViewMC("xuanzhong1_tianfushu", true, false)
                selectSkill:setName("selectSkill")
                selectSkill:setPosition(skillbg:getContentSize().width*0.5, skillbg:getContentSize().height*0.5)
                selectSkill:setScale(1.1)
                skillbg:addChild(selectSkill,1)       
            end
            selectSkill:setVisible(flag)
        end
    end
end

function TeamAwakenShowDialog:reflashUI(data)
    -- local selectTeamData = self._teamModel:getTeamAndIndexById(self._selectTeamId)
    -- dump(selectTeamData, "selectTeamData")
    self:updateLeftData()
end

function TeamAwakenShowDialog:getTreeAndClass(selectSkill)
    local selectSkill = selectSkill or self._selectSkill
    local tree = math.floor(selectSkill/10)
    local class = math.fmod(selectSkill, 10)
    return tree, class
end

function TeamAwakenShowDialog:updateLeftData()
    local teamId = self._selectTeamId
    local teamTab = tab.team[teamId]
    local tskill = teamTab.skill 
    local awakingColor = TeamUtils.awakingRaceLineColor[self._raceImg.pic]
    local awakingLimit = tab:Setting("AWAKINGLIMIT").value
    for tree=1,3 do
        local talentTree = teamTab["talentTree" .. tree]
        local _tskill = tskill[talentTree[1]]
        for class=1,2 do
            local indexId = class + 1
            local skillbg = self:getUI("bg.leftLayer.skillcircle" .. tree .. class)
            local skillType = talentTree[indexId][1]
            local skillId = talentTree[indexId][2]
            if skillType == nil or skillId == nil then
                self._viewMgr:showTip("技能数据错误，请联系管理员")
                skillType = 1
                skillId = 59055
            end
            -- 技能图标
            local sysSkill = SkillUtils:getTeamSkillByType(skillId, skillType)
            local param = {teamSkill = sysSkill, styleType = 2, teamTree = class}
            -- local skillIcon = skillbg:getChildByName("skillIcon" .. tree .. class)
            local skillIcon = skillbg:getChildByName("skillIcon")
            if not skillIcon then
                skillIcon = self:createSkillIcon(param)
                skillIcon:setName("skillIcon")
                skillIcon:setAnchorPoint(0.5, 0.5)
                skillIcon:setScale(1.1)
                skillIcon:setPosition(skillbg:getContentSize().width*0.5, skillbg:getContentSize().height*0.5)
                skillbg:addChild(skillIcon, 5)
            else
                self:updateTeamSkillIconByView(skillIcon, param)
            end

            -- 连接线
            local liudongxian = skillbg:getChildByFullName("liudongxian")
            if not liudongxian then
                liudongxian = mcMgr:createViewMC("liudongxian_tianfushu", true, false)
                liudongxian:setHue(awakingColor.hue)
                liudongxian:setSaturation(awakingColor.saturation)
                liudongxian:setBrightness(awakingColor.brightness)
                liudongxian:setContrast(awakingColor.contrast)
                liudongxian:setName("liudongxian")
                liudongxian:setPosition(skillbg:getContentSize().width*0.5+90, skillbg:getContentSize().height*0.5+70)
                skillbg:addChild(liudongxian,1)       
                if class == 2 then
                    liudongxian:setScaleX(-1)
                    liudongxian:setRotation(8)
                    if tree == 1 then
                        liudongxian:setPosition(skillbg:getContentSize().width*0.5-90, skillbg:getContentSize().height*0.5+70)
                    elseif tree == 2 then
                        liudongxian:setPosition(skillbg:getContentSize().width*0.5-90, skillbg:getContentSize().height*0.5+50)
                    elseif tree == 3 then
                        liudongxian:setPosition(skillbg:getContentSize().width*0.5-90, skillbg:getContentSize().height*0.5+50)
                    end
                else
                    liudongxian:setRotation(-8)
                    if tree == 1 then
                        liudongxian:setPosition(skillbg:getContentSize().width*0.5+90, skillbg:getContentSize().height*0.5+70)
                    elseif tree == 2 then
                        liudongxian:setPosition(skillbg:getContentSize().width*0.5+90, skillbg:getContentSize().height*0.5+50)
                    elseif tree == 3 then
                        liudongxian:setPosition(skillbg:getContentSize().width*0.5+90, skillbg:getContentSize().height*0.5+50)
                    end
                end
            end

            self:registerClickEvent(skillIcon, function()
                -- local desEx = "[color=645252,fontsize=24]" .. lang(sysSkill.name) .. "[][-][-]"  
                -- desEx = desEx .. lang(sysSkill.des)
                -- print("====", desEx)
                local starTip = self:getUI("bg.starTip")
                starTip:setVisible(true)

                local sysSkill = SkillUtils:getTeamSkillByType(skillId, skillType)
                local desEx = lang(sysSkill.des)
                local nameEx = lang(sysSkill.name)
                desEx = string.gsub(desEx, "645252", "fcf4c5")
                local param = {teamSkill = sysSkill, styleType = 1, teamTree = class}
                self:updateShowTip(param, desEx, nameEx)

                -- self._viewMgr:showHintView("global.GlobalTipView",{
                --     node = skillIcon,
                --     tipType = 15,
                --     des = "[color=ffffff]" .. desEx .. "[-]",
                --     posCenter = true,
                -- })
            end)
        end

        local skillBtnLineBg = self:getUI("bg.leftLayer.skillBtnLineBg" .. tree)
        -- 上下连接线
        local skillBtnLine = skillBtnLineBg:getChildByFullName("skillBtnLine")
        if not skillBtnLine then
            skillBtnLine = mcMgr:createViewMC("liudongxian1_tianfushu", true, false)
            skillBtnLine:setName("skillBtnLine")
            skillBtnLine:setPosition(skillBtnLineBg:getContentSize().width*0.5, skillBtnLineBg:getContentSize().height*0.5)
            skillBtnLineBg:addChild(skillBtnLine,1)    
            skillBtnLine:setHue(awakingColor.hue)
            skillBtnLine:setSaturation(awakingColor.saturation)
            skillBtnLine:setBrightness(awakingColor.brightness)
            skillBtnLine:setContrast(awakingColor.contrast)   
        end
        
        -- if teamStage >= awakingLimit[tree] then
        --     skillBtnLine:setVisible(true)
        -- else
        --     skillBtnLine:setVisible(false)
        -- end

        local skillLimitLab = self:getUI("bg.leftLayer.skillBtn" .. tree .. ".lab")
        local str = lang("AWAKING_BUTTON_" .. tree)
        skillLimitLab:setString(str)
        skillLimitLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    end
end

function TeamAwakenShowDialog:updateShowTip(param, desEx, nameEx)
    local iconBg = self:getUI("bg.starTip.iconBg")
    local skillIcon = iconBg:getChildByName("skillIcon")
    if not skillIcon then
        skillIcon = self:createSkillIcon(param)
        skillIcon:setName("skillIcon")
        skillIcon:setAnchorPoint(0.5, 0.5)
        skillIcon:setScale(1.1)
        skillIcon:setPosition(iconBg:getContentSize().width*0.5, iconBg:getContentSize().height*0.5)
        iconBg:addChild(skillIcon, 5)
    else
        self:updateTeamSkillIconByView(skillIcon, param)
    end

    local name = self:getUI("bg.starTip.name")
    if name then
        name:setString(nameEx)
    end

    local desc = desEx
    local richtextBg = self:getUI("bg.starTip.richtextBg")
    local richText = richtextBg:getChildByName("descRichText")
    if richText then
        richText:removeFromParent()
    end
    richText = RichTextFactory:create(desc, richtextBg:getContentSize().width-30, richtextBg:getContentSize().height, false)
    richText:formatText()
    richText:enablePrinter(true)
    richText:setPosition((richText:getInnerSize().width+20)/2, richtextBg:getContentSize().height-richText:getInnerSize().height/2)
    richText:setName("descRichText")
    richtextBg:addChild(richText)
end

local SKILL_WIDTH, SKILL_HEIGHT = 80, 80
function TeamAwakenShowDialog:createSkillIcon(inTable)
    local cardbg = ccui.Layout:create()
    cardbg:setAnchorPoint(0.5, 0.5)
    cardbg:setBackGroundColorOpacity(0)
    cardbg:setBackGroundColorType(1)
    cardbg:setBackGroundColor(cc.c3b(255,255,255))
    cardbg:setContentSize(SKILL_WIDTH, SKILL_HEIGHT)
    cardbg:setName("cardbg")

    local centerx, centery = SKILL_WIDTH * 0.5, SKILL_HEIGHT * 0.5

    -- 遮罩
    -- 背景
    local mask = cc.Sprite:createWithSpriteFrameName("globalImage_IconMaskCircle.png")
    mask:setScale(0.8)
    mask:setPosition(centerx, centery)

    -- 裁剪框
    local cardClip = cc.ClippingNode:create()
    cardClip:setInverted(false)
    cardClip:setStencil(mask)
    cardClip:setAlphaThreshold(0.1)
    cardClip:setName("cardClip")
    cardClip:setAnchorPoint(cc.p(0.5,0.5))
    -- cardClip:setPosition(centerx*0.5, centery*0.5)
    cardbg:addChild(cardClip)

    local skillIcon = cc.Sprite:create()
    skillIcon:setPosition(centerx, centery)
    skillIcon:setName("skillIcon")
    cardClip:addChild(skillIcon)

    -- icon
    local iconFrame = cc.Sprite:createWithSpriteFrameName("globalImageUI_teamskillFrame1.png")
    iconFrame:setPosition(centerx, centery)
    iconFrame:setName("iconFrame")
    cardbg:addChild(iconFrame)

    self:updateTeamSkillIconByView(cardbg, inTable)
    return cardbg
end

function TeamAwakenShowDialog:updateTeamSkillIconByView(inView, inTable)
    if not inView then
        return
    end

    local sysSkill = inTable.teamSkill
    local skillIcon = inView:getChildByFullName("cardClip.skillIcon")
    if skillIcon then
        local fileName = sysSkill.art .. ".png"
        print("fileName=============", fileName)
        skillIcon:setSpriteFrame(fileName)
    end

    local teamTree = inTable.teamTree or 1
    local iconFrame = inView:getChildByFullName("iconFrame")
    if iconFrame then
        local fileName = "globalImageUI_teamskillFrame" .. teamTree .. ".png"
        iconFrame:setSpriteFrame(fileName)
    end

    local styleType = inTable.styleType
    if styleType == 2 then
        local skillName = inView:getChildByFullName("skillName")
        local sysSkillName = lang(sysSkill.name)
        if not skillName then
            skillName = cc.Label:createWithTTF(sysSkillName, UIUtils.ttfName, 14)
            skillName:setPosition(inView:getContentSize().width*0.5, 0)
            skillName:setColor(cc.c3b(252, 244, 197))
            skillName:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
            skillName:setName("skillName")
            inView:addChild(skillName, 5) -- 4
        else
            skillName:setString(sysSkillName)
        end
        local skillNameBg = inView:getChildByFullName("skillNameBg")
        if not skillNameBg then
            skillNameBg = cc.Sprite:createWithSpriteFrameName("TeamAwakenImageUI_img2.png")
            skillNameBg:setPosition(inView:getContentSize().width*0.5, 0)
            skillNameBg:setName("skillNameBg")
            inView:addChild(skillNameBg)
        end
    else
        local skillName = inView:getChildByFullName("skillName")
        if skillName then
            skillName:setVisible(false)
        end
        local skillNameBg = inView:getChildByFullName("skillNameBg")
        if skillNameBg then
            skillNameBg:setVisible(false)
        end
    end
end

-- function TeamAwakenShowDialog:getAsyncRes()
--     return {
--         {"asset/ui/team.plist", "asset/ui/team.png"},
--         {"asset/ui/team1.plist", "asset/ui/team1.png"},
--     }
-- end

return TeamAwakenShowDialog
