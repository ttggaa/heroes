--
-- Author: huangguofang
-- Date: 2017-03-28 15:57:40
--

local HeroBioMemoirDialog = class("HeroBioMemoirDialog", BasePopView)

function HeroBioMemoirDialog:ctor(data)
    HeroBioMemoirDialog.super.ctor(self)
    -- self.initAnimType = 1
    self._heroModel = self._modelMgr:getModel("HeroModel")
    -- self._userModel = self._modelMgr:getModel("UserModel")
    self._heroId = data.heroId or 60102
    self._callBack = data.callBack
end

function HeroBioMemoirDialog:onInit()
    -- 通用动态背景
    -- self:addAnimBg()

    self._tabIdx = 0                        -- 当前页签索引
    -- 根据英雄ID获取传记数据
    local bioServerData = self._heroModel:getBiographyDataByHeroId(self._heroId) or {}
    -- dump(bioServerData,"bioserver",5)    
    self._bioData = self:initBioData(bioServerData)

    self:registerClickEventByName("bg.btn_return", function(sender)
    	if self._callBack then
    		self._callBack()
    	end
        self:close()
        UIUtils:reloadLuaFile("hero.HeroBioMemoirDialog")
    end)
    self:getUI("bg.bgleft"):loadTexture("asset/bg/bg_magic.png")
    self:getUI("bg.bgright"):loadTexture("asset/bg/bg_magic.png")

     -- 左 简介
    self._left_panel        = self:getUI("bg.left_panel")    
    self._left_heroImg      = self:getUI("bg.left_panel.heroImg")      
    
      -- 右 解锁
    self._rightPanel_Unlock = self:getUI("bg.right_panel_unLock")    
    self._Unlock_desPanel   = self:getUI("bg.right_panel_unLock.desPanel")
    -- self._Unlock_titleTxt   = self:getUI("bg.right_panel_unLock.titleBg.titleTxt")
    self._Unlock_DesTxt     = self:getUI("bg.right_panel_unLock.desPanel.desTxt")
    -- self._Unlock_Date       = self:getUI("bg.right_panel_unLock.unlockDate")
    self._Unlock_leftBtn    = self:getUI("bg.right_panel_unLock.leftBtn")
    self._Unlock_rightBtn   = self:getUI("bg.right_panel_unLock.rightBtn")
    self._Unlock_pageTxt    = self:getUI("bg.right_panel_unLock.pageTxt") 
    self._Unlock_DesTxt:setVisible(false)   
    self._Unlock_txtArr     = {}
    self._Unlock_leftBtn:setVisible(false)
    self._Unlock_rightBtn:setVisible(false)
    self._Unlock_pageTxt:setVisible(false)
    self:registerClickEvent(self._Unlock_leftBtn, function(sender)
        self:clickPageBtn(1)
    end)
    self:registerClickEvent(self._Unlock_rightBtn, function(sender)
        self:clickPageBtn(-1)
    end)

    self._buttons = {}   --页签
    -- self._localRedData = {}
    
    local finishImgArr = {}
    for i=1,5 do
        local bioData = self._bioData[i]

        -- 页签初始化
        self._buttons[i] = {}
        self._buttons[i]._btn = self:getUI("bg.btn_" .. i)
        self._buttons[i]._btn:getTitleRenderer():disableEffect()
        -- self._buttons[i]._btn:setTitleFontSize(24)
        self:registerClickEvent(self._buttons[i]._btn, function ()  
            if bioData.state == 2 then
                self:touchTab(i)
            else
                self._viewMgr:showTip(lang("MEMENTO_01")) 
            end
        end)      
        self._buttons[i]._titleTxt = self:getUI("bg.btn_" .. i .. ".titleTxt")
        self._buttons[i]._titleTxt:setFontSize(24)
        self._buttons[i]._currImg = self:getUI("bg.btn_" .. i .. ".currImg")
        self._buttons[i]._currImg:setVisible(true)
        local currTxt = self:getUI("bg.btn_" .. i .. ".currImg.currTxt")
        currTxt:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

        local btnImg = "heroBio_memoir_common.png"
        if bioData.state ~= 2 then
            btnImg = "heroBio_memoir_locked.png"
        elseif i == self._tabIdx then
            btnImg = "heroBio_memoir_selected.png"
        end
        self._buttons[i]._btn:loadTextures(btnImg,btnImg,btnImg,1)

        self._buttons[i]._redImg = self:getUI("bg.btn_" .. i .. ".redImg")
        -- 是否显示红点
        self._buttons[i]._isHaveClick = SystemUtils.loadAccountLocalData("HEROMEMOIR_RED_" .. self._heroId .. "0" .. i)
        self._buttons[i]._redImg:setVisible(bioData.state == 2 and not SystemUtils.loadAccountLocalData("HEROMEMOIR_RED_" .. self._heroId .. "0" .. i))
        self._buttons[i]._titleTxt:setString(lang(bioData.heroDes))
        self._buttons[i]._finishImg = self:getUI("bg.btn_" .. i .. ".finishImg")
        self._buttons[i]._finishImg:setVisible(bioData.state == 2)
        -- 已完成未查看的回忆录播放动画
        if bioData.state == 2 and not self._buttons[i]._isHaveClick then
            table.insert(finishImgArr, self._buttons[i]._finishImg)      
        end
    end

    -- 已完成动画
    local num = 1
    for k,v in pairs(finishImgArr) do
        local img = v
        img:setOpacity(0)
        local scale = img:getScale()
        img:setScale(3)
        img:runAction(cc.Sequence:create(cc.DelayTime:create(num*0.17),cc.FadeIn:create(0.01),cc.ScaleTo:create(0.15, scale - 0.2),cc.ScaleTo:create(0.02, scale)))
        num = num + 1
    end

    --[[
    -- 调整左侧页签的位置
    local posY = self._buttons[2]._btn:getPositionY()
    local subY = 86
    for k,v in pairs(self._buttons) do
        if v._btn:isVisible() then
            v._btn:setPositionY(posY)
            posY = posY - subY
        end
    end
    ]]

 	self:touchTab(1)
    self:initLeftPanel(self._bioData[2])
    -- if true then return end
  
end

-- 点击页签
function HeroBioMemoirDialog:touchTab(idx)

    if idx == self._tabIdx then return end
    self._tabIdx = idx
    -- 红点显示
    local data = self._bioData[self._tabIdx]
    if not self._buttons[idx]._isHaveClick then
	    -- 更新model里的数据
	    self._heroModel:setBioRedNotice(self._heroId,self._tabIdx,false)
	    -- --点击过
	    SystemUtils.saveAccountLocalData("HEROMEMOIR_RED_" .. data.id ,true)
	    self._buttons[idx]._isHaveClick = true

	 	self._buttons[idx]._redImg:setVisible(false)
	end
	
    for i = 1, 5 do
        local btn = self._buttons[i]._btn
        btn:setEnabled(i ~= self._tabIdx )        
        self._buttons[i]._currImg:setVisible(i == self._tabIdx)
        
        -- btn:setBright(i ~= self._tabIdx)
        self._buttons[i]._titleTxt:setColor(i ~= self._tabIdx and cc.c4b(78,50,13,255) or cc.c4b(196,73,4,255))
    end
    self:updateRightPanel(data)

end

-- 更新左边详情面板
function HeroBioMemoirDialog:initLeftPanel(data)
	-- dump(data,"data-->",3)
    if not data then return end
   
    -- 初始化 英雄原画
    self._left_heroImg:loadTexture("heroBio_img_" .. self._heroId .. ".jpg",1)
end

function HeroBioMemoirDialog:updateRightPanel(data)

	-- dump(data,"data==>",3)

	self._rightPanel_Unlock:setVisible(data.state == 2)
    local pTime = tonumber(data.pTime) or 0   
    -- self._Unlock_titleTxt:setString(lang(data.textTitle))    

    --[[
    -- 已完成状态是时间戳  
    local time = TimeUtils.getDateString(pTime,"%Y.%m.%d")
    self._Unlock_Date:setString("完成时间: " .. time)
    self._Unlock_Date:setVisible(data.pTime and data.pTime > 1)
    ]]

    self._Unlock_txtArr = {}
    -- 页数 
    self._pageNum = 1
    
    self._Unlock_txtArr = self:getDesPageTxt(data.heroBio)    
    self._pageMax = #self._Unlock_txtArr 

    self._Unlock_pageTxt:setString(self._pageNum .. "/" .. self._pageMax)

    self._Unlock_pageTxt:setVisible(self._pageMax > 1)
    self._Unlock_leftBtn:setVisible(self._pageNum < self._pageMax)
    self._Unlock_rightBtn:setVisible(self._pageNum > 1) 
    -- 走到底隐藏左右按钮 
    -- self._Unlock_rightBtn:setEnabled(self._pageNum ~= 1)
    -- self._Unlock_leftBtn:setEnabled(self._pageNum ~= self._pageMax)

    local BioTxt = self._Unlock_desPanel:getChildByFullName("BioTxtRight")
    if BioTxt then
        BioTxt:removeFromParent()
    end

    if not self._Unlock_txtArr[self._pageNum] then return end
    --[[
    -- 左侧页文本
    local desTxtLeft = self._Unlock_txtArr[self._pageNum] or "[][-]"
    local BioTxtLeft = self._left_panel:getChildByFullName("BioTxtLeft")
    if BioTxtLeft then
        BioTxtLeft:removeFromParent()
    end
    
    BioTxtLeft = RichTextFactory:create(desTxtLeft,342,368)
    BioTxtLeft:formatText()
    BioTxtLeft:setVerticalSpace(3)
    BioTxtLeft:setName("BioTxtLeft")
    BioTxtLeft:setAnchorPoint(cc.p(0,1))
    BioTxtLeft:setPosition(-150,self._Unlock_DesTxt:getPositionY() - 35)
    self._left_panel:addChild(BioTxtLeft,1)
    ]]
    -- 右侧页文本
    -- dump(self._Unlock_txtArr,"textArr")
    if not self._Unlock_txtArr[self._pageNum] then return end
    local desTxt = self._Unlock_txtArr[self._pageNum] or "[][-]"
    -- local desTxt = "[color=462800,fontsize=20]凯瑟琳女王是一个身手矫健，做事坚决的女人，    她在战斗方面有着娴熟的技巧，她在战争中的表现一次次地证明，    她既是一位英勇的战士，又是一位杰出的领导人。凯瑟琳加    入埃拉西亚军队原本违抗了她父亲的意愿，而她所    做的这一切，最终证明了她具备战术家、勇士和领导人的能力。    瑟琳女王是一个身手矫健，做事坚决的女人，    她在战斗方面有着娴熟的技巧，她在战争中的表现一次次地证明，    她既是一位英勇的战士，又是一位杰出的领导人。凯瑟琳加    入埃拉西亚军队原本违抗了她父亲的意愿，而她所    做的这一切，最终证明了她具备战术家、勇士和领导人的能    瑟琳女王是一个身手矫健，做事坚决的女人，    她在战斗方面有着娴熟的技巧，她在战争中的表现一次次地证明，    她既是一位英勇的战士，又是一位杰出的领导人。凯瑟琳加    入埃拉西亚军队原本违抗了她父亲的意愿，而她所    做的这一切，最终证明了她具备战术家、勇士和领导人的能[-]"-- self._Unlock_txtArr[self._pageNum] or "[][-]"

    local BioTxt = RichTextFactory:create(desTxt,342,440)
    BioTxt:formatText()
    BioTxt:setVerticalSpace(3)
    BioTxt:setName("BioTxtRight")
    BioTxt:setAnchorPoint(cc.p(0,1))
    BioTxt:setPosition(-168,self._Unlock_DesTxt:getPositionY()+260)
    self._Unlock_desPanel:addChild(BioTxt,1)

end

-- +1 -1
function HeroBioMemoirDialog:clickPageBtn(num)
    if self._Unlock_txtArr and 0 == #self._Unlock_txtArr then
        return
    end
    self._pageNum = self._pageNum + num
    if self._pageNum > self._pageMax then
        self._pageNum = 1
    end
    if self._pageNum < 1 then
        self._pageNum = self._pageMax
    end

    -- 直接setString 会造成汉字缩小的问题
    local desTxt = self._Unlock_txtArr[self._pageNum] or "[][-]"
    local BioTxt = self._Unlock_desPanel:getChildByFullName("BioTxtRight")
    if BioTxt then
        BioTxt:removeFromParent()
    end
    
    local BioTxt = RichTextFactory:create(desTxt,342,440)
    BioTxt:formatText()
    BioTxt:setVerticalSpace(3)
    BioTxt:setName("BioTxtRight")
    BioTxt:setAnchorPoint(cc.p(0,1))
    BioTxt:setPosition(-168,self._Unlock_DesTxt:getPositionY()+260)
    self._Unlock_desPanel:addChild(BioTxt,1)
 
    self._Unlock_pageTxt:setString(self._pageNum .. "/" .. self._pageMax)

    -- 走到底隐藏左右按钮 
    self._Unlock_leftBtn:setVisible(self._pageNum < self._pageMax)
    self._Unlock_rightBtn:setVisible(self._pageNum > 1) 
    -- self._Unlock_rightBtn:setEnabled(self._pageNum ~= 1)
    -- self._Unlock_leftBtn:setEnabled(self._pageNum ~= self._pageMax)
end

-- 初始化传记数据
function HeroBioMemoirDialog:initBioData(serverData)

 	local bioTableData = {}
    -- dump(serverData,"serverData==>",4)
    local index = 1
    for i=1,5 do
        local bioId = tonumber(self._heroId .. "0" .. i)
        -- local bioId = tostring(self._heroId .. "0" .. i)
        -- print("======================bioId=========",bioId)
        --表数据
        local tableData = clone(tab:HeroBio(bioId))
        tableData.index = index
        index = index + 1
        local sData = serverData[tostring(bioId)]
        if sData then
            for k,v in pairs(sData) do
                tableData[k] = v 
            end
        end
        -- 0 条件未达到 1 条件达到可以挑战关卡 2 通关
        tableData.state = 0
        if sData and sData.pTime then
            if sData.pTime > 1 then
                tableData.state = 2
            else
                tableData.state = sData.pTime
            end
        end
        -- tableData.state = 2
        tableData.isPassed = false 
        if 2 == tableData.state then
            tableData.isPassed = true
        end
        table.insert(bioTableData,tableData)
    end

    return bioTableData
end


--获取每页显示的富文本
function HeroBioMemoirDialog:getDesPageTxt(bioTxtData)
    -- dump(bioTxtData,"bioTxtData",5)
    if not bioTxtData or type(bioTxtData) ~= "table" then  return {} end

    local strArr = {}
    for k,v in pairs(bioTxtData) do
        if v then

            strArr[#strArr + 1] = lang(v)
        end
    end
    -- dump(strArr,"atrArr",5)
    return strArr
end

return HeroBioMemoirDialog