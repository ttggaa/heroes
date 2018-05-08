--[[
    Filename:    DialogFlashPreView.lua
    Author:      <wangguojun@playcrab.com>
    Datetime:    2016-01-20 15:45:27
    Description: File description
--]]
local choukashowTab = clone(tab.choukashow)
local NewFormationIconView = require("game.view.formation.NewFormationIconView")
local DialogFlashPreView = class("DialogFlashPreView",BasePopView)
function DialogFlashPreView:ctor()
    self.super.ctor(self)
    self._showData = {}
    for k,v in ipairs(tab.choukashow) do
        if not self._showData[tonumber(v.race)] then
            self._showData[tonumber(v.race)] = {}
        end
    	table.insert(self._showData[tonumber(v.race)],v)
    end
    self._idx2RaceMap = {

    }
    -- table.sort(self._showData,function( a,b )
    -- 	return a.id < b.id
    -- end)
    dump(self._showData,"showData....====------$$$$$$")

end

function DialogFlashPreView:getAsyncRes()
    return 
    {
        -- {"asset/ui/arena.plist", "asset/ui/arena.png"},
        -- {"asset/ui/nests.plist", "asset/ui/nests.png"},
    }
end

-- 初始化UI后会调用, 有需要请覆盖
function DialogFlashPreView:onInit()
	
    self._item = self:getUI("item")
    self._item:setVisible(false)
    self._tabBtn = self:getUI("tabBtn")
    self._tabBtn:setVisible(false)
    local notClose = false
    self:registerClickEventByName("bg.closeBtn",function( )
        if not notClose then
            self:close()
            notClose = true
            UIUtils:reloadLuaFile("flashcard.DialogFlashPreView")
        end
    end)
    self:getUI("bg.closeBtn"):setZOrder(100)
    self:getUI("bg.leftTableBg"):setZOrder(100)

    local beginX,beginY
    local touchInEffect
    self._closePanel = self:getUI("closePanel")
    self._closePanel:setZOrder(0)
        

    -- 加上下箭头
    -- self._leftTableBg = self:getUI("bg.leftTableBg")
    -- self._upArrow = mcMgr:createViewMC("chaoxuejiantou1_teamnatureanim", true, false)
    -- self._upArrow:setPosition(22, self._leftTableBg:getContentSize().height - 80)
    -- self._leftTableBg:addChild(self._upArrow, 5)

    -- self._downArrow = mcMgr:createViewMC("chaoxuejiantou2_teamnatureanim", true, false)
    -- self._downArrow:setPosition(20, 80)
    -- self._leftTableBg:addChild(self._downArrow, 5)
    self._bg = self:getUI("bg")
    -- self._bg:setPositionX(50)
    -- self._bg:runAction(cc.Sequence:create(
    --     cc.MoveBy:create(0,cc.p(-200,0)),
    --     cc.MoveBy:create(0.2,cc.p(210,0)),
    --     cc.MoveBy:create(0.2,cc.p(-10,0))
    -- ))
    self._scrollView = self:getUI("bg.leftTableBg.scrollView")
    self._iconsPanel = self:getUI("bg.iconsPanel")
    self:initTabs()
    self:touchTab(1)
end

function DialogFlashPreView:initTabs( )
    self._tabBtns = {}
    local btnSize = 86
    local x,y = 0,0
    local offsetX,offsetY = 0,-10
    local tabNums = table.nums(self._showData)
    local maxHeight = math.max(480,tabNums*btnSize)
    self._scrollView:setInnerContainerSize(cc.size(130,maxHeight))
    local count = 0
    for i=1,10 do
        if self._showData[i] then
            local tabBtn = self._tabBtn:clone()
            tabBtn:setVisible(true)
            tabBtn:setScaleAnim(false)
            tabBtn:setAnchorPoint(0,0)
            count = count + 1
            tabBtn:setPosition(x+offsetX, maxHeight-(count)*btnSize+offsetY)
            local race = tab.team[self._showData[i][1].teamId].race[1]
            self._idx2RaceMap[count] = race
            self:initTabByRace(tabBtn,race)
            self._scrollView:addChild(tabBtn,99)
            self:registerClickEvent(tabBtn,function() 
                -- if i == 9 then
                --     self:touchTab(7)
                -- elseif i == 7 then
                --     self:touchTab(8)
                -- else
                    self:touchTab(i)
                -- end
            end)
            table.insert(self._tabBtns,tabBtn)
        end
    end
    -- self._tabBtns[7],self._tabBtns[8] = self._tabBtns[8],self._tabBtns[7]
end

function DialogFlashPreView:initTabByRace( tabBtn,race )
    local icon = tabBtn:getChildByFullName("icon")
    icon:loadTexture("flashcardBtn_".. race ..".png",1)
    local text = tabBtn:getChildByFullName("text")
    text:setString(lang("RACE_".. race .."_1"))
    text:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
end

function DialogFlashPreView:touchTab( idx )
    for i,v in ipairs(self._tabBtns) do
        if i ~= idx then
            self:tabChangeStatus(self._tabBtns[i],false)
        end
    end
    self:tabChangeStatus(self._tabBtns[idx],true)
    self:reflashIcons(idx)
end

function DialogFlashPreView:tabChangeStatus( tabBtn,isSelect )
    tabBtn:setEnabled(not isSelect)
    tabBtn:loadTextureNormal(isSelect and "globalImageUI12_tab_d.png" or "globalImageUI12_tab_n.png",1)
end

function DialogFlashPreView:reflashIcons( idx )
    local iconData = self._showData[idx]
    -- if idx == 7 then iconData = self._showData[9] end
    -- if idx == 8 then iconData = self._showData[7] end
    iconData = iconData or {}
    self._iconsPanel:removeAllChildren()
    local iconW,iconH = 193,235
    local offsetX,offsetY = 0,0
    local maxHeight = 460
    local row,col = 2,3
    for i=1,#iconData do
        local teamIcon = self:createItem(iconData[i],idx)
        local x = ((i-1)%col)*iconW+offsetX
        local y = maxHeight - math.ceil(i/col)*iconH +offsetY
        teamIcon:setPosition(x,y)
        self._iconsPanel:addChild(teamIcon)
    end
end

-- 接收自定义消息
function DialogFlashPreView:reflashUI(data)

end


function DialogFlashPreView:createItem(data,idx)
    local teamD = tab:Team(data.teamId)
    local teamIcon = self._item:clone()
    teamIcon:setVisible(true)
    teamIcon:loadTexture("classboard_".. self._idx2RaceMap[idx] .."_flashcard.png", 1)
	-- teamIcon:setPosition(cc.p(x,y))
	local name = teamIcon:getChildByFullName("name") --ccui.Text:create()
	name:setFontName(UIUtils.ttfName)
	name:setString(lang(teamD.name))
	name:setFontSize(22)
	name:enableOutline(cc.c4b(64,64,64,255),1)
    local color = teamD.color or 1
    name:setColor(UIUtils.colorTable["ccColorQuality" .. color])
    name:setFontName(UIUtils.ttfName)

    local tW,tH = teamIcon:getContentSize().width,teamIcon:getContentSize().height
    local dizuoImg = ccui.ImageView:create()
    dizuoImg:loadTexture("asset/uiother/dizuo/teamBgDizuo".. teamD.race[1] ..".png")
    dizuoImg:setScale(0.6)
    dizuoImg:setAnchorPoint(cc.p(0.5,0))
    dizuoImg:setPosition(tW/2,20)
    teamIcon:addChild(dizuoImg)

    local teamImg = ccui.ImageView:create()
    local filename = "asset/uiother/steam/" .. teamD.steam .. ".png"
    local fu = cc.FileUtils:getInstance()
    if not fu:isFileExist(filename) then
        filename = "asset/uiother/steam/" .. teamD.steam .. ".jpg"
    end
    teamImg:setAnchorPoint(cc.p(0.5,0))
    teamImg:loadTexture(filename)
    local width,height = teamImg:getContentSize().width,teamImg:getContentSize().height
    teamImg:setPosition(tW/2,30)
    local scale = math.min(150/width,150/height)
    teamImg:setScale(0.5)
    teamIcon:addChild(teamImg,9)

    -- 资质
    local zizhiLab = teamIcon:getChildByFullName("zizhi")
    zizhiLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    zizhiLab:setString(teamD.zizhi+12)

    -- 星级
    local star = teamIcon:getChildByFullName("star")
    star:loadTexture("globalImageUI6_cardteamStar".. teamD.starlevel ..".png",1)
    
    -- 
    local darkBg = teamIcon:getChildByFullName("darkBg")
    darkBg:setZOrder(-1)

    local scrolling = false
    local firstDir 
    local touchBeginX,touchBeginY = 0
    self:registerTouchEvent(teamIcon,function( _,x,y )
            touchBeginX = x
            touchBeginY = y
            scrolling = false
        end,
        function( _,x,y )
            scrolling = true
        end,
        function( _,x,y )
            if math.abs(x-touchBeginX) < 5 and math.abs(y-touchBeginY) < 5 then 
                ViewManager:getInstance():showDialog("formation.NewFormationDescriptionView", { iconType = NewFormationIconView.kIconTypeLocalTeam, iconId = data.teamId}, true)
            end
            touchBeginX = 0
            firstDir = false
        end,
        function () 
            scrolling = false
            firstDir = false
        end
    )
    teamIcon:setSwallowTouches(false)
    return teamIcon
end

return DialogFlashPreView	