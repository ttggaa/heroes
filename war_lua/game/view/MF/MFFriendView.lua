--[[
    Filename:    MFFriendView.lua
    Author:      <qiaohuan@playcrab.com>
    Datetime:    2016-09-28 17:42:53
    Description: File description
--]]

local MFFriendView = class("MFFriendView",BaseView)
function MFFriendView:ctor(params)
    MFFriendView.super.ctor(self)
    self._friendMfData = params.tasks
    self._userId = params.userid
    self._userdata = params.userdata
    self._posJump = 10
    -- dump(params, "params ===")
end

function MFFriendView:onInit()
    local ruleBtn = self:getUI("ruleBtn")
    self:registerClickEvent(ruleBtn, function()
        self._viewMgr:showDialog("MF.MFDescDialog")
    end)

    self._modelMgr:getModel("MFModel"):setCloudShow(true)

    local closeBtn = self:getUI("closeBtn")
    self:registerClickEvent(closeBtn, function()
        local beijing = mcMgr:createViewMC("yunqiehuan_mfqiehuanyun", false, true, function()
            if OS_IS_WINDOWS then
                UIUtils:reloadLuaFile("MF.MFFriendView")
            end
            self:close()
        end)
        beijing:setName("beijing")
        beijing:setAnchorPoint(cc.p(0.5,0.5))
        beijing:setPosition(cc.p(MAX_SCREEN_WIDTH*0.5,MAX_SCREEN_HEIGHT*0.5))
        self:addChild(beijing)
    end)

    self._firstJump = false

    local mfbg = self:getUI("bg.scrollView.bg")
    mfbg:removeFromParent()

    local helpLab = self:getUI("helptimeBg.helpLab")
    helpLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

    local helptimeBg = self:getUI("helptimeBg")
    local jiasuTip = self:getUI("helptimeBg.jiasuTip")
    self:registerTouchEvent(helptimeBg, nil, nil, function()
        jiasuTip:setVisible(false)
    end, function()
        jiasuTip:setVisible(false)
    end, function()
        jiasuTip:setVisible(true)
    end)

    local sp1 = cc.Sprite:create("asset/bg/bg_mf_1.jpg")
    sp1:setPosition(512, 480)
    local sp2 = cc.Sprite:create("asset/bg/bg_mf_2.jpg")
    sp2:setPosition(1024 + 340, 480)

    self._scrollView = self:getUI("bg.scrollView")
    self._scrollView:addChild(sp1)
    self._scrollView:addChild(sp2)

    self._daoyu = {}
    for i=1,8 do
        self._daoyu[i] = self:getUI("bg.scrollView.layer.daoyu" .. i)
        local cityTab = tab:MfOpen(i)

        self._daoyu[i].daoyu = self:createDaoyu(cityTab["cityCo"][1], cityTab["cityCo"][2], i)
        self._daoyu[i].cloud1 = self:createCloud(self._daoyu[i].daoyu, cityTab["cloud"], i)

        self._daoyu[i].titleBg = self._daoyu[i]:getChildByFullName("titleBg") -- self:createTitle(titlePos[i]["x"], titlePos[i]["y"], i, self._daoyu[i])
        self._daoyu[i].titleBg:setCascadeOpacityEnabled(true)
        self._daoyu[i].title = self._daoyu[i]:getChildByFullName("titleBg.title") -- self:createTitle(titlePos[i]["x"], titlePos[i]["y"], i, self._daoyu[i])
        self._daoyu[i].title:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        self._daoyu[i].starBg = self._daoyu[i]:getChildByFullName("titleBg.starBg")
        self._daoyu[i].starBg:setCascadeOpacityEnabled(true)
        -- self._daoyu[i].teamBg = self._daoyu[i]:getChildByFullName("titleBg.icon")
        -- self._daoyu[i].teamBg:setCascadeOpacityEnabled(true)
        self._daoyu[i].timeBg = self._daoyu[i]:getChildByFullName("timeBg")
        -- self._daoyu[i].timeBg:setCascadeOpacityEnabled(true)
        self._daoyu[i].timeBg:setVisible(false)
        self._daoyu[i].timeBar = self._daoyu[i]:getChildByFullName("timeBg.timeBar")
        self._daoyu[i].timerLab = self._daoyu[i]:getChildByFullName("timeBg.timerLab")
        self._daoyu[i].timerLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)

        self:registerClickEvent(self._daoyu[i], function()
            self:updateButton(self._daoyu[i])
        end)

        local mc2 = mcMgr:createViewMC("shalou_mfhanghaifengweitexiao", true, false)
        mc2:setName("shalou")
        mc2:setScale(1.2)
        mc2:setPosition(0, 10)
        self._daoyu[i].timeBg:addChild(mc2, 10)
        self._daoyu[i].shalou = mc2
    end

    -- self._suo = false
    self:setHanghaiBg()
    -- -- 菜单
    -- self._isShowMenu = false
    self:setMenu()
    -- self:setMenuStart(1)
    
    self._cloudOpen = true
    self:reflashUI(self._friendMfData)
    self:updatePlayerTimes()
    self:listenReflash("PlayerTodayModel", self.updatePlayerTimes)
end 

function MFFriendView:checkTips()
    local mfModel = self._modelMgr:getModel("MFModel") 
    local dayinfo = self._modelMgr:getModel("PlayerTodayModel"):getData()
    local noticeMap = {
        -- 布阵
        {iconName = "menu.menuList.fourmation",detectFuc = function()
            local formationModel = self._modelMgr:getModel("FormationModel")
            local flag = formationModel:isFormationTeamFullByType(formationModel.kFormationTypeMFDef)
            return not flag 
        end},
        -- 好友
        {iconName = "menu.menuList.friend",detectFuc = function()
            local flag = false
            if dayinfo["day26"] < tab:Setting("G_MF_HELP_NUM").value then
                if mfModel:isHelpFriend() then
                    flag = true
                end
            end
            return flag 
        end},
    }

    -- 红点处理
    for k,v in pairs(noticeMap) do
        local hint = false
        if v.detectFuc then
            hint = v.detectFuc()
        end
        self:setHintTip(v.iconName, hint)
    end
end

function MFFriendView:setHintTip(btnName, hint)
    local btnName = self:getUI(btnName)
    if not btnName then
        return
    end
    if btnName then
        btnNameTip = btnName:getChildByName("btnNameTip")
        if btnNameTip then
            btnNameTip:setVisible(hint)
        else
            btnNameTip = cc.Sprite:createWithSpriteFrameName("globalImageUI_bag_keyihecheng.png")
            btnNameTip:setName("btnNameTip")
            btnNameTip:setAnchorPoint(cc.p(0,0))
            btnNameTip:setPosition(cc.p(btnName:getContentSize().width - 26, btnName:getContentSize().height*0.5 + 17))
            btnName:addChild(btnNameTip, 10)
            btnNameTip:setVisible(hint)
        end
    end
end
function MFFriendView:setMenu()
    -- local menu1 = self:getUI("menu.menu1")
    -- menu1:setScaleAnim(true)
    local menu2 = self:getUI("menu.menuList.menu2")
    menu2:setScaleAnim(true)
    
    self:registerClickEvent(menu2, function()
        self:setMenuStart()
    end)

    local fourmation = self:getUI("menu.menuList.fourmation")
    fourmation:setScaleAnim(true)
    local friend = self:getUI("menu.menuList.friend")
    friend:setScaleAnim(true)
    local log = self:getUI("menu.menuList.log")
    log:setScaleAnim(true)
    fourmation:setCascadeOpacityEnabled(true)
    friend:setCascadeOpacityEnabled(true)
    log:setCascadeOpacityEnabled(true)
    local lab = self:getUI("menu.menuList.fourmation.lab")
    lab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    lab:setFontName(UIUtils.ttfName)
    local lab = self:getUI("menu.menuList.friend.lab")
    lab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    lab:setFontName(UIUtils.ttfName)
    local lab = self:getUI("menu.menuList.log.lab")
    lab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    lab:setFontName(UIUtils.ttfName)
    self:registerClickEvent(fourmation, function()
        print("布阵防守阵容")
        self._viewMgr:showView("formation.NewFormationView", {
            formationType = self._modelMgr:getModel("FormationModel").kFormationTypeMFDef,
        })
        -- self:setMenuStart()
        -- self._viewMgr:showView("MF.", params, forceSync)
    end)
    self:registerClickEvent(friend, function()
        print("好友帮助")
        local param = {checkTipCallback = function()
            self:checkTips()
        end, callback = function(data)
            -- dump(data, "data ===")
            self._cloudOpen = true
            self._userId = data.userid
            self._userdata = data.userdata
            self:reflashUI(data["tasks"])
            self:checkTips()
        end}
        self._viewMgr:showDialog("MF.MFFriendDialog", param)
    end)
    self:registerClickEvent(log, function()
        print("战报")
        self._serverMgr:sendMsg("MFServer", "getReportList", {}, true, {}, function (result)
            self._viewMgr:showDialog("MF.MFTaskLogDialog", {list = result.list})
        end)
        -- self._viewMgr:showDialog("MF.MFTaskLogDialog")
    end)
end

function MFFriendView:setMenuStart(menuType)
    self._isShowMenu = not self._isShowMenu
    local menu1 = self:getUI("menu.menu1")
    local menu2 = self:getUI("menu.menuList.menu2")
    local menuList = self:getUI("menu.menuList")

    local fourmation = self:getUI("menu.menuList.fourmation")
    local friend = self:getUI("menu.menuList.friend")
    local log = self:getUI("menu.menuList.log")

    if self._isShowMenu == true then
        menu2:setFlippedX(not self._isShowMenu)
        local callFunc = cc.CallFunc:create(function()
            fourmation:setVisible(true)
            friend:setVisible(true)
            log:setVisible(true)
        end)
        local seq = cc.Sequence:create(callFunc, cc.EaseBackOut:create(cc.MoveTo:create(0.2, cc.p(205, 21)))) 
        menuList:runAction(seq)
    else
        menu2:setFlippedX(not self._isShowMenu)
        local callFunc = cc.CallFunc:create(function()
            fourmation:setVisible(false)
            friend:setVisible(false)
            log:setVisible(false)
        end)
        local seq = cc.Sequence:create(cc.EaseBackIn:create(cc.MoveTo:create(0.1, cc.p(-75, 21))), callFunc)
        menuList:runAction(seq)
    end
end

function MFFriendView:onTop()
    self:checkTips()
end

function MFFriendView:updateButton(inView)
    if inView.click == 1 then
        self._viewMgr:showTip(lang("MF_HELP1"))
    elseif inView.click == 2 then
        -- self._viewMgr:showTip("帮助好友")
        self:helpGameFriendMF(inView)
    elseif inView.click == 3 then
        self._viewMgr:showTip("岛屿暂未开启")
    elseif inView.click == 4 then -- 帮助过
        self._viewMgr:showTip(lang("MF_HELP2"))
    elseif inView.click == 5 then -- 没有帮助次数
        self._viewMgr:showTip(lang("MF_HELP3"))
    elseif inView.click == 6 then -- 任务进行中，玩家没有帮助过，但已经达到任务帮助上限时的情况
        self._viewMgr:showTip(lang("MF_HELP4"))
    elseif inView.click == 7 then -- 岛屿没有任务的情况
        -- self:helpAnim(1)
        self._viewMgr:showTip(lang("MF_HELP7"))
    elseif inView.click == 8 then -- 岛屿任务已完成的
        self._viewMgr:showTip(lang("MF_HELP8"))
    end
end

function MFFriendView:helpGameFriendMF(inView)
    self._serverMgr:sendMsg("MFServer", "helpGameFriendMF", inView.data, true, {}, function (result)
        dump(result, "result ======", 10)
        -- 
        self._friendMfData[tostring(inView.data.id)].finishTime = self._friendMfData[tostring(inView.data.id)].finishTime - tab:Setting("G_MF_SPEED").value*60
        -- self._friendMfData[tostring(inView.data.id)].finishTime = self._friendMfData[tostring(inView.data.id)].finishTime - tab:Setting("G_MF_SPEED").value*60
        -- self:reflashUI(self._friendMfData)
        self:helpFriendAnim(inView.data.id, result.reward)
        local cityTab = tab:MfOpen(inView.data.id)
        self:updateDaoyu(cityTab, inView.data.id)
        inView.click = 4
    end, function(errorId)
        if tonumber(errorId) == 2616 then
            self._viewMgr:showTip(lang("MF_HELP3"))
        elseif tonumber(errorId) == 2617 then
            self._viewMgr:showTip(lang("MF_HELP4"))
        elseif tonumber(errorId) == 2622 then
            self._viewMgr:showTip(lang("MF_TIPS_DES3"))
        elseif tonumber(errorId) == 2624 then
            self._viewMgr:showTip(lang("MF_HELP1"))
        end
    end)
end

function MFFriendView:helpFriendAnim(index, reward)
    self._viewMgr:lock(-1)
    audioMgr:playSound("mf_jiasu")
    -- self._daoyu[index].helpanim:stopAllActions()
    local daoyuBg = self:getUI("bg.daoyuBg")
    local jiasu1 = mcMgr:createViewMC("xinbao_bangzhucaihong", false, true, function()
        self._viewMgr:unlock()
        if reward then reward.notPop = true end
        DialogUtils.showGiftGet(reward)
    end)
    jiasu1:setPosition(cc.p(self._daoyu[index]:getContentSize().width*0.5, self._daoyu[index]:getContentSize().height*0.5+20))
    self._daoyu[index]:addChild(jiasu1)


    local playerTimesData = self._modelMgr:getModel("PlayerTodayModel"):getData()
    local temphelptime = self:getUI("helptimeBg.helptime" .. (6-playerTimesData["day26"]))
    local helptime = ccui.ImageView:create()
    helptime:loadTexture("mf_helpTimes1.png", 1)
    helptime:setPosition(cc.p(temphelptime:getPositionX(), temphelptime:getPositionY()))
    temphelptime:getParent():addChild(helptime)
    helptime:runAction(cc.Sequence:create(cc.Spawn:create(cc.MoveBy:create(0.3, cc.p(0, 60)), cc.FadeOut:create(1)), cc.RemoveSelf:create(true)))

    self:touchPiaoExp(index)

    -- local mc2 = mcMgr:createViewMC("yanhua_mfhanghaifengweitexiao", false, true, function()
    -- end)
    -- mc2:setPosition(self._daoyu[index]:getContentSize().width*0.5, self._daoyu[index]:getContentSize().height*0.5+80)
    -- self._daoyu[index]:addChild(mc2)
    if self._daoyu[index].helpanim then
        -- self._daoyu[index].helpanim:setOpacity(0)
        self._daoyu[index].helpanim:setVisible(false)
    end

end

function MFFriendView:touchPiaoExp(index)
    local expBar = self._daoyu[index].timerLab
    local str = "-" .. tab:Setting("G_MF_SPEED").value .. "分钟"
    local expLab = cc.Label:createWithTTF(str, UIUtils.ttfName, 18)
    expLab:setName("expLabLab")
    expLab:setColor(cc.c3b(0,255,30))
    expLab:enableOutline(cc.c4b(60,30,10,255), 2)
    expLab:setPosition(cc.p(expBar:getContentSize().width/2+10,0))
    expBar:addChild(expLab,1000)
    expLab:setOpacity(0)
    local moveExp = cc.MoveBy:create(0.2, cc.p(0,5))
    local fadeExp = cc.FadeOut:create(0.2)
    local spawnExp = cc.Spawn:create(moveExp,fadeExp)
    local spawnExp0 = cc.Spawn:create(cc.MoveBy:create(0.1, cc.p(0,40)),cc.FadeIn:create(0.1))
    local callFunc = cc.CallFunc:create(function()
        expLab:removeFromParent()
    end)
    local seqExp = cc.Sequence:create(spawnExp0, cc.MoveBy:create(0.4, cc.p(0,20)), spawnExp,callFunc)
    expLab:runAction(seqExp)
end


function MFFriendView:tempText(data)
    for k,v in pairs(data:getChildren()) do
        print("tempFun1 ===", k, v, v:getName())
        self:tempText(v)
    end
end

function MFFriendView:reflashUI(data)
    if self._cloudOpen == true then
        audioMgr:playSound("mf_qiehuanyun")
        local beijing = mcMgr:createViewMC("yunqiehuan1_mfqiehuanyun", false, true, function()

        end)
        beijing:setAnchorPoint(cc.p(0.5,0.5))
        beijing:setPosition(cc.p(MAX_SCREEN_WIDTH*0.5, MAX_SCREEN_HEIGHT*0.5))
        self:addChild(beijing)

        beijing:addCallbackAtFrame(8, function()
            local scrollView = self:getUI("bg.scrollView")
            if self._posJump < 3 then
                scrollView:jumpToBottomRight()
            elseif self._posJump >=3 and self._posJump < 6 then
                scrollView:jumpToBottomLeft()
            end
        end)
        self._cloudOpen = false
    end

    self._friendMfData = data
    -- self._suo = false
    -- local tasks = self._modelMgr:getModel("MFModel"):getTasks()
    local currentTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
    local userData = self._modelMgr:getModel("UserModel"):getData()
    -- dump(tasks)
    local mfCityNum = table.nums(self._friendMfData)
    dump(self._friendMfData)
    for i=1,8 do
        if i <= mfCityNum then
            local cityTab = tab:MfOpen(i)

            self:updateDaoyu(cityTab, i)

            self._daoyu[i].cloud1:setVisible(false)
            self._daoyu[i].titleBg:setVisible(false)
            

            if not self._friendMfData[tostring(i)].finishTime then
                print("任务未开始" , "不可帮助")
                self._daoyu[i].click = 7
            elseif self._friendMfData[tostring(i)].finishTime then                
                if self._friendMfData[tostring(i)].finishTime <= currentTime then
                    print("任务已完成" , "不可帮助")
                    self._daoyu[i].click = 8
                elseif self._friendMfData[tostring(i)].helper and self._friendMfData[tostring(i)].th then
                    print("split=======", self._friendMfData[tostring(i)].th)
                    local th = string.split(self._friendMfData[tostring(i)].th, ",")
                    local flag = 0 -- 没帮助过
                    for k,v in pairs(th) do
                        if userData._id == v then
                            flag = 1 -- 帮助过 
                        end
                    end
                    if table.nums(th) == tab:Setting("G_MF_HELP").value then
                        self._daoyu[i].click = 6
                    elseif flag == 0 then
                        self._daoyu[i].click = 2
                        self._daoyu[i].data = {fid = self._userId, id = i}
                        -- self._daoyu[i].titleBg:setVisible(true)
                        self:helpAnim(i)
                    else
                        self._daoyu[i].click = 4
                    end
                else
                    self._daoyu[i].click = 2
                    self._daoyu[i].data = {fid = self._userId, id = i}
                    print("没帮助过")
                    -- self._daoyu[i].titleBg:setVisible(true)
                    self:helpAnim(i)
                end
            end
        else
            self._daoyu[i].titleBg:setVisible(false)
            self._daoyu[i].timeBg:setVisible(false)
            self._daoyu[i].cloud1:setVisible(true)
            self:updateDaoyuUI(i)
            self._daoyu[i].click = 3
        end
    end

    -- if self._firstJump == false then
    --     local scrollView = self:getUI("bg.scrollView")
    --     scrollView:jumpToBottomRight()
    --     self._firstJump = true
    -- end

    local title = self:getUI("titleBg.title")
    title:setString(self._userdata.name)
end 


function MFFriendView:updateDaoyuUI(index)
    if self._daoyu[index].animTeamIcon then
        self._daoyu[index].animTeamIcon:setVisible(false)
    end
    if self._daoyu[index].renwuStart then
        self._daoyu[index].renwuStart:setVisible(false)
    end
    if self._daoyu[index].stop then
        self._daoyu[index].stop:setVisible(false)
    end
    if self._daoyu[index].helpanim then
        self._daoyu[index].helpanim:setVisible(false)
    end
end

function MFFriendView:helpAnim(index)
    if self._posJump > index then
        self._posJump = index
    end
    if self._daoyu[index].helpanim then
        self._daoyu[index].helpanim:setVisible(true)
        self._daoyu[index].helpanim:setOpacity(0)
    else
        local jiasu = cc.Sprite:createWithSpriteFrameName("mf_helpTimes1.png")
        jiasu:setPosition(cc.p(self._daoyu[index]:getContentSize().width*0.5, 0))
        -- jiasu:setPosition(cc.p(self._daoyu[index]:getContentSize().width*0.5, self._daoyu[index]:getContentSize().height*0.5))
        self._daoyu[index]:addChild(jiasu,3) 
        jiasu:setOpacity(0)
        jiasu:setScale(1.5)
        self._daoyu[index].helpanim = jiasu
    end
    if self._daoyu[index].helpanim then
        self._daoyu[index].helpanim:stopAllActions()
        local posx = self._daoyu[index]:getContentSize().width*0.5
        local posy = self._daoyu[index]:getContentSize().height*0.5
        -- local repeatSeq = cc.RepeatForever:create(cc.Sequence:create(cc.MoveBy:create(1, cc.p(0, 20)), cc.MoveBy:create(1, cc.p(0, -20))))
        local seq = cc.Sequence:create(cc.ScaleTo:create(0, 0), cc.FadeOut:create(0), cc.MoveTo:create(0.1, cc.p(posx, 0)), cc.Spawn:create(
            cc.MoveTo:create(0.5, cc.p(posx, posy)), 
            cc.FadeIn:create(0.5),
            cc.ScaleTo:create(0.5, 1.5)
            ), cc.CallFunc:create(function()
                self._daoyu[index].helpanim:stopAllActions()
                local repeatSeq = cc.RepeatForever:create(cc.Sequence:create(cc.MoveBy:create(1, cc.p(0, 20)), cc.MoveBy:create(1, cc.p(0, -20))))
                self._daoyu[index].helpanim:runAction(repeatSeq)
            end)
        )
        self._daoyu[index].helpanim:runAction(seq)
    end
    if self._daoyu[index].renwuStart then
        self._daoyu[index].renwuStart:setVisible(false)
    end
end

function MFFriendView:updatePlayerTimes()
    local playerTimesData = self._modelMgr:getModel("PlayerTodayModel"):getData()
    for i=1,5 do
        local helptime = self:getUI("helptimeBg.helptime" .. i)
        if helptime then
            if i <= (5-playerTimesData["day26"]) then
                helptime:loadTexture("mf_helpTimes1.png", 1)
            else
                helptime:loadTexture("mf_helpTimes2.png", 1)
            end
        end
    end

    self:checkTips()
end

-- 更新岛屿
function MFFriendView:updateDaoyu(cityTab, index)
    self:updateDaoyuUI(index)
    local tasks = self._modelMgr:getModel("MFModel"):getTasks()
    local currentTime = self._modelMgr:getModel("UserModel"):getCurServerTime()
    local userlvl = self._modelMgr:getModel("UserModel"):getData().lvl

    -- self._daoyu[index].titleBg:setVisible(false)
    local tempTask = self._friendMfData[tostring(index)]
    local taskTab = tab:MfTask(tempTask.taskId)

    -- 设置星星
    -- local starBg = self._daoyu[index].starBg
    -- local x = (starBg:getContentSize().width - taskTab.star*48*1)*0.5
    -- for i=1,5 do
    --     local iconStar = starBg:getChildByName("star" .. i)
    --     if i <= taskTab.star then
    --         if iconStar == nil then
    --             iconStar = cc.Sprite:createWithSpriteFrameName("globalImageUI6_star1.png")
    --             iconStar:setScale(1)
    --             iconStar:setAnchorPoint(cc.p(0, 1))
    --             starBg:addChild(iconStar,3) 
    --             iconStar:setName("star" .. i)
    --         else
    --             iconStar:setVisible(true)
    --         end
    --         iconStar:setPosition(x, starBg:getContentSize().height-10)
    --         x = x + iconStar:getContentSize().width*iconStar:getScaleX()
    --     else
    --         if iconStar then
    --             iconStar:setVisible(false)
    --         end
    --     end
    -- end
    -- local title = self:getUI("bg.titleBg.title")
    self._daoyu[index].title:setString(lang(taskTab.name))

    if self._daoyu[index].timerLab then
        self._daoyu[index].timerLab:stopAllActions()
    end

    -- 处理任务开始以后
    if tempTask["finishTime"] then
        self._daoyu[index].timeBg:setVisible(true)
        local tempTime = tempTask["finishTime"]
        tempTime = tempTime - currentTime
        if tempTime > 0 then
            if self._daoyu[index].timerLab then
                self._daoyu[index].timerLab:runAction(cc.RepeatForever:create(
                    cc.Sequence:create(cc.CallFunc:create(function()
                        tempTime = tempTime - 1
                        local tempValue = tempTime
                        local hour, minute, second
                        hour = math.floor(tempValue/3600)
                        tempValue = tempValue - hour*3600
                        minute = math.floor(tempValue/60)
                        tempValue = tempValue - minute*60
                        second = math.fmod(tempValue, 60)
                        local showTime = string.format("%.2d:%.2d:%.2d", hour, minute, second)
                        if tempTime <= 0 then
                            showTime = "00:00:00"
                            self._daoyu[index].timerLab:stopAllActions()
                            self._daoyu[index].timerLab:setString(showTime)
                            self._daoyu[index].timeBar:setScaleX(1)
                            self._daoyu[index].click = 1
                            self:updateDaoyu(cityTab, index)
                            return
                        end
                        if self._daoyu[index].timerLab then
                            self._daoyu[index].timerLab:setString(showTime)
                        end
                        if self._daoyu[index].timeBar then
                            local str = math.ceil(((3600*taskTab.time-tempTime)/(3600*taskTab.time))*100)/100
                            if str < 0 then
                                str = 0
                            end
                            self._daoyu[index].timeBar:setScaleX(str)
                        end
                    end), cc.DelayTime:create(1))
                ))
            end
        end

        if (currentTime - tempTask["finishTime"]) >= 0 then
            -- self._daoyu[index].daoyu:setBrightness(40)
            if self._daoyu[index].stop then
                self._daoyu[index].stop:removeFromParent()
                self._daoyu[index].stop = nil
            end
            if taskTab["icon"] then
                -- local sysTeam = tab:Team(taskTab["icon"])
                -- if self._daoyu[index].animTeamIcon then
                --     IconUtils:updateSysTeamIconByView(self._daoyu[index].animTeamIcon, {sysTeamData = sysTeam,isGray = false ,eventStyle = 0, star = false})
                -- else
                --     local animTeamIcon = IconUtils:createSysTeamIconById({sysTeamData = sysTeam,isGray = false ,eventStyle = 0, star = false})
                --     animTeamIcon:setName("animTeamIcon")
                --     animTeamIcon:setAnchorPoint(cc.p(0.5, 0.5))
                --     -- animTeamIcon:setScale(1.11)
                --     animTeamIcon:setPosition(cc.p(self._daoyu[index]:getContentSize().width*0.5, self._daoyu[index]:getContentSize().height*0.5-20))
                --     self._daoyu[index]:addChild(animTeamIcon, 99)
                --     animTeamIcon:setScale(0.5)
                --     animTeamIcon:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.MoveBy:create(1, cc.p(0, 10)), cc.MoveBy:create(1, cc.p(0, -10)))))
                --     self._daoyu[index].animTeamIcon = animTeamIcon
                -- end
                -- self._daoyu[index].animTeamIcon:setVisible(true)
                local stop = mcMgr:createViewMC("stop_bangzhucaihong", true, false)
                stop:setName("stop")
                stop:setPosition(cc.p(self._daoyu[index]:getContentSize().width*0.5, self._daoyu[index]:getContentSize().height*0.5-20))
                self._daoyu[index]:addChild(stop, 99)
                self._daoyu[index].stop = stop
            else
                local stop = mcMgr:createViewMC("stop2_bangzhucaihong", true, false)
                stop:setName("stop")
                stop:setPosition(cc.p(self._daoyu[index]:getContentSize().width*0.5, self._daoyu[index]:getContentSize().height*0.5-20))
                self._daoyu[index]:addChild(stop, 99)
                self._daoyu[index].stop = stop
            end

            if self._daoyu[index].renwuStart then
                self._daoyu[index].renwuStart:removeFromParent()
                self._daoyu[index].renwuStart = nil
            end
            if self._daoyu[index].jindutiao then
                self._daoyu[index].jindutiao:setVisible(false)
            end
            if self._daoyu[index].timeBg then
                self._daoyu[index].timeBg:setVisible(false)
            end
            print("领取状态" .. index)
        else
            if self._daoyu[index].renwuStart then
                self._daoyu[index].renwuStart:removeFromParent()
                self._daoyu[index].renwuStart = nil
            end
            local pos = tab:MfOpen(index)["cameracature"]
            local daoyuPos = taskTab["cameracatureCo"]
            self._daoyu[index].renwuStart = mcMgr:createViewMC(taskTab["cameracature"], true, false)
            local sca = pos[daoyuPos][3]
            self._daoyu[index].renwuStart:setPosition(cc.p(pos[daoyuPos][1]*sca, pos[daoyuPos][2]*sca))
            self._daoyu[index].renwuStart:setScale(sca)
            self._daoyu[index]:addChild(self._daoyu[index].renwuStart)

            if taskTab["icon"] then
                if self._daoyu[index].animTeamIcon then
                    self._daoyu[index].animTeamIcon:setVisible(false)
                end
            else
                local stop = self._daoyu[index]:getChildByFullName("stop")
                if stop then
                    stop:setVisible(false)
                end
            end

            -- if self._daoyu[index].kelingqu then
            --     self._daoyu[index].kelingqu:setVisible(false)
            -- end

            print("任务进行中" .. index)
        end
    else
        if self._daoyu[index].animTeamIcon then
            self._daoyu[index].animTeamIcon:setVisible(false)
        end
        if self._daoyu[index].renwuStart then
            self._daoyu[index].renwuStart:setVisible(false)
        end

        
        local stop = self._daoyu[index]:getChildByFullName("stop")
        if stop then
            stop:setVisible(false)
        end
        self._daoyu[index].timeBg:setVisible(false)
        print("任务未开始" .. index)
    end
end

-- function MFFriendView:setNavigation()
--     self._viewMgr:showNavigation("global.UserInfoView",{hideHead=true,hideInfo=true})
-- end

function MFFriendView:setNoticeBar()
    self._viewMgr:hideNotice(true)
end

-- mf 背景动画 
function MFFriendView:setHanghaiBg()
    local bg = self:getUI("bg")
    local layer = self:getUI("bg.scrollView.layer")

    -- 旋涡
    local mc2 = mcMgr:createViewMC("xuanwo_mfhanghaifengweitexiao", true, false)
    mc2:setName("xuanwo") 
    mc2:setScale(1)
    mc2:setPosition(677, 610)
    layer:addChild(mc2, -1)

    -- 背景
    -- local mc3 = mcMgr:createViewMC("haimian_mfhanghaifengweitexiao", true, false)
    -- mc3:setName("haimian")
    -- mc3:setScale(1.5)
    -- mc3:setPosition(480, 320)
    -- bg:addChild(mc3, -1)

    -- 云鸟
    local mc4 = mcMgr:createViewMC("yunniao_mfhanghaifengweitexiao", true, false)
    mc4:setName("yunniao")
    mc4:setPosition(480, 380)
    layer:addChild(mc4, 99)
end

function MFFriendView:createShalou(index)
    local mc3 = mcMgr:createViewMC("shalou_mfhanghaifengweitexiao", true, false)
    mc3:setName("shalou")
    mc3:setScale(1.5)
    mc3:setPosition(0, 0)
    bg:addChild(mc3, -1)
    return shalou
end

function MFFriendView:createTitle(x, y, index, inView)
    local titleBg = ccui.ImageView:create()
    titleBg:loadTexture("daoyubg_mf.png", 1)
    titleBg:setAnchorPoint(cc.p(0.5, 0.5))
    titleBg:setPosition(cc.p(inView:getContentSize().width*0.5+x, inView:getContentSize().height*0.5+y))
    titleBg:setScale(0.5)
    titleBg:setName("titleBg")
    inView:addChild(titleBg, 200)

    local title =  cc.Label:createWithTTF(lang("MF_ISLANDS_" .. index), UIUtils.ttfName, 20)
    title:setAnchorPoint(cc.p(0.5, 0.5))
    title:setPosition(cc.p(inView:getContentSize().width*0.5+x, inView:getContentSize().height*0.5+y+7))
    title:setColor(cc.c3b(255, 255, 255))
    title:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    title:setName("title")
    inView:addChild(title, 500) -- 4

    return titleBg
end

function MFFriendView:createDaoyu(x, y, index)
    local layer = self:getUI("bg.scrollView.layer")
    local daoyu = ccui.ImageView:create()
    daoyu:loadTexture("mf_btnbefore" .. index .. ".png", 1)
    daoyu:setAnchorPoint(cc.p(0.5, 0.5))
    daoyu:setPosition(cc.p(x, y))
    daoyu:setVisible(false)
    daoyu:setScale(2)
    daoyu:setName("daoyu")
    layer:addChild(daoyu, -1)

    local mc3 = mcMgr:createViewMC("haidao" .. index .."_mfhanghaifengweitexiao", true, false)
    mc3:setName("anim2")
    mc3:setScale(1)
    mc3:setPosition(x, y)
    mc3:setPlaySpeed(0.5)
    layer:addChild(mc3, -1)

    return daoyu
end

function MFFriendView:createCloud(inView, cloudPos, index)
    local layer = self:getUI("bg.scrollView.layer")
    local cloud1 = ccui.ImageView:create()
    cloud1:loadTexture("mf_cloud" .. index .. ".png", 1)
    cloud1:setAnchorPoint(cc.p(0.5, 0.5))
    cloud1:setPosition(cc.p(cloudPos[1], cloudPos[2]))
    cloud1:setScale(2)
    cloud1:setName("cloud1")
    layer:addChild(cloud1, 100)

    return cloud1 
end

function MFFriendView:createSuo(inView, x, y, index)
    local layer = self:getUI("bg.scrollView.layer")
    local suo = ccui.ImageView:create()
    suo:loadTexture("pokeImage_suo.png", 1)
    suo:setAnchorPoint(cc.p(0.5, 0.5))
    suo:setPosition(cc.p(x-80, y))
    suo:setName("suo")
    layer:addChild(suo, 1000)

    local levelLab = cc.Label:createWithTTF("100级解锁", UIUtils.ttfName, 24)
    levelLab:setAnchorPoint(cc.p(0, 0.5))
    levelLab:setPosition(suo:getContentSize().width*0.5 + 20, suo:getContentSize().height*0.5)
    levelLab:setColor(cc.c3b(255, 255, 255))
    levelLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    levelLab:setName("levelLab")
    suo:addChild(levelLab) -- 4

    return suo, levelLab
end

return MFFriendView