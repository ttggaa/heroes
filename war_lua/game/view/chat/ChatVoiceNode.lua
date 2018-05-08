--[[
    Filename:    ChatVoiceNode.lua
    Author:      <wangyan@playcrab.com>
    Datetime:    2017-3-31 10:30:21
    Description: 聊天语音按钮
--]]

local ChatVoiceNode = class("ChatVoiceNode", BaseMvcs, ccui.Widget)

function ChatVoiceNode:ctor()
	ChatVoiceNode.super.ctor(self)

	self._userModel = self._modelMgr:getModel("UserModel")
	self._chatModel = self._modelMgr:getModel("ChatModel")
	self._voiceId = 0
	-- self:onInit()
end

function ChatVoiceNode:onInit(inData)
	self._data = inData
	-- voiceBtn
	self._voiceBtn = ccui.Button:create()
	self._voiceBtn:loadTextures("chatPri_voice1.png", "chatPri_voice1.png", "chatPri_voice1.png", 1)
	self._voiceBtn:setScaleAnim(false)
	self:addChild(self._voiceBtn) 

    local beginPos = {x = inData.pos.x, y = inData.pos.y}
    local curPos = {x = 0, y = 0}
    local moveDis, disX, disY = 0, 0, 0

    registerTouchEvent(self._voiceBtn,
        function (_, _x, _y)
            local isCanSend, tipStr = self:checkIsCanSend()
            if isCanSend == true then
                local inType = 1
                if self._curType == ChatConst.CHAT_CHANNEL.PRIVATE then
                    inType = 2
                end
                VoiceUtils.startRecording(inType ,function (vType, vId, vTime)
                    print("语音聊天：", vType, vId, vTime)
                    if vType == 0 then  --录音成功
                        self._voiceId = vId
                        self._voiceTime = vTime or 0
                        self:sendVoice()
                    end
                end)
            else
                self._viewMgr:showTip(tipStr or "当前不能发送聊天")
            end
        end,

        function (_, _x, _y)
        	curPos.x, curPos.y = _x, _y
        	moveDis = MathUtils.pointDistance(beginPos, curPos)
        	disX, disY = _x - beginPos.x, _y - beginPos.y

        	if disX >= -50 and disX <= 50 and disY >= -50 and disY <= 50 then
        		VoiceUtils.changeRecordUI(1) 
        	else
        		VoiceUtils.changeRecordUI(2)  --取消录音
        	end
        end,

        function ()
            VoiceUtils.stopRecording()
        end,

        function(_, _x, _y)
        	if disX >= -50 and disX <= 50 and disY >= -50 and disY <= 50 then
        		VoiceUtils.stopRecording()
        	else
        		VoiceUtils.cancelRecording()
        	end
        end
        )
    self._voiceBtn:setSwallowTouches(false)
end

function ChatVoiceNode:checkIsCanSend()
    local limitLevel = tonumber(tab.systemOpen["Chat"][1])
    if self._userModel:getData().lvl < limitLevel then 
        return false, lang("CHAT_SYSTEM_OPEN")
    end

    --禁言 by idip
    local isIdipBanned, banStr = self._chatModel:isChatIdipBanned()
    if isIdipBanned == true and self._curType == "all" then  
        return false, banStr
    end

    -- 禁言 by time
    local isTimeBanned = self._chatModel:checkTimeBannedByType(self._curType)  
    if isTimeBanned == true then        
        return false, lang("CHAT_SYSTEM_LAG")
    end

    return true
end

function ChatVoiceNode:sendVoice()
	local limitLevel = tonumber(tab.systemOpen["Chat"][1])
    if self._userModel:getData().lvl < limitLevel then 
        self._viewMgr:showTip(lang("CHAT_SYSTEM_OPEN"))
        return
    end

    if self._curType == ChatConst.CHAT_CHANNEL.PRIVATE then   --私聊
    	local curPriId = self._chatModel:getCacheUserData().rid
    	local userData = self._userModel:getData()
	    local VipData = self._modelMgr:getModel("VipModel"):getData()
	    local idPrefix = string.split(curPriId, "_")

	    if curPriId == "bug_op" then   --bug反馈
            --语音按钮已隐藏
            
	    elseif idPrefix[1] == "arena" then     --排行榜NPC
            local param1 = {
                typeCell = "voice", 
                textId = self._voiceId,
                textTime = self._voiceTime,
            }
	        local _, _, param = self._chatModel:paramHandle(ChatConst.CELL_TYPE.PRI3, param1)
	        self._chatModel:pushData(param)

	    else                                   
	        local param1 = {
	            toID = curPriId,
	            typeCell = "voice", 
	            textId = self._voiceId,
                textTime = self._voiceTime,
	        }
	        local _, _, param = self._chatModel:paramHandle(ChatConst.CHAT_CHANNEL.PRIVATE, param1)
	        self._serverMgr:sendMsg("ChatServer", "sendPriMessage", param, true, {}, function (result)  end)
	    end
    else
        local param1 = {
            typeCell = "voice", 
            textId = self._voiceId,
            textTime = self._voiceTime,
        }
    	local isTimeBanned, isInfoBanned, sendData = self._chatModel:paramHandle(self._curType, param1)
	    local isMsgBanned = self._chatModel:isChatMsgBanned()
	    local isIdipBanned, banStr = self._chatModel:isChatIdipBanned()
        -- dump(sendData, "123", 10)
	    
	    self._serverMgr:sendMsg("ChatServer", "sendMessage", sendData, true, {}, 
	    	function (result) 

            end,
	        function(errorId, errorMsg)
	            if errorId == 140 then   --人工禁言
	                self._viewMgr:showTip(errorMsg)
	            end
	        end)

        --设置上次发言时间
        self._chatModel:setLastTimeByType(self._curType) 
    end
end

return ChatVoiceNode


--[[
	local pt = self._emojiBtn:convertToWorldSpace(cc.p(0, 0))
    local x, y = pt.x - 20, pt.y - 20

	local pt = self._emojiBtn:convertToWorldSpace(cc.p(0, 0))
    local x, y = pt.x, pt.y
    self:registerTouchEvent(self._emojiBtn, 
    function ()
        -- down
        -- print("***************************************", pt.x, pt.y)
        VoiceUtils.startRecording(function (a, b)
            print(a, b)
        end)
    end, 
    function (_, _x, _y)
        if _x >= x and _y >= y and _x <= x + 48 and _y <= y + 51 then
            VoiceUtils.changeRecordUI(1)
        else
            VoiceUtils.changeRecordUI(2)
        end
    end,
    function ()
        VoiceUtils.stopRecording()
    end,
    function ()
        VoiceUtils.cancelRecording()
    end)
]]