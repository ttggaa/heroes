--[[
    @FileName   StarChartsBody.lua
    @Authors    zhangtao
    @Date       2018-03-09 10:18:34
    @Email      <zhangtao@playcrad.com>
    @Description   星体文件
--]]
local StarChartsBody = {}


local ccSprite = cc.Sprite
local ccuiImageView = ccui.ImageView
local ccLabel = cc.Label
local ccuiText = ccui.Text
local ccuiWidget = ccui.Widget
local ccuiLayout = ccui.Layout
local bodyWidth = 90
local bodyHeight = 80


StarChartsBody.starChartsModel = ModelManager:getInstance():getModel("StarChartsModel")

StarChartsBody.TypeNormal = 1
StarChartsBody.TypeMiddle = 2
StarChartsBody.TypeSenior = 3
StarChartsBody.TypeCenter = 4
StarChartsBody.borderImage = 
{
    [0] = {"starCharts_lockN.png","starCharts_lockA.png"},
    [1] = {"starCharts_unLock1N.png","starCharts_unLock1A.png"},
    [2] = {"starCharts_unLock2N.png","starCharts_unLock2A.png"},
    [3] = {"starCharts_unLock3N.png","starCharts_unLock3A.png"},
    [4] = {"starCharts_mainHero.png","starCharts_mainHero.png"},
}

function StarChartsBody:createStarBody(bodyId)
    local bgNode = ccuiWidget:create()
    bgNode:setContentSize(bodyWidth, bodyHeight)

    local borderImageName = StarChartsBody.borderImage[0][1]
    local bodyType = tab.starChartsStars[tonumber(bodyId)]["show_sort"]  --星体显示类型
    local bodySortType = tab.starChartsStars[tonumber(bodyId)]["sort"]   --星体类型
    local isLock = StarChartsBody.starChartsModel:checkOrLock(bodyId)    --是否解锁
    local canActive = false
    local iconImage = tab.starChartsStars[tonumber(bodyId)]["icon"]..".png" or "starCharts_2.png"
    if bodySortType == 3 then
        canActive = StarChartsBody.starChartsModel:checkActiveState(bodyId)
        if not canActive then
            iconImage = "starCharts_lock.png"
        end
    end
    local isAll = tab.starChartsStars[tonumber(bodyId)]["ability_sort"] == StarChartConst.AbilityAllSort or false    --是否是全局
    if isAll then
        borderImageName = StarChartsBody.borderImage[bodyType][2]
    else
        borderImageName = StarChartsBody.borderImage[bodyType][1]
    end
    -- if isLock then
    --     if isAll then
    --         borderImageName = StarChartsBody.borderImage[bodyType][2]
    --     else
    --         borderImageName = StarChartsBody.borderImage[bodyType][1]
    --     end
    -- else
    --     if isAll then
    --         borderImageName = StarChartsBody.borderImage[0][2]
    --     end
    -- end

    -- print("=====borderImageName======"..borderImageName)
    local borderImage = ccuiImageView:create()
    borderImage:setName("borderImage")
    borderImage:loadTexture(borderImageName, 1)
    borderImage:setContentSize(bodyWidth, bodyHeight)
    borderImage:ignoreContentAdaptWithSize(false)
    borderImage:setPosition(borderImage:getContentSize().width/2, borderImage:getContentSize().height/2)
    bgNode.borderImage = borderImage
    bgNode:addChild(borderImage)



    local bodyIcon = ccuiImageView:create()
    bodyIcon:setName("bodyIcon")
    bodyIcon:loadTexture(iconImage, 1)
    bodyIcon:setContentSize(bodyWidth, bodyHeight)
    bodyIcon:ignoreContentAdaptWithSize(false)
    bodyIcon:setPosition(bodyIcon:getContentSize().width/2, bodyIcon:getContentSize().height/2)
    bgNode.bodyIcon = bodyIcon
    borderImage:addChild(bodyIcon)

    --touchBtn
    local touchBtn1 = ccuiImageView:create()
    touchBtn1:loadTexture("globalImageUI6_meiyoutu.png", 1)
    touchBtn1:setCapInsets(cc.rect(1,1,1,1))
    touchBtn1:setContentSize(bodyWidth/2,bodyHeight)
    touchBtn1:setScale9Enabled(true)
    touchBtn1:setPosition(bodyWidth/2,bodyHeight/2)
    bgNode.touchBtn1 = touchBtn1
    touchBtn1:setName("touchBtn")
    bgNode:addChild(touchBtn1)

    local touchBtn2 = touchBtn1:clone()
    touchBtn2:setRotation(60)
    bgNode.touchBtn2 = touchBtn2
    bgNode:addChild(touchBtn2)

    local touchBtn3 = touchBtn1:clone()
    touchBtn3:setRotation(-60)
    bgNode.touchBtn3 = touchBtn3
    bgNode:addChild(touchBtn3)


    local postion = tab.starPosition[tab.starChartsStars[bodyId]["position"]]["position"]
    local name = "bodyName"..postion[1] .."_"..postion[2]
    bgNode:setName(name)

    self:setBodyHue(bodyId,bodyIcon,isLock)


    return bgNode
end

function StarChartsBody:setBodyHue(bodyId,bodyIcon,isLock)
    local colour = tab.starChartsStars[tonumber(bodyId)].colour
    if isLock then
        UIUtils:setGray(bodyIcon,not isLock)
        bodyIcon:setHue(colour[1])
        bodyIcon:setSaturation(colour[2])
        bodyIcon:setBrightness(colour[3])
    else
        bodyIcon:setHue(0)
        bodyIcon:setSaturation(0)
        bodyIcon:setBrightness(0)
        UIUtils:setGray(bodyIcon,not isLock)
    end
    
end

--星体选中图片
function StarChartsBody:createSelectedNode()
    -- local selectImage = ccuiImageView:create()
    -- selectImage:setName("selectImage")
    -- selectImage:loadTexture("starCharts_bodySelected.png", 1)
    -- selectImage:setContentSize(120, 113)
    -- selectImage:ignoreContentAdaptWithSize(false)
    -- selectImage:setPosition(-100,-100)
    -- selectImage:setVisible(false)
    -- return selectImage

    local selectImage = mcMgr:createViewMC("xuanzhong_xingtu", true,false)
    selectImage:setPosition(-100,-100)
    selectImage:setVisible(false)
    return selectImage

end
--分支选中动画
function StarChartsBody:bodyAddAni1(bodyId,bodyNode)
    local mc = mcMgr:createViewMC("dingwei_xingtu", false,true)
    local mcContentSize = bodyNode:getContentSize()
    mc:setAnchorPoint(0.5,0.5)
    -- mc:setPosition(0,0)
    mc:setPosition(mcContentSize.width/2,mcContentSize.height/2)
    bodyNode.ani1 = mc
    bodyNode:addChild(mc,30)

end

--中心星体动画
function StarChartsBody:updateCenterBodyAni(bodyId,bodyNode,isComplete)
    if bodyNode.centerAni ~= nil then
        bodyNode.centerAni:removeFromParentAndCleanup(true)
        bodyNode.centerAni = nil
    end
    local animationName = "chushi1_xingtu1"
    if tonumber(isComplete) == 1 then animationName = "chushi2_xingtu1" end
    local centerAni = mcMgr:createViewMC(animationName, true,false)
    local mcContentSize = bodyNode:getContentSize()
    centerAni:setAnchorPoint(0.5,0.5)
    -- mc:setPosition(0,0)
    centerAni:setPosition(mcContentSize.width/2,mcContentSize.height/2)
    bodyNode.centerAni = centerAni
    bodyNode:addChild(centerAni, -1)
end

function StarChartsBody:addCompletedAni(bodyNode)
    local completedAni = mcMgr:createViewMC("linjinkejihuozhuangtai_xingtu2", true,false)
    local mcContentSize = bodyNode:getContentSize()
    completedAni:setAnchorPoint(0.5,0.5)
    -- mc:setPosition(0,0)
    -- completedAni:setScale(0.6)
    -- completedAni:setOpacity(180)

    completedAni:setPosition(mcContentSize.width/2,mcContentSize.height/2)
    bodyNode.completedAni = completedAni
    bodyNode:addChild(completedAni,40)
end

function StarChartsBody:jieSuo1Ani(bodyNode,callback)
    ViewManager:getInstance():lock()
    local mc = mcMgr:createViewMC("jiesuo1_xingtu", false,true,function()
    end)
    mc:addCallbackAtFrame(5,function( )
        ViewManager:getInstance():unlock()
        if callback then
            callback()
        end
    end)
    local mcContentSize = bodyNode:getContentSize()
    mc:setAnchorPoint(0.5,0.5)
    -- mc:setPosition(0,0)
    mc:setPosition(mcContentSize.width/2,mcContentSize.height/2)
    bodyNode.ani1 = mc
    bodyNode:addChild(mc,40)
end

function StarChartsBody:jieSuo2Ani(bodyNode,callback)
    ViewManager:getInstance():lock()
    local mc = mcMgr:createViewMC("jiesuo2_xingtu", false,true,function()
    end)
    mc:addCallbackAtFrame(15,function( )
        ViewManager:getInstance():unlock()
        if callback then
            callback()
        end
    end)
    local mcContentSize = bodyNode:getContentSize()
    mc:setAnchorPoint(0.5,0.5)
    -- mc:setPosition(0,0)
    mc:setPosition(mcContentSize.width/2,mcContentSize.height/2)
    bodyNode.ani1 = mc
    bodyNode:addChild(mc,40)
end

function StarChartsBody:updateStarBody(bodyId,bodyNode)
    local borderImageName = StarChartsBody.borderImage[0][1]
    print("=========bodyId======="..bodyId)
    local bodyType = tab.starChartsStars[tonumber(bodyId)]["show_sort"]  --星体显示类型
    local isLock = StarChartsBody.starChartsModel:checkOrLock(bodyId)   --是否解锁
    local bodySortType = tab.starChartsStars[tonumber(bodyId)]["sort"]   --星体类型
    local canActive = false
    local iconImage = tab.starChartsStars[tonumber(bodyId)]["icon"]..".png" or "starCharts_2.png"
    if bodySortType == 3 then
        canActive = StarChartsBody.starChartsModel:checkActiveState(bodyId)
        if not canActive then
            iconImage = "starCharts_lock.png"
        end
        bodyNode.bodyIcon:loadTexture(iconImage, 1)
    end
    local isAll = tab.starChartsStars[tonumber(bodyId)]["ability_sort"] == StarChartConst.AbilityAllSort or false    --是否是全局
    if isAll then
        borderImageName = StarChartsBody.borderImage[bodyType][2]
    else
        borderImageName = StarChartsBody.borderImage[bodyType][1]
    end
    -- if isLock then
    --     if isAll then
    --         borderImageName = StarChartsBody.borderImage[bodyType][2]
    --     else
    --         borderImageName = StarChartsBody.borderImage[bodyType][1]
    --     end
    -- else
    --     if isAll then
    --         borderImageName = StarChartsBody.borderImage[0][2]
    --     end
    -- end
    UIUtils:setGray(bodyNode.bodyIcon,not isLock)
    bodyNode.borderImage:loadTexture(borderImageName, 1)

    self:setBodyHue(bodyId,bodyNode.bodyIcon,isLock)
end

return StarChartsBody