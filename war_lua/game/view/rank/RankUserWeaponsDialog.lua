--
-- Author: huangguofang
-- Date: 2017-09-26 21:01:21
--

local RankUserWeaponsDialog = class("RankUserWeaponsDialog",BasePopView)
function RankUserWeaponsDialog:ctor(params)
    self.super.ctor(self)
    self._weaponData = params.weaponData
    self._userData = params
end

-- 初始化UI后会调用, 有需要请覆盖
function RankUserWeaponsDialog:onInit()

	self:registerClickEventByName("bg.closeBtn", function(  )
		self:close()
        UIUtils:reloadLuaFile("rank.RankUserWeaponsDialog")
	end)

	self._bg = self:getUI("bg")
	self._title = self:getUI("bg.title_img.title_txt")
    UIUtils:setTitleFormat(self._title, 1)

    self._userHead = self:getUI("bg.userHead")
    self:updateUserHead(self._userHead)

    self._nameBg = self:getUI("bg.nameBg")
    self._nameBg:setContentSize(1,1)
	self._name = self:getUI("bg.name")
	UIUtils:setTitleFormat(self._name, 2)
	self._name:setString(self._userData.name or "")

	self._rank = self:getUI("bg.rank")
	-- self._rank:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
    local rank = (self._userData.rank and self._userData.rank > 0) and self._userData.rank or "暂无排名" 
	self._rank:setString(rank)

    -- self._userData["tequan"] = "sq_gamecenter"
	local tequanImg = IconUtils.tencentIcon[self._userData["tequan"]] or "globalImageUI6_meiyoutu.png"
	local tequanIcon = ccui.ImageView:create(tequanImg, 1)
    tequanIcon:setPosition(658, 419)
	self._bg:addChild(tequanIcon)
    tequanIcon:setScaleAnim(true)

    if tequanImg ~= "globalImageUI6_meiyoutu.png" then
        self:registerClickEvent(tequanIcon,function( sender )
            self._viewMgr:showDialog("tencentprivilege.TencentPrivilegeView")
        end)
    end

    self._siegeListData = tab.siegeWeaponType
    self._weaponCell = self:getUI("weaponCell")
    self._weaponCell:setVisible(false)
    self:addTableView()
end

--添加玩家头像
function RankUserWeaponsDialog:updateUserHead(userHead)
	local avtar = self._userData.avatar
	if not avtar or avtar == 0 then
		avtar = 1203
	end 
    if not self._avatar then
        local tencetTp = self._userData["qqVip"]
        self._avatar = IconUtils:createHeadIconById({avatar = avtar,level = tonumber(self._userData.level) or tonumber(self._userData.lvl) or "0" ,tp = 4 ,avatarFrame = self._userData["avatarFrame"], tencetTp = tencetTp})
        self._avatar:setPosition(cc.p(-1,-1))
        self._userHead:addChild(self._avatar)
    end
end
-- 接收自定义消息
function RankUserWeaponsDialog:reflashUI(data)
    
    self:progressData()

    self._tableView:reloadData()
end

function RankUserWeaponsDialog:progressData()
    self._unlockIds = {}
    -- dump(self._weaponData,"self._weaponData==>",5)
    for k,v in pairs(self._weaponData) do
        local unlockIds = v.unlockIds
        local score = 0
        if unlockIds then
            for kk,vv in pairs(unlockIds) do
                local indexId = tonumber(kk)
                self._unlockIds[indexId] = vv
                -- 基础值取一个器械的战力
                score = vv
                -- break
            end
        end
        -- local score = 0
        -- if unlockIds then
        --     for kk,vv in pairs(unlockIds) do
        --         local indexId = tonumber(kk)
        --         self._unlockIds[indexId] = vv
        --         score = score + vv
        --     end
        -- end

        for i=1,4 do
            if v["sp" .. i] and type(v["sp" .. i]) == "table" then
                local spScore = v["sp" .. i].score
                if spScore then
                    score = score + spScore
                end
            end
        end
        v.score = score
    end
end


--[[
用tableview实现5
--]]
function RankUserWeaponsDialog:addTableView()
    local tableViewBg = self:getUI("bg.tableViewBg")
    local theight = tableViewBg:getContentSize().height + 10
    self._tableView = cc.TableView:create(cc.size(tableViewBg:getContentSize().width, theight))
    self._tableView:setDelegate()
    self._tableView:setDirection(1)
    self._tableView:setVerticalFillOrder(cc.TABLEVIEW_FILL_TOPDOWN)
    self._tableView:setPosition(0, -6)
    self._tableView:registerScriptHandler(function(table, idx) return self:cellSizeForTable(table,idx) end,cc.TABLECELL_SIZE_FOR_INDEX)
    self._tableView:registerScriptHandler(function(table, idx) return self:tableCellAtIndex(table, idx) end,cc.TABLECELL_SIZE_AT_INDEX)
    self._tableView:registerScriptHandler(function(table) return self:numberOfCellsInTableView(table) end,cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    self._tableView:setBounceable(true)
    -- self._tableView:reloadData()
    -- if self._tableView.setDragSlideable ~= nil then 
    --     self._tableView:setDragSlideable(true)
    -- end
    tableViewBg:addChild(self._tableView)
end

-- 返回cell的数量
function RankUserWeaponsDialog:numberOfCellsInTableView(table)
   return self:getTableNum()
end

function RankUserWeaponsDialog:getTableNum()
   return table.nums(self._siegeListData)
end

-- cell的尺寸大小
function RankUserWeaponsDialog:cellSizeForTable(table,idx) 
    return 150, 100
end

-- 创建在某个位置的cell
function RankUserWeaponsDialog:tableCellAtIndex(table, idx)
    local cell = table:dequeueCell()
    local indexId = idx + 1
    local param = self._siegeListData[indexId]
    if nil == cell then
        cell = cc.TableViewCell:new()
        local listCell = self._weaponCell:clone()
        listCell:setName("listCell")
        listCell:setVisible(true)
        listCell:setAnchorPoint(0, 0)
        listCell:setPosition(0, 0)
        cell:addChild(listCell)
        cell._listCell = listCell

        local zhandouliLab = cc.LabelBMFont:create("", UIUtils.bmfName_zhandouli_little)
        zhandouliLab:setName("zhandouli")
        zhandouliLab:setAnchorPoint(1,0.5)
        zhandouliLab:setScale(0.6)
        zhandouliLab:setPosition(500, 135)
        listCell:addChild(zhandouliLab, 100)
        listCell.zhandouliLab = zhandouliLab
    end

    local listCell = cell._listCell
    self:updateCell(listCell, indexId, param)

    return cell
end


function RankUserWeaponsDialog:updateCell(inView, indexId, weaponsData)
    print("==========", weaponsData, indexId)
    local weaponsId = weaponsData.weaponId
    local userWeapon = self._weaponData[tostring(indexId)]
    local level = (userWeapon and userWeapon.lv) and userWeapon.lv or 0
    for i=1,5 do
        local weaponIcon = inView["weaponIcon" .. i] -- inView:getChildByName("weaponIcon" .. i)
        if i <= table.nums(weaponsId) then
            local weaponId = weaponsId[i]
            local weaponsTab = tab:SiegeWeapon(weaponId)
            local suo = true
            local tlevel
            if self._unlockIds[weaponId] then
                suo = false
                tlevel = level
            end
            local param = {weaponsTab = weaponsTab, suo = suo, level = tlevel}
            if not weaponIcon then
                weaponIcon = IconUtils:createWeaponsIconById(param)
                weaponIcon:setName("weaponIcon" .. i)
                weaponIcon:setScale(0.9)
                weaponIcon:setPosition(12+100*(i-1), 15)
                inView:addChild(weaponIcon)
                inView["weaponIcon" .. i] = weaponIcon
            else
                IconUtils:updateWeaponsIcon(weaponIcon, param)
            end
            weaponIcon:setVisible(true)

            local clickFlag = false
            local downY
            local posX, posY
            registerTouchEvent(
                weaponIcon,
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
                    if clickFlag == false then 
                        if suo == true then
                            self._viewMgr:showTip("该器械未解锁")
                        else
                            print("==========打开详情=============")
                            local param = {userWeapon = userWeapon, weaponId = weaponId, weaponType = indexId}
                            self._viewMgr:showDialog("rank.RankWeaponsDetailView", param)
                        end
                    end
                end,
                function ()
                end)
            weaponIcon:setSwallowTouches(false)
        else
            if weaponIcon then
                weaponIcon:setVisible(false)
            end
        end
    end

    local wname = inView:getChildByName("wname")
    local itemStr = lang(weaponsData.name)
    wname:setString(itemStr)

    local zhandouliLab = inView.zhandouliLab
    local wscore = (userWeapon and userWeapon.score) and userWeapon.score or 0
    zhandouliLab:setString("a" .. wscore)
end


return RankUserWeaponsDialog
