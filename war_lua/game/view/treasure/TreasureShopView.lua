--[[
    Filename:    TreasureShopView.lua
    Author:      <wangguojun@playcrab.com>
    Datetime:    2016-02-03 16:43:51
    Description: File description
--]]
local tc = cc.Director:getInstance():getTextureCache()

local isLuckyCoin = false
local rightCostType = isLuckyCoin and "luckyCoin" or "gem"
local navigationRes = isLuckyCoin and {"LuckyCoin","Gem","41003"} or {"Gold","Gem","41003"}

local oneDrawCost = tab:Setting("G_DRAWCOST_TREASURE_SINGLE").value
local fiveDrawCost = tab:Setting("G_DRAWCOST_TREASURE_FIVETIMES").value 
local twentyDrawCost = tab:Setting("G_DRAWCOST_TREASURE_TWENTY").value 
local TreasureShopView = class("TreasureShopView",BaseView)
function TreasureShopView:ctor()
    self.super.ctor(self)

    -- [[ 活动加成
    local actCostOneLess = self._modelMgr:getModel("ActivityModel"):getAbilityEffect(self._modelMgr:getModel("ActivityModel").PrivilegIDs.PrivilegID_17)
    local actCostTenLess = self._modelMgr:getModel("ActivityModel"):getAbilityEffect(self._modelMgr:getModel("ActivityModel").PrivilegIDs.PrivilegID_18)
    oneDrawCost = tab:Setting("G_DRAWCOST_TREASURE_SINGLE").value*(1+actCostOneLess)
    fiveDrawCost = tab:Setting("G_DRAWCOST_TREASURE_FIVETIMES").value*(1+actCostTenLess)
    --]]
    self._tModel = self._modelMgr:getModel("TreasureModel")

    isLuckyCoin = self._modelMgr:getModel("UserModel"):drawUseLuckyCoin()
    rightCostType = isLuckyCoin and "luckyCoin" or "gem"
    navigationRes = isLuckyCoin and {"LuckyCoin","Gem","41003"} or {"Gold","Gem","41003"}
end

-- function TreasureShopView:getBgName()
--     return "treasure_shopbg.jpg"
-- end

function TreasureShopView:setNavigation()
    self._viewMgr:showNavigation("global.UserInfoView",{types=navigationRes,titleTxt = "宝物占星"})
end

function TreasureShopView:getAsyncRes()
    return 
        {
            {"asset/ui/treasureshop.plist", "asset/ui/treasureshop.png"},
            {"asset/ui/treasureshop1.plist", "asset/ui/treasureshop1.png"},
            {"asset/ui/treasureshop2.plist", "asset/ui/treasureshop2.png"},
            {"asset/ui/treasureshop3.plist", "asset/ui/treasureshop3.png"},
            {"asset/ui/treasure.plist", "asset/ui/treasure.png"},        
            {"asset/ui/treasure1.plist", "asset/ui/treasure1.png"},        
            {"asset/ui/treasure4.plist", "asset/ui/treasure4.png"},        
            {"asset/anim/shoprefreshanimimage.plist", "asset/anim/shoprefreshanimimage.png"}
        }
end

-- 初始化UI后会调用, 有需要请覆盖
function TreasureShopView:onInit()
    self._preBGMName = audioMgr:getMusicFileName()
    audioMgr:playMusic("SaintHeaven", true)

    self._drawOneBtn = self:getUI("bg.drawOne.drawBtn")
    -- self._drawOneBtn:setTitleText("购买一次")
    self._drawOneBtn:enableOutline(cc.c4b(1, 67, 128, 255), 1) 
    self._drawOneBtn:setTitleFontSize(24)  
    
    self:registerClickEventByName("bg.drawOne.drawBtn", function ()
        local vip = self._modelMgr:getModel("VipModel"):getData().level
        local canDraw = math.min(vip,#tab.vip)
        local haveGem = self._modelMgr:getModel("UserModel"):getData()[rightCostType] or 0
        local freenNum = self._modelMgr:getModel("PlayerTodayModel"):getData().day12 or 0
        local haveFree = self._modelMgr:getModel("PrivilegesModel"):getPeerageEffect(PrivilegeUtils.peerage_ID.BaoWuChouKa)
        local leftCount = self._tModel:countLeftNum()--self:countLeftNum()
        local _,haveNum = self._modelMgr:getModel("ItemModel"):getItemsById(41003)
        if (not (haveFree > 0 and freenNum < haveFree)) and ( (leftCount <= 0 and haveNum == 0) or (leftCount <= 0 and not self._useExItem)or (haveNum == 0 and self._useExItem and haveGem < oneDrawCost) )then
            self._viewMgr:showDialog("global.GlobalResTipDialog",{des1 = "今日购买次数已用完",des2 = "提升vip可增加购买次数"},true)
            return 
        end
        if( (haveGem < oneDrawCost and not self._useExItem) or ((haveNum <= 0 and haveGem < oneDrawCost) and self._useExItem) ) 
            and not (haveFree > 0 and freenNum < haveFree) then
            -- DialogUtils.showNeedCharge({desc = lang("TIP_GLOBAL_LACK_LUCKYCOIN"),button1 = "前往",title = "幸运币不足",callback1=function( )
            --     DialogUtils.showBuyRes({goalType = "luckyCoin",inputNum = oneDrawCost-haveGem })
            -- end})
            self:showNeedCharge(oneDrawCost-haveGem)
            return 
        end
        local drewFuc = "drewDisTreasure"
        if (haveNum > 0 and self._useExItem) or (haveFree > 0 and freenNum < haveFree)  then
            drewFuc = "drewFreeDisTreasure"
        end
        -- self._spine:setAnimation(0, "baowunv2", false)
        self._drawTwelveBtn:setEnabled(false)
        self._drawFiveBtn:setEnabled(false)
        self._drawOneBtn:setEnabled(false)
        self._serverMgr:sendMsg("TreasureServer", drewFuc, {num=1}, true, {}, function(result)
            self:showChoukaMc(function( )
                if not self.showChoukaMc or not result then return end
                self._drawTwelveBtn:setEnabled(true)
                self._drawFiveBtn:setEnabled(true)
                self._drawOneBtn:setEnabled(true)
                dump(result,"抽宝")
                self._viewMgr:showDialog("treasure.DrawTreasureResultDialog",{drawNum = 1,rewards = result.rewards, treasureCoinNum = result.treasureCoinNum,callback = function( )
                     self:showCommentView(result.rewards)
                end},true,nil,nil,true)
                -- DialogUtils.showTreasureGet(result.rewards, result.treasureCoinNum,function( )
                --     print("··············· 关闭展示回调")
                --     self:showCommentView(result.rewards)
                -- end)
                self:reflashUI()
            end)
        end)
    end)

    self._drawFiveBtn = self:getUI("bg.drawFive.drawBtn")
    -- self._drawFiveBtn:setTitleText("购买五次")
    self._drawFiveBtn:enableOutline(cc.c4b(1, 67, 128, 255), 1) 
    self._drawFiveBtn:setTitleFontSize(24) 
    self:registerClickEventByName("bg.drawFive.drawBtn", function ()
        local vip = self._modelMgr:getModel("VipModel"):getData().level
        local canDraw = math.min(vip,#tab.vip)
        local leftCount = self._tModel:countLeftNum()
        local _,haveNum = self._modelMgr:getModel("ItemModel"):getItemsById(41003)
        local haveGem = self._modelMgr:getModel("UserModel"):getData()[rightCostType] or 0
        if (leftCount < 5 and self._useExItem and haveNum < 5) or (leftCount < 5 and not self._useExItem) or (leftCount <= 0 and haveNum == 0) then
            if leftCount <= 0 then
                self._viewMgr:showDialog("global.GlobalResTipDialog",{des1 = "今日购买次数已用完",des2 = "提升vip可增加购买次数"},true)
            else
                self._viewMgr:showTip("剩余次数不足五次")
            end
            return 
        end
        if (haveGem < fiveDrawCost and not self._useExItem) or (self._useExItem and (haveNum < 5 and haveGem < fiveDrawCost)) then
            -- DialogUtils.showNeedCharge({desc = lang("TIP_GLOBAL_LACK_LUCKYCOIN"),button1 = "前往",title = "幸运币不足",callback1=function( )
            --     DialogUtils.showBuyRes({goalType = "luckyCoin",inputNum = fiveDrawCost-haveGem })
            -- end})
            self:showNeedCharge(fiveDrawCost-haveGem)
            return 
        end
        local drewFuc = "drewDisTreasure"
        if haveNum >= 5 and self._useExItem then
            drewFuc = "drewFreeDisTreasure"
        end
        -- self._spine:setAnimation(0, "baowunv2", false)
        self:showChoukaMc()
        self._drawTwelveBtn:setEnabled(false)
        self._drawFiveBtn:setEnabled(false)
        self._drawOneBtn:setEnabled(false)
        self._serverMgr:sendMsg("TreasureServer", drewFuc, {num=5}, true, {}, function(result)
            
            self:reflashUI()
            self:showChoukaMc(function( )
                if not self.showChoukaMc or not result then return end
                self._drawTwelveBtn:setEnabled(true)
                self._drawFiveBtn:setEnabled(true)
                self._drawOneBtn:setEnabled(true)
                dump(result,"抽宝")
                GRandomSeed(tostring(os.time()):reverse():sub(1, 6)) 
                local rand1 = (GRandom(1,#result.rewards))
                local temp = result.rewards[#result.rewards]
                result.rewards[#result.rewards] = result.rewards[rand1]
                result.rewards[rand1] = temp
                -- dump(result.rewards,"抽宝")
                -- DialogUtils.showTreasureGet(result.rewards, result.treasureCoinNum,function( )
                --     print("··············· 关闭展示回调")
                --     self:showCommentView(result.rewards)
                -- end)
                self._viewMgr:showDialog("treasure.DrawTreasureResultDialog",{drawNum = 5,rewards = result.rewards, treasureCoinNum = result.treasureCoinNum,callback = function( )
                     self:showCommentView(result.rewards)
                end},true,nil,nil,true)

                self:reflashUI()
            end)
        end)
    end)

    self._drawTwelveBtn = self:getUI("bg.drawTwelve.drawBtn")
    self._drawTwelveBtn:setTitleText("占星20次")
    self._drawTwelveBtn:enableOutline(cc.c4b(1, 67, 128, 255), 1) 
    self._drawTwelveBtn:setTitleFontSize(24) 
    self:registerClickEventByName("bg.drawTwelve.drawBtn", function ()
        local vip = self._modelMgr:getModel("VipModel"):getData().level
        local canDraw = math.min(vip,#tab.vip)
        local leftCount = self._tModel:countLeftNum()
        local _,haveNum = self._modelMgr:getModel("ItemModel"):getItemsById(41003)
        local haveGem = self._modelMgr:getModel("UserModel"):getData()[rightCostType] or 0
        if (leftCount < 20 and self._useExItem and haveNum < 20) or (leftCount < 20 and not self._useExItem) or (leftCount <= 0 and haveNum == 0) then
            if leftCount <= 0 then
                self._viewMgr:showDialog("global.GlobalResTipDialog",{des1 = "今日购买次数已用完",des2 = "提升vip可增加购买次数"},true)
            else
                self._viewMgr:showTip("剩余次数不足20次")
            end
            return 
        end
        if (haveGem < twentyDrawCost and not self._useExItem) or (self._useExItem and (haveNum < 20 and haveGem < twentyDrawCost)) then
            -- DialogUtils.showNeedCharge({desc = lang("TIP_GLOBAL_LACK_LUCKYCOIN"),button1 = "前往",title = "幸运币不足",callback1=function( )
            --     DialogUtils.showBuyRes({goalType = "luckyCoin",inputNum = twentyDrawCost-haveGem })
            -- end})
            self:showNeedCharge(twentyDrawCost-haveGem)
            return 
        end
        local drewFuc = "drewDisTreasure"
        if haveNum >= 20 and self._useExItem then
            drewFuc = "drewFreeDisTreasure"
        end
        -- self._spine:setAnimation(0, "baowunv2", false)
        self:showChoukaMc()
        self._drawTwelveBtn:setEnabled(false)
        self._drawFiveBtn:setEnabled(false)
        self._drawOneBtn:setEnabled(false)
        self._serverMgr:sendMsg("TreasureServer", drewFuc, {num=20}, true, {}, function(result)
            self:reflashUI()
            self:showChoukaMc(function( )
                if not self.showChoukaMc or not result then return end
                self._drawTwelveBtn:setEnabled(true)
                self._drawFiveBtn:setEnabled(true)
                self._drawOneBtn:setEnabled(true)
                dump(result,"抽宝")
                local rewards = result.rewards 
                local treasureCoinNum = result.treasureCoinNum 
                if treasureCoinNum and treasureCoinNum > 0 then
                    local treasureCoin = {
                        num = treasureCoinNum,
                        ["type"] = "tool",
                        typeId = IconUtils.iconIdMap["treasureCoin"]                    
                    }
                    table.insert(rewards,treasureCoin)
                end
                DialogUtils.showGiftGet({gifts = rewards})
                self:reflashUI()
            end)
        end)
    end)
    
    local desTxt = self:getUI("bg.des1")
    desTxt:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)

    local desTxt = self:getUI("bg.des1_0")
    desTxt:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)

    self._priceLab1     = self:getUI("bg.drawOne.priceLab")
    self._priceLab1:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
    self._diamondImg1   = self:getUI("bg.drawOne.diamondImg")          
    local scaleNum1     = math.floor((32/self._diamondImg1:getContentSize().width)*100)
    self._diamondImg1:setScale(scaleNum1/100)
    self._diamondImg1InitPosX = self._diamondImg1:getPositionX()
    
    self._priceLab1:setString(oneDrawCost or "")
    self._priceLab1:setPositionX(self._diamondImg1:getPositionX()+self._diamondImg1:getContentSize().width/2)

    -- 单抽原价
    self._originalOneNode   = self:getUI("bg.drawOne.originalNode")
    self._originalOneNode:setVisible(false)
    self._originalOneNode:getChildByFullName("label_yuanjia"):enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
    self._originalOneLab    = self._originalOneNode:getChildByFullName("label_original_cost")
    self._originalOneLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
    self._originalOneLab:setString(oneDrawCost)

    self._priceLab5     = self:getUI("bg.drawFive.priceLab")
    self._priceLab5:setString(fiveDrawCost or "")
    self._priceLab5:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
    self._diamondImg5   = self:getUI("bg.drawFive.diamondImg")      
    self._scaleNum2     = math.floor((32/self._diamondImg5:getContentSize().width)*100)
    self._diamondImg5:setScale(self._scaleNum2/100)
    self._priceLab5:setPositionX(self._diamondImg5:getPositionX()+self._diamondImg5:getContentSize().width/2)

    -- 五连抽原价
    self._originalFiveNode = self:getUI("bg.drawFive.originalNode")
    self._originalFiveNode:setVisible(false)
    self._originalFiveNode:getChildByFullName("label_yuanjia"):enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
    self._originalFiveLab = self._originalFiveNode:getChildByFullName("label_original_cost")
    self._originalFiveLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
    self._originalFiveLab:setString(fiveDrawCost)

    -- 20连抽
    self._priceLab20     = self:getUI("bg.drawTwelve.priceLab")
    self._priceLab20:setString(fiveDrawCost or "")
    self._priceLab20:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
    self._diamondImg20   = self:getUI("bg.drawTwelve.diamondImg")      
    self._scaleNum3     = math.floor((32/self._diamondImg20:getContentSize().width)*100)
    self._diamondImg20:setScale(self._scaleNum3/100)
    self._priceLab20:setPositionX(self._diamondImg20:getPositionX()+self._diamondImg20:getContentSize().width/2)


    self._spliceNum = self:getUI("bg.spliceNum")
    self._spliceNum:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)

    self._shopBg = self:getUI("bg.shopBg")
    -- self._shopBg:loadTexture("asset/bg/treasure_shopbg.jpg")
    local guideDes = self:getUI("bg.guideBg.guideDes")
    guideDes:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    
    self._drawFive = self:getUI("bg.drawFive")

    self._guide = self:getUI("bg.guideBg.guide")
    self._guideDes = self:getUI("bg.guideBg.guideDes")
    self._bg = self:getUI("bg")

    -- [[ 2017.1.16 增加选择黑市币
    self._selBox = self:getUI("bg.selBox")
    self._checkDes = self:getUI("bg.selBox.checkDes")
    self._checkDes:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    self._checkBox = self:getUI("bg.selBox.checkBox")
    self._useExItem = false
    self._checkBox:addEventListener(function (_, state)
        print("touch check box...")
        local selected = state == 0
        self._useExItem = selected
        self:reflashUI()
    end)
    local _,haveNum = self._modelMgr:getModel("ItemModel"):getItemsById(41003)
    self._selBox:setVisible(haveNum > 0)
    self._checkBox:setSelected(haveNum > 0)
    self._useExItem = haveNum > 0
    print("self._useExItem...",self._useExItem)
    -- 增加显示下一次的逻辑
    self._promptBg = self:getUI("promptBg")
    -- self._promptDes1 = self:getUI("bg.promptBg.des1")
    -- self._promptDes1:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    -- self._promptDes1:setColor(cc.c3b(242, 242, 229))
    -- self._promptDes1:enable2Color(1, cc.c4b(255, 236, 73, 255))

    -- self._promptDes2 = self:getUI("bg.promptBg.des2")
    -- self._promptDes2:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    -- self._promptDes2:setColor(cc.c3b(242, 242, 229))
    -- self._promptDes2:enable2Color(1, cc.c4b(255, 236, 73, 255))
    
    -- self._promptDes3 = self:getUI("bg.promptBg.des3")
    -- self._promptDes3:setColor(cc.c3b(242, 242, 229))
    -- self._promptDes3:enable2Color(1, cc.c4b(255, 236, 73, 255))
    -- self._promptDes3:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)

    self._nextNum = self:getUI("promptBg.nextNum")
    self._nextNum:setColor(cc.c3b(255, 210, 138))
    self._nextNum:setFontSize(22)
    -- self._nextNum:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    self._nextNumHigh = self:getUI("promptBg1.nextNum")
    self._nextNumHigh:setColor(cc.c3b(255, 210, 138))
    self._nextNumHigh:setFontSize(20)
    -- 
    self._textBg1 = self:getUI("bg.drawOne.textBg")
    self._textBg5 = self:getUI("bg.drawFive.textBg")

    self._textBg1Des1 = self:getUI("bg.drawOne.textBg.des1")
    self._textBg1Des1:setString("本次必得")
    self._textBg1Des2 = self:getUI("bg.drawOne.textBg.des2")
    self._textBg1Des2:setPositionX(35)
    self._textBg5Des2 = self:getUI("bg.drawFive.textBg.des2")
    self._textBg1Des2:setPositionX(35)
    self._textBg20Des2 = self:getUI("bg.drawTwelve.textBg.des2")
    self._textBg20Des2:setString("必得橙色宝物")
    self._textBg20Des2:setColor(cc.c3b(250, 210, 138))
    -- 预览按钮
    -- local preViewBtn = self:getUI("bg.preViewBtn")
    -- preViewBtn:setVisible(false)
    self:registerClickEventByName("preViewBtn",function() 
        self._viewMgr:showDialog("treasure.TreasureExchangePreview", {allOpen=true})
    end)
    -- 商店按钮
    self:registerClickEventByName("shopBtn",function() 
        self._viewMgr:showView("shop.ShopView", {idx = 4})
    end)
    --]]
    --橙色宝物预览
    self._prePanel = self:getUI("prePanel")
    self:registerClickEvent(self._prePanel,function() 
        UIUtils:reloadLuaFile("treasure.TreasureShopPreView")
        self._viewMgr:showDialog("treasure.TreasureShopPreView", {imgs = self._preTreasure})
    end)
    self:registerClickEventByName("prePanel.infoBtn",function() 
        self._viewMgr:showDialog("spellbook.SpellBookRuleView",{title = "宝物热点规则",des =  lang("DRAWTREASURETE_TIPS2")})
    end)
    self._timeLab = self:getUI("prePanel.timeLab")
    self._treasure1 = self:getUI("prePanel.treasure1")
    self._treasure2 = self:getUI("prePanel.treasure2")

    self:listenReflash("VipModel",self.reflashUI)
    self:listenReflash("ItemModel",self.reflashUI)
    self:listenReflash("UserModel",self.reflashUI)


    -- spine 动画
    self._guideBg = self:getUI("bg.guideBg")
    -- self:addTreasureSpine()
    -- self:registerClickEvent(self._guideBg,function() 
    --     self._spine:setAnimation(0, "baowunv2", false)
    -- end)

    -- 加特效
    -- 气泡缩放动画
    -- self._guide:runAction(cc.RepeatForever:create(
    --     cc.Sequence:create(
    --         cc.EaseIn:create(cc.ScaleTo:create(1,0.95),0.5),
    --         cc.EaseOut:create(cc.ScaleTo:create(1,1),0.5)
    --     )
    -- ))
    -- 背景灯晕 加在背景图上 适配
    -- if self.__viewBg then 
    --     local mcLight = mcMgr:createViewMC("guangyun_shoprefreshanim", true, false)
    --     mcLight:setPosition(cc.p(self.__viewBg:getContentSize().width/2-160,self.__viewBg:getContentSize().height/2+50))
    --     self.__viewBg:addChild(mcLight,10)
        
    --     local mcLight2 = mcMgr:createViewMC("guangyun_shoprefreshanim", true, false)
    --     mcLight2:setPosition(cc.p(self.__viewBg:getContentSize().width/2+300,self.__viewBg:getContentSize().height/2+50))
    --     self.__viewBg:addChild(mcLight2,10)
    -- end
    -- 十次必得
    -- local mcBoard = mcMgr:createViewMC("10cibide_shoprefreshanim", true, false)
    -- mcBoard:setPosition(cc.p(self._promptBg:getContentSize().width/2,self._promptBg:getContentSize().height/2))
    -- self._promptMc = mcBoard
    -- self._promptBg:addChild(mcBoard,10)
    -- 必得橙色
    -- local drawOneTextBg = self:getUI("bg.drawOne.textBg")
    -- local mcChengZi = mcMgr:createViewMC("chengsebaowu_shoprefreshanim", true, false)
    -- mcChengZi:setPosition(cc.p(drawOneTextBg:getContentSize().width/2-2+16,drawOneTextBg:getContentSize().height/2))
    -- self._1ChengZiMc = mcChengZi
    -- drawOneTextBg:addChild(mcChengZi,10)
    
    -- local drawFiveTextBg = self:getUI("bg.drawFive.textBg")
    -- local mcChengZi = mcMgr:createViewMC("chengsebaowu_shoprefreshanim", true, false)
    -- mcChengZi:setPosition(cc.p(drawFiveTextBg:getContentSize().width/2-2,drawFiveTextBg:getContentSize().height/2))
    -- self._5ChengZiMc = mcChengZi
    -- drawFiveTextBg:addChild(mcChengZi,10)
    self:reflashUI()
    self:addBgMc()
    self:addDaiJiMc()
    self:registerTimer(5,0,0, function ()
        self:reflashUI()
    end)
end

function TreasureShopView:addBgMc( )
    local offsetX = (960-MAX_SCREEN_WIDTH)/2
    local offsetY = (-640+MAX_SCREEN_HEIGHT)/2
    local mcBgYun = mcMgr:createViewMC("baowuchoukabeij_treasureshopbaowuchouka", true, false)
    mcBgYun:setAnchorPoint(0.5,0.5)
    mcBgYun:setPosition(offsetX,640+offsetY)
    -- mcBgYun:setScale(scale)
    self._bg:addChild(mcBgYun,-1)
    local xscale = MAX_SCREEN_WIDTH / 960
    local yscale = MAX_SCREEN_HEIGHT / 640
    if xscale > yscale then
        mcBgYun:setScale(xscale)
    else
        mcBgYun:setScale(yscale)
    end
end

function TreasureShopView:addDaiJiMc( )
    local mcDaiji = mcMgr:createViewMC("daiji_treasurechoukadaiji", true, false)
    mcDaiji:setPosition(cc.p(self._bg:getContentSize().width/2,self._bg:getContentSize().height/2-50))
    -- mcDaiji:setPlaySpeed(0.01)
    self._daijiMc = mcDaiji
    self._bg:addChild(mcDaiji,0)

    -- 点击抽卡动画
    local mcChouka = mcMgr:createViewMC("dianjichoukai_treasurechoukadaiji", true, false)
    mcChouka:setPosition(cc.p(self._bg:getContentSize().width/2,self._bg:getContentSize().height/2-50))
    -- mcChouka:setPlaySpeed(0.01)
    self._choukaMc = mcChouka
    self._bg:addChild(mcChouka,2)
    self._choukaMc:setVisible(false)
    self._choukaMc:gotoAndStop(0)

    local mcYun = mcMgr:createViewMC("yun_treasurebaowuchouka2", true, false)
    mcYun:setPosition(cc.p(self._bg:getContentSize().width/2,self._bg:getContentSize().height/2+20))
    -- mcYun:setPlaySpeed(0.01)
    self._yunMc = mcYun
    self._bg:addChild(mcYun,1)
    self._yunMc:setVisible(false)
    self._yunMc:gotoAndStop(0)
    self._yunMc:setCascadeOpacityEnabled(true,true)
end

-- 增加spine
function TreasureShopView:addTreasureSpine( )
    tc:addImage("asset/spine/".. "baowunv" ..".png")
    self._spineLayer = cc.Node:create()
    self._guideBg:addChild(self._spineLayer, 998)
    -- self._spineLayer:setScale(self.__viewBg:getScaleX())
    self._spineLayer:setPosition(0,0)
    -- 人物动画
    spineMgr:createSpine("baowunv", function (spine)
        if self._spineLayer == nil then return end
        spine:setScale(0.9)
        -- spine:setSkin(nameTab[8])
        spine:setAnimation(0, "baowunvdaiji", true)
        spine:setPosition(200, -20)
        self._spineLayer:addChild(spine, 10)
        spine.endCallback = function( spine )
            spine:setAnimation(0, "baowunvdaiji", true)
        end
        spine:initUpdate()
        self._spine = spine
    end)
end

-- 接收自定义消息
function TreasureShopView:reflashUI(data)
    local coinNum = self._modelMgr:getModel("UserModel"):getData().treasureCoin
    self._spliceNum:setString(coinNum or 0)
    local leftCount,haveExItem,toGetNum,highToGetNum = self._tModel:countLeftNum()
    -- if haveExItem > 0 then 
    self._guide:removeChildByName("rtx")
    local rtxDes = "[color = ffffff,fontsize=18]购买[-][color = fff535,fontsize=18]宝物精华[-][color = ffffff,fontsize=18]送宝物，[-]"
    if self._useExItem and haveExItem >= 5 then
        local prompt = lang("BUY_TREASURE_COINUSE")
        rtxDes = rtxDes .. "[color = ffffff,fontsize=18]" .. prompt .."[-]"
    else
        rtxDes = rtxDes .. "[color = ffffff,fontsize=18]你今天还能购买[-][color = fff535,fontsize=18]".. leftCount .."[-][color = ffffff,fontsize=18]次[-]"
    end
    self._nextNum:setString(toGetNum)
    self._nextNumHigh:setString(highToGetNum)

    -- [[ 剩余一次得橙色显示
    local isOrange = toGetNum == 1
    local isPurple = toGetNum%5 == 1 and toGetNum ~= 0
    self._textBg1:setVisible( isOrange or isPurple)
    if isOrange then
        -- self._promptDes2:setVisible(false)
        -- self._nextNum:setString("")
        -- self._promptDes2:setString("本次必得")
        -- if self._1ChengZiMc then
        --     self._1ChengZiMc:setVisible(true)
        -- end
    else
        -- self._promptDes1:setVisible(true)
        self._nextNum:setString(toGetNum)
        -- self._promptDes2:setString("次之后必得")
        -- if self._1ChengZiMc then
        --     self._1ChengZiMc:setVisible(false)
        -- end
    end
    if highToGetNum <= 20 then
        self._nextNum:setString(toGetNum+20)
    end
    -- 设置textBg上显示
    if isPurple and not isOrange then
        self._textBg1Des2:setString("必得紫色宝物")
        self._textBg1Des2:setColor(cc.c3b(255, 120, 255))
    elseif isOrange then
        self._textBg1Des2:setString("必得橙色宝物")
        self._textBg1Des2:setColor(cc.c3b(250, 210, 138))
    end
    -- self._promptDes2:setPositionX(self._nextNum:getPositionX()+self._nextNum:getContentSize().width+1)
    -- self._promptDes3:setPositionX(self._promptDes2:getPositionX()+self._promptDes2:getContentSize().width+1)
    if toGetNum <= 5 then
        self._textBg5Des2:setString("必得橙色宝物")
        self._textBg5Des2:setColor(cc.c3b(250, 210, 138))
        -- if self._promptMc then
        --     self._promptMc:setVisible(true)
        -- end
        -- if self._5ChengZiMc then
        --     self._5ChengZiMc:setVisible(true)
        -- end
    else
        self._textBg5Des2:setString("必得紫色宝物")
        self._textBg5Des2:setColor(cc.c3b(255, 120, 255))
        -- if self._5ChengZiMc then
        --     self._5ChengZiMc:setVisible(false)
        -- end
    end
    --]]
    -- rtxDes = rtxDes .. "[][-][color = 825528,fontsize=22]还有[-][color = 00ff1e,outlinecolor=3c1e0a00,outlinesize=1]".. toGetNum .."[-][color = 14232a,fontsize=22]次就必定获得[-]"
    -- rtxDes = rtxDes .. "[][-][color = ffbb38,fontsize=20,outlinecolor=3c1e0a00,outlinesize=1]橙色宝物[-]"
    local rtx = RichTextFactory:create(rtxDes,640,40)
    rtx:formatText()
    rtx:setVerticalSpace(7)
    rtx:setName("rtx")
    local w = rtx:getInnerSize().width
    local h = rtx:getVirtualRendererSize().height
    print("self._guide:getContentSize().width/2",self._guide:getContentSize().width/2)
    rtx:setPosition(w*0.5,self._guide:getContentSize().height/2)
    self._guide:addChild(rtx,99)
    -- UIUtils:alignRichText(rtx,{vAlign="bottom"})
    if haveExItem > 0 and self._useExItem then
        self._priceLab1:setString( ItemUtils.formatItemCount(haveExItem) .. "/" .. 1)
        self._diamondImg1:loadTexture("globalImageUI_treasurecoupon.png",1)

        self:showOriginalOneNode(1)
        if haveExItem >= 5 then
            self._priceLab5:setString( ItemUtils.formatItemCount(haveExItem) .. "/" .. 5)
            self._diamondImg5:loadTexture("globalImageUI_treasurecoupon.png",1)
            self:showOriginalOneNode(5)
            if haveExItem >= 20 then
                self._priceLab20:setString( ItemUtils.formatItemCount(haveExItem) .. "/" .. 20)
                self._diamondImg20:loadTexture("globalImageUI_treasurecoupon.png",1)
            else
                self._priceLab20:setString(twentyDrawCost)
                self._diamondImg20:loadTexture(IconUtils.resImgMap[rightCostType],1)
            end
        else
            self._priceLab5:setString(fiveDrawCost)
            self._diamondImg5:loadTexture(IconUtils.resImgMap[rightCostType],1)
            self:showOriginalOneNode(1)
            self._priceLab20:setString(twentyDrawCost)
            self._diamondImg20:loadTexture(IconUtils.resImgMap[rightCostType],1)
        end
    else
        self:showOriginalOneNode(0)
        self._priceLab1:setString(oneDrawCost)
        self._diamondImg1:loadTexture(IconUtils.resImgMap[rightCostType],1)
        self._priceLab5:setString(fiveDrawCost)
        self._diamondImg5:loadTexture(IconUtils.resImgMap[rightCostType],1)
        self._priceLab20:setString(twentyDrawCost)
        self._diamondImg20:loadTexture(IconUtils.resImgMap[rightCostType],1)
    end
    local freenNum = self._modelMgr:getModel("PlayerTodayModel"):getData().day12 or 0
    local haveFree = self._modelMgr:getModel("PrivilegesModel"):getPeerageEffect(PrivilegeUtils.peerage_ID.BaoWuChouKa)
    print(haveFree,"haveFree------------",freenNum)
    if haveFree > 0 and freenNum < haveFree then
        -- self._priceLab1:setVisible(false)
        -- self._diamondImg1:setVisible(false)
        self._diamondImg1:loadTexture(IconUtils.resImgMap["privilege"],1)
        local scaleN = math.floor((32/self._diamondImg1:getContentSize().width)*100)
        self._diamondImg1:setScale(scaleN/100)
        self._priceLab1:setString("".."免费(1)")
        -- self._des1:setColor(cc.c3b(5, 255, 16))
        self._priceLab1:setColor(cc.c3b(255, 255, 255))
        self._priceLab1:disableEffect()
        self._selBox:setVisible(false)
       
        self._diamondImg1:setPositionX(self._diamondImg1InitPosX)
    else
        -- self._priceLab1:setVisible(true)
        -- self._diamondImg1:setVisible(true)
        self._diamondImg1:setPositionX(self._diamondImg1InitPosX)
        self._diamondImg1:setScale(self._scaleNum2/100)
        -- self._priceLab1:setString("消耗")
        self._priceLab1:setColor(cc.c3b(255, 255, 255))
    end

    UIUtils:alignRichText(rtx,{valign = "left",halign = "bottom"})

    -- 额外代码判断不够的时候pricelab变红
    local gem = self._modelMgr:getModel("UserModel"):getData()[rightCostType] or 0 
    if (haveExItem < 5 and self._useExItem and gem < fiveDrawCost) or (not self._useExItem and gem < fiveDrawCost) then
        self._priceLab5:setColor(cc.c3b(255, 0, 0))
    else
        self._priceLab5:setColor(cc.c3b(255, 255, 255))
    end
    
    if (haveExItem < 20 and self._useExItem and gem < twentyDrawCost) or (not self._useExItem and gem < twentyDrawCost) then
        self._priceLab20:setColor(cc.c3b(255, 0, 0))
    else
        self._priceLab20:setColor(cc.c3b(255, 255, 255))
    end

    if ((haveExItem < 1 and gem < oneDrawCost and self._useExItem) or (gem < oneDrawCost and not self._useExItem)) and not (haveFree > 0 and freenNum < haveFree) then
        self._priceLab1:setColor(cc.c3b(255, 0, 0))
    else
        self._priceLab1:setColor(cc.c3b(255, 255, 255))
    end 

    local _,haveNum = self._modelMgr:getModel("ItemModel"):getItemsById(41003)
    self._selBox:setVisible(haveNum > 0)
    if haveNum <= 0 then
        self._useExItem = false
    end
    local freenNum = self._modelMgr:getModel("PlayerTodayModel"):getData().day12 or 0
    local haveFree = self._modelMgr:getModel("PrivilegesModel"):getPeerageEffect(PrivilegeUtils.peerage_ID.BaoWuChouKa)
    print(haveFree,"haveFree------------",freenNum)
    if haveFree > 0 and freenNum < haveFree then
        self._selBox:setVisible(false)
    end
    self:reflashPreBoard()
end

-- 刷新抽出预览
function TreasureShopView:reflashPreBoard( )
    -- if self._prePanel then self._prePanel:setVisible(false) end
    -- if true then return end
    local nowTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
    local serverWeek = self._modelMgr:getModel("UserModel"):getData().week

    local weekday = tonumber(TimeUtils.date("%w",nowTime)) or 1
    local hour  = tonumber(TimeUtils.date("%H",nowTime) or 0) or 0
    local week = TimeUtils.date("%W",nowTime) or 0
    print(weekday,"weekday----------------",hour,week)
    if weekday == 1 then
        if hour < 5 then
            nowTime = nowTime-7*86400
            hour = 5
            week = week-1
        end
    elseif weekday == 0 then
        weekday = 7
    end    
    local year = TimeUtils.date("%Y",nowTime) or 2017
    local month = TimeUtils.date("%m",nowTime - (weekday-1)*86400) or 1
    local day  = TimeUtils.date("%d",nowTime) or 1
    local weekBegin = TimeUtils.date("%d",nowTime - (weekday-1)*86400) or day - weekday + 1
    print("weekday",weekday)
    local weekIndex = weekday 
    if weekday == 0 then weekIndex = 7 end
    local weekEnd = TimeUtils.date("%d",nowTime+(7-weekIndex+1)*86400) or 1
    local monthEnd = TimeUtils.date("%m",nowTime+(7-weekIndex+1)*86400) or 1
    if week == 0 then week = 1 end
    -- local showIndex = year .. string.format("%02d",week)
    
    local showIndex = serverWeek or year .. string.format("%02d",week)
    print("======serverWeek=========="..serverWeek)
    local showD = tab.scrollHotSpot[tonumber(serverWeek)]
    -- if not showD then 
    --     showD = tab.scrollHotSpot[showIndex]
    -- end
    local sysOpenTime = 20171211
    local nowDayTime = tonumber( year .. string.format("%02d",month) .. day) or 0 
    print(showIndex,nowDayTime,"----",hour)
    if showD and (sysOpenTime < nowDayTime or (sysOpenTime == nowDayTime and hour >=5)) then
        self._prePanel:setVisible(true)
        local index = showD.drawTreasure or 1
        print(index,"lindex")
        local drawD = tab.drawTreasureTe[index]
        if not drawD then
            self._prePanel:setVisible(false)
            return 
        end
        local timeStr = "持续时间:" .. month .. "月" .. weekBegin .. " 5:00" .. "-" ..
                                       monthEnd .. "月" .. weekEnd   .. " 5:00"
        self._timeLab:setString(timeStr)
        local treasureImgs = {
            (drawD.image2 or "globalImageUI6_meiyoutu") .. ".png",
            (drawD.image1 or "globalImageUI6_meiyoutu") .. ".png",
        }
        self._preTreasure = treasureImgs
        self._timeLab:setFontSize(16)
        self._treasure1:loadTexture((drawD.image2 or "globalImageUI6_meiyoutu") .. ".png",1)
        self._treasure1:setScale(0.4)
        self._treasure2:loadTexture((drawD.image1 or "globalImageUI6_meiyoutu") .. ".png",1)
        self._treasure2:setScale(0.5)
        
        local isAutoShow = SystemUtils.loadAccountLocalData("treasureHot_dateidx")
        if not isAutoShow or (tonumber(isAutoShow) and tonumber(isAutoShow) < tonumber(showIndex)) then
            SystemUtils.saveAccountLocalData("treasureHot_dateidx", showIndex)
            ScheduleMgr:delayCall(1,self,function( )
                self._viewMgr:showDialog("treasure.TreasureShopPreView", {imgs = self._preTreasure}) 
            end)
        end
    else
        self._prePanel:setVisible(false)
    end
end

-- 是否显示原价
-- @param sType 0:都不显示 1:显示单抽原价 5:都显示原价
function TreasureShopView:showOriginalOneNode(sType)
    if true then return end
    if sType == 0 then
        self._originalOneNode:setVisible(false)
        self._originalFiveNode:setVisible(false)
        -- self._drawOneBtn:setPositionY(92)
        -- self._drawFiveBtn:setPositionY(92)
    elseif sType == 1 then
        self._originalOneNode:setVisible(true)
        self._originalFiveNode:setVisible(false)
        -- self._drawOneBtn:setPositionY(109)
        -- self._drawFiveBtn:setPositionY(92)
    elseif sType == 5 then
        self._originalOneNode:setVisible(true)
        self._originalFiveNode:setVisible(true)
        -- self._drawOneBtn:setPositionY(109)
        -- self._drawFiveBtn:setPositionY(109)
    end
end

-- 评论
function TreasureShopView:showCommentView( awards )
    local inType = 6
    for k,v in pairs(awards) do
        -- 评论
        local param = {inType = inType, treasureId = v.typeId}
        local isPop, popData = self._modelMgr:getModel("CommentGuideModel"):checkCommentGuide(param)
        if isPop == true then
            self._viewMgr:showDialog("global.GlobalCommentGuideView", popData, true)
            break
        end
    end
end

function TreasureShopView:onHide( )
    if self._preBGMName then
        audioMgr:playMusic(self._preBGMName, true)
    end
end

function TreasureShopView:onShow( )
    self:updateRealVisible(true)
end

function TreasureShopView:onTop( )
    self:updateRealVisible(true)
    self._preBGMName = audioMgr:getMusicFileName()
    audioMgr:playMusic("SaintHeaven", true)
end

function TreasureShopView:onDestroy( )
    -- self._preBGMName = audioMgr:getMusicFileName()
    -- audioMgr:playMusic("SaintHeaven", true)
    if self._preBGMName then
        audioMgr:playMusic(self._preBGMName, true)
    end
    TreasureShopView.super.onDestroy(self)
end

------------- 宝物效果逻辑  2017.5.23 工期紧，尽量不改之前逻辑
-- 
function TreasureShopView:showChoukaMc(callback)
    self._choukaMc:setVisible(true)
    self._choukaMc:gotoAndPlay(0)
    self._yunMc:setVisible(true)
    self._yunMc:gotoAndPlay(0)
    -- self._choukaMc:addCallbackAtFrame()
    self._daijiMc:setVisible(false)
    ScheduleMgr:delayCall(500, self, function( )
        if not tolua.isnull(self._daijiMc) then
            self._yunMc:runAction(cc.Sequence:create(
                cc.FadeOut:create(1),
                cc.CallFunc:create(function(  )
                    self._choukaMc:setVisible(false)
                    self._daijiMc:setVisible(true)
                    self._daijiMc:gotoAndPlay(0)
                    self._yunMc:setVisible(false)
                    self._yunMc:setOpacity(255)
                end)
            ))
            if callback then
                callback()
            end
        end
    end)
end

-- 根据类型跳转
function TreasureShopView:showNeedCharge( needNum )
    if isLuckyCoin then
        DialogUtils.showNeedCharge({desc = lang("TIP_GLOBAL_LACK_LUCKYCOIN"),button1 = "前往",title = "幸运币不足",callback1=function( )
            DialogUtils.showBuyRes({goalType = "luckyCoin",inputNum = needNum })
        end})
    else
        DialogUtils.showNeedCharge({desc = lang("TIP_GLOBAL_LACK_GEM"),callback1=function( )
            local viewMgr = ViewManager:getInstance()
            viewMgr:showView("vip.VipView", {viewType = 0})
        end})
    end
end

return TreasureShopView