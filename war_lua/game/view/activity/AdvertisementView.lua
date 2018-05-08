--[[
    Filename:    AdvertisementView.lua
    Author:      <wangyan@playcrab.com>
    Datetime:    2016-05-18 14:43
    Description: 游戏广告界面
--]]

local AdvertisementView = class("AdvertisementView", BasePopView)

local director = cc.Director:getInstance()
local winSize = {width = MAX_SCREEN_WIDTH, height = MAX_SCREEN_HEIGHT}
local isAdjust = false   --是否是调试状态
local fu = cc.FileUtils:getInstance()

function AdvertisementView:ctor(param)
	AdvertisementView.super.ctor(self)
	self._adTb = self._modelMgr:getModel("AdvertisementModel"):getAdList()   	--广告列表
	-- dump(self._adTb, "", 5)
	-- -- 广告debug===============================
	-- self._adTb = {}
	-- self._adTb[#self._adTb+1] = tab.advertise[21]
	-- self._adTb[#self._adTb+1] = tab.advertise[60]
	-- self._adTb[#self._adTb+1] = tab.advertise[61]
	-- self._adTb[#self._adTb+1] = tab.advertise[62]
	-- self._adTb[#self._adTb+1] = tab.advertise[63]
	-- -- ========================================

	self._callback = param.callback
	isAdjust = param.isAdjust or false
	self._currShowIndex = 1     --当前展示的广告顺序
end

function AdvertisementView:getAsyncRes()
    return {
    	{"asset/bg/cloudCityBg1.plist", "asset/bg/cloudCityBg1.png"}
    }
end

function AdvertisementView:onInit()
	self.__maskLayer:setBackGroundColor(cc.c3b(0,0,0))

	local adjustBg = self:getUI("adjustBg")
	adjustBg:setVisible(false)
	if isAdjust then
		adjustBg:setVisible(true)
		self:adjustPosByInput()
		return
	end

	self:initAdConfigList()
	self:updateAdShowImg()

	--右上角 关闭按钮 
	local closeBtn = ccui.Button:create("activity_close_btn.png", "activity_close_btn.png", "activity_close_btn.png", 1)
	closeBtn:setPosition(cc.p(winSize.width/2 + 440, winSize.height/2 + 20 + 204))
	self:addChild(closeBtn, 10)
	self:registerClickEvent(closeBtn, function() 
		if self._callback then
        	self._callback()
        end
		UIUtils:reloadLuaFile("activity.AdvertisementView")
		self:close()
		end)

	--切换按钮
	local switchBtn = ccui.Button:create()  
	switchBtn:loadTextures("globalButtonUI13_1_1.png", "globalButtonUI13_1_1.png", "globalButtonUI13_1_1.png", 1)
	switchBtn:setPosition(cc.p(winSize.width/2, winSize.height * 0.09 + 10))
	switchBtn:setTitleFontName(UIUtils.ttfName)
	self:L10N_Text(switchBtn)
	-- switchBtn:setTitleColor(cc.c4b(255, 255, 255, 255))
	-- switchBtn:getTitleRenderer():enableOutline(cc.c4b(124, 64, 0, 255), 2)
	switchBtn:setTitleText("我知道了")
	switchBtn:setTitleFontSize(22)	
	self:addChild(switchBtn)
	self:registerClickEvent(switchBtn, function() 
		self:updateAdShowImg()
		end)
end

--切换广告页
function AdvertisementView:updateAdShowImg()
	local imgPath = "asset/other/ad/"
	if #self._adTb < self._currShowIndex then
        if self._callback then
        	self._callback()
        end
        UIUtils:reloadLuaFile("activity.AdvertisementView")
		self:close(false)

	else
		local curSysData = self._adTb[self._currShowIndex]

		local adImgName = curSysData.activity_id  
		adImgName = string.gsub(adImgName, " ", "")
		local isSuffix = string.find(adImgName, ".jpg")
		if isSuffix then
			adImgName = string.sub(adImgName,1, string.len(adImgName)-4)
		end
		

		------------大图
		-------------------------------
		if self.adImg == nil then
			self.adImg = ccui.ImageView:create()
			self.adImg:setAnchorPoint(cc.p(0.5,0.5))
			self:addChild(self.adImg)
		end
		self.adImg:removeAllChildren()
		self.adImg:loadTexture(imgPath .. adImgName .. ".jpg")
		self.adImg:setPosition(cc.p(winSize.width/2, winSize.height/2 + 20))
		print("=====================广告图", adImgName)

		------------小图
		local adInfo = self._adResList[adImgName]
		---------------------------------
		--英雄交锋 / 冠军对决 / 积分联赛
		if adImgName == "ad_heroMatch" or adImgName == "ad_champion" or adImgName == "ad_citybattle" then
			self:adjustAdHeroMatchOrChampion(adImgName)

		--巢穴特惠返利
		elseif adImgName == "ad_nest" then   
			self:adjustAdNest()

		--真人训练场
		elseif adImgName == "ad_train" then
			self:adjustTrain()

		--策划配表控制位置
		elseif curSysData["imgPos"] then
			for k,v in ipairs(curSysData["imgPos"]) do
				local resTemp = imgPath .. adImgName .. "_" .. k .. ".png"
				if fu:isFileExist(resTemp) then
					local pic = ccui.ImageView:create(resTemp) 
					pic:setAnchorPoint(cc.p(0, 0))
					pic:setPosition(v[1], v[2])
					self.adImg:addChild(pic, 1)
				end
			end

		--统一配置
		elseif adInfo then
			if adInfo["res"] then 	--小图
				for k,v in ipairs(adInfo["res"]) do
					local picPath, picZOrder = imgPath, 1
					if v[4] and v[4] ~= "" then
						picPath = v[4]
					end
					if v[5] then
						picZOrder = v[5]
					end

					local resTemp = picPath .. v[1] .. ".png"
					if fu:isFileExist(resTemp) then
						local pic = ccui.ImageView:create(resTemp) 
						pic:setAnchorPoint(cc.p(0, 0))
						pic:setPosition(v[2], v[3])
						self.adImg:addChild(pic, picZOrder)
					end
				end
			end

			-- 单张图
			if adInfo["sp"] then
				for i,v in ipairs(adInfo["sp"]) do
					local sp = cc.Sprite:createWithSpriteFrameName(v[1])
					sp:setPosition(v[3], v[4])
					sp:setScale(v[2])
					self.adImg:addChild(sp)
				end
			end

			-- 道具图标
			if adInfo["item"] then
				for i,v in ipairs(adInfo["item"]) do
					local icon = IconUtils:createItemIconById({itemId = v[1] ,itemData = tab.tool[v[1]],eventStyle = 0,effect = true})
					icon:setPosition(v[3], v[4])
					icon:setScale(v[2])
					self.adImg:addChild(icon)
				end
			end

			--按钮
			if adInfo["btn"] then
				for i,v in ipairs(adInfo["btn"]) do
					local resPath = imgPath .. v[1] .. ".png"
					local btn = ccui.Button:create(resPath, resPath, resPath, 0)
					btn:setPosition(cc.p(v[2], v[3]))
					self.adImg:addChild(btn)
					self:registerClickEvent(btn, function() 
						if v[4] and type(v[4]) == "function" then
							v[4]()
						end
						end)
				end
			end
		end

		------------描述
		-------------------------------
		local des = curSysData.des
		if des then
			local imgWid = self.adImg:getContentSize().width
			local richTxt = RichTextFactory:create(lang(des), imgWid, 0)   
			richTxt:setPixelNewline(true)              
		    richTxt:formatText()
		    self.adImg:addChild(richTxt, 10)

		    if adInfo and adInfo["des"] and adInfo["des"][1] then
		    	local desPos = adInfo["des"][1]
		    	richTxt:setPosition(desPos[1] + imgWid * 0.5 + (imgWid - richTxt:getRealSize().width) * 0.5, desPos[2])
		    else
		    	richTxt:setPosition(imgWid * 0.5 + (imgWid - richTxt:getRealSize().width) * 0.5, 19)
		    end
		end

		self._currShowIndex = self._currShowIndex + 1
	end
end

-- 真人训练场
function AdvertisementView:adjustTrain()
	local pic1 = ccui.ImageView:create("asset/other/ad/ad_train_1.png") 
	pic1:setAnchorPoint(cc.p(0, 0))
	pic1:setPosition(98, 469)
	self.adImg:addChild(pic1)

    local imgWid = self.adImg:getContentSize().width
	local richTxt = RichTextFactory:create(lang("TRAINING_ACTIVITY_SHOW_4"), imgWid, 0)   
	richTxt:setPixelNewline(true)              
    richTxt:formatText()
    richTxt:setPosition(imgWid * 0.5 + (imgWid - richTxt:getRealSize().width) * 0.5, 21)
    self.adImg:addChild(richTxt)
end

--巢穴
function AdvertisementView:adjustAdNest()
	local pic1 = ccui.ImageView:create("asset/uiother/team/t_dafashi.png") --role
	pic1:setPosition(self.adImg:getContentSize().width - 895, self.adImg:getContentSize().height * 0.5 + 26)
	pic1:setScale(0.85)
	self.adImg:addChild(pic1, 1)

    local rightDown = cc.Sprite:createWithSpriteFrameName("cloudCityBg_CloudLeftBottom.png")
    rightDown:setPosition(989, -145)
    rightDown:setScaleX(-1)
    self.adImg:addChild(rightDown, 2)

    local rightUp = cc.Sprite:createWithSpriteFrameName("cloudCityBg_CloudLeftTop.png")
    rightUp:setPosition(879, 524)
    rightUp:setScaleX(-1)	
    self.adImg:addChild(rightUp, 2)

    local leftBottom = cc.Sprite:createWithSpriteFrameName("cloudCityBg_CloudRightBottom.png")
    leftBottom:setPosition(132, -47)
    leftBottom:setScaleX(-1)
    self.adImg:addChild(leftBottom, 2)

    local leftUp = cc.Sprite:createWithSpriteFrameName("cloudCityBg_CloudRightTop.png")
    leftUp:setPosition(-17, 459)
    leftUp:setScaleX(-1)
    self.adImg:addChild(leftUp, 2)
end

--英雄交锋 / 积分联赛
function AdvertisementView:adjustAdHeroMatchOrChampion(inType)
	local days, posY, tipDes, acId
	if inType == "ad_heroMatch" then
		acId, posY = 104, 21
		tipDes = "HERODUEL_PAILIAN"
	elseif inType == "ad_champion" then
		acId, posY = 101, 21
		tipDes = "LEAGUE_PAILIAN"
	else
		acId, posY = 102, 25
		tipDes = "CITYBATTLE_PAILIAN"
	end
	days = tab.sTimeOpen[acId]["opentime"] - 1

	local secTime = self._modelMgr:getModel("UserModel"):getData().sec_open_time
	local sec_time = TimeUtils.getIntervalByTimeString(TimeUtils.getDateString(secTime,"%Y-%m-%d 05:00:00"))
	if secTime < sec_time then   --过零点判断
		sec_time = sec_time - 86400
	end
	local openTime = sec_time + 24 * 3600 * days   --开服第几天
	local timeStr = tonumber(TimeUtils.date("%m", openTime)) .. "月" .. tonumber(TimeUtils.date("%d", openTime)) ..  "日"

    local imgWid = self.adImg:getContentSize().width
	local richTxt = RichTextFactory:create(string.gsub(lang(tipDes), "{$date}", timeStr), imgWid, 0)   
	richTxt:setPixelNewline(true)              
    richTxt:formatText()
    richTxt:setPosition(imgWid * 0.5 + (imgWid - richTxt:getRealSize().width) * 0.5, posY)
    self.adImg:addChild(richTxt)
end

--运营调位置配表
function AdvertisementView:adjustPosByInput()
	local imgPath = "asset/other/ad/"

	local pathDes = self:getUI("adjustBg.pathDes")
	pathDes:setString("【调图路径】：war/client_win/asset/other/ad/...   【小图命名规则】：大图资源名_数字")
	local pathDes_0 = self:getUI("adjustBg.pathDes_0")
	pathDes_0:setString("【svn提图路径】：war/svn/Assets/asset/other/ad...")

	local closeBtn = self:getUI("adjustBg.closeBtn")
	self:registerClickEvent(closeBtn, function()
		UIUtils:reloadLuaFile("activity.AdvertisementView")
		self:close()
		end)

	for i=1, 4 do
		--输入框
		local inputBg = self:getUI("adjustBg.input" .. i)
		local input = self:getUI("adjustBg.input" .. i .. ".input")
	    input:setTouchEnabled(false)
	    input.rectifyPos = true
	    input.openCustom = true
	    input:setPlaceHolder("")
	    input:setTextColor(UIUtils.colorTable.ccUIBaseTextColor2)
	    input:setPlaceHolderColor(UIUtils.colorTable.ccUIInputTipColor)

	    input.handleLen = function(sender, param)
	        local temp = string.gsub(param,"(<[^>]+>)$", "")
	        if temp ~= param then 
	            param = temp
	            sender:setString(param)
	        else
	            sender:setString(utf8.sub(param, 1 , (sender:getMaxLength() - 1)))
	        end
	        return true
	    end

	    self:registerClickEvent(inputBg, function ()
	        input:attachWithIME()
	    end)
	end

	local adjustBg = self:getUI("adjustBg")
	local enterBtn = self:getUI("adjustBg.enterBtn")
	local img = self:getUI("adjustBg.img")
	local input1 = self:getUI("adjustBg.input1.input")
	local input2 = self:getUI("adjustBg.input2.input")
	local input3 = self:getUI("adjustBg.input3.input")
	local input4 = self:getUI("adjustBg.input4.input")
	self:registerClickEvent(enterBtn, function()
		local imgRes = input1:getString()
		local imgIndex = input2:getString()
		local posX = input3:getString()
		local posY = input4:getString()

		--大图
		if imgRes ~= "" then
			local resName = imgPath .. imgRes .. ".jpg"
			img:loadTexture(resName)
			img:removeAllChildren()

			local sizeImg = img:getContentSize()
			if sizeImg.width ~= 940 and sizeImg.height ~= 470 then
				self._viewMgr:showTip("图片尺寸不对：" .. sizeImg.width .."*" .. sizeImg.height)
			end

			local fu = cc.FileUtils:getInstance()
			local aaa = fu:getFileSize(resName) 
			if (aaa / 1024) > 160 then
				self._viewMgr:showTip("图片过大，应小于160kb，当前：" .. (aaa / 1024) .. "kb")
			end
		end

		--小图
		if imgIndex ~= "" and posX ~= "" and posY ~= "" then
			local imgS = ccui.ImageView:create(imgPath .. imgRes .. "_" .. tonumber(imgIndex) .. ".png")
			imgS:setAnchorPoint(cc.p(0, 0))
			imgS:setPosition(tonumber(posX), tonumber(posY))
			img.imgS = imgS
			img:addChild(imgS, 1)
		end
		end)

	local left = self:getUI("adjustBg.left")
	local right = self:getUI("adjustBg.right")
	local up = self:getUI("adjustBg.up")
	local down = self:getUI("adjustBg.down")
	self:registerClickEvent(left, function()
		if not img.imgS then
			return
		end
		local x = img.imgS:getPositionX()
		img.imgS:setPositionX(x - 1)
		input3:setString(x - 1)
		end)

	self:registerClickEvent(right, function()
		if not img.imgS then
			return
		end
		local x = img.imgS:getPositionX()
		img.imgS:setPositionX(x + 1)
		input3:setString(x + 1)
		end)

	self:registerClickEvent(up, function()
		if not img.imgS then
			return
		end
		local x = img.imgS:getPositionY()
		img.imgS:setPositionY(x + 1)
		input4:setString(x + 1)
		end)

	self:registerClickEvent(down, function()
		if not img.imgS then
			return
		end
		local x = img.imgS:getPositionY()
		img.imgS:setPositionY(x - 1)
		input4:setString(x - 1)
		end)
end

--获取装饰配置（小图 + 描述）
--配置规则：大图.jpg，小图.png  描述配富文本
--des = {[1] = {0, 19},}  不填des默认为0,19
function AdvertisementView:initAdConfigList()
	local adImgW, adImgH = 940, 470
	local adImgPosX, adImgPosY = winSize.width/2, winSize.height/2 + 20
	local pathType = {"asset/uiother/team/", "asset/other/ad/"}
			
	self._adResList = {
		["ad_battleFrist"] = {  --战力第一
			res = { 
				[1] = {"ad_battleFrist_1", 264, -35}, [2] = {"ad_battleFrist_2", 27, 469}}, 
			},

		["ad_login"] = {		--每日登陆
			res = {
				[1] = {"ad_login_1", 939, 269}, [2] = {"ad_login_2", 649, 469},
			}, 
			},

		["ad_wuyao"] = {		--巫妖
			res = {
				[1] = {"ad_wuyao_1", 372, 469},
			}, 
			},

		["ad_carnival"] = {		--嘉年华
			res = {
				[1] = {"ad_carnival_1", 562, 469},
			},
			}, 

		["ad_firstpay"] = {  	--首冲
			res = {
				[1] = {"ad_firstpay_1", -52, 10}, [2] = {"ad_firstpay_2", 0, 469},
			}, 
			},

		["ad_role_datianshi"] = { 			--大天使英雄
			res = {
				[1] = {"ad_role_datianshi1", 360, 470},
			}, 
			},

		["ad_role_tiexuedaofeng"] = {  		--铁血交锋英雄
			res = {
				[1] = {"ad_role_tiexuedaofeng1", 297, 470},
			}, 
			},

		["ad_onegem"] = { 					--1钻购
			res = {
				[1] = {"ad_onegem_1", -81, 148},
			}, 
			des = {[1] = {-324, 20},}
			},

		["ad_dayRecharge"] = {  			--每日充值
			des = {[1] = {0, 21},}
			},

		["ad_hero_luolande"] = { 	 		--hero罗伊德
			res = {
				[1] = {"ad_hero_luolande_1", 96, 358}
			}, 
			},

		["ad_element_corps"] = { 			--元素神兵
			res = {
				[1] = {"ad_element_corps_1", 484, 464},
			}, 
			des = {[1] = {0, 25},}
			},

		["ad_limitT_leiyuansu"] = { 		--限时活动 雷元素
			res = {
				[1] = {"ad_limitT_leiyuansu_1", 10, 468},
			}, 
			},

		["ad_limitT_shangjinlieren"] = { 	--限时活动 赏金猎人
			res = {
				[1] = {"ad_limitT_shangjinlieren_1", 99, 469},
			}, 
			},

		["ad_shendeng"] = { 				--兵团 神灯
			res = {
				[1] = {"ad_shendeng_1", 230, 469}, [2] = {"ad_shendeng_2", 193, -106},
			}, 
			},

		["ad_hero_suomula"] = { 			--兵团 索姆拉
			res = {
				[1] = {"ad_hero_suomula_1", 189, 470},
			}, 
			},

		["ad_txtv_gift"] = {  				--腾讯视频给积分
			des = {[1] = {0, 20},}
			},

		["ad_shiyuansu"] = { 				--石元素
			res = {
				[1] = {"ad_shiyuansu_1", -87, 250}, [2] = {"ad_shiyuansu_2", 67, 464},
			}, 
			des = {[1] = {0, 22},}
			},

		["ad_dayRecharge2"] = { 			--每日充值2
			res = {
				[1] = {"ad_dayRecharge2_1", 569, 465}, [2] = {"ad_dayRecharge2_2", 798, 466},
			}, 
			des = {[1] = {0, 20},}
			},

		["ad_treasurebottle"] = { 			--宝物精华
			res = {
				[1] = {"ad_treasurebottle_1", 301, 470},
			}, 
			des = {[1] = {0, 18},}
			},

		["ad_cValentinesday"] = {  			--七夕
			res = {
				[1] = {"ad_cValentinesday_1", 616, 469},
			}, 
			des = {[1] = {0, 20},},
			sp = {[1] = {"avatarFrame_27.png", 0.7, 300, 95}, [2] = {"avatarFrame_28.png", 0.7, 384, 95},},
			item = {[1] = {3906, 0.8, 45, 58}, [2] = {3002, 0.8, 123, 58},}
			},

		["ad_stonesale"] = {  				--符石特惠
			des = {[1] = {-135, 169},}
			},

		["ad_hero_zeda"] = {  				--泽达
			res = {
				[1] = {"ad_hero_zeda_1", 449, 464},
			}, 
			des = {[1] = {0, 20},}
			},

		["ad_bimeng"] = {  					--比蒙
			res = {
				[1] = {"ad_bimeng_1", 367, 470},
			}, 
			},

		["ad_hero_keerge"] = {  			--英雄科尔格
			res = {
				[1] = {"ad_hero_keerge_1", 319, 465},
			}, 
			},

		["ad_ZF_login"] = {  				--专服登录
			res = {
				[1] = {"ad_ZF_login_1", 639, 465},
			}, 
			},

		["ad_VIPGIFT"] = {  				--VIP礼包
			res = {
				[1] = {"ad_VIPGIFT_1", 137, 465},
			}, 
			},

		["ad_wxgame"] = {  					--微信游戏送福利
			btn = {
				[1] = {"ad_wxgame_1", 470, 109, function()
					print("AD_wxGame_url:", GameStatic.AD_wxGame_url)  
					sdkMgr:loadUrl({url = GameStatic.AD_wxGame_url})
					end},
			}, 
			},

		["ad_xinyue"] = {  					--心悦运营圈
			btn = {
				[1] = {"ad_xinyue_1", 470, 60, function()
					print("AD_xinyueClub_url:", GameStatic.AD_xinyueClub_url)  
					sdkMgr:loadUrl({url = GameStatic.AD_xinyueClub_url})
					end},
			}, 
			},

		["ad_tuiguangyuan3"] = {  			--好友招募
			res = {
				[1] = {"ad_tuiguangyuan3_1", 624, 465},
			}, 
			},

		["ad_ZF_heroduel"] = {  			--交锋竞技
			res = {
				[1] = {"ad_ZF_heroduel_1", 367, 465},
			}, 
			},

		["ad_sale_wuyao"] = {  				--累充特惠 巫妖/活体鹰眼
			res = {
				[1] = {"ad_sale_wuyao_1", 508, 469},
			}, 
			},

		["ad_guoqing_1"] = {  				--累充特惠 巫妖/活体鹰眼
			res = {
				[1] = {"ad_guoqing_1_1", 265, 468},
			}, 
			},

		["ad_sale_munaiyi"] = {  			--木乃伊
			res = {
				[1] = {"ad_sale_munaiyi_1", 118, 465},
			}, 
			},

		["ad_role_gulong"] = {  			--骨龙
			res = {
				[1] = {"ad_role_gulong_1", 282, 469},
			}, 
			},

		["ad_sale_niutouguai"] = {  		--骨龙招募
			res = {
				[1] = {"ad_sale_niutouguai_1", -64, 226},
			}, 
			},

		["ad_sale_Medusa"] = {  			--美杜莎
			res = {
				[1] = {"ad_sale_Medusa_1", 201, 448},
			}, 
			},

		["ad_community"] = {  				--微社区
			res = {
				[1] = {"ad_community_1", 255, 468},
			}, 
			},

		["ad_siege_instrument"] = {  		--微社区
			res = {
				[1] = {"ad_siege_instrument_1", 88, 434},
			}, 
			},

		["ad_dayRecharge3"] = {  			--鬼王斗篷
			res = {
				[1] = {"ad_dayRecharge3_1", 537, 463},
			}, 
			},

		["ad_hero_Xeron"] = {  				--赛尔伦
			res = {
				[1] = {"ad_hero_Xeron_1", 145, 470},
			}, 
			},

		["ad_role_daemo"] = {  				--大恶魔
			res = {
				[1] = {"ad_role_daemo_1", 237, 470},
			}, 
			},

		["ad_team_Beholder"] = {  				--大恶魔
			res = {
				[1] = {"ad_team_Beholder_1", 97, 464},
			}, 
			},

		["ad_bimeng_awake"] = {  				--大恶魔
			res = {
				[1] = {"ad_bimeng_awake_1", 4, 468},
			}, 
			},

		["ad_tuiguangyuan4"] = {  				--好友招募
			res = {
				[1] = {"ad_tuiguangyuan4_1", 422, 464},
			}, 
			},

		["ad_wuyao_awake"] = {  				--觉醒巫妖
			res = {
				[1] = {"ad_wuyao_awake_1", 16, 464},
			}, 
			},
	}
end

function AdvertisementView.dtor()
	director = nil
	winSize = nil
	isAdjust = nil
	fu = nil
end

return AdvertisementView