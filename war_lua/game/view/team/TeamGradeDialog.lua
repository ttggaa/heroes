--[[
    Filename:    TeamGradeDialog.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2015-12-22 18:30:21
    Description: File description
--]]


local TeamGradeDialog = class("TeamGradeDialog", BasePopView)

function TeamGradeDialog:ctor()
    TeamGradeDialog.super.ctor(self)
end


function TeamGradeDialog:onInit()
    
    -- local Image_26 = self:getUI("bg.Image_26")
    -- Image_26:setColor(cc.c4b(66, 64, 66, 255))

    local title = self:getUI("bg.titlebg.title")
    title:setColor(UIUtils.colorTable.ccUIBaseTextColor2)

    self._titleTxt = self:getUI("bg.titleBg1.titleLab")
    -- UIUtils:setTitleFormat(self._titleTxt, 2)
    UIUtils:adjustTitle(self:getUI("bg.titleBg1"))

    self:registerClickEventByName("bg.closeBtn", function ()
        if OS_IS_WINDOWS then
            UIUtils:reloadLuaFile("team.TeamGradeDialog")
        end
        self:close()
    end)

    local zhiye = {
        "tl_shuchu.png",
        "tl_fangyu.png",
        "tl_tuji.png",
        "tl_yuancheng.png",
        "tl_mofa.png",
    }

    self._zhiyeAnim = {
        "gongji_yindao",
        "jinzhan_yindao",
        "qibing_yindao",
        "yuanchengbing_yindao",
        "mofa_yindao",
    }

    local teamBg = self:getUI("bg.teamBg")
    local beijing = mcMgr:createViewMC("beijing_yindao", true, false)
    beijing:setName("beijing")
    beijing:setPosition(cc.p(teamBg:getContentSize().width*0.5, teamBg:getContentSize().height*0.5))
    teamBg:addChild(beijing)

    self._classTeam = {}
    for i=1,5 do
        local classTeam = self:getUI("bg.classTeam" .. i)
        classTeam.icon = self:getUI("bg.classTeam" .. i .. ".icon")
        classTeam.icon:loadTexture(zhiye[i], 1)
        classTeam.icon:setScale(0.9)
        classTeam.icon:setPosition(classTeam:getContentSize().width * 0.5, classTeam:getContentSize().height * 0.5)
        classTeam.icon:setZOrder(-2)

        classTeam.selectClass = mcMgr:createViewMC("xuanzhong_teamqianneng", true, false)
        classTeam.selectClass:setScale(0.7)
        classTeam.selectClass:setName("selectClass")
        classTeam.selectClass:setPosition(cc.p(classTeam:getContentSize().width*0.5, classTeam:getContentSize().height*0.5))
        classTeam:addChild(classTeam.selectClass)

        self:registerClickEvent(classTeam, function()
            self._selectIndex = i
            self:reflashUI()
        end)

        self._classTeam[i] = classTeam
    end

    self:registerClickEvent(self:getUI("bg.leftBtn"), function ()
        self:scrollEvent(-1)
    end)

    self:registerClickEvent(self:getUI("bg.rightBtn"), function ()
        self:scrollEvent(1)
    end)


    local animBg1 = self:getUI("bg.animBg.animBg1")

    local downY, downX, endX
    local spBegin = {}
    registerTouchEvent(
        animBg1,
        function (_, x, y)
            downY = y
            downX = x
            endX = x
        end, 
        function (_, x, y)
        end, 
        function (_, x, y)
            if x - downX > 100 then
                print("right=========== -1")
                self:scrollEvent(-1)
            elseif x - downX < -100 then
                print("left=========== +1")
                self:scrollEvent(1)
            end
        end,
        function (_, x, y)
            if x - downX > 100 then
                print("right=========== -1")
                self:scrollEvent(-1)
            elseif x - downX < -100 then
                print("left=========== +1")
                self:scrollEvent(1)
            end
        end)

    self._selectIndex = 1
end

-- 滑动事件
function TeamGradeDialog:scrollEvent(selectType)
    local maxSelect = self._selectIndex + selectType
    if maxSelect > 5 then
        self._selectIndex = 1
    elseif maxSelect < 1 then
        self._selectIndex = 5
    else
        self._selectIndex = maxSelect
    end
    self._openAnim = selectType
    self:updateUI()
end

function TeamGradeDialog:reflashUI(data)
    if data then
        print("teamId======", data.classlabel)
        local classlabel = tab:Team(data.classlabel).class
        self._selectIndex = classlabel
    end

    self:updateUI()
end

function TeamGradeDialog:updateUI()
    self._titleTxt:setString(lang("CLASS_INTRODUCENAME_" .. self._selectIndex))
    UIUtils:adjustTitle(self:getUI("bg.titleBg1"))

    local desc = lang("CLASS_INTRODUCE_" .. self._selectIndex)
    
    local labPanel = self:getUI("bg.labPanel")
    local richText = labPanel:getChildByName("descRichText")
    if richText then
        richText:removeFromParentAndCleanup()
    end
    desc = string.gsub(desc, "562600", "825528")
    richText = RichTextFactory:create(desc, labPanel:getContentSize().width, labPanel:getContentSize().height - 5)
    richText:formatText()
    richText:enablePrinter(true)
    local posX = (labPanel:getContentSize().width-richText:getRealSize().width)*0.5+labPanel:getContentSize().width*0.5
    richText:setPosition(posX, labPanel:getContentSize().height - richText:getInnerSize().height*0.5)
    richText:setName("descRichText")
    labPanel:addChild(richText)



    local animBg = self:getUI("bg.animBg")
    for i=1,5 do
        local classTeam = self._classTeam[i]

        if i == self._selectIndex then
            classTeam.selectClass:setVisible(true)
            local seq, seq1
            if self._openAnim and self._openAnim ~= 0 then
                if self._openAnim == 1 then
                    seq = cc.Sequence:create(cc.Spawn:create(cc.MoveBy:create(0.2, cc.p(-200, 0)), cc.FadeOut:create(0.1)), cc.RemoveSelf:create(true))
                    seq1 = cc.Sequence:create(cc.FadeOut:create(0), cc.MoveBy:create(0, cc.p(200, 0)), 
                        cc.Spawn:create(cc.MoveBy:create(0.2, cc.p(-200, 0)), cc.FadeOut:create(0.1)) 
                        )
                elseif self._openAnim == -1 then
                    seq = cc.Sequence:create(cc.Spawn:create(cc.MoveBy:create(0.2, cc.p(200, 0)), cc.FadeOut:create(0.1)), cc.RemoveSelf:create(true))
                    seq1 = cc.Sequence:create(cc.FadeOut:create(0), cc.MoveBy:create(0, cc.p(-200, 0)), 
                        cc.Spawn:create(cc.MoveBy:create(0.2, cc.p(200, 0)), cc.FadeOut:create(0.1)) 
                        )
                end
                self._openAnim = 0
            end
            if self._anim then
                local tempAnim = self._anim
                if seq then
                    tempAnim:runAction(seq)
                else
                    self._anim:removeFromParent()
                end
                self._anim = nil
            end
            self._anim = mcMgr:createViewMC(self._zhiyeAnim[i], true, false)
            self._anim:setPosition(cc.p(animBg:getContentSize().width*0.5, animBg:getContentSize().height*0.5-15))
            animBg:addChild(self._anim)
            if seq1 then
                self._anim:runAction(seq1)
            end
            classTeam:setOpacity(100)
            classTeam.icon:setZOrder(1)
        else
            classTeam.selectClass:setVisible(false)
            classTeam:setOpacity(255)
            classTeam.icon:setZOrder(-2)
        end
    end
            
end

return TeamGradeDialog
