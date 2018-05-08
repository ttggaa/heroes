--[[
    Filename:    IntanceHeroAttrBranchView.lua
    Author:      <weiwei02@playcrab.com>
    Datetime:    2017-01-16 17:43:39
    Description: File description
--]]


local IntanceHeroAttrBranchView = class("IntanceHeroAttrBranchView", BasePopView)


function IntanceHeroAttrBranchView:ctor()
    IntanceHeroAttrBranchView.super.ctor(self)
    self:registerScriptHandler(function(eventType)
        if eventType == "exit" then 
            UIUtils:reloadLuaFile("intance.IntanceHeroAttrBranchView")
        elseif eventType == "enter" then 

        end
    end)      
end


function IntanceHeroAttrBranchView:reflashUI(inData)
    self:registerClickEventByName("bg.closeBtn", function()
        self:close()
    end)

    self._curSelected = 0
    audioMgr:playSound("branchCampaign")
    local branchId= inData.branchId
    local stageId = inData.stageId
    self._curBranchId = inData.branchId
    self._callback = inData.callback
    local sysBranchStage = tab:BranchStage(branchId)

    local titleLab = self:getUI("bg.titleBg.title")
    UIUtils:setTitleFormat(titleLab, 1)

    local titleLab1 = self:getUI("bg.infoBg.titleLab")
    titleLab1:setString(lang(sysBranchStage.title))
    UIUtils:adjustTitle(self:getUI("bg.infoBg"))


    local infoBg = self:getUI("bg.infoBg")
    local teamPic = cc.Sprite:create("asset/uiother/intance/" .. sysBranchStage.tipPic .. '.png')
    teamPic:setAnchorPoint(0.5, 0)
    teamPic:setScale(sysBranchStage.zoom / 100)
    teamPic:setPosition(cc.p(infoBg:getContentSize().width * 0.5 - 20, 20))
    infoBg:addChild(teamPic)

    local intanceModel = self._modelMgr:getModel("IntanceModel")
    local branchInfo = intanceModel:getStageInfo(stageId).branchInfo


    local branchLevel = 0
    if branchInfo[tostring(branchId)] ~= nil then 
        branchLevel = tonumber(branchInfo[tostring(branchId)])
    end

    if branchLevel > 0 then 
        local attrLevel = self:getUI("bg.attrLevel")
        local amin3 = mcMgr:createViewMC("level" .. branchLevel .. "_branch_heroattr", false, false, nil, nil, false)
        amin3:setPosition(attrLevel:getContentSize().width * 0.5 + 35, attrLevel:getContentSize().height * 0.5 - 20)
        attrLevel:addChild(amin3)
        if IntanceConst.IS_OPEN_BRANCH_HERO_ATTR_ANIM == false then 
            amin3:gotoAndStop(35)
        end
        IntanceConst.IS_OPEN_BRANCH_HERO_ATTR_ANIM = false
    end



    local strDes = lang(sysBranchStage.des)
    -- 支线完成时展示另外的描述
    if branchLevel >= 4 then 
        strDes = lang(sysBranchStage.des2)
    end

    local descBg = self:getUI("bg.descBg")
    local rtx = RichTextFactory:create(strDes, descBg:getContentSize().width, descBg:getContentSize().height)
    rtx:formatText()
    rtx:setVerticalSpace(3)
    rtx:setAnchorPoint(cc.p(0,0.5))
    rtx:setPosition(-rtx:getInnerSize().width/2,descBg:getContentSize().height/2)
    descBg:addChild(rtx)
    local heroAttrPics = {[112] = "hero_tip_1.png", [115] = "hero_tip_2.png", [118] = "hero_tip_4.png", [121] = "hero_tip_3.png" }
    local sysBranchHeroAdd = tab:BranchHeroAdd(branchId)
    for i=1,4 do
        local attrBg = self:getUI("bg.attrBg.attr" .. i)
        local imgGet = attrBg:getChildByName("imgGet")
        if i > branchLevel  then
            imgGet:setVisible(false)
        else
            imgGet:setVisible(true)
        end
        local reward = sysBranchHeroAdd["reward" .. i]
        if reward then 
            attrBg:setVisible(true) 
            local labTip = attrBg:getChildByName("iconAttr")
            labTip:loadTexture(heroAttrPics[reward[1][1]], 1)

            local labTip = attrBg:getChildByName("labTip")
            labTip:setString(lang("ARTIFACTDES_PRO_" .. reward[1][1]))
            labTip:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
            
            local labTip1 = attrBg:getChildByName("Label_19")
            labTip1:setColor(UIUtils.colorTable.ccUIBaseTextColor1)

            local labAttrNum = attrBg:getChildByName("labAttrNum")
            labAttrNum:setColor(UIUtils.colorTable.ccUIBaseColor2)
            labAttrNum:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
            labAttrNum:setString("+" .. reward[1][2])
        else
            attrBg:setVisible(false) 
        end
    end

    local attrLevelImg = self:getUI("bg.attrLevel")
    if branchLevel <= 0 then 
        attrLevelImg:setVisible(false)
    else
        attrLevelImg:setVisible(true)
    end

    local cancelBtn = self:getUI("bg.cancelBtn")
    cancelBtn:enableOutline(UIUtils.colorTable.ccUICommonBtnOutLine2, 1) 
    self:registerClickEvent(cancelBtn, function ()
        self:close()
    end)
     
    local enterBtn = self:getUI("bg.enterBtn")
    enterBtn:enableOutline(cc.c4b(124, 64, 0, 255), 1)        
    if branchLevel < 4 then 
        self:registerClickEvent(enterBtn, function ()
            if self._callback ~= nil  then 
                self._callback(branchId, 2, self._curSelected)
            end
            self:close()
        end)
    else
        cancelBtn:setPosition(cancelBtn:getPositionX() - cancelBtn:getContentSize().width * 0.5, cancelBtn:getPositionY())
        enterBtn:setVisible(false)
    end
    
end



return IntanceHeroAttrBranchView