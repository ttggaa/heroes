--[[
    Filename:    ACCommentGuideLayer.lua
    Author:      <wangyan@playcrab.com>
    Datetime:    2017-03-24 15:34
    Description: 评论引导活动
--]]

local ACCommentGuideLayer = class("ACCommentGuideLayer", require("game.view.activity.common.ActivityCommonLayer"))

function ACCommentGuideLayer:ctor(params)
    ACCommentGuideLayer.super.ctor(self)
    self._container = params.container
end

function ACCommentGuideLayer:onInit()
	self._modelMgr:getModel("CommentGuideModel"):setAcShowRed(1)  --已显示过

	local bg = self:getUI("bg")
    bg:setBackGroundImage("asset/bg/comment_acBg.jpg")

    --reward
    local itemId = tab.comaward["COMAWARD_NAME"]["award1Show"][1][2]
    local itemNum = tab.comaward["COMAWARD_NAME"]["award1Show"][1][3]
	local itemData = tab:AvatarFrame(itemId)
	local rwdIcon = IconUtils:createHeadFrameIconById({itemId = itemId, itemData = itemData})
	rwdIcon:setAnchorPoint(cc.p(0.5, 0.5))
    rwdIcon:setPosition(188, 149)
    rwdIcon:setScale(0.85)
    bg:addChild(rwdIcon)

    --btn
	local cmtBtn = self:getUI("bg.cmtBtn")
	self:registerClickEvent(cmtBtn, function()
		--跳转ios
		-- self._isClick = true
		cmtBtn:setTouchEnabled(false)
		sdkMgr:loadUrl({type = "1", url = GameStatic.CommentGuide_ios_url})
		-- if OS_IS_WINDOWS then
			self._serverMgr:sendMsg("UserServer", "getIOSCommentAward", {}, true, {}, function (result)
				DialogUtils.showGiftGet({
		            gifts = result["reward"], 
		            callback = function() 
                        if self._container and self._container.refreshUI then
                            self._container:refreshUI()
                        end
                    end
		            })
				end)
		-- end
 	end)
end

function ACCommentGuideLayer:applicationWillEnterForeground(seconds)
	-- if self._isClick and self._isClick == true then
	-- 	self._serverMgr:sendMsg("UserServer", "getIOSCommentAward", {}, true, {}, function (result)
	-- 		DialogUtils.showGiftGet({
	--             gifts = result["reward"], 
	--             callback = function() end
	--             })
	-- 		end)
	-- end
end

return ACCommentGuideLayer