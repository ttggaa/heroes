--[[
    Filename:    GuildMapPvpCell.lua
    Author:      <weiwei02@playcrab.com>
    Datetime:    2016-07-20 00:21:11
    Description: File description
--]]


local GuildMapPvpUserCell = class("GuildMapPvpUserCell", cc.TableViewCell, BaseEvent)

function GuildMapPvpUserCell:ctor()
    -- GuildMapPvpUserCell.super.ctor(self)

end

function GuildMapPvpUserCell:onInit()

end

function GuildMapPvpUserCell:reflashUI(inUserId, inIsFriend)  -- 442/119
    self._guildMapModel = ModelManager:getInstance():getModel("GuildMapModel")
    local userList = self._guildMapModel:getData().userList
    local holdUserInfo = userList[inUserId]
    if holdUserInfo == nil then
        local count = #self:getChildren()
        for i = 1, count do
            self:getChildren()[i]:setVisible(false)
        end
        return
    end
    local count = #self:getChildren()
    for i = 1, count do
        self:getChildren()[i]:setVisible(true)
    end
    self:setContentSize(cc.size(430, 105))

    if self._cellBg == nil then
        self._cellBg = ccui.ImageView:create("globalPanelUI7_cellBg21.png", 1)
        self._cellBg:setScale9Enabled(true)
        self._cellBg:setCapInsets(cc.rect(41, 41, 1, 1))
        self._cellBg:setContentSize(cc.size(430, 105))
        self._cellBg:setAnchorPoint(0, 0.5)
        self._cellBg:setPosition(0, self:getContentSize().height * 0.5)
        self:addChild(self._cellBg)
    end

    if self._nameLab == nil then 
        self._nameLab = cc.Label:createWithTTF("", UIUtils.ttfName, 20)
        self:addChild(self._nameLab)
        self._nameLab:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
        self._nameLab:setPosition(100, 80)
        self._nameLab:setAnchorPoint(0, 0.5)          
    end
    self._nameLab:setString(holdUserInfo.name)
    local dis = math.max(self._nameLab:getContentSize().width - 141, 0) + 10

    if self._scoreLab == nil then 
        self._scoreLab = cc.LabelBMFont:create("a1000", UIUtils.bmfName_zhandouli)
        self._scoreLab:setAnchorPoint(cc.p(0,0))
        self._scoreLab:setPosition(100, 23)
        self._scoreLab:setScale(0.5)
        self:addChild(self._scoreLab, 1)
    end
    self._scoreLab:setString("a" ..holdUserInfo.score)

    if self._mapHurtLab == nil then 
        self._mapHurtLab = cc.Label:createWithTTF("", UIUtils.ttfName, 20)
        self:addChild(self._mapHurtLab)
        self._mapHurtLab:setColor(UIUtils.colorTable.ccUIBaseTextColor1)
        self._mapHurtLab:setAnchorPoint(0, 0)
        self._mapHurtLab:setPosition(100, 43)      
    end

    if holdUserInfo.mapHurt == nil then 
        self._mapHurtLab:setString("生命 0/100")
    else
        self._mapHurtLab:setString("生命 " .. holdUserInfo.mapHurt .. "/100")
    end

    local headP = {avatar = holdUserInfo.avatar,level = holdUserInfo.lvl or 0 , tp = 4,avatarFrame = holdUserInfo["avatarFrame"], plvl = holdUserInfo.plvl}
    if self._avatar == nil then
        self._avatar = IconUtils:createHeadIconById(headP)   --,tp = 2
        -- self._avatar:getChildByFullName("iconColor"):loadTexture("globalImageUI6_headBg.png",1)
        self._avatar:setPosition(20, 17)
        self._avatar:setScale(0.8)
        self:addChild(self._avatar)
    else
        IconUtils:updateHeadIconByView(self._avatar,headP)
        -- self._avatar:getChildByFullName("iconColor"):loadTexture("globalImageUI6_headBg.png",1)
    end
    if self._attackBtn == nil then
        self._attackBtn = ccui.Button:create("globalButtonUI13_1_2.png", "globalButtonUI13_1_2.png", "", 1)
        self._attackBtn:setTitleFontName(UIUtils.ttfName)
        self._attackBtn:setTitleText("攻击")
        self._attackBtn:setTitleFontSize(24) 
        self._attackBtn:ignoreContentAdaptWithSize(false)
        self._attackBtn:setPosition(345, self:getContentSize().height * 0.5)
        self._attackBtn:setAnchorPoint(0.5, 0.5)
        -- self._attackBtn:setScaleAnim(true)
        self:L10N_Text(self._attackBtn)
        self:addChild(self._attackBtn)
    end
    registerClickEvent(self._attackBtn,function() 
        if self._callback ~= nil then 
            self._callback(inUserId, false)            
        end
    end)

    if self._viewBtn == nil then
        self._viewBtn = ccui.Button:create("globalButtonUI13_3_2.png", "globalButtonUI13_3_2.png", "", 1)
        self._viewBtn:setTitleFontName(UIUtils.ttfName)
        self._viewBtn:setTitleText("查看")
        self._viewBtn:setTitleFontSize(24)
        self._viewBtn:ignoreContentAdaptWithSize(false)
        self._viewBtn:setPosition(345, self:getContentSize().height * 0.5)
        self._viewBtn:setAnchorPoint(0.5, 0.5)
        self._viewBtn:setScaleAnim(true)
        self:L10N_Text(self._attackBtn)
        self:addChild(self._viewBtn)
    end
    registerClickEvent(self._viewBtn,function() 
        if self._callback ~= nil then 
            self._callback(inUserId, true)            
        end
    end)

    if inIsFriend == true then
        self._attackBtn:setVisible(false)
        self._viewBtn:setVisible(true)
    else
        self._attackBtn:setVisible(true)
        self._viewBtn:setVisible(false)
    end
end

function GuildMapPvpUserCell:setCallback(inCallback)
    self._callback = inCallback
end

return GuildMapPvpUserCell