--[[
    Filename:    GlobalPromptDialog.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2017-01-22 19:59:58
    Description: File description
--]]

-- 弹出提示框
-- 如有需要自己在后面加方法
-- 传入Id问策划
local GlobalPromptDialog = class("GlobalPromptDialog", BasePopView)

function GlobalPromptDialog:ctor(param)
    GlobalPromptDialog.super.ctor(self)
    if not param then
        param = {}
    end
    self._indexId = param.indexId or 1
    self._tihuan = param.tihuan or 1
end

function GlobalPromptDialog:onInit()
    self._title = self:getUI("bg.titleBg.title")
    UIUtils:setTitleFormat(self._title, 6)

    self:registerClickEventByName("bg.closeBtn", function ()
        if OS_IS_WINDOWS then
            UIUtils:reloadLuaFile("global.GlobalPromptDialog")
        end
        self:close()
    end)

    self._label1 = self:getUI("bg.label1")
    self._label2 = self:getUI("bg.label2")

    self._gotoBtn = self:getUI("bg.gotoBtn")
    self._gotoBtn:setAnchorPoint(0.5,0.5)
    self._gotoBtn:setScaleAnim(true)

    self._gName = self:getUI("bg.gotoBtn.gName")
    self._gName:setColor(UIUtils.colorTable.ccUIMenuBtnColor1)
    self._gName:enable2Color(1, UIUtils.colorTable.ccUIMenuBtnColor2)
    self._gName:enableOutline(cc.c4b(60, 30, 10, 255), 1)
end

function GlobalPromptDialog:reflashUI(data)
    print("===========", self._indexId)
    local promptTab = tab:Prompt(self._indexId)
    dump(promptTab, "promptTab====", 3)
    self._title:setString(lang(promptTab["label"]))
    local str = self:slipt(lang(promptTab["lang1"]))
    self._label1:setString(str)
    self._label2:setString(lang(promptTab["lang2"]))
    self._gName:setString(lang(promptTab["lang3"]))
    self._gotoBtn:loadTexture(promptTab["pic"] .. ".png", 1)

    self:registerClickEvent(self._gotoBtn, function()
        local prompt = promptTab["link"]
        self["gotoView" .. prompt](self)
        self:close()
    end) 
    self._gName:setPositionX(self._gotoBtn:getContentSize().width*0.5)
end

function GlobalPromptDialog:slipt(str)
    local gStr = str 
    if self._tihuan then
        gStr = string.gsub(str, "$name", self._tihuan)
    end
    return gStr
end

function GlobalPromptDialog:gotoView1()
    self._viewMgr:showView("intance.IntanceView")
end

function GlobalPromptDialog:gotoView2()
    self._viewMgr:showView("MF.MFView")
end

function GlobalPromptDialog:gotoView3()
    self._viewMgr:showView("intance.IntanceView")
end

function GlobalPromptDialog:gotoView4()
    self._viewMgr:showView("intance.IntanceEliteView")
end

function GlobalPromptDialog:gotoView5()
    self._viewMgr:showView("treasure.TreasureShopView")
end

function GlobalPromptDialog:gotoView6()
    local userData = self._modelMgr:getModel("UserModel"):getData()
    if not userData.guildId or userData.guildId == 0 then
        self._viewMgr:showView("guild.join.GuildInView")
    else
        self._viewMgr:showView("guild.GuildView")
    end
end

function GlobalPromptDialog:gotoView7()
    self._viewMgr:showView("cloudcity.CloudCityView")
end

function GlobalPromptDialog:gotoView8()
    local isOpen,notOpenDes = self._modelMgr:getModel("CityBattleModel"):checkIsGvgOpen()
    if isOpen then
        self._viewMgr:showView("citybattle.CityBattleView")
    else
        self._viewMgr:showTip(lang("TIP_TASK_TIP_LOCK") or "")
    end
end

-- 攻城战日常
function GlobalPromptDialog:gotoView9()
    if not SystemUtils:enableDailySiege() then
        self._viewMgr:showTip(lang("TIP_DailySiege"))
        return 
    end
    self._viewMgr:showDialog("siegeDaily.SiegeDailySelectView")  
end
-- 守城战日常
function GlobalPromptDialog:gotoView10()
    if not SystemUtils:enableDailySiege() then
        self._viewMgr:showTip(lang("TIP_DailySiege"))
        return 
    end
    self._viewMgr:showDialog("siegeDaily.SiegeDailySelectView")
end

--器械配件分解
function GlobalPromptDialog:gotoView11()
    self._viewMgr:showDialog("weapons.WeaponsBreakView")
end

function GlobalPromptDialog:gotoView12()
	UIUtils:reloadLuaFile("team.TeamHolyBreakDialog")
	self._viewMgr:showDialog("team.TeamHolyBreakDialog")
end

function GlobalPromptDialog:gotoView13()
	self._serverMgr:sendMsg("ShopServer", "getShopInfo", {type="rune"}, true, {}, function(result)
		UIUtils:reloadLuaFile("team.TeamHolyShopView")
		self._viewMgr:showView("team.TeamHolyShopView")
	end)
end

return GlobalPromptDialog