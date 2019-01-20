--[[
    @FileName   WorldBossInfoView.lua
    @Authors    zhangtao
    @Date       2018-10-16 15:12:10
    @Email      <zhangtao@playcrad.com>
    @Description   描述
--]]
local WorldBossInfoView = class("WorldBossInfoView", BasePopView)
local skillTypeTab = {"skill","skillPassive","skillCharacter"}
function WorldBossInfoView:ctor(params)
    WorldBossInfoView.super.ctor(self)
    self._bossId =  params.bossId
    self._tableData = tab:WorldBossMain(self._bossId)
    self._teamModel = self._modelMgr:getModel("TeamModel")
    self._skillNodeTab = {}
end

function WorldBossInfoView:onInit()
    self._skillArr = {}
    self._desScroll = self:getUI("bg.image_dragon_bg.desScroll")
    local title = self:getUI("bg.dragon_title_bg.dragonTitle")
    UIUtils:setTitleFormat(title, 6)
    self._scrollview = self:getUI("bg.scrollview")
    for i = 1, #self._scrollview:getChildren() do
        self._scrollview:getChildren()[i].oriHeight = self._scrollview:getChildren()[i]:getPositionY()
    end
    self._bossInfo = {}
    -- self._bossInfo._recommendTeam = {}
    -- local skillCount = #self._tableData["skillID"] or 0
    -- local teamNode = self:getUI("bg.scrollview.team_1")
    -- local skillNode = self:getUI("bg.scrollview.skill_1")
    -- for i = 1, skillCount do
    --     self._bossInfo._recommendTeam[i] = clone(teamNode)
    -- end

    -- self._bossInfo._skillDescription = {}
    -- for i = 1, skillCount do
    --     self._bossInfo._skillDescription[i] = clone(skillNode)
    -- end
    self:InitBossDesc()
    self:InitSkillInfo()
    self:registerClickEventByName("bg.btn_close", function()
        self:close()
        UIUtils:reloadLuaFile("worldboss.WorldBossInfoView")
    end)
end

function WorldBossInfoView:InitBossDesc()
    local desc = lang("worldBoss_Info")
    if not string.find(desc, "color") then
        desc = "[color=3d1f00]" .. desc .. "[-]"
    end
    local scrollW = self._desScroll:getContentSize().width
    local scrollH = self._desScroll:getContentSize().height
    local richText = self._desScroll:getChildByName("descRichText")
    if richText then
        richText:removeFromParentAndCleanup()
    end
    richText = RichTextFactory:create(desc, scrollW, scrollH)
    
    richText:formatText()
    richText:enablePrinter(true)
    local richRealHeight = richText:getRealSize().height
    richText:setPosition(scrollW / 2, richRealHeight / 2)
    richText:setName("descRichText")
    self._desScroll:addChild(richText)
    -- UIUtils:alignRichText(richText,{hAlign = "left"})
    
    self._desScroll:setTouchEnabled(richRealHeight > scrollH)
    local innerHeight = math.max(scrollH,richRealHeight)
    self._desScroll:setInnerContainerSize(cc.size(scrollW,innerHeight))
    ScheduleMgr:nextFrameCall(self,function ()
        self._desScroll:getInnerContainer():setPositionY(scrollH - richRealHeight)
    end)
    
end

function WorldBossInfoView:InitSkillInfo()  
    --添加技能介绍
    for k,v in pairs(self._skillArr) do
        if v then 
            v:removeFromParent()
            v = nil
        end
    end
    self._skillArr = {}
    local height = 120
    local oriH = 0
    local panelH = 85
    local skillCount = #self._tableData["skillID"]
    local innerContentHeight = 0
    -- 

    for i = 1, #self._tableData["skillID"] do
        local skillName,skillId = skillTypeTab[self._tableData["skillID"][i][1]],self._tableData["skillID"][i][2]
        local skillPanel,realHeight = self:createDragonSkill(skillName,skillId,panelH)
        innerContentHeight = innerContentHeight + realHeight
    end
    self._scrollview:setInnerContainerSize(cc.size(450, innerContentHeight))


    local totalHeight = 0
    for i = 1, #self._tableData["skillID"] do
        local skillName,skillId = skillTypeTab[self._tableData["skillID"][i][1]],self._tableData["skillID"][i][2]
        local skillNode = self._skillNodeTab[skillId]["node"]
        local nodeHeight = self._skillNodeTab[skillId]["realHeight"]
        totalHeight = nodeHeight + totalHeight 
        self._scrollview:addChild(skillNode)
        skillNode:setPositionY(innerContentHeight - totalHeight)
    end

    -- local labelDiscription = self._bossInfo._skillDescription[1]
    -- local desc = lang("RULE_DRAGON_"..2)
    -- if not string.find(desc, "color") then
    --     desc = "[color=3d1f00]" .. desc .. "[-]"
    -- end
    -- local richText = labelDiscription:getChildByName("descRichText")
    -- if richText then
    --     richText:removeFromParentAndCleanup()
    -- end
    -- richText = RichTextFactory:create(desc, labelDiscription:getContentSize().width, labelDiscription:getContentSize().height)
    -- richText:formatText()
    -- richText:enablePrinter(true)
    -- richText:setPosition(labelDiscription:getContentSize().width / 2, labelDiscription:getContentSize().height - 5 - richText:getInnerSize().height / 2)
    -- richText:setName("descRichText")
    -- labelDiscription:addChild(richText)
    -- labelDiscription.oriHeight = oriH - #self._tableData["skill"]*panelH - labelDiscription:getContentSize().height
    
    -- height = height + richText:getInnerSize().height + 5

   
    -- for i = 1, #self._scrollview:getChildren() do
    --     self._scrollview:getChildren()[i]:setPositionY(self._scrollview:getChildren()[i].oriHeight - (670 - height))
    -- end
    -- self._scrollview:scrollToTop(0.01, false)
    self._scrollview:scrollToPercentVertical(0.1, 0, false)
end

function WorldBossInfoView:createDragonSkill(skillName,skillId,height)
    local bgNode = ccui.Layout:create()
    bgNode:setBackGroundColorOpacity(0)
    bgNode:setAnchorPoint(0,0)
    bgNode:setBackGroundColorType(1)
    bgNode:setBackGroundColor(cc.c3b(0,0,0))
       
    local realSkillTable = tab[skillName]
    local art = realSkillTable[skillId]["art"]
    local nameStr = realSkillTable[skillId]["name"]
    local desStr = realSkillTable[skillId]["des"]
    print("==========art========"..art)
    print("==========skillId========"..skillId)
    --temp
    -- local nameStr = "SKILL_6900225"
    -- local desStr = "SKILL_6890019"

    local skillIcon = IconUtils:createPveBossSkillIconById(
       {bossSkill = {id = tostring(skillId), 
                     art = art,
                     name = nameStr,
                     des = desStr
                     },
                      eventStyle = 1
       })

    skillIcon:setScale(80 / skillIcon:getContentSize().width)
    skillIcon:setAnchorPoint(0,1)
    
    bgNode:addChild(skillIcon)

    local name = ccui.Text:create()
    name:setFontSize(22)
    name:setName("name")
    name:setFontName(UIUtils.ttfName)
    name:setColor(cc.c4b(134,92,48,255))   --UIUtils.colorTable.ccUIBaseTextColor2)
    name:setString(lang(nameStr))
    name:setAnchorPoint(0,1)

    bgNode:addChild(name,10)


    local rtx = RichTextFactory:create(lang(desStr),310,65)
    rtx:setName("des")
    rtx:formatText()
    -- rtx:setAnchorPoint(0,0.5)
    
    bgNode:addChild(rtx,10)

    table.insert(self._skillArr, bgNode)
    local realHeight = 0
    local nameH = name:getContentSize().height
    local rtxW,rtxH = rtx:getRealSize().width,rtx:getRealSize().height
    

    -- print("=====name.height======",nameH)
    -- print("=====rtx.height======",rtx:getRealSize().height)
    local distance = 10
    realHeight = math.max(height,(nameH + rtxH + distance))

    bgNode:setContentSize(418, realHeight-1) 
    rtx:setPosition(100 + rtxW/2, rtxH/2 + distance -2)
    skillIcon:setPosition(10, realHeight-2)
    name:setPosition(100, realHeight-2)

    -- 
    self._skillNodeTab[skillId] = {}
    self._skillNodeTab[skillId].node = bgNode
    self._skillNodeTab[skillId].realHeight = realHeight
    return bgNode ,realHeight
end

return WorldBossInfoView