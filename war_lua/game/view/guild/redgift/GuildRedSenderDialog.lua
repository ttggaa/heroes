--[[
    Filename:    GuildRedSenderDialog.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2016-06-06 19:55:16
    Description: File description
--]]

-- 发红包类型弹窗
local GuildRedSenderDialog = class("GuildRedSenderDialog", BasePopView)

function GuildRedSenderDialog:ctor(param)
    GuildRedSenderDialog.super.ctor(self)
    self._selectRed = param.sendType or 1
    self._callback = param.callback
    self._initHalf = 1

end


function GuildRedSenderDialog:onInit()
    self._redSend = (self._selectRed - 1) * 2

    local title = self:getUI("bg.titleBg.title")
    UIUtils:setTitleFormat(title, 4)
    -- title:setFontName(UIUtils.ttfName)
    -- title:setFontSize(30)

    for i=1,2 do
        local sendType = self:getUI("bg.sendType" .. i)
        local title = sendType:getChildByFullName("titleBg.title")
        if title then
            UIUtils:setTitleFormat(title, 2)
            -- title:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        end

        local vipLvl = sendType:getChildByFullName("vipLvl")
        if vipLvl then
            -- vipLvl:setFontName(UIUtils.ttfName)
            vipLvl:setFontSize(22)
            vipLvl:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        end
        
        local sendNum = sendType:getChildByFullName("sendNum")
        if sendNum then
            -- sendNum:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        end
        
        -- local sendPeople = sendType:getChildByFullName("sendPeople")
        -- sendPeople:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        local sendCostNum = sendType:getChildByFullName("sendCostNum")
        if sendCostNum then
            -- sendCostNum:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        end
        -- local des1 = sendType:getChildByFullName("des1")
        -- if des1 then
        --     des1:enableOutline(cc.c4b(65, 46, 0, 255), 2)
        -- end
        -- local rewardNum1 = sendType:getChildByFullName("rewardNum1")
        -- if rewardNum1 then
        --     rewardNum1:enableOutline(cc.c4b(65, 46, 0, 255), 2)
        -- end
        -- local rewardNum2 = sendType:getChildByFullName("rewardNum2")
        -- if rewardNum2 then
        --     rewardNum2:enableOutline(cc.c4b(65, 46, 0, 255), 2)
        -- end

    end
    self:listenReflash("VipModel", self.reflashUI)
    self:registerClickEventByName("bg.closeBtn", function ()
        self:close()
    end)
    self:listenReflash("VipModel", self.refreshSenderAnima)
end

function GuildRedSenderDialog:reflashUI()
    print("self._selectRed", self._redSend)
    for i=1,2 do
        local sendType = self:getUI("bg.sendType" .. i)
        local title = sendType:getChildByFullName("title")
        local redData = tab:GuildUserRed(self._redSend + i)
        if title then
            title:setString(lang("RED_NAME_" .. (self._redSend + i)))
        end
        
        local sendNum = sendType:getChildByFullName("sendNum")
        if sendNum then
            sendNum:setString(redData["give"][3])
        end
        
        local sendPeople = sendType:getChildByFullName("sendPeople")
        if sendPeople then
            sendPeople:setString("(数量:" .. redData["people"] .. "个)")
        end

        local sendCostNum = sendType:getChildByFullName("sendCostNum")
        if sendCostNum then
            sendCostNum:setString(redData["cost"][3])
        end

        local vipLvl = sendType:getChildByFullName("vipLvl")
        local biaoqian = sendType:getChildByFullName("biaoqian")
        if vipLvl then
            if not redData["condition"] then
                redData["condition"] = 0
            end
            if tonumber(redData["condition"]) == 0 then
                vipLvl:setVisible(false)
                if biaoqian then
                    biaoqian:setVisible(false)
                end
            end
            vipLvl:setString("V" .. redData["condition"])
        end

        local redType, _ = GuildUtils:getRedType(redData["type"])
        local sendIcon = sendType:getChildByFullName("sendIcon")
        if sendIcon then
            sendIcon:loadTexture("allicance_redziyuan" .. redType .. ".png", 1)
        end

        local ziyuan = sendType:getChildByFullName("hongbao.ziyuan")
        if ziyuan then
            -- ziyuan:loadTexture("allicance_redziyuan" .. redType .. ".png", 1)
            ziyuan:setVisible(false)
        end

        local hongbao = sendType:getChildByFullName("hongbao")
        local image = {"guild_red_huangjin.png","guil_red_zuanshi.png","guild_red_baowu.png"}
        if hongbao and image[redType] then
            hongbao:loadTexture(image[redType],1)
        end


        if i == 2 then
            local guildUserData = tab:GuildUserRed(self._selectRed*2)
            local userVipLv = self._modelMgr:getModel("VipModel"):getLevel()
            local needVip = guildUserData.vipEffect
            local vipTips = sendType:getChildByFullName("vip_tip")
            local rich =sendType:getChildByName("richText_")
            if rich then
                rich:removeFromParent(true)
            end
            if userVipLv < needVip then
                vipTips:setVisible(false)
                local strTips = string.gsub(lang("TIP_GUILD_RED_1"),"{$num}",needVip)
                local richText = RichTextFactory:create(strTips, 0, 0,true)
                richText:formatText()
                sendType:addChild(richText)
                richText:setPosition(vipTips:getPosition())
                richText:setName("richText_")
                -- vipTips:setString(strTips)
            else
                vipTips:setVisible(false)
            end

            local type_ = self._modelMgr:getModel("GuildRedModel"):isShowHalfRed()
            local half_line = sendType:getChildByFullName("half")
            local half_price = sendType:getChildByFullName("half_price")
            local sendCostIcon = sendType:getChildByFullName("sendCostIcon")
            local off = -20
            if type_ and type_ >= self._selectRed then
                half_line:setVisible(true)
                half_price:setVisible(true)  
                half_price:setString(tonumber(redData["cost"][3])/2)
                sendCostIcon:setPositionX(sendCostIcon:getPositionX()+off)
                sendCostNum:setPositionX(sendCostNum:getPositionX()+off-2)
                half_line:setPositionX(half_line:getPositionX()+off-2)
                half_line:setContentSize(half_price:getContentSize().width*0.75,2)
                half_price:setPositionX(half_price:getPositionX()+off-2)
                self._initHalf = 2
            else
                half_line:setVisible(false)
                half_price:setVisible(false)                  
            end
        end

        -- local des1 = sendType:getChildByFullName("des1")
        -- if des1 then
        --     des1:setString(redData["cost"][3])
        -- end
        for i=1,2 do
            local rewardNum = sendType:getChildByFullName("rewardNum" .. i)
            local rewardPic = sendType:getChildByFullName("rewardPic" .. i)

            if i <= table.nums(redData["reward"]) then
                if rewardNum and redData["reward"][i] then
                    rewardNum:setString(redData["reward"][i][3])
                    rewardPic:loadTexture(tab:Tool(redData["reward"][i][2]).art .. ".png", 1)
                    rewardNum:setVisible(true)
                    rewardPic:setVisible(true)
                else
                    rewardNum:setVisible(false)
                    rewardPic:setVisible(false)
                end
            else
                if rewardNum then
                    rewardNum:setVisible(false)
                    rewardPic:setVisible(false)
                end
            end
        end

        sendPeople:setPositionX(sendNum:getContentSize().width + sendNum:getPositionX())
        local sendRedBtn = sendType:getChildByFullName("sendRedBtn")
        if sendRedBtn then
            local viplevel = self._modelMgr:getModel("VipModel"):getData().level
            local userGem = self._modelMgr:getModel("UserModel"):getData().gem
            if redData["condition"] > viplevel then
                self:registerClickEvent(sendRedBtn, function ()
                    -- self._viewMgr:showTip("Vip 等级不足")
                    DialogUtils.showNeedCharge({desc = "VIP等级不足，是否前去充值", callback1=function()
                        self._viewMgr:showView("vip.VipView", {viewType = 0})
                    end})
                end)
            elseif redData["cost"][3]/self._initHalf > userGem then
                self:registerClickEvent(sendRedBtn, function ()
                    -- self._viewMgr:showTip("钻石不足")
                    DialogUtils.showNeedCharge({desc = lang("TIP_GLOBAL_LACK_GEM"), callback1=function( )
                        local viewMgr = ViewManager:getInstance()
                        viewMgr:showView("vip.VipView", {viewType = 0})
                    end})
                end)
            else
                self:registerClickEvent(sendRedBtn, function ()
                    if self._callback then
                        self._callback(self._redSend + i)
                    end
                    self:close()
                end)
            end

        end
    end
end

return GuildRedSenderDialog