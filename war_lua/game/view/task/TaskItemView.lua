--[[
    Filename:    TaskItemView.lua
    Author:      <liushuai@playcrab.com>
    Datetime:    2015-09-09 15:20:01
    Description: File description
--]]

local TaskItemView = class("TaskItemView", BaseLayer)

TaskItemView.kViewTypeItemPrimary = 1
TaskItemView.kViewTypeItemEveryday = 2
TaskItemView.kViewTypeFinished = 3
TaskItemView.kViewTypeItemWeekly = 4

TaskItemView.kItemContentSize = {
    width = 770,
    height = 117
}

function TaskItemView:ctor(params)
    TaskItemView.super.ctor(self)
    self._container = params.container
    self._viewType = params.viewType
    self._taskData = params.taskData
    self._privilegesModel = self._modelMgr:getModel("PrivilegesModel")
    self._userModel = self._modelMgr:getModel("UserModel")
end

function TaskItemView:disableTextEffect(element)
    if element == nil then
        element = self._widget
    end
    local desc = element:getDescription()
    if desc == "Label" then
        element:disableEffect()
    end
    local count = #element:getChildren()
    for i = 1, count do
        self:disableTextEffect(element:getChildren()[i])
    end
end

function TaskItemView:onInit()
    --print("TaskItemView:onInit")
    self:disableTextEffect()
    self._layerItem = self:getUI("layer_item")
    self._layerGoBg = self:getUI("layer_item.layer_go_bg")
    self._layerGoBg:setSwallowTouches(false)
    --self._layerGoBg:setBrightness(-51)
    
    self._layerFinishedLine = self:getUI("layer_finished_line")
    local label_finished = self:getUI("layer_finished_line.label_finished")
    -- label_finished:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
    self._taskIconBg = self:getUI("layer_item.task_icon_bg")
    self._taskIcon = self:getUI("layer_item.task_icon_bg.task_icon")
    self._taskIcon:setVisible(false)
    self._taskName = self:getUI("layer_item.task_title_bg.task_name")
    --self._taskName:enableOutline(cc.c4b(60, 30, 10, 255), 1)
    --self._taskName:setFontName(UIUtils.ttfName)
    --self._taskName:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
    self._task_namebg = self:getUI("layer_item.task_namebg")
    self._taskDescription = self:getUI("layer_item.task_title_bg.task_description")
    self._taskActive = self:getUI("layer_item.task_title_bg.task_active")
    -- self._taskActive:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
    --self._taskActive:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
    self._taskActiveValue = self:getUI("layer_item.task_title_bg.task_active_value")
    -- self._taskActiveValue:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
    self._taskCurrentDataBg = self:getUI("layer_item.task_title_bg.task_current_data_bg")
    self._taskCurrentData = self:getUI("layer_item.task_title_bg.task_current_data")
    self._btnGo = self:getUI("layer_item.btn_go")
    self._btnGet = self:getUI("layer_item.btn_get")
    --[[
    self._getMC = mcMgr:createViewMC("anniuguangxiao_tongyonganniu", true)
    self._getMC:setPlaySpeed(1, true)
    self._getMC:setPosition(self._btnGet:getContentSize().width / 2, self._btnGet:getContentSize().height / 2)
    self._btnGet:addChild(self._getMC)
    ]]

    self._label_reward_value_1 = self:getUI("layer_item.task_title_bg.label_reward_value_1")
    self._label_reward_value_2 = self:getUI("layer_item.task_title_bg.label_reward_value_2")
    self._label_reward_value_3 = self:getUI("layer_item.task_title_bg.label_reward_value_3")
    self._task_reward = self:getUI("layer_item.task_title_bg.task_reward")
    -- self._label_reward_value_1:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
    -- self._label_reward_value_2:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
    -- self._label_reward_value_3:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
    --[[
    self._getMC2 = mcMgr:createViewMC("anniuguangxiao_tongyonganniu", true)
    self._getMC2:setPlaySpeed(1, true)
    self._getMC2:setPosition(self._btnGet:getContentSize().width / 2, self._btnGet:getContentSize().height / 2)
    self._btnGet:addChild(self._getMC2)
    ]]
    self._imageAlreadyGet = self:getUI("layer_item.image_already_get")

    self._rewards = {}
    for i = 1, 2 do
        self._rewards[i] = {}
        self._rewards[i]._icon = self:getUI("layer_item.task_title_bg.reward_icon_" .. i)
        self._rewards[i]._value = self:getUI("layer_item.task_title_bg.label_reward_value_" .. i)
        --self._rewards[i]._value:enableShadow(cc.c4b(0, 0, 0,255))
        self._rewards[i]._addValue = self:getUI("layer_item.task_title_bg.label_reward_add_value_" .. i)
        -- self._rewards[i]._addValue:enableOutline(cc.c4b(60, 30, 10, 255), 2)
        self._rewards[i]._addValue:setVisible(false)
        self._rewards[i]._bg = self:getUI("layer_item.task_title_bg.icon_bg_" .. i)
    end

    self:registerClickEvent(self._btnGo, function ()
        self:onButtonGoClicked()
    end)

    self:registerClickEvent(self._btnGet, function ()
        self:onButtonGetClicked()
    end)

    --[[
    self:registerClickEvent(self._layerGoBg, function ()
        self._viewMgr:showTip(lang("TIP_TASK_RECIEVE"))
    end)
    ]]

    self:updateUI()
end

function TaskItemView:updateUI()
    if self._viewType == TaskItemView.kViewTypeFinished then
        self._layerItem:setVisible(false)
        self._layerFinishedLine:setVisible(true)
        return
    end
    --dump(self._taskData, "TaskItemView")
    self._layerItem:setVisible(true)
    self._layerFinishedLine:setVisible(false)
    --self:setSaturation(0 ~= self._taskData.status and 1 ~= self._taskData.status and -100 or 0)

    local filename = IconUtils.iconPath .. self._taskData.art .. ".png"
    self._taskIcon:setVisible(true)
    self._taskIcon:loadTexture(filename, 1)
    -- self._taskIcon:loadTexture(IconUtils.iconPath .. self._taskData.art .. ".png")
    if self._taskData.floor and 1 == self._taskData.floor then
        self._taskIconBg:loadTexture("item_bg_80_flag_task.png", 1)

        self._layerItem:setBackGroundImage(self._taskData.status > 1 and "item_bg_80_d_task.png" or "item_bg_80_n_task.png", 1)
        self._layerItem:setBackGroundImageCapInsets(cc.rect(41,41,1,1))

        self._layerGoBg:setBackGroundImage("item_bg_80_p_task.png", 1)
        self._layerGoBg:setBackGroundImageCapInsets(cc.rect(41,41,1,1))
    elseif self._taskData.floor and 2 == self._taskData.floor then
        self._taskIconBg:loadTexture("item_bg_80_flag_task.png", 1)

        self._layerItem:setBackGroundImage(self._taskData.status > 1 and "item_bg_80_d_task.png" or "item_bg_80_n_task.png", 1)
        self._layerItem:setBackGroundImageCapInsets(cc.rect(41,41,1,1))

        self._layerGoBg:setBackGroundImage("item_bg_80_rand_n_task.png", 1)
        self._layerGoBg:setBackGroundImageCapInsets(cc.rect(41,41,1,1))
    elseif self._taskData.floor and 3 == self._taskData.floor then
        self._taskIconBg:loadTexture("item_bg_weekly_flag_3.png", 1)

        self._layerItem:setBackGroundImage(self._taskData.status > 1 and "globalPanelUI7_cellBg2.png" or "globalPanelUI7_cellBg0.png", 1)
        self._layerItem:setBackGroundImageCapInsets(cc.rect(41,41,1,1))

        self._layerGoBg:setBackGroundImage("globalPanelUI7_cellBg1.png", 1)
        self._layerGoBg:setBackGroundImageCapInsets(cc.rect(41,41,1,1))
    elseif self._taskData.floor and 4 == self._taskData.floor then
        self._taskIconBg:loadTexture("item_bg_weekly_flag_4.png", 1)

        self._layerItem:setBackGroundImage(self._taskData.status > 1 and "item_bg_80_d_task.png" or "item_bg_80_n_task.png", 1)
        self._layerItem:setBackGroundImageCapInsets(cc.rect(41,41,1,1))

        self._layerGoBg:setBackGroundImage("item_bg_80_rand_n_task.png", 1)
        self._layerGoBg:setBackGroundImageCapInsets(cc.rect(41,41,1,1))
    else
        self._taskIconBg:loadTexture("globalImageUI_flagBg_blue.png", 1)

        self._layerItem:setBackGroundImage(self._taskData.status > 1 and "globalPanelUI7_cellBg2.png" or "globalPanelUI7_cellBg0.png", 1)
        self._layerItem:setBackGroundImageCapInsets(cc.rect(41,41,1,1))

        self._layerGoBg:setBackGroundImage("globalPanelUI7_cellBg1.png", 1)
        self._layerGoBg:setBackGroundImageCapInsets(cc.rect(41,41,1,1))
    end
    
    self._layerGoBg:setVisible(self._taskData.status < 1)
    self._btnGo:setVisible(0 == self._taskData.status and 0 < self._taskData.button)
    self._btnGet:setVisible(1 == self._taskData.status)
    --[[
    if 1 == self._taskData.status then
    --     self._label_reward_value_1:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
    --     self._label_reward_value_2:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
    --     self._label_reward_value_3:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
        self._label_reward_value_1:setColor(UIUtils.colorTable.ccUIBaseTextColor1)
        self._label_reward_value_2:setColor(UIUtils.colorTable.ccUIBaseTextColor1)
        self._label_reward_value_3:setColor(UIUtils.colorTable.ccUIBaseTextColor1)
        self._task_reward:setColor(UIUtils.colorTable.ccUIBaseTextColor1)
        for i = 1, 3 do
            self._rewards[i]._value:setColor(UIUtils.colorTable.ccUIBaseTextColor1)
        end
        self._taskActive:setColor(UIUtils.colorTable.ccUIBaseTextColor1)
        self._taskActiveValue:setColor(UIUtils.colorTable.ccUIBaseTextColor1)
    else
        self._label_reward_value_1:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
        self._label_reward_value_2:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
        self._label_reward_value_3:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
        self._task_reward:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
        for i = 1, 3 do
            self._rewards[i]._value:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
        end
        self._taskActive:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
        self._taskActiveValue:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    end
    ]]
    self._imageAlreadyGet:setVisible(self._taskData.status > 1)
    self._taskCurrentDataBg:setVisible(not self._imageAlreadyGet:isVisible())
    self._taskCurrentData:setVisible(not self._imageAlreadyGet:isVisible())
    self._taskName:setFontName(UIUtils.ttfName)
    self._taskName:setString(lang(self._taskData.name))
    self._task_namebg:setContentSize(cc.size(math.max(190,self._taskName:getContentSize().width+95),34))
    --[[
    if self._taskData.id >= 19618 and self._taskData.id <= 19627 then
        self._taskName:setColor(cc.c3b(0, 255, 0))
    else
        self._taskName:setColor(cc.c3b(255, 255, 255))
    end
    ]]
    -- self._taskName:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
    local labelDiscription = self._taskDescription
    local desc = lang(self._taskData.des)
    if self._taskData.id == 9622 and self._userModel:getData().guildLevel and (self._userModel:getData().guildLevel >= 3) then
        desc = lang("TASKDES_9622_1")
    end
    local varibleNameToValue = {
        ["$physical1"] = self._privilegesModel:getAbilityEffect(PrivilegeUtils.privileg_ID.PRIVILEGENAME_19),
        ["$physical2"] = self._privilegesModel:getAbilityEffect(PrivilegeUtils.privileg_ID.PRIVILEGENAME_17),
        ["$physical3"] = self._privilegesModel:getAbilityEffect(PrivilegeUtils.privileg_ID.PRIVILEGENAME_18)
    }
    desc = string.gsub(desc, "%b{}", function(substring)
        return math.round(loadstring("return " .. string.gsub(string.gsub(substring, "%$%w+", function(variableName)
            return tostring(varibleNameToValue[variableName])
        end), "[{}]", ""))())
    end)
    desc = string.gsub(desc, "，", ",")
    -- 强制换色
    -- desc = string.gsub(desc,"%b[]",function( catchStr )
    --     local _,pos1 = string.find(catchStr,"color=")
    --     if pos1 then
    --         -- if 1 == self._taskData.status then
    --         --     return string.sub(catchStr,1,pos1) .. "865c30" .. string.sub(catchStr,pos1+7,string.len(catchStr))
    --         -- else
    --             catchStr = string.sub(catchStr,1,pos1) .. "3d1f00" .. string.sub(catchStr,pos1+7,string.len(catchStr))
    --         -- end
    --     end
    --     local _,pos2 = string.find(catchStr,"fontsize=")
    --     if pos2 then
    --         catchStr = string.sub(catchStr,1,pos2) .. 24 .. string.sub(catchStr,pos2+3,string.len(catchStr))
    --     end
    --     return catchStr
    -- end)
    local richText = labelDiscription:getChildByName("descRichText")
    if richText then
        richText:removeFromParentAndCleanup()
    end
    richText = RichTextFactory:create(desc, labelDiscription:getContentSize().width, labelDiscription:getContentSize().height - 5)
    richText:formatText()
    richText:enablePrinter(true)
    richText:setPosition(labelDiscription:getContentSize().width / 2-15, labelDiscription:getContentSize().height - richText:getInnerSize().height / 2)
    richText:setName("descRichText")
    labelDiscription:addChild(richText)
    local activeName = self._viewType == self.kViewTypeItemPrimary and "成长值" or "活跃度"
    -- print(self._viewType,"============activeName=========",activeName)
    local activeValue = "+" .. (self._viewType == self.kViewTypeItemPrimary and self._taskData.grow or self._taskData.active)
    local isActiveShow = self._viewType == self.kViewTypeItemPrimary and 0 ~= self._taskData.grow or
                         self._viewType == self.kViewTypeItemEveryday and 0 ~= self._taskData.active or
                         self._viewType == self.kViewTypeItemWeekly and 0 ~= self._taskData.active
    self._taskActive:setVisible(isActiveShow)
    self._taskActiveValue:setVisible(isActiveShow)
    self._taskActive:setString(activeName)
    self._taskActiveValue:setString(activeValue)
    -- self._taskActiveValue:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
    --self._taskCurrentData:setPositionY((self._btnGo:isVisible() or self._btnGet:isVisible()) and 7 or -23)
    self._taskCurrentData:setColor(cc.c3b(138, 92, 29))
    local conditiontype = self._taskData.conditiontype
    if 101 == conditiontype or
       102 == conditiontype then
       self._taskCurrentDataBg:setVisible(true)
        self._taskCurrentData:setVisible(true)
        if 0 == self._taskData.status then
            self._taskCurrentData:setString("0/1")
        elseif 1 == self._taskData.status then
            self._taskCurrentData:setString("1/1")
        else
            self._taskCurrentDataBg:setVisible(false)
            self._taskCurrentData:setVisible(false)
        end
        self._taskCurrentData:setColor(1 == self._taskData.status and cc.c3b(28, 162, 22) or cc.c3b(138, 92, 29))
    elseif 998 == conditiontype or 997 == conditiontype then
        self._taskCurrentDataBg:setVisible(true)
        self._taskCurrentData:setVisible(true)
        if 0 == self._taskData.status then
            self._taskCurrentData:setString("未购买")
        elseif 1 == self._taskData.status then
            self._taskCurrentData:setString("已购买")
            self._taskActive:setVisible(true)
            self._taskActiveValue:setVisible(true)
            self._taskActive:setString("剩余:")
            local restDay = math.floor((self._taskData.val2 - self._modelMgr:getModel("UserModel"):getCurServerTime()) / 86400)
            self._taskActiveValue:setString(restDay .. "天")
        else
            self._taskCurrentDataBg:setVisible(false)
            self._taskCurrentData:setVisible(false)
        end   
    elseif 999 == conditiontype then
        if 0 == self._taskData.status then
            self._taskCurrentData:setString("时间未到")
        elseif self._taskData.status >= 1 then
            self._taskCurrentData:setVisible(false)
        elseif -1 == self._taskData.status then
            self._taskCurrentData:setString("时间已过")
        end
    else
        self._taskCurrentData:setVisible(not self._imageAlreadyGet:isVisible())
        self._taskCurrentData:setColor(1 == self._taskData.status and cc.c3b(28, 162, 22) or cc.c3b(138, 92, 29))
        self._taskCurrentData:setString(ItemUtils.formatItemCount(tonumber(self._taskData.val2)) .. "/" .. ItemUtils.formatItemCount(tonumber(self._taskData.val1)))
    end
    --[[
    if not self._taskCurrentData:isVisible() then 
        local height = self._layerItem:getContentSize().height
        self._btnGo:setPositionY(height/2)
        self._btnGet:setPositionY(height/2)
    else
        self._btnGo:setPositionY(55)
        self._btnGet:setPositionY(55)
    end
    ]]
    local toolTableData = tab.tool
    local staticConfigTableData = IconUtils.iconIdMap
    local staticConfigTableResData = clone(IconUtils.resImgMap)
    staticConfigTableResData.exp = "globalImageUI_exp2.png"
    staticConfigTableResData.vexp = "globalImageUI_exp2.png"
    staticConfigTableResData.starfrag = "globalImageUI_starfrag.png"

    for i=1, 2 do
        self._rewards[i]._icon:setVisible(false)
        self._rewards[i]._value:setVisible(false)
        self._rewards[i]._addValue:setVisible(false)
        self._rewards[i]._bg:setVisible(false)
    end

    local count = math.min(#self._taskData.award, 2)
    for i = 1, count do
        self._rewards[i]._icon:setVisible(true)
        self._rewards[i]._value:setVisible(true)
        self._rewards[i]._bg:setVisible(true)
        if self._taskData.award[i][1] ~= "tool" and staticConfigTableData[self._taskData.award[i][1]] then
            local filename = IconUtils.iconPath .. staticConfigTableResData[self._taskData.award[i][1]]
            self._rewards[i]._icon:loadTexture(filename, 1)
            self._rewards[i]._icon:setScale(30 / self._rewards[i]._icon:getContentSize().width)
            local value = tonumber(self._taskData.award[i][3])
            local addition = 0
            local additionValue = 0
            local color = cc.c3b(255, 255, 255)
            if self._taskData.award[i][1] == "physcal" then
                if 9615 == self._taskData.id then
                    addition = self._privilegesModel:getAbilityEffect(PrivilegeUtils.privileg_ID.PRIVILEGENAME_19)
                    if addition > 0 then
                        color = cc.c3b(118, 238, 0)
                    end
                    additionValue = addition
                elseif 9616 == self._taskData.id then
                    addition = self._privilegesModel:getAbilityEffect(PrivilegeUtils.privileg_ID.PRIVILEGENAME_17)
                    if addition > 0 then
                        color = cc.c3b(118, 238, 0)
                    end
                    additionValue = addition
                elseif 9617 == self._taskData.id then
                    addition = self._privilegesModel:getAbilityEffect(PrivilegeUtils.privileg_ID.PRIVILEGENAME_18)
                    if addition > 0 then
                        color = cc.c3b(118, 238, 0)
                    end
                    additionValue = addition
                end
            elseif self._taskData.award[i][1] == "exp" then
                if 201 ~= self._taskData.conditiontype 
                    and self._taskData.type 
                    and  not (self._taskData.type == 4 or self._taskData.type == 5) 
                then
                    addition = self._privilegesModel:getAbilityEffect(PrivilegeUtils.privileg_ID.PRIVILEGENAME_16)
                    if addition > 0 then
                        color = cc.c3b(118, 238, 0)
                    end
                    additionValue = value * addition * 0.01
                end
            end
            -- self._rewards[i]._value:setColor(color)
            --self._rewards[i]._icon:loadTexture(IconUtils.iconPath .. toolTableData[staticConfigTableData[self._taskData.award[i][1]]].art .. ".jpg")
            --self._rewards[i]._value:setString(math.round(value))
            self._rewards[i]._value:setString(math.round(value))
            if additionValue > 0 then
                self._rewards[i]._addValue:setVisible(true)
                -- self._rewards[i]._addValue:enableOutline(cc.c4b(60, 30, 10, 255), 1)
                self._rewards[i]._addValue:setPosition(self._rewards[i]._value:getPositionX() + self._rewards[i]._value:getContentSize().width, self._rewards[i]._value:getPositionY())
                self._rewards[i]._addValue:setString(string.format("+%d", math.round(additionValue)))
            end
        elseif self._taskData.award[i][1] == "tool" and toolTableData[self._taskData.award[i][2]] then
            local filename = IconUtils.iconPath .. toolTableData[self._taskData.award[i][2]].art .. ".png"
            self._rewards[i]._icon:loadTexture(filename, 1)
            self._rewards[i]._icon:setScale(30 / self._rewards[i]._icon:getContentSize().width)
            -- self._rewards[i]._icon:loadTexture(IconUtils.iconPath .. toolTableData[self._taskData.award[i][2]].art .. ".jpg")
            self._rewards[i]._value:setString(self._taskData.award[i][3])
        end
    end
end

function TaskItemView:setContext(context)
    self._container = context.container
    self._viewType = context.viewType
    self._taskData = context.taskData
end

function TaskItemView:onButtonGoClicked()
    if not (self._container and self._container.onButtonGoClicked) then return end
    self._container:onButtonGoClicked(self._taskData)
end

function TaskItemView:onButtonGetClicked()
    if not (self._container and self._container.onButtonGetClicked) then return end
    self._container:onButtonGetClicked(self._taskData)
end

return TaskItemView