--[[
    Filename:    IntanceChooseBranchView.lua
    Author:      <weiwei02@playcrab.com>
    Datetime:    2017-01-13 11:50:27
    Description: File description
--]]


local IntanceChooseBranchView = class("IntanceChooseBranchView", BasePopView)


function IntanceChooseBranchView:ctor()
    IntanceChooseBranchView.super.ctor(self)
    self:registerScriptHandler(function(eventType)
        if eventType == "exit" then 
            UIUtils:reloadLuaFile("intance.IntanceChooseBranchView")
        elseif eventType == "enter" then 

        end
    end)    
end


function IntanceChooseBranchView:reflashUI(inData)
    self:registerClickEventByName("bg.closeBtn", function()
        self:close()
    end)

    self._curSelected = 0
    audioMgr:playSound("branchCampaign")
    local branchId= inData.branchId
    self._curBranchId = inData.branchId
    self._callback = inData.callback
    local sysBranchStage = tab:BranchStage(branchId)




    local titleLab = self:getUI("bg.titleBg.title")
    UIUtils:setTitleFormat(titleLab, 1)

    local titleLab1 = self:getUI("bg.infoBg.titleLab")
    titleLab1:setString(lang(sysBranchStage.title))
    UIUtils:adjustTitle(self:getUI("bg.infoBg"))

    local tipLab = self:getUI("bg.tipLab")
    tipLab:setColor(UIUtils.colorTable.ccUIBaseTextColor1)

    local infoBg = self:getUI("bg.infoBg")
    local teamPic = cc.Sprite:create("asset/uiother/intance/" .. sysBranchStage.tipPic .. '.png')
    teamPic:setAnchorPoint(0.5, 0)
    teamPic:setScale(sysBranchStage.zoom / 100)
    teamPic:setPosition(cc.p(infoBg:getContentSize().width * 0.5 - 20, 20))
    infoBg:addChild(teamPic)


    local strDes = lang(sysBranchStage.des)

    local descBg = self:getUI("bg.descBg")
    local rtx = RichTextFactory:create(strDes, descBg:getContentSize().width, descBg:getContentSize().height)
    rtx:formatText()
    rtx:setVerticalSpace(3)
    rtx:setAnchorPoint(cc.p(0,0.5))
    rtx:setPosition(-rtx:getInnerSize().width/2,descBg:getContentSize().height/2)
    descBg:addChild(rtx)

    local bg = self:getUI("bg")

    local rewardBg = self:getUI("bg.rewardBg")
    local selectImg = self:getUI("bg.rewardBg.selectImg")
    selectImg:setVisible(false)
    local iconId = 0
    local x = 55
    for k,v in pairs(sysBranchStage.reward) do
        if v[1] == "tool" then
            iconId = v[2]
        else
            iconId = IconUtils.iconIdMap[sysStage["firstReward"][1]]
        end
        local selectX = x
        local rewardIcon = IconUtils:createItemIconById({itemId = iconId,itemData = tab:Tool(iconId), num = v[3], showTip = true, eventStyle = 3,clickCallback = function()
            self._curSelected = k 
            selectImg:setVisible(true)
            selectImg:setPosition(selectX , rewardBg:getContentSize().height * 0.5 - 1)
        end})
        rewardIcon:setScale(0.8)
        rewardIcon:setAnchorPoint(cc.p(0.5, 0.5))
        rewardIcon:setPosition(x, rewardBg:getContentSize().height * 0.5)
        rewardBg:addChild(rewardIcon)
        rewardIcon:setScaleAnim(false)
        x = x + (rewardIcon:getContentSize().width * rewardBg:getScale()) + 10
    end

    local cancelBtn = self:getUI("bg.cancelBtn")
    if cancelBtn ~= nil then 
        cancelBtn:enableOutline(UIUtils.colorTable.ccUICommonBtnOutLine2, 1)
        self:registerClickEvent(cancelBtn, function ()
            self:close()
        end)
    end

    local enterBtn = self:getUI("bg.enterBtn")
    if enterBtn ~= nil then 
        enterBtn:enableOutline(cc.c4b(125, 64, 0, 255), 1)        
        self:registerClickEvent(enterBtn, function ()
            if self._curSelected == 0 then self._viewMgr:showTip("请选择一项奖励") return end
            if self._callback ~= nil  then 
                self._callback(branchId, 2, self._curSelected)
            end
            self:close()
        end)
    end
  
end



return IntanceChooseBranchView