--[[
    Filename:    WeekRewardDialog.lua
    Author:      <lishunan@playcrab.com>
    Datetime:    2017-04-21 17:22:54
    Description: File description
--]]



local WeekRewardDialog = class("WeekRewardDialog",BasePopView)

function WeekRewardDialog:ctor(param)
    self.super.ctor(self)
    self._giftId = param.id
end

-- 第一次被加到父节点时候调用
function WeekRewardDialog:onAdd()

end


-- 初始化UI后会调用, 有需要请覆盖
function WeekRewardDialog:onInit()

    local giftData = tab:ToolGift(self._giftId)

    local rewardPanel1 = self:getUI("bg.week1")
    rewardPanel1:setVisible(false)
    local rewardPanel2 = self:getUI("bg.week2")
    rewardPanel2:setVisible(false)

    if self._giftId == 3018 then
        rewardPanel1:setVisible(true)
        local count = rewardPanel1:getChildByFullName("count")
        local num = giftData.giftContain[1][3]
        count:setString(num)

        local image = rewardPanel1:getChildByFullName("Image_21")
        local lightMc = mcMgr:createViewMC("huodedaojudiguang_commonlight", true)
        lightMc:setCascadeOpacityEnabled(true, true)
        lightMc:setOpacity(120)
        image:addChild(lightMc, -1)
        lightMc:setPosition(image:getContentSize().width/2,image:getContentSize().height/2)
    else
        rewardPanel2:setVisible(true)
        local count1 = rewardPanel2:getChildByFullName("count1")
        local count2 = rewardPanel2:getChildByFullName("count2")

        local num1 = giftData.giftContain[1][3]
        local num2 = giftData.giftContain[2][3]

        count1:setString(num1)
        count2:setString(num2)

        local image = rewardPanel2:getChildByFullName("Image_22")
        local lightMc = mcMgr:createViewMC("huodedaojudiguang_commonlight", true)
        lightMc:setCascadeOpacityEnabled(true, true)
        lightMc:setOpacity(120)
        image:addChild(lightMc, -1)
        lightMc:setPosition(image:getContentSize().width/2,image:getContentSize().height/2)
    end

    self._roleImg = self:getUI("bg.roleImg")
    self._roleImg:loadTexture("asset/bg/global_reward2_img.png")
   
    self:registerClickEventByName("closePanel", function()
        self:close()
    end)
end

return WeekRewardDialog