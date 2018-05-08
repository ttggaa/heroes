--[[
    Filename:    GuildBaseView.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2016-05-12 21:34:44
    Description: File description
--]]
-- 为保证联盟退出正常，联盟所有界面必须继承此类
local GuildBaseView = class("GuildBaseView", BaseMvcs)

require "game.view.guild.GuildConst"
function GuildBaseView:ctor()
    GuildBaseView.super.ctor(self)
end

-- function GuildBaseView:init()
--     self._modelMgr:getModel("GuildModel"):setQuitAlliance(false)
--     self:listenReflash("UserModel", self.reflashQuitAlliance)
-- end

function GuildBaseView:reflashQuitAlliance()
    local alliance = self._modelMgr:getModel("GuildModel"):getQuitAlliance()
    if alliance == true then
        -- 为了处理多次执行这个方法
        -- print ("reflashQuitAlliance reflashQuitAlliance===================")
        return
    end
    -- print ("GuildBaseView ==================================")
    local guildId = self._modelMgr:getModel("UserModel"):getData().guildId
    if not guildId or guildId == 0 then
        self:linstenQuitGuild()
        self._modelMgr:getModel("GuildMapModel"):clear()
        self._modelMgr:getModel("GuildModel"):setQuitAlliance(true)
        local quitShow = self._modelMgr:getModel("GuildModel"):getQuitAllianceShow()

        self._viewMgr:returnMain()

        if quitShow and quitShow == true then
            ViewManager:getInstance():showTip("您已被踢出联盟！")
            ModelManager:getInstance():getModel("GuildModel"):setQuitAllianceShow(false)
        end
        
    end
end

function GuildBaseView:linstenQuitGuild()

end
return GuildBaseView 
