--[[
    @FileName   GuildMercenarySendView.lua
    @Authors    zhangtao
    @Date       2017-08-09 19:55:56
    @Email      <zhangtao@playcrad.com>
    @Description   描述
--]]
local GuildMercenarySendView = class("GuildMercenarySendView",BasePopView)
function GuildMercenarySendView:ctor()
    self.super.ctor(self)
    self._teamModel = self._modelMgr:getModel("TeamModel")
    self._teamId = 0
end

-- 初始化UI后会调用, 有需要请覆盖
function GuildMercenarySendView:onInit()
    local closeBtn = self:getUI("bg.layer.btn_close")
    self:registerClickEvent(closeBtn, function()
        self:close()
        UIUtils:reloadLuaFile("guild.mercenary.GuildMercenarySendView")
    end)

    self._sureBg = self:getUI("bg.layer.sureBg")
    self._teamIconBg = self:getUI("bg.layer.listBg.teamIconBg")
    self._name = self:getUI("bg.layer.listBg.name")
    self._fightValue = self:getUI("bg.layer.listBg.fightValue")
    self._profitValue = self:getUI("bg.layer.listBg.profitValue")
    self._profitTimeNode = self:getUI("bg.layer.listBg.profitTimeNode")
    local title = self:getUI("bg.layer.titleBg.title")
    UIUtils:setTitleFormat(title, 1)
    
    --确定按钮
    local surebtn = self:getUI("bg.layer.surebtn")
    --换一个按钮
    local changeBtn = self:getUI("bg.layer.changeBtn")

    self:registerClickEvent(surebtn,function ()
        self._serverMgr:sendMsg("GuildServer", "setMercenary", {pos = self._pos,teamId = self._teamId }, true, {}, function(result, errorCode)
            if errorCode ~= 0 then 
                self._viewMgr:unlock(51)
                return
            end
            self._viewMgr:showTip("佣兵设置成功")
            -- self._parent:reloadTableView()
            self:close()
            self._viewMgr:reflashUI("guild.mercenary.GuildMercenaryView",{pos = self._pos})
        end)
    end)
    self:registerClickEvent(changeBtn,function ()
        self:close()
        self._viewMgr:showDialog("guild.mercenary.GuildMercenaryListView", {pos = self._pos})
    end)
end

function GuildMercenarySendView:changeTeamId()
    
end

-- 第一次进入调用, 有需要请覆盖
function GuildMercenarySendView:onShow()


end

function GuildMercenarySendView:loadUI()
    -- self._teamId = self._teamData[self._selectIndex]["teamId"]
    self._teamId = self._teamData["teamId"]

    local changeTime = tab.lansquenet[self._pos]["changeTime"]
    local hour, minute, second
    hour = math.floor(changeTime/3600)
    tempValue = changeTime - hour*3600
    minute = math.floor(tempValue/60)
    tempValue = changeTime - minute*60
    second = math.fmod(tempValue, 60)
    local timeDes
    if hour > 0 then
        timeDes = changeTime/3600 .. "个小时"
    else
        if minute > 0 then
            timeDes = changeTime/60 .. "分钟"
        else
            timeDes = changeTime .. "秒"
        end
    end

    --武将Icon
    local teamIcon = self._teamIconBg.teamIcon
    local teamData = self._teamModel:getTeamAndIndexById(self._teamId)
    local teamTableData = tab:Team(teamData.teamId)
    local quality = self._teamModel:getTeamQualityByStage(teamData.stage)  

    if teamIcon then
        IconUtils:updateTeamIconByView(teamIcon, {teamData = teamData, sysTeamData = teamTableData, quality = quality[1], quaAddition = quality[2],isShowOriginScore = true,eventStyle = 0})
    else
        teamIcon = IconUtils:createTeamIconById({teamData = teamData, sysTeamData = teamTableData, quality = quality[1], quaAddition = quality[2],isShowOriginScore = true,eventStyle = 0})
        -- teamIcon:setName("teamIcon")
        teamIcon:setScale(0.9)
        teamIcon:setPosition(cc.p(50,50))
        teamIcon:setAnchorPoint(cc.p(0.5,0.5))
        self._teamIconBg.teamIcon = teamIcon
        self._teamIconBg:addChild(teamIcon)
    end
    local inView = self._teamIconBg.teamIcon
    registerTouchEvent(self._teamIconBg.teamIcon,function()
        inView:runAction(cc.EaseIn:create(cc.ScaleTo:create(0.05, 0.9*0.9), 2))
    end,function()
    end,function()
        inView:runAction(cc.Sequence:create(cc.EaseIn:create(cc.ScaleTo:create(0.05, 0.9), 2),cc.DelayTime:create(0.2),cc.CallFunc:create(function( )
            ViewManager:getInstance():showHintView("global.GlobalTipView",{tipType = 8, node = inView, id = teamData.teamId or teamData.id,teamData = teamData,sysTeamData = teamTableData})
        end)))
    end)

    --名字
    local isAwaking,awakingLvl = TeamUtils:getTeamAwaking(teamData)
    local teamName = teamTableData.name
    local useless1 = nil
    local useless2 = nil
    -- if isAwaking then
        teamName, useless1, useless2 = TeamUtils:getTeamAwakingTab(teamData)
    -- end
    local teamName = lang(teamName)
    self._name:setString(teamName)

    -- local timeCount = changeTime/3600
    --描述
    local str1 = "[color=3C2A1E,fontsize=20]是否确定派遣[-]"
    local str2 = "[color=00FF00,fontsize=20,outlinecolor=603010,outlinesize=1]"..teamName.."[-]"
    local str3 = "[color=3C2A1E,fontsize=20]作为佣兵，派遣后[-]"
    local str4 = "[color=3C2A1E,fontsize=20]"..timeDes.."[-]"
    local str5 = "[color=3C2A1E,fontsize=20]内不能更换该佣兵[-]"
    local rtxStr = str1 .. str2 .. str3 .. str4 .. str5
    local sureDes = RichTextFactory:create(rtxStr,420,30)
    sureDes:formatText()
    sureDes:setVerticalSpace(0)
    sureDes:setAnchorPoint(cc.p(0.5,0.5))
    local w = self._sureBg:getContentSize().width
    local h = self._sureBg:getContentSize().height
    sureDes:setName("sureDes")
    sureDes:setPosition(cc.p(w/2,h/2))
    self._sureBg:addChild(sureDes)
    --战力
    self._fightValue:setString("战斗力:"..self._teamData["score"])
    --收益
    local profitValue = self:getProfitValue(self._teamData["score"])
    self._profitValue:setString(profitValue)

    local posX,posY = self._profitValue:getPosition()
    local anchorPointX = self._profitValue:getAnchorPoint().x
    local contsizeWidth = self._profitValue:getContentSize().width
    self._profitTimeNode:setPosition(posX + (1-anchorPointX)*contsizeWidth , posY)

    -- UIUtils:center2Widget(buyIcon,priceLab,itemW/2,5)

end
--计算收益值
function GuildMercenarySendView:getProfitValue(score)
    local tecAdd = self._modelMgr:getModel("GuildModel"):getMercenaryScienceAdd() or 0
    local userLevel = self._modelMgr:getModel("UserModel"):getData().lvl
    local m = tab.lansquenet[self._pos]["m"]  --战斗力系数
    local k = tab.lansquenet[self._pos]["k"]*(1+(tecAdd/100))  --基础奖励
    local n = tab.lansquenet[self._pos]["n"]*(1+(tecAdd/100))
    local perValue = string.format("%0.2f",tonumber(userLevel)*k + math.pow(score/m,2)*n)
    print("perValue",perValue)
    return math.ceil(tonumber(perValue)*(3600/tab.lansquenet[self._pos]["time"]))
end

-- 接收自定义消息
function GuildMercenarySendView:reflashUI(data)
    dump(data,"=====data======")
    self._parent = data.parent
    self._teamData = data.teamData
    -- self._selectIndex = data.selectIndex
    self._pos = data.pos
    self:loadUI()
end

return GuildMercenarySendView