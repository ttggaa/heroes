--[[
 	@FileName 	SiegeWallReinforceView.lua
	@Authors 	zhangtao
	@Date    	2017-09-19 15:43:31
	@Email    	<zhangtao@playcrad.com>
	@Description   描述
--]]
local createItemIconById = IconUtils.createItemIconById
local adjustIconScale    = IconUtils.adjustIconScale

local SiegeWallReinforceView = class("SiegeWallReinforceView",BasePopView)
function SiegeWallReinforceView:ctor(data)
    self.super.ctor(self)
    self._siegeModel = self._modelMgr:getModel("SiegeModel")
    self._callBack = data.callBack
    self:setListenReflashWithParam(true)
    self:listenReflash("SiegeModel", self.onModelReflash)

end

function SiegeWallReinforceView:onShow()
    self:updateRealVisible(true)
end

function SiegeWallReinforceView:onTop()
    self:updateRealVisible(true)
end

-- 初始化UI后会调用, 有需要请覆盖
function SiegeWallReinforceView:onInit()
	local pre = "bg.imageBg."
	local closeBtn = self:getUI(pre.."closeBtn")
	self:registerClickEvent(closeBtn,function()
        self:close()
        if self._callBack then self._callBack() end
        UIUtils:reloadLuaFile("siege.SiegeWallReinforceView")
	end)
	local imageBg = self:getUI(pre)
	imageBg:loadTexture("asset/bg/golbalIamgeUI5_hintBg.png")

	-- left
	pre = "bg.imageBg.leftBg."
	self._cityImage 	= self:getUI(pre.."cityImage")
	self._cityDes 		= self:getUI(pre.."cityDes")
	self._infoBtn		= self:getUI(pre.."infoBtn")
	self._nextOpenPart  = self:getUI(pre.."nextOpenPart")
	self._nextOpenImg   = self:getUI(pre.."nextOpenPart.img")
	self._nextOpenLabel = self:getUI(pre.."nextOpenPart.unLockLevel")

	-- right Top
	pre = "bg.imageBg.rightTop."
	self._wallLevel  = self:getUI(pre.."wallLevel")
	self._buildText2 = self:getUI(pre.."buildText2")

	self._hpNode 	  = self:getUI(pre.."hpNode")
	self._attackNode  = self:getUI(pre.."attackNode")
	self._hchNode 	  = self:getUI(pre.."hchNode")

	pre = "bg.imageBg.rightTop.BarBg."
	self._bar1      = self:getUI(pre.."bar1")
	self._bar2      = self:getUI(pre.."bar2")
	self._progress  = self:getUI(pre.."progressNode")
	self._bar2StarP = cc.p(self._bar2:getPosition())

	local progressTxt1 = self._progress:getChildByFullName("progressTxt1")
	local progressTxt3 = self._progress:getChildByFullName("progressTxt3")
	self._startPosX    = {progressTxt1:getPositionX(),progressTxt3:getPositionX()}

	-- right Bottom
	pre = "bg.imageBg.rightBottom."
	self._strengthenBtn = self:getUI(pre.."strengthenBtn")
	self._itemTp 		= self:getUI(pre.."itemTp")
	self._itemNode 		= self:getUI(pre.."itemNode")

	self:registerClickEvent(self._infoBtn,function ()
		self:clickInfoBtn()
	end)

	self:registerClickEvent(self._nextOpenPart,function ()
		self:clickInfoBtn()
	end)

	self:registerClickEvent(self._strengthenBtn,function ()
		self:clickStrengthenBtn()
	end)
end

function SiegeWallReinforceView:updateNextOpen()
	local isShowNext = false
	local isShowInfo = false
	local img = self._nextOpenPart:getChildByFullName("img")
	local txt = self._nextOpenPart:getChildByFullName("unLockLevel")
	local baseOpenLevel, defenceOpenLevel = self._siegeModel:getSiegeWallOpenLevel()
	if self._currLevel < baseOpenLevel then
		local cfg = self._siegeModel:getSiegeWallCfg(baseOpenLevel)
		local res = cfg.baseResource..".png"
		img:loadTexture(res,1)
		isShowNext = true
		txt:setString(baseOpenLevel.."级开启")
		adjustIconScale(self,self._nextOpenPart,img)
	elseif self._currLevel < defenceOpenLevel then
		local cfg = self._siegeModel:getSiegeWallCfg(defenceOpenLevel)
		local res = cfg.defenceResource..".png"
		img:loadTexture(res,1)
		isShowNext = true
		txt:setString(defenceOpenLevel.."级开启")
		adjustIconScale(self,self._nextOpenPart,img)
	else
		isShowNext = false
		isShowInfo = true
	end
	self._nextOpenPart:setVisible(isShowNext)
	self._infoBtn:setVisible(isShowInfo)
	img:setVisible(isShowNext)
end

function SiegeWallReinforceView:updateLeftUI()
	self:updateNextOpen()
	local todayTotal = self._siegeModel:getTodayTotalAccumulation()
	local today      = self._siegeModel:getTodayAccumulation()
	local percent    = self._siegeModel:getPercentBeyondOthers()
	-- local progress   = nil
	-- if todayTotal ~= 0 then
	-- 	progress = 100*today/todayTotal
	-- else
	-- 	progress = 0
	-- end 
	
	-- local des = "今日已贡献修建进度:"..progress..",超越了全服"..percent.."%的领主请再接再厉！"
	local bgImage = self:getUI("bg.imageBg.leftBg")
	if bgImage.rtxDes then
		bgImage.rtxDes:removeFromParent()
		bgImage.rtxDes = nil
	end
    local str1 = "[color=DFB0A0,fontsize=20]今日已贡献修建进度：[-]"
    local str2 = "[color=32CD32,fontsize=20]"..today.."[-]"
    local str3 = "[color=DFB0A0,fontsize=20]，超越了全服[-]"
    local str4 = "[color=DFB0A0,fontsize=20]"..percent.."[-]"
    local str5 = "[color=DFB0A0,fontsize=20]%的领主请再接再厉！[-]"
	local rtxStr = str1 .. str2 .. str3 .. str4 .. str5
    local rtxDes = RichTextFactory:create(rtxStr,300,60)
    rtxDes:formatText()
    rtxDes:setVerticalSpace(0)
    rtxDes:setAnchorPoint(cc.p(0.5,0.5))
    
    local w = bgImage:getContentSize().width
    local h = bgImage:getContentSize().height
    bgImage.rtxDes = rtxDes
    rtxDes:setPosition(cc.p(w/2+10,60))
    bgImage:addChild(rtxDes)

	-- self._cityDes:setString(des)
end

function SiegeWallReinforceView:updateRightUI()
	self:updateRightTop()
	self:updateRightBottom()
end

function SiegeWallReinforceView:updateAttr()
	local cfg = self._cfgDatas
	local updateSigle = function (node, title, value, add, color)
		local txt       = node:getChildByFullName("txt")
		local valueNode = node:getChildByFullName("value")
		local addNode   = node:getChildByFullName("add")
		valueNode:setString(value)
		addNode:setString("("..add..")")
		if add == "" then
			addNode:setString("")
		end 
		addNode:setColor(color)
		txt:setString(title)
	end

	local isReachMaxLevel = self._siegeModel:isWallReachMaxLevel(self._currLevel)

	local attrrDatas = self._siegeModel:getWallAttrrDatas()
	local baseOpenLevel, defenceOpenLevel = self._siegeModel:getSiegeWallOpenLevel()

	local color = cc.c4b(66,255,35,255)
	local lockColor = cc.c4b(176,175,175,255)

	local key 	  = self._currLevel
	local nextKey = self._currLevel + 1


	local value   = attrrDatas[key].wallValue
	local add = ""
	if attrrDatas[nextKey] then
		add = attrrDatas[nextKey].wallValue - value
		add = "下级+" .. add
	end 
	local title = lang("SIEGE_EVENT_WALLTITLE1")
	updateSigle(self._hpNode, title, value, add, color)

	value = attrrDatas[key].arrowValue
	add = ""
	if attrrDatas[nextKey] then
		add  = attrrDatas[nextKey].arrowValue - value
		add  = "下级+"..add
	end 

	local tips = "级解锁"
	if cfg.baseIsOpen == 0 then
		add   = baseOpenLevel .. tips
		color = lockColor
	end 
	title = lang("SIEGE_EVENT_WALLTITLE2")
	updateSigle(self._attackNode, title, value, add, color)

	value = attrrDatas[key].hchValue
	add = ""
	if attrrDatas[nextKey] then
		add   = attrrDatas[nextKey].hchValue - value
		add   = "下级+"..add
	end 

	if add ~= "" then
		add = add .. "%"
	end 
	value = value .. "%"

	if cfg.defenceIsOpen == 0 then
		add   = defenceOpenLevel .. tips
		color = lockColor
	end 
	title = lang("SIEGE_EVENT_WALLTITLE3")
	updateSigle(self._hchNode, title, value, add, color)

end

function SiegeWallReinforceView:updateProgressTxt(todayTotal, yesterdayTotal)
	local progressTxt1 = self._progress:getChildByFullName("progressTxt1")
	local progressTxt2 = self._progress:getChildByFullName("progressTxt2")
	local progressTxt3 = self._progress:getChildByFullName("progressTxt3")
	progressTxt1:setString(yesterdayTotal)
	progressTxt2:setString("(+".. todayTotal ..")")
	progressTxt3:setString("/".. self._cfgDatas.exp)
	progressTxt1:setPositionX(self._startPosX[1] - progressTxt2:getSize().width - 10)
	progressTxt3:setPositionX(self._startPosX[2] + progressTxt2:getSize().width + 10)
	progressTxt1:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
	progressTxt2:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
	progressTxt3:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

	progressTxt1:setVisible(not self._isMaxLevel)
	progressTxt3:setVisible(not self._isMaxLevel)
	if self._isMaxLevel then
		progressTxt2:setString("Max")
	end 
	UIUtils:alignNodesToPos({progressTxt1,progressTxt2,progressTxt3},200)
	
end

function SiegeWallReinforceView:updateRightTop()
	self._wallLevel:setString(self._currLevel.."级城墙")

	local todayTotal = self._siegeModel:getTodayTotalAccumulation()
	self._buildText2:setString("+"..todayTotal)
	if self._isMaxLevel then
		self._buildText2:setVisible(false)
		local pre = "bg.imageBg.rightTop."
		local buildText1 = self:getUI(pre.."buildText1")
		local buildText3 = self:getUI(pre.."buildText3")
		buildText1:setVisible(false)
		buildText3:setVisible(false)
	end

    local nodePosX,nodePosY = self._buildText2:getPosition()
    local anchorPointX = self._buildText2:getAnchorPoint().x
    local contsizeWidth = self._buildText2:getContentSize().width
    local buildText3 = self:getUI("bg.imageBg.rightTop.buildText3")
    buildText3:setPosition(nodePosX + (1-anchorPointX)*contsizeWidth , nodePosY)

	local accumulationYesterday = self._siegeModel:getAccumulationYesterday()
	local ra = accumulationYesterday/self._cfgDatas.exp
	self._bar1:setPercent(100*ra)
	self._bar2:setPercent(100*math.min(todayTotal/self._cfgDatas.exp, 1-ra))
	local posX = self._bar2StarP.x + ra * self._bar1:getSize().width
	self._bar2:setPositionX(posX)

	self:updateProgressTxt(todayTotal, accumulationYesterday)
	self:updateAttr()
end

function SiegeWallReinforceView:updateRightBottom()
	local buildMaterals = self._siegeModel:getWallBuildMaterial()
    self._itemNode:removeAllChildren()
    local offset = 15
    local itemModel = self._modelMgr:getModel("ItemModel")
    self._strengthItem = {}
    for i,v in ipairs(buildMaterals) do
    	local id = v
        local itemData = {}
        local itemIcon = nil
        
        itemData = tab:Tool(id)
        local _,count = itemModel:getItemsById(id)
        table.insert(self._strengthItem,count)
        local itemRedFlag = itemModel:approatchIsOpen(id)
        local suo = nil
        if count == 0 then
        	suo = 2
        end 
        itemIcon = createItemIconById(self, {itemId = id, suo = suo,num = count, itemData = itemData,
	            		eventStyle = 3,clickCallback = function( )
	                    self._viewMgr:showDialog("bag.DialogAccessTo", {goodsId = id, callback = function ()
	                    	self:reflashUI()
	                    end}, true)
            		end})
        
        if itemIcon then
            local itemTp = self._itemTp:clone()
            itemTp:addChild(itemIcon)
            local posX = (i-1)*itemTp:getContentSize().width + (i-1)*offset
            itemTp:setPositionX(posX)
            adjustIconScale(self, itemTp, itemIcon)
            self._itemNode:addChild(itemTp)
        end 
    end
end

-- 接收自定义消息
function SiegeWallReinforceView:reflashUI(data)
	local currLevel  = self._siegeModel:getWallCurLevel()
	self._currLevel  = currLevel
	self._isMaxLevel = self._siegeModel:isWallReachMaxLevel(currLevel)

	-- 满级判断
	local maxLevelNode = self:getUI("bg.imageBg.rightTop.maxLevelNode")
	maxLevelNode:setVisible(self._isMaxLevel) 
	self._cfgDatas   = self._siegeModel:getSiegeWallCfg(currLevel)
	self:updateLeftUI()
	self:updateRightUI()
end

function SiegeWallReinforceView:clickInfoBtn()
	print("click info btn")
	self._viewMgr:showDialog("siege.SiegeFunctionOpenView",{level = self._currLevel})
end

function SiegeWallReinforceView:clickStrengthenBtn()
	print("click strenghen btn")

	local cityState = self._siegeModel:getData().status
	if cityState == self._siegeModel.STATUS_PREOVER or cityState == self._siegeModel.STATUS_OVER then
		self._viewMgr:showTip(lang("TIPS_SIEGE_WARNINGTIPS4"))
		return
	end
	if self._strengthItem then
		local isHasItem = false
		for i,v in ipairs(self._strengthItem) do
			if v ~= 0 then
				isHasItem = true
				break
			end 
		end
		if not isHasItem then
			self._viewMgr:showTip(lang("TIPS_SIEGE_WARNINGTIPS3"))
			return
		end
	end
	self._serverMgr:sendMsg("SiegeServer", "fixTheWall", {}, true, {},function (success,result)
        if success then
        	local reward = result.reward
        	-- local sumExp = result.sumExp
        	local aniEndCallBack = function()
                DialogUtils.showGiftGet({gifts = reward, callback = function() 
                end})
            end
            self:strengthenAni(aniEndCallBack)
        end 
    end)
end

function SiegeWallReinforceView:strengthenAni(callBack)
    local mc1 = mcMgr:createViewMC("chengchijianzhao_kaiqi", false, true,function()
    end)
    mc1:setPosition(cc.p(self._progress:getPositionX()+40,self._progress:getPositionY()+self._progress:getContentSize().height+10))
    mc1:setName("chengchijianzhao")
    self._progress:addChild(mc1,10)

    local mc2 = mcMgr:createViewMC("jindutiaozhang_teamqianneng", false, true)
    mc2:setPosition(cc.p(self._progress:getPositionX()+1,self._progress:getPositionY()+self._progress:getContentSize().height-23))
    mc2:setName("chengchijianzhao")
    mc2:setScale(1.27)
    self._progress:addChild(mc2,1)

    local todayTotal = self._siegeModel:getAddExpSingle()

    local addText = cc.Label:createWithTTF("+"..todayTotal,UIUtils.ttfName, 30)
    addText:setColor(cc.c3b(39, 247, 58))
    addText:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    addText:setPosition(cc.p(self._progress:getPositionX()+1,self._progress:getPositionY()+self._progress:getContentSize().height-10))
    self._progress:addChild(addText,11)
    addText:setVisible(false)
    addText:runAction(cc.Sequence:create(
        cc.DelayTime:create(0.25),
        cc.Spawn:create(
            cc.CallFunc:create(function ()
                    addText:setVisible(true)
                end),
            cc.ScaleTo:create(0.1,1.2)
        ),
        cc.DelayTime:create(0.5),
        cc.Spawn:create(
            cc.MoveBy:create(0.3,cc.p(0,70)),
            cc.FadeOut:create(0.2)
        )
        ,cc.RemoveSelf:create()
    ))

    ScheduleMgr:delayCall(300, self, function( )
        self:reflashUI()
    end)
    ScheduleMgr:delayCall(1100, self, function( )
        callBack()
    end)
end


function SiegeWallReinforceView:_clearVars()
	self._cityImage 	= nil
	self._cityDes 		= nil
	self._infoBtn       = nil
	self._nextOpenPart  = nil
	self._nextOpenImg   = nil
	self._nextOpenLabel = nil
	self._wallLevel  	= nil
	self._buildText2 	= nil
	self._hpNode 	  	= nil
	self._attackNode  	= nil
	self._hchNode 	  	= nil
	self._bar1     		= nil
	self._bar2     		= nil
	self._progress 		= nil
	self._strengthenBtn = nil
	self._itemTp 		= nil
	self._itemNode 		= nil
	self._strengthenBtn = nil
	self._startPosX		= nil
	self._strengthItem  = nil
	self._bar2StarP     = nil
	self._isMaxLevel    = nil
end

function SiegeWallReinforceView.dtor()
	createItemIconById = nil
	adjustIconScale    = nil
end

function SiegeWallReinforceView:onDestroy()
	self:_clearVars()
	SiegeWallReinforceView.super.onDestroy(self)
end

function SiegeWallReinforceView:getAsyncRes()
    return {{"asset/ui/guildMapbuild.plist", "asset/ui/guildMapbuild.png"}}
end

function SiegeWallReinforceView:onModelReflash(eventName)
    if eventName == "refleshWallLVEvent" then
        self:reflashUI()
    end
end

return SiegeWallReinforceView