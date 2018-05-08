--
-- Author: huangguofang
-- Date: 2016-05-03 17:50:46
--
local ArenaDialogCD = class("ArenaDialogCD",BasePopView)
function ArenaDialogCD:ctor()
    self.super.ctor(self)

end

-- 第一次被加到父节点时候调用
function ArenaDialogCD:onAdd()

end
-- 初始化UI后会调用, 有需要请覆盖
function ArenaDialogCD:onInit()
	self:registerClickEventByName("bg.cancelBtn", function( )
		-- self:close()
        if self._cancelCallback then
            self._cancelCallback()
        end
        UIUtils:reloadLuaFile("arena.ArenaDialogCD")
	end)
	self._sureCallback = nil
	self._descLabel = self:getUI("bg.descLabel")
	self._CDValue = self:getUI("bg.CDValue")
    self._CDtxt = self:getUI("bg.CDtxt")
    self._CDtxt:setString("冷却剩余时间:")
    self._CDtxt:setPositionX(self._CDtxt:getPositionX()-20)
    self._CDValue:setString("")
    self._CDValue:setPositionX(self._CDValue:getPositionX()-20)
    -- self:CDupdate()

    local title = self:getUI("bg.title")
    UIUtils:setTitleFormat(title, 6)
    title:setString("消除冷却")
    local confirmBtn = self:getUI("bg.confirmBtn")
    confirmBtn:setTitleFontSize(28)
    self:registerClickEventByName("bg.confirmBtn", function( )        
        -- self:close()
        if self._sureCallback ~= nil then
            self._sureCallback()
            self._sureCallback = nil
        end
        if self._cancelCallback then
            self._cancelCallback()
        end
    end)
end

-- 第一次进入调用, 有需要请覆盖
function ArenaDialogCD:onShow()
    -- if not self._CDSchedule then
        -- self._CDSchedule = ScheduleMgr:regSchedule(1000,self,function( )
        --     self:CDupdate()
        -- end)
    -- end
end
function ArenaDialogCD:CDupdate(cdTime)
    -- local privilgeCD = self._modelMgr:getModel("PrivilegesModel"):getAbilityEffect(PrivilegeUtils.privileg_ID.PRIVILEGENAME_11) or 0
    -- local lastChallengeTime = self._modelMgr:getModel("ArenaModel"):getArena().cdTime - privilgeCD
    -- if lastChallengeTime and lastChallengeTime > 0 then
        -- local curTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
        -- if lastChallengeTime+10 > curTime then
            -- local cdTime = lastChallengeTime-curTime+10 
            -- self._CDValue:setString(string.format("%02d:%02d",math.floor(cdTime/60),math.floor(cdTime%60)))
        -- else
            -- self._CDValue:setString("00:00")
            -- if self._CDSchedule then
                -- ScheduleMgr:unregSchedule(self._CDSchedule)
                -- self._CDSchedule = nil
                -- self:close()
            -- end
        -- end
    -- end 

    if cdTime and tonumber(cdTime) > 0 then
        self._CDValue:setString(string.format("%02d:%02d",math.floor(cdTime/60),math.floor(cdTime%60)))
    else
        self._CDValue:setString("00:00")
        
        if self._cancelCallback then
            self._cancelCallback()
        end
    end
end
-- 成为topView会调用, 有需要请覆盖
function ArenaDialogCD:onTop()

end

-- 被其他View盖住会调用, 有需要请覆盖
function ArenaDialogCD:onHide()

end

-- 接收自定义消息
function ArenaDialogCD:reflashUI(data)
	--{desc = desc, button1 = btn1name, callback1 = callback1,  button2 = btn2name, callback2 = callback2}
	if string.find(data.desc,"[-]") then
        self._descLabel:setString("")
        local rtx = DialogUtils.createRtxLabel(data.desc,{width = 400} )
        rtx:formatText()
        rtx:setPosition(self._descLabel:getPositionX()+5,self._descLabel:getPositionY())
        self._descLabel:getParent():addChild(rtx,10)
        -- UIUtils:alignRichText(rtx,{hAlign = "center"})
    else
        self._descLabel:setString(data.desc)
    end

    if data.callBack1 then
        self._sureCallback = data.callBack1
    end

    if data.callBack2 then
        self._cancelCallback = data.callBack2
    end
end

function ArenaDialogCD:setCDString(str)
    self._CDValue:setString(str)
end
return ArenaDialogCD