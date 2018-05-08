--[[
    Filename:    GuildChangeDeclareDialog.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2016-07-07 18:16:13
    Description: File description
--]]

-- -- 废弃
-- local GuildChangeDeclareDialog = class("GuildChangeDeclareDialog",BasePopView)
-- function GuildChangeDeclareDialog:ctor()
--     self.super.ctor(self)

-- end

-- -- 第一次被加到父节点时候调用
-- function GuildChangeDeclareDialog:onAdd()

-- end
-- -- 初始化UI后会调用, 有需要请覆盖
-- function GuildChangeDeclareDialog:onInit()
--     self:registerClickEventByName("bg.closeBtn", function( )
--         self:close()
--     end)
--     self._sloganLabel = self:getUI("bg.sloganLabel")
--     self._sloganLabel:setPlaceHolderColor(cc.c4b(255,251,215,255))
--     -- self._sloganLabel:setPlace
--     -- local allianceDetail declareelf._modelMgr:getModel("ArenaModel"):getArena()
--     local allianceDetail = self._modelMgr:getModel("GuildModel"):getAllianceDetail()
--     dump(allianceDetail)
--     if allianceDetail.declare == nil or allianceDetail.declare == "" then
--         self._sloganLabel:setString(lang("GUIDEDECLA_WORD"))
--     else
--         self._sloganLabel:setString(allianceDetail.declare or "")
--     end

--     local  sloganTitle = self:getUI("bg.title")
--     sloganTitle:setColor(UIUtils.colorTable.ccUIBaseColor1)
--     sloganTitle:setFontName(UIUtils.ttfName)
--     -- sloganTitle:enable2Color(1, cc.c4b(240, 165, 40, 255))
--     sloganTitle:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 2) 
--     sloganTitle:setFontSize(30)

--     local  slogantitleTip = self:getUI("bg.titleTip")
--     slogantitleTip:setColor(UIUtils.colorTable.ccUIBaseColor1)
--     slogantitleTip:setFontName(UIUtils.ttfName)
--     -- sloganTitle:enable2Color(1, cc.c4b(240, 165, 40, 255))
--     slogantitleTip:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 2) 
--     slogantitleTip:setFontSize(30)


--     local des1 = self:getUI("bg.des1")
--     des1:setString("")
--     -- local des2 = self:getUI("bg.des2")
--     -- des2:setString(lang("TIPS_ARENA_03"))
--     self._sloganLabel:addEventListener(function(sender, eventType)
--             if eventType == 0 then
--                 -- event.name = "ATTACH_WITH_IME"
--                 self._sloganLabel:setPlaceHolder("")
--             elseif eventType == 1 then
--                --  event.name = "DETACH_WITH_IME"
--                self._sloganLabel:setPlaceHolder("请输入宣言！")
--             elseif eventType == 2 then
--                 -- event.name = "INSERT_TEXT"
--             elseif eventType == 3 then
--                 -- event.name = "DELETE_BACKWARD"
--                 if self._sloganLabel:getString() == "" then
--                     self._sloganLabel:setPlaceHolder("请输入宣言！")
--                 end
--             end
--         end)
--     -- 确定按钮
--     self:registerClickEventByName("bg.btn1", function( )
--         local slogan = self._sloganLabel:getString()
--         if slogan == "" then
--             self._viewMgr:showTip("请输入宣言！")
--         elseif utf8.len(slogan) < 2 or utf8.len(slogan) > 40 then
--             self._viewMgr:showTip("宣言长度需2~40个字！")
--         else
--             self:sendSvaeDeclarationMsg(slogan)
            
--         end
--     end)
--     self:registerClickEventByName("bg.btn2", function( )
--         self:close()
--     end)    
-- end

-- -- 接收自定义消息
-- function GuildChangeDeclareDialog:reflashUI(data)

-- end

-- function GuildChangeDeclareDialog:sendSvaeDeclarationMsg( slogan )
--     local msg = slogan--string.urlencode(slogan)
--     local param = {content = msg}
--     self._serverMgr:sendMsg("GuildServer", "addGuildDeclare", param, true, {}, function(result)
--         self._modelMgr:getModel("GuildModel"):updateDeclare(param)
--         self._viewMgr:showTip("设置成功！")
--         -- self._modelMgr:getModel("ArenaModel"):setSlogan(self._sloganLabel:getString())
--         -- self:close()
--     end, function(errorId)
--         if tonumber(errorId) == 125 then
--             self._viewMgr:showTip("只能为中文、英文、数字")
--         elseif tonumber(errorId) == 126 then
--             self._viewMgr:showTip("字符串长度不足")
--         elseif tonumber(errorId) == 127 then
--             self._viewMgr:showTip("字符串长度超出限制")
--         elseif tonumber(errorId) == 117 or tonumber(errorId) == 107 then
--             self._viewMgr:showTip("输入内容含有非法字符")
--         end
--     end)
-- end

-- return GuildChangeDeclareDialog