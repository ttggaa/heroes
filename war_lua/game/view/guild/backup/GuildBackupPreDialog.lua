--[[
    Filename:    GuildBackupPreDialog.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2016-05-27 19:56:59
    Description: File description
--]]

local GuildBackupPreDialog = class("GuildBackupPreDialog",BasePopView)
function GuildBackupPreDialog:ctor(param)
    self.super.ctor(self)
    self._callback = param.callback
end

-- 初始化UI后会调用, 有需要请覆盖
function GuildBackupPreDialog:onInit()
    self._scrollView = self:getUI("bg.scrollview")
    self._scrollView:setBounceEnabled(true)
    self.scrollViewW = self._scrollView:getContentSize().width
    self.scrollViewH = self._scrollView:getContentSize().height
    self._title = self:getUI("bg.title")
    UIUtils:setTitleFormat(self._title, 7)
    
    -- self._itemBg_0 = self:getUI("bg.itemBg_0")
    -- self._itemBg_0:setColor(cc.c3b(66, 66, 66))
    self._item = self:getUI("itemPanel")
    self._item:setVisible(false)

    -- local mask = cc.Sprite:createWithSpriteFrameName("globalPanelUI7_roleBg.png")
    -- mask:setPosition(self._item:getContentSize().width/2, self._item:getContentSize().height/2)
    -- local Clip = cc.ClippingNode:create()
    -- Clip:setInverted(false)
    -- Clip:setStencil(mask)
    -- Clip:setAlphaThreshold(0.1)
    -- Clip:setAnchorPoint(cc.p(0,0))
    -- Clip:setName("clipNode")
    -- self._item:addChild(Clip,20)
    
    self:registerClickEventByName("bg.closeBtn",function( )
        UIUtils:reloadLuaFile("guild.backup.GuildBackupPreDialog")
        self:close()
    end)
end

-- 接收自定义消息
function GuildBackupPreDialog:reflashUI(data)
    local goodsData = self._modelMgr:getModel("TeamModel"):getTeamDataByZizhi()
    self._scrollView:removeAllChildren()
    self._scrollView:setInnerContainerSize(cc.size(self.scrollViewW,self.scrollViewH))

    local itemSizeX,itemSizeY = 200,255
    local offsetX,offsetY = 3,0
    local col = 4 --math.ceil(#goodsData/2) --4
    local row = math.ceil(#goodsData/col)
    local boardHeight = row*itemSizeY+20
    if boardHeight < self.scrollViewH then
        boardHeight = self.scrollViewH 
    else
        self._scrollView:setInnerContainerSize(cc.size(self.scrollViewW,boardHeight))
    end
    -- print("row,",row,math.ceil(#goodsData/col),#goodsData,boardHeight,self.scrollViewH)
    -- local boardWidth = math.ceil(#goodsData/col)*itemSizeX
    -- if boardWidth > self.scrollViewW then
    --     self._scrollView:setInnerContainerSize(cc.size(boardWidth+20,self.scrollViewH))
    --     self:showArrow("right")
    -- end
    local x,y = 0,0
    local goodsCount = #goodsData--math.max(8,row*col)
    -- self:lock()
    -- dump(goodsData)
    for i=1,goodsCount do
        x =  (i-1)%col*itemSizeX+offsetX
        y = boardHeight - math.floor((i-1)/col+1)*itemSizeY+offsetY
        if goodsData[i] then
            self:createItem( goodsData[i],x,y,i)
        end
    end
    -- self:unlock()
end

function GuildBackupPreDialog:createItem(data,x,y,idx)
    local teamD = tab:Team(data.teamId)
    local teamIcon = self._item:clone()
    teamIcon:setVisible(true)
    -- teamIcon:setScale(70/teamIcon:getContentSize().width)
    teamIcon:setPosition(cc.p(x,y))
    -- teamIcon:loadTexture("globalPanelUI7_roleBg.png")
    self._scrollView:addChild(teamIcon)
    local name = teamIcon:getChildByFullName("name") --ccui.Text:create()
    name:setFontName(UIUtils.ttfName)
    name:setString(lang(teamD.name))
    -- name:setFontSize(22)
    -- name:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    -- name:setPosition(cc.p(x+teamIcon:getContentSize().width/2,y-5))
    -- self._scrollView:addChild(name)
    -- local color = teamD.color or 1
    -- name:setColor(UIUtils.colorTable["ccColorQuality" .. color])
    -- name:enableOutline(UIUtils.colorTable["ccColorQualityOutLine" .. color],1)
    -- name:setFontName(UIUtils.ttfName)

    local teamImg = ccui.ImageView:create()
    local filename = "asset/uiother/steam/" .. teamD.steam .. ".png"
    local fu = cc.FileUtils:getInstance()
    if not fu:isFileExist(filename) then
        filename = "asset/uiother/steam/" .. teamD.steam .. ".jpg"
    end
    teamImg:setAnchorPoint(cc.p(0.5,0))
    teamImg:loadTexture(filename)
    local width,height = teamImg:getContentSize().width,teamImg:getContentSize().height
    local tW,tH = teamIcon:getContentSize().width,teamIcon:getContentSize().height
    local offsetX = tW*0.5+7
    -- if 804 == data.teamId then --蜥蜴位置 回退
    --    offsetX = offsetX + 5
    -- end
    teamImg:setPosition(offsetX,40)
    local scale = math.min(150/width,150/height)
    teamImg:setScale(0.5)
    -- if teamIcon:getChildByName("clipNode") then
    --     teamIcon:getChildByName("clipNode"):addChild(teamImg, 1)
    -- else
    --     teamIcon:addChild(teamImg, 1)
    -- end
    teamIcon:addChild(teamImg, 12)
    

    -- 创建星星
    local starNum = data.star
    local teamstar = teamIcon:getChildByFullName("backStar")
    if teamstar then
        teamstar:loadTexture("globalImageUI6_cardteamStar" .. starNum .. ".png",1)
    end

    --裁剪框

    -- local mask = cc.Sprite:createWithSpriteFrameName("globalPanelUI7_roleBg.png")
    -- mask:setPosition(teamIcon:getContentSize().width/2, teamIcon:getContentSize().height/2)
    -- local Clip = cc.ClippingNode:create()
    -- Clip:setInverted(false)
    -- Clip:setStencil(mask)
    -- Clip:setAlphaThreshold(0.1)
    -- Clip:setAnchorPoint(cc.p(0,0))
    -- teamIcon:addChild(Clip,20)

    -- Clip:addChild(teamImg)

    -- local backStar = teamIcon:getChildByFullName("backStar")
    -- local sfc = cc.SpriteFrameCache:getInstance()
    -- local spriteFrame = sfc:getSpriteFrameByName("alliancebackup_img1.png")
    -- local rect = spriteFrame:getRect()
    -- local isRotated = spriteFrame:isRotated()
    -- local widthO,heightO = rect.width,rect.height
    -- local width,height = rect.width,rect.height
    -- if isRotated then
    --     width,height = height,width
    --     width = width*starNum/6
    -- else
    --     height = height*starNum/6
    -- end
    -- local srect = cc.rect(rect.x+widthO-width,rect.y,width,height)
    -- srect = cc.rect(rect.x,rect.y,width,height)
    -- local starImg = cc.Sprite:createWithTexture(spriteFrame:getTexture(),srect) 
    -- -- starImg:setTextureRect(cc.rect(0,0,57,57))
    -- starImg:setAnchorPoint(cc.p(0.5,1))
    -- starImg:setPosition(cc.p(backStar:getPositionX(),backStar:getPositionY()))
    -- if isRotated then
    --     starImg:setRotation(270)
    -- end
    -- teamIcon:addChild(starImg,10)

    -- self:showStar(name, data.star)
    local tW,tH = teamIcon:getContentSize().width,teamIcon:getContentSize().height
    local dizuoImg = ccui.ImageView:create()
    dizuoImg:loadTexture("asset/uiother/dizuo/teamBgDizuo" .. teamD.race[1] .. ".png", 0)
    dizuoImg:setScale(0.6)
    dizuoImg:setAnchorPoint(cc.p(0.5,0))
    dizuoImg:setPosition(tW/2,20)
    teamIcon:addChild(dizuoImg,11)

    local downY,clickFlag
    registerTouchEvent(
        teamIcon,
        function (_, _, y)
            downY = y
            clickFlag = false
            
        end, 
        function (_, _, y)
            if downY and math.abs(downY - y) > 5 then
                clickFlag = true
            end
        end, 
        function ()
            if self._callback ~= nil and clickFlag == false then 
                if self._callback then
                    self._callback(data.teamId)
                end
                self:close()
            end
        end,
        function ()
        end)

    return teamIcon
end

-- local starInfos = {
--     {{pos = cc.p(0,-8),scale = 1}},
--     {{pos = cc.p(-15,-8),scale = 0.9},{pos = cc.p(15,-8),scale = 0.9}},
--     {{pos = cc.p(-20,-8),scale = 0.8},{pos = cc.p(0,-8),scale = 1},{pos = cc.p(20,-8),scale = 0.8}},
--     {{pos = cc.p(-20,-8),scale = 0.8},{pos = cc.p(0,-8),scale = 1},{pos = cc.p(20,-8),scale = 0.8}},
--     {{pos = cc.p(-20,-8),scale = 0.8},{pos = cc.p(0,-8),scale = 1},{pos = cc.p(20,-8),scale = 0.8}},
--     {{pos = cc.p(-20,-8),scale = 0.8},{pos = cc.p(0,-8),scale = 1},{pos = cc.p(20,-8),scale = 0.8}},
-- }

-- function DialogFlashPreView:showStar( view,starlevel )
--     if not tonumber(starlevel) then return end
--     local starInfo = starInfos[starlevel]
--     local bgW,bgH = view:getContentSize().width,view:getContentSize().height
--     for i,info in ipairs(starInfo) do
--         local star = ccui.ImageView:create()
--         star:loadTexture("globalImageUI6_star1.png",1)
--         star:setPosition(cc.p(info.pos.x+bgW/2,info.pos.y+bgH/2-15))
--         star:setAnchorPoint(cc.p(0.5,0.5))
--         star:setScale(0.5)
--         view:addChild(star)
--     end
-- end
return GuildBackupPreDialog   