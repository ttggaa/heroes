--
-- Author: <ligen@playcrab.com>
-- Date: 2017-10-17 13:36:54
--
local SiegeBranchView = class("SiegeBranchView", BasePopView)

require "game.view.siege.SiegeConst"

function SiegeBranchView:ctor()
    SiegeBranchView.super.ctor(self)
    self._usingIcon = {}
    self._freeingIcon = {}
    self:registerScriptHandler(function(eventType)
        if eventType == "exit" then 
            UIUtils:reloadLuaFile("siege.SiegeBranchView")
        elseif eventType == "enter" then 

        end
    end)
end

function SiegeBranchView:reflashUI(inData)

  audioMgr:playSound("branchCampaign")
  local branchId = inData.branchId
  self._curBranchId = inData.branchId
  self._callback = inData.callback
  local sysBranchStage = tab:SiegeBranchStage(branchId)

  for i=1,8 do
    local bg = self:getUI("bg" .. i)
    if bg ~= nil then
      bg:setVisible(false)
      local imageBg = bg:getChildByFullName("Image_9")
      if imageBg and ADOPT_IPHONEX then
        imageBg:setContentSize(MAX_SCREEN_WIDTH, imageBg:getContentSize().height)
        for k, v in pairs(imageBg:getChildren()) do
            v:setPositionX(v:getPositionX() + (MAX_SCREEN_WIDTH - 1136) * 0.5)
        end
      end
    end
  end

  local bg = self:getUI("bgSpecial")
  bg:setVisible(false)



    -- cancelBtn:setTitleColor(cc.c4b(255, 243, 223, 255))
    -- cancelBtn:getTitleRenderer():enable2Color(1, cc.c4b(255, 239, 133, 255))
    -- cancelBtn:getTitleRenderer():enableOutline(cc.c4b(125, 64, 0, 255), 2)
  local branchType = sysBranchStage.type 
  print("branchType=====", branchType, branchId)  
  if sysBranchStage.specialShow ~= nil then 
    self:onInitSpecial(sysBranchStage)
    return
  end
  if sysBranchStage.type == SiegeConst.STAGE_BRANCH_TYPE.REWARD_ITEM_TEAM then 
    branchType = SiegeConst.STAGE_BRANCH_TYPE.REWARD_TEAM
  end

  if sysBranchStage.type == SiegeConst.STAGE_BRANCH_TYPE.REWARD_ITEM_HERO or
    sysBranchStage.type == SiegeConst.STAGE_BRANCH_TYPE.TALK_REWARD then 
    branchType = SiegeConst.STAGE_BRANCH_TYPE.REWARD_HERO
  end
  print("branchType=====", branchType, branchId)
  local bg = self:getUI("bg" .. branchType)

--  local imageBg = bg:getChildByFullName("Image_9")
--  if imageBg then
--    imageBg:setContentSize(MAX_SCREEN_WIDTH, imageBg:getContentSize().height)
--  end

  local labTitle = bg:getChildByName("labTitle")
  labTitle:setFontName(UIUtils.ttfName)
  labTitle:setColor(cc.c3b(250,146,26))
  labTitle:setString(lang(sysBranchStage.title))
  labTitle:enableOutline(cc.c4b(60, 30, 10, 255), 1)
  -- callback 第二个参数是指是领取奖励，还是触发战斗
  local callbackFunction = nil
  if branchType == SiegeConst.STAGE_BRANCH_TYPE.WAR or 
        branchType == SiegeConst.STAGE_BRANCH_TYPE.REWARD_TEAM or 
        branchType == SiegeConst.STAGE_BRANCH_TYPE.COST_TEAM or
        branchType == SiegeConst.STAGE_BRANCH_TYPE.COST_ITEM_CHIP then
        local posInfo = tab.setting["FUBEN_ZHIXIAN_LIHUI"].value
        local teamPic = cc.Sprite:create("asset/uiother/team/" .. sysBranchStage.tipPic .. '.png') 
        local panelBg = bg:getChildByName("Panel_35")
        teamPic:setAnchorPoint(0, 0)
        teamPic:setPosition(posInfo[1] , posInfo[2])
        teamPic:setScale(posInfo[3])
        panelBg:addChild(teamPic)
        callbackFunction = function()
          if sysBranchStage.type == SiegeConst.STAGE_BRANCH_TYPE.WAR then
            self._callback(branchId, 1)
            return
          elseif branchType == SiegeConst.STAGE_BRANCH_TYPE.COST_TEAM or 
            branchType == SiegeConst.STAGE_BRANCH_TYPE.COST_ITEM_CHIP then
            local userModel = self._modelMgr:getModel("UserModel")
            if sysBranchStage.cost[1] == "gem" then 
                if userModel:getData().gem < tonumber(sysBranchStage.cost[3]) then 
                  self._viewMgr:showTip("钻石不足")
                  return
                end
            elseif sysBranchStage.cost[1] == "gold" then
                if userModel:getData().gold < tonumber(sysBranchStage.cost[3]) then 
                  -- self._viewMgr:showTip("金币不足")
                  DialogUtils.showLackRes({goalType = "gold"})
                  return
                end
            else
              return
            end
            self._callback(branchId, 2)
            return
          end
          self._callback(branchId, 2)
        end
    elseif branchType == SiegeConst.STAGE_BRANCH_TYPE.REWARD_ITEM or 
      branchType == SiegeConst.STAGE_BRANCH_TYPE.TIP or 
      branchType == SiegeConst.STAGE_BRANCH_TYPE.STAR then 
        local itemIcon = bg:getChildByName("itemIcon")
        itemIcon:loadTexture("asset/uiother/intance/" .. sysBranchStage.tipPic .. '.png')
        callbackFunction = function()
          self._callback(branchId, 2)
        end
        itemIcon:setScale((sysBranchStage.zoom or 100) /100)
    elseif branchType == SiegeConst.STAGE_BRANCH_TYPE.REWARD_HERO then 
        local heroIcon = bg:getChildByName("heroIcon")
        heroIcon:loadTexture('asset/uiother/hero/' .. sysBranchStage.tipPic .. '.png')
        heroIcon:setScale((sysBranchStage.zoom or 100) /100)

        callbackFunction = function()
            self._callback(branchId, 2)
        end
    end
  -- 战报回放特殊处理
  if branchType == SiegeConst.STAGE_BRANCH_TYPE.WAR then
      print("sysBranchStage.record=================", sysBranchStage.record)
      local recordBtn = self:getUI("bg" .. branchType ..".recordBtn")
      self._battleResult = {}
      self:registerClickEvent(recordBtn, function ()
        self:showReport(branchId, 2, function()
            self:showReport(branchId, 1, function()
                self._viewMgr:showDialog("intance.IntanceRecordView", {
                  branchId = branchId,
                  battleResult = self._battleResult
                  })
            end)
        end)      
      end)
      if sysBranchStage.record == 1 then 
        recordBtn:setVisible(true)
      else
        recordBtn:setVisible(false)
      end
  end
  -- 奖励内容特殊处理
  if branchType == SiegeConst.STAGE_BRANCH_TYPE.COST_TEAM or 
            branchType == SiegeConst.STAGE_BRANCH_TYPE.COST_ITEM_CHIP then
      local num1 = sysBranchStage.cost[3]
      local itemId1 = sysBranchStage.cost[2]
      if sysBranchStage.cost[1] == "gold" then
          itemId1 = IconUtils.iconIdMap.gold
      elseif sysBranchStage.cost[1] == "gem" then
          itemId1 = IconUtils.iconIdMap.gem 
      elseif sysBranchStage.cost[1] == "texp" then
          itemId1 = IconUtils.iconIdMap.texp 
      else 
          itemId1 = sysBranchStage.cost[2]
      end
      local icon1 = IconUtils:createItemIconById({itemId = itemId1, num = num1,effect = true})
      -- icon1:setScale(sysBranchStage.zoom/100)
      local leftPanel = self:getUI("bg" .. branchType ..".leftPanel")
      leftPanel:addChild(icon1)
      leftPanel:setLocalZOrder(100)

      local rightPanel = self:getUI("bg" .. branchType ..".rightPanel")

      if sysBranchStage.reward[1][1] == "team" then
          local sysTeam = tab:Team(sysBranchStage.reward[1][2])
          local icon2 = IconUtils:createSysTeamIconById({sysTeamData = sysTeam})
          rightPanel:addChild(icon2)
      else
          local num2 = sysBranchStage.reward[1][3]
          local itemId2 = sysBranchStage.reward[1][2]
          if sysBranchStage.reward[1][1] == "gold" then
              itemId2 = IconUtils.iconIdMap.gold
          elseif sysBranchStage.reward[1][1] == "gem" then
              itemId2 = IconUtils.iconIdMap.gem 
          elseif sysBranchStage.reward[1][1] == "texp" then
              itemId2 = IconUtils.iconIdMap.texp 
          else 
              itemId2 = sysBranchStage.reward[1][2]
          end
          local icon2 = IconUtils:createItemIconById({itemId = itemId2, num = num2,effect = true})
          local rightPanel = self:getUI("bg" .. branchType ..".rightPanel")
          rightPanel:addChild(icon2)
      end
  end

    local strDes    --by wangyan
    if branchType == SiegeConst.STAGE_BRANCH_TYPE.STAR then
      local limitLevel = tonumber(tab.systemOpen["Talent"][1])
      if self._modelMgr:getModel("UserModel"):getData().lvl >= limitLevel then
        strDes = lang("branchStage_des1012_back")
      else
        strDes = lang("branchStage_des1012")
      end
    else
      strDes = lang(sysBranchStage.des)
    end

    local descBg = self:getUI("bg" .. branchType ..".descBg")
    local rtx = RichTextFactory:create(strDes, descBg:getContentSize().width, descBg:getContentSize().height)
    rtx:formatText()
    rtx:setVerticalSpace(3)
    rtx:setAnchorPoint(cc.p(0,0.5))
    rtx:setPosition(-rtx:getInnerSize().width/2,descBg:getContentSize().height - rtx:getRealSize().height * 0.5)
    descBg:addChild(rtx)

    local cancelBtn = bg:getChildByName("cancelBtn")
    -- cancelBtn:setTitleColor(cc.c4b(255, 243, 223, 255))
    -- cancelBtn:getTitleRenderer():enable2Color(1, cc.c4b(255, 239, 133, 255))
    -- cancelBtn:getTitleRenderer():enableOutline(cc.c4b(125, 64, 0, 255), 2)
    if cancelBtn ~= nil then 
      self:registerClickEvent(cancelBtn, function ()
        self:close()
      end)
    end

    local enterBtn = bg:getChildByName("enterBtn")
    if enterBtn ~= nil then 
      self:registerClickEvent(enterBtn, function ()
        if callbackFunction ~= nil then 
          callbackFunction()
        end
        self:close()
      end)
    end
    bg:setVisible(true)
end


function SiegeBranchView:onInitSpecial(sysBranchStage)
  local bg = self:getUI("bgSpecial")
  bg:setVisible(true)
  local branchType = sysBranchStage.type
  if branchType ~= SiegeConst.STAGE_BRANCH_TYPE.WAR then
    self:close()
  end

  local animBg = self:getUI("bgSpecial.animBg")
  local templeAnim = mcMgr:createViewMC(sysBranchStage.specialShow, false, false)
  templeAnim:setPosition(cc.p(animBg:getContentSize().width * 0.5, animBg:getContentSize().height * 0.5) ) 
  -- registerClickEvent(bgLayer, function()
  --     templeAnim:stop()
  --     bgLayer:removeFromParent(true)
  -- end)

  animBg:addChild(templeAnim)
 
  templeAnim:addCallbackAtFrame(52, function()
    templeAnim:stop()
  end)


  local scalWidth = MAX_SCREEN_WIDTH / 1136
  
  animBg:setPositionX(animBg:getPositionX() + animBg:getContentSize().width * (1 - scalWidth) * 0.5 )
  animBg:setScale(scalWidth)

  local labTitle = bg:getChildByName("labTitle")
  labTitle:setVisible(false)


  local tip = cc.Label:createWithTTF(lang(sysBranchStage.des), UIUtils.ttfName, 22)
  tip:setAnchorPoint(0, 0)
  tip:setColor(cc.c4b(255, 253, 226,255))
  tip:enable2Color(1,cc.c4b(255, 236, 125,255))
  tip:enableOutline(cc.c4b(60, 30, 10, 255), 1)
  tip:setPosition(340, 34)
  animBg:addChild(tip)


  local recordBtn = self:getUI("bgSpecial.recordBtn")
  self._battleResult = {}
  self:registerClickEvent(recordBtn, function ()
    self:showReport(sysBranchStage.id, 2, function()
        self:showReport(sysBranchStage.id, 1, function()
            self._viewMgr:showDialog("intance.IntanceRecordView", {
              branchId = sysBranchStage.id,
              battleResult = self._battleResult
              })
        end)
    end)      
  end)
  if sysBranchStage.record == 1 then 
    recordBtn:setVisible(true)
  else
    recordBtn:setVisible(false)
  end

  local cancelBtn = bg:getChildByName("cancelBtn")
  if cancelBtn ~= nil then 
    self:registerClickEvent(cancelBtn, function ()
      self:close()
    end)
  end

  local enterBtn = bg:getChildByName("enterBtn")
  if enterBtn ~= nil then 
    self:registerClickEvent(enterBtn, function ()
      self._callback(self._curBranchId, 1)
      self:close()
    end)
  end
end



function SiegeBranchView:showReport(branchId, inSubType, inCallback)
    --回放
    local param = {id = branchId, type  = 3, subType  = inSubType}
    self._serverMgr:sendMsg("StageServer", "showReport", param, true, {}, function (result)
        if result == nil or next(result) == nil then 
            self._viewMgr:showTip(lang("TIP_ZHUXIAN_8"))
            return
        end
        self._battleResult[inSubType] = result
        if inCallback ~= nil then 
            inCallback()
        end
    end)    
end

return SiegeBranchView