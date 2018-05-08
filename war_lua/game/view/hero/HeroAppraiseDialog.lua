--[[
    Filename:    HeroAppraiseDialog.lua
    Author:      <lishunan@playcrab.com>
    Datetime:    2018-01-19 20:47:33
    Description: File description
--]]

local HeroAppraiseDialog = class("HeroAppraiseDialog", BasePopView)

function HeroAppraiseDialog:ctor(param)
    HeroAppraiseDialog.super.ctor(self)
    self._selectTabIndex = 0
    self._teamCommentData = {}
    self._commentModel = self._modelMgr:getModel("CommentModel")
    self._userModel = self._modelMgr:getModel("UserModel")
    self._teamModel = self._modelMgr:getModel("TeamModel")

    self._teamCommentData = self._commentModel:getTeamData()
    local teamDetail = self._commentModel:getTeamDetailData()
    self._hotNum = table.nums(teamDetail.hList)

    self._heroID = param.id
    self._satr = param.star or 0
    -- self._teamId = param.teamId or 106
end

function HeroAppraiseDialog:getRegisterNames()
    return{
        {"tab_appraise","bg.leftBg.btn1"}, 
        {"tab_suggest","bg.leftBg.btn2"}, 
        {"select_bg_1","bg.leftBg.select_bg_1"}, 
        {"select_bg_2","bg.leftBg.select_bg_2"}, 
        {"tabName1","bg.leftBg.Label_52"}, 
        {"tabName2","bg.leftBg.Label_53"}, 
        {"cell_appraise","cell_appraise"},
        {"cell_suggest","cell_suggest"},
        {"noneBg","bg.noneBg"},
        {"noneDes","bg.noneBg.none"},

        {"downBg","bg.downBg"},
        {"mySuggest","bg.mySuggest"},
        {"noneBg","bg.noneBg"},
        {"tableViewBg","bg.tableViewBg"},
        {"commentTxt", "bg.downBg.commentTxt"},
        {"commentBtn", "bg.downBg.commentBtn"},
        {"iconPanel", "bg.iconPanel"},
        {"heroName", "bg.heroName"},
        {"camp", "bg.camp"},
        {"heroDes", "bg.heroDes"}

    }
end

function HeroAppraiseDialog:onInit()

    local title = self:getUI("bg.titleBg.title")
    UIUtils:setTitleFormat(title, 1)
    self._cell_appraise:setVisible(false)
    self._cell_suggest:setVisible(false)
    self:registerClickEventByName("bg.closeBtn", function ()
        if OS_IS_WINDOWS then
            UIUtils:reloadLuaFile("hero.HeroAppraiseDialog")
        end
        self:close()
    end)

    self._noneDes:setString("暂无评价")
    self._tabName2:setString("阵容")
    -- self._commentTxt:setPlaceHolder(" 拥有此英雄并达到2星后可进行评论")
    self._commentTxt:setColor(cc.c3b(255, 255, 255))
    self._commentTxt:setPlaceHolderColor(UIUtils.colorTable.ccUIInputTipColor)
    self._commentTxt:addEventListener(function(sender, eventType)
        self._commentTxt:setColor(cc.c3b(70, 40, 0))
        if self._commentTxt:getString() == "" then
            self._commentTxt:setColor(cc.c3b(255, 255, 255))
            self._commentTxt:setPlaceHolderColor(UIUtils.colorTable.ccUIInputTipColor)
            if self._satr < 2 then
                self._commentTxt:setTouchEnabled(false)
                self._commentTxt:setPlaceHolder(" 拥有此英雄并达到2星后可进行评论")
            else
                self._commentTxt:setTouchEnabled(true)
                self._commentTxt:setPlaceHolder(lang("hero_comment_11"))
            end
        end
    end)
    if self._satr < 2 then
        self._commentTxt:setTouchEnabled(false)
        self._commentTxt:setPlaceHolder(" 拥有此英雄并达到2星后可进行评论")
    else
        self._commentTxt:setTouchEnabled(true)
        self._commentTxt:setPlaceHolder(lang("hero_comment_11"))
    end

    self:registerClickEvent(self._commentBtn, function()
        self:commentMessage()
    end)

    self:registerClickEvent(self._mySuggest, function()
        self:onMySuggest()
    end)

    -- 增加点击动画
    -- UIUtils:setTabChangeAnimEnable(self._tab_appraise,-35,handler(self, self.tabButtonClick))
    -- UIUtils:setTabChangeAnimEnable(self._tab_suggest,-35,handler(self, self.tabButtonClick))
    -- self._tabEventTarget = {}
    -- table.insert(self._tabEventTarget, self._tab_appraise)
    -- table.insert(self._tabEventTarget, self._tab_suggest)
    -- self._animBtns = self._tabEventTarget

    -- self:tabButtonClick(self._tabEventTarget[self._selectTabIndex],true,true)

    self._select_bg_1:setVisible(false)
    self._select_bg_2:setVisible(false)
    self:registerClickEvent(self._tab_appraise, function()
        self:clickTab(1)
    end)

    self:registerClickEvent(self._tab_suggest, function()
        self:clickTab(2)
    end)
    self:clickTab(1)

    ---top-----
    local heroData = clone(tab:Hero(self._heroID))
    local itemIcon = IconUtils:createHeroIconById({sysHeroData = heroData})
    itemIcon:getChildByName("starBg"):setVisible(false)
    itemIcon:getChildByFullName("iconStar"):setVisible(false)
    itemIcon:setScale(0.9)
    self._iconPanel:addChild(itemIcon)
    itemIcon:setPosition(self._iconPanel:getContentSize().width*0.5,self._iconPanel:getContentSize().height*0.5)

    self._heroName:setString(lang(heroData.heroname))
    self._heroDes:setString(lang("HEROLOCATION_"..self._heroID))
    local camp = {"无","城堡","壁垒","墓园","据点","地狱","塔楼","地下城","要塞","元素"}
    self._camp:setString(camp[heroData.masterytype+1] or "无")

end

function HeroAppraiseDialog:clickTab(idx)
    print("idx",idx)
    if self._selectTabIndex == idx then
        return
    end
    self._noneDes:setString(idx == 1 and "暂无评价" or "暂无阵容")
    if self._selectTabIndex and self._selectTabIndex > 0 then
        self["_select_bg_" .. self._selectTabIndex]:setVisible(false)
    end
    self._selectTabIndex = idx
    self["_select_bg_" .. self._selectTabIndex]:setVisible(true)

    if not self._init then
        self._init = true
        self:selectView()
        return
    end
    if idx == 1 then
        local param = {ctype = 5, id = self._heroID}
        self._serverMgr:sendMsg("CommentServer", "getCommentData", param, true, {}, function(result)
           self:reflashUI()
           self:selectView()
        end)
    else
        print("aaaaaaaaaaaaa",self._heroID)
        local param = {ctype = 6, id = self._heroID}
        self._serverMgr:sendMsg("CommentServer", "getCommentData", param, true, {}, function(result)
            dump(result,"===============",10)
           self:reflashUI()
           self:selectView()
        end)
    end

end

function HeroAppraiseDialog:tabButtonClick(sender,noAudio,noRequest)
    if sender == nil then 
        return 
    end
    print("sender:getName()",sender:getName())
    local name = sender:getName()

    local callback = function ()
        if name == "tab_appraise" then
            self._selectTabIndex = 1
        elseif name == "tab_suggest" then
            self._selectTabIndex = 2
        else
            self._selectTabIndex = 1
        end
        if not noAudio then 
            audioMgr:playSound("Tab")
        end
        if sender._notOpen then
            self._viewMgr:showTip(sender._notOpenDes or "未开启")
            UIUtils:tabTouchAnimOut(sender)
            return
        end
        for k,v in pairs(self._tabEventTarget) do
            if v ~= sender then 
                local text = v:getTitleRenderer()
                v:setTitleColor(UIUtils.colorTable.ccUITabColor1)
                text:disableEffect()
                v:setScaleAnim(false)
                v:stopAllActions()
                v:setScale(1)
                if v:getChildByName("changeBtnStatusAnim") then 
                    v:getChildByName("changeBtnStatusAnim"):removeFromParent()
                end
                v:setZOrder(-10)
                self:setTabStatus(v, false)
            end
        end
        if self._preBtn then
            UIUtils:tabChangeAnim(self._preBtn,nil,true)
        end
        
        -- 按钮动画
        self._preBtn = sender
        sender:stopAllActions()
        sender:setZOrder(99)
        UIUtils:tabChangeAnim(sender,function( )
            local text = sender:getTitleRenderer()
            text:disableEffect()
            sender:setTitleColor(UIUtils.colorTable.ccUITabColor2)
            self:setTabStatus(sender, true)
        end)
        self:selectView()
    end
    if noRequest then
        callback()
    else
        if name == "tab_appraise" then
            local param = {ctype = 1, id = 606}
            self._serverMgr:sendMsg("CommentServer", "getCommentData", param, true, {}, function(result)
               self:reflashUI()
               callback()
            end)
        elseif name == "tab_suggest" then
            local param = {ctype = 1, id = 606}
            self._serverMgr:sendMsg("CommentServer", "getCommentData", param, true, {}, function(result)
               self:reflashUI()
               callback()
            end)
        end
    end
    
end

function HeroAppraiseDialog:setTabStatus( tabBtn,isSelect )
    if isSelect then
        tabBtn:loadTextureNormal("globalBtnUI4_page1_p.png",1)
        local text = tabBtn:getTitleRenderer()
        tabBtn:setTitleColor(UIUtils.colorTable.ccUITabColor1)
        text:disableEffect()
    else
        tabBtn:loadTextureNormal("globalBtnUI4_page1_n.png",1)
        local text = tabBtn:getTitleRenderer()
        tabBtn:setTitleColor(UIUtils.colorTable.ccUITabColor2)
        text:disableEffect()
    end
    tabBtn:setEnabled(not isSelect)
end

function HeroAppraiseDialog:selectView()
    --visible

    if self._selectTabIndex == 1 then
        self._downBg:setVisible(true)
        self._mySuggest:setVisible(false)
    else
        self._downBg:setVisible(false)
        self._mySuggest:setVisible(true)
    end
    self:addTableView()


end


function HeroAppraiseDialog:onPopEnd(data)
    if 1 then
        return
    end
    local teamDetail = self._commentModel:getTeamDetailData()
    local flag = self._teamModel:getTeamCommentFristShow(self._teamId)
    if flag == true then
        if teamDetail.daily == 0 then
            return
        end
        local desc = "近期又有" .. teamDetail.daily .. "名玩家为你点赞喔，总共被点赞" .. teamDetail.total .. "次"
        self._viewMgr:showDialog("global.GlobalSelectDialog",
            {desc = desc,
            alignNum = 1,
            -- button1 = "确定",
            -- button2 = "取消", 
            callback1 = function ()
                if self._teamModel then
                    self._teamModel:saveTeamCommentFristShow(self._teamId)
                end
            end,
            callback2 = function()
                if self._teamModel then
                    self._teamModel:saveTeamCommentFristShow(self._teamId)
                end
            end}, true)  
    end
end

function HeroAppraiseDialog:reflashUI(data)
    self._teamCommentData = self._commentModel:getTeamData()
    local teamDetail = self._commentModel:getTeamDetailData()
    self._hotNum = table.nums(teamDetail.hList)
    
    if table.nums(self._teamCommentData) == 0 then
        self._noneBg:setVisible(true)
    else
        self._noneBg:setVisible(false)
    end
    -- dump(self._teamCommentData)
    -- print("refnum",table.nums(self._teamCommentData))
end

function HeroAppraiseDialog:addTableView()

    local tableViewBg = self._tableViewBg
    if self._selectTabIndex == 1 then
        if not self._appraiseTableVierw then
            self._appraiseTableVierw = cc.TableView:create(cc.size(tableViewBg:getContentSize().width, tableViewBg:getContentSize().height))
            self._appraiseTableVierw:setDelegate()
            self._appraiseTableVierw:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
            self._appraiseTableVierw:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
            self._appraiseTableVierw:setPosition(cc.p(0, 0))
            self._appraiseTableVierw:registerScriptHandler(function(table, cell) return self:tableCellTouched(table,cell) end,cc.TABLECELL_TOUCHED)
            self._appraiseTableVierw:registerScriptHandler(function(table, idx) return self:cellSizeForTable(table,idx) end,cc.TABLECELL_SIZE_FOR_INDEX)
            self._appraiseTableVierw:registerScriptHandler(function(table, idx) return self:tableCellAtIndex(table, idx) end,cc.TABLECELL_SIZE_AT_INDEX)
            self._appraiseTableVierw:registerScriptHandler(function(table) return self:numberOfCellsInTableView(table) end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
            self._appraiseTableVierw:setBounceable(true)
            tableViewBg:addChild(self._appraiseTableVierw)
            self._appraiseTableVierw:reloadData()
        else
            self._appraiseTableVierw:setVisible(true)
        end
        if not tolua.isnull(self._suggestTableView) then
            self._suggestTableView:setVisible(false)
        end
        
    else
        if not self._suggestTableView then
            self._suggestTableView = cc.TableView:create(cc.size(tableViewBg:getContentSize().width, tableViewBg:getContentSize().height))
            self._suggestTableView:setDelegate()
            self._suggestTableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
            self._suggestTableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
            self._suggestTableView:setPosition(cc.p(0, 0))
            self._suggestTableView:registerScriptHandler(function(table, cell) return self:tableCellTouched(table,cell) end,cc.TABLECELL_TOUCHED)
            self._suggestTableView:registerScriptHandler(function(table, idx) return self:cellSizeForTable(table,idx) end,cc.TABLECELL_SIZE_FOR_INDEX)
            self._suggestTableView:registerScriptHandler(function(table, idx) return self:tableCellAtIndex(table, idx) end,cc.TABLECELL_SIZE_AT_INDEX)
            self._suggestTableView:registerScriptHandler(function(table) return self:numberOfCellsInTableView(table) end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
            self._suggestTableView:setBounceable(true)
            tableViewBg:addChild(self._suggestTableView)
            self._suggestTableView:reloadData()
        else
            self._suggestTableView:setVisible(true)
        end
        if not tolua.isnull(self._appraiseTableVierw) then
            self._appraiseTableVierw:setVisible(false)
        end
    end
end


function HeroAppraiseDialog:scrollViewDidScroll(view)
    -- self._offsetY = view:getContentOffset().y
    -- local minY = 0 - #self._teamCommentData * 80 + self._tableViewHeight 
    -- local isDragging = view:isDragging()
    
    -- if isDragging then
    --     -- print("minY ===", isDragging, minY, self._offsetY)
    --     if self._offsetY >= 0 then
    --         if (self._offsetY - minY) > 60 and not self._reRequest then
    --             self._loadingMc:setPositionY(20)
    --             self._reRequest = true
    --             self._loadingMc:setVisible(true)
    --         elseif self._offsetY < 260 and not self._reRequest then
    --             self._loadingMc:setPositionY(330)
    --             self._reRequest = true
    --             self._loadingMc:setVisible(true)
    --         end

    --         if self._offsetY < 30 and self._reRequest then
    --             self._reRequest = false
    --             self._loadingMc:setVisible(false)
    --         end
    --     else
    --         if self._offsetY < minY - 60 and not self._reRequest then
    --             self._loadingMc:setPositionY(330)
    --             self._reRequest = true
    --             self._loadingMc:setVisible(true)
    --         end
    --         if self._offsetY > minY - 30 and self._reRequest then
    --             self._reRequest = false
    --             self._loadingMc:setVisible(false)
    --         end
    --     end
    -- else
    --     if self._reRequest and 0 == self._offsetY then
    --         self._reRequest = false
    --         -- 请求
    --         self._loadingMc:setVisible(false)
    --         if self._updateMailTick == nil or socket.gettime() > self._updateMailTick + 5 then
    --             self:getApplyGuildList(true, 1)
    --             self._updateMailTick = socket.gettime()
    --         end
    --     elseif self._reRequest and minY == self._offsetY then
    --         self._reRequest = false
    --         -- 请求
    --         self._loadingMc:setVisible(false)
    --         if self._updateMailTick == nil or socket.gettime() > self._updateMailTick + 5 then
    --             self:getApplyGuildList(true, -1)
    --             self._updateMailTick = socket.gettime()
    --         end
    --     end
    -- end
end


function HeroAppraiseDialog:scrollViewDidZoom(view)

end

-- 触摸时调用
function HeroAppraiseDialog:tableCellTouched(table,cell)

end

-- cell的尺寸大小
function HeroAppraiseDialog:cellSizeForTable(table,idx)
    local width, height
    if self._selectTabIndex == 1 then
        width = 634
        height = 75 
    else
        width = 634
        height = 116
    end
    return height, width
end

-- 创建在某个位置的cell
local ccTableViewCell = cc.TableViewCell
function HeroAppraiseDialog:tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    local indexId = idx+1
    local param = self._teamCommentData[indexId]
    if nil == cell then
        cell = ccTableViewCell:new()
        local commentCell
        if self._selectTabIndex == 1 then
            commentCell = self._cell_appraise:clone()
        else
            commentCell = self._cell_suggest:clone()
        end
        commentCell:setPosition(2, 0)
        commentCell:setVisible(true)
        cell:addChild(commentCell)
        cell.item = commentCell
        commentCell:setSwallowTouches(false)
    end

    local commentCell = cell.item
    if commentCell then
        self:updateCell(commentCell, param, indexId)
    end
    return cell
end

-- 返回cell的数量
function HeroAppraiseDialog:numberOfCellsInTableView(table)
    return self:tableNum()
end

function HeroAppraiseDialog:tableNum()
    return table.nums(self._teamCommentData)
end

function HeroAppraiseDialog:updateAppraiseCell(inView, param, indexId)
    if not param then
        return
    end
    local reping = inView:getChildByFullName("reping")
    local cellBg = inView:getChildByFullName("cellBg")
    local name = inView:getChildByFullName("name")
    local pingLab = inView:getChildByFullName("pingLab")
    local zanBg = inView:getChildByFullName("zanBg")
    local zanLab = inView:getChildByFullName("zanBg.lab")
    local zanIcon = inView:getChildByFullName("zanBg.icon")

	if zanIcon then
		zanIcon:loadTexture("comment_iconLikeGold.png", 1)
	end
    if indexId <= self._hotNum then
        if reping then
            reping:setVisible(true)
        end
        if cellBg then
            cellBg:loadTexture("globalPanelUI7_cellBg0.png", 1)
            -- cellBg:setCapInsets(cc.rect(41,41,1,20))
        end
    else
        if reping then
            reping:setVisible(false)
        end
        if cellBg then
            cellBg:loadTexture("globalPanelUI7_cellBg1.png", 1)
            -- cellBg:setCapInsets(cc.rect(41,41,1,20))
        end
    end

    local tempFlag = 0
    if param.aId and param.aId == 0 then
        zanLab:disableEffect()
        zanLab:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    elseif param.aId and param.aId == 1 then
        zanLab:disableEffect()
        zanLab:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
        if zanIcon then
            zanIcon:loadTexture("comment_iconLikeGreen.png", 1)
        end
        tempFlag = 1
    elseif param.aId and param.aId == 2 then
        zanLab:disableEffect()
        zanLab:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
        tempFlag = 2
    end

    zanLab:setString(param.ag)
    
    local rtx = inView.richItem
    if rtx then
        rtx:removeFromParent(true)
        inView.richItem = nil
    end
    local nameStr = self:formatName(param.name)
    rtx = RichTextFactory:create("[color = 46280A,fontsize=22]".. nameStr .. "[-]", 115, 80)
    rtx:formatText()
    rtx:setTouchEnabled(false)
    rtx:setVerticalSpace(7)
    rtx:setName("rtx")
    rtx:setPosition(70, 37)
    rtx:setSaturation(0)
    rtx:setSwallowTouches(false)
    inView.richItem = rtx
    inView:addChild(rtx)
    UIUtils:alignRichText(rtx,{hAlign = center})

    name:setVisible(false)


    local str = ""
    if (not param.rid and param.lId) or (param.rid and param.rid == "") then
        local comTab = tab:CommentTeam(param.lId)
        if comTab then
            str = lang(comTab.lang)
        end
    elseif param.cm then
        str = param.cm
    end
    pingLab:setString(str)

    if tempFlag == 0 then
        local callback = function(resultParam)
            self:updateCell(inView, resultParam, indexId)
        end
        self:registerClickEvent(zanBg, function()
            self:commentAttitude(5,param.cId, 1, indexId, callback)
        end)
        -- zanIcon:setScaleAnim(true)
        -- self:registerClickEvent(zanIcon, function()
        --     self:commentAttitude(param.cId, 1, indexId, callback)
        -- end)
    else
        self:registerClickEvent(zanBg, function()
            self:showTishi(tempFlag)
        end)
        -- zanIcon:setScaleAnim(true)
        -- self:registerClickEvent(zanIcon, function()
        --     self:showTishi(tempFlag)
        -- end)
    end
end

function HeroAppraiseDialog:updateSuggestCell(inView, param, indexId)
    if not param then
        return
    end
    print("limitLen=====", os.clock())
    local reping = inView:getChildByFullName("reping")
    local cellBg = inView:getChildByFullName("cellBg")
    local name = inView:getChildByFullName("name")
	local appraiseNumLab = inView:getChildByFullName("appraiseNumLab")
    local level = inView:getChildByFullName("level")
    local vip = inView:getChildByFullName("vip")
    local appraise = inView:getChildByFullName("appraise")
    vip:setVisible(false)
    local iconItem = inView:getChildByFullName("icon")
    iconItem:setVisible(false)
    -- local pingLab = inView:getChildByFullName("pingLab")


    local zanBg = inView:getChildByFullName("zanBg")
    local zanLab = inView:getChildByFullName("zanBg.lab")
    local zanIcon = inView:getChildByFullName("zanBg.icon")
   

	if zanIcon then
		zanIcon:loadTexture("comment_iconLikeGold.png", 1)
	end
    if indexId <= self._hotNum then
        if reping then
            reping:setVisible(true)
        end
        if cellBg then
            cellBg:loadTexture("globalPanelUI7_cellBg0.png", 1)
            cellBg:setCapInsets(cc.rect(41,41,1,20))
        end
    else
        if reping then
            reping:setVisible(false)
        end
        if cellBg then
            cellBg:loadTexture("globalPanelUI7_cellBg1.png", 1)
            cellBg:setCapInsets(cc.rect(41,41,1,20))
        end
    end

    local tempFlag = 0
    if param.aId and param.aId == 0 then
        zanLab:disableEffect()
        zanLab:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    elseif param.aId and param.aId == 1 then
        zanLab:disableEffect()
        zanLab:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
        if zanIcon then
            zanIcon:loadTexture("comment_iconLikeGreen.png", 1)
        end
        tempFlag = 1
    elseif param.aId and param.aId == 2 then
        zanLab:disableEffect()
        zanLab:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
        tempFlag = 2
    end

    zanLab:setString(param.ag)
    name:setString(param.name)
	if param.cnum and param.cnum>0 then
		appraiseNumLab:setString(string.format("%d条", param.cnum))
		appraiseNumLab:setVisible(true)
	else
		appraiseNumLab:setVisible(false)
	end
    name:setPositionY(90)
    level:setPositionY(90)
    level:setString("Lv."..param.lvl)
    if name:getContentSize().width > 60 then
        level:setPositionX(name:getPositionX()+name:getContentSize().width+40)
    else
        level:setPositionX(name:getPositionX()+80)
    end
    if not inView.vipLabel then
        local vipLabel = cc.Label:createWithBMFont(UIUtils.bmfName_vip, "V" .. param.vipLv)
        vipLabel:setAnchorPoint(cc.p(0,0.5))
        vipLabel:setPosition(vip:getPositionX(),vip:getPositionY()-5)
        inView:addChild(vipLabel, 2)
        inView.vipLabel = vipLabel
    else
        inView.vipLabel:setString("V" .. param.vipLv)
    end
    inView.vipLabel:setVisible(false)

    local teamList = json.decode(param.cm)
    if teamList.teams then
        teamList = teamList.teams 
    end
    -- dump(teamList,"teamList---------")
    local width = 58
    for i=1,8 do 
        local teamItem = inView["teamIcon" .. i]
        if teamList[i] then
            -- print("teamList[i]",teamList[i])
            local id = tonumber(teamList[i])
            if not teamItem then
                local teamTeam = clone(tab:Team(id))
                local itemIcon = IconUtils:createSysTeamIconById({sysTeamData = teamTeam})
                itemIcon:setScale(0.5)
                itemIcon:setPosition((i-1)*width+iconItem:getPositionX(),iconItem:getPositionY())
                inView:addChild(itemIcon)
                inView["teamIcon" .. i] = itemIcon
            else
                local teamTeam = clone(tab:Team(id))
                IconUtils:updateSysTeamIconByView(teamItem,{sysTeamData = teamTeam})
            end
        else
            if teamItem then
                teamItem:setVisible(false)
            end
        end
    end

    if tempFlag == 0 then
        local callback = function(resultParam)
            self:updateCell(inView, resultParam, indexId)
        end
        self:registerClickEvent(zanBg, function()
            self:commentAttitude(6,param.cId, 1, indexId, callback)
        end)
        -- zanIcon:setScaleAnim(true)
        -- self:registerClickEvent(zanIcon, function()
        --     self:commentAttitude(param.cId, 1, indexId, callback)
        -- end)
    else
        self:registerClickEvent(zanBg, function()
            self:showTishi(tempFlag,true)
        end)
        -- zanIcon:setScaleAnim(true)
        -- self:registerClickEvent(zanIcon, function()
        --     self:showTishi(tempFlag)
        -- end)
    end

    self:registerClickEvent(appraise, function()
        local callback = function()
            -- self:updateCell(inView, param, indexId)
        end
        self:onAppraiseFormation(param)
    end)
end

function HeroAppraiseDialog:onAppraiseFormation(param_)
    local ext = cjson.encode({cId = param_.cId})
    local param = {ctype = 7, id = self._heroID, ext = ext}
    self._serverMgr:sendMsg("CommentServer", "getCommentData", param, true, {}, function(result)
        self._viewMgr:showDialog("hero.FormationAppraiseDialog",{id = self._heroID,content = param_,star = self._satr},true)
    end)
end

function HeroAppraiseDialog:updateCell(inView, param, indexId)
    if self._selectTabIndex == 1 then
        self:updateAppraiseCell(inView, param, indexId)
    else
        self:updateSuggestCell(inView, param, indexId)
    end
end

function HeroAppraiseDialog:showTishi(flag,isSuggest)
    if flag == 1 then
        self._viewMgr:showTip(isSuggest and lang("hero_comment_12") or lang("hero_comment_5"))
    else
        self._viewMgr:showTip("您已经踩过该评论了")
    end
end

-- rid  评论人ID 为空代表官方评论
-- name 评论人名字
-- cm   评论内容
-- lId  语言表ID
-- cId  评论ID
-- ct   评论时间
-- aId  当前玩家对应该条评论的状态(0:无 1:赞 2:踩)
-- ag   赞的总数
-- dis  踩的总数
function HeroAppraiseDialog:commentAttitude(ctype, cId, aId, indexId, callback)
    local param = {ctype = ctype, id = self._heroID, cId = cId, aId = aId}
    self._serverMgr:sendMsg("CommentServer", "commentAttitude", param, true, {}, function(result)
        if aId == 1 then
            self._teamCommentData[indexId].aId = aId
            self._teamCommentData[indexId].ag = self._teamCommentData[indexId].ag + 1
        elseif aId == 2 then
            self._teamCommentData[indexId].aId = aId
            self._teamCommentData[indexId].dis = self._teamCommentData[indexId].dis + 1
        end
        callback(self._teamCommentData[indexId])
    end)
end

-- 规范名字格式
function HeroAppraiseDialog:formatName(nameStr, fontSize, outlineSize)
    if not nameStr then
        return ""
    end
    local subStr = self:limitLen(nameStr)
    return subStr
end

function HeroAppraiseDialog:limitLen(str)
    local maxNum = 8
    if not str then
        str = ""
    end
    local _, nameLen = utf8.width(str)
    local nameAdd = ""
    if nameLen > 10 then
        maxNum = 8
        nameAdd = "..."
    else
        maxNum = nameLen
    end
    local str = utf8.limitLen(str, maxNum)
    str = str .. nameAdd
    return str
end

function HeroAppraiseDialog:stringLenNum(str)
    local lenInByte = #str
    local lenNum = 0
    for i=1,lenInByte do
        local curByte = string.byte(str, i)
        if curByte>0 and curByte<=127 then
            lenNum = lenNum + 1
        elseif curByte>=192 and curByte<=247 then
            lenNum = lenNum + 2
        end
    end
    return lenNum
end

-- 英雄阵容评价一天一次限制
function HeroAppraiseDialog:canCommitSuggest( )
    if self._heroID then
        local heroData = self._modelMgr:getModel("HeroModel"):getHeroData(self._heroID)
        if heroData then
            -- dump(heroData)
            print(heroData.ct2,"ct2---------")
            local ct2 = heroData.ct2 
            if ct2 then
                local nowTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
                local tempPreTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(nowTime,"%Y-%m-%d 05:00:00"))
                local tempTomorrowTime = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(nowTime + 86400,"%Y-%m-%d 05:00:00"))
                if ct2 >= tempPreTime and ct2 <= tempTomorrowTime then
                    return false
                end
            end
        end
    end
    return true
end

function HeroAppraiseDialog:onMySuggest()
    if self._satr < 3 then
        self._viewMgr:showTip(lang("hero_comment_3"))
        return
    end
    local teamDetail = self._commentModel:getTeamDetailData()
    local cNum1 = teamDetail.cNum and tonumber(teamDetail.cNum) or 0
    local maxNum = tab:Setting("H_COMMENT_NUM8").value
    if cNum1 >= maxNum then
        self._viewMgr:showTip(lang("hero_comment_8"))
        return
    end
    if not self:canCommitSuggest() then
        self._viewMgr:showTip(lang("hero_comment_13"))
        return 
    end
    local param = {fixedHero = self._heroID,isSimpleFormation = true}
    self._viewMgr:showView("formation.NewFormationView", {formationType = 1,extend = param,
    closeCallback = function (result, closeFormation)
        if not result then
            return
        end
		local callback = function(context)
			local list = {}
			list.teams = result
			list.content = context
			self._suggetList = json.encode({teams = result, content = context})
			local param = {ctype = 6, id = self._heroID, content = json.encode(list)}
			self._serverMgr:sendMsg("CommentServer", "commentMessage", param, true, {}, function(result)
				dump(result, "result======", 10)
				-- self:addTableCell(conLabel, result["cId"])
				self:addSuggestTableCell(result["cId"])
				self:reflashUI()
				if closeFormation then
					closeFormation()
				end
			end)
		end
		self._viewMgr:showDialog("hero.HeroFormationAppraiseDialog", {callback = callback})
    end})
end

-- 评论
function HeroAppraiseDialog:commentMessage()
    if self._satr < 2 then
        self._viewMgr:showTip(lang("hero_comment_2"))
        return
    end
    local teamDetail = self._commentModel:getTeamDetailData()
    local cNum = teamDetail.cNum and tonumber(teamDetail.cNum) or 0
    local maxNum = tab:Setting("H_COMMENT_NUM6").value
    if cNum >= maxNum then
        self._viewMgr:showTip(lang("hero_comment_6"))
        return
    end
    local conLabel = self._commentTxt:getString()
    conLabel = string.gsub(conLabel, "^%s*(.-)%s*$", "%1")
    if conLabel == "" then
        self._viewMgr:showTip("输入内容为空")
        return
    end
    local userData = self._userModel:getData()
    local curServerTime = self._userModel:getCurServerTime()
    local param = {ctype = 5, id = self._heroID, content = conLabel}
    self._serverMgr:sendMsg("CommentServer", "commentMessage", param, true, {}, function(result)
        -- dump(result, "result======", 10)
        -- self._viewMgr:showDialog("team.HeroAppraiseDialog", {teamId = self._curSelectTeam.teamId})
        self:addTableCell(conLabel, result["cId"])
        self._commentTxt:setString("")
		self._commentTxt:setColor(cc.c3b(255, 255, 255))
        if self._satr < 2 then
            self._commentTxt:setTouchEnabled(false)
            self._commentTxt:setPlaceHolder(" 拥有此英雄并达到2星后可进行评论")
        else
            self._commentTxt:setTouchEnabled(true)
            self._commentTxt:setPlaceHolder(lang("hero_comment_11"))
        end
        self._commentTxt:setPlaceHolderColor(UIUtils.colorTable.ccUIInputTipColor)
    end, function(errorId)
        if tonumber(errorId) == 125 then
            self._viewMgr:showTip("只能为中文、英文、数字")
        elseif tonumber(errorId) == 126 then
            self._viewMgr:showTip("字符串长度不足")
        elseif tonumber(errorId) == 127 then
            self._viewMgr:showTip("字符串长度超出限制")
        elseif tonumber(errorId) == 117 then
            self._viewMgr:showTip("输入内容含有非法字符")
        elseif tonumber(errorId) == 4514 then
            self._viewMgr:showTip("输入内容含有非法字符")
        elseif tonumber(errorId) == 4515 then
            self._viewMgr:showTip("输入内容为空")
        elseif tonumber(errorId) == 4517 then
            self._viewMgr:showTip("没有该英雄无法评论或推荐")
        elseif tonumber(errorId) == 4518 then
            self._viewMgr:showTip("英雄星级不足无法评价")
        elseif tonumber(errorId) == 4519 then
            self._viewMgr:showTip("请明天再评论")
        elseif tonumber(errorId) == 4504 then
            local str = lang("COMTERM_NUM1")
            self._viewMgr:showTip(str)
        end
    end)
end

function HeroAppraiseDialog:addSuggestTableCell(cId)
    local userData = self._userModel:getData()
    local curServerTime = self._userModel:getCurServerTime()
    local tempValue = {}
    tempValue["aId"]  = 0
    tempValue["ag"]  = 0
    tempValue["cId"]  = cId
    tempValue["cm"]  = self._suggetList
    tempValue["ct"]  = curServerTime
    tempValue["dis"]  = 0
    tempValue["lId"]  = 0
	tempValue["cnum"] = 0
    tempValue["name"]  = userData.name
    tempValue["rid"]  = userData._id
    tempValue["vipLv"] = self._modelMgr:getModel("VipModel"):getLevel()
    tempValue["lvl"] = userData.lvl
--    if table.nums(self._teamCommentData) >= self._hotNum then
        table.insert(self._teamCommentData, self._hotNum+1, tempValue)
    --[[else
        local insertId = table.nums(self._teamCommentData) + 1
        table.insert(self._teamCommentData, self._hotNum+1, tempValue)
    end--]]
    
    self._suggestTableView:reloadData()
end

function HeroAppraiseDialog:addTableCell(conLabel, cId)
    -- local conLabel = self._conLabel:getString()
    local userData = self._userModel:getData()
    local curServerTime = self._userModel:getCurServerTime()

    local tempValue = {}
    tempValue["aId"]  = 0
    tempValue["ag"]  = 0
    tempValue["cId"]  = cId
    tempValue["cm"]  = conLabel
    tempValue["ct"]  = curServerTime
    tempValue["dis"]  = 0
    tempValue["lId"]  = 0
    tempValue["name"]  = userData.name
    tempValue["rid"]  = userData._id
--    if table.nums(self._teamCommentData) >= 3 then
        table.insert(self._teamCommentData, self._hotNum+1, tempValue)
    --[[else
        local insertId = table.nums(self._teamCommentData) + 1
        table.insert(self._teamCommentData, insertId, tempValue)
    end--]]
    if table.nums(self._teamCommentData) == 0 then
        self._noneBg:setVisible(true)
    else
        self._noneBg:setVisible(false)
    end
    
    self._appraiseTableVierw:reloadData()
end


return HeroAppraiseDialog
