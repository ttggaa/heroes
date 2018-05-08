--
-- Author: <wangguojun@playcrab.com>
-- Date: 2017-08-05 19:21:14
--
local TreasureSelectFormDialog = class("TreasureSelectFormDialog",BasePopView)
function TreasureSelectFormDialog:ctor(param)
    self.super.ctor(self)
    self._tFModel   	 = self._modelMgr:getModel("TformationModel")
    self._formationId 	 = param and param.formationId
    self._formationModel = self._modelMgr:getModel("FormationModel")
    self._formationData  = self._formationModel:getFormationDataByType(self._formationId) or {}
    self._tFormId		 = param and param.tFormId

    self._callback 		 = param and param.callback
end

-- 初始化UI后会调用, 有需要请覆盖
function TreasureSelectFormDialog:onInit()
	self:registerClickEventByName("bg.closeBtn", function()
        self:close()
        UIUtils:reloadLuaFile("treasure.TreasureSelectFormDialog")
    end )
	-- 监听事件
    self:listenReflash("TformationModel",function( )
    	self:reflashUI()
    end)
    self._scrollView = self:getUI("bg.scrollView")
    self._cell = self:getUI("bg.cell")
end

-- 接收自定义消息
function TreasureSelectFormDialog:reflashUI(data)
    local formInfo = self._tFModel:getData()
    local formNum = table.nums(formInfo)
    self._scrollView:removeAllChildren()
    local cellW,cellH = self._cell:getContentSize().width,self._cell:getContentSize().height
    cellW = cellW+3
    cellH = cellH+3
    local x,y = 0,0
    local height = 250
    local offsetX,offsetY = 2,5
    for i=1,8 do
    	local formD = formInfo[i]
    	local cell = self:createFormCell(formD,i)
    	x = (i-1)%2*cellW
    	y = height - math.floor((i-1)/2)*cellH
    	cell:setPosition(x+offsetX,y+offsetY)
    	self._scrollView:addChild(cell)
    end
end

function TreasureSelectFormDialog:createFormCell( data,idx )
	-- dump(data,"dzrta...data.....")
	local cell = self._cell:clone()
	cell:setVisible(true)
	local lock = cell:getChildByFullName("lock")
	local lockDes = lock:getChildByFullName("des")
	local btn = cell:getChildByFullName("btn")
	local onUse = cell:getChildByFullName("onUse")
	local tname = cell:getChildByFullName("tname")
	tname:setVisible(idx == 1 and true or data ~= nil)
	lock:setVisible(not data)
	if idx == 1 then lock:setVisible(false) end

	if data then 
		local tformationName = data.name 
		if not data.name or data.name == "" then
			tformationName = "宝物编组".. idx
		end
		tname:setString(tformationName)
		self:registerClickEvent(btn, function()
			if not self._formationId then
				if self._callback then
					self._callback(idx)
					self:close()
				end
				return 
			end
	        self._serverMgr:sendMsg("FormationServer", "changeTformation", {id=self._formationId,tid=idx}, true, { }, function(result)
        		self._formationData  = self._formationModel:getFormationDataByType(self._formationId)
        		self._tFormId = idx
        		self:reflashUI()
        		if self._callback then
					self._callback(idx)
					-- self:close()
				end
		    end)
	    end)
	else
		lockDes:setString("编组名".. idx .."\n尚未解锁")
		btn:loadTextures("globalButtonUI13_3_2.png","globalButtonUI13_3_2.png",nil,1)
		btn:setTitleText("解锁")
		self:registerClickEvent(btn, function()
	        self:sendUnlockMsg(idx)
	    end)
	end
	self:L10N_Text(btn)
	print("self._tFormId == idx",self._tFormId, idx)
	local inUse = self._tFormId == idx
	btn:setVisible(not inUse)
	onUse:setVisible(inUse)
	return cell
end

function TreasureSelectFormDialog:sendUnlockMsg()
	-- 添加编组
	local slotMaxNum = tab.setting["G_BUY_TREASURE_SKILLSLOT"].value
	local formNum
	for i=1,slotMaxNum do
		if not self._tFModel:getTFormDataById(i) then
			formNum = i 
			break
		end
	end

	if not formNum or formNum > slotMaxNum then
		self._viewMgr:showTip("编组已满")
		return 
	end
	local costFormNum = math.max(formNum,2)
	local cost = tab.reflashCost[costFormNum] and tab.reflashCost[costFormNum].unlockTskill
	local gem = self._modelMgr:getModel("UserModel"):getData().gem 
	if gem < cost then
		DialogUtils.showNeedCharge({desc = "钻石不足，是否前去充值",callback1=function( )
            -- print("充值去！")
            local viewMgr = ViewManager:getInstance()
            viewMgr:showView("vip.VipView", {viewType = 0})
        end})
		return
	end
	local descStr =  "[color=462800,fontsize=24]是否使用[pic=globalImageUI_littleDiamond.png][-][color=3d1f00,fontsize=24]" .. (cost or 0) 
					.. "[-][-]" .. "[color=462800,fontsize=24]".. "解锁宝物编组" .. costFormNum .."[-]"
	self._viewMgr:showSelectDialog( descStr, "", function( )
			local param = {id = formNum}
			if formNum == 1 then
		        local param = {id = 2}
		        self._serverMgr:sendMsg("TformationServer", "openFormation", param, true, { }, function(result)
			        if callback then 
			        	callback()
			        end
			    end)
			else
				self._serverMgr:sendMsg("TformationServer", "openFormation", param, true, { }, function(result)
			        if callback then 
			        	callback()
			        end
			    end)
			end
		end, 
    "", nil)
end

return TreasureSelectFormDialog