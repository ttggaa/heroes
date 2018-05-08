--[[
    Filename:    GuildManageSysDialog.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2016-04-22 17:03:21
    Description: File description
--]]

-- -- 限制设置
-- local GuildManageSysDialog = class("GuildManageSysDialog",BasePopView)
-- function GuildManageSysDialog:ctor(param)
--     self.super.ctor(self)
--     self._callback = param.callback
--     -- self._itemModel = self._modelMgr:getModel("ItemModel")
-- end

-- -- 初始化UI后会调用, 有需要请覆盖5
-- function GuildManageSysDialog:onInit()
--     local title = self:getUI("bg.Image_29.Label_31")
--     title:setFontName(UIUtils.ttfName)
--     title:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 2)
--     title:setFontSize(30)

--     local closeBtn = self:getUI("bg.closeBtn")
--     self:registerClickEvent(closeBtn, function()
--         self:close()
--     end)
--     local saveBtn = self:getUI("bg.saveBtn")
--     self:registerClickEvent(saveBtn, function()
--         self:setJoinGuildCondition()
--     end)

--     local value = self:getUI("bg.levelBg.value")
--     value:enableOutline(cc.c4b(55,42,28,255), 2)
--     value = self:getUI("bg.needBg.value")
--     value:enableOutline(cc.c4b(55,42,28,255), 2)

--     self:setLevel()
--     self:setNeed()
-- end

-- function GuildManageSysDialog:reflashUI()

--     local allianceD = self._modelMgr:getModel("GuildModel"):getAllianceDetail()
--     -- dump(allianceD)
--     local value = self:getUI("bg.levelBg.value")
--     local lastBtn = self:getUI("bg.levelBg.lastBtn")
--     local nextBtn = self:getUI("bg.levelBg.nextBtn")
--     self._tempLevel = allianceD.lvlimit
--     value:setString(allianceD.lvlimit)
--     if allianceD.lvlimit == 0 then
--         lastBtn:setSaturation(-100)
--     elseif allianceD.lvlimit == 80 then
--         nextBtn:setSaturation(-100)
--     end
--     local value = self:getUI("bg.needBg.value")
--     if allianceD.status == 1 then
--         value:setString("需要")
--         self._tempValue = 1
--     else
--         value:setString("不需要")
--         self._tempValue = 0
--     end
-- end 

-- function GuildManageSysDialog:setLevel()
--     local lastBtn = self:getUI("bg.levelBg.lastBtn")
--     local nextBtn = self:getUI("bg.levelBg.nextBtn")
--     local value = self:getUI("bg.levelBg.value")
--     self:registerClickEvent(lastBtn, function()
--         if tonumber(value:getString()) - 5 < 25 then
--             value:setString(tonumber(0))
--             lastBtn:setSaturation(-100)
--         elseif tonumber(value:getString()) - 5 >= 25 then
--             value:setString(tonumber(value:getString()) - 5)
--             nextBtn:setSaturation(0)
--         else
--             lastBtn:setSaturation(-100)
--         end
--         self._tempLevel = tonumber(value:getString())
--     end)
--     self:registerClickEvent(nextBtn, function()
--         if tonumber(value:getString()) + 5 <= 25 then
--             value:setString(25)
--             lastBtn:setSaturation(0)
--         elseif tonumber(value:getString()) + 5 <= 80 then
--             value:setString(tonumber(value:getString()) + 5)
--             lastBtn:setSaturation(0)
--         else
--             nextBtn:setSaturation(-100)
--         end
--         self._tempLevel = tonumber(value:getString())
--     end)
-- end 

-- function GuildManageSysDialog:setNeed()
--     local lastBtn = self:getUI("bg.needBg.lastBtn")
--     local nextBtn = self:getUI("bg.needBg.nextBtn")
--     local value = self:getUI("bg.needBg.value")
--     self:registerClickEvent(lastBtn, function()
--         -- print ("================")
--         if self._tempValue == 0 then
--             value:setString("需要")
--             self._tempValue = 1
--         else
--             value:setString("不需要")
--             self._tempValue = 0 
--         end
--     end)
--     self:registerClickEvent(nextBtn, function()
--         -- print ("================")
--         if self._tempValue == 1 then
--             value:setString("不需要")
--             self._tempValue = 0
--         else
--             value:setString("需要")
--             self._tempValue = 1
--         end
--     end)
-- end 

-- function GuildManageSysDialog:setJoinGuildCondition()
--     -- print ("==GuildManageSysDialog=======",self._tempValue, self._tempLevel, type(self._tempLevel))
--     local param = {status = self._tempValue, levelLimit = self._tempLevel}
--     local levelLab, needApply
--     if self._tempLevel == 0 then
--         levelLab = "无等级限制，"
--     else
--         levelLab = self._tempLevel .. "级，"
--     end
--     if self._tempValue == 0 then
--         needApply = "自由加入"
--     else
--         needApply = "需审核"
--     end
--     local str = "申请限制：" .. levelLab .. needApply
--     self._serverMgr:sendMsg("GuildServer", "setJoinGuildCondition", param, true, {}, function(result)
--         local guildData = self._modelMgr:getModel("GuildModel"):getAllianceDetail()
--         if result["lvlimit"] then
--             guildData["lvlimit"] = result["lvlimit"]
--         end
--         if result["status"] then
--             guildData["status"] = result["status"]
--         end
--         self._callback(str)
--         self:close()
--         -- self:setJoinGuildConditionFinish(result)
--     end)
-- end 

-- -- function GuildManageSysDialog:setJoinGuildConditionFinish(result)
-- --     if result == nil then 
-- --         return 
-- --     end
-- -- end


-- return GuildManageSysDialog