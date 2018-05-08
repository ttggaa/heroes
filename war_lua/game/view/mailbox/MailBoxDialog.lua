--[[
    Filename:    MailBoxDialog.lua
    Author:      qiaohuan@playcrab.com 
    Datetime:    2015-11-14 18:20:00
    Description: File description
--]]
require("game.utils.IconUtils")
local MailBoxDialog = class("MailBoxDialog", BasePopView)

local iconIdMap = IconUtils.iconIdMap

function MailBoxDialog:ctor()
    MailBoxDialog.super.ctor(self)
    self._mailModel = self._modelMgr:getModel("MailBoxModel")
end

function MailBoxDialog:onInit()
    self._scrollView = self:getUI("bg.scrollView")
    self._scrollView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)

    self._title = self:getUI("bg.layer.titleBg.title")
    UIUtils:setTitleFormat(self._title, 6)

    self._content = self:getUI("bg.scrollView.content")
    self._content:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    self._content:setFontName(UIUtils.ttfName)
    self._sender = self:getUI("bg.scrollView.luokuan.sender")
    self._sender:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    self._sender:setFontName(UIUtils.ttfName)
    self._luokuan = self:getUI("bg.scrollView.luokuan")
    self._append = self:getUI("bg.scrollView.append")
    -- self._appendList = self:getUI("bg.layer.scrollView.append.appendList")
    self._append:setVisible(false)    
    self._append:setAnchorPoint(0, 1)

    self._appendNone = self:getUI("bg.layer.none")
    self._appendNone:setVisible(false)
    -- self._appendList:setDirection(1)
    self._receive = self:getUI("bg.layer.receive")
    self:registerClickEventByName("bg.closeBtn", function()
        if OS_IS_WINDOWS then
            UIUtils:reloadLuaFile("mailbox.MailBoxDialog")
        end
        self:close()
    end)

    local desLab1 = self:getUI("bg.scrollView.append.desLab1")
    desLab1:setVisible(false)
    local desLab2 = self:getUI("bg.scrollView.append.desLab2")
    desLab2:setVisible(false)
    local vipLab = self:getUI("bg.scrollView.append.vipLab")
    vipLab:setFntFile(UIUtils.bmfName_vip)
    vipLab:setVisible(false)
end

function MailBoxDialog:reflashUI(data)
    dump(data, "data=========", 10)
    self._mail = data
    local maxHeight = 0
    self._content:setVisible(true)
    if table.nums(self._mail.att) ~= 0 then
        self._append:setVisible(true)
        self._appendList = self._append:getChildByFullName("appendList") 
        self._appendNone = self:getUI("bg.layer.none")
        if self._mail.rec == 1 then
            self._appendNone:setVisible(true)
            self._receive:setVisible(false)
        else
            self._appendNone:setVisible(false)
        end
        self:setAttachment()
        maxHeight = maxHeight + self._append:getContentSize().height - 20
    else
        self._append:setVisible(false)
        self._receive:setTitleText("关闭")
    end
    local str = "系统邮件" -- self:limitLen(self._mail.title, 16)
    self._title:setString(str)

    local str = self._mail.ser or "小冰雹"
    self._sender:setString(str)

    if data.tId ~= 0 then
        if data.tId > table.nums(tab.mail) then
            self._luokuan:loadTexture("lk_1.png", 1)
        end
        self._luokuan:loadTexture(tab:Mail(data.tId)["signature"] .. ".png", 1)
    else
        self._luokuan:loadTexture("lk_1.png", 1)
    end
    

    local str = lang("email_goal")
    self._content:setString(str)
    local concentBg = self:getUI("bg.scrollView.concentBg")
    str = self._mail.con
    -- str = "[color=3D1F00]　　亲爱的各位玩家，服务器于25日11：25进行了一次更新，升级了服务器性能，给各位带来的不变敬请谅解，现奉上300钻石作为奖励，祝各位游戏愉快！[-]"
    -- str = "[color=462800]　　训练场明星挑战赛第[color=1ca216]3[-][color=462800]关，与您同服的玩家[color=1ca216]骑士谢尔·肯[-][color=462800]获得第一名，所在服务器所有玩家获得200钻石参与奖励，请查收[-]"
    local str = self:checkChar(str)
    if string.find(str, "color=") == nil then
        str = "[color=3D1F00]　　"..str.."[-]"
    -- else
    --     local i,j = string.find(str, "color=")
    --     local str1 = string.sub(str, 1, j)
    --     local str2 = string.sub(str, j+6, string.len(str))
    --     str = str1.."3D1F00"..str2
    end  

    
    local richText = RichTextFactory:create(str, concentBg:getContentSize().width-25, 0)
    richText:formatText()
    richText:enablePrinter(true)
    richText:setPosition(concentBg:getContentSize().width/2, concentBg:getContentSize().height - richText:getInnerSize().height/2)
    concentBg:addChild(richText)

    local descHeight = richText:getRealSize().height
    maxHeight = maxHeight + self._content:getContentSize().height
    maxHeight = maxHeight + descHeight + self._luokuan:getContentSize().height + 60
    if maxHeight > self._scrollView:getContentSize().height then
        self._scrollView:setInnerContainerSize(cc.size(self._scrollView:getContentSize().width,maxHeight))
    else
        maxHeight = self._scrollView:getContentSize().height      
    end
    local posY = 0

    self._content:setPositionY(maxHeight-posY)
    self._content:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    posY = posY + self._content:getContentSize().height + 10
    concentBg:setPositionY(maxHeight-posY)
    posY = posY + descHeight + 40
    self._luokuan:setPositionY(maxHeight - posY)
    if table.nums(self._mail.att) ~= 0 then
        posY = posY + self._luokuan:getContentSize().height - 30
        self._append:setPositionY(maxHeight - posY)
    end
    -- print("领取附件")
    if table.nums(self._mail.att) ~= 0 then
        if self._mail.rec == 1 then
            self:registerClickEvent(self._receive, function()
                self:close()
            end)
        else
            self:registerClickEvent(self._receive, function()
                if self._mail.mId then
                    -- [[体力超3000不让领取体力 by guojun 2016.8.23 
                    if self._mail.att and #self._mail.att == 1 and self._mail.att[1].type == "physcal" then
                        local physcal = self._modelMgr:getModel("UserModel"):getData().physcal 
                        if physcal >= 3000 then
                            self._viewMgr:showTip("体力接近上限，请去扫荡副本")
                            return 
                        end
                    end
                    --]]
                    self:attachMent()
                end
            end)
        end
    else
        self:registerClickEvent(self._receive, function()
            self:close()
        end)                       
    end

end

--设置附件
function MailBoxDialog:setAttachment()
    local iconId = 301104
    local number = 0
    if table.nums(self._mail.att) == 0 then
        return
    end

    if self._mail.tId == 2 then
        local viplevel = self._modelMgr:getModel("VipModel"):getData().level
        if viplevel >= 13 then
            local desLab1 = self:getUI("bg.scrollView.append.desLab1")
            desLab1:setVisible(true)
            local desLab2 = self:getUI("bg.scrollView.append.desLab2")
            desLab2:setVisible(true)
            desLab2:setColor(cc.c3b(28,162,22))
            -- desLab2:enableOutline(cc.c4b(60,30,10,255), 2)
            
            local vipLab = self:getUI("bg.scrollView.append.vipLab")
            vipLab:setVisible(true)
            vipLab:setString("V" .. 13)
            desLab1:setString("竞技币增加奖励")
            desLab1:setPosition(cc.p(vipLab:getContentSize().width+vipLab:getPositionX()+2, vipLab:getPositionY()))
            desLab2:setString("20%")
            desLab2:setPosition(cc.p(desLab1:getContentSize().width+desLab1:getPositionX(), desLab1:getPositionY()))
        end
    end

    -- for k,v in pairs(self._mail.att) do
    for i=1, table.nums(self._mail.att) do
        local v = self._mail.att[i] or self._mail.att[tostring(i)]
        local itemId, _type, itemNum 

        if v.type then
            itemId = v.typeId
            _type = v.type
            itemNum = v.num
        else
            itemId = v[2]
            _type = v[1] 
            itemNum = v[3]
        end
        if _type == "team" then
            local sysTeam = tab:Team(itemId)
            local param = {sysTeamData = sysTeam, eventStyle = 0, swallowTouches = true,isJin=true}

            local mailIcon = IconUtils:createSysTeamIconById(param)
            mailIcon:setAnchorPoint(cc.p(0, 0))
            mailIcon:setContentSize(cc.size(78, 78))
            -- local scale = 78/mailIcon:getContentSize().width*100
            mailIcon:setScale(0.69)
            mailIcon:setPosition(cc.p(0,0))
            if mailIcon then
                self._appendList:pushBackCustomItem(mailIcon)
            end  
        elseif _type == "hero" then
            local sysHeroData = tab:Hero(itemId)
            local param = {sysHeroData = sysHeroData, effect = false}

            local mailIcon = IconUtils:createHeroIconById(param)
            mailIcon:setAnchorPoint(cc.p(0, 0))
            mailIcon:setContentSize(cc.size(80, 80))
            -- local scale = 78/mailIcon:getContentSize().width*100
            mailIcon:setScale(0.685)
            mailIcon:setPosition(cc.p(-3,-7))
            mailIcon:getChildByName("starBg"):setVisible(false)
            mailIcon:getChildByName("iconStar"):setVisible(false)
            if mailIcon then
                self._appendList:pushBackCustomItem(mailIcon)
            end  
         elseif _type == "avatarFrame" then

            local frameData = tab:AvatarFrame(itemId)
            param = {itemId = itemId, itemData = frameData,eventStyle = 0}
            local mailIcon = IconUtils:createHeadFrameIconById(param)
            -- mailIcon:setAnchorPoint(0,0)
            mailIcon:setScale(0.67)
            mailIcon:setContentSize(cc.size(76, 78))
            if mailIcon then
                self._appendList:pushBackCustomItem(mailIcon)
            end  
        elseif _type == "tool" then
            local toolD = tab:Tool(itemId)
            local param = {itemId = itemId,itemData = toolD,num = itemNum,eventStyle = 1, swallowTouches = true, effect = true}
            local mailIcon = IconUtils:createItemIconById(param)
            mailIcon:setAnchorPoint(cc.p(0, 0))
            mailIcon:setContentSize(cc.size(78, 78))
            -- local scale = 78/mailIcon:getContentSize().width*100
            mailIcon:setScale(0.78)
            mailIcon:setPosition(cc.p(0,0))
            if mailIcon then
                self._appendList:pushBackCustomItem(mailIcon)
            end  
        else
            itemId = iconIdMap[_type]

            local toolD = tab:Tool(itemId)
            local param = {itemId = itemId,itemData = toolD,num = itemNum,eventStyle = 1, swallowTouches = true}
            local mailIcon = IconUtils:createItemIconById(param)
            mailIcon:setAnchorPoint(cc.p(0, 0))
            mailIcon:setContentSize(cc.size(78, 78))
            -- local scale = 78/mailIcon:getContentSize().width*100
            mailIcon:setScale(0.78)
            mailIcon:setPosition(cc.p(0,0))
            if mailIcon then
                self._appendList:pushBackCustomItem(mailIcon)
            end  
        end
    end
    print("附件设置完成")
end

--取附件
function MailBoxDialog:attachMent()
    local mailIdData = {self._mail.mId}
    local mailList = {}
    self._removeMailList = {}
    self._saveMailList = {}
    local count = 0
    local model = {self._mail}
    for k,v in pairs(model) do
        if v and v.att and v.rec == 0 then
            if v.type == 1 then 
                table.insert(self._removeMailList, v)
            elseif v.type == 2 then
                table.insert(self._saveMailList, v)
            end
            table.insert(mailList, v.mId)
            count = count + 1
            if count == 1 then
                break
            end
        end
    end
    dump(mailList)
    self._serverMgr:sendMsg("MailServer", "getAttachment", {mailId=mailIdData}, true, {}, function(result)
        self:attachMentFinish(result)
    end, function(errorId)
        if tonumber(errorId) == 702 then
            for k,v in pairs(self._saveMailList) do
                v.rec = 1
            end
            self._mailModel:setDataByMailList(self._saveMailList)
        end
        -- if tonumber(errorId) == 701 then
        --     --todo
        -- elseif tonumber(errorId) == 702 then
        --     --todo
        -- elseif tonumber(errorId) == 703 then
        --     --todo
        -- elseif tonumber(errorId) == 704 then
        --     --todo
        -- elseif tonumber(errorId) == 705 then
        --     --todo
        -- elseif tonumber(errorId) == 706 then
        --     --todo
        -- elseif tonumber(errorId) == 707 then
        --     --todo
        -- end
-- 701 该邮件不存在
-- 702 不能重复领取附件
-- 703 该邮件已过期
-- 704 该邮件没有附件
-- 705 邮件发送失败
-- 706 邮件附件有误
-- 707 邮件附件物品数量需要大于
    end)
end

function MailBoxDialog:attachMentFinish(result)
    if not result then
        return
    end
    dump(result, "rstu==========", 5)
    for k,v in pairs(self._saveMailList) do
        v.rec = 1
    end
    self._mailModel:removeMailList(self._removeMailList)
    self._mailModel:setDataByMailList(self._saveMailList)
    -- 奖励展示
    local reward = result.reward
    local notChange = false
    for k,v in pairs(reward) do
        if v[1] == "avatarFrame" or v["type"] == "avatarFrame" 
            or v[1] == "avatar" or v["type"] == "avatar" then
            notChange = true
        end
    end
    -- 只有一个头像或者头像框需要特殊展示 hgf
    if notChange and table.nums(reward) == 1 then
        DialogUtils.showAvatarFrameGet( {gifts = reward}) 
    else
        DialogUtils.showGiftGet( {gifts = reward})
    end

    self._removeMailList = nil
    self._saveMailList = nil
    self:close()
end


-- function MailBoxDialog:attachMentFinish(result)
--         local award = {}
--         if self._mail == nil then
--             return
--         end
--         for k,v in pairs(self._mail.att) do
--             award[k+0] = {}
--             local x = 1
--             for k1,v1 in pairs(v) do
--                 award[k+0][x] = v1 
--                 x = x + 1
--             end
--         end
--         if self._mail.type == 1 then 
--             print("类型1有附件邮件")           
--             self._model:removeMail(self._mail)
--         elseif self._mail.type == 2 then
--             print("类型2有附件邮件")
--             self._mail.rec = 1
--             self._model:setDataByMailID(self._mail)
--         else
--             self._viewMgr:showTip("邮件类型有误" .. self._mail.type)
--             self._mail.rec = 1
--             self._model:setDataByMailID(self._mail)
--         end
--         DialogUtils.showGiftGet(award)
--         self:close()
-- end

function MailBoxDialog:limitLen(str, maxNum)
    local lenInByte = #str
    local lenNum = 0
    for i=1,lenInByte do
        local curByte = string.byte(str, i)
        if curByte>0 and curByte<=127 then
            lenNum = lenNum + 1
        elseif curByte>=192 and curByte<225 then
            lenNum = lenNum + 2
            maxNum = maxNum + 1
        elseif curByte>=225 and curByte<=247 then
            lenNum = lenNum + 3
            maxNum = maxNum + 1
        end
        if lenNum >= maxNum then
            break
        end
    end
    str = string.sub(str, 1, lenNum)
    return str
end

function MailBoxDialog:checkChar(str)
    str = string.gsub(str, "%b[]", "")
    local lenInByte = #str
    local lenNum = 0
    local maxNum = 0
    local subNum = 0
    local tempNum = 1
    local tempIndex = 1
    local strTab = {}
    for i=1,lenInByte do
        local curByte1, curByte2
        if i+1 > lenInByte then
            curByte1 = string.byte(str, i)
            curByte2 = 123
            -- strTab[tempIndex] = string.sub(str, tempNum, lenNum)
        else
            curByte1 = string.byte(str, i)
            curByte2 = string.byte(str, i + 1)
        end
        local temp1 = self:checkChar1(curByte1)
        local temp2 = self:checkChar1(curByte2)

        if temp1 ~= temp2 then
            if temp1 == true and temp2 == false then
                strTab[tempIndex] = string.sub(str, tempNum, lenNum + 1)
                tempNum = lenNum + 2
            else
                strTab[tempIndex] = string.sub(str, tempNum, lenNum)
                tempNum = lenNum + 1
            end
            tempIndex = tempIndex + 1
        elseif i == lenInByte and temp1 == temp2 then
            strTab[tempIndex] = string.sub(str, tempNum, lenInByte)
        end

        if curByte1>0 and curByte1<=127 then
            lenNum = lenNum + 1
        elseif curByte1>=192 and curByte1<225 then
            lenNum = lenNum + 2
        elseif curByte1>=225 and curByte1<=247 then
            lenNum = lenNum + 3
        end
    end
    -- dump(strTab)

    local tempStr = ""
    for i=1, table.nums(strTab) do
        tempStr = tempStr ..  "[color=3D1F00]" .. strTab[i] .. "[-]"
    end
    print(tempStr)
    return tempStr
end

function MailBoxDialog:checkChar1(curByte)
    local flag = false
    if curByte>0 and curByte<=127 then
        flag = true
    elseif curByte>=192 and curByte<225 then
        -- flag = true
    elseif curByte>=225 and curByte<=247 then
        -- maxNum = maxNum + 3
    end
    return flag
end

return MailBoxDialog