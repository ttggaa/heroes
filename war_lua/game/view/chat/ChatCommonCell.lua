--[[
    Filename:    ChatCommonCell.lua
    Author:      <weiwei02@playcrab.com>
    Datetime:    2016-04-01 13:36:34
    Description: File description
--]]

local ChatCommonCell = class("ChatCommonCell", cc.TableViewCell)

function ChatCommonCell:ctor()
    -- ChatCommonCell.super.ctor(self)
    self._viewMgr = ViewManager:getInstance()
    self._serverMgr = ServerManager:getInstance()
    self._modelMgr = ModelManager:getInstance()
    self._chatModel = self._modelMgr:getModel("ChatModel")
    self._guildModel = self._modelMgr:getModel("GuildModel")
    self._chooseObj = {}    --需要选择被显示的对象
end


function ChatCommonCell:onInit()

end

function ChatCommonCell:reflashUI(data, richText, width, height, isMyself, oldUI)
    self._data = data
    self._isMyself = isMyself
    self._oldUI = oldUI
    self._infoData = data.message
    local userData = data.message.udata
    -- dump(data,"123", 10)

    if richText:getParent() ~= nil then 
        local tempText = richText
        richText = cc.Node:create()
        richText:setContentSize(cc.size(tempText:getContentSize().width, tempText:getContentSize().height))
    end
    if richText.getRealSize == nil then 
        richText.getRealSize = richText.getContentSize
    end

    --headIcon
    if not self._avatar then
        if data.message.typeCell == ChatConst.CELL_TYPE.WORLD4 then
            local headP = {art = "ti_xiaojingling", level = 0, tp = 4, eventStyle=1,avatarFrame=userData["avatarFrame"]}
            self._avatar = IconUtils:createHeadIconById(headP) 
        else
            local headP = {avatar = userData.avatar, level = userData.lvl, tp = 4, eventStyle=1,avatarFrame = userData["avatarFrame"], plvl = userData.plvl}
            self._avatar = IconUtils:createHeadIconById(headP)
        end
        self._avatar:setScale(0.64)
        self._avatar:setAnchorPoint(0, 1)
        self:addChild(self._avatar)
    else
        if data.message.typeCell == ChatConst.CELL_TYPE.WORLD4 then
            local headP = {art = "ti_xiaojingling", level = 0, tp = 4,avatarFrame = userData["avatarFrame"]}
            IconUtils:updateHeadIconByView(self._avatar, headP)
        else
            local headP = {avatar = userData.avatar, level = userData.lvl, tp = 4,avatarFrame = userData["avatarFrame"], plvl = userData.plvl}
            IconUtils:updateHeadIconByView(self._avatar, headP)   --,tp = 2
        end
    end

    if isMyself == true then 
        self._avatar:setPosition(width - self._avatar:getContentSize().width * self._avatar:getScaleX() - 125, height - 5)
        self._avatar:setTouchEnabled(false)
    else
        self._avatar:setPosition(3, height - 5)
        if data.message.typeCell == ChatConst.CELL_TYPE.WORLD4 then
            self._avatar:setTouchEnabled(false)
        else
            self._avatar:setTouchEnabled(true)
            registerClickEvent(self._avatar, function() 
                -- 获取玩家信息详情  hgf
                local fId = (userData.lvl and  userData.lvl >= 15) and 101 or 1
                ServerManager:getInstance():sendMsg("UserServer", "getTargetUserBattleInfo", {tagId = userData["rid"],fid=fId}, true, {}, function(result)                 
                    -- 打开聊天详情界面
                    if self._viewMgr then
                        self._viewMgr:showDialog("chat.DialogFriendHandle", {uiData = data, detailData = result, oldUI = oldUI}, true)
                    end
                end)
            end)
        end
    end

    --channel
    if self._channelSp == nil then
        self._channelSp = cc.Sprite:create()
        self._channelSp:setAnchorPoint(0, 1)
        self:addChild(self._channelSp)
    end
    if data.message.typeCell == "guanfang" then
        self._channelSp:setSpriteFrame("chatImg_channel_" .. data.message.typeCell .. ".png")
    else
        self._channelSp:setSpriteFrame("chatImg_channel_" .. (data.type or "all") .. ".png")
    end
   
    if isMyself == true then 
        self._channelSp:setPosition(width - self._channelSp:getContentSize().width - 199, height - 8)
    else
        self._channelSp:setPosition(77, height - 8)
    end

    --name
    if self._nameLab == nil then
        self._nameLab = cc.Label:createWithTTF("", UIUtils.ttfName, 20)
        self._nameLab:setColor(UIUtils.colorTable.ccUIBaseTextColor1)
        -- self._nameLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        self._nameLab:setAnchorPoint(0, 1)
        self:addChild(self._nameLab)
    end
    self._nameLab:setString(userData.name)
    self._nameLab:setVisible(userData.name ~= "")

    if isMyself == true then 
        self._nameLab:setPosition(width - self._nameLab:getContentSize().width - 255 , height - 9)
    else
        self._nameLab:setPosition(132, height - 9)
    end

    --vip
    userData.vipLvl = userData.vipLvl or 0
    if self._vipImg == nil then
        self._vipImg = cc.Sprite:createWithSpriteFrameName("chatPri_vipLv"..math.max(1, userData.vipLvl)..".png")  
        self._vipImg:setAnchorPoint(0, 1)
        self._vipImg:setScale(0.7)
        self:addChild(self._vipImg)
    else
        self._vipImg:setVisible(true)
        self._vipImg:setSpriteFrame("chatPri_vipLv".. math.max(1, userData.vipLvl) ..".png")
    end
    self._vipImg:setVisible(userData.vipLvl > 0)

    if isMyself == true then
        self._vipImg:setPosition(width - self._nameLab:getContentSize().width - 291 , height - 10)
    else
        self._vipImg:setPosition(140 + self._nameLab:getContentSize().width, height - 7)
    end

    --textBg
    if self._textBg == nil then
        self._textBg = cc.Scale9Sprite:createWithSpriteFrameName("chatImg_contextBg.png")
        self:addChild(self._textBg)
    end

    if self._myTextBg == nil then
        self._myTextBg = cc.Scale9Sprite:createWithSpriteFrameName("chatImg_contextBg1.png")
        self:addChild(self._myTextBg)
    end

    --------------------------------按类型创建---------------------------------------
    --显示隐藏
    for i,v in ipairs(self._chooseObj) do
        v:setVisible(false)
    end

    local cellType = data.message.typeCell
    if cellType and cellType == ChatConst.CELL_TYPE.VOICE then
        self:createVoiceItem(data, richText, width, height, isMyself)  --语音
    else
        self:createOtherItem(data, richText, width, height, isMyself)
    end

    --btn
    self:createBtnEvent(data, height, isMyself)
end

--创建语音
function ChatCommonCell:createVoiceItem(data, richText, width, height, isMyself, oldUI)
    local voiceNode, parentNode
    local posVX, posVY
    if isMyself == true then
        self._textBg:setVisible(false)
        self._myTextBg:setVisible(true)
        self._myTextBg:setAnchorPoint(0, 1)
        parentNode = self._myTextBg
        voiceNode = self._voiceImgR
        posVX, posVY = 12, 27
    else
        self._textBg:setVisible(true)
        self._myTextBg:setVisible(false)
        self._textBg:setAnchorPoint(0, 1)
        parentNode = self._textBg
        voiceNode = self._voiceImgL
        posVX, posVY = 47, 27
    end

    --语音红点
    local function refreshState(inObj)
        local redpoint = inObj._redpoint
        local readList = self._chatModel:getVoiceReadState()
        if readList[self._infoData["textId"]] and readList[self._infoData["textId"]] == true and isMyself == false then
            redpoint:setVisible(true)
        else
            redpoint:setVisible(false)
        end
    end

    if voiceNode == nil then
        --voiceImg
        voiceNode = ccui.ImageView:create("chat_voice_msg.png", 1)
        voiceNode:setScale9Enabled(true)
        voiceNode:setCapInsets(cc.rect(36, 16, 1, 1))
        voiceNode:setAnchorPoint(cc.p(0, 0.5))
        voiceNode:setPosition(posVX, posVY)
        voiceNode:ignoreContentAdaptWithSize(false)
        voiceNode:setTouchEnabled(true)
        voiceNode:setSwallowTouches(false)
        parentNode:addChild(voiceNode)
        table.insert(self._chooseObj, voiceNode)

        --变长
        local tDis = 250 * (6 * (data.message.textTime or 0) + 40) / (4 * (data.message.textTime or 0) + 160)
        voiceNode:setContentSize(cc.size(math.max(tDis, 72), voiceNode:getContentSize().height))

        --时长
        local voiceT = ccui.Text:create()
        voiceT:setFontName(UIUtils.ttfName)
        voiceT:setString((data.message.textTime or 0) .. "秒")
        voiceT:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
        voiceT:setFontSize(18)
        voiceT:setPosition(voiceNode:getContentSize().width * 0.5, voiceNode:getContentSize().height * 0.5)
        voiceNode._time = voiceT
        voiceNode:addChild(voiceT)

        --红点
        local voiceRedPt = ccui.ImageView:create("globalImageUI_bag_keyihecheng.png", 1)
        if isMyself == true then
            voiceRedPt:setPosition(3, voiceNode:getContentSize().height)
        else
            voiceRedPt:setPosition(voiceNode:getContentSize().width - 3, voiceNode:getContentSize().height)
        end
        voiceRedPt:setScale(0.6)
        voiceNode._redpoint = voiceRedPt
        voiceNode:addChild(voiceRedPt)

        refreshState(voiceNode)

        --特效
        local voiceAinm
        if isMyself == true then
            voiceAinm = mcMgr:createViewMC("yuyinR_mainviewcoin", true)
            voiceAinm:setPosition(voiceNode:getContentSize().width + 21, voiceNode:getContentSize().height * 0.5 - 1)
        else
            voiceAinm = mcMgr:createViewMC("yuyin_mainviewcoin", true)
            voiceAinm:setPosition(-19, voiceNode:getContentSize().height * 0.5 - 1)
        end
        voiceAinm:gotoAndStop(9)
        voiceNode._anim = voiceAinm
        voiceNode:addChild(voiceAinm)
        
        --textBg
        parentNode:setContentSize(voiceNode:getContentSize().width + 60, 50)  --300
        parentNode:setCapInsets(cc.rect(20, 25, 1, 1))
        if isMyself == true then
            parentNode:setPosition(width - parentNode:getContentSize().width - 193, height - 40)
        else
            parentNode:setPosition(70, height - 40)
        end

        registerTouchEvent(voiceNode, 
            function(_, _x, _y)
                self._vPosX1, self.vPosY1 = _x, _y
                self._vDisX, self._vDisY = 0, 0  --cell滑动距离
            end,
            --move
            function(_, _x, _y)
                local disX, disY = math.abs(self._vPosX1 - _x), math.abs(self.vPosY1 - _y)
                if disX > self._vDisX then
                    self._vDisX = disX
                end
                if disY > self._vDisY then
                    self._vDisY = disY
                end
            end,
            --pop
            function(_, _x, _y)
                if self._vDisX >= 5 or self._vDisY >= 5 then
                    return
                end
                local fileID = self._infoData["textId"] or 0
                self._chatModel:setVoiceReadState(fileID, false)
                voiceNode._redpoint:setVisible(false)
                voiceNode._anim:gotoAndPlay(1)
                
                VoiceUtils.play(fileID, function()
                    if voiceNode and voiceNode._anim then
                        voiceNode._anim:gotoAndStop(9)
                    end
                    end)
            end)
    else
        --变长
        local tDis = 250 * (6 * (self._infoData["textTime"] or 0) + 40) / (4 * (self._infoData["textTime"] or 0) + 160)
        voiceNode:setContentSize(cc.size(math.max(tDis, 72), voiceNode:getContentSize().height))
        voiceNode:setVisible(true)

        --textBg
        parentNode:setContentSize(voiceNode:getContentSize().width + 60, 50)
        if isMyself == true then
            parentNode:setPosition(width - parentNode:getContentSize().width - 193, height - 40)
        else
            parentNode:setPosition(70, height - 40)
        end
        
        --时长
        voiceNode._time:setString((self._infoData["textTime"] or 0) .. "秒")
        voiceNode._time:setPosition(voiceNode:getContentSize().width * 0.5, voiceNode:getContentSize().height * 0.5)

        --红点
        if isMyself == true then
            voiceNode._redpoint:setPosition(3, voiceNode:getContentSize().height)
        else
            voiceNode._redpoint:setPosition(voiceNode:getContentSize().width - 3, voiceNode:getContentSize().height)
        end
        refreshState(voiceNode)
        
        --特效
        if isMyself == true then
            voiceNode._anim:setPosition(voiceNode:getContentSize().width  + 20, voiceNode:getContentSize().height * 0.5 - 1)
        else
            voiceNode._anim:setPosition(-20, voiceNode:getContentSize().height * 0.5 - 1)
        end
    end

    if isMyself == true then
        self._voiceImgR = voiceNode
    else
        self._voiceImgL = voiceNode
    end
end

--创建普通信息
function ChatCommonCell:createOtherItem(data, richText, width, height, isMyself, oldUI)
    local parentNode
    if isMyself == true then
        self._textBg:setVisible(false)
        self._myTextBg:setVisible(true)
        parentNode = self._myTextBg
    else
        self._textBg:setVisible(true)
        self._myTextBg:setVisible(false)
        parentNode = self._textBg
    end

    --create
    parentNode.showId = data.id
    parentNode:setAnchorPoint(0, 1)

    local x = richText:getRealSize().width / 2
    if richText:getRealSize().width < richText:getContentSize().width then 
        x = richText:getContentSize().width / 2
    end
    if isMyself == true then
        x = x + 10
    else
        x = x + 20
    end
    parentNode:addChild(richText)

    local textBgHeight = 45 
    if richText:getRealSize().height + 10 > textBgHeight then 
        textBgHeight = richText:getRealSize().height + 20
    end
    richText:setPosition(x, textBgHeight/2 + 2)

    parentNode:setContentSize(math.max(richText:getRealSize().width +30, 44), textBgHeight)
    parentNode:setCapInsets(cc.rect(20, 25, 1, 1))
    if isMyself == true then
        parentNode:setPosition(width - self._myTextBg:getContentSize().width - 193, height - 40)
    else
        parentNode:setPosition(70, height - 40)
    end
    
    if richText.restoreGif then 
        richText:restoreGif()
    end
    self.richText = richText
end

--添加按钮点击事件
function ChatCommonCell:createBtnEvent(data, height, isMyself)
    local img, btnScale, btnColor, outColor
    local title, titlePosX, titlePosY, titleSize
    local isVisible, callback
    local _typeCell = ""
    if data.message and data.message.typeCell then
        _typeCell = data.message.typeCell
    end

    if _typeCell == ChatConst.CELL_TYPE.WORLD2 or _typeCell == ChatConst.CELL_TYPE.WORLD5 then         --战报回放
        img = "chatAll_replayBtn.png"
        title = "回放"
        btnColor = cc.c4b(252,244,194,255)
        outColor = cc.c4b(85,38,10,255)
        titlePosX, titlePosY, btnScale, titleSize = 27, -13, 1, 16
        isVisible = true
        callback = function()
            if _typeCell == ChatConst.CELL_TYPE.WORLD2 then
                self:callbackHandle1(data)
            else
                self:callbackHandle3(data)
            end
        end

    elseif _typeCell == ChatConst.CELL_TYPE.WORLD3 then     --联盟招募
        img = "chatAll_joinBtn.png"
        title = ""
        titlePosX,titlePosY, btnScale, titleSize = 30, -13, 1, 16
        isVisible = not isMyself
        callback = function()
            self:callbackHandle2(data)
        end

    else
        img = "globalImageUI6_meiyoutu.png"
        title = ""
        titlePosX,titlePosY, btnScale, titleSize = 0, 0, 1, 22
        isVisible = false
        callback = function() end
    end

    --btn
    if self._clickBtn == nil then
        self._clickBtn = ccui.Button:create()
        self:addChild(self._clickBtn)
        
        local btnTitle = ccui.Text:create()
        btnTitle:setFontName(UIUtils.ttfName)
        self._clickBtn.btnTitle = btnTitle
        self:addChild(btnTitle)
    end
    self._clickBtn:loadTextures(img, img, img, 1)
    self._clickBtn:setScale(btnScale)

    --title
    if self._btnTitle == nil then
        self._btnTitle = ccui.Text:create()
        self._btnTitle:setFontName(UIUtils.ttfName)
        self:addChild(self._btnTitle)
    end
    self._btnTitle:setFontSize(titleSize)
    self._btnTitle:setString(title)
    self._btnTitle:setColor(btnColor or cc.c4b(255,255,255,255))
    self._btnTitle:enableOutline(outColor or cc.c4b(124, 64, 0, 255), 1)

    -- pos
    if isMyself == true then
        self._clickBtn:setAnchorPoint(0, 0.5)
        local bPosX, bPosY = 75, self._myTextBg:getPositionY() - self._myTextBg:getContentSize().height*0.5
        self._clickBtn:setPosition(bPosX, bPosY)
        self._clickBtn:setScaleX(-btnScale)
        self._btnTitle:setPosition(bPosX - titlePosX, bPosY + titlePosY)
    else
        self._clickBtn:setAnchorPoint(0, 0.5)
        local bPosX, bPosY = 320, self._textBg:getPositionY() - self._textBg:getContentSize().height*0.5
        self._clickBtn:setPosition(bPosX, bPosY)
        self._clickBtn:setScaleX(btnScale)
        self._btnTitle:setPosition(bPosX + titlePosX, bPosY + titlePosY)
    end 

    -- visible
    self._clickBtn:setVisible(isVisible)
    self._btnTitle:setVisible(isVisible)

    --callback
    registerClickEvent(self._clickBtn, callback)  
end

--战斗回放 按钮点击事件
function ChatCommonCell:callbackHandle1(data)
    --回放
    local function reviewTheBattle(reportData)
        local left = BattleUtils.jsonData2lua_battleData(reportData.atk)
        local right = BattleUtils.jsonData2lua_battleData(reportData.def)
        BattleUtils.enterBattleView_Arena(left, right, reportData.r1, reportData.r2, 2, false,
        function (info, callback)
            callback(info)
        end,
        function (info)
            -- 退出战斗
        end)
    end

    if data.message.reportInfo ~= nil then
        local sendP = {reportKey = data.message.reportInfo.reportKey}
        ServerManager:getInstance():sendMsg("BattleServer","getBattleReport",sendP,true,{},
            function( result )
                if result and type(result) == "table" and next(result) == nil then
                    self._viewMgr:showTip("战报不存在")
                    return
                end
                reviewTheBattle(result)
            end)
    end
end

--联盟招募 按钮点击事件
function ChatCommonCell:callbackHandle2(data)
    local userModelData = self._modelMgr:getModel("UserModel"):getData()
    local guildID = data.message.zhaomu.guildId
    local guildName = data.message.zhaomu.guildName
    local ChatModel = self._modelMgr:getModel("ChatModel")

    --已有联盟
    if userModelData.guildId and userModelData.guildId ~= 0 then
        self._viewMgr:showTip(string.gsub(lang("GUILD_RECRUIT_3"), "{$guildname}", userModelData.guildName))
        return
    end

    --等级判断
    if userModelData.lvl < data.message.zhaomu.lvlimit then
        self._viewMgr:showTip(lang("GUILD_RECRUIT_4"))
        return
    end

    -- 需审批的联盟 是否已申请过
    if ChatModel:isHasAppliedGuild(guildID) then
        self._viewMgr:showTip(lang("GUILD_RECRUIT_6"))
        return
    end

    --加联盟24小时限制
    if not self._guildModel:canJoin() then
        local str = self._guildModel:getJoinLeftTime()
        self._viewMgr:showTip(lang("GUILD_EXIT_TIPS_2")..str)
        return
    end

    self._serverMgr:sendMsg("GuildServer", "applyJoin", {guildId = guildID}, true, {}, 
        function (result)
            if not result["d"] then   --需审批
                ChatModel:setApplyRecord(guildID) --本地记录申请状态
                self._viewMgr:showTip(lang("GUILD_RECRUIT_5"))
            else 
                self._viewMgr:showTip(string.gsub(lang("TIP_CREATE_GUILD_NAME_3"), "{$name}", guildName))
                self._viewMgr:showView("guild.GuildView")
                self._viewMgr:popView()
            end
        end,
        function(errorId)
            if tonumber(errorId) == 2712 then
                self._viewMgr:showTip(lang("GUILD_RECRUIT_8"))  -- 联盟申请人数已满
            elseif tonumber(errorId) == 119 then
                self._viewMgr:showTip(lang("GUILD_RECRUIT_4"))  -- 用户等级不足
            elseif tonumber(errorId) == 111 then
                self._viewMgr:showTip(lang("GUILD_RECRUIT_9"))  -- 系统尚未开放
            elseif tonumber(errorId) == 2307 then
                self._viewMgr:showTip(lang("GUILD_RECRUIT_7"))  -- 工会ID不存在
            elseif tonumber(errorId) == 2703 then
                self._viewMgr:showTip(lang("GUILD_RECRUIT_7"))  --联盟已解散
            elseif tonumber(errorId) == 2711 then
                self._viewMgr:showTip(lang("GUILD_RECRUIT_10"))  --联盟已满员
            elseif tonumber(errorId) == 2714 then 
                --本地记录申请状态              
                ChatModel:setApplyRecord(guildID)  
                self._viewMgr:showTip(lang("GUILD_RECRUIT_6"))  --已申请过
            end
        end)
end

--荣耀竞技场 战斗回放
function ChatCommonCell:callbackHandle3(inData)
    if self._oldUI._infoNode then
        self._oldUI._infoNode:removeFromParent(true)
        self._oldUI._infoNode = nil
    end

    local infoNode = require("game.view.chat.ChatReportInfoNode").new()
    infoNode:setScale(0.8)
    self._oldUI:addChild(infoNode, 100001) --比监听layer高1层级

    local point = self._clickBtn:convertToWorldSpace(cc.p(0, 0)) 
    point = self._oldUI:convertToNodeSpace(point)
    if self._isMyself then
        infoNode:setPosition(point.x + 20, point.y + 100)
    else
        infoNode:setPosition(point.x + 70, point.y + 100)
    end

    infoNode:reflashUI(inData)
   
    --屏幕监听事件
    self._oldUI._lockScrollBtn:setSelected(true)
    self._oldUI._infoNode = infoNode  --用于chatView处理node显示
end

return ChatCommonCell