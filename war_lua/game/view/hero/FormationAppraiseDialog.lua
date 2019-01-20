--[[
    Filename:    FormationAppraiseDialog.lua
    Author:      <lishunan@playcrab.com>
    Datetime:    2018-01-19 20:47:33
    Description: File description
--]]

local FormationAppraiseDialog = class("FormationAppraiseDialog", BasePopView)

local type_ = "7"
function FormationAppraiseDialog:ctor(param)
    FormationAppraiseDialog.super.ctor(self)
    self._selectTabIndex = 0
    self._teamCommentData = {}
    self._commentModel = self._modelMgr:getModel("CommentModel")
    self._userModel = self._modelMgr:getModel("UserModel")
    self._teamModel = self._modelMgr:getModel("TeamModel")

    self._teamCommentData = self._commentModel:getDataByType(type_)
    local teamDetail = self._commentModel:getDetailDataByType(type_)
--    dump(teamDetail)
    self._hotNum = table.nums(teamDetail.hList)

    self._heroID = param.id
    self._content = param.content
    self._star = param.star
    -- self._teamId = param.teamId or 106
end

function FormationAppraiseDialog:getRegisterNames()
    return{
        {"cell_appraise","cell_appraise"},
        {"noneBg","bg.noneBg"},
        {"downBg","bg.downBg"},
        {"noneBg","bg.noneBg"},
        {"tableViewBg","bg.tableViewBg"},
        {"commentTxt", "bg.downBg.commentTxt"},
        {"commentBtn", "bg.downBg.commentBtn"},
        {"iconPanel", "bg.iconPanel"},
        {"heroName", "bg.heroName"},
        {"heroDes", "bg.heroDes"},
        {"bg", "bg"},
        {"level","bg.level"},
        {"vip","bg.vip"}

    }
end

function FormationAppraiseDialog:onInit()

    local title = self:getUI("bg.titleBg.title")
    UIUtils:setTitleFormat(title, 1)
    self._cell_appraise:setVisible(false)
    self:registerClickEventByName("bg.closeBtn", function ()
        if OS_IS_WINDOWS then
            UIUtils:reloadLuaFile("hero.FormationAppraiseDialog")
        end
        self:close()
    end)

    -- self._commentTxt:setPlaceHolder(" 拥有此英雄并达到2星后可进行评论")
    self._commentTxt:setColor(cc.c3b(255, 255, 255))
    self._commentTxt:setPlaceHolderColor(UIUtils.colorTable.ccUIInputTipColor)
    self._commentTxt:addEventListener(function(sender, eventType)
        self._commentTxt:setColor(cc.c3b(70, 40, 0))
        if self._commentTxt:getString() == "" then
            self._commentTxt:setColor(cc.c3b(255, 255, 255))
            self._commentTxt:setPlaceHolderColor(UIUtils.colorTable.ccUIInputTipColor)
            if self._star < 2 then
                self._commentTxt:setTouchEnabled(false)
                self._commentTxt:setPlaceHolder(" 拥有此英雄并达到2星后可进行评论")
            else
                self._commentTxt:setTouchEnabled(true)
                self._commentTxt:setPlaceHolder(lang("hero_comment_11"))
            end
        end
    end)

    if self._star < 2 then
        self._commentTxt:setTouchEnabled(false)
        self._commentTxt:setPlaceHolder(" 拥有此英雄并达到2星后可进行评论")
    else
        self._commentTxt:setTouchEnabled(true)
        self._commentTxt:setPlaceHolder(lang("hero_comment_11"))
    end

    self:registerClickEvent(self._commentBtn, function()
        self:commentMessage()
    end)

    ---top-----
    local heroData = clone(tab:Hero(self._heroID))
    local itemIcon = IconUtils:createHeroIconById({sysHeroData = heroData})
    itemIcon:setScale(0.9)
    itemIcon:getChildByName("starBg"):setVisible(false)
	itemIcon:getChildByName("iconStar"):setVisible(false)
    self._iconPanel:addChild(itemIcon)
    itemIcon:setPosition(self._iconPanel:getContentSize().width*0.5,self._iconPanel:getContentSize().height*0.5)
    local inView = self._bg
    self._heroName:setString(lang(heroData.heroname))
    local inParam = {lvlStr = "Lv." .. (self._content.level or self._content.lvl or 0), lvl = (self._content.level or self._content.lvl or 0), plvl = self._content.plvl}
    UIUtils:adjustLevelShow(self._level, inParam, 1)
    self._vip:setVisible(false)
    local vipLabel = cc.Label:createWithBMFont(UIUtils.bmfName_vip, "V" .. self._content.vipLv)
    vipLabel:setAnchorPoint(cc.p(0,0.5))
    vipLabel:setScale(0.7)
    vipLabel:setPosition(self._vip:getPositionX(),self._vip:getPositionY()-2)
	local userData = self._modelMgr:getModel("UserModel"):getData()
	local extra = userData.extra
	if extra and extra.hideVip then
		vipLabel:setVisible(extra.hideVip["2"]==0)
	end
    inView:addChild(vipLabel, 2)
    -- local camp = {"无","城堡","壁垒","墓园","据点","地狱","塔楼","地下城","要塞","元素"}
    -- self._camp:setString(camp[heroData.masterytype+1] or "无")
    local teamContent = json.decode(self._content.cm)
	if teamContent.content then
		self._hasSelfAppraise = true
		local tempValue = {}
		tempValue["aId"]  = 0
		tempValue["ag"]  = 0
		tempValue["cId"]  = self._content.cId
		tempValue["cm"]  = teamContent.content
		tempValue["ct"]  = self._modelMgr:getModel("UserModel"):getCurServerTime()
		tempValue["dis"]  = 0
		tempValue["lId"]  = 0
		tempValue["name"]  = self._content.name
		tempValue["rid"]  = self._content.rid
		table.insert(self._teamCommentData, 1, tempValue)
	end
    self:addTableView()

    
	local teamList = teamContent.teams or teamContent
    local width = 65
    for i=1,8 do 
        local teamItem = inView["teamIcon" .. i]
        if teamList[i] then
            print("teamList[i]",teamList[i])
            local id = tonumber(teamList[i])
            if not teamItem then
                local teamTeam = clone(tab:Team(id))
                local itemIcon = IconUtils:createSysTeamIconById({sysTeamData = teamTeam})
                itemIcon:setScale(0.6)
                itemIcon:setPosition((i-1)*width+self._iconPanel:getPositionX()+100,self._iconPanel:getPositionY())
                inView:addChild(itemIcon)
                inView["teamIcon" .. i] = itemIcon
            else
                local teamTeam = clone(tab:Team(id))
                IconUtils:updateSysTeamIconByView(teamItem,{sysTeamData = teamTeam})
            end
        end
    end
end



function FormationAppraiseDialog:onPopEnd(data)
    if 1 then
        return
    end
    local teamDetail = self._commentModel:getDetailDataByType(type_)
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

function FormationAppraiseDialog:reflashUI(data)
    self._teamCommentData = self._commentModel:getDataByType(type_)
    local teamDetail = self._commentModel:getDetailDataByType(type_)
    self._hotNum = table.nums(teamDetail.hList)
    
    if table.nums(self._teamCommentData) == 0 then
        self._noneBg:setVisible(true)
    else
        self._noneBg:setVisible(false)
    end
    -- dump(self._teamCommentData)
    print("refnum",table.nums(self._teamCommentData))
end

function FormationAppraiseDialog:addTableView()

    local tableViewBg = self._tableViewBg
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
    end
end


function FormationAppraiseDialog:scrollViewDidScroll(view)
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


function FormationAppraiseDialog:scrollViewDidZoom(view)

end

-- 触摸时调用
function FormationAppraiseDialog:tableCellTouched(table,cell)

end

-- cell的尺寸大小
function FormationAppraiseDialog:cellSizeForTable(table,idx)
    local width, height
    width = 730
    height = 80
    return height, width
end

-- 创建在某个位置的cell
local ccTableViewCell = cc.TableViewCell
function FormationAppraiseDialog:tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    local indexId = idx+1
    local param = self._teamCommentData[indexId]
    if nil == cell then
        cell = ccTableViewCell:new()
        local commentCell = self._cell_appraise:clone()
        commentCell:setPosition(6, 0)
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
function FormationAppraiseDialog:numberOfCellsInTableView(table)
    return self:tableNum()
end

function FormationAppraiseDialog:tableNum()
    return table.nums(self._teamCommentData)
end

function FormationAppraiseDialog:updateAppraiseCell(inView, param, indexId)
    if not param then
        return
    end
    local reping = inView:getChildByFullName("reping")
    local cellBg = inView:getChildByFullName("cellBg")
    local name = inView:getChildByFullName("name")
    local pingLab = inView:getChildByFullName("pingLab")
	local descImg = inView:getChildByFullName("descImg")
    -- local zanBg = inView:getChildByFullName("zanBg")
    -- local zanLab = inView:getChildByFullName("zanBg.lab")
    -- local zanIcon = inView:getChildByFullName("zanBg.icon")
	if self._hasSelfAppraise then
		self._hotNum = self._hotNum + 1
		
	end
--    if indexId <= self._hotNum then
        if reping then
            reping:setVisible(false)
        end
		descImg:setVisible(indexId==1 and self._hasSelfAppraise)
        if cellBg then
			if indexId==1 and self._hasSelfAppraise then
				cellBg:loadTexture("globalPanelUI7_cellBg0.png", 1)
			else
				cellBg:loadTexture("globalPanelUI7_cellBg1.png", 1)
			end
            cellBg:setCapInsets(cc.rect(41,41,1,20))
        end
    --[[else
        if reping then
            reping:setVisible(false)
        end
        if cellBg then
            cellBg:loadTexture("globalPanelUI7_cellBg1.png", 1)
            cellBg:setCapInsets(cc.rect(41,41,1,20))
        end
    end--]]

    -- local tempFlag = 0
    -- if param.aId and param.aId == 0 then
    --     zanLab:disableEffect()
    --     zanLab:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    -- elseif param.aId and param.aId == 1 then
    --     zanLab:disableEffect()
    --     zanLab:setColor(UIUtils.colorTable.ccUIBaseColor9)
    --     tempFlag = 1
    -- elseif param.aId and param.aId == 2 then
    --     zanLab:disableEffect()
    --     zanLab:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    --     tempFlag = 2
    -- end

    -- zanLab:setString(param.ag)
    
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
end

function FormationAppraiseDialog:updateCell(inView, param, indexId)
    self:updateAppraiseCell(inView, param, indexId)
end

function FormationAppraiseDialog:showTishi(flag)
    if flag == 1 then
        self._viewMgr:showTip("您已经对该评论点过赞")
    else
        self._viewMgr:showTip("您已经踩过该评论了")
    end
end

-- 规范名字格式
function FormationAppraiseDialog:formatName(nameStr, fontSize, outlineSize)
    if not nameStr then
        return ""
    end
    local subStr = self:limitLen(nameStr)
    return subStr
end

function FormationAppraiseDialog:limitLen(str)
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

function FormationAppraiseDialog:stringLenNum(str)
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


-- 评论
function FormationAppraiseDialog:commentMessage()
    if self._star < 2 then
        self._viewMgr:showTip(lang("hero_comment_2"))
        return
    end
    local teamDetail = self._commentModel:getDetailDataByType(type_)
    local cNum = teamDetail.cNum and tonumber(teamDetail.cNum) or 0
    local maxNum = tab:Setting("H_COMMENT_NUM7").value
    print("maxNum",maxNum,"cNum",cNum)
    if cNum >= maxNum then
        self._viewMgr:showTip(lang("hero_comment_10"))
        return
    end
    -- dump(teamDetail)
    local conLabel = self._commentTxt:getString()
    conLabel = string.gsub(conLabel, "^%s*(.-)%s*$", "%1")
    if conLabel == "" then
        self._viewMgr:showTip("输入内容为空")
        return
    end
    local userData = self._userModel:getData()
    local curServerTime = self._userModel:getCurServerTime()
    local ext = cjson.encode({cId = self._content.cId})
    
    local param = {ctype = 7, id = self._heroID, content = conLabel,ext = ext}
    self._serverMgr:sendMsg("CommentServer", "commentMessage", param, true, {}, function(result)
        -- dump(result, "result======", 10)
        -- self._viewMgr:showDialog("team.FormationAppraiseDialog", {teamId = self._curSelectTeam.teamId})
        self:addTableCell(conLabel, result["cId"])
        self._commentTxt:setString("")
        if self._star < 2 then
            self._commentTxt:setTouchEnabled(false)
            self._commentTxt:setPlaceHolder(" 拥有此英雄并达到2星后可进行评论")
        else
            self._commentTxt:setTouchEnabled(true)
            self._commentTxt:setPlaceHolder(lang("hero_comment_11"))
        end
		self._commentTxt:setColor(cc.c3b(255, 255, 255))
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
        elseif tonumber(errorId) == 4504 then
            local str = lang("COMTERM_NUM1")
            self._viewMgr:showTip(str)
        end
    end)
end

function FormationAppraiseDialog:addTableCell(conLabel, cId)
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
	
	if self._hasSelfAppraise then
        table.insert(self._teamCommentData, 2, tempValue)
	else
		table.insert(self._teamCommentData, 1, tempValue)
	end
	self._noneBg:setVisible(table.nums(self._teamCommentData)==0)
    
    self._appraiseTableVierw:reloadData()
end


return FormationAppraiseDialog
