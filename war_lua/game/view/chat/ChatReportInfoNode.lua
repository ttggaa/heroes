--[[
    Filename:    ChatReportInfoNode.lua
    Author:      <wangyan@playcrab.com>
    Datetime:    2018-08-29 11:26
    Description: 战报回放详情界面
--]]

local ChatReportInfoNode = class("ChatReportInfoNode", BaseMvcs, ccui.Widget)

function ChatReportInfoNode:ctor(param)
	self.super.ctor(self)
end

function ChatReportInfoNode:reflashUI(inData)
    self._data = inData
    local wid, hei = 125, 153
    self:setContentSize(wid, hei)

    --bg
    if not self._bgImg then
        self._bgImg = cc.Scale9Sprite:createWithSpriteFrameName("globalPanelUI5_tipBg.png")
        self._bgImg:setCapInsets(cc.rect(35,35,1,1))
        self._bgImg:setContentSize(wid, hei)
        self:addChild(self._bgImg)
    end

    --btn
    local res = {"globalImage_winlose_1.png", "globalImage_winlose_2.png", "globalImage_winlose_3.png"}
    local bgWid, bgHei = self._bgImg:getContentSize().width, self._bgImg:getContentSize().height
    for i=1, 3 do
        local resData = {{}, {}}
        if self._data.message.reportInfo then
            resData = self._data.message.reportInfo.reportKey or {{}, {}}
        end
        if not self["winBtn" .. i] then
            local btnRes = "globalImage_winloseBg_1.png"
            local btn = ccui.Button:create(btnRes, btnRes, btnRes, 1)
            btn:setPosition(bgWid * 0.5, bgHei - i * btn:getContentSize().height + btn:getContentSize().height * 0.5 - 9)
            self["winBtn" .. i] = btn
            self._bgImg:addChild(btn)
        end

        if not self["winState" .. i] then
            local state = ccui.ImageView:create()
            state:setPosition(88, 25)
            self["winState" .. i] = state
            self["winBtn" .. i]:addChild(state)
        end

        if not self["text" .. i] then
            local txt = ccui.Text:create()
            txt:setColor(cc.c4b(60,42,30,255))
            txt:setFontSize(24)
			txt:setFontName(UIUtils.ttfName)
			txt:setString("第" .. i .. "场")
            txt:setPosition(35, 20)
            self["text" .. i] = txt
            self["winBtn" .. i]:addChild(txt)
        else
            self["text" .. i]:setString("第" .. i .. "场")
        end

        self["winState" .. i]:loadTexture(res[resData[2][i] or 2], 1)

        registerClickEvent(self["winBtn" .. i], function()
            self:setVisible(false)
            self:reviewTheBattle(i)
            end) 
    end
end

function ChatReportInfoNode:reviewTheBattle(inType)    
    local reportData = self._data.message.reportInfo
    if reportData ~= nil then
        local sendP = reportData.reportKey or {{}, {}}
        local isMeAtk = reportData._isMeAtk
        local _sec = ModelManager:getInstance():getModel("UserModel"):getServerId()
        ServerManager:getInstance():sendMsg("CrossArenaServer","getBattleReport",{reportKey = sendP[1][inType] or "", sec = _sec, type = 1},true,{},function( result )
                if result and type(result) == "table" and next(result) == nil then
                    self._viewMgr:showTip("战报不存在")
                    return
                end
                local left 
                local right 
                
                -- local userId = self._modelMgr:getModel("UserModel"):getUID()
                -- dump(result.def)
                -- local isMeAtk = userId == _data.atkId
                left  = BattleUtils.jsonData2lua_battleData(result.atk)
                right = BattleUtils.jsonData2lua_battleData(result.def)
                BattleUtils.disableSRData()
    
                BattleUtils.enterBattleView_GloryArena(left, right, result.r1, result.r2, true,
                    function(info, callback)
                        -- 战斗结束
                        callback(info)
                    end,
                    function (info)
                        -- 退出战斗
                    end, false, not isMeAtk, true
                )
        end)
    end
end

return ChatReportInfoNode