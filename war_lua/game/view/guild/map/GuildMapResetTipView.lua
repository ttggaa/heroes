--[[
    Filename:    GuildMapResetTipView.lua
    Author:      <weiwei02@playcrab.com>
    Datetime:    2017-05-02 14:47:50
    Description: File description
--]]



local GuildMapResetTipView = class("GuildMapResetTipView", BasePopView)

function GuildMapResetTipView:ctor(data)
    GuildMapResetTipView.super.ctor(self)

end


function GuildMapResetTipView:onInit()
    self:registerClickEvent(self._widget, function ()
        self:close()
    end)

    local leftImg = self:getUI("bg.Image_2")
    leftImg:loadTexture("asset/bg/guildMap/guild_map_reset_temp.png")

    self:registerScriptHandler(function(eventType)
        if eventType == "exit" then 
            UIUtils:reloadLuaFile("guild.map.GuildMapResetTipView")
        elseif eventType == "enter" then 
        end
    end)   
    for i=1,3 do
        local panel = self:getUI("bg.panel" .. i)
        panel:setVisible(false)
    end
    self._widget:runAction(                
                    cc.Sequence:create(
                    cc.DelayTime:create(0.2), 
                    cc.CallFunc:create(function()
                        for i=1,3 do
                            local panel = self:getUI("bg.panel" .. i)
                            panel.positionY = panel:getPositionY()
                            panel:setPositionY(panel.positionY - 50)
                            panel:setVisible(true)
                            local tipLab = panel:getChildByName("tipLab")
                            tipLab:setString(lang("GUILD_RESET_" .. i))
                            tipLab:setColor(UIUtils.colorTable.ccUIBasePromptColor)
                            panel:setCascadeOpacityEnabled(true, true)  
                            panel:setOpacity(0)    
                            panel:runAction(
                                    cc.Sequence:create(
                                        cc.DelayTime:create(0.2 * (i - 1)  - 0.1 * (i - 1)), 
                                        cc.Spawn:create(
                                            cc.EaseOut:create(cc.FadeIn:create(0.2), 2),
                                            cc.EaseOut:create(cc.MoveTo:create(0.2, cc.p(panel:getPositionX(), panel.positionY)), 2)
                                            )
                                        )
                                )
                        end
                    end)
                    ))

    

    -- local runTextAction
    -- runTextAction = function(inIndex)
    --     local panel = self:getUI("bg.panel" .. inIndex)
    --     if panel == nil  then return end
    --     local richText = RichTextFactory:create(lang("GUILD_RESET_" .. inIndex), panel:getContentSize().width, 0)
    --     richText:setPixelNewline(true)
    --     richText:enablePrinter(true)
    --     richText:formatText()
    --     richText:setPosition(panel:getContentSize().width/2, panel:getContentSize().height - richText:getRealSize().height/2)
    --     panel:addChild(richText)
    --     panel:runAction(
    --         cc.RepeatForever:create(
    --             cc.Sequence:create(
    --                 cc.DelayTime:create(0.1), 
    --                 cc.CallFunc:create(function() 
    --                         if richText:allFinished() then 
    --                             panel:stopAllActions()
    --                             runTextAction(inIndex + 1)
    --                         end
    --                     end
    --                     )
    --                 )
    --             )
    --         )

    -- end
    -- runTextAction(1)
    local tipLab4 = self:getUI("bg.tipLab4")
    tipLab4:setColor(UIUtils.colorTable.ccUIBaseColor8)
end


return GuildMapResetTipView