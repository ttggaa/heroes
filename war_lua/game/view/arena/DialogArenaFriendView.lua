--
-- Author: <wangguojun@playcrab.com>
-- Date: 2017-01-09 21:20:10
--
local DialogArenaFriendView = class("DialogArenaFriendView",BasePopView)
function DialogArenaFriendView:ctor(param)
    self.super.ctor(self)
    param = param or {}
    self._friends = param.friends or {}
    self._rankTab = param.rankTab or 10000
end

-- 初始化UI后会调用, 有需要请覆盖
function DialogArenaFriendView:onInit()
	self:registerClickEventByName("bg.closeBtn",function() 
		self:close()
		UIUtils:reloadLuaFile("arena.DialogArenaFriendView")
	end)
	self._scrollView = self:getUI("bg.scrollView")
	UIUtils:setTitleFormat(self:getUI("bg.title_bg.title"),1)

    self._cell = self:getUI("cell")
    self._cell:setVisible(false)

    local vipLab = self:getUI("cell.vipLab")
    vipLab:setFntFile(UIUtils.bmfName_vip)
    vipLab:setVisible(false)

    self:addTableView()
end

-- 第一次进入调用, 有需要请覆盖
function DialogArenaFriendView:onShow()

end

-- 接收自定义消息
function DialogArenaFriendView:reflashUI(data)
    dump(self._friends)
    self._tableView:reloadData()

    local ranklimLab = self:getUI("bg.ranklimLab")
    ranklimLab:setString("排名达到" .. self._rankTab .. "的好友")
    
	-- if not next(self._friends) then return end
	-- -- for i=1,2 do
	-- -- 	table.insert(self._friends,self._friends[i])
	-- -- end
	-- local col = 5
 --    local avatarSize = 120
 --    -- local maxHeight = 100 -- 两个title高40 计算
 --    local titleHeight = 50
 --    local scrollWidth = self._scrollView:getContentSize().width
 --    local scrollHeight = self._scrollView:getContentSize().height

 --    local heroBgHeight = math.ceil(#self._friends/col)*avatarSize+10
 --    -- maxHeight = maxHeight+heroBgHeight 
 --    heroBgHeight = math.max(heroBgHeight,scrollHeight)

 --    self._scrollView:setInnerContainerSize(cc.size(scrollWidth,heroBgHeight))
	-- local x,y = 0,0
	-- for i,v in ipairs(self._friends) do
	-- 	x,y = ((i-1)%col)*(avatarSize-20)+6,heroBgHeight-math.floor((i-1)/col+1)*avatarSize+12
	-- 	local icon = IconUtils:createUrlHeadIconById({url = v.picUrl,openid=i})
	-- 	icon:setPosition(x,y)
	-- 	self._scrollView:addChild(icon)
	-- 	local name = ccui.Text:create()
	-- 	name:setFontSize(20)
	-- 	name:setFontName(UIUtils.ttfName)
	-- 	name:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
	-- 	name:setPosition(x+50,y-10)
	-- 	name:setString(v.nickName or " ")
	-- 	self._scrollView:addChild(name,99)
	-- end
end


function DialogArenaFriendView:updateCell(inView, data, indexId)
    if data == nil then
        return
    end

    local iconBg = inView:getChildByFullName("iconBg")
    if iconBg then
        local param1 = {url = data.picUrl,openid=data.openid or indexId,tp=4}
        local icon = iconBg:getChildByName("icon")
        if not icon then
            icon = IconUtils:createUrlHeadIconById(param1)
            icon:setScale(0.8)
            icon:setName("icon")
            icon:setPosition(cc.p(-5, -5))
            iconBg:addChild(icon)
        else
            IconUtils:updateUrlHeadIconByView(icon, param1)
        end
    end

    local nickName = inView:getChildByFullName("name")
    if nickName then
        nickName:setString(data.nickName)
        local nameLen = utf8.len(data.nickName)
        if nameLen > 7 then
            local name = utf8.sub(data.nickName,1,7) .. "..."
            nickName:setString(name)
        end
    end

    local vipImg = inView:getChildByFullName("vipImg")
    if vipImg then
        if data.vipLvl == 0 then
            vipImg:setVisible(false)
        else
            vipImg:loadTexture("chatPri_vipLv" .. data.vipLvl .. ".png", 1)
            vipImg:setVisible(true)
        end
    end

    local secLab = inView:getChildByFullName("secLab")
    if secLab then
        secLab:setString(data.secName)
    end
end

--[[
用tableview实现
--]]
function DialogArenaFriendView:addTableView()
    local tableViewBg = self:getUI("bg.tableViewBg")
    self._tableView = cc.TableView:create(cc.size(tableViewBg:getContentSize().width, tableViewBg:getContentSize().height))
    self._tableView:setDelegate()
    self._tableView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    self._tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._tableView:setPosition(cc.p(0, 0))
    self._tableView:registerScriptHandler(function(table, cell) return self:tableCellTouched(table,cell) end,cc.TABLECELL_TOUCHED)
    self._tableView:registerScriptHandler(function(table, idx) return self:cellSizeForTable(table,idx) end,cc.TABLECELL_SIZE_FOR_INDEX)
    self._tableView:registerScriptHandler(function(table, idx) return self:tableCellAtIndex(table, idx) end,cc.TABLECELL_SIZE_AT_INDEX)
    self._tableView:registerScriptHandler(function(table) return self:numberOfCellsInTableView(table) end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._tableView:setBounceable(true)
    
    -- if self._tableView.setDragSlideable ~= nil then 
    --     self._tableView:setDragSlideable(true)
    -- end
    tableViewBg:addChild(self._tableView)
end


-- 触摸时调用
function DialogArenaFriendView:tableCellTouched(table,cell)

end

-- cell的尺寸大小
function DialogArenaFriendView:cellSizeForTable(table,idx) 
    local width = 636 
    local height = 115
    return height, width
end

-- 创建在某个位置的cell
function DialogArenaFriendView:tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    local param = self._friends[idx + 1] -- {typeId = 3, id = 1}
    local indexId = idx + 1
    if nil == cell then
        cell = cc.TableViewCell:new()
        local logCell = self._cell:clone() -- self._viewMgr:createLayer("guild.GuildInCell")
        logCell:setAnchorPoint(cc.p(0,0))
        logCell:setPosition(cc.p(-1,-5))
        logCell:setVisible(true)
        logCell:setName("logCell")
        cell:addChild(logCell)

        -- local fight = cc.LabelBMFont:create("a1", UIUtils.bmfName_zhandouli_little)
        -- fight:setName("addfight")
        -- fight:setScale(0.8)
        -- fight:setAnchorPoint(cc.p(0,0.5))
        -- fight:setPosition(cc.p(103, 35))
        -- logCell:addChild(fight, 1)

        local nickName = logCell:getChildByFullName("name")
        UIUtils:setTitleFormat(nickName, 2)
    end

    local logCell = cell:getChildByName("logCell")
    if logCell then
        self:updateCell(logCell, param, indexId)
        logCell:setSwallowTouches(false)
    end

    return cell
end

-- 返回cell的数量
function DialogArenaFriendView:numberOfCellsInTableView(table)
    return self:tableNum() 
end

function DialogArenaFriendView:tableNum()
    return table.nums(self._friends)
end

return DialogArenaFriendView