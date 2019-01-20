--[[
    Filename:    ChatModel.lua
    Author:      <weiwei02@playcrab.com>
    Datetime:    2016-03-10 11:41:42
    Description: File description
--]]


local ChatModel = class("ChatModel", BaseModel)

function ChatModel:ctor()
    ChatModel.super.ctor(self)
    self._friendModel = self._modelMgr:getModel("FriendModel")
    self._userModel = self._modelMgr:getModel("UserModel")
    self._userModelData = self._modelMgr:getModel("UserModel"):getData()
    require("game.view.chat.ChatConst")

    self._allPushData = {}      --用于判断消息是否有重复id
    self._currPirDataOnShow = {}--私聊当前显示的玩家（策划需求一次只显示最多5个用户）
    self._isLoadData = {}
    self._cacheUserData = {}    --当前聊天用户信息

    self._guildUnread = 0       --联盟未读数
    self._worldUnread = 0       --联盟未读数
    self._godWarUnread = 0      --跨服诸神未读数
    self._unreadPir = {}        --私聊未读用户ID
     
    self._deleteRecord = {}     --删除数据记录
    self._loginNum = 0
    self._isPriViewOpen = false
    self._isChatViewOpen = false
    self._curChannel = nil
    self._bannedList = {}        --禁言信息列表【取最新十条】

    for k,v in pairs(ChatConst.CHAT_CHANNEL) do
        self._isLoadData[v] = false
    end

    for k,v in pairs(ChatConst.CHAT_CHANNEL) do
        self._data[v] = {}
    end
end

function ChatModel:setCurrChannel(channel)  
    self._curChannel = channel
end

function ChatModel:setIsOpenPrivateView(data)
    self._isPriViewOpen = data
end  

function ChatModel:setIsChatViewOpen(data)
    self._isChatViewOpen = data
end

function ChatModel:setLoadDataByChannel(inChannel)
    self._isLoadData[inChannel] = true
end

function ChatModel:getIsLoadDataByChannel(inChannel)
    return self._isLoadData[inChannel]
end

function ChatModel:getData()
    return self._data
end
 
function ChatModel:setData(data)
    self._data =  data
end

--设置当前聊天玩家信息
function ChatModel:checkInsertUserData(userData)
    if userData == nil then return end

    self._cacheUserData = userData
    local isHasChat = false
    local currUser = {}
    local currPriData = self._data[ChatConst.CHAT_CHANNEL.PRIVATE]

    --判断是否之前有聊过天
    for k,v in pairs(currPriData) do
        if v["user"].rid == userData.rid then
            isHasChat = true
            currUser = v
            table.remove(currPriData, k)
            break
        end
    end

    --没有聊过则初始化一个空结构，有则更新玩家user数据
    if not isHasChat then
        currUser["user"] = userData
        currUser["chat"] = {}
    else
        currUser["user"] = userData
    end

    --移动玩家页签到顶部
    if ChatConst.IS_DEBUG_OPEN == true then
        table.insert(currPriData, #currPriData, currUser)  --排序到列表第二位，顶部默认给debug反馈
    else
        table.insert(currPriData, #currPriData+1, currUser)
    end
end

function ChatModel:refreshPriUserData(data1, data2)
    if not data1 and not data2 then
        return
    end
    local curId = data1.rid or data2.rid
    local priData = self._data[ChatConst.CHAT_CHANNEL.PRIVATE]
    for k,v in pairs(priData) do
        if v["user"].rid == curId then
            for m, n in pairs(v["user"]) do
                if data1[m] or data2[m] then
                    n = data1[m] or data2[m]
                end
            end
            v["user"]["plvl"] = data1["plvl"] or data2["plvl"]
            break
        end
    end

    self:reflashData("pri" .. "/user/" .. curId)
end

function ChatModel:setCacheUserID(userID)
    local currPriData = self._data[ChatConst.CHAT_CHANNEL.PRIVATE]
    for k,v in pairs(currPriData) do
        if v["user"].rid == userID then
            self._cacheUserData = v["user"]
            return
        end
    end
end

--获取当前聊天玩家信息
function ChatModel:getCacheUserData()
    return self._cacheUserData
end

function ChatModel:clearCacheUser()
    self._cacheUserData = {}
end


function ChatModel:updatDataByType(inType, data)
    -- dump(data, "updatDataByType--"..inType)   --最早的消息index为0
    if inType == ChatConst.CHAT_CHANNEL.SYS then                --系统
        self:updateSysData(data, inType)

    elseif inType == ChatConst.CHAT_CHANNEL.PRIVATE then        --私聊
        self:updatePriData(data, inType)

    elseif inType == ChatConst.CHAT_CHANNEL.WORLD then          --世界
        self:undateWorldData(data, inType)

    elseif inType == ChatConst.CHAT_CHANNEL.GODWAR then         --跨服诸神
        self:updateCrossWarData(data,inType)
        
    elseif inType == ChatConst.CHAT_CHANNEL.FSERVER then        --全服
        self:updateFullServerData(data,inType)

    else                                                        --联盟
        self:updateGuildData(data,inType)
    end
end

function ChatModel:updateSysData(data, inType)
    local sortFunc = function(a, b) return a.id > b.id end

    for k,v in pairs(data) do
        self:handleSysText(v)
    end
    self._data[inType] = data
    table.sort(self._data[inType], sortFunc)
end

function ChatModel:undateWorldData(data, inType)
    local loginTime = self._userModelData._lt or 0
    local closeTime = self._userModelData.leaveTime or 0
    local sortFunc = function(a, b) return a.id > b.id end 

    local unreadNum = 0
    for i=#data, 1, -1 do
        if data[i]["message"] ~= nil then
            --世界官方消息数据结构重组
            if data[i]["message"]["idip"] and data[i]["message"]["idip"] == 1 and inType == ChatConst.CHAT_CHANNEL.WORLD then
                _, _, data[i] = self:paramHandle("guanfang", data[i], false)
            end

            --黑名单/文字处理
            if data[i]["message"]["udata"] and data[i]["message"]["udata"]["rid"] then
                local _id = data[i]["message"]["udata"]["rid"]
                if self._friendModel:checkIsBlack(_id) then 
                    table.remove(data, i)  --黑名单
                else
                    self:handleEmoji(data[i])
                    --未读数
                    if data[i]["t"] > closeTime and data[i]["t"] <= loginTime then
                        unreadNum = unreadNum + 1
                    end

                    --自己发言最近十条
                    self:insertBannedList(data[i], true)   --最新的在数组最后
                end
            end
        end
    end
    
    self:setUnread(unreadNum, ChatConst.CHAT_CHANNEL.WORLD, true)
    self._data[inType] = data
    table.sort(self._data[inType], sortFunc)
end

function ChatModel:updateGuildData(data, inType)
    local loginTime = self._userModelData._lt or 0
    local closeTime = self._userModelData.leaveTime or 0
    local sortFunc = function(a, b) return a.id > b.id end 

    local guildLeave = self._userModelData.guildLeave or 0
    local unreadNum = 0

    for i=#data, 1, -1 do
        if data[i]["t"] <= guildLeave then
            table.remove(data, i)
        else
            if data[i]["message"] ~= nil then
                --世界官方消息数据结构重组
                if data[i]["message"]["idip"] and data[i]["message"]["idip"] == 1 and inType == ChatConst.CHAT_CHANNEL.WORLD then
                    _, _, data[i] = self:paramHandle("guanfang", data[i], false)
                end

                --黑名单/文字处理
                if data[i]["message"]["udata"] and data[i]["message"]["udata"]["rid"] then
                    local _id = data[i]["message"]["udata"]["rid"]
                    if self._friendModel:checkIsBlack(_id) then 
                        table.remove(data, i)  --黑名单
                    else
                        self:handleEmoji(data[i])
                        --未读数
                        if data[i]["t"] > closeTime and data[i]["t"] <= loginTime then
                            unreadNum = unreadNum + 1
                        end
                    end
                end
            end
        end
    end
    
    self:setUnread(unreadNum, ChatConst.CHAT_CHANNEL.GUILD, true)
    self._data[inType] = data
    table.sort(self._data[inType], sortFunc)
end

function ChatModel:updatePriData(data, inType)
    local loginTime = self._userModelData._lt or 0
    local closeTime = self._userModelData.leaveTime or 0
    local sortFunc = function(a, b) return a.id > b.id end 

    for i=#data, 1, -1 do
        if data[i]["user"] then
            data[i]["user"] = {}
        end

        local isNew = false  --数据是否完整
        local isFindUnread = false   --是否未读
        local chatData = data[i]["chat"]
        for k=#chatData, 1, -1 do
            if chatData[k]["message"] and chatData[k]["message"]["toData"] and chatData[k]["message"]["toData"].rid then
                local curPriData = chatData[k]["message"]
                --设置玩家user字段
                if not data[i]["user"] or next(data[i]["user"]) == nil then   
                    if curPriData["toData"].rid == self._userModelData._id then
                        data[i]["user"] = curPriData["udata"]
                    else
                        data[i]["user"] = curPriData["toData"]
                    end
                end
                
                --设置未读数
                if not isFindUnread and chatData[k]["t"] > closeTime and chatData[k]["t"] <= loginTime then
                    local toId
                    if self._userModelData._id ~= curPriData["udata"]["rid"] then
                        toId = curPriData["udata"]["rid"]

                    elseif self._userModelData._id ~= curPriData["toData"]["rid"] then
                        toId = curPriData["toData"]["rid"]
                    end

                    if toId then
                        self:setPriUnread(toId, "login")
                        isFindUnread = true
                    end
                end
                
                isNew = true
            else
                table.remove(chatData, k)
            end
        end

        if isNew == false then
            table.remove(data, i)
        end
    end

    -- 黑名单数据清除
    -- 插入bug反馈数据
    for i=#data, 1, -1 do
        local _id = data[i]["user"]["rid"] 
        if self._friendModel:checkIsBlack(_id) then 
            table.remove(data, i)  --黑名单
        else
            for k,msg in pairs(data[i]["chat"]) do
                self:handleEmoji(msg)
            end
            table.sort(data[i]["chat"], sortFunc)  
        end
    end

    --聊天user排序  表末尾为最新数据
    local userSort = function(a, b) return a["chat"][1].t < b["chat"][1].t end
    self._data[inType] = data  
    table.sort(self._data[inType], userSort) 
    if ChatConst.IS_DEBUG_OPEN == true then
        self:insertDebugData()  --插入debug数据至表顶
    end
end

function ChatModel:updateCrossWarData(data,inType)
    local loginTime = self._userModelData._lt or 0
    local closeTime = self._userModelData.leaveTime or 0
    local sortFunc = function(a, b) return a.id > b.id end

    local unreadNum = 0
    for i=#data, 1, -1 do
        if data[i]["message"] ~= nil then
            --黑名单/文字处理
            if data[i]["message"]["udata"] and data[i]["message"]["udata"]["rid"] then
                local _id = data[i]["message"]["udata"]["rid"]
                if self._friendModel:checkIsBlack(_id) then 
                    table.remove(data, i)  --黑名单
                else
                    self:handleEmoji(data[i])
                    --未读数
                    if data[i]["t"] > closeTime and data[i]["t"] <= loginTime then
                        unreadNum = unreadNum + 1
                    end
                end
            end
        end
    end
    
    self:setUnread(unreadNum, ChatConst.CHAT_CHANNEL.GODWAR, true)
    self._data[inType] = data
    table.sort(self._data[inType], sortFunc)
end

function ChatModel:updateFullServerData(data,inType)
    local loginTime = self._userModelData._lt or 0
    local closeTime = self._userModelData.leaveTime or 0
    local sortFunc = function(a, b) return a.id > b.id end
    table.sort(data, sortFunc)

    -- local unreadNum = 0
    for i=#data, 1, -1 do
        if data[i]["message"] ~= nil then
            --黑名单/文字处理
            if data[i]["message"]["udata"] and data[i]["message"]["udata"]["rid"] then
                local _id = data[i]["message"]["udata"]["rid"]
                local cellType = data[i]["message"]["udata"]["cellType"]
                if self._friendModel:checkIsBlack(_id) or cellType == ChatConst.CELL_TYPE.FSERVER2 then
                    table.remove(data, i)  --黑名单
                else
                    self:handleEmoji(data[i])
                    --未读数
                    -- if data[i]["t"] > closeTime and data[i]["t"] <= loginTime then
                    --     unreadNum = unreadNum + 1
                    -- end

                    --计算两条消息之间的时间差
                    if i == #data then
                        data[i]["disT"] = 60 * 60 * 24 + 1
                    else
                        local lastT = data[i + 1]["t"]  --上一条
                        local curT = data[i]["t"]       --当前
                        data[i]["disT"] = math.max(0, curT - lastT)
                    end
                end
            end
        end
    end
    
    -- self:setUnread(unreadNum, ChatConst.CHAT_CHANNEL.FSERVER, true)
    self._data[inType] = data 
end

function ChatModel:getPrivateChatWithNum(inType)
    -- self._currPirDataOnShow = {}
    -- local priData = clone(self._data[ChatConst.CHAT_CHANNEL.PRIVATE])
    -- if #priData >= ChatConst.CHAT_PRIVATE_USER_MAX_LEN then
    --     local limitNum = #priData - ChatConst.CHAT_PRIVATE_USER_MAX_LEN + 1
    --     for i=#priData, limitNum, -1 do
    --         table.insert(self._currPirDataOnShow,1, priData[i])
    --     end
    -- else
    --     self._currPirDataOnShow = priData
    -- end
    -- return self._currPirDataOnShow

    --改为：去掉玩家列表5条上限限制
    local priData = clone(self._data[ChatConst.CHAT_CHANNEL.PRIVATE])
    local index = 1  --第一个默认bug反馈
    if inType and inType == 1 then
        index = 2
    end
    for i=#priData - index, 1, -1 do  
        local tempD = priData[i]
        local userID = tempD["user"].rid

        if self._unreadPir[userID] ~= nil then
            table.insert(priData, #priData + 1 - index, tempD)
            table.remove(priData, i)
        end
    end

    self._currPirDataOnShow = priData
    return self._currPirDataOnShow
end

--通过玩家id获取信息  
function ChatModel:getPrivateDataByUserID(avataID)
    if not avataID then
        return {}
    end

    for k,v in pairs(self._data["pri"]) do
        if v["user"].rid == avataID then
            return self._data["pri"][k]["chat"]
        end
    end
    return {}
end

function ChatModel:removeDataByChannel(inChannel, inIndex, priID)
    if inChannel == "pri" then
        if priID then
            for i,v in ipairs(self._data[inChannel]) do     --删除聊天
                if v["user"].rid == priID and #v["chat"] >= inIndex then
                    table.remove(v["chat"], inIndex)
                    break
                end
            end
        else
            if #self._currPirDataOnShow >= inIndex then       --删除用户
                for i,v in ipairs(self._data[inChannel]) do
                    if v["user"].rid == self._currPirDataOnShow[inIndex]["user"].rid then
                        table.remove(self._data[inChannel], i)   --00先删除总表数据
                        break
                    end
                end
                table.remove(self._currPirDataOnShow, inIndex)   --删除当前显示表中数据
            end

            -- if #self._data[inChannel] >= inIndex then   --改成全部显示后 只需删除self._data[inChannel]
            --     table.remove(self._data[inChannel], inIndex)
            -- end
        end
        
    else
        if #self._data[inChannel] >= inIndex then 
            table.remove(self._data[inChannel], inIndex)
        end
    end  
end

--服务器/手动推送
function ChatModel:pushData(data)
    dump(data, "push", 10)

    if data == nil then
        return
    end

    --黑名单检查屏蔽
    if data["message"] and data["message"]["udata"] and data["message"]["udata"]["rid"] then
        local isInBlack = self._friendModel:checkIsBlack(data["message"]["udata"]["rid"])
        if isInBlack then
            return
        end
    end
    
    --重复id检查
    if self:backupPushData(data) == true then
        return 
    end

    --移除多余条数
    self:removeExcessData(data)

    --语音红点记录
    if data.message and data.message.typeCell and data.message.typeCell == ChatConst.CELL_TYPE.VOICE then
        self:setVoiceReadState(data.message.textId, true)
    end
    
    if data.type == ChatConst.CHAT_CHANNEL.SYS then             --系统
        self:handleSysText(data)
        table.insert(self._data[data.type], 1, data)
        self:reflashData(data.type)

    elseif data.type == ChatConst.CHAT_CHANNEL.PRIVATE then     --私聊
        self:pushPrivateData(data)

    elseif data.type == ChatConst.CHAT_CHANNEL.GUILD then       --联盟
        self:pushGuildData(data)

    elseif data.type == ChatConst.CHAT_CHANNEL.GODWAR then     --跨服诸神
        self:pushGodWarData(data)
        
    elseif data.type == ChatConst.CHAT_CHANNEL.WORLD then       --世界 
        self:pushWorldData(data) 

    elseif data.type == ChatConst.CHAT_CHANNEL.FSERVER then     --全服
        self:pushFullServerData(data) 

    elseif data.type == ChatConst.CHAT_CHANNEL.FSERVER1 then    --全服喊话
        self:pushFullServerData(data)

    elseif data.type == ChatConst.CHAT_CHANNEL.DEBUG then       --debug反馈
        self:pushPrivateData(data)

    elseif data.type == ChatConst.CHAT_CHANNEL.ARENA_NPC then   --排行榜NPC
        self:pushPrivateData(data)
    end
end

-- push消息重复id判断
-- 注：【在没有load聊天数据之前有重复id加入，再有push消息时就会删掉】
function ChatModel:backupPushData(data)
    if data == nil or data.id == nil or data.type == nil then return false end 

    -- 私聊/debug/竞技场npc
    if data.type == "pri" or data.type == "debug" or data.type == "arena" then
        local pushUser = clone(data["message"]["udata"]["rid"])
        if pushUser == self._userModelData["_id"] then  --自己
            pushUser = self._cacheUserData["rid"]
        end

        for i=#self._data["pri"], 1, -1 do
            local priData = self._data["pri"][i]
            if priData["user"]["rid"] == pushUser then 
                return self:backupPushDataCheck(priData["chat"], data)
            end
        end
        
    -- 系统/世界/联盟
    elseif data.type == "sys" or data.type == "all" or data.type == "guild" then
        return self:backupPushDataCheck(self._data[data.type], data)
    end

    return false
end

function ChatModel:backupPushDataCheck(inTable, data)
    if data == nil or data.id == nil or data.type == nil then return false end 

    self._allPushData = {}

    --push前数据是否有重复id
    for i=#inTable, 1, -1 do
        local tempCacheId = self._allPushData[inTable[i].id]
        if tempCacheId == nil then 
            self._allPushData[inTable[i].id] = 1
        else
            table.remove(inTable, i)
        end
    end

    --push的数据是否是重复id
    if self._allPushData[data.id] then
        return true
    end
    return false
end

-- 聊天条数上限判断
-- 注：【当前聊天页的上限在页面中判断处理，以下为非当前聊天页的处理】
--【只在push消息才会处理】
function ChatModel:removeExcessData(data)
    -- 私聊/debug/竞技场NPC
    if data.type == "pri" or data.type == "debug" or data.type == "arena" then 
        local priData = self._data[ChatConst.CHAT_CHANNEL.PRIVATE]
        local pushId = data["message"]["udata"]["rid"]

        if not (self._userModelData._id == pushId or self._cacheUserData["rid"] == pushId) then   --非当前聊天页
            for i=#priData, 1, -1 do
                if priData[i]["user"].rid == pushId then
                    local chatData = priData[i]["chat"]
                    if #chatData >= ChatConst.CHAT_MSG_MAX_LEN then
                        --删掉上限临界值是为了给新push的数据腾地
                        for k=#chatData, ChatConst.CHAT_MSG_MAX_LEN, -1 do
                            table.remove(chatData, k)
                        end
                    end
                    break
                end
            end
        end
        
    -- 系统/世界/联盟
    elseif data.type == "sys" or data.type == "all" or data.type == "guild" then 
        local chatData = self._data[data.type]
        if not (data.type == self._curChannel) and #chatData >= ChatConst.CHAT_MSG_MAX_LEN then  --非当前频道
            for i=#chatData, ChatConst.CHAT_MSG_MAX_LEN, -1 do
                table.remove(chatData, i)
            end
        end
    end
end

--文本替换【用于非玩家发送的信息，策划配富文本太长，所以只发文字lang表字段，push之后再对文字做替换】
function ChatModel:replacePushText(inData)
    if inData.message and inData.message.typeCell then
        local inMsg = inData.message

        --世界 战报分享
        local cellType = inMsg.typeCell
        if cellType == ChatConst.CELL_TYPE.WORLD2 then
            if inMsg.reportInfo and inMsg.reportInfo.enemyName then
                --名字特殊字符替换
                local enemyName = inMsg.reportInfo.enemyName
                enemyName = self:replaceSepcialSignal(enemyName)

                inMsg.text = string.gsub(lang("REPLAY_ARENA"),"{$enemyname}",enemyName)
            end
            
        elseif cellType == ChatConst.CELL_TYPE.WORLD5 then
            if inMsg.reportInfo and inMsg.reportInfo.enemyName then
                --名字特殊字符替换
                local enemyName = inMsg.reportInfo.enemyName
                enemyName = self:replaceSepcialSignal(enemyName)

                inMsg.text = string.gsub(lang("REPLAY_GLORYARENA"),"{$enemyname}",enemyName)
            end

        --世界/私聊 联盟招募
        elseif cellType == ChatConst.CELL_TYPE.WORLD3 or 
            cellType == ChatConst.CELL_TYPE.PRI5 or 
            cellType == ChatConst.CELL_TYPE.PRI6 then
            local str
            if inMsg.zhaomu and inMsg.zhaomu.lvlimit > 0 then
                str = string.gsub(lang("GUILD_RECRUIT_1"), "{$level}", inMsg.zhaomu.lvlimit)
            else
                str = lang("GUILD_RECRUIT_2")
            end
            if inMsg.zhaomu and inMsg.zhaomu.guildName then
                inMsg.text = string.gsub(str, "{$guildName}", inMsg.zhaomu.guildName) 
            end
            if inMsg.zhaomu and inMsg.zhaomu.guildLevel then
                inMsg.text = string.gsub(inMsg.text, "{$guildLv}", inMsg.zhaomu.guildLevel) 
            end

        --联盟秘境
        elseif cellType == ChatConst.CELL_TYPE.GUILD3 then
            inMsg.text = lang("LIANMENG_4")

        --私聊 好友切磋战报
        elseif cellType == ChatConst.CELL_TYPE.PRI4 then
            inMsg.text = lang("FRIEND_PK")
        end
    end

    return inData
end

function ChatModel:replaceUserSendText(inText)
    if inText == nil then
        return "。。"
    end

    local str = string.gsub(inText, "%[", "【")
    str = string.gsub(str, "%]", "】")

    -- local str = string.gsub(inText, "%b[]", "")
    -- if str == "" then
    --     str = "。。"
    -- end

    return str
end

--联盟消息推送
function ChatModel:pushGuildData(data)
    if data.typeCell == ChatConst.CELL_TYPE.GUILD2 then
        if data.message.id == "GUILD_RED_BOX" then
            self:handleSysText(data)
        end
    else
        self:handleEmoji(data)
    end
    table.insert(self._data[data.type], 1, data)

    if not self._isChatViewOpen or self._curChannel ~= ChatConst.CHAT_CHANNEL.GUILD then
        self._guildUnread = self._guildUnread + 1
        self:reflashData("priUnread")  
    end
    self:reflashData(data.type)
end

--跨服诸神
function ChatModel:pushGodWarData(data)
    self:handleEmoji(data)
    table.insert(self._data[data.type], 1, data)

    if not self._isChatViewOpen or self._curChannel ~= ChatConst.CHAT_CHANNEL.GODWAR then
        self._godWarUnread = self._godWarUnread + 1
        self:reflashData("priUnread")  
    end
    self:reflashData(data.type)
end

--世界消息推送
function ChatModel:pushWorldData(data)
    --官方世界消息重组
    if data["message"] and data["message"]["idip"] and data["message"]["idip"] == 1 then
        _, _, data = self:paramHandle("guanfang", data, false)
    end

    self:handleEmoji(data)
    table.insert(self._data[data.type], 1, data)
    self:insertBannedList(data)

    if not self._isChatViewOpen or self._curChannel ~= ChatConst.CHAT_CHANNEL.WORLD then
        self._worldUnread = self._worldUnread + 1
        self:reflashData("priUnread")  
    end
    self:reflashData(data.type)
end

function ChatModel:pushFullServerData(data)
    --喊话类型：在全服界面才接收push，不展示在聊天滚动区域
    local typeCell = data.message.typeCell
    if typeCell == ChatConst.CELL_TYPE.FSERVER2 and 
     self._isChatViewOpen and self._curChannel == ChatConst.CHAT_CHANNEL.FSERVER then    
        self:setCallChatData(data)
        return
    end

    --添加时间差
    local tempData = self._data[data.type]
    local curT = data.t or 0
    if #tempData == 0 then
        data["disT"] = 60 *60 * 24 + 1
    else
        local lastT = tempData[1].t or 0
        data["disT"] = math.max(0, curT - lastT)
    end

    self:handleEmoji(data)
    table.insert(self._data[data.type], 1, data)

    if not self._isChatViewOpen or self._curChannel ~= ChatConst.CHAT_CHANNEL.FSERVER then
        local cellType = data["message"] and data["message"]["typeCell"]  --@类型
        if cellType == ChatConst.CELL_TYPE.FSERVER3 and data["message"]["callId"] == self._userModel:getData()._id then
            self:setConnectUserList(data)
            self:reflashData("priUnread")  --外部红点
        end
        return
    end
    self:reflashData(data.type)  --界面红点   
end

function ChatModel:setConnectUserList(data)
    if self._connectList and next(self._connectList) ~= nil then
        return
    end

    self._connectList = {}
    table.insert(self._connectList, data)
    self:reflashData("priUnread")
end

function ChatModel:getConnectUserList()
    return self._connectList or {}
end

function ChatModel:clearConnectUserList()
    self._connectList = {}
    self:reflashData("priUnread")
end

function ChatModel:setCallChatData(data)
    if self._callChats == nil then
        self._callChats = {}
    end

    self._callChats = data
    self:reflashData("CallChat")
end

function ChatModel:getCallChatData()
    return self._callChats or {}
end

function ChatModel:clearCallChatData()
    self._callChats = {}
end

--私聊消息推送
function ChatModel:pushPrivateData(data)
    --如果未load数据只设置红点
    if self._isLoadData[ChatConst.CHAT_CHANNEL.PRIVATE] == false then
        self:setPriUnread(data.message.udata.rid) 
        return
    end

    local currPriData = self._data[ChatConst.CHAT_CHANNEL.PRIVATE]   --00当前私聊信息
    local currUserData = self:getCacheUserData()                     --00当前聊天对象信息
    local pushUserData = data.message.udata                          --00信息发送者
    local toUserData = data.message.toData                           --00信息被发送对象

    self:handleEmoji(data)

    if data.message.udata.rid and data.message.udata.rid == self._userModelData._id then  --00自己发送的信息
        if self._isPriViewOpen == false then   --私聊界面未开
            local isHasChat = false  
            for i,v in pairs(currPriData) do   
                if v["user"].rid == toUserData.rid then    --00已聊过
                    isHasChat = true   
                    table.insert(v["chat"], 1, data)
                end
            end
            if isHasChat == false then      --00未聊过
                local addData = {}
                addData["user"] = toUserData
                addData["chat"] = {data}
                if ChatConst.IS_DEBUG_OPEN == true then
                    table.insert(currPriData, #currPriData, addData)  --排序到列表第二位，顶部默认给debug反馈
                else
                    table.insert(currPriData, #currPriData+1, addData)
                end
            end

        else
            for k,v in pairs(currPriData) do   --00当前聊天对象
                if v["user"].rid == currUserData.rid then               
                    table.insert(v["chat"], 1, data)
                    self:reflashData("pri/"..currUserData.rid)
                    break
                end
            end
        end
        
    else   --非自己发送的信息
        if self._isPriViewOpen == false then
            self:setPriUnread(data.message.udata.rid) 
        end

        local isOnShow = false
        for i,v in ipairs(self._currPirDataOnShow) do   --是否在页面显示
            if v["user"].rid == data.message.udata.rid then
                isOnShow = true
                break
            end
        end

        local isHasChat = false 
        for k,v in pairs(currPriData) do   --00已聊过
            if v["user"].rid == data.message.udata.rid then         
                isHasChat = true
                if isOnShow then    --已聊过且显示在页面中
                    table.insert(v["chat"], 1, data)
                    self:reflashData(data.type.. "/"..pushUserData.rid)
                else                --已聊过但未显示在页面中
                    table.insert(v["chat"], 1, data)
                    self:setPriUnread(pushUserData.rid)  --未读添加
                end
                break
            end
        end

        if not isHasChat then      --00未聊过
            local addData = {}
            addData["user"] = pushUserData
            addData["chat"] = {data}
            if ChatConst.IS_DEBUG_OPEN == true then
                table.insert(currPriData, #currPriData, addData)  --排序到列表第二位，顶部默认给debug反馈
            else
                table.insert(currPriData, #currPriData+1, addData)
            end
            self:setPriUnread(pushUserData.rid)  --未读添加
        end
    end
end

--文字处理
function ChatModel:handleSysText(data)
    local context = ""
    local notSepcialStr = false   --无需特殊处理的字段标识
    if data.type and data.type == "guild" then
        context = lang(data.message.text)
    elseif data.message.id == "GUANGBO_AWAKING" then
        context = lang("GUANGBO_11")
    elseif data.message.id == "GUANGBO_13_1_1" or data.message.id == "GUANGBO_13_1_2"
        or data.message.id == "GUANGBO_13_1_3" or data.message.id == "GUANGBO_13_2"
        or data.message.id == "GUANGBO_13_3" then

        context = lang(data.message.id)
        notSepcialStr = true
    else
        context = lang(data.message.id .. "_3")
    end
    
    for i,v in pairs(data.message.value) do
        local releaceData = string.split(v, "::")
        if #releaceData == 2 then
            local name = releaceData[2]
            local key = releaceData[1]
            if string.find(key, '$teamId') ~= nil then            
                local sysTeam = tab:Team(tonumber(releaceData[2]))
                if data.message.id == "GUANGBO_AWAKING" then   --兵团觉醒
                    key = "$awakingName"
                    name = lang(sysTeam.awakingName)
                else
                    name = lang(sysTeam.name)
                end

            elseif string.find(key, '$gift') ~= nil then
                local giftId = self:getGiftId(releaceData[2])
                local sysTool = tab:Tool(tonumber(giftId))
                name = lang(sysTool.name)
            end
            --名字特殊字符替换
            name = self:replaceSepcialSignal(name)
            
            local uresult,count1 = string.gsub(context, key, name)
            if count1 > 0 then 
                context = uresult
            end
            --无需特殊处理的字段，只需要按照value数组中的key替换语言表中对应的key
            if notSepcialStr then
                context = string.gsub(context,key,name)
            end

        end
    end
    data.message.text = context
end

--表情处理  
function ChatModel:handleEmoji(data)
    --文本替换 2016/12/9
    self:replacePushText(data)

    data.message.stext = data.message.text
    local tempText = string.gsub(data.message.text, "<[^>]+>",function(inSubStr)
        local sysEmoji = tab.emoji[inSubStr]
        if sysEmoji == nil then 
            return inSubStr
        end
        return "[-][gif = asset/other/emoji/" .. sysEmoji.resource .. " ,width = 35, height = 35, tile = true][-][color=3c2a1e]"
    end)
    tempText = "[color=3c2a1e, fontsize = 18]" .. tempText
    if string.sub(tempText, string.len(tempText) - 3, string.len(tempText)) ~= "[-]" then 
        tempText = tempText .. "[-]"
    end
    tempText = string.gsub(tempText, "%[color=632c0f%]%[%-%]", "")
    data.message.text = tempText
end

function ChatModel:getDataByType(inType)
    return self._data[inType]
end

--未读数  世界/联盟
function ChatModel:setUnread(num, inType, isLogin)
    if inType == ChatConst.CHAT_CHANNEL.WORLD then
        self._worldUnread = num

    elseif inType == ChatConst.CHAT_CHANNEL.GUILD then
        self._guildUnread = num

    elseif inType == ChatConst.CHAT_CHANNEL.GODWAR then
        self._godWarUnread = num
    end

    if not isLogin then
        self:reflashData("priUnread")
    end 
end

function ChatModel:getUnread(inType)
    if inType == ChatConst.CHAT_CHANNEL.WORLD then
        return self._worldUnread or 0

    elseif inType == ChatConst.CHAT_CHANNEL.GUILD then
        return self._guildUnread or 0 

    elseif inType == ChatConst.CHAT_CHANNEL.GODWAR then
        return self._godWarUnread or 0 

    elseif inType == ChatConst.CHAT_CHANNEL.FSERVER then
        return #(self._connectList or {}) 
    end

    return 0
end

--未读数  私聊
function ChatModel:setPriUnread(userID, isLogin)
    if self._unreadPir[userID] == nil then
        self._unreadPir[userID] = 1
    end

    if not (isLogin == "login") then
        self:reflashData("priUnread")
    end
end

function ChatModel:removePriUnread(userID)
    if self._unreadPir[userID] then
        self._unreadPir[userID] = nil
    end

    self:reflashData("priUnread")
end

function ChatModel:getPriUnread()
    return self._unreadPir 
end

-- debug反馈
function ChatModel:getReortlist( callback )
    ApiUtils.playcrab_get_question_result(function( result )
        local proData = {}
        for k,v in pairs(result or {}) do
            self:generateChat(v,proData)
        end
        
        if callback then 
            callback(proData)
        end
    end)
end

function ChatModel:generateChat( data,proData )
    proData = proData or {}
    local userModel = ModelManager:getInstance():getModel("UserModel"):getData()
    local userReport = {
        id = 2400,
        message = {
            text = data.content,
            udata = {
                avatar = userModel.avatar,
                guildName = userModel.name,
                lvl = userModel.lvl,
                name = userModel.name,
                rid = userModel._id,
                vipLvl = ModelManager:getInstance():getModel("VipModel"):getData().level or 0,
            }
        },
        t = data.create_time,
        ["type"] = "debug",
    }
    table.insert(proData,userReport)

    local opReport = {
        id = 2400,
        message = {
            text = "您好！您反馈的bug我们会尽快处理！",
            udata = {
                avatar = 2302,
                guildName = "",
                lvl = 0,
                name = "会跳舞的小妖精",
                rid = "bug_op",
                vipLvl = 0,
            }
        },
        t =  data.create_time+1, 
        ["type"] = "debug",
    }
    table.insert(proData,opReport)

    if data.op_datetime then
        local opReport = {
            id = 2400,
            message = {
                text = data.op_content,
                udata = {
                    avatar = 2302,
                    guildName = "",
                    lvl = 0,
                    name = "会跳舞的小妖精",
                    rid = "bug_op",
                    vipLvl = 0,
                }
            },
            t = data.op_datetime,
            ["type"] = "debug",
        }  
        table.insert(proData,opReport)
    end 
end

--登录游戏加载数据
function ChatModel:checkUnloginData(data)
    -- local function debugCallback()  --手动获取debug反馈信息  
    --     self:getReortlist( function(data)
    --         if not data or type(data) ~= "table" then
    --             data = {}
    --         end
    --         self._debugData = data
    --         local debugUnread = 0
    --         for p, debug in ipairs(data) do
    --             debug.id = tostring(p) .. tostring(os.time())
    --         end
    --     end )
    -- end

    local function crossWarCallback()
        local isSysOpen, toBeOpen, level = SystemUtils["enableCrossGuild"]
        local isOpen = self._modelMgr:getModel("CrossGodWarModel"):matchIsOpen()
        if not isSysOpen or isOpen ~= 0 then  --0是 1不是
           data = {}
        end
    end

    local function fSerCallback()
        local isSysOpen, toBeOpen, level = SystemUtils["enableWeChat"]
        if not isSysOpen then
           data = {}
        end
    end

    
    self._loginNum = (self._loginNum or 0) + 1
    if self._loginNum == 2 then
        -- debugCallback()
    elseif self._loginNum == 4 then
        crossWarCallback()
    elseif self._loginNum == 5 then
        fSerCallback()
    elseif self._loginNum > 5 then
        return
    end

    --登录检查  
    --1.挪到updatDataByType方法里，红点和黑名单一起处理
    --2.因为debug返回有延迟，所以进私聊时会重新load数据
    local typeList = {
        ChatConst.CHAT_CHANNEL.PRIVATE,     --pri  
        ChatConst.CHAT_CHANNEL.GUILD,       --guild
        ChatConst.CHAT_CHANNEL.WORLD,       --all
        ChatConst.CHAT_CHANNEL.GODWAR,      --诸神
        ChatConst.CHAT_CHANNEL.FSERVER,     --全服
    }
    self:setLoadDataByChannel(typeList[self._loginNum])
    self:updatDataByType(typeList[self._loginNum], data or {})
end

--获取debug数据 并插入到私聊最顶端
function ChatModel:insertDebugData()
    local setType = ChatConst.CHAT_CHANNEL.PRIVATE
    local debugInfo = { chat = self._debugData or {}, 
                        user = {    rid = "bug_op",
                                    name = "会跳舞的小妖精",
                                    avatar = 2101,
                                    lvl = 0,
                                    type = "world",
                                    vipLvl = 0,
                                }
                    }
    if self._debugData and next(self._debugData) ~= nil then
        for k,msg in pairs(self._debugData) do
            self:handleEmoji(msg)
        end
        local sortFunc = function(a, b) return a.t > b.t end    --排序
        table.sort(self._debugData, sortFunc) 
    end

    table.insert(self._data[setType], #self._data[setType]+1, debugInfo)
end

function ChatModel:setLoginLoadNum()
    if not self._loginNum then
        self._loginNum = 1
    end
    self._loginNum = self._loginNum + 1
end

function ChatModel:getLoginLoadNum()
    return self._loginNum
end

--删除黑名单私聊数据
function ChatModel:removeBlackChatUser(inID, isReflush, isWorld, isGuild, isPri)
    --私聊
    if isPri == true then
        local priData = self._data[ChatConst.CHAT_CHANNEL.PRIVATE]
        for i=#priData ,1, -1 do
            if priData[i]["user"] then
                if (priData[i]["user"]["usid"] and priData[i]["user"]["usid"] == inID) or 
                    (priData[i]["user"]["rid"] and priData[i]["user"]["rid"] == inID) then
                    table.remove(priData, i)
                end
            end
        end
    end
    

    --世界
    if isWorld then
        local allData = self._data[ChatConst.CHAT_CHANNEL.WORLD]
        for i=#allData ,1, -1 do
            if allData[i]["message"] and allData[i]["message"]["udata"] then
                if (allData[i]["message"]["udata"]["usid"] and allData[i]["message"]["udata"]["usid"] == inID)  or 
                    (allData[i]["message"]["udata"]["rid"] and allData[i]["message"]["udata"]["rid"] == inID) then
                    table.remove(allData, i)
                end
            end
        end
    end
    

    --联盟
    if isGuild then
        local guildData = self._data[ChatConst.CHAT_CHANNEL.GUILD]
        for i=#guildData ,1, -1 do
            if guildData[i] and guildData[i]["message"] and guildData[i]["message"]["udata"] then
                if (guildData[i]["message"]["udata"]["usid"] and guildData[i]["message"]["udata"]["usid"] == inID)  or 
                    (guildData[i]["message"]["udata"]["rid"] and guildData[i]["message"]["udata"]["rid"] == inID) then
                    table.remove(guildData, i)
                end 
            end
        end
    end
    
    if isReflush == true then
        self:reflashData("BlackRemove")
    end
end

--退出联盟
function ChatModel:quitGuild()
    self._data[ChatConst.CHAT_CHANNEL.GUILD] = {}
    self:setUnread(0, ChatConst.CHAT_CHANNEL.GUILD)
end

-- send / push消息重组数据
-- return timeBanned, infoBanned, data
function ChatModel:paramHandle(inType, inData, isSend)
    local param = {}
    local userData = self._userModel:getData()
    local curVip = self._modelMgr:getModel("VipModel"):getLevel() or 0

    -- 客户端拼的udata
    local udataFake = {
        rid = userData._id, 
        usid = userData.usid, 
        lvl = userData.lvl,
        plvl = userData.plvl,
        vipLvl = curVip,
        guildName = userData.guildName or "",
        roleGuild = userData.roleGuild and userData.roleGuild.pos or 3,
        avatar = userData.avatar,
        name = userData.name,
        avatarFrame = userData.avatarFrame,
        sec = GameStatic.sec,
    }

    --获取被发送用户数据(字段名不同单独处理)
    local function getToUserData(inData)
        return {
            avatar = inData.avatar,
            avatarFrame = inData.avatarFrame or 1000,
            lvl = inData.lvl or 0,
            plvl = inData.plvl,
            name = inData.name or "",
            rid = inData.rid, 
            roleGuild = inData.roleGuild or 3,
            usid = inData.usid,
            vipLvl = inData.vipLvl or 0,
            sec = inData.sec,
        }  
    end

    --隐藏vip功能
    if self._userModel:isHideVip("chat") == true then
        udataFake["vipLvl"] = 0
    end

    -- send
    local _typeCell  --【提前设置类型，暂用于语音类型辨认】
    if isSend == nil or isSend == true then
        --禁言 by time
        local isTimeBanned = self:isChatTimeBanned(inType)  
        if isTimeBanned == true then
            return true
        end
        param.message = {}
        param.message.text = inData and inData.text or "空"
        if inData and inData.typeCell then
            param.message.typeCell = inData.typeCell   --暂用于语音类型和id设置
            param.message.textId = inData.textId or 0
            param.message.textTime = inData.textTime or 0
            _typeCell = inData.typeCell
        end
         
    -- push                
    else
        param = inData
    end

    --世界
    if inType == ChatConst.CELL_TYPE.WORLD1 then 
        param.message.typeCell      = _typeCell or ChatConst.CELL_TYPE.WORLD1  
        param.type                  = ChatConst.CHAT_CHANNEL.WORLD

        if param.message.text then
            param.message.text = self:replaceUserSendText(param.message.text)
        end  

    --世界【战斗回放】
    elseif inType == ChatConst.CELL_TYPE.WORLD2 then        
        param.message.typeCell      = ChatConst.CELL_TYPE.WORLD2
        param.type                  = ChatConst.CHAT_CHANNEL.WORLD
        param.message.reportInfo    = inData.reportInfo

    --世界【荣耀竞技战斗回放】
    elseif inType == ChatConst.CELL_TYPE.WORLD5 then        
        param.message.typeCell      = ChatConst.CELL_TYPE.WORLD5
        param.type                  = ChatConst.CHAT_CHANNEL.WORLD
        param.message.reportInfo    = inData.reportInfo

    --世界【招募(联盟)】
    elseif inType == ChatConst.CELL_TYPE.WORLD3 then 
        param.message.typeCell  = ChatConst.CELL_TYPE.WORLD3
        param.type              = ChatConst.CHAT_CHANNEL.WORLD
        param.message.zhaomu    = inData.zhaomu

    --世界【官方消息】push
    elseif inType == ChatConst.CELL_TYPE.WORLD4 then
        param.message.typeCell  = ChatConst.CELL_TYPE.WORLD4
        if param.message.udata == nil then
            param.message.udata = {rid = "guanfang", lvl = 0, vipLvl = 0,guildName = "",roleGuild = 3,avatar = 2302,name = ""}
        end
        
    --联盟
    elseif inType == ChatConst.CELL_TYPE.GUILD1 then
        param.message.typeCell      = _typeCell or ChatConst.CELL_TYPE.GUILD1  
        param.type                  = ChatConst.CHAT_CHANNEL.GUILD
        if param.message.text then
            param.message.text = self:replaceUserSendText(param.message.text)
        end  

    --联盟【日志/红包/地图战报】手动push
    elseif inType == ChatConst.CELL_TYPE.GUILD2 then
        param = self:paramHandleForGuildRed(inData, param)

    --联盟秘境邀请
    elseif inType == ChatConst.CELL_TYPE.GUILD3 then            --联盟秘境
        param.message.typeCell  = ChatConst.CELL_TYPE.GUILD3
        param.type              = ChatConst.CHAT_CHANNEL.GUILD
        param.message.famData   = inData.famData

    --跨服诸神
    elseif inType == ChatConst.CELL_TYPE.GODWAR1 then
        param.message.typeCell      = _typeCell or ChatConst.CELL_TYPE.GODWAR1  
        param.type                  = ChatConst.CHAT_CHANNEL.GODWAR
        if param.message.text then
            param.message.text = self:replaceUserSendText(param.message.text)
        end

    --全服
    elseif inType == ChatConst.CELL_TYPE.FSERVER1 then
        param = self:paramHandleForFServer(param, _typeCell)

    --全服喊话
    elseif inType == ChatConst.CELL_TYPE.FSERVER2 then
        param = self:paramHandleForFServer2(param, _typeCell)

    --全服@人
    elseif inType == ChatConst.CELL_TYPE.FSERVER3 then
        param = self:paramHandleForFServer3(param, _typeCell, inData)

    --私聊
    elseif inType == ChatConst.CELL_TYPE.PRI1 then
        local toUserData = self._cacheUserData
        param["message"]["toData"]  = getToUserData(toUserData)
        param.message.typeCell      = _typeCell
        param.type                  = ChatConst.CHAT_CHANNEL.PRIVATE
        param.to                    = inData and inData.toID or ""
        if param.message.text then
            param.message.text = self:replaceUserSendText(param.message.text)
        end  

    --私聊【bug反馈】手动加udata
    elseif inType == ChatConst.CELL_TYPE.PRI2 then 
        param.type      = ChatConst.CHAT_CHANNEL.DEBUG
        param.id        = 2300 .. tostring(os.time())
        param.t         = self._userModel:getCurServerTime()
        param.message.udata = udataFake
        param.message.typeCell      = _typeCell
        if param.message.text then
            param.message.text = self:replaceUserSendText(param.message.text)
        end 

    --私聊【排行榜NPC】手动加udata加push
    elseif inType == ChatConst.CELL_TYPE.PRI3 then          
        param.type      = ChatConst.CHAT_CHANNEL.ARENA_NPC
        param.id        = "arena"..os.time()
        param.t         = self._userModel:getCurServerTime()
        param.message.udata         = udataFake
        param.message.typeCell      = _typeCell
        param.isManual = true   --是否是手动
        if param.message.text then
            param.message.text = self:replaceUserSendText(param.message.text)
        end

    --私聊【好友切磋战报】手动加udata
    elseif inType == ChatConst.CELL_TYPE.PRI4 then
        local toUserData = inData.toData
        param["message"]["toData"]  = getToUserData(toUserData)
        param["message"]["toData"]["lvl"] = toUserData.lv or 0
        param.message.typeCell      = ChatConst.CELL_TYPE.PRI4
        param.type                  = ChatConst.CHAT_CHANNEL.PRIVATE
        param.message.reportInfo    = inData.reportInfo
        param.to                    = inData and inData.toID or ""

    --私聊【联盟招募】
    elseif inType == ChatConst.CELL_TYPE.PRI5 or inType == ChatConst.CELL_TYPE.PRI6 then
        local toUserData = self._cacheUserData
        param["message"]["toData"]  = getToUserData(toUserData)
        if inType == ChatConst.CELL_TYPE.PRI6 then
            param.message.udata = udataFake
            param.isManual  = true   --是否是手动
            param.id        = 2200 .. tostring(os.time())..(math.random() * 10)
            param.t         = self._userModel:getCurServerTime()
            param.message.typeCell  = ChatConst.CELL_TYPE.PRI6
        else
            param.message.typeCell  = ChatConst.CELL_TYPE.PRI5
        end
        
        param.type              = ChatConst.CHAT_CHANNEL.PRIVATE
        param.message.zhaomu    = inData.zhaomu
        param.to                = inData and inData.toID or ""
    end

    --禁言 by info[不走服务器，只显示在自己的聊天中] 手动push
    local isInfoBanned = self:isChatMsgBan(inData and inData.text or "", inType)
    if isInfoBanned == true then
        param.id                = 2200 .. tostring(os.time())..(math.random() * 10)
        param.t                 = self._userModel:getCurServerTime()
        if param.message.udata == nil then
            param.message.udata = udataFake
        end
        param.isManual = true   --是否是手动
        return false, isInfoBanned, param
    end

    return false, isInfoBanned, param    --timeBanned, infoBanned, data
end

function ChatModel:paramHandleForGuildRed(inData, param)
    param = {
        id = inData["infoType"] .. os.time() ..(math.random() * 10),
        message = {
            id = inData["infoType"],
            text = "",
            value = {}
        },
        t = os.time(), 
        type = ChatConst.CHAT_CHANNEL.GUILD,
        typeCell = ChatConst.CELL_TYPE.GUILD2,
        isManual = true   --是否是手动
    }

    if inData["infoType"] == "GUILD_RED_BOX" then           --红包
        param["message"]["text"] = "LIANMENG_1"
        param["message"]["value"] = {
            [1] = "$name::" .. inData["infoName"]
        }

    elseif inData["infoType"] == "GUILD_MAP_REPORT" then    --联盟地图战报
        local str = lang(tab:GuildMapReport(inData.infoData.type)["report"])
        for k,v in pairs(inData.infoData.params) do
            v = self:replaceSepcialSignal(v)
            str = string.gsub(str, "{$" .. k .. "}", v)
        end
        if string.find(str, "color=") == nil then
            str = "[color=3d1f00]"..str.."[-]"
        end  
        param["message"]["text"] = str

    else                                                    --联盟战报
        param["message"]["text"] = inData["info"]
    end

    return param 
end

function ChatModel:paramHandleForFServer(param, _typeCell)
    param.message.typeCell      = _typeCell or ChatConst.CELL_TYPE.FSERVER1  
    param.type                  = ChatConst.CHAT_CHANNEL.FSERVER

    if param.message.text then
        param.message.text = self:replaceUserSendText(param.message.text)
    end  

    return param
end

function ChatModel:paramHandleForFServer2(param, _typeCell)
    param.message.typeCell      = _typeCell or ChatConst.CELL_TYPE.FSERVER2  
    param.type                  = ChatConst.CHAT_CHANNEL.FSERVER1

    if param.message.text then
        param.message.text = self:replaceUserSendText(param.message.text)
    end  

    return param
end

function ChatModel:paramHandleForFServer3(param, _typeCell, inData)
    param.message.typeCell      = _typeCell or ChatConst.CELL_TYPE.FSERVER3  
    param.type                  = ChatConst.CHAT_CHANNEL.FSERVER
    param.message.callId   = inData.callId

    if param.message.text then
        param.message.text = self:replaceUserSendText(param.message.text)
    end  

    return param
end

-- 联盟申请状态记录(防止需审批加入联盟时，多次请求服务器)
-- 参数为空时，清空记录【关闭聊天界面或联盟申请批准时】
--【关闭聊天界面清空是为了处理联盟拒绝，而本地还是不能请求】
function ChatModel:setApplyRecord(guildId)
    if self._guildApply == nil or guildId == nil then
        self._guildApply = {}
        return
    end

    self._guildApply[guildId] = 1
end

function ChatModel:isHasAppliedGuild(guildId)
    if self._guildApply and self._guildApply[guildId] == 1 then
        return true
    end
    return false
end

function ChatModel:setPriApplyRecord(guildId)
    if self._priGuildApply == nil or guildId == nil then
        self._priGuildApply = {}
        return
    end

    self._priGuildApply[guildId] = 1
end

function ChatModel:isPriHasAppliedGuild(guildId)
    if self._priGuildApply and self._priGuildApply[guildId] == 1 then
        return true
    end
    return false
end

--禁言 by info
function ChatModel:isChatMsgBanned()
    local userModelData = self._userModel:getData()
    local timeC = userModelData.banChat and userModelData.banChat > os.time()
    local typeC = userModelData.banChatT and userModelData.banChatT == ChatConst.BANNED_TYPE.SYS
    if timeC and typeC then
        return true
    end

    return false
end

function ChatModel:isChatMsgBan(inDes, inType)
    if inType ~= ChatConst.CHAT_CHANNEL.WORLD then   --非世界
        return false
    end

    if self:isChatMsgBanned() == true then
        return true
    end

    local userModelData = self._userModel:getData()
    --世界聊天
    local sameTimes = 0
    -- dump(self._bannedList, "_bannedList", 10)
    for i=1,#self._bannedList do
        if self._bannedList[i].message and self._bannedList[i].message.text and self:isStringSame(inDes, self._bannedList[i].message.text) == true then
            sameTimes = sameTimes + 1
            local openTime = userModelData.sec_open_time
            local curTime = self._userModel:getCurServerTime()
            local checkLv = math.min(24 + math.floor((curTime-openTime)/86400), tab.setting["G_MAX_TEAMLEVEL"].value - 20)
            -- local checkLv = 100
            if sameTimes >= 5 and userModelData.lvl < checkLv then
                return true
            end
        end
    end

    return false
end

function ChatModel:isStringSame(inDes1, indes2)
    -- 获取字符串的字列表
    local function calculateStrWithTable(convertStr)
        if convertStr == nil or type(convertStr) ~= "string" then
            return {}
        end

        local len  = #convertStr
        local left = 0
        local arr  = {0, 0xc0, 0xe0, 0xf0, 0xf8, 0xfc}
        local strTb = {}
        local start = 1
        local wordLen = 0
        while len ~= left do
            local tmp = string.byte(convertStr, start)
            local i   = #arr
            while arr[i] do
                if tmp >= arr[i] then
                    break
                end
                i = i - 1
            end
            wordLen = i + wordLen
            local tmpString = string.sub(convertStr, start, wordLen)
            start = start + i
            left = left + i
            strTb[#strTb + 1] = tmpString
        end 

        return strTb
    end

    local strList1 = calculateStrWithTable(inDes1)
    local strList2 = calculateStrWithTable(indes2)
    if #strList1 >= 10 and #strList2 >= 10 then
        local long = #strList2 >= #strList1 and strList2 or strList1
        local short = #strList2 < #strList1 and strList2 or strList1

        for i,v in ipairs(short) do
            local sameNum = 0
            for p,q in ipairs(long) do
                if short[i + sameNum] and short[i + sameNum] == q then
                    sameNum = sameNum + 1
                    if sameNum >= 10 then
                        return true
                    end
                else
                    sameNum = 0   --有不连续
                end
            end
        end
    end

    return false
end

-- 存储最新十条消息
-- isInvert:是否是倒序，是只需要连续存10条就不用存了
function ChatModel:insertBannedList(inData, isInvert) 
    if self:isChatMsgBanned() == true then
        self._bannedList = {}
        return
    end

    if not inData["message"] or not inData["message"]["typeCell"] or 
        inData["message"]["typeCell"] ~= "all" or not inData["message"]["udata"] then
        return
    end

    local inRid = inData["message"]["udata"]["rid"]
    if #self._bannedList == 0 or (inRid and self._userModelData["_id"] == inRid) then
        if isInvert and isInvert == true then
            if #self._bannedList < 10 then
                table.insert(self._bannedList, 1, inData)
            end
        else
            table.insert(self._bannedList, 1, inData)
        end
    end

    if #self._bannedList > 10 then
        for i=#self._bannedList, 11, -1 do
            table.remove(self._bannedList, i)
        end
    end
end

--禁言 by time
function ChatModel:isChatTimeBanned(inType)
    local isBanned = false
    if inType == ChatConst.CHAT_CHANNEL.WORLD then  --10s
        if os.time() - (self._worldTime or 0) <= 10 then
            isBanned = true
        else
            self._worldTime = os.time()
        end
        
    elseif inType == ChatConst.CHAT_CHANNEL.GUILD then   --3s
        if os.time() - (self._guildTime or 0) <= 3 then
            isBanned = true
        else
            self._guildTime = os.time()
        end
        
    end

    return isBanned
end

function ChatModel:setLastTimeByType(inType)
    if inType == ChatConst.CHAT_CHANNEL.WORLD then
        self._worldTime = os.time()

    elseif inType == ChatConst.CHAT_CHANNEL.GUILD then
        self._guildTime = os.time()
    end
end

function ChatModel:checkTimeBannedByType(inType)
    local isBanned = false
    if inType == ChatConst.CHAT_CHANNEL.WORLD then  --10s
        if os.time() - (self._worldTime or 0) <= 10 then
            isBanned = true
        end
        
    elseif inType == ChatConst.CHAT_CHANNEL.GUILD then   --3s
        if os.time() - (self._guildTime or 0) <= 3 then
            isBanned = true
        end
    end

    return isBanned
end

--idid 世界禁言
function ChatModel:isChatIdipBanned()
    local isBanned = false
    local userModelData = self._userModel:getData()
    local timeC = userModelData.banChat and userModelData.banChat > self._userModel:getCurServerTime()
    local typeC = userModelData.banChatT and userModelData.banChatT == ChatConst.BANNED_TYPE.IDIP
    local banStr = userModelData.banChatR or ""
    if timeC and typeC then
        isBanned = true
    end

    return isBanned, banStr
end

--私聊是否开启 用于外部打开聊天
function ChatModel:isPirChatOpen()
    local chatOpen = tab.systemOpen["PrivateChat"]
    local userModelData = self._userModel:getData()
    if userModelData.lvl >= chatOpen[1] then
        return true
    end

    return false, lang(chatOpen[3])
end

function ChatModel:setVoiceReadState(inId, inState)
    if inId == nil or inState == nil then
        return 
    end

    if self._voiceRead == nil then
        self._voiceRead = {}
    end

    --等于true为未读，nil也表示已读
    self._voiceRead[inId] = inState
end

function ChatModel:getVoiceReadState()
    return self._voiceRead or {}
end

function ChatModel:replaceSepcialSignal(inStr)
    if inStr == nil then
        return
    end
    
    if string.find(inStr, "%[") then
        inStr = string.gsub(inStr, "%[", "【")
    end

    if string.find(inStr, "%]") then
        inStr = string.gsub(inStr, "%]", "】")
    end

    return inStr
end

function ChatModel:getGiftId(inData)
    local gift = json.decode(inData)
    local itemId
    if gift[1] == "tool" then
        itemId = gift[2]
    elseif gift[1] == "hero" then
        itemId = gift[2]
    elseif gift[1] == "team" then
        itemId = gift[2]
    else
        itemId = IconUtils.iconIdMap[gift[1]]
    end

    return itemId,gift[1],gift[3]
end

function ChatModel:checkIsShowTime(inData)
    local disT = inData["disT"] or 60*60*24+1
    if disT > 60 then
       return true
    end

    return false
end

return ChatModel