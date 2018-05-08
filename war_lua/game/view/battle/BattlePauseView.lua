--[[
    Filename:    BattlePauseView.lua
    Author:      huachangmiao@playcrab.com
    Datetime:    2015-08-26 20:26:13
    Description: File description
--]]

local BattlePauseView = class("BattlePauseView", BasePopView)

function BattlePauseView:ctor()
    BattlePauseView.super.ctor(self)

end

function BattlePauseView:close(noAnim, callback)
    SystemUtils.saveGlobalLocalData("musicVolume", self._nowMusicVolume)
    SystemUtils.saveGlobalLocalData("soundVolume", self._nowSoundVolume)
    SystemUtils.saveAccountLocalData("HUD_TYPE", self._hudType)

    BattlePauseView.super.close(self, noAnim, callback)
end

function BattlePauseView:onInit()
    self._btn1 = self:getUI("bg.btn1")
    self._btn2 = self:getUI("bg.btn2")
    self._musicBtn = self:getUI("bg.musicBtn")
    self._soundBtn = self:getUI("bg.effectBtn")
    self._btn11 = self:getUI("bg1.btn1")
    self._btn12 = self:getUI("bg1.btn2")
    self._musicBtn1 = self:getUI("bg1.musicBtn")
    self._soundBtn1 = self:getUI("bg1.effectBtn")
    self._allHpBtn = self:getUI("bg.allHpBtn")
    self._sigleHpBtn = self:getUI("bg.singleHpBtn")
    self._allHpBtn1 = self:getUI("bg1.allHpBtn")
    self._sigleHpBtn1 = self:getUI("bg1.singleHpBtn")

    self:registerClickEvent(self._btn1, specialize(self.onGoOn, self))
    self:registerClickEvent(self._btn2, specialize(self.onQuit, self))
    self:registerClickEvent(self._musicBtn, specialize(self.onMusic, self))
    self:registerClickEvent(self._soundBtn, specialize(self.onSound, self))
    self:registerClickEvent(self._allHpBtn, specialize(self.onHpAll, self))
    self:registerClickEvent(self._sigleHpBtn,  specialize(self.onHpSingle, self))
    self:registerClickEvent(self._allHpBtn1,   specialize(self.onHpAll, self))
    self:registerClickEvent(self._sigleHpBtn1, specialize(self.onHpSingle, self))


    self._musicVolume = SystemUtils.loadGlobalLocalData("musicVolume") or 0
    self._soundVolume = SystemUtils.loadGlobalLocalData("soundVolume") or 0
    self._hudType   = SystemUtils.loadAccountLocalData("HUD_TYPE") or 1
    self._musicOpen = self._musicVolume > 0
    self._soundOpen = self._soundVolume > 0

    self._nowMusicVolume = self._musicVolume
    self._nowSoundVolume = self._soundVolume

    self._musicBtn:setSelected(self._musicOpen)
    self._soundBtn:setSelected(self._soundOpen)

    self._musicBtn:setScaleAnim(false)
    self._soundBtn:setScaleAnim(false)
    self._musicBtn1:setScaleAnim(false)
    self._soundBtn1:setScaleAnim(false)

    self:registerClickEvent(self._btn11, specialize(self.onGoOn, self))
    self:registerClickEvent(self._btn12, specialize(self.onQuit, self))
    self:registerClickEvent(self._musicBtn1, specialize(self.onMusic, self))
    self:registerClickEvent(self._soundBtn1, specialize(self.onSound, self))
    
    self._musicBtn1:setSelected(self._musicVolume > 0)
    self._soundBtn1:setSelected(self._soundVolume > 0)

    self:resetCheckBoxStatus(self._musicBtn,self._musicOpen)
    self:resetCheckBoxStatus(self._musicBtn1,self._musicOpen)
    self:resetCheckBoxStatus(self._soundBtn,self._soundOpen)
    self:resetCheckBoxStatus(self._soundBtn1,self._soundOpen)

    self._allHpBtn:setSelected(self._hudType == 1)
    self._sigleHpBtn:setSelected(self._hudType ~= 1)
    self._allHpBtn1:setSelected(self._hudType == 1)
    self._sigleHpBtn1:setSelected(self._hudType ~= 1)
    self._allHpBtn:setEnabled(self._hudType ~= 1)
    self._allHpBtn1:setEnabled(self._hudType ~= 1)
    self._sigleHpBtn:setEnabled(self._hudType == 1)
    self._sigleHpBtn1:setEnabled(self._hudType == 1)

    if not BC.BATTLE_QUIT then
        self._btn2:setSaturation(-100)
    end
end

function BattlePauseView:reflashUI(data)
	self._callback = data.callback
    self._quitTip = data.quitTip
    self._showStarDes = data.showStarDes
    self._isReplay = data.isReport
    local title1 = self:getUI("bg.titleBg.title")
    UIUtils:setTitleFormat(title1, 1)
   
    local title2 = self:getUI("bg1.titleBg.title")
    UIUtils:setTitleFormat(title2, 1)
    self._bg = self:getUI("bg")
    self._bg1 = self:getUI("bg1")  

    if not self._showStarDes then
        -- self._bg = self:getUI("bg")
        -- self._bg:setContentSize(self._bg:getContentSize().width, 222)
        -- self._titleBg = self:getUI("bg.titleBg")
        -- self._titleBg:setPositionY(182)
        -- self._desBg = self:getUI("bg.desBg")
        -- self._desBg:setVisible(false)
        self._bg1:setVisible(true)
        self._bg:setVisible(false)
    else
        self._bg1:setVisible(false)
        self._bg:setVisible(true)
        self:getUI("bg.desBg.label1"):setString("战斗胜利")
        self:getUI("bg.desBg.label2"):setString("战斗时间小于1分钟")
        self:getUI("bg.desBg.label3"):setString("死亡方阵小于3个")
    end
end

function BattlePauseView:onGoOn()
	if self._callback then
		self._callback(1)
	end
    self:close(true)
    UIUtils:reloadLuaFile("battle.BattlePauseView")
end

function BattlePauseView:onQuit()
    if not BC.BATTLE_QUIT then
        self._viewMgr:showTip(lang("TIP_BATTLE_QUIT"))
        return
    end
    if self._isReplay then
        if self._callback then
            self._callback(2)
        end
        self:close(true)
        return
    end
    if self._quitTip == nil or self._quitTip == "" then
    	if self._callback then
    		self._callback(2)
    	end
        self:close(true)
    elseif self._quitTip == 1 then
        self._viewMgr:showDialog("global.GlobalSelectDialog", {desc = lang("TIPS_QUIT"), callback1 = function ()
            if self._callback then
                self._callback(2)
            end
            self:close(true) 
        end}, true)
    else
        -- local substr = ""
        local count = math.ceil((string.len(self._quitTip) - string.len(lang("TIPS_QUIT"))) / 6)
        -- for i = 1, count do
            -- substr = substr..","
        -- end
        local str = "[color=3D1F00,fontsize=24]"..self._quitTip.."，[color=3D1F00,fontsize=24]"..lang("TIPS_QUIT").."[-]"
        self._viewMgr:showDialog("global.GlobalSelectDialog", {desc = str, callback1 = function ()
            if self._callback then
                self._callback(2)
            end
            self:close(true) 
        end}, true)
    end
end

function BattlePauseView:onMusic()
    self._musicOpen = not self._musicOpen
    if self._musicOpen then
        if self._musicVolume > 0 then
            self._nowMusicVolume = self._musicVolume
        else
            self._nowMusicVolume = 5
        end
    else
        self._nowMusicVolume = 0
    end
    audioMgr:adjustMusicVolume(self._nowMusicVolume)
    self:resetCheckBoxStatus(self._musicBtn,self._musicOpen)
    self:resetCheckBoxStatus(self._musicBtn1,self._musicOpen)
end

function BattlePauseView:onSound()
    self._soundOpen = not self._soundOpen
    if self._soundOpen then
        if self._soundVolume > 0 then
            self._nowSoundVolume = self._soundVolume
        else
            self._nowSoundVolume = 5
        end
    else
        self._nowSoundVolume = 0
    end
    audioMgr:adjustSoundVolume(self._nowSoundVolume)
    self:resetCheckBoxStatus(self._soundBtn,self._soundOpen)
    self:resetCheckBoxStatus(self._soundBtn1,self._soundOpen)
end

function BattlePauseView:onHpAll()
    self._hudType = 1
    BattleUtils.HUD_TYPE = 1
    self._sigleHpBtn:setSelected(self._hudType ~= 1)
    self._sigleHpBtn1:setSelected(self._hudType ~= 1)
    self._allHpBtn:setEnabled(false)
    self._allHpBtn1:setEnabled(false)
    self._sigleHpBtn:setEnabled(true)
    self._sigleHpBtn1:setEnabled(true)
end

function BattlePauseView:onHpSingle()
    self._hudType = 2
    BattleUtils.HUD_TYPE = 2
    self._allHpBtn:setEnabled(true)
    self._allHpBtn1:setEnabled(true)
    self._sigleHpBtn:setEnabled(false)
    self._sigleHpBtn1:setEnabled(false)
    -- self._sigleHpBtn:setSelected(self._hudType ~= 1)
    -- self._sigleHpBtn1:setSelected(self._hudType ~= 1)
    self._allHpBtn:setSelected(self._hudType == 1)
    self._allHpBtn1:setSelected(self._hudType == 1)
end

-- checkbox bug normal状态不隐藏pressed对应图片 不改c++情况下处理
function BattlePauseView:resetCheckBoxStatus( checkbox, isSelected )
    if isSelected then
        checkbox:getVirtualRenderer():setVisible(false)
    else
        checkbox:getVirtualRenderer():setVisible(true)
    end
end


function BattlePauseView.dtor()
    BattlePauseView = nil
end

return BattlePauseView