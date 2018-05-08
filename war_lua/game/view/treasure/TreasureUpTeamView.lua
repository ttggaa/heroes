--
-- Author: <wangguojun@playcrab.com>
-- Date: 2017-02-01 20:16:26
--
local TreasureUpTeamView = class("TreasureUpTeamView",BasePopView)
function TreasureUpTeamView:ctor(param)
    self.super.ctor(self)
    self._buffId	= param.buffId
    self._buffValue = param.buffValue
    self._volume 	= param.volume
    self._callback 	= param.callback
    self._items 	= {}
end

-- 加载资源
-- function TreasureUpTeamView:getAsyncRes()
--     return 
--     {
--         {"asset/ui/battle.plist", "asset/ui/battle.png"},        
--     }
-- end
function TreasureUpTeamView:getMaskOpacity()
    return 230
end

-- 初始化UI后会调用, 有需要请覆盖
function TreasureUpTeamView:onInit()
	self._closePanel = self:getUI("closePanel")
    -- self._closePanel:setSwallowTouches(false)
    self._isCloseClick = false
    self._buffDeses = {}
    self._bg1 = self:getUI("bg.bg1")
    self._bg1:setSwallowTouches(false)
    self._bg1:setScale9Enabled(true)
    self._bg1:setCapInsets(cc.rect(511,86,1,1))
    self._touchLab = self:getUI("bg.touchLab")
    self._touchLab:setVisible(true)
    self._touchLab:setOpacity(0)

    self._desNode = self:getUI("bg.desNode")
    self._desNode:setOpacity(0)
    self._desNode:setCascadeOpacityEnabled(true)
    self._desLabel1 = self._desNode:getChildByFullName("desLabel1")
    self._desLabel1:setFontName(UIUtils.ttfName)
    -- self._desLabel1:setColor(cc.c3b(254, 235, 177))
    self._desLabel1:setString(self._volume .. "单位兵团")
    self._volumeImg = self._desNode:getChildByFullName("volumeImg")
    local volumeImgIdxs = {
	    [1] = 5,
	    [4] = 4,
	    [9] = 3,
	    [16]= 2, 
	}
    local volumeImgIdx = volumeImgIdxs[self._volume] 
    self._volumeImg:loadTexture("v".. volumeImgIdx .."_battle_treasure.png",1)
    self._volumeImg:setScale(0.5)
    self._numLab = self._desNode:getChildByFullName("numLab")
    self._numLab:setFontName(UIUtils.ttfName)
    self._numLab:setString(lang("ATTR_" .. self._buffId) .. "增加" .. self._buffValue)
end

function TreasureUpTeamView:animBegin(callback)
   	-- 播放获得音效
    audioMgr:playSound("ItemGain_1")

    self._bg = self:getUI("bg")
    local bgW,bgH = self._bg1:getContentSize().width,self._bg1:getContentSize().height
    self:addPopViewTitleAnim(self._bg, "huodetisheng_huodetitleanim", 480, 480)

    ScheduleMgr:delayCall(400, self, function( )
        -- ScheduleMgr:delayCall(200, self, function( )
            if callback and self._bg1 then
                callback()
            end
        -- end)
    end)
   
end

-- 接收自定义消息
function TreasureUpTeamView:reflashUI(data)
   
	self.bgWidth,self.bgHeight = self._bg1:getContentSize().width,self._bg1:getContentSize().height
	local gifts = {}
	local volume = self._volume
	local teams = self._modelMgr:getModel("TeamModel"):getData()
	-- dump(teams)
	local count = 1
	for k,v in pairs(teams) do
		if tonumber(v.volume) == volume and count <= 10 then
			table.insert(gifts,{"team",tonumber(v.teamId),0})
			count = count+1
		end
	end
	self._gifts = gifts

    local colMax = 5
    local itemHeight,itemWidth = 140,115
    local maxHeight = itemHeight * math.ceil( #gifts / colMax) + 80
    local maxHeight = self._bg1:getContentSize().height

    local x = 0
    local y = 0

    -- print("gifts===",#gifts)
    local offsetX,offsetY = 0,0
    local row = math.ceil( #gifts / colMax)
    local col = #gifts
    if col > colMax then
        col = colMax
    end

    offsetX = (self.bgWidth-(col-1)*itemWidth)*0.5
    --    矫正 - (row - 2) * 15  2行 +15 2行不加
    offsetY = maxHeight/2 + row*itemHeight/2 - itemHeight/2 - 15  --maxHeight/2 - row * itemHeight/2 + (row -1) * itemHeight + itemHeight / 2 --offsetY + (row-1)*itemHeight +self.bgHeight/2 + 60
    
    x = x+offsetX-itemWidth
    y = y+offsetY
  
  	--创建item
    local showItems
    showItems = function( idx )
       -- print("=============idx=====",idx)
       	if idx > #gifts then
       		return
       	end
        x = x + itemWidth
        if idx ~= 1 and (idx-1) % colMax == 0 then 
            x =  offsetX
            y = y - itemHeight
        end
        self:createItem(gifts[idx], x, y, idx,showItems)
    end

    local sizeSchedule
    local step = 0.5
    local stepConst = 50
    local bg1Height = 200
    self._bg1:setContentSize(cc.size(self.bgWidth,bg1Height))
    self._bg1:setOpacity(0)
    self:animBegin(function( )
        self._bg1:setOpacity(255)
        sizeSchedule = ScheduleMgr:regSchedule(1,self,function( )
            stepConst = stepConst-step
            if stepConst < 1 then 
                stepConst = 1
            end
            bg1Height = bg1Height+stepConst
            if bg1Height < maxHeight then
                self._bg1:setContentSize(cc.size(self.bgWidth,bg1Height))
            else
            	self._desNode:runAction(
            		cc.Spawn:create(
	            		cc.MoveBy:create(0.1,cc.p(0,-10)),
	            		cc.FadeIn:create(0.1)
            		)
            	)  
                self._bg1:setContentSize(cc.size(self.bgWidth,maxHeight))
                ScheduleMgr:unregSchedule(sizeSchedule)
                self:addDecorateCorner()
                -- title动画
                --添加items      
                showItems(1)
            end
        end)
    end)
end

function TreasureUpTeamView:createItem( data,x,y,index,nextFunc )
    local itemType = data[1] or data.type
    local itemId = data[2] or data.typeId 
    local itemNum = data[3] or data.num

    -- local item = IconUtils:createItemIconById({itemId = itemId,num = itemNum,teamD = teamD,effect = true,treasureCircle=true })  --effect = true 不加特效 --treasureCircle 不加内框
    local teamD = tab:Team(itemId)
	-- print("===========self._palyerData.formation.heroId,teamId=>",self._palyerData.formation.heroId,teamId)
	local teamData = self._modelMgr:getModel("TeamModel"):getTeamAndIndexById(itemId)
	-- dump(teamData)
	local quality = self._modelMgr:getModel("TeamModel"):getTeamQualityByStage(teamData.stage)
    local item = IconUtils:createTeamIconById({teamData = teamData,sysTeamData = teamD, quality = quality[1] , quaAddition = quality[2]})
    item:setSwallowTouches(true)
    item:setAnchorPoint(cc.p(0,0))
    item:setPosition(cc.p(x,y))
    item:setScaleAnim(false)
    item:setCascadeOpacityEnabled(true)
    table.insert(self._items,item)
    -- item:setVisible(true)

    -- local itemIcon = item:getChildByFullName("teamIcon")
    -- itemIcon:setScale(0.85)

    local itemNormalScale = .8 
    local buffDes = ccui.Text:create()
    buffDes:setTextAreaSize(cc.size(300,50))
    buffDes:setTextHorizontalAlignment(1)
    buffDes:setTextVerticalAlignment(0)
    buffDes:setFontSize(24)
    local color = ItemUtils.findResIconColor(itemId,itemNum)
    buffDes:setColor(cc.c3b(250, 230, 200))
    buffDes:setFontName(UIUtils.ttfName)        
    -- buffDes:getVirtualRenderer():setLineHeight(100.0)
    -- buffDes:enableOutline(cc.c4b(0,0,0,255),2)
    buffDes:setAnchorPoint(cc.p(0.5,1))
    buffDes:setPosition(cc.p(item:getContentSize().width/2,0))
    item:addChild(buffDes,-1)
    buffDes:setVisible(false)
    local beforeValue = self:getTeamAttrValue(teamData,self._buffId)
    buffDes:setString(lang("ATTR_" .. self._buffId) .. (beforeValue - self._buffValue))
    buffDes._endNum = beforeValue--+ self._buffValue
    table.insert(self._buffDeses,buffDes)
    print(beforeValue)
   
    item:setAnchorPoint(cc.p(0.5,0.5))
    self._bg1:addChild(item)

    item:setOpacity(0)
    item:setCascadeOpacityEnabled(true)
    
    --第一个item不需要延迟
    local itemTime = (index -1) > 0 and 100 or 100
    ScheduleMgr:delayCall(itemTime, self, function( )      
        audioMgr:playSound("ItemGain_2")
        -- if bgMc then
        --     bgMc:setVisible(true)
        -- end        
        item:setScale(2.5)
        if index == #self._gifts then
            item:runAction(cc.Sequence:create(cc.Spawn:create(cc.FadeIn:create(0.15),cc.ScaleTo:create(0.1,itemNormalScale*0.7)),cc.CallFunc:create(function()
            	local baowuguangMc = mcMgr:createViewMC("baowuguang_choubaowu", false, true)
		        baowuguangMc:setPosition(item:getContentSize().width/2, item:getContentSize().height/2)
		        baowuguangMc:setPlaySpeed(0.8)
		        baowuguangMc:setScale(0.9)
		        item:addChild(baowuguangMc,10)
		        
            end),
            cc.ScaleTo:create(0.1,itemNormalScale),cc.CallFunc:create(function( )
                --最后一个item播完动画，显示name
                for k,v in pairs(self._buffDeses) do
                    v:setVisible(true) 
                    self:runValueChangeAnim(v,lang("ATTR_" .. self._buffId) .. v._endNum)         
                end 
                for k,v in pairs(self._items) do
                 	local baowuguangMc = mcMgr:createViewMC("baowubingtuantisheng_qianghua", false, true)
			        baowuguangMc:setPosition(v:getContentSize().width/2, v:getContentSize().height/2)
			        -- baowuguangMc:setPlaySpeed(0.8)
			        -- baowuguangMc:setScale(0.9)
			        v:addChild(baowuguangMc,10)
			        -- [[ 飘字动画
			        local floatLab = ccui.Text:create()
					floatLab:setTextAreaSize(cc.size(300,50))
					floatLab:setTextHorizontalAlignment(1)
					floatLab:setTextVerticalAlignment(0)
					floatLab:setFontSize(30)
					floatLab:setColor(UIUtils.colorTable["ccUIBaseColor2"])
					floatLab:setFontName(UIUtils.ttfName)    
					floatLab:setAnchorPoint(cc.p(0.5,1))
					floatLab:setString("+" .. self._buffValue)
					floatLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
					floatLab:setPosition(cc.p(v:getContentSize().width/2,10))
					v:addChild(floatLab,999)
					floatLab:runAction(cc.Sequence:create(cc.MoveBy:create(0.5,cc.p(0,20)),cc.FadeOut:create(0.1)))
			        --]]
                end             
                -- item:setScaleAnim(true)
            end)))
        else        	
            item:runAction(cc.Sequence:create(cc.Spawn:create(cc.FadeIn:create(0.15),cc.ScaleTo:create(0.1,itemNormalScale*0.8)),cc.CallFunc:create(function()
            	local baowuguangMc = mcMgr:createViewMC("baowuguang_choubaowu", false, true)
		        baowuguangMc:setPosition(item:getContentSize().width/2, item:getContentSize().height/2)
		        baowuguangMc:setPlaySpeed(0.8)
		        baowuguangMc:setScale(0.9)
		        item:addChild(baowuguangMc,10)
                
            end),
            cc.ScaleTo:create(0.1,itemNormalScale),
            cc.CallFunc:create(function( )
                -- item:setScaleAnim(true)
            end)))
        end
          
        if index == #self._gifts then

        	--播完动画 注册关闭点击事件
            ScheduleMgr:delayCall(120*index, self, function( )
                self._touchLab:runAction(cc.FadeIn:create(0.1))       
                local hadClose
                self:registerClickEventByName("closePanel", function()
                    if not hadClose then
                        -- print("=====================================================")
                        hadClose = true
                        local callback = self._callback
                        if callback and type(callback) == "function" then
                            callback()
                        end                        
                        if self.close then                       
                            self:close(true)
                        end
                        UIUtils:reloadLuaFile("treasure.TreasureUpTeamView")
                    end
                end)

            end)
        end     
        nextFunc(index+1)
    end) 

end

-- 获得兵团原始数据
function TreasureUpTeamView:getTeamAttrValue(teamData,attrId)
	local attrs = {}
	local sysTeam = tab.team[tonumber(teamData.teamId)]
    local tempEquips = {}
    for i=1,4 do
        local tempEquip = {}
        local equipLevel = teamData["el" .. i]
        local equipStage = teamData["es" .. i]
        tempEquip.stage = equipStage
        tempEquip.level = equipLevel
        table.insert(tempEquips, tempEquip)
    end 
    self._modelMgr:getModel("TeamModel"):setTeamTreasure()   
    local attr = self._modelMgr:getModel("TeamModel"):getTeamTreasure(teamData.volume)
    -- dump(attr)
    -- 基础数据
    local backData, backSpeed, atkSpeed = BattleUtils.getTeamBaseAttr(teamData, tempEquips, self._modelMgr:getModel("PokedexModel"):getScore())
    -- copy from team
    local treasureAttr = self._modelMgr:getModel("TeamModel"):getTeamTreasureAttrData(teamData.teamId)
    local heroAttr = self._modelMgr:getModel("TeamModel"):getTeamHeroAttrByTeamId(teamData.teamId)
    for i=BattleUtils.ATTR_Atk, BattleUtils.ATTR_COUNT do
        backData[i] = backData[i] + heroAttr[i] + treasureAttr[i]
    end
    -- end copy
    backData[2] = backData[2] + attr[2]
    backData[3] = backData[3] + attr[3]
    backData[5] = backData[5] + attr[5]
    backData[6] = backData[6] + attr[6]
    attrs[6] = BattleUtils.getTeamHpAttr(backData, true)        -- 生命
    attrs[3] = BattleUtils.getTeamAttackAttr(backData, true) 	-- 攻击
    return string.format("%.0f",attrs[tonumber(attrId)])
end

-- 数值变化动画
function TreasureUpTeamView:runValueChangeAnim( label,endDes )
    if not label then return end
    local preColor = label:getColor()
    local seq = cc.Sequence:create(
    	cc.MoveBy:create(0.1,cc.p(0,-10)),
    	cc.DelayTime:create(0.5),
    	cc.CallFunc:create(function( )
	        label:setColor(UIUtils.colorTable["ccUIBaseColor2"])
    	end),
    	cc.ScaleTo:create(0.1,1.2),
    	cc.ScaleTo:create(0.3,1),
    	cc.CallFunc:create(function( )
	        label:setColor(preColor)
	        label:setString(endDes)
	    end
    ))
    seq:setTag(101)
    label:runAction(seq)
end

function TreasureUpTeamView:getMaskOpacity()
    return 230
end

return TreasureUpTeamView