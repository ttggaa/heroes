--[[
    Filename:    GuildSelectFlagsDialog2.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2016-05-05 20:47:49
    Description: File description
--]]

local GuildSelectFlagsDialog = class("GuildSelectFlagsDialog",BasePopView)
function GuildSelectFlagsDialog:ctor(param)
    self.super.ctor(self)
    -- if param and param.create then
    self._isCreate = param.create
    self._callback = param.callback
    -- end
end

-- 初始化UI后会调用, 有需要请覆盖5
function GuildSelectFlagsDialog:onInit()
    local closeBtn = self:getUI("bg.closeBtn")
    self:registerClickEvent(closeBtn, function( )
        if OS_IS_WINDOWS then
            UIUtils:reloadLuaFile("guild.dialog.GuildSelectFlagsDialog")
        end
        self:close()
    end)
    self._scrollView = self:getUI("bg.scrollView")
    self._scrollView:setBounceEnabled(true)
    -- local maxHeight = 0
    -- local flagsBg = self._scrollView:getChildByFullName("flagsBg")
    -- local flagsBgHeight = flagsBg:getContentSize().height
    -- local logoBg = self._scrollView:getChildByFullName("logoBg")
    -- local flagHeight = logoBg:getContentSize().height

    -- local qizi1 = cc.Scale9Sprite:createWithSpriteFrameName("globalPanelUI6_qianBg50_50.png")
    -- qizi1:setContentSize(90, 90)
    -- addChild(qizi1)

    local title = self:getUI("bg.title_bg.title")
    UIUtils:setTitleFormat(title, 1)

    self._logoAvatar = {}
    self._flagsAvatar = {}
    self._allAvatar = {}
    self._flagsBg = self:getUI("bg.scrollView.flagsBg")
    self._logoBg = self:getUI("bg.scrollView.logoBg")
    self._scrollView = self:getUI("bg.scrollView")

    local flagsTitleName = self:getUI("bg.scrollView.flagsTitle.name")
    UIUtils:setTitleFormat(flagsTitleName, 3, 1)

    self._flagsTitle =  self:getUI("bg.scrollView.flagsTitle")
    local logoTitleName = self:getUI("bg.scrollView.logoTitle.name")
    UIUtils:setTitleFormat(logoTitleName, 3, 1)
    self._logoTitle = self:getUI("bg.scrollView.logoTitle")

    self:initAvatar()

    local saveBtn = self:getUI("bg.saveBtn")
    self:registerClickEvent(saveBtn,function( )
        print("==eself._isCreate======",self._selectFlags, self._selectLogo)
        local param = {avatar1 = self._selectFlags, avatar2 = self._selectLogo}
        if self._isCreate then self._callback(param) self:close() return end
        self._serverMgr:sendMsg("GuildServer","changeAvatar", param, true, {}, function()
            print("换旗子 ==============")
            self._callback(param)
            self:close()
        end)
    end)

    -- local qizi = CCScale9Sprite:create(file, rect)

    -- maxHeight = maxHeight + flagBgHeight + flagHeight 
    -- self._scrollView:setInnerContainerSize(cc.size(self._scrollView:getContentSize().width, maxHeight))
end

function GuildSelectFlagsDialog:initAvatar()
    local logoAvatars = {}
    local flagsAvatars = {} 
    local allAvatar = clone(tab.guildFlag)
    local avatarsInfo = self._modelMgr:getModel("AvatarModel"):getGuildAvatar()

    for k,v in pairs(allAvatar) do
        -- if v.display == 1 then
            if v.type == 2 then
                table.insert(logoAvatars, v)
            else
                table.insert(flagsAvatars, v)
            end
            -- v.islocked = not avatarsInfo[tostring(k)]
        -- end
    end
    -- table.sort(logoAvatars,function(a,b)
    --     if a.islocked == b.islocked then 
    --         return a.unlock < b.unlock
    --     end
    --     return b.islocked or false 
    -- end)
    -- table.sort(flagsAvatars,function( a,b )
    --     if a.islocked == b.islocked then 
    --         return a.unlock < b.unlock
    --     end
    --     return b.islocked or false 
    -- end)
    self._logoAvatar = logoAvatars
    self._flagsAvatar = flagsAvatars
    local col = 4
    local avatarSize = 100
    local avatarHeigh = 110
    local maxHeight = 0 -- 两个title高40 计算
    local titleHeight = 50
    local scrollWidth = self._scrollView:getContentSize().width-10

    local flagsBgHeight = math.ceil(#flagsAvatars/col)*avatarHeigh+40
    maxHeight = maxHeight+flagsBgHeight 

    self._flagsBg:setContentSize(cc.size(scrollWidth,flagsBgHeight))
    -- 旗面
    for i,v in ipairs(flagsAvatars) do
        local avatar = self:createAvatar(flagsAvatars[i])
        avatar:setPosition(cc.p(((i-1)%col)*(avatarSize+12)+22,flagsBgHeight-math.floor((i-1)/col+1)*(avatarHeigh)-35))
        -- avatar:setScale(0.9)
        self._flagsBg:addChild(avatar)
        if not v.islocked then
            table.insert(self._allAvatar,avatar)
        end
    end

    local logoBgHeight = math.ceil(#logoAvatars/col)*avatarHeigh+60
    maxHeight = maxHeight+logoBgHeight 

    self._logoBg:setContentSize(cc.size(scrollWidth,logoBgHeight))
    -- 标志
    for i,v in ipairs(logoAvatars) do
        local avatar = self:createAvatar(logoAvatars[i])
        avatar:setPosition(cc.p(((i-1)%col)*(avatarSize+12)+20,logoBgHeight-math.floor((i-1)/col+1)*avatarHeigh-45))
        self._logoBg:addChild(avatar)
        if not v.islocked then
            table.insert(self._allAvatar,avatar)
        end
    end

    self._scrollView:setInnerContainerSize(cc.size(scrollWidth,maxHeight))

    -- self._flagsTitle:setPositionY(maxHeight-titleHeight/2)
    self._flagsBg:setPositionY(maxHeight-flagsBgHeight)
    self._logoBg:setPositionY(maxHeight-flagsBgHeight-logoBgHeight)

    local titleFlag = self._flagsBg:getChildByFullName("title")
    titleFlag:setPositionY(flagsBgHeight-20)
    self._flagsBg:getChildByFullName("Image_214"):setPositionY(flagsBgHeight-20)
    self._flagsBg:getChildByFullName("Image_215"):setPositionY(flagsBgHeight-20)

    local titleLogo = self._logoBg:getChildByFullName("title")
    titleLogo:setPositionY(logoBgHeight - 20)
    self._logoBg:getChildByFullName("Image_215_0"):setPositionY(logoBgHeight-20)
    self._logoBg:getChildByFullName("Image_214_0"):setPositionY(logoBgHeight-20)
    -- self._logoTitle:setPositionY(titleHeight/2+logoBgHeight)
    
end 

function GuildSelectFlagsDialog:createAvatar(data)
    local bgNode = ccui.Widget:create()
    bgNode:setAnchorPoint(cc.p(0,0))
    bgNode:setName("bgNode" .. data.id)
    bgNode:setContentSize(cc.size(110,110))
    -- if data.type == 1 then
        -- bgNode:setContentSize(cc.size(110,110))
    -- else
    --     bgNode:setContentSize(cc.size(110,110))
    -- end
    bgNode._data = data
    local fu = cc.FileUtils:getInstance()
    local icon = ccui.ImageView:create()
    local sfc = cc.SpriteFrameCache:getInstance()
    local art = data.pic


    if sfc:getSpriteFrameByName(art ..".jpg") then
        icon:loadTexture("" .. art ..".jpg", 1)
    else
        icon:loadTexture("" .. art ..".png", 1) 
    end
    -- icon:ignoreContentAdaptWithSize(false)
    -- icon:setContentSize(cc.size(78,78))
    icon:setAnchorPoint(cc.p(0,0))
    -- icon:setAnchorPoint(cc.p(0.5, 0.5))
    if data.type == 1 then
        icon:setPosition(cc.p(0, 0))
    else
        icon:setPosition(cc.p(0, -10))
    end
    
    icon:setScale(0.8)
    bgNode:addChild(icon, 1)
    if data.type == 1 then --旗子
        self:registerClickEvent(bgNode,function()
            local tempNode = self._flagsBg:getChildByName("bgNode" .. self._selectFlags)
            self:setSelect(tempNode, false, 1)
            self._selectFlags = data.id
            self:setSelect(bgNode, true, 1)
            print("================", self._selectFlags)
        end)
    else
        self:registerClickEvent(bgNode,function()
            local tempNode = self._logoBg:getChildByName("bgNode" .. self._selectLogo)
            self:setSelect(tempNode, false, 2)
            self._selectLogo = data.id
            self:setSelect(bgNode, true, 2)
            print("================", self._selectLogo)
        end)

        local inTipBg = cc.Scale9Sprite:createWithSpriteFrameName("flag_bg.png")
        inTipBg:setAnchorPoint(cc.p(0, 0))
        inTipBg:setColor(cc.c3b(166,166,166))
        inTipBg:setPosition(cc.p(0, 0))
        -- inTipBg:setCapInsets(cc.rect(25, 25, 1, 1))
        inTipBg:setContentSize(cc.size(90, 98))
        bgNode:addChild(inTipBg)
    end
    return bgNode
end 

-- 选择框
function GuildSelectFlagsDialog:setSelect(bgNode, flag, type)
    local flagsSelect = bgNode:getChildByName("flagsSelect")
    if flagsSelect then
        flagsSelect:setVisible(flag)
    else
        -- flagsSelect = cc.Sprite:createWithSpriteFrameName("globalImageUI4_selectFrame.png")
        flagsSelect = cc.Scale9Sprite:createWithSpriteFrameName("globalImageUI_checkImg.png")
        flagsSelect:setAnchorPoint(cc.p(0.5, 0.5))
        -- flagsSelect:setPosition(55, 55)
        flagsSelect:setScale(0.8)
        flagsSelect:setName("flagsSelect")
        flagsSelect:setPosition(0,0)
        bgNode:addChild(flagsSelect,2)
        flagsSelect:setVisible(flag)
    end

    local flagsSelectBg = bgNode:getChildByName("flagsSelectBg")
    if flagsSelectBg then
        flagsSelectBg:setVisible(flag)
    else
        -- flagsSelect = cc.Sprite:createWithSpriteFrameName("globalImageUI4_selectFrame.png")
        flagsSelectBg = cc.Scale9Sprite:createWithSpriteFrameName("select_frame.png")
        -- flagsSelectBg:setAnchorPoint(cc.p(0.5, 0.5))
        -- flagsSelectBg:setPosition(55, 55)
        -- flagsSelectBg:setScale(0.8)
        flagsSelectBg:setName("flagsSelectBg")
        bgNode:addChild(flagsSelectBg,1)
        flagsSelectBg:setVisible(flag)
    end

    if type == 1 then
        -- flagsSelect:setSpriteFrame("alliance_qizi_xuanzhong.png")
        -- flagsSelect:setContentSize(cc.size(150, 166))
        -- flagsSelect:setCapInsets(cc.rect(25, 25, 1, 1))
        flagsSelectBg:setContentSize(cc.size(84,100))
        flagsSelect:setPosition(46, 53)
        flagsSelectBg:setPosition(45, 53)
    else
        -- flagsSelect:setContentSize(cc.size(132, 132))
        -- flagsSelect:setCapInsets(cc.rect(25, 25, 1, 1))
        flagsSelectBg:setContentSize(cc.size(90,98))
        flagsSelect:setPosition(46, 57)
        flagsSelectBg:setPosition(45, 50)
    end
    self:updateFlag()
end 

function GuildSelectFlagsDialog:reflashUI(data)
    local allianceDetail = self._modelMgr:getModel("GuildModel"):getAllianceDetail()
    -- dump(allianceDetail)
    if self._isCreate then
        local acatar = data["acatar"]
        self._selectFlags = acatar["avatar1"]
        self._selectLogo = acatar["avatar2"]
    else
        self._selectFlags = allianceDetail.avatar1
        self._selectLogo = allianceDetail.avatar2
    end

    local tempNode = self._flagsBg:getChildByName("bgNode" .. self._selectFlags)
    -- if tempNode then
        self:setSelect(tempNode, true, 1)
    -- end
    
    local tempNode = self._logoBg:getChildByName("bgNode" .. self._selectLogo)
    -- if tempNode then
        self:setSelect(tempNode, true, 2)
    -- end
end 

function GuildSelectFlagsDialog:updateFlag()
    local iconBg = self:getUI("bg.iconBg")
    local avatarIcon = iconBg:getChildByName("avatarIcon")

    local param = {flags = self._selectFlags, logo = self._selectLogo}
    if not avatarIcon then
        avatarIcon = IconUtils:createGuildLogoIconById(param)
        avatarIcon:setPosition(0, 0)
        avatarIcon:setName("avatarIcon")
        -- avatarIcon:setScale(1.2)
        iconBg:addChild(avatarIcon)
    else
        IconUtils:updateGuildLogoIconByView(avatarIcon, param)
    end
end 


return GuildSelectFlagsDialog