--[[
    Filename:    UIUtils.lua
    Author:      <weiwei02@playcrab.com>
    Datetime:    2015-06-13 12:22:26
    Description: File description
--]]
local ALR = pc.PCAsyncLoadRes:getInstance()
local UIUtils = {}

UIUtils.noPic = "static/WhenCannotFindShowThis.png"
-- 默认ttf字体路径
UIUtils.ttfName = cc.FileUtils:getInstance():fullPathForFilename("static/common.ttf")
UIUtils.ttfName_Title = cc.FileUtils:getInstance():fullPathForFilename("static/common.ttf")
UIUtils.ttfName_Number = cc.FileUtils:getInstance():fullPathForFilename("static/common.ttf")

UIUtils.bmfName_red = "asset/fnt/hud_red.fnt"
UIUtils.bmfName_green = "asset/fnt/hud_green.fnt"
UIUtils.bmfName_yellow = "asset/fnt/hud_yellow.fnt"
UIUtils.bmfName_sp = "asset/fnt/hud_sp.fnt"
UIUtils.bmfName_crit = "asset/fnt/hud_crit.fnt"

UIUtils.bmfName_vip = "asset/fnt/font_vip.fnt"
UIUtils.bmfName_zhandouli = "asset/fnt/font_zhandouli.fnt"
UIUtils.bmfName_zhandouli_bianhua = "asset/fnt/font_zhandouli_bianhua.fnt"
UIUtils.bmfName_zhandouli_little = "asset/fnt/font_zhandouli.fnt"
UIUtils.bmfName_team_fight = UIUtils.bmfName_zhandouli--"asset/fnt/font_fight.fnt"
UIUtils.bmfName_teamnum = "asset/fnt/font_teamnum.fnt"
UIUtils.bmfName_paiming = "asset/fnt/font_paiming.fnt"
UIUtils.bmfName_rank = "asset/fnt/font_rank.fnt"

UIUtils.bmfName_gvg = "asset/fnt/font_gvg.fnt"

UIUtils.bmfName_arena_newrecord = "asset/fnt/font_lishixingao.fnt"


UIUtils.bmfName_treasure_rate = "asset/fnt/font_treasureRate.fnt"

UIUtils.bmfName_vip_1 = "asset/fnt/vip.fnt"

UIUtils.bmfName_timecount ="asset/fnt/font_timecount.fnt"

UIUtils.bmfName_hduel_win = "asset/fnt/hDuel_win.fnt"

UIUtils.bmfName_activity = "asset/fnt/font_activity_count_down.fnt"

UIUtils.bmfName_Lottery = "asset/fnt/font_Lottery.fnt"
UIUtils.bmfName_backFlow = "asset/fnt/backFlowFont.fnt"


UIUtils.autoCloseTip = true -- 手离开屏幕前是否自动关闭tip by guojun

UIUtils.colorValueTable = {
    ccColorQuality1 = "FFFFFF",  --白色
    ccColorQuality2 = "27F73A",    --绿色
    ccColorQuality3 = "4BEBFF",   --蓝色
    ccColorQuality4 = "FF78FF",  --紫色
    ccColorQuality5 = "FA921A",   --橙色
    ccColorQuality6 = "CD201E",    --红色
}

UIUtils.colorTable = {
        ccTeamLabTip = cc.c4b(16, 0, 0, 255),
        ccTeamLabValue = cc.c4b(196, 175, 109, 255),
        ccTeamShadowValue = cc.c4b(95, 72, 48, 255),
        ccTeamNum = cc.c4b(222, 200, 142, 255),
        ccTeamNumShadowValue = cc.c4b(107, 84, 42, 255),
        ccTeamRaceNameLab = cc.c4b(254, 249, 207, 255),
        ccTeamRaceDescLab = cc.c4b(120, 83, 31, 255),
        ccTeamRaceSDescLab = cc.c4b(245, 202, 73, 255),

        ccBtnUnlock = cc.c4b(128, 128, 128, 255),
        ccWhite = cc.c4b(255, 255, 255),
        ccWarning = cc.c4b(122, 12, 0, 255),
        ccSystemRed = cc.c4b(255, 0, 0, 255),
        ccColor1 = cc.c4b(255, 249, 208, 255),
        ccColor2 = cc.c4b(217, 140, 50, 255),
        ccColor3 = cc.c4b(96, 53, 10, 255),
        ccColor4 = cc.c4b(40, 22, 0, 255),

        ccColorNew2 = cc.c4b(255, 255, 255, 255),
        ccColorNew3 = cc.c4b(219, 154, 52, 255),
        ccColorNew4 = cc.c4b(41, 136, 171, 255),
        
        ccColorQuality1 = cc.c4b(255,255,255,255),  --白色
        ccColorQuality2 = cc.c4b(39,247,58,255),    --绿色
        ccColorQuality3 = cc.c4b(75,235,255,255),   --蓝色
        ccColorQuality4 = cc.c4b(255,120,255,255),  --紫色
        ccColorQuality5 = cc.c4b(250,146,26,255),   --橙色
        ccColorQuality6 = cc.c4b(205,32,30,255),    --红色

        ccColorQualityOutLine1 = cc.c4b(60,30,10,255),  --白色
        ccColorQualityOutLine2 = cc.c4b(60,30,10,255),  --绿色
        ccColorQualityOutLine3 = cc.c4b(60,30,10,255),  --蓝色
        ccColorQualityOutLine4 = cc.c4b(60,30,10,255),  --紫色
        ccColorQualityOutLine5 = cc.c4b(60,30,10,255),  --橙色
        ccColorQualityOutLine6 = cc.c4b(60,30,10,255),  --红色

        ccUIBaseColor1 = cc.c4b(255,255,255,255),    --白
        ccUIBaseColor2 = cc.c4b(39,247,58,255),      --绿
        ccUIBaseColor3 = cc.c4b(25,123,212,255),     --蓝
        ccUIBaseColor4 = cc.c4b(255,120,255,255),    --紫
        ccUIBaseColor5 = cc.c4b(196,73,4,255),       --橙(强调字色)
        ccUIBaseColor6 = cc.c4b(205,32,30,255),      --红
        ccUIBaseColor7 = cc.c4b(240,240,0,255),      --金
        ccUIBaseColor8 = cc.c4b(120,120,120,255),    --灰

        ccUIBaseColor9 = cc.c4b(28,162,22,255),      --特殊绿(不加描边)

        ccItemNumShadowValue    = cc.c4b(53, 39, 13 , 255),

        titleOutLineColor       = cc.c4b(94,47,0,255),      --title 字体描边色
        subTitleOutLineColor    = cc.c4b(60,30,10,255),
        titleColorRGB           = cc.c4b(255,218,47,255),   --title 字体色 

        ccUIBaseOutlineColor    = cc.c4b(60,30,10,255), --通用描边
        ccUIBaseShadowColor     = cc.c4b(60,30,10,255), --通用阴影

        ccUIBaseDescTextColor1  = cc.c4b(138,92,29,255),  --说明文本色
        
        ccUIBaseTextColor1      = cc.c4b(100,82,82,255),  --浅色文本色
        ccUIBaseTextColor2      = cc.c4b(60,42,30,255),    --深色文本色
        ccUIBasePromptColor     = cc.c4b(250,238,160,255),--提示文字颜色

        ccUIBaseTitleTextColor      = cc.c4b(252,244,197,255),    --标题颜色

        -- 按钮字色
        ccUICommonBtnColor1     = cc.c4b(255,243,229,255),          --文字颜色  橙色/2级橙色按钮 
        ccUICommonBtnOutLine1   = cc.c4b(140, 52, 7, 255),          --文字描边  橙色/2级橙色按钮 
        ccUICommonBtnColor2     = cc.c4b(255,243,229,255),          --文字颜色  蓝色/2级蓝色按钮 
        ccUICommonBtnOutLine2   = cc.c4b(115, 63, 32, 255),          --文字描边  蓝色/2级蓝色按钮 (棕色)
        ccUICommonBtnColor3     = cc.c4b(255, 255, 255, 255),       --文字颜色  小橙色/小蓝色按钮 
        ccUICommonBtnColor4     = cc.c4b(60, 30, 10, 255),          --文字描边  小橙色/小蓝色按钮/其它 
        ccUICommonBtnOutLine5   = cc.c4b(136, 20, 10, 255),         -- 按钮描边 红色强调
        ccUICommonBtnOutLine6   = cc.c4b(85, 38, 10, 255),          -- 按钮描边 悬浮棕色
        ccUICommonBtnOutLine7   = cc.c4b(1, 67, 128, 255),          -- 按钮描边 蓝色按钮

        ccUITabColor1       = cc.c4b(122, 82, 55, 255),       -- 切页浅色
        ccUITabColor2       = cc.c4b(78, 50, 13, 255),        -- 切页深色
        ccUITabColor3       = cc.c4b(240, 201, 146, 255),     -- 魔法书切页亮色
        ccUITabColor4       = cc.c4b(199, 175, 141, 255),     -- 书切页浅色
        ccUITabColor5       = cc.c4b(93, 69, 50, 255),        -- 书切页深色
        ccUIMagicTab1       = cc.c4b(255, 244, 217, 255),     -- 学院切页选中
        ccUIMagicTab2       = cc.c4b(199, 175, 151, 255),     -- 学院切页未选中

        ccUIInputTipColor   = cc.c4b(135, 128, 128, 255),   --输入框提示文字字色
        ccUIMenuBtnColor1   = cc.c4b(255, 250, 220, 255),   --菜单按钮文字渐变色1
        ccUIMenuBtnColor2   = cc.c4b(255, 235, 130, 255),   --菜单按钮文字渐变色2
        ccUITxtColor1       = cc.c4b(251, 244, 236, 255),   --文字渐变色1
        ccUITxtColor2       = cc.c4b(243, 189, 85, 255),    --文字渐变色2

        ccUIUnLockColor = cc.c4b(60, 60, 60, 255),

        -- 英雄法术  火水土气 -- 1234
        ccUIHeroSkillColor1 = cc.c4b(117, 73, 34, 255),        -- 元素
        ccUIHeroSkillColor2 = cc.c4b(178, 46, 47, 255),        -- 火
        ccUIHeroSkillColor3 = cc.c4b(56, 72, 185, 255),        -- 水
        ccUIHeroSkillColor4 = cc.c4b(103, 154, 182, 255),      -- 气
        ccUIHeroSkillColor5 = cc.c4b(115, 145, 13, 255),       -- 土

        -- 三级面板title颜色
        ccTitleColor = cc.c4b(255, 253, 235, 255),  
        ccTitleEnable2Color = cc.c4b(253, 229, 175, 255),
        ccTitleOutlineColor = cc.c4b(168, 69, 3, 255),

        -- 主界面联盟建筑名称字色
        ccBuildNameColor = cc.c4b(255, 248, 210,255)
    }
--[[
    @function createMultiLineLabel
    @desc  创建多行文本标签，程序自动判断是否需要换行
    @param tLabel Table 
    @return  CCLabel
--]]
function UIUtils:createMultiLineLabel(tLabel)
    local tData = {}
    local fontname = tLabel.fontname or UIUtils.ttfName
    local fontsize = tLabel.fontsize or 22
    local color = tLabel.color or ccc3(0x78, 0x25, 0)
    local alignment = tLabel.alignment or cc.TEXT_ALIGNMENT_LEFT
    local anchorPoint = tLabel.anchorPoint or ccp(0, 1)
    local width=tLabel.width or 470
    -- 指定高度，若不指定则由系统计算出实际高度
    local height = tLabel.height or 0
    local cclObj = cc.Label:createWithTTF(tLabel.text, fontname, fontsize)
    local nRealWidth = cclObj:getContentSize().width
    if nRealWidth > width then
        cclObj = cc.Label:createWithTTF(tLabel.text, fontname, fontsize, cc.size(width, height), alignment)
    end
    if tLabel.position then
        cclObj:setPosition(tLabel.position)
    end
    cclObj:setColor(color)
    cclObj:setAnchorPoint(anchorPoint)
    return cclObj
end

--[[
    @function createHorizontalNode
    @desc  创建横向排列node
    @param tLabel Table 
    @return  CCLabel
--]]
function UIUtils:createHorizontalNode( node_table, inAnchorPoint, isNeedHide, inDistance )
    local width = 0
    local height = 0
    local distance = 0
    if inDistance ~= nil then 
        distance = inDistance
    end
    for k,v in pairs(node_table) do
        if k == #node_table then 
            width = width + v:getContentSize().width * v:getScaleX()
        else
            width = width + v:getContentSize().width * v:getScaleX() + distance
        end
        
        if(v:getContentSize().height * v:getScaleY() > height) then
            height = v:getContentSize().height * v:getScaleY()
        end
    end
    if inAnchorPoint == nil then 
        inAnchorPoint = cc.p(0, 0.5)
    end
    local nodeContent = nil 
    if isNeedHide then 
        nodeContent = cc.Sprite:create()
        nodeContent:setCascadeOpacityEnabled(true)
    else
        nodeContent = cc.Node:create()
    end
    
    nodeContent:setContentSize(cc.size(width, height))
    local tempWidth = 0
    for k,v in pairs(node_table) do
        v:setAnchorPoint(inAnchorPoint)
        v:setPosition(tempWidth, inAnchorPoint.y * height)
        nodeContent:addChild(v)
        if k == #node_table then 
            tempWidth = tempWidth + v:getContentSize().width * v:getScaleX()
        else
            tempWidth = tempWidth + v:getContentSize().width * v:getScaleX() + distance
        end
    end
    return nodeContent
end


function UIUtils:alignHorizontalNode(inNode, node_table, inAnchorPoint, isNeedHide, inDistance, ignoreHide )
   local width = 0
    local height = 0
    local distance = 0
    if inDistance ~= nil then 
        distance = inDistance
    end

    if ignoreHide == nil then 
        ignoreHide = true
    end
    for k,v in pairs(node_table) do
        if v:isVisible() == true or allowHide == true then 
            if k == #node_table then 
                width = width + v:getContentSize().width * v:getScaleX()
            else
                width = width + v:getContentSize().width * v:getScaleX() + distance
            end
            
            if(v:getContentSize().height * v:getScaleY() > height) then
                height = v:getContentSize().height * v:getScaleY()
            end
        end
    end
    if inAnchorPoint == nil then 
        inAnchorPoint = cc.p(0, 0.5)
    end
    inNode:setContentSize(cc.size(width, height))
    local tempWidth = 0
    for k,v in pairs(node_table) do
        if v:isVisible() == true or allowHide == true then 
            v:setAnchorPoint(inAnchorPoint)
            v:setPosition(tempWidth, inAnchorPoint.y * height)
            if k == #node_table then 
                tempWidth = tempWidth + v:getContentSize().width * v:getScaleX()
            else
                tempWidth = tempWidth + v:getContentSize().width * v:getScaleX() + distance
            end
        end
    end
end

-- 设置richText 对齐
function  UIUtils:alignRichText(rtx,param)
    param = param or {}
    local hAlign = param.hAlign or "center" -- "left" ,"right"
    local vAlign = param.vAlign or "center" -- "top","bottom"
    local realW,realH = rtx:getRealSize().width,rtx:getRealSize().height
    local w,h = rtx:getInnerSize().width,rtx:getInnerSize().height
    local offsetPos = cc.p(0,0)
    if hAlign == "center" then
        offsetPos.x = (w-realW)/2
    elseif hAlign == "left" then
        offsetPos.x = 0
    elseif hAlign == "right" then
        offsetPos.x = w-realW
    end
    if vAlign == "top" then
        offsetPos.y = (h+realH)/2
    elseif vAlign == "center" then
        offsetPos.y = 0
    elseif vAlign == "bottom" then
        offsetPos.y = (h-realH)/2
    end
    local prePos = cc.p(rtx:getPositionX(),rtx:getPositionY())
    rtx:setPosition(cc.pAdd(prePos,offsetPos))
    return rtx
end

-- 全屏模糊
function UIUtils:getScreenBlurSprite()
    local width = MAX_SCREEN_WIDTH
    local height = MAX_SCREEN_HEIGHT
    local rt1 = cc.RenderTexture:create(width, height, RGBART)--, gl.DEPTH24_STENCIL8_OES)
    rt1:getSprite():getTexture():setAntiAliasTexParameters()
    rt1:begin()
    cc.Director:getInstance():getRunningScene():visit()
    rt1:endToLua()

    local sp = UIUtils:_blur1(rt1)
    sp:setPosition(width * 0.5, height * 0.5)
    return sp
end

-- 节点模糊
function UIUtils:getBlurSprite(node)
    local width = node:getContentSize().width
    local height = node:getContentSize().height
    local rt1 = cc.RenderTexture:create(width, height, RGBART)--, gl.DEPTH24_STENCIL8_OES)
    rt1:getSprite():getTexture():setAntiAliasTexParameters()
    rt1:begin()
    node:visit()
    rt1:endToLua()

    local sp = UIUtils:_blur2(rt1)
    sp:setAnchorPoint(0, 0)
    return sp
end

-- 模糊算法1
function UIUtils:_blur1(rt1)
    local Radius = 2
    local width = rt1:getSprite():getContentSize().width
    local height = rt1:getSprite():getContentSize().height
    local sp1 = cc.Sprite:createWithTexture(rt1:getSprite():getTexture())
    sp1:setPosition(width * 0.5, height * 0.5)
    sp1:setGLProgramState(Shader.getBlur1Shader(width, height, 1, 0, Radius))

    local rt2 = cc.RenderTexture:create(width, height, RGBART)--, gl.DEPTH24_STENCIL8_OES)
    rt2:getSprite():getTexture():setAntiAliasTexParameters()
    rt2:begin()
    sp1:visit()
    rt2:endToLua()

    local sp2 = cc.Sprite:createWithTexture(rt2:getSprite():getTexture())
    sp2:setFlipY(true)
    sp2:setPosition(width * 0.5, height * 0.5)
    sp2:setGLProgramState(Shader.getBlur1Shader(width, height, 0, 1, Radius))

    local rt3 = cc.RenderTexture:create(width, height, RGBART)--, gl.DEPTH24_STENCIL8_OES)
    rt3:getSprite():getTexture():setAntiAliasTexParameters()
    rt3:begin()
    sp2:visit()
    rt3:endToLua()

    local sp = cc.Sprite:createWithTexture(rt3:getSprite():getTexture())
    return sp
end

-- 模糊算法2
function UIUtils:_blur2(rt1)
    local Radius = 3
    local width = rt1:getSprite():getContentSize().width
    local height = rt1:getSprite():getContentSize().height
    local sp1 = cc.Sprite:createWithTexture(rt1:getSprite():getTexture())
    sp1:setPosition(width * 0.5, height * 0.5)
    sp1:setGLProgramState(Shader.getBlur2Shader(width, height, Radius))

    local rt2 = cc.RenderTexture:create(width, height, RGBART)--, gl.DEPTH24_STENCIL8_OES)
    rt2:getSprite():getTexture():setAntiAliasTexParameters()
    rt2:begin()
    sp1:visit()
    rt2:endToLua()

    local sp = cc.Sprite:createWithTexture(rt2:getSprite():getTexture())
    return sp
end

-- 磨砂玻璃效果
-- ui需要玻璃效果的ui
-- bgNode背景节点
-- maskPicName遮罩图片
function UIUtils:generateBlurUI(ui, bgNode, maskPicName)
    local sp = UIUtils:getBlurSprite(bgNode)

    local clipNode = cc.ClippingNode:create()
    clipNode:setInverted(false)
    clipNode:addChild(sp)

    local mask = cc.Sprite:createWithSpriteFrameName(maskPicName)
    if mask == nil then
        cc.Sprite:create(maskPicName)
    end
    mask:setAnchorPoint(0, 0)
    clipNode:setStencil(mask)
    clipNode:setAlphaThreshold(0.05)
    local pt = ui:convertToWorldSpace(cc.p(0, 0))
    sp:setPosition(-pt.x, -pt.y)

    ui:addChild(clipNode, -1)
    sp.schedule = ScheduleMgr:regSchedule(1, self, function(self, dt)
        local pt = ui:convertToWorldSpace(cc.p(0, 0))
        sp:setPosition(-pt.x, -pt.y)
    end)   
    sp:registerScriptHandler(function (state)
        if state == "exit" then
            ScheduleMgr:unregSchedule(sp.schedule)
        end
    end)
end
local fu = cc.FileUtils:getInstance()
local tc = cc.Director:getInstance():getTextureCache()
local sfc = cc.SpriteFrameCache:getInstance()
UIUtils.animPath = "asset/anim/"
UIUtils.animPathEx = "asset/anim/"
UIUtils.uiPathEx = "asset/anim/"
function UIUtils:loadRes(list, callback)
    local sfList = {}
    local function finish()
        -- 由于UI有补丁的形式，需要保证顺序，所以这边异步只加载图片。最后再进行sf分割
        for i = 1, #sfList do
            sfc:addSpriteFrames(sfList[i][1], sfList[i][2])
            -- dump(sfList[i])
        end
        if callback then
            callback()
        end
    end
    local __count = #list
    local __index = 0
    for i = 1, __count do
        local item = list[i]
        if type(item) == "string" then
            if tc:getTextureForKey(item) then
                __index = __index + 1
                if __index >= __count then
                    finish()
                end
            else
                if fu:isFileExist(item) then
                    local task = pc.LoadResTask:createImageTask(item, RGBAUTO)
                    task:setLuaCallBack(function ()
                        ScheduleMgr:delayCall(0, self, function()
                            __index = __index + 1
                           if __index >= __count then
                                finish()
                            end
                        end)
                    end)
                    ALR:addTask(task) 
                else
                    __index = __index + 1
                    if __index >= __count then
                        finish()
                    end
                end
            end
        else
            if tc:getTextureForKey(item[2]) then
                __index = __index + 1
                if __index >= __count then
                    finish()
                end   
            else
                
                if string.find(item[1], "asset/ui") ~= nil then
                    local filename = string.sub(item[2], 10, string.len(item[2]))
                    local plistname = string.sub(item[1], 10, string.len(item[1]))
                    if UI_EX[filename] then
                        local taskex = pc.LoadResTask:createPlistTask(UIUtils.uiPathEx..plistname, UIUtils.uiPathEx..filename, RGBAUTO)
                        taskex:setLuaCallBack(function ()
                            local task
                            sfList[#sfList + 1] = item
                            task = pc.LoadResTask:createImageTask(item[2], RGBAUTO)
                            task:setLuaCallBack(function ()
                                ScheduleMgr:delayCall(0, self, function()
                                __index = __index + 1
                                if __index >= __count then
                                    finish()
                                end    
                                end)
                            end)
                            ALR:addTask(task) 
                        end)
                        ALR:addTask(taskex)
                    else
                        local task
                        sfList[#sfList + 1] = item
                        task = pc.LoadResTask:createImageTask(item[2], RGBAUTO)
                        task:setLuaCallBack(function ()
                            ScheduleMgr:delayCall(0, self, function()
                            __index = __index + 1
                            if __index >= __count then
                                finish()
                            end    
                            end)
                        end)
                        ALR:addTask(task) 
                    end

                else
                    if string.find(item[1], "asset/anim") ~= nil and string.find(item[1], "image.plist") ~= nil then
                        local animjson = string.gsub(item[1], "image.plist", ".animxml.json")
                        local jtask = pc.LoadResTask:createAnimJsonTask(animjson)
                        jtask:setLuaCallBack(function ()
                            ScheduleMgr:delayCall(0, self, function()
                                local filename = string.sub(item[2], 12, string.len(item[2]))
                                local plistname = string.sub(item[1], 12, string.len(item[1]))
                                if MOVIECLIP_EX[filename] then
                                    local taskex
                                    if item[3] then
                                        taskex = pc.LoadResTask:createPlistTask(UIUtils.animPathEx..plistname, UIUtils.animPathEx..filename, item[3])
                                    else
                                        taskex = pc.LoadResTask:createPlistTask(UIUtils.animPathEx..plistname, UIUtils.animPathEx..filename, RGBAUTO)
                                    end
                                    taskex:setLuaCallBack(function ()
                                        if item[3] then
                                            task = pc.LoadResTask:createPlistTask(item[1], item[2], item[3])
                                        else
                                            task = pc.LoadResTask:createPlistTask(item[1], item[2], RGBAUTO)
                                        end
                                        task:setLuaCallBack(function ()
                                            ScheduleMgr:delayCall(0, self, function()
                                                __index = __index + 1
                                                if __index >= __count then
                                                    finish()
                                                end
                                            end)
                                        end)
                                        ALR:addTask(task)
                                    end)
                                    ALR:addTask(taskex)
                                else
                                    if item[3] then
                                        task = pc.LoadResTask:createPlistTask(item[1], item[2], item[3])
                                    else
                                        task = pc.LoadResTask:createPlistTask(item[1], item[2], RGBAUTO)
                                    end
                                    task:setLuaCallBack(function ()
                                        ScheduleMgr:delayCall(0, self, function()
                                            __index = __index + 1
                                            if __index >= __count then
                                                finish()
                                            end
                                        end)
                                    end)
                                    ALR:addTask(task)
                                end
                            end)
                        end)
                        ALR:addTask(jtask) 
                    else
                        if fu:isFileExist(item[1]) then
                            if item[3] then
                                task = pc.LoadResTask:createPlistTask(item[1], item[2], item[3])
                            else
                                task = pc.LoadResTask:createPlistTask(item[1], item[2], RGBAUTO)
                            end
                            task:setLuaCallBack(function ()
                                ScheduleMgr:delayCall(0, self, function()
                                    __index = __index + 1
                                    if __index >= __count then
                                        finish()
                                    end
                                end)
                            end)
                            ALR:addTask(task)
                        else
                            __index = __index + 1
                            if __index >= __count then
                                finish()
                            end
                        end
                    end
                end

            end
        end
    end
end

function UIUtils:aysncLoadRes(list, callback)
    if #list > 0 then
        -- 由于才用多核加载，当同时载入相同的资料会发生错误，所以这里需要过滤一下
        local _list = {}
        local _map = {}
        for i = 1, #list do
            if type(list[i]) == "string" then
                if _map[list[i]] == nil then
                    _list[#_list + 1] = list[i]
                    _map[list[i]] = true
                end
            else
                if _map[list[i][1]] == nil then
                    _list[#_list + 1] = list[i]
                    _map[list[i][1]] = true
                end
            end  
        end
        UIUtils:loadRes(_list, callback)
    else
        if callback then
            callback()
        end
    end
end

--[[
    @function setGoldValueColor
    @desc  金币统一颜色
    @param inView, needValue, userValue
--]]
function UIUtils:setGoldValueColor(inView, needValue, userValue)
    local userValue
    if not model then
        userValue = ModelManager:getInstance():getModel("UserModel"):getData().gold
    end
    if userValue >= needValue then
        inView:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    else
        inView:setColor(UIUtils.colorTable.ccColorQuality6)
    end
end

--[[
    @function adjustTitle
    @desc  统一调整三级面板副标题标题与装饰物.的间距
    @param inView
--]]
function UIUtils:adjustTitle(inView, offset)
    local titleLab = inView:getChildByName("titleLab")
    if titleLab then
        titleLab:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
    end
    local leftAdorn = inView:getChildByName("leftAdorn")
    if leftAdorn ~= nil then
        leftAdorn:setPositionX(titleLab:getPositionX() - titleLab:getContentSize().width * 0.5 - (offset or 10))
    end
    local rightAdorn = inView:getChildByName("rightAdorn")
    if rightAdorn ~= nil then
        rightAdorn:setPositionX(titleLab:getPositionX() + titleLab:getContentSize().width * 0.5 + (offset or 10))
    end
end

-- userData,    类型1，二级三级界面title字色
            --  类型2，globalPanelUI7_subInner2TitleBg 图片上的 title
            --  类型3，globalPanelUI7_subTitleBg2 图片上的 title
            --  类型4，globalPanelUI7_titleBg2 弹窗title，
            --  类型6，卷轴 title字色（eg.邮件详情 规则）

            --  类型7  新版二级Ttitle 26号,字色 252,244,297
            --  font_Title 是否通用字体 默认通用，需要ttfName_Title传0
            --  isShadow 是否带阴影 默认带，不带传0
function UIUtils:setTitleFormat(inView, _type, font_Title, isShadow)
    if not inView then
        return
    end
    if _type == nil then
        _type = 1
    end
    if isShadow == nil then
        isShadow = 0
    end
    if _type == 1 then
        inView:setFontName(UIUtils.ttfName_Title)
        inView:setColor(UIUtils.colorTable.ccUIBaseTitleTextColor)
        inView:setFontSize(28)
        isShadow = 0
    elseif _type == 2 then
        inView:setFontName(UIUtils.ttfName)
        inView:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
        -- inView:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        inView:setFontSize(22)
        isShadow = 0
    elseif _type == 3 then
        inView:setFontName(UIUtils.ttfName)
        inView:setColor(UIUtils.colorTable.ccUIBaseTextColor2)
        -- inView:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        inView:setFontSize(24)
    elseif _type == 4 then
        inView:setFontName(UIUtils.ttfName_Title)
        inView:setColor(UIUtils.colorTable.ccUIBaseColor1)
        inView:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        inView:setFontSize(28)
        isShadow = 0
    elseif _type == 5 then
        inView:setFontName(UIUtils.ttfName_Title)
        inView:setColor(UIUtils.colorTable.ccTitleColor)
        inView:enable2Color(1, UIUtils.colorTable.ccTitleEnable2Color)
        inView:enableOutline(UIUtils.colorTable.ccTitleOutlineColor, 2)    
        inView:setFontSize(34)
    elseif _type == 6 then
        inView:setFontName(UIUtils.ttfName_Title)
        inView:setColor(UIUtils.colorTable.ccUITabColor2)
        inView:setFontSize(28)
        isShadow = 0
    elseif _type == 7 then
        inView:setFontName(UIUtils.ttfName_Title)
        inView:setColor(cc.c4b(252,244,197,255))
        inView:setFontSize(26)
        isShadow = 0
    end

    -- if font_Title and font_Title == 1 then
    --     -- inView:setFontName(UIUtils.ttfName)
    -- end
    -- if isShadow == 1 then
    --     inView:enableShadow(UIUtils.colorTable.ccUIBaseShadowColor, cc.size(0, -2))
    -- end
end

-- 界面是否隐藏vip标志
function UIUtils:isHideVip( hideInfo,typeStr )
    if not hideInfo then return false end
    local typeStrs = {chat = "1",userInfo = "2", guild = "3",friend = "4"}
    local hideIdx = typeStrs[typeStr]
    if hideIdx and hideInfo[hideIdx] then
        return hideInfo[hideIdx] == 1
    end
end

-- _type
-- 1 = "globalButtonUI13_1_1.png" -- 橙色
-- 2 = "globalButtonUI13_3_1.png" -- 蓝色
-- 3 = "globalBtnUI6_btn1_o_n.png" -- 小橙色 
-- 4 = "globalBtnUI6_btn1_b_n.png" -- 小蓝色
function UIUtils:setButtonFormat(inView, _type)
    if not inView then
        return
    end
    if _type == nil then
        _type = 1
    end
    if _type == 1 then
        inView:setTitleFontSize(28) 
        inView:setTitleFontName(UIUtils.ttfName)
        inView:setColor(UIUtils.colorTable.ccUICommonBtnColor1)
        inView:getTitleRenderer():enableOutline(UIUtils.colorTable.ccUICommonBtnOutLine1, 2)
    elseif _type == 2 then
        inView:setTitleFontSize(28) 
        inView:setTitleFontName(UIUtils.ttfName)
        inView:setColor(UIUtils.colorTable.ccUICommonBtnColor2)
        inView:getTitleRenderer():enableOutline(UIUtils.colorTable.ccUICommonBtnOutLine2, 2)
        -- inView:enableShadow(UIUtils.colorTable.ccUIBaseShadowColor, cc.size(0, -2))
    elseif _type == 3 then
        inView:setTitleFontSize(22) 
        inView:setTitleFontName(UIUtils.ttfName)
        inView:setColor(UIUtils.colorTable.ccUICommonBtnColor1)
        inView:getTitleRenderer():enableOutline(UIUtils.colorTable.ccUICommonBtnOutLine1, 2)
    elseif _type == 4 then
        inView:setTitleFontSize(22) 
        inView:setTitleFontName(UIUtils.ttfName)
        inView:setColor(UIUtils.colorTable.ccUICommonBtnColor2)
        inView:getTitleRenderer():enableOutline(UIUtils.colorTable.ccUICommonBtnOutLine2, 2)
        -- inView:setTitleFontSize(22) 
        -- inView:setTitleFontName(UIUtils.ttfName)
        -- inView:setColor(UIUtils.colorTable.ccUICommonBtnColor3)
        -- inView:getTitleRenderer():enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 2)
    elseif _type == 5 then
        inView:setTitleFontSize(22) 
        inView:setTitleFontName(UIUtils.ttfName)
        inView:setColor(UIUtils.colorTable.ccUICommonBtnColor2)
        inView:getTitleRenderer():enableOutline(UIUtils.colorTable.ccUICommonBtnOutLine5, 2)
    elseif _type == 7 then
        inView:setTitleFontSize(18) 
        inView:setTitleFontName(UIUtils.ttfName)
        inView:setColor(UIUtils.colorTable.ccUICommonBtnColor1)
        inView:getTitleRenderer():enableOutline(UIUtils.colorTable.ccUICommonBtnOutLine6, 1)
    end
end


--[[
    @desc 创建一个GIF动画
]]
function UIUtils:createGifNode(fileName)
    if fileName==nil then
        return
    end

    local fullPath = cc.FileUtils:getInstance():fullPathForFilename(fileName)
    if fullPath then
        return CacheGif:create(fullPath)
    end
end

function UIUtils:setGray(node, enable)
    if enable then
        -- node:setBrightness(-10)
        -- node:setContrast(50)
        node:setHue(10)
        node:setSaturation(-80)
    else
        -- node:setBrightness(0)
        -- node:setContrast(0)
        node:setHue(0)
        node:setSaturation(0)
    end
end

function UIUtils:outlineNodeLabel(element)
    if element == nil then
        return 
    end
    local desc = element:getDescription()
    local nameStr = element:getName()
    if desc == "Label" and name ~= "stage" then
        element:setFontName(UIUtils.ttfName)
        element:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
    end
    local count = #element:getChildren()
    for i = 1, count do
        self:outlineNodeLabel(element:getChildren()[i])
    end
end

-- 创建空板子提示的小精灵
function UIUtils:addBlankPrompt( node,param )
    param = param or {}
    local scale = param.scale or 0.8
    local zOrder = param.zOrder or 0
    local x,y = param.x or 0,param.y or 0
    local des = param.des or "暂无"

    if node:getChildByName("jingling") then
        node:getChildByName("jingling"):removeFromParent()
    end

    local _widget = ccui.Widget:create()
    _widget:setName("jingling")
    _widget:setContentSize(node:getContentSize())
    _widget:setAnchorPoint(cc.p(0, 0))
    _widget:setPosition(0, 0)
    node:addChild(_widget)

    spineMgr:createSpine("xinshouyindao", function (spine)
        -- spine:setVisible(false)
        spine.endCallback = function ()
            spine:setAnimation(0, "pingdan", true)
        end 
        local anim = "pingdan"
        spine:setAnimation(0, anim, true)
        spine:setPosition(x, y)
        spine:setScale(scale)
        _widget:addChild(spine,zOrder)
    end)

    local bubble = ccui.ImageView:create()
    bubble:loadTexture("globalPanelUI4_guideTalkBg1.png",1)
    bubble:setScale(scale or 0.8)
    bubble:setScale9Enabled(true)
    bubble:setCapInsets(cc.rect(80,157,1,1))
    bubble:setContentSize(cc.size(477,157))
    bubble:setPosition(cc.p(x+scale*375,y+50))
    _widget:addChild(bubble)

    local dir = ccui.ImageView:create()
    dir:loadTexture("guideTip_bg_dir.png",1)
    dir:setPosition(cc.p(-0,75))
    dir:setRotation(90)
    bubble:addChild(dir,10)

    local desLab = ccui.Text:create()
    desLab:setColor(cc.c3b(61, 31, 0))
    desLab:setFontName(UIUtils.ttfName)
    desLab:setAnchorPoint(cc.p(0.5, 0.5))
    desLab:setPosition(cc.p(bubble:getContentSize().width/2, bubble:getContentSize().height/2))
    desLab:setFontSize(28)
    desLab:setString(des or "")
    bubble:addChild(desLab,10)

    return _widget
end

--[[
    @function createFightLabel
    @desc  创建战斗力
    @param 
            _fightNum  战斗力
            _scale     战斗力缩放比
            _labelSize “战斗力” fontSize

    @return fightLayout       战斗力节点         
            zhandouliLabel    bmfont
--]]
function UIUtils:createFightLabel(_fightNum,_scale,_labelSize)
    local scale = _scale or 0.5
    local labelSize =_labelSize or 16
    local fightNum = _fightNum or 0

    local fightLayout = ccui.Layout:create()  
    -- fightLayout:setBackGroundColorOpacity(255)
    -- fightLayout:setBackGroundColorType(1)
    fightLayout:setName("fightLayout")   
    fightLayout:setContentSize(100, 30)
    
    local fightText = ccui.Text:create()
    fightText:setString("战斗力")
    fightText:setColor(UIUtils.colorTable.ccUIBasePromptColor)
    -- fightText:enableOutline(cc.c4b(0,0,0,255),1)
    fightText:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,2)
    fightText:setFontName(UIUtils.ttfName)
    fightText:setFontSize(labelSize)
    fightText:setAnchorPoint(0,0.5)
    fightText:setPosition(0, 20)
    fightLayout:addChild(fightText, 1)
    
    local zhandouliLabel = cc.LabelBMFont:create(fightNum, UIUtils.bmfName_zhandouli)
    zhandouliLabel:setAnchorPoint(0,0.5)
    zhandouliLabel:setPosition(fightText:getContentSize().width+2, 22)
    zhandouliLabel:setScale(scale)
    fightLayout:addChild(zhandouliLabel, 1)

    local width = fightText:getContentSize().width+zhandouliLabel:getContentSize().width
    local height = fightText:getContentSize().height+zhandouliLabel:getContentSize().height
    fightLayout:setContentSize(cc.size(width,height))

    return fightLayout ,zhandouliLabel
end

-- 重新载入lua文件,为了省略重开客户端的时间 半动态加载
-- 参数建议为 self,moduleName 如果是UI,可以不写
function UIUtils:reloadLuaFile( name,moduleName )
    if not OS_IS_WINDOWS then
        return
    end
    if not name then return end 
    local fileName = name
    if type(name) == "userdata" then
        fileName = name:getClassName() or ""
    end
    if not moduleName then
        moduleName = "game.view."
    end
    moduleName = moduleName or ""
    fileName = moduleName .. fileName
    package.loaded[fileName] = nil  
    require(fileName)
end

-- UI 震屏
-- node: 除当前view外需要一起震动的
-- inObj：当前view不需要一起震动的
function UIUtils:shakeWindow( node, inObj)
    local viewMgr = ViewManager:getInstance()
    local topNode = viewMgr._viewLayer:getChildren()[#viewMgr._viewLayer:getChildren()]
    if topNode.view and topNode.view._widget then
        topNode.view:runAction(cc.Repeat:create(cc.Sequence:create(
            cc.MoveBy:create(0.05,cc.p(0,-10)),
            cc.MoveBy:create(0.05,cc.p(0,10))
        ),1))
    end

    if node then
        node:runAction(cc.Repeat:create(cc.Sequence:create(
            cc.MoveBy:create(0.05,cc.p(0,-10)),
            cc.MoveBy:create(0.05,cc.p(0,10))
        ),1))
    end

    if inObj then
        inObj:runAction(cc.Repeat:create(cc.Sequence:create(
            cc.MoveBy:create(0.05,cc.p(0,10)),
            cc.MoveBy:create(0.05,cc.p(0,-10))
            ),1))
    end
end

-- 结算UI 震屏 左右
-- node: 需要一起震动的对象
function UIUtils:shakeWindowRightAndLeft(node)   
    if node then
        node:runAction(cc.Repeat:create(cc.Sequence:create(
            cc.MoveBy:create(0.05,cc.p(-20,0)),
            cc.MoveBy:create(0.05,cc.p(20,0))
        ),1))
    end

end

-- 结算UI 震屏 上下
-- node: 需要一起震动的对象
function UIUtils:shakeWindowUpAndDown(node)   
    if node then
        node:runAction(cc.Repeat:create(cc.Sequence:create(
            cc.MoveBy:create(0.05,cc.p(0,-20)),
            cc.MoveBy:create(0.05,cc.p(0,20))
        ),1))
    end
end

-- 结算UI 震屏 左右中
-- node: 需要一起震动的对象
function UIUtils:shakeWindowRightAndLeft2(node)   
    if node then
        node:runAction(cc.Repeat:create(cc.Sequence:create(
            cc.MoveBy:create(0.05,cc.p(-10,0)),
            cc.MoveBy:create(0.05,cc.p(20,0)),
            cc.MoveBy:create(0.05,cc.p(-10,0))
        ),1))
    end
end

-- 给按钮加title
function UIUtils:addFuncBtnName( btn,titleTxt,pos,hasTextBg,fontSize )
    local txt = ccui.Text:create()
    txt:setName("titleName")
    txt:setFontSize(fontSize or 18)
    txt:setFontName(UIUtils.ttfName)
    txt:setString(titleTxt or "")
    txt:setPosition(pos or cc.p(btn:getContentSize().width/2,0))
    txt:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor,1)
    btn:addChild(txt,1)

    if hasTextBg then
        local txtBg = ccui.ImageView:create()
        txtBg:loadTexture("globalImageUI11_btnTextBg.png",1)
        txtBg:setPosition(pos or cc.p(btn:getContentSize().width/2,0))
        btn:addChild(txtBg,0)
        -- 背景圆
        local btnBg = ccui.ImageView:create()
        btnBg:loadTexture("globalImageUI12_iconBg.png",1)
        btnBg:setAnchorPoint(0.5,0.5)
        btnBg:setPosition(btn:getContentSize().width/2,btn:getContentSize().height/2)
        btn:addChild(btnBg,-1)
    end
    return txt
end

-- 居中对齐两个控件
function UIUtils:center2Widget( node1,node2,posX,blank )
    blank = blank or 0
    local w1 = node1:getContentSize().width*node1:getScaleX()
    local w2 = node2:getContentSize().width*node2:getScaleX()
    node1:setAnchorPoint(0.5,0.5)
    node2:setAnchorPoint(0.5,0.5)
    local totalW = w1+w2
    local posX1 = posX-w2/2-blank/2
    local posX2 = posX+w1/2+blank/2
    node1:setPositionX(posX1)
    node2:setPositionX(posX2)
end

-- 计算若干节点的总宽度
function UIUtils:sumNodesWidth( nodes,blank )
    if not type(nodes) == "table" then
        return 
    end
    blank = blank or 0
    local totalWidth = 0
    for i,node in ipairs(nodes) do
        totalWidth = totalWidth + node:getContentSize().width*node:getScaleX()+blank
    end
    totalWidth = totalWidth-blank
    return totalWidth
end

-- 排列若干个控件 到某个位置
function UIUtils:alignNodesToPos( nodes,posX,blank )
    if type(nodes) ~= "table" then return end
    posX = posX or 0
    blank = blank or 0
    local totalWidth = self:sumNodesWidth(nodes,blank)
    local offsetX = posX-totalWidth/2
    local x = 0
    for i,node in ipairs(nodes) do
        local anchor = node:getAnchorPoint()
        node:setAnchorPoint(0,anchor.y or 0.5)
        node:setPositionX(x+offsetX)
        x = x + node:getContentSize().width*node:getScaleX()+blank
    end
    return totalWidth
end

function UIUtils:createShowCGBtn( node ,param )
    local btn = ccui.Button:create()
    btn:loadTextures("globalBtnUI_preViewBtn2.png","globalBtnUI_preViewBtn2.png","globalBtnUI_preViewBtn2.png",1)
    btn:setPosition(param.pos or cc.p(0,0))
    param = param or {}
    local isHero = param.isHero 
    local isTeam = param.isTeam 
    local id = param.id or 0
    if isHero then
        local fu = cc.FileUtils:getInstance()
        local heroData = tab.hero[tonumber(id)]
        if not heroData then 
            print("创建立绘按钮,没有 hero id ") 
            return
        end
        if not heroData.heroport then 
            print("没有配立绘",id) 
            return
        end
        local fileName ="asset/uiother/hero/"..  heroData.heroport ..".jpg" 
        if not fu:isFileExist( fileName ) then 
            print("找不到文件",fileName) 
            return
        end
        if node then
            node:addChild(btn,999)
            registerClickEvent(btn,function() 
                DialogUtils.showHeroCG({isHero=true,heroId = id,imgName = fileName,heroSkinImgName = param.heroSkinImgName})
            end)
        end
    elseif isTeam then
        local fileName = "asset/bg/loading-HD/".. "l_1_" .. id  ..".jpg"
        local fu = cc.FileUtils:getInstance()
        if not fu:isFileExist(fileName) then 
            print("找不到文件",fileName) 
            return
        end
        if node then
            node:addChild(btn,999)
            registerClickEvent(btn,function() 
                DialogUtils.showTeamCG({isTeam=true,imgName = fileName})
            end)
        end
    end

    return btn
end

-- 创建宝物名
-- 参数 nameLab 如传入则设置传入lab 对应样式
-- 参数 comId 宝物id
-- 参数 stage 宝物阶数
-- 参数 fontSize lab大小
-- 参数 isBrightColor 是否用亮色
function UIUtils:createTreasureNameLab( comId,stage,fontSize,nameLab,isBrightColor )
    if not comId or not (tab.comTreasure[tonumber(comId)] or tab.disTreasure[tonumber(comId)]) then return nameLab end
    stage = stage and ("+" .. stage) or ""
    fontSize = fontSize or 40
    if not nameLab then
        nameLab = ccui.Text:create()
        nameLab:setFontName(UIUtils.ttfName)
    end
    nameLab:setFontSize(fontSize)
    -- 宝物名颜色 渐变色 描边
    local nameColorTab = {
        [2] = {color = cc.c3b(100, 199, 86),color2 = cc.c4b(29,81,12,255),outColor = cc.c3b(4, 73, 0)},
        [3] = {color = cc.c3b(55, 107, 165),color2 = cc.c4b(14,55,76,255),outColor = cc.c3b(13, 45, 133)},
        [4] = {color = cc.c3b(120, 72, 158),color2 = cc.c4b(74,27,131,255),outColor = cc.c3b(96, 0, 166)},
        [5] = {color = cc.c3b(179, 99, 39),color2 = cc.c4b(102,46,21,255),outColor = cc.c3b(93, 54, 1)},
    }
    if isBrightColor then
        nameColorTab = {
            [2] = {color = cc.c3b(109, 233, 90),color2 = cc.c4b(46,127,16,255),outColor = cc.c3b(4, 73, 0)},
            [3] = {color = cc.c3b(87, 196, 255),color2 = cc.c4b(15,68,157,255),outColor = cc.c3b(13, 45, 133)},
            [4] = {color2 = cc.c3b(147, 7, 209),color = cc.c4b(214,38,238,255),outColor = cc.c3b(96, 0, 166)},
            [5] = {color2 = cc.c3b(220, 113, 29),color = cc.c4b(255,192,118,255),outColor = cc.c3b(93, 54, 1)},
        }
    end
    local comData = tab.comTreasure[tonumber(comId)] or tab.disTreasure[tonumber(comId)]
    nameLab:setString(lang(comData.name) .. stage)
    local quality = comData.quality
    if nameColorTab[quality] then
        nameLab:setColor(nameColorTab[quality]["color"])
        nameLab:enable2Color(1,nameColorTab[quality]["color2"])
        if isBrightColor then
            nameLab:enableOutline(nameColorTab[quality]["outColor"],1)
        end
    end
    return nameLab
end

-- 页签出现动画
function UIUtils:setTabAppearAnim( btns,afterOrder,btnsOffset ,finishCallBack)
    if not btns or not next(btns) then return end
    local btnsOffset = btnsOffset or 100
    local isFirstSinish = false
    for i,btn in pairs(btns) do
        if i == 1 then 
            isFirstSinish = true
        end
        if not tolua.isnull(btn) then
            local initPos = cc.p(btn:getPositionX(),btn:getPositionY()) 
            btn:setPositionX(initPos.x+btnsOffset)
            btn:setOpacity(0)
            if not btn._appearSelect then
                btn:setZOrder(-2)
                btn:setEnabled(false)
            else
                btn:setZOrder( 2)
            end
            local actionSeq = cc.Sequence:create(
                cc.DelayTime:create(i*0.05+0.1),
                cc.Spawn:create(
                    cc.MoveTo:create(0.1,initPos),
                    cc.FadeIn:create(0.1)
                ),
                cc.CallFunc:create(function( )
                    if not btn._appearSelect then
                        btn:setZOrder(afterOrder or 100)
                        btn:setEnabled(true)
                    else
                        btn:setZOrder( 999 )
                    end
                    if isFirstSinish and finishCallBack then
                        finishCallBack()
                        isFirstSinish = false
                    end
                end)
            )
            actionSeq:setTag(101)
            btn:runAction(actionSeq)
        end
    end

end

-- 页签切换动画  begin

---- 单独设置点击事件
-----------
-- 参数 btn   按钮 
-- initPosX   按钮位置(需单独调整) 
-- clickFunc  点击事件
-- clickParam 点击事件传入参数，为nil 默认参数为按钮对象
-- isRightBtn 按钮是否在右边
function UIUtils:setTabChangeAnimEnable( btn,initPosX, clickFunc, clickParam, isRightBtn )
    btn:setScaleAnim(false)
    btn:setZOrder(-2)
    btn:setPositionX(initPosX)
    btn._tabPosX = initPosX or btn:getPositionX()
    registerTouchEvent(btn,
        function(sender)self:tabTouchAnimBegin(sender,isRightBtn) end,
        nil, 
        function(sender) clickFunc(clickParam or sender) end,
        function( sender ) self:tabTouchAnimOut(sender)end)
end
-- 按钮按下动画
function UIUtils:tabTouchAnimBegin(sender,isRightBtn)
    if not isRightBtn then
        sender:runAction(cc.MoveTo:create(0.1,cc.p(sender._tabPosX-5,sender:getPositionY())))
    else
        sender:runAction(cc.MoveTo:create(0.1,cc.p(sender._tabPosX+5,sender:getPositionY())))
    end
end
-- 按钮按下动画
function UIUtils:tabTouchAnimOut(sender)
    local actionSeq = cc.MoveTo:create(0.1,cc.p(sender._tabPosX,sender:getPositionY()))
    sender:runAction(actionSeq)
end
---- 切换动画
-- 参数 
-- btn 按钮 、
-- callback 动画执行完回调
-- isReverse   false or nil ：选中动画; true: 取消选中动画
-- isRightBtn 按钮是右侧按钮 主要用于排行榜 兵团
function UIUtils:tabChangeAnim( btn,callback,isReverse,isRightBtn )
    btn:setEnabled(false)
    local clippNode = btn:getChildByName("changeBtnStatusAnim")
    if clippNode then
        clippNode:removeFromParent()
    end
    clippNode = cc.ClippingNode:create()
    clippNode:setContentSize(cc.size(200,65))
    clippNode:setName("changeBtnStatusAnim")
    clippNode:setAnchorPoint(0,0)
    clippNode:setPosition(0,0)
    
    local maskPos = -120
    local moveDis = 120
    local dir = 1
    local cloneImgName = isRightBtn and "TeamBtnUI_tab_p.png" or "globalBtnUI4_page1_p.png"
    if btn.tabAnimImgName then 
        cloneImgName = btn.tabAnimImgName
    end
    local color = UIUtils.colorTable.ccUITabColor2
    local cloneOffset = -10
    -- reverse 
    if isReverse then
        maskPos = 0
        moveDis = 120
        dir = -1
        color = UIUtils.colorTable.ccUITabColor1
        btn:setEnabled(true)
        btn:setZOrder(-99)
    end
    if isRightBtn then
        cloneOffset = 0
        if isReverse then
            color = UIUtils.colorTable.ccUITabColor1
            maskPos = 20
            moveDis = 100
            dir = 1
            btn:setEnabled(true)
            btn:setZOrder(-99)
        else
            maskPos = 120
            moveDis = 100
            dir = -1
        end
    end
    local btnClone = btn:clone()
    btnClone:removeAllChildren()
    btnClone:loadTextureNormal(cloneImgName,1)
    local text = btnClone:getTitleRenderer()
    btnClone:setTitleColor(UIUtils.colorTable.ccUITabColor2)
    btnClone:setScale(1)
    btnClone:setAnchorPoint(0,0)
    btnClone:setPosition(0 or cloneOffset,0)
    clippNode:addChild(btnClone)
    
    local mask = cc.Sprite:createWithSpriteFrameName("globalPanelUI7_zhezhao.png")
    mask:setContentSize(cc.size(240,200))
    if btn.tabAnimImgName then
        mask:setScale(2,2)
    else
        mask:setScale(1.2)
    end
    mask:setAnchorPoint(0,0)
    mask:setPosition(maskPos,0)
    clippNode:setStencil(mask)
    clippNode:setAlphaThreshold(0.05)

    -- local maskClone = cc.Sprite:createWithSpriteFrameName("globalPanelUI7_zhezhao.png")
    -- maskClone:setContentSize(cc.size(240,200))
    -- maskClone:setAnchorPoint(0,0)
    -- maskClone:setPosition(maskPos,0)
    -- clippNode:addChild(maskClone)

    local actionTime = 0.1
    mask:runAction(cc.Sequence:create(
        cc.MoveBy:create(actionTime,cc.p(moveDis*dir,0)),
        cc.CallFunc:create(function( )
            if btn then
                -- btn:setPositionX(btn._tabPosX or 140)
                local btnAction = btn:getActionByTag(101)
                if not btnAction then
                    UIUtils:tabTouchAnimOut(btn)
                end
                if not isReverse then
                    btn:setZOrder(99)
                else
                    btn:setZOrder(-99)
                end
            end
        end),
        cc.DelayTime:create(0.05),
        cc.CallFunc:create(function( )
            if callback then 
                callback()
            end
            clippNode:removeFromParent()
        end)
    ))
    -- btnClone:runAction(cc.MoveBy:create(actionTime,cc.p(-moveDis*dir+10,0)))
    btn:addChild(clippNode,0)
end

-- 页签切换动画 end

-- 结算统计按钮 渐变字色
function UIUtils:formatBattleResultBtnTxt(titleTxt)   
    if not titleTxt then return end 
    titleTxt:setVisible(false)
    if true then return end
    titleTxt:setColor(cc.c3b(250,242,192))
    titleTxt:enable2Color(1, cc.c3b(255, 195, 17))
    titleTxt:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
    titleTxt:setFontName(UIUtils.ttfName )
    titleTxt:setFontSize(24)
    titleTxt:setPosition(36,-10)
end

-- 给ccScrollView增加滚动条, 需要scrollview 先add到父节点以后再调用
-- invX, 为滚动条距离scrollview右边边界的距离, width为滚动条的宽度
function UIUtils:ccScrollViewAddScrollBar(scrollview, barColor, bgColor, invX, width)
    if scrollview.__scrollBg then scrollview.__scrollBg:removeFromParent() end
    if scrollview.__scrollBar then scrollview.__scrollBar:removeFromParent() end 
    local swidth = scrollview:getViewSize().width
    local sheight = scrollview:getViewSize().height
    local x, y = scrollview:getPosition()
    if not width then width = 6 end
    if width < 3 then width = 3 end
    if not invX then invX = 2 end

    -- 滚动条背景
    local bg = cc.Scale9Sprite:createWithSpriteFrameName("globalImageUI_scrollBg.png")
    bg:setCapInsets(cc.rect(3,3,1,1))
    bg:setContentSize(width, sheight)
    bg:setAnchorPoint(0, 0)
    bg:setPosition(x + swidth + invX, y)
    scrollview:getParent():addChild(bg)

    -- 滚动条
    local bar = cc.Scale9Sprite:createWithSpriteFrameName("globalImageUI_scrollBar.png")
    bar:setCapInsets(cc.rect(3,3,1,1))
    bar:setContentSize(width, sheight)
    bar:setAnchorPoint(0, 0)
    bar:setPosition(x + swidth + invX, y)
    scrollview:getParent():addChild(bar)

    bg:setVisible(false)
    bar:setVisible(false)
    scrollview.__scrollBg = bg
    scrollview.__scrollBar = bar
    scrollview.__scrollWidth = width
    scrollview.__scrollHeight = sheight
    scrollview.__initY = y
end

-- 更新ccScrollView的滚动条
-- 需要在cc.SCROLLVIEW_SCRIPT_SCROLL 事件方法中调用
function UIUtils:ccScrollViewUpdateScrollBar(scrollview)
    local bg = scrollview.__scrollBg
    local bar = scrollview.__scrollBar
    if bg == nil or bar == nil then return end
    local width = scrollview.__scrollWidth
    local height = scrollview.__scrollHeight

    local allHeight = scrollview:getContentSize().height
    if allHeight <= height then
        if scrollview.__scrollVisible ~= false then
            scrollview.__scrollVisible = false
            bar:setVisible(false)
            bg:setVisible(false)
        end
    else
        if scrollview.__scrollVisible ~= true then
            scrollview.__scrollVisible = true
            bar:setVisible(true)
            bg:setVisible(true)
        end
        local barHeight = height / allHeight * height

        local offsety = scrollview:getContentOffset().y
        local pro = -offsety / (allHeight - height)
        local y = (height - barHeight) * pro
        if y < 0 then
            barHeight = barHeight + y
            y = 0
            if barHeight < width then barHeight = width end
        end
        local dh = height - barHeight
        if y > dh then
            barHeight = barHeight - (y - dh)
            if y > height - width then y = height - width end
            if barHeight < width then barHeight = width end
        end
        bar:setPositionY(y + scrollview.__initY)
        bar:setContentSize(width, barHeight)
    end
end

--[[
    根据tool表中的color获取颜色值
    itemId 道具id
    num  道具数量
]]
function UIUtils:getItemColorValue(itemId,num)
    local toolD = tab.tool[itemId]
    if not toolD then return end
    local color = toolD.color or 1
    if color == 9 then
        color = ItemUtils.findResIconColor(itemId,num)
    end
    return UIUtils.colorValueTable["ccColorQuality"..color]
end

function UIUtils:showFloatItems( gifts,param )
    -- 兼容弄处理
    if type(gifts) == "table" and type(gifts[1]) ~= "table" then
        gifts = {gifts}
    end
    local callback = param and param.callback
    local viewMgr = ViewManager:getInstance()
    local hintLayer = viewMgr._hintLayer
    -- 创建node 在node上 展示动画
    local floatNode = ccui.Widget:create()
    floatNode:setName("floatNode")
    floatNode:setPosition(MAX_SCREEN_WIDTH/2,MAX_SCREEN_HEIGHT/2)
    hintLayer:addChild(floatNode)

    local createItem = function( itemId,num,delay,exDes,itemType)
        local toolD
        local icon 
        if itemType and itemType == "siegeProp" then
            toolD = tab:SiegeEquip(tonumber(itemId) or 0)
            if not toolD then return end
            local param = {itemId = itemId, level = 1, itemData = toolD, quality = toolD.quality, iconImg = toolD.art, eventStyle = 0}
            icon = IconUtils:createWeaponsBagItemIcon(param)
        elseif itemType and itemType == "rune" then
            toolD = tab:Rune(itemId)
            icon =IconUtils:createHolyIconById({suitData = toolD})
        else
            toolD = tab.tool[tonumber(itemId) or 0]
            if not toolD then return end
            icon = IconUtils:createItemIconById({itemId = itemId,effect=true,num=num,eventStyle=0})
        end
        local bg = ccui.ImageView:create()
        bg:loadTexture("globalImageUI_commonGetBg2.png",1)
        bg:setAnchorPoint(0.5,0)
        local y = bg:getContentSize().height/2
        local x = bg:getContentSize().width/2
        
        local numLab = icon:getChildByFullName("numLab")
        if numLab then numLab:setVisible(false) end
        icon:setScale(0.65)
        icon:setPositionY(11)
        bg:addChild(icon)

        local nameLab = ccui.Text:create()
        nameLab:setFontSize(22)
        nameLab:setFontName(UIUtils.ttfName)
        bg:addChild(nameLab)
        nameLab:setString(lang(toolD.name))
        nameLab:setPositionY(y)
        local color = toolD.color or 1
        if color == 9 then
            color = ItemUtils.findResIconColor(itemId,itemNum)
        end
        nameLab:setColor(UIUtils.colorTable["ccColorQuality" .. color])

        local numLab = ccui.Text:create()
        numLab:setFontSize(22)
        numLab:setFontName(UIUtils.ttfName)
        bg:addChild(numLab)
        
        numLab:setPositionY(y)
        numLab:setString("x" .. num .. exDes)

        UIUtils:alignNodesToPos({icon,nameLab,numLab},x)

        bg:setCascadeOpacityEnabled(true,true)
        bg:setOpacity(0)
        bg:setScale(0.5)
        bg:runAction(cc.Sequence:create(
            cc.DelayTime:create(delay),
            cc.Spawn:create(
                cc.FadeIn:create(0.1),
                cc.ScaleTo:create(0.1,1)
            ),
            -- cc.EaseIn:create(
                cc.MoveBy:create(0.4,cc.p(0,60)),
            --     0.8
            -- ),
            cc.Spawn:create(
                cc.MoveBy:create(0.4,cc.p(0,120)),
                cc.FadeOut:create(0.3)
            )
            ,cc.RemoveSelf:create()
        ))
        floatNode:addChild(bg)
        return bg 
    end
    local delayInterval = 0.3
    local avatarGifts = {}
    local skinGifts = {}
    local teamSkinGifts = {}
    for i,data in ipairs(gifts) do
        local itemType = data[1] or data.type
        local itemId = data[2] or data.typeId 
        local itemNum = data[3] or data.num
        local isChange = data[4] or data.isChange
        if itemType ~= "tool" 
            and itemType ~= "hero" 
            and itemType ~= "team" 
            and itemType ~= "avatarFrame" 
            and itemType ~= "avatar"
            and itemType ~= "siegeProp"
            and itemType ~= "rune"
        then
            itemId = IconUtils.iconIdMap[itemType]
        end
        local exDes = ""
        if data.transfer then 
            if data.transfer == "avatarFrame" then
                exDes = "(" .. lang("DIAMONDPRICE_1") .. ")"
            elseif  data.transfer == "avatar" then
                exDes = "(" .. lang("DIAMONDPRICE_2") .. ")"
            elseif  data.transfer == "hSkin" then
                exDes = "(" .. lang("DIAMONDPRICE_3") .. ")"
            end
        end
        -- 展示兵团英雄整卡
        if itemType == "hero" then
            local heroView = viewMgr:createLayer("hero.HeroUnlockView", {heroId = itemId, callBack = function() 
                -- nextFunc(index+1)
            end})
            local node = viewMgr._viewLayer:getChildren()[#viewMgr._viewLayer:getChildren()]
            node:addChild(heroView,999)
        elseif itemType == "team" then
            local teamId  = itemId
            DialogUtils.showTeam({teamId = teamId,callback = function (  )
                -- nextFunc(index+1)
            end})
        
        elseif isChange and isChange == 1 and tab.team[tonumber(string.sub(itemId,2,string.len(itemId)))] then
            DialogUtils.showCard({itemId = itemId,changeNum= itemNum ,callback = function (  )
                -- nextFunc(index+1)
            end})
        else
            local isDis = tab.disTreasure[itemId] and tab.disTreasure[itemId].produce == 2
            -- local isHadItemInTreasure = self._modelMgr:getModel("TreasureModel"):getTreasureById(itemId)
            -- local _,itemCount = self._modelMgr:getModel("ItemModel"):getItemsById(itemId)
            local isOTreasure = isDis --and not isHadItemInTreasure and itemCount < 2
            if isOTreasure then
                viewMgr:showDialog("global.GlobalShowTreasureDialog", {itemId = itemId, callback = function() 
                    -- nextFunc(index+1)
                end})
            else
                -- nextFunc(index+1)
            end
        end

        --
        if itemType == "avatarFrame" or itemType == "avatar" then
            table.insert(avatarGifts,data)
        elseif itemType == "hSkin" then
            table.insert(skinGifts,data)
        elseif itemType == "tSkin" then
            table.insert(teamSkinGifts,data)
        else
            createItem(itemId,itemNum,(i-1)*delayInterval,exDes,itemType)
        end
    end
    local totalDelay = (delayInterval)*(table.nums(gifts) - table.nums(skinGifts) - table.nums(avatarGifts))+0.2
    floatNode:runAction(cc.Sequence:create(
        cc.DelayTime:create(totalDelay),
        cc.CallFunc:create(function(  )
            if #avatarGifts > 0 then
                DialogUtils.showAvatarFrameGet( {gifts = avatarGifts})
            end  
            if #skinGifts > 0 then 
               local skinItemID = skinGifts[1].typeId or skinGifts[1][2]
               DialogUtils.showSkinGetDialog({skinId = skinItemID})
            end 
            if #teamSkinGifts > 0 then 
               local skinItemID = teamSkinGifts[1].typeId or teamSkinGifts[1][2]
               DialogUtils.showTeamSkinGetDialog({skinId = skinItemID})
            end 
            -- if callbackNow then
            --     if callback then callback() end
            -- end
        end),
        cc.DelayTime:create(0.8),
        cc.RemoveSelf:create()
    ))
    -- 修改，立马执行回调
    if callback then callback() end
end

-- 给uiScrollView增加滚动条, 需要scrollview 先add到父节点以后再调用
-- invX, 为滚动条距离scrollview右边边界的距离, width为滚动条的宽度
function UIUtils:uiScrollViewAddScrollBar(scrollview, barColor, bgColor, invX, width)
    if scrollview.__scrollBg then scrollview.__scrollBg:removeFromParent() end
    if scrollview.__scrollBar then scrollview.__scrollBar:removeFromParent() end 
    local swidth = scrollview:getContentSize().width
    local sheight = scrollview:getContentSize().height
    local x, y = scrollview:getPosition()
    if not width then width = 6 end
    if width < 3 then width = 3 end
    if not invX then invX = 2 end

    -- 滚动条背景
    local bg = cc.Scale9Sprite:createWithSpriteFrameName("globalImageUI_scrollBg.png")
    bg:setCapInsets(cc.rect(3,3,1,1))
    bg:setContentSize(width, sheight)
    bg:setAnchorPoint(0, 0)
    bg:setPosition(x + swidth + invX, y)
    scrollview:getParent():addChild(bg)

    -- 滚动条
    local bar = cc.Scale9Sprite:createWithSpriteFrameName("globalImageUI_scrollBar.png")
    bar:setCapInsets(cc.rect(3,3,1,1))
    bar:setContentSize(width, sheight)
    bar:setAnchorPoint(0, 0)
    bar:setPosition(x + swidth + invX, y)
    scrollview:getParent():addChild(bar)

    scrollview.__scrollBg = bg
    scrollview.__scrollBar = bar
    scrollview.__scrollWidth = width
    scrollview.__scrollHeight = sheight
    scrollview.__initY = y
end

-- 更新uiScrollView的滚动条
-- 需要自己在update里面调用
function UIUtils:uiScrollViewUpdateScrollBar(scrollview)
    local bg = scrollview.__scrollBg
    local bar = scrollview.__scrollBar
    if bg == nil or bar == nil then return end
    local width = scrollview.__scrollWidth
    local height = scrollview.__scrollHeight

    local allHeight = scrollview:getInnerContainerSize().height
    if allHeight <= scrollview.__scrollHeight then
        if scrollview.__scrollVisible ~= false then
            scrollview.__scrollVisible = false
            bar:setVisible(false)
            bg:setVisible(false)
        end
    else
        if scrollview.__scrollVisible ~= true then
            scrollview.__scrollVisible = true
            bar:setVisible(true)
            bg:setVisible(true)
        end
        local barHeight = height / allHeight * height

        local offsety = scrollview:getInnerContainer():getPositionY()
        local pro = -offsety / (allHeight - height)
        local y = (height - barHeight) * pro
        if y < 0 then
            barHeight = barHeight + y
            y = 0
            if barHeight < width then barHeight = width end
        end
        local dh = height - barHeight
        if y > dh then
            barHeight = barHeight - (y - dh)
            if y > height - width then y = height - width end
            if barHeight < width then barHeight = width end
        end
        bar:setPositionY(y + scrollview.__initY)
        bar:setContentSize(width, barHeight)
    end
end

-- 显示systemOpen表对应的 未开启tip
function UIUtils:showNotOPenTip( system )
    if not system or not SystemUtils["enable" .. system] then return end
    local isOpen,_,openLevel = SystemUtils["enable" .. system]()
    if tab.systemOpen[system] then
        local systemOpenTip = tab.systemOpen[system][3]
        if not systemOpenTip then
            ViewManager:getInstance():showTip(tab.systemOpen[system][1] .. "级开启")
        else
            ViewManager:getInstance():showTip(lang(systemOpenTip))
        end
    else
        ViewManager:getInstance():showTip(openLevel .. "级开启")
    end
end

function UIUtils:getNotOPenTip(inSys)
    if not inSys then 
        return 
    end

    local tips = "暂无开启"
    if tab.systemOpen[inSys] then
        local unOpenTip = tab.systemOpen[inSys][3]
        if not unOpenTip then
            tips = tab.systemOpen[inSys][1] .. "级开启"
        else
            tips = lang(unOpenTip)
        end
    end

    return tips
end

-- 大世界使用气泡
function UIUtils:addShowBubble(btntitle, tip)
    local btn = btntitle
    if not tip then
        return nil
    end
    if not tip.pic then
        return nil
    end
    -- i = 1
    -- local tip = tip
    local scale = 1 -- 1 / btn:getScale()
    if tip.scale ~= nil then 
        scale = tip.scale 
    end
    local posX = tip.position[1] * scale
    local posY = tip.position[2] * scale
    -- local posX = -180
    -- local posY = 30
    local tipbg

    if tip then
        tipbg = cc.Scale9Sprite:createWithSpriteFrameName(tip.pic .. ".png")        
        tipbg:setName("tipbg")
        tipbg:setAnchorPoint(0.25, 0)
        tipbg:setPosition(posX, posY)
        tipbg:setScale(scale)
        local seq = cc.Sequence:create(cc.ScaleTo:create(1, scale+scale*0.2), cc.ScaleTo:create(1, scale))
        tipbg:runAction(cc.RepeatForever:create(seq))
    end
    return tipbg
end

--[[
--! @function shareToPlatfrom
--! @param inPlan 方案方便扩展
--! @param inLayer 需要截屏的层
--！@param inCallback 回调函数
--! @desc 分享图片到平台
--! @return 
--]]
function UIUtils:shareToPlatfrom(inPlan, inLayer, inCallback)
    if self["sharePlan" .. inPlan] == nil then return end
    self["sharePlan" .. inPlan](self, inLayer, inCallback)
end

function UIUtils:sharePlan2(inLayer, inCallback)
    -- 默认game.conf中没有版本号，如果人为添加则需要注意
    local appPlatForm = kakura.Config:getInstance():getValue("APP_PLATFORM")
    local qrSprite = cc.Sprite:create("asset/other/qr/" .. appPlatForm .. ".png")
    if qrSprite ~= nil then 
        qrSprite:setAnchorPoint(1, 0)
        qrSprite:setPosition(inLayer:getContentSize().width, 0)
        qrSprite:setScale(0.5)
        inLayer:addChild(qrSprite)
    end
    self:captureScreen(inLayer, function(imgPath)
        if qrSprite ~= nil then 
            qrSprite:removeFromParent()
        end
        if inCallback ~= nil then 
            inCallback(imgPath)
        end               
    end)
end

function UIUtils:sharePlan1(inLayer, inCallback)
    self:captureScreen(inLayer, function(imgPath)
        if inCallback ~= nil then 
            inCallback(imgPath)
        end
    end)
end

function UIUtils:captureScreen(inLayer, callback)
    local MATRIX_STACK_TYPE = {
        MATRIX_STACK_MODELVIEW = 0,
        MATRIX_STACK_PROJECTION = 1,
        MATRIX_STACK_TEXTURE = 2,
    }    
    local fu = cc.FileUtils:getInstance()
    local imgPath = fu:getWritablePath() .. "share.jpg"
    if OS_IS_ANDROID then
        local appInformation = AppInformation:getInstance()
        if appInformation:getValue("external_asset_path") ~= nil and appInformation:getValue("external_asset_path") ~= "" then
            imgPath = appInformation:getValue("external_asset_path") .. "share.jpg"
        end
    end
    if fu:isFileExist(imgPath) then 
        fu:removeFile(imgPath)
    end
    
    local ox, oy = inLayer:getPosition()
    local director = cc.Director:getInstance()
    local transform = {
        1, 0, 0, 0,
        0, 1, 0, 0,
        0, 0, 1, 0,
        -ox, -oy, 0, 1
    }

    local render = cc.RenderTexture:create(inLayer:getContentSize().width * inLayer:getScaleX() , inLayer:getContentSize().height * inLayer:getScaleY(), cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888, 0x88f0)
    render:begin()

    director:pushMatrix(MATRIX_STACK_TYPE.MATRIX_STACK_MODELVIEW)
    director:loadMatrix(MATRIX_STACK_TYPE.MATRIX_STACK_MODELVIEW, transform)

    local isVisible = inLayer:isVisible()
    inLayer:setVisible(true)

    inLayer:visit()

    inLayer:setVisible(isVisible)
    render:endToLua()
    
    cc.Director:getInstance():flushScene()
    local newImg = render:newImage(true)
    newImg:saveToFile(imgPath)
    render:clear(0, 0, 0, 0)
    newImg:release()

    if fu:isFileExist(imgPath) then 
        callback(imgPath)
        return
    end

end

-- 异步加载资源
UIUtils.asyncLoadReqHead = nil
UIUtils.asyncLoadReqTail = nil
UIUtils.asyncLoading = false
function UIUtils:asyncLoadTexture(view, filename)
    local req = {view = view, filename = filename, next = nil}
    view.__asyncCallback = function (_filaname)
        if view.__asyncCallback then
            if view.__asyncFileName == _filaname then
                if view.setTexture then
                    view:setTexture(_filaname)
                elseif view.loadTexture then
                    view:loadTexture(_filaname, 0)
                end
                view.__asyncCallback = nil
                view.__asyncFileName = nil
            end
        end
    end
    view.__asyncFileName = filename
    if view.setSpriteFrame then
        view:setSpriteFrame("alpha.png")
    elseif view.loadTexture then
        view:loadTexture("alpha.png", 1)
    end

    if UIUtils.asyncLoadReqHead == nil then
        UIUtils.asyncLoadReqHead = req
        UIUtils.asyncLoadReqTail = req
    else
        UIUtils.asyncLoadReqTail.next = req
        UIUtils.asyncLoadReqTail = req
    end
    UIUtils:_doAsyncLoadTexture(0)
end

function UIUtils:_doAsyncLoadNext(req)
    UIUtils.asyncLoadReqHead = req.next
    if UIUtils.asyncLoadReqHead == nil then
        UIUtils.asyncLoadReqTail = nil
    end
    UIUtils.asyncLoading = false
end

function UIUtils:_doAsyncLoadTexture(id)
    -- print("doAsyncLoadTexture")
    if UIUtils.asyncLoading then return end
    UIUtils.asyncLoading = true
    -- print("doAsyncLoadTexture", id)
    if UIUtils.asyncLoadReqHead then
        local req = UIUtils.asyncLoadReqHead
        local run = (req.view.__asyncCallback ~= nil) and (req.view.__asyncFileName == req.filename)
        if run then
            local callback = req.view.__asyncCallback
            if fu:isFileExist(req.filename) then
                -- print(1, req.filename)

                if tc:getTextureForKey(req.filename) ~= nil then
                    UIUtils:_doAsyncLoadNext(req)
                    UIUtils:_doAsyncLoadTexture(1)
                    callback(req.filename)
                else
                    local task = pc.LoadResTask:createImageTask(req.filename, RGBAUTO)
                    task:setLuaCallBack(function ()
                        -- ScheduleMgr:delayCall(500, self, function()
                            UIUtils:_doAsyncLoadNext(req)
                            UIUtils:_doAsyncLoadTexture(1)
                            callback(req.filename)
                        -- end)
                    end)
                    ALR:addTask(task) 
                end
            else
                UIUtils:_doAsyncLoadNext(req)
                UIUtils:_doAsyncLoadTexture(2)
            end
        else
            -- print(2, req.filename)
        end
        if not run then
            UIUtils:_doAsyncLoadNext(req)
            UIUtils:_doAsyncLoadTexture(3)
        end
    else
        UIUtils.asyncLoading = false
    end
end

function UIUtils:getActivityLabel(str, fontsize)
    local label = cc.Label:createWithTTF(str, UIUtils.ttfName, fontsize)
    local w, h = label:getContentSize().width, label:getContentSize().height
    local rt1 = cc.RenderTexture:create(w, h, cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888)
    rt1:getSprite():getTexture():setAntiAliasTexParameters()
    rt1:beginWithClear(0, 0, 0, 0)
    label:setPosition(w * 0.5, h * 0.5)
    label:setBrightness(15)
    label:visit()
    rt1:endToLua()
    rt1:setPosition(w * 0.5, h * 0.5)

    local rt2 = cc.RenderTexture:create(w, h, cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888)
    rt2:getSprite():getTexture():setAntiAliasTexParameters()
    rt2:beginWithClear(0, 0, 0, 0)

    local bg = cc.Sprite:createWithSpriteFrameName("activ_label_bg.png")
    bg:setScale(w / bg:getContentSize().width, h / bg:getContentSize().height)
    bg:setPosition(w * 0.5, h * 0.5)
    bg:visit()
    local shader = require ("utils.shader.shader_6")
    rt1:getSprite():setGLProgramState(shader)
    rt1:getSprite():setBlendFunc({src = gl.ZERO, dst = gl.ONE_MINUS_SRC_ALPHA})
    rt1:visit()
    rt2:endToLua()
    rt2:setPosition(w * 0.5, h * 0.5)

    rt2:setSkewX(12)
    rt2:setScaleY(.85)

    local label2 = cc.Label:createWithTTF(str, UIUtils.ttfName, fontsize)
    label2:setScaleY(.85)
    label2:setSkewX(12)
    label2:enableOutline(cc.c4b(176, 148, 51, 255), 1)
    label2:setPosition(w * 0.5, h * 0.5)

    local label3 = cc.Label:createWithTTF(str, UIUtils.ttfName, fontsize)
    label3:setScaleY(.85)
    label3:setSkewX(12)
    label3:enableShadow(cc.c4b(145, 18, 18, 255), cc.size(1, -3))
    label3:setPosition(w * 0.5, h * 0.5)

    local node = cc.Node:create()
    node:addChild(label3)
    node:addChild(label2)
    node:addChild(rt2)

    return node
end

--[[
    添加红点
    node 需要添加红点的node
    visible true 显示
    customPos 有自定义坐标优先使用
]]
function UIUtils.addRedPoint(node, visible, customPos)
    local redPoint = node.__redpoint
    if visible then
        if redPoint then
            redPoint:setVisible(true)
        else
            local red = cc.Sprite:createWithSpriteFrameName("globalImageUI_bag_keyihecheng.png")
            red:setAnchorPoint(cc.p(0.5,0.5))
            node.__redpoint = red
            if not customPos then
                red:setPosition(cc.p(node:getContentSize().width-10,node:getContentSize().height-10))
            else
                red:setPosition(customPos)
            end
            node:addChild(red,100)
        end
    else
        if redPoint then
            redPoint:setVisible(false)
        end
    end
end

function UIUtils.showFloatTips( params )
    if not params then return end
    local tips = params.tips
    if not tips then return end
    
    local viewMgr = ViewManager:getInstance()
    local hintLayer = viewMgr._hintLayer

    local floatTip = ccui.Widget:create()
    floatTip:setName("floatTip")
    floatTip:setPosition(MAX_SCREEN_WIDTH / 2, MAX_SCREEN_HEIGHT / 2)
    hintLayer:addChild(floatTip)

    local function createTipItem( data, delay )
        local data = string.gsub(data, "%b[]", "")

        natureLab = cc.Label:createWithTTF(data, UIUtils.ttfName, 24)
        natureLab:setColor(UIUtils.colorTable.ccColorQuality2)
        natureLab:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        natureLab:setOpacity(0)
        natureLab:setScale(0)
        floatTip:addChild(natureLab)

        local seqnature = cc.Sequence:create(
            cc.DelayTime:create(delay),
            cc.Spawn:create(
                cc.ScaleTo:create(0.2, 1),
                cc.FadeIn:create(0.2),
                cc.MoveBy:create(0.2, cc.p(0,38))), 
            cc.MoveBy:create(0.38, cc.p(0,17)),
            cc.Spawn:create(
                cc.MoveBy:create(0.4, cc.p(0,10)),
                cc.FadeOut:create(0.7)),
            cc.RemoveSelf:create(true))
        natureLab:runAction(seqnature)
    end

    local delayInterval = 0.3
    for k, v in pairs(tips) do
        createTipItem(v, (k - 1) * delayInterval)
    end
    local totalDelay = (#tips - 1) * delayInterval + 1
    floatTip:runAction(cc.Sequence:create(
        cc.DelayTime:create(totalDelay),
        cc.DelayTime:create(0.8),
        cc.RemoveSelf:create()
    ))
end

-- 创建兵团圣徽详情按钮
function UIUtils:createHolyDetailBtn( node ,param )
    local btn = ccui.Button:create()
    btn:loadTextures("button_holy_mainView.png","button_holy_mainView.png","button_holy_mainView.png",1)
    btn:setScale(0.6)
    btn:setPosition(param.pos or cc.p(0,0))
    param = param or {}
    
    if node then
        node:addChild(btn,999)
        registerClickEvent(btn,function() 
            DialogUtils.showHolyDetailDailog(param)
        end)
    end

    return btn
end

function UIUtils:createExclusiveInfoNode( parent, param )
    if not param then return end
    local teamData = param.teamData
    if not teamData or not parent then
        return
    end
    if not teamData.zLv and not teamData.zStar then
        local excData = tab.exclusive[teamData.teamId] or {}
        local isOpen = excData.isOpen
        if isOpen and isOpen == 1 then
            teamData.zLv = 0
        else
            return
        end
    end
    local node = cc.Node:create()
    if param.pos then
        node:setPosition(param.pos)
    else
        node:setPosition(0, 0)
    end
    parent:addChild(node)
    local icon = ccui.ImageView:create()
    icon:loadTexture("globalImage_exclusive_icon.png", 1)
    icon:setScale(0.5)
    icon:setPosition(0, 0)
    node:addChild(icon)

    local lvLab = ccui.Text:create()
    lvLab:setFontSize(18)
    lvLab:setFontName(UIUtils.ttfName)
    lvLab:setString(teamData.zLv or 0)
    lvLab:setAnchorPoint(cc.p(0, 0.5))
    lvLab:setColor(cc.c4b(255, 255, 255, 255))
    lvLab:enableOutline(cc.c4b(0, 0, 0, 255), 1)
    node:addChild(lvLab)

    local h = -icon:getContentSize().height * icon:getScale() / 2 - 10
    local starNum = (teamData.zStar or 0) - 1
    if starNum >= 0 then
        local starImg = ccui.ImageView:create()
        starImg:loadTexture("globalImageUI6_star4.png", 1)
        starImg:setPosition(-10, h)
        starImg:setScale(0.8)
        node:addChild(starImg)

        if starNum > 0 then
            starImg:loadTexture("globalImageUI6_star3.png", 1)
            local starLab = ccui.Text:create()
            starLab:setFontSize(18)
            starLab:setFontName(UIUtils.ttfName)
            starLab:setString(starNum)
            starLab:setPosition(starImg:getContentSize().width * starImg:getScale() / 2 + 2, starImg:getContentSize().height * starImg:getScale() / 2 + 2)
            starLab:enableOutline(cc.c4b(0, 0, 0, 255), 1)
            starImg:addChild(starLab)
        end

        lvLab:setPosition(0, h)
    else
        lvLab:setPosition(-lvLab:getContentSize().width / 2, h)
    end
end

function UIUtils:getAttrStrWithAttrName(id, num, notSpace)
	local attrTab = tab.attClient[id]
	local attrStr = lang("ATTR_" .. id)
	if notSpace then
		attrStr = attrStr .. "+" .. num
	else
		attrStr = attrStr .. " +" .. num
	end
	if attrTab and attrTab.attType==1 then
		attrStr = attrStr .. "%"
	end
	return attrStr
end

function UIUtils:getAttrValueStr(id, num)
	local attrTab = tab.attClient[id]
	local attrStr = "+" .. num
	if attrTab and attrTab.attType==1 then
		attrStr = attrStr .. "%"
	end
	return attrStr
end

--[[
--! @function adjustLevelShow
--! @desc 巅峰等级替换
--！@param
    lvlLab          原level元件
    inType          1水平 2垂直
    inData 
    {   lvlStr      原level元件setstring()的值(字符串形式)
        lvl         等级(非当前玩家可省)  
        plvl        巅峰等级(非当前玩家可省)
        disX, disY  位置微调 (可省)
        disScale    缩放比例（可省）
    }
--! @return table
--]]
function UIUtils:adjustLevelShow(lvlLab, inData, inType)
    local userData = ModelManager:getInstance():getModel("UserModel"):getData()
    local maxlevel = tab:Setting("MAX_LV").value
    local lvlStr = inData.lvlStr or ""
    local curLvl = inData.lvl or 0
    local plvl = inData.plvl or 0
    if not inData.lvl then
        curLvl = userData.lvl or 0
        plvl = userData.plvl or 0
    end
    
    if curLvl < maxlevel or plvl < 1 then
        lvlLab:setString(lvlStr)
        lvlLab:setVisible(curLvl > 0)
        if lvlLab._lvlNode then
            lvlLab._lvlNode:setVisible(false)
        end
        return lvlLab
    end

    --初始化必需数据
    inData = {
        disX = inData.disX or 0, 
        disY = inData.disY or 0,
        disScale = inData.disScale or 1
    }

    local tFontSize
    if lvlLab.getTTFConfig then
        tFontSize = lvlLab:getTTFConfig().fontSize
    else
        tFontSize = lvlLab:getFontSize()
    end
    local tAnchor = lvlLab:getAnchorPoint()
    lvlLab:setString("")

    if not lvlLab._lvlNode then
        local node = ccui.Layout:create()
        node:setBackGroundColorOpacity(0)
        node:setBackGroundColorType(1)
        node:setBackGroundColor(cc.c3b(100, 100, 0))
        node:setAnchorPoint(cc.p(0, 0.5))
        lvlLab:getParent():addChild(node)
        lvlLab._lvlNode = node

        --img
        local img = cc.Sprite:createWithSpriteFrameName("gImage_pLevel_icon.png")
        node:addChild(img)
        local imgAnim = mcMgr:createViewMC("dianfengdengji_dianfengdengji", true, false)
        imgAnim:setPosition(img:getContentSize().width / 2, img:getContentSize().height / 2)
        img:addChild(imgAnim)
        lvlLab._img = img

        --lvl
        local lvl = cc.Label:createWithTTF("", UIUtils.ttfName, tFontSize)
        lvl:setColor(cc.c4b(255, 234, 61, 255))
        lvl:enableOutline(UIUtils.colorTable.ccUIBaseOutlineColor, 1)
        node:addChild(lvl)
        lvlLab._lvl = lvl
    end
    lvlLab._lvlNode:setVisible(true)
    local node, img, lvl = lvlLab._lvlNode, lvlLab._img, lvlLab._lvl
    lvl:setString(plvl)

    local wid, hei = 0, 10
    if inType == 1 then   --水平
        lvl:setAnchorPoint(cc.p(0, 0.5))

        wid = img:getContentSize().width * img:getScale() + 5 + lvl:getContentSize().width
        hei = math.max(lvl:getContentSize().height, img:getContentSize().height * img:getScale())
        node:setContentSize(cc.size(wid, hei))

        img:setPosition(img:getContentSize().width * img:getScale() * 0.5 , hei * 0.5)
        lvl:setPosition(img:getContentSize().width * img:getScale() + 5, hei * 0.5)
    elseif inType == 2 then  --垂直
        lvl:setAnchorPoint(cc.p(0.5, 0.5))
        img:setScale(inData.disScale)

        wid = math.max(lvl:getContentSize().width, img:getContentSize().width * img:getScale())
        hei = lvl:getContentSize().height + img:getContentSize().height * img:getScale()
        node:setContentSize(cc.size(wid, hei))

        lvl:setPosition(wid * 0.5, lvl:getContentSize().height * 0.5)
        img:setPosition(wid * 0.5, lvl:getContentSize().height + img:getContentSize().height * img:getScale() * 0.5)
    end

    --调位置
    local posX, poxY = lvlLab:getPositionX(), lvlLab:getPositionY()
    if tAnchor.x == 0 then          --左对齐
        if inType == 1 then
            node:setPosition(posX + inData.disX, poxY + inData.disY)
        elseif inType == 2 then  
            node:setPosition(posX + inData.disX, poxY + hei * 0.5  + inData.disY)
        end
        
    elseif tAnchor.x == 1 then      --右对齐
        if inType == 1 then
            node:setPosition(posX + -wid + inData.disX, poxY + inData.disY)
        elseif inType == 2 then  
            node:setPosition(posX + -wid + inData.disX, poxY + hei * 0.5  + inData.disY)
        end
    else
        if inType == 1 then
            node:setPosition(posX + -wid * 0.5 + inData.disX, poxY + inData.disY)
        elseif inType == 2 then  
            node:setPosition(posX + -wid * 0.5 + inData.disX, poxY + hei * 0.5  + inData.disY)
        end
    end
    
    return node
end

function UIUtils.dtor()
    tc = nil
    UIUtils = nil
    fu = nil
end 

--[[
    s  ==> "xxxx{0}xxxx{1}xxxxx{2}"
    use==>UIUtils.fill(s, 100,200,100)
    return==> xxxx100xxxx200xxxxx100 
]]
function UIUtils.fill(s, ...)
    if s == nil then
        return ""
    end
    local o = tostring(s)
    for i = 1, select("#", ...) do
        o = o:gsub("{"..(i-1).."}", tostring((select(i, ...))))
    end
    return o
end

return UIUtils