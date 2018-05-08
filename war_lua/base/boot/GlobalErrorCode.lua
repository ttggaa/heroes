--
-- Author: huachangmiao@playcrab.com
-- Date: 2016-09-23 17:13:04
--

-- 全局错误码
local ttf = cc.FileUtils:getInstance():fullPathForFilename("static/common.ttf")
function showGlobalErrorCode(uiWidget, errorCode, ex)
	if uiWidget.___errorLabel == nil then
		local errorLabel = cc.Label:createWithTTF("状态码 "..errorCode, ttf, 20)
		errorLabel:setColor(cc.c3b(255, 0, 0))
		-- errorLabel:runAction(cc.RepeatForever:create(cc.Sequence:create( cc.TintTo:create(3, 50, 50, 255), cc.TintTo:create(3, 255, 50, 50) )))
		-- errorLabel:enableOutline(cc.c4b(0, 0, 0, 255), 1)
		local width = uiWidget:getContentSize().width
		errorLabel:setAnchorPoint(0.5, 0)
		errorLabel:setPosition(width * 0.5, 6)
		uiWidget:addChild(errorLabel, 999999)
		uiWidget.___errorLabel = errorLabel
	else
		uiWidget.___errorLabel:setString("状态码 "..errorCode)
	end
	if errorCode and GameStatic.uploadErrorCode then
        if ex == nil then
            ex = ""
        end
		ApiUtils.playcrab_lua_error("errorCode_"..tostring(errorCode), ex, "code")
	end
end

function removeGlobalErrorCode(uiWidget)
	if uiWidget.___errorLabel then
		uiWidget.___errorLabel:removeFromParent()
		uiWidget.___errorLabel = nil
	end
end

--[[
	6661001+ : vms
	6662001+ : global
	6663001+ : login
	6664001+ : kakura
	6665001+ : battle
]]--


function showGlobalErrorCodeTip(x, y, errorCode)
	local scene = cc.Director:getInstance():getRunningScene()
	if scene.___errorLabel == nil then
		local errorLabel = cc.Label:createWithTTF("状态码 "..errorCode, ttf, 20)
		errorLabel:setColor(cc.c3b(0, 255, 0))
		-- errorLabel:runAction(cc.RepeatForever:create(cc.Sequence:create( cc.TintTo:create(3, 50, 50, 255), cc.TintTo:create(3, 255, 50, 50) )))
		errorLabel:setPosition(x, y)
		scene:addChild(errorLabel, 999999)
		scene.___errorLabel = errorLabel

		local mask = ccui.Layout:create()
	    mask:setBackGroundColorOpacity(255)
	    mask:setBackGroundColorType(1)
	    mask:setBackGroundColor(cc.c3b(0,0,0))
	    mask:setContentSize(MAX_SCREEN_WIDTH, 40)
	    mask:setOpacity(180)
	    mask:setAnchorPoint(0.5, 0.5)
	    mask:setPosition(x, y)
	    scene:addChild(mask, 999998)   
	    errorLabel.mask = mask
	else
		scene.___errorLabel:setString("状态码 "..errorCode)
	end
	scene.___errorLabel.tick = os.time()
end

function removeGlobalErrorCodeTip()
	local scene = cc.Director:getInstance():getRunningScene()
	if scene.___errorLabel then
		if os.time() > scene.___errorLabel.tick + 4 then
			scene.___errorLabel.mask:removeFromParent()
			scene.___errorLabel:removeFromParent()
			scene.___errorLabel = nil
		end
	end
end



