--[[
    Filename:    DialogUtils.lua
    Author:      <wangguojun@playcrab.com>
    Datetime:    2015-10-20 15:10:12
    Description: File description
--]]

local DialogUtils = {}

local viewMgr

local iconMap = clone(IconUtils.resImgMap)
iconMap.guildCoin = "globalImageUI_littleallied.png"
iconMap.gem = "globalImageUI_littleDiamond.png"
-- {
--     gold = "globalImageUI_gold1.png",
--     gem = "globalImageUI_diamond.png",
--     currency = "globalImage_jingjibi.png",
--     crusading = "golbalIamgeUI5_yuanzhengbi.png"
-- }
function DialogUtils.init()
    if DialogUtils._init then return end
    DialogUtils._init = true
    DialogUtils._currentHintView = nil
end
--[[
    view:包含tip的view
    data = {
        tipType = (1:道具tip, 2:类似英雄专精这种有titile的描述， 3:仅有描述)
        des = 描述,当tipType为1的时候可以不传
        id = 当tipType为1或者2的时候，道具或者专精等的id
    }
]]
function DialogUtils.showHintView(view, data)
    DialogUtils.init()
    if not view then return end
    DialogUtils._currentHintView = view
    return view:showHintView("global.GlobalTipView", data)
end

function DialogUtils.closeHintView()
    DialogUtils.init()
    view = DialogUtils._currentHintView
    if not view then return end
    return view:closeHintView()
end

-- 弹出是否 花费XX购买 YY
function DialogUtils.showBuyDialog(param) -- costType,costNum,callback1,callback2 
	local costType = param.costType or "gem"
	local costNum = param.costNum or 0
	local goods = param.goods or "." 
	local callback1 = param.callback1
	local callback2 = param.callback2
    local costImg = iconMap[costType]
print("costType..in dialogutils",costType,costImg)
    if not costImg then
        costImg = iconMap["gem"]
    end

    local descStr 
    if costType == "rmb" then
        descStr = "[color=462800,fontsize=24]是否使用¥[color=3d1f00,fontsize=24]" .. (costNum or 0) 
    .. "[-][-]" .. "[color=462800,fontsize=24]".. goods .."[-]"
    else
        descStr = "[color=462800,fontsize=24]是否使用[pic=" .. costImg  .. "][-][color=3d1f00,fontsize=24]" .. (costNum or 0) 
    .. "[-][-]" .. "[color=462800,fontsize=24]".. goods .."[-]"
    end

    
    -- local offsetY = -5
    -- local rtx = DialogUtils.createRtxLabel( descStr,{width = 370} )
    -- rtx:formatText()
    -- local w,h = rtx:getInnerSize().width,rtx:getInnerSize().height
    -- local descStr2 = "[color=ffffff,fontsize=20]".. goods .."[-]"
    -- local rtx2 = DialogUtils.createRtxLabel( descStr2,{width = 300} )
    -- rtx2:formatText()
    -- local w2,h2 = rtx2:getInnerSize().width,rtx2:getInnerSize().height
    
	-- local descNode = ccui.Layout:create()
 --    descNode:setBackGroundColorType(1)
 --    descNode:setContentSize(cc.size(math.max(w,0),h))
 --    -- descNode:setBackGroundColor(cc.c3b(128, 128, 0))
 --    descNode:setBackGroundColorOpacity(0)
 --    descNode:setAnchorPoint(cc.p(0.5,0.5))
 --    descNode:addChild(rtx)
 --    -- descNode:addChild(rtx2)
	-- rtx:setPosition(cc.p(descNode:getContentSize().width/2,descNode:getContentSize().height/2))
 --    -- rtx2:setPosition(cc.p(descNode:getContentSize().width/2,descNode:getContentSize().height/2-h2/2-5))
 --    UIUtils:alignRichText(rtx,{hAlign = "center"})
    -- UIUtils:alignRichText(rtx2,{hAlign = "center"})
    
	local viewMgr = ViewManager:getInstance()
	return viewMgr:showSelectDialog( descStr, "", callback1, 
        "", callback2)

end

-- 确定弹窗 是否。。。。？
function DialogUtils.showShowSelect(param)
    param = param or {}
    local desc = param.desc or "钻石不够是否进行充值"
    local callback1 = param.callback1
    local callback2 = param.callback2
    local addValue = param.addValue
    local viewMgr = ViewManager:getInstance()
    local node = viewMgr._viewLayer:getChildren()[#viewMgr._viewLayer:getChildren()]
    return node.view:showDialog("global.GlobalSelectDialog", {desc = desc, button1 = param.button1 or "", callback1 = callback1 or function( )
            viewMgr:showView("vip.VipView", {viewType = 0})
        end, 
        button2 = param.button2 or "", callback2 = callback2,titileTip=true, addValue = addValue},true)
end

-- 弹出提示框 钻石不够是否进行充值 
function DialogUtils.showNeedCharge(param)
    param = param or {}
    local desc = param.desc or lang("TIP_GLOBAL_LACK_GEM") or "钻石不足，请前往充值"
    local callback1 = param.callback1 
    -- function( )
    --     if param.callback1 then
    --         param.callback1()
    --     end
    --     local viewMgr = ViewManager:getInstance()
    --     viewMgr:showView("vip.VipView", {viewType = 0})
    -- end
    local callback2 = param.callback2
    local callback3 = param.callback3
    local callback4 = param.callback4
    local button1 = param.button1 or ""
    local button2 = param.button2 or ""
    local title = param.title
    local viewMgr = ViewManager:getInstance()
    local node = viewMgr._viewLayer:getChildren()[#viewMgr._viewLayer:getChildren()]
    return node.view:showDialog("global.GlobalSelectDialog", {desc = desc,title = title, button1 = button1, callback1 = callback1 , 
        button2 = button2, callback2 = callback2, callback3 = callback3, callback4 = callback4, titileTip=true},true)
end

-- 购买 体力金币等资源
function DialogUtils.showBuyRes( param )
    local goalType = param.goalType or "gem"
    local viewMgr = ViewManager:getInstance()
    local userInfoView = viewMgr:getNavigation("global.UserInfoView")
    if userInfoView then
        local buyFunc = userInfoView["buy" .. string.upper(string.sub(goalType,1,1)) .. string.sub(goalType,2,string.len(goalType))]
        if buyFunc then
            buyFunc(userInfoView,param.callback,param)-- 加上self参数
        end
    end
end

-- 购买 体力金币等资源--name, data, forceShow, Async, callback, notPop
function DialogUtils.showGiftGet( param )
    local gifts  = param.gifts or param
    local viewType = param.viewType
    local viewMgr = ViewManager:getInstance()
    local node = viewMgr._viewLayer:getChildren()[#viewMgr._viewLayer:getChildren()]
    local notPop = param.notPop 
    if notPop then
        UIUtils:showFloatItems(gifts,param)
    else
        local isAvatar = false
        local isSkin = false
        if gifts and type(gifts) == "table" and #gifts ~= 0 then
            for k,v in pairs(gifts) do
                if type(v) == "table" then
                    if v[1] == "avatarFrame" or v["type"] == "avatarFrame" 
                        or v[1] == "avatar" or v["type"] == "avatar" then

                        isAvatar = true
                        -- break
                    end
                    if v[1] == "hSkin" or v["type"] == "hSkin"  then 
                        isSkin = true
                    end
                end
            end
        end
        -- 只有一个头像或者头像框需要特殊展示 hgf
        if isAvatar and table.nums(gifts) == 1 then
            DialogUtils.showAvatarFrameGet( {gifts = gifts})
        elseif isSkin and table.nums(gifts) == 1 then
            local skinItemID = gifts[1].typeId or gifts[1][2]
            DialogUtils.showSkinGetDialog({skinId = skinItemID})
        else
            if not viewType then
                return node.view:showDialog("global.GlobalGiftGetDialog", param, true,false,nil,true)
            else
                return node.view:showDialog("global.GlobalGiftGetDialog", param, true)
            end
        end
    end
end

-- 物品获取途径
function DialogUtils.showItemApproach(itemId,callback)
    local viewMgr = ViewManager:getInstance()
    local view = viewMgr:showDialog("bag.DialogAccessTo", {goodsId = itemId,callback=callback}, true)
    return view
end

-- 弹出确认弹窗
function DialogUtils.showOk( param )
    if not param then return end
    if type(param) == "string" then
        local str = param
        param = {}
        param.desc = str
    end
    local viewMgr = ViewManager:getInstance()
    viewMgr:showDialog("global.GlobalOkDialog", {desc = param.desc or "确定？",button = param.button or "确定"}, true)
end

-- 展示卡牌
function DialogUtils.showCard( param )
    local itemId = param.itemId
    local showTeam = param.showTeam
    local changeNum = param.changeNum
    local callback = param.callback
    local viewMgr = ViewManager:getInstance()
    local node = viewMgr._viewLayer:getChildren()[#viewMgr._viewLayer:getChildren()]
    return node.view:showDialog("global.GlobalShowCardDialog", {itemId = itemId,changeNum = changeNum,showTeam = showTeam,callback = callback}, true,false,nil,true)
end

-- 展示怪兽
function DialogUtils.showTeam( param )
    param = param or {}
    param.itemId = 3000+(param.teamId or 1) 
    param.showTeam = true
    DialogUtils.showCard(param)
end

-- 展示兵团英雄立绘
function DialogUtils.showTeamCG( param )
    param = param or {}
    param.isTeam =  true
    local viewMgr = ViewManager:getInstance()
    local node = viewMgr._viewLayer:getChildren()[#viewMgr._viewLayer:getChildren()]
    return node.view:showDialog("global.TeamHeroCGView", param, true,false,nil,true)
end

-- 展示英雄立绘
function DialogUtils.showHeroCG( param )
    param = param or {}
    param.isHero = true
    local viewMgr = ViewManager:getInstance()
    local node = viewMgr._viewLayer:getChildren()[#viewMgr._viewLayer:getChildren()]
    return node.view:showDialog("global.TeamHeroCGView", param, true,false,nil,true)
end

-- 推荐组合弹窗
function DialogUtils.showZuHe( id )
    -- print("==========showZuhe========",id)
    local showZuhe = false
    local heroD = tab:Hero(id)
    local param = {teams = {}}
    local zuhe
    local modelMgr = ModelManager:getInstance()
    local heroModel = modelMgr:getModel("HeroModel")
    local saveLocal = true
    local saveKey = ""
    if heroD and heroD.zuhe then
        local heroData = heroModel:getHeroData(id)
        if heroData then
            dump(heroData,"heroData")
            zuhe = heroD.zuhe 
            -- print("===========heroD.zehe============",heroD.zuhe)
            param.des = heroD.zuhedes
            for k,v in pairs(zuhe) do
                local teamId,needStar = v[1],v[2]
                local saveTempKey = "zuhe_hero_" .. id .. "_team_" .. teamId
                saveLocal = SystemUtils.loadAccountLocalData(saveTempKey)
                -- print("===========-heroData.star-=================",heroData.star,saveLocal,id,teamId)
                if (heroData.star == v[2] or (heroData.star > v[2] and not saveLocal)) and modelMgr:getModel("TeamModel"):getTeamAndIndexById(teamId) then
                    showZuhe = true
                    saveKey = "zuhe_hero_" .. id .. "_team_" .. teamId
                    param.heroId = id 
                    table.insert(param.teams,teamId)
                    param.teamId = teamId
                    local _,changeId = TeamUtils.changeArtForHeroMastery(id,teamId)
                    param.changeId = changeId
                    -- print("=teamId +++++++++heripId,changeId==========",teamId,id,changeId,needStar)
                end
            end 
        end
    else
        local teamD = tab:Team(id)
        if teamD and teamD.zuhe then
            zuhe = teamD.zuhe 
            param.des = teamD.zuhedes
            -- print("===========teamD.zehe============",teamD.zuhe)
            local heroId,heroStar = zuhe[1],zuhe[2]
            local saveTempKey = "zuhe_hero_" .. heroId .. "_team_" .. id
            saveLocal = SystemUtils.loadAccountLocalData(saveTempKey)
            local heroData = heroModel:getHeroData(heroId)
            if heroData and (heroData.star == heroStar or (heroData.star > heroStar and not saveLocal)) then
                showZuhe = true
                saveKey = "zuhe_hero_" .. heroId .. "_team_" .. id
                param.heroId = heroId 
                table.insert(param.teams,id)
            end
            local _,changeId = TeamUtils.changeArtForHeroMastery(heroId,id)
            -- print("=========================",heroId,id,changeId)
            param.teamId = id
            param.changeId = changeId
        end
    end
    if showZuhe then
        if saveKey ~= "" then
            SystemUtils.saveAccountLocalData(saveKey, true)
        end
        if param.heroId and param.teamId then
            ViewManager:getInstance():showDialog("global.DialogTeamRecommandView",param)
        end
    end
end

-- 辅助函数
-- local vAligns = {"top","bottom","center"}
-- local hAligns = {"left","right","center"}
function DialogUtils.createRtxLabel( str,param )
    local w = param.width or 200
    local h = param.height or 40
    local pos = param.pos 
    local rtx = RichTextFactory:create(str,w,h)
    rtx:formatText()
    rtx:setVerticalSpace(7)
    if pos then
        UIUtils:alignRichText(rtx,param)
    end
    -- rtx:setAnchorPoint(cc.p(0,0))
    -- rtx:setPosition(pos)
    rtx:setName("rtx")
    -- node:addChild(rtx)
    return rtx
end

function DialogUtils.showScoreTip( )
    local viewMgr = ViewManager:getInstance()
    viewMgr:showDialog("global.GlobalScoreStatisticsView",{},true)
end

function DialogUtils.showLackRes( param )
    local viewMgr = ViewManager:getInstance()
    viewMgr:showDialog("global.GlobalResApproatchView",param or {},true)
end

-- 购买宝物悬浮界面
function DialogUtils.showTreasureGet( treasureData , treasureCoinNum ,callback)
    local gifts  = treasureData.gifts or treasureData
    
    local viewMgr = ViewManager:getInstance()
    local node = viewMgr._viewLayer:getChildren()[#viewMgr._viewLayer:getChildren()]
   
    return node.view:showDialog("global.GlobalTreasureGetDialog", {gifts = gifts, coinCount = treasureCoinNum,callback = callback}, true,nil,nil,true)

end

-- 获得头像悬浮窗
function DialogUtils.showAvatarFrameGet(param)    
    -- dump(param,"param",4)
    local gifts  = param.gifts or param
    local callBack = param.callBack or nil
    local viewMgr = ViewManager:getInstance()
    local node = viewMgr._viewLayer:getChildren()[#viewMgr._viewLayer:getChildren()]
   
   -- , forceShow, Async, callback, noPop)
    return node.view:showDialog("global.GlobalHeadFrameGetDialog", {gifts = gifts,callBack = callBack}, true)
end

-- 获得皮肤
function DialogUtils.showSkinGetDialog(param)    
    -- dump(param,"param",4)
    local skinId  = param.skinId or nil
    local callBack = param.callBack or nil
    local viewMgr = ViewManager:getInstance()
    local node = viewMgr._viewLayer:getChildren()[#viewMgr._viewLayer:getChildren()]
   
   -- , forceShow, Async, callback, noPop)
    return node.view:showDialog("global.GlobalSkinGetDialog", {skinID = skinId,callBack = callBack}, true)
end

-- 打开兵团圣徽详情
function DialogUtils.showHolyDetailDailog(param)    
    -- dump(param,"param",4)
    local viewMgr = ViewManager:getInstance()
    local node = viewMgr._viewLayer:getChildren()[#viewMgr._viewLayer:getChildren()]

    return node.view:showDialog("team.TeamHolyDetailDialog", param, true)
end
            
function DialogUtils.dtor()
    iconMap = nil
    viewMgr = nil
end


return DialogUtils