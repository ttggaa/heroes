--
-- Author: wangguojun
-- Date: 2016-04-12 20:45:48
--
local DialogSelectAvatar = class("DialogSelectAvatar",BasePopView)
function DialogSelectAvatar:ctor()
    self.super.ctor(self)

end

-- 初始化UI后会调用, 有需要请覆盖
function DialogSelectAvatar:onInit()
    self:registerClickEventByName("bg.closeBtn", function ()
        self:close()
        UIUtils:reloadLuaFile("main.DialogSelectAvatar")
    end)

    self._teamAvatar = {}
    self._heroAvatar = {}
    self._skinAvatar = {}
    self._allAvatar = {}
    self._scrollView = self:getUI("bg.scrollView")
    self._scrollView:setBounceEnabled(true)
    self._teamBg = self:getUI("bg.scrollView.teamBg")
    self._heroBg = self:getUI("bg.scrollView.heroBg")
    self._exBg = self._heroBg:clone()
    self._scrollView:addChild(self._exBg)

    self._frameScrollView = self:getUI("bg.frameScrollView")
    self._frameScrollView:setBounceEnabled(true)
    self._frameScrollView:setClippingType(1)
    self._frames = {}

    self._shadowsScrollView = self:getUI("bg.shadowsScrollView")
    self._shadowsScrollView:setBounceEnabled(true)
    self._shadowsScrollView:setClippingType(1)
    self._shadowsFrames = {}

    self._panels = {}
    table.insert(self._panels,self._scrollView)
    table.insert(self._panels,self._frameScrollView)
    table.insert(self._panels,self._shadowsScrollView)

    self._tabs = {}
    table.insert(self._tabs, self:getUI("bg.tab_avatar"))
    table.insert(self._tabs, self:getUI("bg.tab_frame"))
    table.insert(self._tabs, self:getUI("bg.tab_shadows"))
    self:getUI("bg.tab_frame"):setTitleText("头像框")
    
    for i=1,3 do
        -- self:registerClickEvent(self._tabs[i],function( )
        --     self:touchTab(i)
        -- end)
        UIUtils:setTabChangeAnimEnable(self._tabs[i],255,function( )
            self:touchTab(i)
        end)
    end

    local title = self:getUI("bg.title_bg.title")
    UIUtils:setTitleFormat(title, 1)

    local teamTitleName = self:getUI("bg.scrollView.teamTitle.name")
    UIUtils:setTitleFormat(teamTitleName, 3)
    teamTitleName:setString("稀有")
    self._teamTitle =  self:getUI("bg.scrollView.teamTitle")
    local heroTitleName = self:getUI("bg.scrollView.heroTitle.name")
    UIUtils:setTitleFormat(heroTitleName, 3)
    heroTitleName:setString("普通")
    self._heroTitle = self:getUI("bg.scrollView.heroTitle")
    
    self._exTitle = self._heroTitle:clone()
    self._scrollView:addChild(self._exTitle)
    local exTitleName = self._exTitle:getChildByName("name")
    UIUtils:setTitleFormat(exTitleName, 3)
    exTitleName:setString("典藏")
    

    self:initAvatar()
    self:touchTab(1)
    -- self._tabs[2]:loadTextureNormal("globalBtnUI4_page1_n.png",1)
    -- self._tabs[2]:loadTexturePressed("globalBtnUI4_page1_n.png",1)
    -- local text = self._tabs[2]:getTitleRenderer()
    -- self._tabs[2]:setTitleFontName(UIUtils.ttfName)
    -- self._tabs[2]:setTitleFontSize(28)
    -- text:disableEffect()
    -- text:setPositionX(40)
    -- self:touchTab(1)
end

function DialogSelectAvatar:touchTab( idx )
    print("========idx======="..idx)
    if self._tabIdx and self._tabIdx == idx then return end
    self._tabIdx = idx
    for i,v in ipairs(self._tabs) do
        if idx ~= i then
            self:setTabStatus(v,false)
            self._panels[i]:setVisible(false)
        end
    end
    if self._preBtn then
        UIUtils:tabChangeAnim(self._preBtn,nil,true)
    end
    self._preBtn = self._tabs[idx]
    UIUtils:tabChangeAnim(self._tabs[idx],function( )
        self:setTabStatus(self._tabs[idx],true)
    end)
    self._panels[idx]:setVisible(true)
    if idx == 2 then
        if not next(self._frames) then
            self._serverMgr:sendMsg("AvatarFramesServer","getAvatarFrameInfo",{}, true, {},function( )
                self:initFrames()
                self:reflashUI()
            end)
        end
    elseif idx == 3 then
        if not next(self._shadowsFrames) then
            self._serverMgr:sendMsg("ShadowsServer","getShadowsInfo",{}, true, {},function( )
                self:initShadowsFrames()
                self:reflashUI()
            end)
        end
    end

end

function DialogSelectAvatar:setTabStatus( sender,isSelect )
    if not isSelect then
        sender:loadTextureNormal("globalBtnUI4_page1_n.png",1)
        sender:loadTexturePressed("globalBtnUI4_page1_n.png",1)
        sender:setTitleColor(UIUtils.colorTable.ccUITabColor1)
    else
        sender:loadTextureNormal("globalBtnUI4_page1_p.png",1)
        sender:loadTexturePressed("globalBtnUI4_page1_p.png",1)
        sender:setTitleColor(UIUtils.colorTable.ccUITabColor2)
    end
end

function DialogSelectAvatar:initAvatar( )
    local teamAvatars = {}
    local heroAvatars = {}
    -- [[新逻辑 英雄兵团分类变成  普通 稀有 典藏
    local normalAvatars = {}
    local rareAvatars = {}
    local collectionAvatars = {}
    --]]
    local allAvatar = clone(tab.roleAvatar)
    local avatarsInfo = self._modelMgr:getModel("AvatarModel"):getData()
    -- dump(avatarsInfo)
    local sfc = cc.SpriteFrameCache:getInstance()
    for k,v in pairs(allAvatar) do
        if v.display == 1 then
            local have = true 
            local art = v.icon
            if not (sfc:getSpriteFrameByName(art ..".jpg") or sfc:getSpriteFrameByName(art ..".png")) then
                have = false
            end
            if have then
                if v.avtype == 1 then
                    table.insert(teamAvatars, v)
                elseif v.avtype == 2 or v.avtype == 3 then
                    table.insert(heroAvatars, v)
                end
                -- [[ 新逻辑分类
                if v.avaQuality == 1 then
                    table.insert(normalAvatars,v)
                elseif v.avaQuality == 2 then
                    table.insert(rareAvatars,v)
                elseif v.avaQuality == 3 then
                    table.insert(collectionAvatars,v)
                end
                --]]
                v.islocked = not avatarsInfo[tostring(k)]
                -- if v.avtype == 3 then
                --     local heroId = string.sub(v.unlock,2,6)
                --     v.islocked = true
                --     local heroData = self._modelMgr:getModel("HeroModel"):getHeroData(heroId or 60101)
                --     if heroData then 
                --         allSkin = heroData.allSkin 
                --         if allSkin and allSkin[tostring(v.unlock)] then
                --             v.islocked = false 
                --         end
                --     end
                -- end
            end
        end
    end
    table.sort(teamAvatars,function( a,b )
        if a.islocked == b.islocked then
            if a.unlock and b.unlock then 
                return a.unlock < b.unlock
            elseif a.unlock ~= b.unlock then
                return b.unlock 
            else
                return a.id > b.id
            end
        end
        return b.islocked or false 
    end)
    table.sort(heroAvatars,function( a,b )
        if a.islocked == b.islocked then 
            return tonumber(a.id) < tonumber(b.id)
        end
        return b.islocked or false 
    end)
    self._teamAvatar = teamAvatars
    -- dump(teamAvatars)
    self._heroAvatar = heroAvatars

    -- [[ 新分类排序
    local sortFunc = function( tableD )
        if not next(tableD) then return end
        table.sort(tableD,function( a,b )
            if a.islocked == b.islocked then
                if a.avtype == b.avtype then
                    return a.id < b.id 
                else
                    return a.avtype < b.avtype
                end
            end
            return b.islocked or false
        end)
    end
    sortFunc(normalAvatars)
    sortFunc(rareAvatars)
    sortFunc(collectionAvatars)
    --]]

    local col = 5
    local avatarSize = 100
    local maxHeight = 150 -- 两个title高40 计算
    local titleHeight = 50
    local scrollWidth = self._scrollView:getContentSize().width

    local heroBgHeight = math.ceil(#normalAvatars/col)*avatarSize+10
    maxHeight = maxHeight+heroBgHeight 

    self._heroBg:setContentSize(cc.size(scrollWidth,heroBgHeight))
    for i,v in ipairs(normalAvatars) do
        local avatar = self:createAvatar(normalAvatars[i])
        avatar:setPosition(cc.p(((i-1)%5)*avatarSize+13,heroBgHeight-math.floor((i-1)/5+1)*avatarSize+5))
        self._heroBg:addChild(avatar)
        if not v.islocked then
            table.insert(self._allAvatar,avatar)
        end
    end

    local teamBgHeight = math.ceil(#rareAvatars/col)*avatarSize+10
    maxHeight = maxHeight+teamBgHeight 

    self._teamBg:setContentSize(cc.size(scrollWidth,teamBgHeight))
    for i,v in ipairs(rareAvatars) do
        local avatar = self:createAvatar(rareAvatars[i])
        avatar:setPosition(cc.p(((i-1)%5)*avatarSize+13,teamBgHeight-math.floor((i-1)/5+1)*avatarSize+5))
        self._teamBg:addChild(avatar)
        if not v.islocked then
            table.insert(self._allAvatar,avatar)
        end
    end

    local exBgHeight = math.ceil(#collectionAvatars/col)*avatarSize+10
    maxHeight = maxHeight+exBgHeight 

    self._exBg:setContentSize(cc.size(scrollWidth,exBgHeight))
    for i,v in ipairs(collectionAvatars) do
        local avatar = self:createAvatar(collectionAvatars[i])
        avatar:setPosition(cc.p(((i-1)%5)*avatarSize+13,exBgHeight-math.floor((i-1)/5+1)*avatarSize+5))
        self._exBg:addChild(avatar)
        if not v.islocked then
            table.insert(self._allAvatar,avatar)
        end
    end

    self._scrollView:setInnerContainerSize(cc.size(scrollWidth,maxHeight))

    self._heroTitle:setPositionY(maxHeight-titleHeight/2)
    self._heroBg:setPositionY(maxHeight-titleHeight-heroBgHeight)
    self._teamBg:setPositionY(exBgHeight+titleHeight)
    self._teamTitle:setPositionY(titleHeight*1.5+teamBgHeight+exBgHeight)
    self._exBg:setPositionY(0)
    self._exTitle:setPositionY(titleHeight/2+exBgHeight)


end

function DialogSelectAvatar:initFrames( )
    -- [[ 头像框资源
    local allFrames = clone(tab.avatarFrame)
    local frames = {}
    local frameInfo = self._modelMgr:getModel("AvatarModel"):getFrameData()
    -- dump(avatarsInfo)
    local sfc = cc.SpriteFrameCache:getInstance()
    for k,v in pairs(allFrames) do
        if v.display == 1 then
            local have = true 
            local art = v.icon
            if art == "avatarFrame_0" then art = "bg_head_mainView" end
            if not (sfc:getSpriteFrameByName(art ..".jpg") or sfc:getSpriteFrameByName(art ..".png")) then
                have = false
            end
            if have then
                if GameStatic.appleExamine then
                    -- 苹果审核去掉 qq weixin 头像框
                    if (v.id ~= 1007 and v.id ~= 1016 and v.id ~= 1008 and v.id ~= 1014 and v.id ~= 1015 and v.id ~= 1022) then
                        table.insert(frames, v)
                    end
                    -- table.insert(frames, v)
                else
                    -- 分平台屏蔽 头像框
                    if sdkMgr:isWX() and v.id ~= 1007 and v.id ~= 1016 then
                        table.insert(frames, v)
                    elseif sdkMgr:isQQ() and v.id ~= 1008 then
                        table.insert(frames, v)
                    elseif OS_IS_WINDOWS then
                        table.insert(frames, v)
                    end
                end
                v.islocked = not frameInfo[tostring(k)]
            end
        end
    end
    table.sort(frames,function( a,b )
        if a.islocked == b.islocked then 
            return tonumber(a.id) < tonumber(b.id)
        end
        return b.islocked or false 
    end)

    local col = 4
    local avatarSize    = 125
    local maxHeight     = 0 -- 两个title高40 计算
    local titleHeight   = 50
    local scrollWidth   = self._frameScrollView:getContentSize().width
    local scrollHeight  = self._frameScrollView:getContentSize().height
    local heroBgHeight  = math.ceil(#frames/col)*(avatarSize+20)+10
    maxHeight = maxHeight+heroBgHeight 
    maxHeight = math.max(maxHeight,scrollHeight)
    self._frameScrollView:setInnerContainerSize(cc.size(scrollWidth,maxHeight))
    for i,v in ipairs(frames) do
        local avatar = self:createAvatarFrame(frames[i])
        avatar:setPosition(((i-1)%col)*avatarSize+15,maxHeight-math.floor((i-1)/col+1)*(avatarSize+20)+25)
        self._frameScrollView:addChild(avatar)
        if not v.islocked then
            table.insert(self._frames,avatar)
        end
    end
    self._frameScrollView:getInnerContainer():setPositionY(scrollHeight-maxHeight)
    -- self._frameScrollView:scrollToPercentVertical(0, 0, false)
    --]]
end

function DialogSelectAvatar:initShadowsFrames()
    -- [[ 头像框资源
    local allFrames = clone(tab.heroShadow)
    local frames = {}
    local frameInfo = self._modelMgr:getModel("ShadowsModel"):getShadowsFrame() or  {}
    -- dump(avatarsInfo)
    local sfc = cc.SpriteFrameCache:getInstance()
    for k,v in pairs(allFrames) do
        if v.display == 1 then
            local have = true 
            local art = v.icon
            if art == "avatarFrame_0" then art = "bg_head_mainView" end
            if not (sfc:getSpriteFrameByName(art ..".jpg") or sfc:getSpriteFrameByName(art ..".png")) then
                have = false
            end
            table.insert(frames, v)
            v.islocked = not frameInfo[tostring(k)]
        end
    end
    table.sort(frames,function( a,b )
        if a.islocked == b.islocked then 
            return tonumber(a.id) < tonumber(b.id)
        end
        return b.islocked or false 
    end)

    local col = 4
    local avatarSize    = 125
    local maxHeight     = 0 -- 两个title高40 计算
    local titleHeight   = 50
    local scrollWidth   = self._shadowsScrollView:getContentSize().width
    local scrollHeight  = self._shadowsScrollView:getContentSize().height
    local heroBgHeight  = math.ceil(#frames/col)*(avatarSize+20)+10
    maxHeight = maxHeight+heroBgHeight 
    maxHeight = math.max(maxHeight,scrollHeight)
    self._shadowsScrollView:setInnerContainerSize(cc.size(scrollWidth,maxHeight))
    for i,v in ipairs(frames) do
        local avatar = self:createShadowFrame(frames[i])
        avatar:setPosition(((i-1)%col)*avatarSize+15,maxHeight-math.floor((i-1)/col+1)*(avatarSize+20)+25)
        self._shadowsScrollView:addChild(avatar)
        if not v.islocked then
            table.insert(self._shadowsFrames,avatar)
        end
    end
    self._shadowsScrollView:getInnerContainer():setPositionY(scrollHeight-maxHeight)
    -- self._frameScrollView:scrollToPercentVertical(0, 0, false)
    --]]
end



function DialogSelectAvatar:createAvatar( data )
    local bgNode = ccui.Widget:create()
    bgNode:setContentSize(cc.size(80,80))
    bgNode:setAnchorPoint(cc.p(0,0))
    bgNode._data = data
    local fu = cc.FileUtils:getInstance()
    local icon = ccui.ImageView:create()
    local sfc = cc.SpriteFrameCache:getInstance()
    local art = data.icon
    if sfc:getSpriteFrameByName(art ..".jpg") then
        icon:loadTexture("" .. art ..".jpg", 1)
    elseif sfc:getSpriteFrameByName(art ..".png") then
        icon:loadTexture("" .. art ..".png", 1) 
    else
        print("头像资源是空...",art)
    end
    icon:ignoreContentAdaptWithSize(false)
    icon:setContentSize(cc.size(78,78))
    icon:setAnchorPoint(cc.p(0,0))
    icon:setPosition(cc.p(0,0))
    bgNode:addChild(icon)
    local frame = ccui.ImageView:create()
    local quality = data.avaQuality and (data.avaQuality+1) or 1
    frame:loadTexture("globalImageUI4_squality" .. quality .. ".png",1) 
    frame:setContentSize(cc.size(90,90))
    frame:ignoreContentAdaptWithSize(false)
    frame:setPosition(cc.p(-6,-6))
    frame:setAnchorPoint(cc.p(0,0))
    bgNode:addChild(frame,1)

    -- 头像特效
    if icon.__shine then 
        icon.__shine:removeFromParent()
        icon.__shine = nil
    end
    if data.islocked then
        bgNode:setSaturation(-180)
    else
        -- 添加头像特效   
        local shineData = data.shine
        if shineData then 
            local realWidth = 82   -- 头像图片真实宽度                       
            icon.__shine = IconUtils:addHeadFrameMc(icon,shineData[1],data.effect ,icon:getContentSize().width/realWidth,true) 
        end
    end
    -- 头像  未获得弹tips    hgf 17.02.25
    self:registerClickEvent(bgNode,function( )
        if self._inDraging then return end
        if data.islocked then
            self._viewMgr:showTip(lang(data.tips))
            return 
        end
        if bgNode._data.id == self._modelMgr:getModel("UserModel"):getData().avatar then
            return 
        end
        self._viewMgr:showDialog("global.GlobalSelectDialog",{desc = "是否选择该头像？",callback1 = function( )
            self._serverMgr:sendMsg("AvatarsServer","setAvatar",{id = data.id}, true, {},function( )
                self:reflashUI()
            end)
        end})
    end)
    bgNode:setSwallowTouches(false)

    return bgNode
end

function DialogSelectAvatar:createAvatarFrame( data )

    local param = {itemId = data.id,itemData = data ,eventStyle = 0}
    local bgNode = IconUtils:createHeadFrameIconById(param)
    bgNode._data = data

    local nameLab = ccui.Text:create()
    nameLab:setFontSize(20)
    nameLab:setFontName(UIUtils.ttfName)
    nameLab:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    nameLab:setString(lang(data.name))
    nameLab:setPosition(bgNode:getContentSize().width*0.5,-15)
    bgNode:addChild(nameLab)

    if data.islocked then
        bgNode:setSaturation(-180)
        local iconColor = bgNode:getChildByName("iconColor")
        if iconColor then
            local bgMc = iconColor:getChildByName("bgMc")
            if bgMc then
                bgMc:removeFromParent()
            end
        end
    end
    self:registerClickEvent(bgNode,function( )
        if self._inDraging then return end
        if bgNode._data.islocked then
            self._viewMgr:showTip(lang(bgNode._data.tips))
            return 
        end
        if bgNode._data.id == self._modelMgr:getModel("UserModel"):getData().avatarFrame then
            return 
        end
        -- self._viewMgr:showDialog("global.GlobalSelectDialog",{desc = "是否选择该头像框？",callback1 = function( )
            self._serverMgr:sendMsg("AvatarFramesServer","setAvatarFrame",{id = data.id}, true, {},function( )
                self:reflashUI()
            end)
        -- end})
    end)
    bgNode:setSwallowTouches(false)

    return bgNode
end

function DialogSelectAvatar:createShadowFrame(data)
    dump(data,"========data===========")
    local param = {itemData = data ,eventStyle = 0}
    
    local shadowNode = IconUtils:createShadowIcon(param)
    shadowNode.iconColor.nameLab:setVisible(false)
    shadowNode._data = data

    -- 头像特效
    if shadowNode.itemIcon.__shine then 
        shadowNode.itemIcon.__shine:removeFromParent()
        shadowNode.itemIcon.__shine = nil
    end
    if data.islocked then
        shadowNode:setSaturation(-180)
    else
        -- 添加头像特效   
        local shineData = data.shine
        if shineData then 
            local realWidth = 82   -- 头像图片真实宽度                       
            shadowNode.itemIcon.__shine = IconUtils:addHeadFrameMc(icon,shineData[1],data.effect ,icon:getContentSize().width/realWidth,true) 
        end
    end


    local nameLab = ccui.Text:create()
    nameLab:setFontSize(20)
    nameLab:setFontName(UIUtils.ttfName)
    nameLab:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    nameLab:setString(lang(data.name))
    nameLab:setPosition(shadowNode:getContentSize().width*0.5,-15)
    shadowNode:addChild(nameLab)

    if data.islocked then
        shadowNode:setSaturation(-180)
        local iconColor = shadowNode.iconColor
        if iconColor then
            local bgMc = iconColor:getChildByName("bgMc")
            if bgMc then
                bgMc:removeFromParent()
            end
        end
    end
    self:registerClickEvent(shadowNode,function( )
        if self._inDraging then return end
        if shadowNode._data.islocked then
            self._viewMgr:showTip(lang(shadowNode._data.tips))
            return 
        end
        local isSet = 1
        if shadowNode._data.id == self._modelMgr:getModel("ShadowsModel"):getSelectedShadowId() then
            isSet = 0 
        end

        self._serverMgr:sendMsg("ShadowsServer","setShadow",{id = data.id,isSet = isSet}, true, {},function( )
            self:reflashUI()
        end)
    end)
    shadowNode:setSwallowTouches(false)

    return shadowNode
end

-- 接收自定义消息
function DialogSelectAvatar:reflashUI(data)
    for k,v in pairs(self._allAvatar) do
        if v._data and v._data.id == self._modelMgr:getModel("UserModel"):getData().avatar and not v:getChildByName("tag") then
            local selectNode = ccui.Widget:create()
            local tag = ccui.ImageView:create()
            tag:loadTexture("globalImageUI6_connerTag_r.png",1)
            tag:setFlippedX(true)
            selectNode:addChild(tag)
            local name = ccui.Text:create()
            name:setString("当前")
            name:setFontName(UIUtils.ttfName)
            -- name:setColor(cc.c3b(255, 243, 121))
            name:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
            name:setFontSize(22)
            name:setRotation(-41)
            name:setPosition(-12,6)
            selectNode:addChild(name)
            selectNode:setName("tag")
            selectNode:setPosition(cc.p(22,61))
            selectNode:setScale(0.8)
            v:addChild(selectNode,99) 
        else
            if v:getChildByName("tag") and v._data.id ~= self._modelMgr:getModel("UserModel"):getData().avatar then
                v:getChildByName("tag"):removeFromParent()
            end
        end
    end

    for k,v in pairs(self._frames) do
        if v._data and v._data.id == self._modelMgr:getModel("UserModel"):getData().avatarFrame and not v:getChildByName("tag") then
            local selectNode = ccui.Widget:create()
            local tag = ccui.ImageView:create()
            tag:loadTexture("globalImageUI_duigou.png",1)
            -- tag:setFlippedX(true)
            selectNode:addChild(tag)
            -- local name = ccui.Text:create()
            -- name:setString("当前")
            -- name:setFontName(UIUtils.ttfName)
            -- -- name:setColor(cc.c3b(255, 243, 121))
            -- -- name:enableOutline(cc.c4b(146,19,5,255),3)
            -- name:setFontSize(22)
            -- name:setRotation(-41)
            -- name:setPosition(-12,6)
            -- selectNode:addChild(name)
            selectNode:setName("tag")
            selectNode:setPosition(cc.p(55,55))
            -- selectNode:setScale(0.8)
            v:addChild(selectNode,99) 
        else
            if v:getChildByName("tag") and v._data.id ~= self._modelMgr:getModel("UserModel"):getData().avatarFrame then
                v:getChildByName("tag"):removeFromParent()
            end
        end
    end

    for k,v in pairs(self._shadowsFrames) do
        if v._data and v._data.id == self._modelMgr:getModel("ShadowsModel"):getSelectedShadowId() and not v:getChildByName("tag") then
            local selectNode = ccui.Widget:create()
            local tag = ccui.ImageView:create()
            tag:loadTexture("globalImageUI_duigou.png",1)
            -- tag:setFlippedX(true)
            selectNode:addChild(tag)
            -- local name = ccui.Text:create()
            -- name:setString("当前")
            -- name:setFontName(UIUtils.ttfName)
            -- -- name:setColor(cc.c3b(255, 243, 121))
            -- -- name:enableOutline(cc.c4b(146,19,5,255),3)
            -- name:setFontSize(22)
            -- name:setRotation(-41)
            -- name:setPosition(-12,6)
            -- selectNode:addChild(name)
            selectNode:setName("tag")
            selectNode:setPosition(cc.p(55,55))
            -- selectNode:setScale(0.8)
            v:addChild(selectNode,99) 
        else
            if v:getChildByName("tag") and v._data.id ~= self._modelMgr:getModel("ShadowsModel"):getSelectedShadowId() then
                v:getChildByName("tag"):removeFromParent()
            end
        end
    end
end

return DialogSelectAvatar